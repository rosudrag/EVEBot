objectdef obj_Targets
{
	variable string SVN_REVISION = "$Rev$"
	variable int Version

	variable index:string ChainTargets
	variable iterator ChainTarget

	variable bool CheckChain
	variable bool Chaining
	variable int  TotalSpawnValue

	variable bool m_SpecialTargetPresent
	variable bool m_SpecialTargettoLootPresent
	variable string m_SpecialTargetName
	variable string m_SpecialTargetToLootName
	variable set DoNotKillList
	variable bool CheckedSpawnValues = FALSE

	variable obj_targets_ignore TargetIgnoreService
	variable obj_targets_special TargetSpecialService
	variable obj_targets_special_loot TargetSpecialLootService
	variable obj_targets_priority TargetsPriorityService
	
	;	Used to track entities that are locked or being locked
	variable index:entity LockedOrLocking


	method Initialize()
	{
		This.TargetIgnoreService:Initialize
		This.TargetSpecialService:Initialize
		This.TargetsPriorityService:Initialize
		This.TargetSpecialLootService:Initialize

		m_SpecialTargetPresent:Set[FALSE]
		m_SpecialTargetToLootPresent:Set[FALSE]

        DoNotKillList:Clear
	}

	method ResetTargets()
	{
		This.CheckChain:Set[TRUE]
		This.Chaining:Set[FALSE]
		This.CheckedSpawnValues:Set[FALSE]
		This.TotalSpawnValue:Set[0]
	}

	member:bool SpecialTargetPresent()
	{
		return ${m_SpecialTargetPresent}
	}

	member:bool SpecialTargetToLootPresent()
	{
		return ${m_SpecialTargetToLootPresent}
	}

	member:bool TargetNPCs()
	{
		if ${Config.Combat.SkipFight}
		{
			return ${This.ScoutNPCs}
		}
		else
		{
			return ${This.TargetNPCsClassic}
		}
	}

	member:bool ScoutNPCs()
	{
		variable index:entity Targets
		variable iterator Target

		EVE:QueryEntities[Targets, "CategoryID = CATEGORYID_ENTITY && Distance <= 500000"]
		Targets:GetIterator[Target]

		if !${Target:First(exists)}
		{
			UI:UpdateConsole["No npcs found..."]
			return FALSE
		}

		variable bool HasTargets = FALSE

		; Start looking for (and locking) priority targets
		; special targets and chainable targets, only priority
		; targets will be locked in this loop
		variable bool HasSpecialTarget = FALSE

		m_SpecialTargetPresent:Set[FALSE]
		m_SpecialTargetToLootPresent:Set[FALSE]

		; Determine the total spawn value
		if ${Target:First(exists)} && !${This.CheckedSpawnValues}
		{
			This.CheckedSpawnValues:Set[TRUE]
			do
			{
				variable int pos
				variable string NPCName
				variable string NPCGroup
				variable string NPCShipType

				NPCName:Set[${Target.Value.Name}]
				NPCGroup:Set[${Target.Value.Group}]
				pos:Set[1]
				while ${NPCGroup.Token[${pos}, " "](exists)}
				{
					NPCShipType:Set[${NPCGroup.Token[${pos}, " "]}]
					pos:Inc
				}
				UI:UpdateConsole["NPC: ${NPCName}(${NPCShipType}) ${EVEBot.ISK_To_Str[${Target.Value.Bounty}]}"]

				switch ${Target.Value.GroupID}
				{
					case GROUP_LARGECOLLIDABLEOBJECT
					case GROUP_LARGECOLLIDABLESHIP
					case GROUP_LARGECOLLIDABLESTRUCTURE
					case GROUP_SENTRYGUN
					case GROUP_CONCORDDRONE
					case GROUP_CUSTOMSOFFICIAL
					case GROUP_POLICEDRONE
					case GROUP_CONVOYDRONE
					case GROUP_CONVOY
					case GROUP_FACTIONDRONE
					case GROUP_BILLBOARD
						continue

					default
						break
				}
				if ${Target.Value.Bounty} > 0
				{
					This.TotalSpawnValue:Inc[${Target.Value.Bounty}]
				}
			}
			while ${Target:Next(exists)}
			UI:UpdateConsole["NPC: Spawn Value is ${EVEBot.ISK_To_Str[${This.TotalSpawnValue}]}"]
		}

		if ${Target:First(exists)}
		{
			variable int TypeID
			TypeID:Set[${Target.Value.TypeID}]
			do
			{
	            switch ${Target.Value.GroupID}
	            {
					case GROUP_LARGECOLLIDABLEOBJECT
					case GROUP_LARGECOLLIDABLESHIP
					case GROUP_LARGECOLLIDABLESTRUCTURE
					case GROUP_SENTRYGUN
					case GROUP_CONCORDDRONE
					case GROUP_CUSTOMSOFFICIAL
					case GROUP_POLICEDRONE
					case GROUP_CONVOYDRONE
					case GROUP_CONVOY
					case GROUP_FACTIONDRONE
					case GROUP_BILLBOARD
						continue

					default
						break
	            }

				; Check for a special target
				if ${This.TargetSpecialService.IsSpecialTarget[${Target.Value.Name}]}
				{
					HasSpecialTarget:Set[TRUE]
					m_SpecialTargetPresent:Set[TRUE]
					m_SpecialTargetName:Set[${Target.Value.Name}]
					if ${This.TargetSpecialLootService.IsSpecialTargetToLoot[${Target.Value.Name}]}
					{
						m_SpecialTargetToLootPresent:Set[TRUE]
						m_SpecialTargetToLootName:Set[${Target.Value.Name}]
					}
				}

				; Loop through the priority targets
				if ${This.TargetsPriorityService.IsPriorityTarget[${Target.Value.Name}]}
				{
					HasTargets:Set[TRUE]
				}
			}
			while ${Target:Next(exists)}
		}

		return ${HasTargets}
	}

	member:bool TargetNPCsClassic()
	{
		variable index:entity Targets
		variable iterator Target

		EVE:QueryEntities[Targets, "CategoryID = CATEGORYID_ENTITY && Distance <= ${MyShip.MaxTargetRange}"]
		
		Targets:GetIterator[Target]

		if !${Target:First(exists)}
		{
			if ${Ship.IsDamped}
			{	/* Ship.MaxTargetRange contains the maximum undamped value */
				EVE:QueryEntities[Targets, "CategoryID = CATEGORYID_ENTITY && Distance <= ${Ship.MaxTargetRange}"]
				Targets:GetIterator[Target]

				if !${Target:First(exists)}
				{
					UI:UpdateConsole["No targets found..."]
					return FALSE
				}
				else
				{
					UI:UpdateConsole["Damped, cant target..."]
					return TRUE
				}
			}
			else
			{
				UI:UpdateConsole["No targets found..."]
				return FALSE
			}
		}

		if ${MyShip.MaxLockedTargets} == 0
		{
			UI:UpdateConsole["Jammed, cant target..."]
			return TRUE
		}

		; Chaining means there might be targets here which we shouldnt kill
		variable bool HasTargets = FALSE

		; Start looking for (and locking) priority targets
		; special targets and chainable targets, only priority
		; targets will be locked in this loop
		variable bool HasPriorityTarget = FALSE
		variable bool HasChainableTarget = FALSE
		variable bool HasSpecialTarget = FALSE
		variable bool HasMultipleTypes = FALSE

		m_SpecialTargetPresent:Set[FALSE]
		m_SpecialTargetToLootPresent:Set[FALSE]

      ; Determine the total spawn value
      if ${Target:First(exists)} && !${This.CheckedSpawnValues}
      {
		This.CheckedSpawnValues:Set[TRUE]
         do
         {
         	variable int pos
         	variable string NPCName
         	variable string NPCGroup
         	variable string NPCShipType

         	NPCName:Set[${Target.Value.Name}]
			NPCGroup:Set[${Target.Value.Group}]
			pos:Set[1]
        	while ${NPCGroup.Token[${pos}, " "](exists)}
        	{
				;echo ${NPCGroup.Token[${pos}, " "]}
        		NPCShipType:Set[${NPCGroup.Token[${pos}, " "]}]
        		pos:Inc
        	}
            UI:UpdateConsole["NPC: ${NPCName}(${NPCShipType}) ${EVEBot.ISK_To_Str[${Target.Value.Bounty}]}"]

            ;UI:UpdateConsole["DEBUG: Type: ${Target.Value.Type}(${Target.Value.TypeID})"]
            ;UI:UpdateConsole["DEBUG: Category: ${Target.Value.Category}(${Target.Value.CategoryID})"]

            switch ${Target.Value.GroupID}
            {
               case GROUP_LARGECOLLIDABLEOBJECT
               case GROUP_LARGECOLLIDABLESHIP
               case GROUP_LARGECOLLIDABLESTRUCTURE
               case GROUP_SENTRYGUN
               case GROUP_CONCORDDRONE
               case GROUP_CUSTOMSOFFICIAL
               case GROUP_POLICEDRONE
               case GROUP_CONVOYDRONE
               case GROUP_CONVOY
			   case GROUP_FACTIONDRONE
			   case GROUP_BILLBOARD
                  continue

               default
                  break
            }
			if ${NPCGroup.Find["Battleship"](exists)}
			{
            	This.TotalSpawnValue:Inc[${Target.Value.Bounty}]
            }
         }
         while ${Target:Next(exists)}
         UI:UpdateConsole["NPC: Battleship Value is ${EVEBot.ISK_To_Str[${This.TotalSpawnValue}]}"]
      }

      if ${This.TotalSpawnValue} >= ${Config.Combat.MinChainBounty}
      {
         ;UI:UpdateConsole["NPC: Spawn value exceeds minimum.  Should chain this spawn."]
         HasChainableTarget:Set[TRUE]
      }

		if ${Target:First(exists)}
		{
			variable int TypeID
			TypeID:Set[${Target.Value.TypeID}]
			do
			{
	            switch ${Target.Value.GroupID}
	            {
	               case GROUP_LARGECOLLIDABLEOBJECT
	               case GROUP_LARGECOLLIDABLESHIP
	               case GROUP_LARGECOLLIDABLESTRUCTURE
	               case GROUP_SENTRYGUN
		           case GROUP_CONCORDDRONE
	               case GROUP_CUSTOMSOFFICIAL
	               case GROUP_POLICEDRONE
                   case GROUP_CONVOYDRONE
                 case GROUP_CONVOY
				   case GROUP_FACTIONDRONE
    			   case GROUP_BILLBOARD
	                  continue

	               default
	                  break
	            }

				; If the Type ID is different then there's more then 1 type in the belt
				if ${TypeID} != ${Target.Value.TypeID}
				{
					HasMultipleTypes:Set[TRUE]
				}

				; Check for a special target
				if ${This.TargetSpecialService.IsSpecialTarget[${Target.Value.Name}]}
				{
					HasSpecialTarget:Set[TRUE]
					m_SpecialTargetPresent:Set[TRUE]
					m_SpecialTargetName:Set[${Target.Value.Name}]
					if ${This.TargetSpecialLootService.IsSpecialTargetToLoot[${Target.Value.Name}]}
					{
						m_SpecialTargetToLootPresent:Set[TRUE]
						m_SpecialTargetToLootName:Set[${Target.Value.Name}]
					}
				}

				; Loop through the priority targets
				if ${This.TargetsPriorityService.IsPriorityTarget[${Target.Value.Name}]}
				{
					; Yes, is it locked?
					if !${Target.Value.IsLockedTarget} && !${Target.Value.BeingTargeted}
					{
						; No, report it and lock it.
						UI:UpdateConsole["Locking priority target ${Target.Value.Name}"]
						Target.Value:LockTarget
					}

					; By only saying there's priority targets when they arent
					; locked yet, the npc bot will target non-priority targets
					; after it has locked all the priority targets
					; (saves time once the priority targets are dead)
					if !${Target.Value.IsLockedTarget}
					{
						HasPriorityTarget:Set[TRUE]
					}

					; We have targets
					HasTargets:Set[TRUE]
				}
			}
			while ${Target:Next(exists)}
		}

		; Determine if we need to chain
		if ${Config.Combat.ChainSpawns} && ${CheckChain}
		{
			; Is there a chainable target? Is there a special or priority target?
			if ${HasChainableTarget} && !${HasSpecialTarget} && !${HasPriorityTarget}
			{
	        	UI:UpdateConsole["NPC: Chaining Spawn"]
				Chaining:Set[TRUE]
			}

			; Special exception, if there is only 1 type its most likely a chain in progress
			if !${HasMultipleTypes} && !${HasPriorityTarget}
			{
	        	UI:UpdateConsole["NPC: Chaining Spawn"]
				Chaining:Set[TRUE]
			}

			if ${HasSpecialTarget}
			{
				UI:UpdateConsole["NPC: Not Chaining: Special targets present"]
				Chaining:Set[FALSE]
			}

			if ${HasPriorityTarget}
			{
				UI:UpdateConsole["NPC: Not Chaining: EWar Rats present"]
				Chaining:Set[FALSE]
			}

			;skip chaining if chain solo == false and we are alone
			if !${Config.Combat.ChainSolo} && ${EVE.LocalsCount} == 1
			{
				UI:UpdateConsole["NPC: Not Chaining: ChainSolo disabled"]
				Chaining:Set[FALSE]
			}

			CheckChain:Set[FALSE]
		}

		; If there was a priority target, dont worry about targeting the rest
		if !${HasPriorityTarget} && ${Target:First(exists)}
		do
		{
			switch ${Target.Value.GroupID}
			{
				case GROUP_LARGECOLLIDABLEOBJECT
				case GROUP_LARGECOLLIDABLESHIP
				case GROUP_LARGECOLLIDABLESTRUCTURE
				case GROUP_SENTRYGUN
				case GROUP_CONCORDDRONE
				case GROUP_CUSTOMSOFFICIAL
				case GROUP_POLICEDRONE
				case GROUP_CONVOYDRONE
				case GROUP_CONVOY
				case GROUP_FACTIONDRONE
			    case GROUP_BILLBOARD
					continue

				default
					break
			}

			variable bool DoTarget = FALSE
			if ${Chaining}
			{
				; We're chaining, only kill chainable spawns'
                if ${Target.Value.Group.Find["Battleship"](exists)}
                {
                   DoTarget:Set[TRUE]
                }
			}
			else
			{
				; Target everything
				DoTarget:Set[TRUE]
			}

            ; override DoTarget to protect partially spawned chains
            if ${DoNotKillList.Contains[${Target.Value.ID}]}
            {
				DoTarget:Set[FALSE]
            }

			; ignore ignored target
			if ${This.TargetIgnoreService.IsIgnoredTarget[${Target.Value.Name}]}
            {
				UI:UpdateConsole["NPC: ignoring ${Target.value.Name}"]
				DoTarget:Set[FALSE]
            }

			; Do we have to target this target?
			if ${DoTarget}
			{
				if !${Target.Value.IsLockedTarget} && !${Target.Value.BeingTargeted}
				{
					if ${Me.TargetCount} < ${Ship.MaxLockedTargets}
					{
						if ${Ship.TypeID} == TYPE_RIFTER
						{
							if ${Target.Value.Distance} > ${MyShip.MaxTargetRange}
							{
								if ${Me.ToEntity.Approaching.NotEqual[NULL]}
								{
									Target.Value:Approach
								}
							}
						}
						else
						{
							UI:UpdateConsole["Locking ${Target.Value.Name}"]
							Target.Value:LockTarget
						}
					}
				}

				; Set the return value so we know we have targets
				HasTargets:Set[TRUE]
			}
			else
			{
				if !${DoNotKillList.Contains[${Target.Value.ID}]}
				{
					UI:UpdateConsole["NPC: Adding ${Target.Value.Name} (${Target.Value.Group})(${Target.Value.ID}) to the \"do not kill list\"!"]
					DoNotKillList:Add[${Target.Value.ID}]
				}
				; Make sure (due to auto-targeting) that its not targeted
				if ${Target.Value.IsLockedTarget}
				{
					Target.Value:UnlockTarget
				}
			}
		}
		while ${Target:Next(exists)}

		;if ${HasTargets} && ${Me.ActiveTarget(exists)}
		;{
		;	variable int OrbitDistance
		;	OrbitDistance:Set[${Math.Calc[${MyShip.MaxTargetRange}*0.40/1000].Round}]
		;	OrbitDistance:Set[${Math.Calc[${OrbitDistance}*1000]}]
		;	Me.ActiveTarget:Orbit[${OrbitDistance}]
		;}
		
		;if ${HasTargets} && ${Me.ActiveTarget(exists)}
		;{
		;	variable int KeepAtRangeDistance
		;	KeepAtRangeDistance:Set[${Math.Calc[${MyShip.MaxTargetRange}*0.40/1000].Round}]
		;	KeepAtRangeDistance:Set[${Math.Calc[${KeepAtRangeDistance}*1000]}]
		;	Me.ActiveTarget:KeepAtRange[${KeepAtRangeDistance}]
		;}

		return ${HasTargets}
	}

	member:bool PC()
	{
		variable index:entity tgtIndex
		variable iterator tgtIterator

		EVE:QueryEntities[tgtIndex, "CategoryID = CATEGORYID_SHIP"]
		tgtIndex:GetIterator[tgtIterator]

		if ${tgtIterator:First(exists)}
		do
		{
			; todo - make ignoring whitelisted chars in your belt an optional action.
			if ${tgtIterator.Value.Owner.CharID} != ${Me.CharID} && !${Social.PilotWhiteList.Contains[${tgtIterator.Value.Owner.CharID}]}
			{	/* A player is already present here ! */
				UI:UpdateConsole["Player found ${tgtIterator.Value.Owner} ${tgtIterator.Value.Owner.CharID} ${tgtIterator.Value.ID}"]
				return TRUE
			}
		}
		while ${tgtIterator:Next(exists)}

		; No other players around
		return FALSE
	}

	member:bool NPC()
	{
		variable index:entity tgtIndex
		variable iterator tgtIterator

		EVE:QueryEntities[tgtIndex, "CategoryID = CATEGORYID_ENTITY"]
		UI:UpdateConsole["DEBUG: Found ${tgtIndex.Used} entities."]

		tgtIndex:GetIterator[tgtIterator]
		if ${tgtIterator:First(exists)}
		do
		{
			switch ${tgtIterator.Value.GroupID}
			{
				case GROUP_CONCORDDRONE
				case GROUP_CONVOYDRONE
				case GROUP_CONVOY
				case GROUP_LARGECOLLIDABLEOBJECT
				case GROUP_LARGECOLLIDABLESHIP
				case GROUP_LARGECOLLIDABLESTRUCTURE
					;UI:UpdateConsole["DEBUG: Ignoring entity ${tgtIterator.Value.Group} (${tgtIterator.Value.GroupID})"]
					continue
					break
				default
					UI:UpdateConsole["DEBUG: NPC found: ${tgtIterator.Value.Group} (${tgtIterator.Value.GroupID})"]
					return TRUE
					break
			}
		}
		while ${tgtIterator:Next(exists)}

		; No NPCs around
		return FALSE
	}

	member:int64 Rat()
	{
		variable index:entity tgtIndex
		variable iterator tgtIterator

		EVE:QueryEntities[tgtIndex, "CategoryID = CATEGORYID_ENTITY"]

		tgtIndex:GetIterator[tgtIterator]
		if ${tgtIterator:First(exists)}
		do
		{
			switch ${tgtIterator.Value.GroupID}
			{
				case GROUP_CONCORDDRONE
				case GROUP_CONVOYDRONE
				case GROUP_CONVOY
				case GROUP_LARGECOLLIDABLEOBJECT
				case GROUP_LARGECOLLIDABLESHIP
				case GROUP_LARGECOLLIDABLESTRUCTURE
					;UI:UpdateConsole["DEBUG: Ignoring entity ${tgtIterator.Value.Group} (${tgtIterator.Value.GroupID})"]
					continue
					break
				default
					UI:UpdateConsole["ALERT: Targeting: ${tgtIterator.Value.Group}"]
					return ${tgtIterator.Value.ID}
					break
			}
		}
		while ${tgtIterator:Next(exists)}

		; No NPCs around
		return -1
	}
	
	method UpdateLockedAndLockingTargets()
	{
		variable index:entity Targets
		variable iterator Target

		LockedOrLocking:Clear
		EVE:QueryEntities[Targets]
		Targets:GetIterator[Target]
		if ${Target:First(exists)}
			do
			{
				if ${Target.Value.IsLockedTarget} || ${Target.Value.BeingTargeted}
					LockedOrLocking:Insert[${Target.Value}]
			}
			while ${Target:Next(exists)}
	}
	member:int LockedAndLockingTargets()
	{
		variable index:entity Targets
		variable iterator Target

		LockedOrLocking:Clear
		EVE:QueryEntities[Targets]
		Targets:GetIterator[Target]
		if ${Target:First(exists)}
			do
			{
				if ${Target.Value.IsLockedTarget} || ${Target.Value.BeingTargeted}
					LockedOrLocking:Insert[${Target.Value}]
			}
			while ${Target:Next(exists)}
		return ${LockedOrLocking.Used}
	}
}
