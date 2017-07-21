 #ifndef __OBJ_COMBAT__
 #define __OBJ_COMBAT__

/*
		The combat object

		The obj_Combat object is a bot-support module designed to be used
		with EVEBOT.  It provides a common framework for combat decissions
		that the various bot modules can call.

		USAGE EXAMPLES
		--------------

		objectdef obj_Miner
		{
				variable string SVN_REVISION = "$Rev$"
				variable int Version

				variable obj_Combat Combat

				method Initialize()
				{
						;; bot module initialization
						;; ...
						;; ...
						;; call the combat object's init routine
						This.Combat:Initialize
						;; set the combat "mode"
						This.Combat:SetMode["DEFENSIVE"]
				}

				method Pulse()
				{
						if ${EVEBot.Paused}
								return
						if !${Config.Common.BotModeName.Equal[Miner]}
								return
						;; bot module frame action code
						;; ...
						;; ...
						;; call the combat frame action code
						This.Combat:Pulse
				}

				function ProcessState()
				{
						if !${Config.Common.BotModeName.Equal[Miner]}
								return

						; call the combat object state processing
						call This.Combat.ProcessState

						; see if combat object wants to
						; override bot module state.
						if ${This.Combat.Fled}
								return

						; process bot module "states"
						switch ${This.CurrentState}
						{
								;; ...
								;; ...
						}
				}
		}

		COMBAT OBJECT "MODES"
		---------------------

				* DEFENSIVE -- If under attack (by NPCs) AND damage taken exceeds threshold, fight back
				* AGGRESSIVE -- If hostile NPC is targeted, destroy it
				* TANK      -- Maintain defenses but attack nothing

				NOTE: The combat object will activate and maintain your "tank" in all modes.
							It will also manage any enabled "flee" state.

		-- GliderPro
*/

objectdef obj_Combat
{
	variable string SVN_REVISION = "$Rev$"
	variable int Version

	variable time NextPulse
	variable int PulseIntervalInSeconds = 1

	variable string CombatMode
	variable string CurrentState = "IDLE"
	variable bool   Fled = FALSE

	method Initialize()
	{
		This.CombatMode:Set["AGGRESSIVE"]
		UI:UpdateConsole["obj_Combat: Initialized", LOG_MINOR]
	}

	method Shutdown()
	{
	}

	method Pulse()
	{
		if ${EVEBot.Paused}
		{
			This.ManageTank
			return
		}

		if ${Time.Timestamp} >= ${This.NextPulse.Timestamp}
		{
			This:SetState

			This.NextPulse:Set[${Time.Timestamp}]
			This.NextPulse.Second:Inc[${This.PulseIntervalInSeconds}]
			This.NextPulse:Update
		}
	}

	method SetState()
	{
		if ${Me.InStation} == TRUE
		{
	  		This.CurrentState:Set["INSTATION"]
	  		return
		}

		if ${Ship.IsPod}
		{
			UI:UpdateConsole["Warning: We're in a pod, running"]
			This.CurrentState:Set["FLEE"]
			return
		}

		if ${EVEBot.ReturnToStation}
		{
			This.CurrentState:Set["FLEE"]
			return
		}

		if ${This.CombatMode.NotEqual["TANK"]} && ${Me.TargetCount} > 0
		{
			This.CurrentState:Set["FIGHT"]
		}
		else
		{
			This.CurrentState:Set["IDLE"]
		}
	}

	method SetMode(string newMode)
	{
		This.CombatMode:Set[${newMode}]
	}

	member:string Mode()
	{
		return ${This.CombatMode}
	}

	function ProcessState()
	{
		;; Scripts need to check *both* if it's in station AND if it's in space.   (See "Pulse" method of the ship object)
		if (${This.CurrentState.NotEqual["INSTATION"]} && ${Me.InSpace})
		{
			if ${Me.ToEntity.IsWarpScrambled}
			{
				; TODO - we need to quit if a red warps in while we're scrambled -- cybertech
				UI:UpdateConsole["Warp Scrambled: Ignoring System Status"]
			}
			elseif !${Social.IsSafe} || ${Social.PossibleHostiles}
			{
				UI:UpdateConsole["Debug: Fleeing: Local isn't safe"]
				call This.Flee
				return
			}
			elseif ${This.CombatMode.NotEqual["TANK"]} && !${Ship.IsAmmoAvailable}
			{
				if ${Config.Combat.RestockAmmo}
				{
					UI:UpdateConsole["Restocking Ammo: Low ammo"]
					call This.RestockAmmo
					return
				}
				elseif ${Config.Combat.RunOnLowAmmo}
				{
					UI:UpdateConsole["Fleeing: Low due to ammo"]
					; TODO - what to do about being warp scrambled in this case?
					call This.Flee
					return
				}
			}
			call This.ManageTank
		}

		UI:UpdateConsole["Debug: Combat: This.Fled = ${This.Fled} This.CurrentState = ${This.CurrentState} Social.IsSafe = ${Social.IsSafe}", LOG_DEBUG]

		switch ${This.CurrentState}
		{
			case INSTATION
				if ${Social.IsSafe}
				{
					call Station.Undock
				}
				break
			case IDLE
				break
			case FLEE
				call This.Flee
				break
			case RESTOCK
				call This.RestockAmmo
			case FIGHT
				call This.Fight
				break
		}
	}

	function Fight()
	{
		Ship:Deactivate_Cloak
		variable int Count = 0
		while ${Count:Inc} < 10 && ${Ship.IsCloaked}
		{
			wait 5
		}
		if ${Ship.IsCloaked}
		{
			UI:UpdateConsole["Error: Ship.IsCloaked still true after 5 seconds", LOG_CRITICAL]
		}
		;Ship:Offline_Cloak
		;Ship:Online_Salvager

		; Reload the weapons -if- ammo is below 30% and they arent firing
		Ship:Reload_Weapons[FALSE]

		if ${Config.Combat.Orbit}
		{
			Ship:Activate_AfterBurner

			if ${Config.Combat.OrbitAtOptimal}
			{
				Ship:OrbitAtOptimal
			}
			else
			{
				Me.ActiveTarget:Orbit[${Config.Combat.OrbitDistance}]
			}
		}
		if ${Config.Combat.KeepAtRange}
		{
			Ship:Activate_AfterBurner

			if ${Config.Combat.KeepAtRangeAtOptimal}
			{
				Ship:KeepAtRangeAtOptimal
			}
			else
			{
				Me.ActiveTarget:KeepAtRange[${Config.Combat.KeepAtRangeDistance}]
			}
		}
		; Activate the weapons, the modules class checks if there's a target (no it doesn't - ct)
		Ship:Activate_TargetPainters
		Ship:Activate_StasisWebs
		Ship:Activate_Weapons
		if ${Me.TargetedByCount} >= ${Me.TargetCount}
		{
			Ship.Drones:SendDrones
		}
		elseif ${Me.TargetedByCount} < ${Me.TargetCount}
		{
; Note - this will break if targetedby is greater than we can target, such as in an anomaly, or low sp char.
			EVE:Execute[CmdDronesReturnToBay]
		}
	}

	function Flee()
	{
		This.CurrentState:Set["FLEE"]
		if !${This.Fled}
		{
			Sound:Speak["Fleeing to safespot! Aura, I need warp speed in three minutes or we're all dead!", 1.1]
		}
		This.Fled:Set[TRUE]
		EVE:Execute[CmdDronesReturnToBay]

		if ${Config.Combat.RunToStation}
		{
			call This.FleeToStation
		}
		else
		{
			call This.FleeToSafespot
		}
		; This is not a safe wait, but some folks like it.
		;wait ${Math.Rand[3600]:Inc[3000]}
	}

	function FleeToStation()
	{
		if !${Station.Docked}
		{
			call Station.Dock
		}
	}

	function FleeToSafespot()
	{
		if ${Safespots.IsAtSafespot}
		{
			if !${Ship.IsCloaked}
			{
				Ship:Activate_Cloak[]
			}
			; This is not a safe wait, but some folks like it.
			;wait ${Math.Rand[3600]:Inc[3000]}

		}
		else
		{
			; Are we at the safespot and not warping?
			if ${Me.ToEntity.Mode} != 3
			{
				call Safespots.WarpTo
				wait 30
			}
		}
	}

	method CheckTank()
	{
		if ${This.Fled}
		{
			/* don't leave the "fled" state until we regen */
			if (${Ship.IsPod} || \
				${MyShip.ArmorPct} < 50 || \
				(${MyShip.ShieldPct} < 80 && ${Config.Combat.MinimumShieldPct} > 0) || \
				${MyShip.CapacitorPct} < 60 )
			{
				This.CurrentState:Set["FLEE"]
				UI:UpdateConsole["Debug: Staying in Flee State: Armor: ${MyShip.ArmorPct} Shield: ${MyShip.ShieldPct} Cap: ${MyShip.CapacitorPct}", LOG_DEBUG]
			}
			else
			{
				This.Fled:Set[FALSE]
				This.CurrentState:Set["IDLE"]
			}
		}
		elseif (${MyShip.ArmorPct} < ${Config.Combat.MinimumArmorPct}  || \
				${MyShip.ShieldPct} < ${Config.Combat.MinimumShieldPct} || \
				${MyShip.CapacitorPct} < ${Config.Combat.MinimumCapPct})
		{
			UI:UpdateConsole["Armor is at ${MyShip.ArmorPct.Int}%%: ${MyShip.Armor.Int}/${MyShip.MaxArmor.Int}", LOG_CRITICAL]
			UI:UpdateConsole["Shield is at ${MyShip.ShieldPct.Int}%%: ${MyShip.Shield.Int}/${MyShip.MaxShield.Int}", LOG_CRITICAL]
			UI:UpdateConsole["Cap is at ${MyShip.CapacitorPct.Int}%%: ${MyShip.Capacitor.Int}/${MyShip.MaxCapacitor.Int}", LOG_CRITICAL]

			if !${Config.Combat.RunOnLowTank}
			{
				UI:UpdateConsole["Run On Low Tank Disabled: Fighting", LOG_CRITICAL]
			}
			elseif ${Me.ToEntity.IsWarpScrambled}
			{
				UI:UpdateConsole["Warp Scrambled: Unable To Flee", LOG_CRITICAL]
			}
			else
			{
				UI:UpdateConsole["Fleeing due to defensive status", LOG_CRITICAL]
				This.CurrentState:Set["FLEE"]
			}
		}
	}

	function ManageTank()
	{
		if ${MyShip.ArmorPct} < 100
		{
			/* Turn on armor reps, if you have them
				Armor reps do not rep right away -- they rep at the END of the cycle.
				To counter this we start the rep as soon as any damage occurs.
			*/
			Ship:Activate_Armor_Reps[]
		}
		elseif ${MyShip.ArmorPct} > 98
		{
			Ship:Deactivate_Armor_Reps[]
		}

		if ${MyShip.ShieldPct} < 85 || ${Config.Combat.AlwaysShieldBoost}
		{   /* Turn on the shield booster, if present */
			Ship:Activate_Shield_Booster[]
		}
		elseif ${MyShip.ShieldPct} > 95 && !${Config.Combat.AlwaysShieldBoost}
		{
			Ship:Deactivate_Shield_Booster[]
		}

		if ${MyShip.CapacitorPct} < 20
		{   /* Turn on the cap booster, if present */
			Ship:Activate_Cap_Booster[]
			Ship:Deactivate_ECM_Burst
		}
		elseif ${MyShip.CapacitorPct} > 80
		{
			Ship:Deactivate_Cap_Booster[]
			Ship:Activate_ECM_Burst
		}

		if ${This.CombatMode.NotEqual["TANK"]}
		{
			if !${This.Fled} && ${Config.Combat.LaunchCombatDrones} && \
				${Ship.Drones.DronesInSpace[FALSE]} == 0 && !${Ship.InWarp} && \
				${Me.TargetCount} > 0
			{
				if ${Config.Combat.AnomalyAssistMode}
				{
					Ship.Drones:LaunchAll[]
				}
				elseif ${Me.TargetCount} >= 1 && ${Me.TargetedByCount} >= ${Me.TargetCount}
				{
					Ship.Drones:LaunchAll[]
				}
			}
		}

		; Activate shield (or armor) hardeners
		; If you don't have hardeners this code does nothing.
		if ${Me.TargetedByCount} > 0
		{
			Ship:Activate_Hardeners[]
		}
		else
		{
			Ship:Deactivate_Hardeners[]
		}

		This:CheckTank
	}

/* This does the following:
	1) Checks for a CHA on grid. If one exists, it drops off all inventory
	2) Checks for a GSC, and fills cargo with ammo
*/
	function RestockAmmo()
	{
		variable int QuantityToMove
		variable index:item ContainerItems
		variable iterator CargoIterator

		if ${Config.Combat.RunToStation}
		{
			if !${Station.Docked}
			{
				call Station.Dock
			}

			EVE:Execute[OpenHangarFloor]
			wait 10
			MyShip:GetCargo[ContainerItems]
			ContainerItems:GetIterator[CargoIterator]
			if ${CargoIterator:First(exists)}
			{
				do
				{
					CargoIterator.Value:MoveTo[MyStationHangar, Hangar]
					wait 2
				}
				while ${CargoIterator:Next(exists)}
			}
			EVEWindow[ByName, "hangarFloor"]:StackAll
			wait 20
			ContainerItems:Clear
			Me.Station:GetHangarItems[ContainerItems]
		}
		else
		{
			if ${Ammospots:IsThereAmmospotBookmark}
			{
				UI:UpdateConsole["RestockAmmo: Fleeing: No ammo bookmark"]
				call This.Flee
				return
			}
			else
			{
				call Ammospots.WarpTo
				UI:UpdateConsole["Restocking ammo"]
				call Ship.OpenCargo
				; If a corp hangar array is on grid - drop loot
				if ${Entity["TypeID = 17621"].ID} != NULL
				{
					UI:UpdateConsole["Restocking from ${Entity["TypeID = 17621"]} (${Entity["TypeID = 17621"].ID})"]
					call Ship.Approach ${Entity["TypeID = 17621"].ID} 2000
					call Ship.OpenCargo
					Entity["TypeID = 17621"]:Open

					; Drop off all loot/leftover ammo
					; TODO - don't dump the ammo we're using for our own weapons. Do dump other ammo that we might have looted.
					call Cargo.TransferCargoToCorpHangarArray

					Entity["TypeID = 17621"]:GetCargo[ContainerItems]
				}

				; If there is no CHA, but there is a GSC, Take Ammo, do not drop off items
				else
				{
					UI:UpdateConsole["Restocking from ${Entity["GroupID =340"]} (${Entity["GroupID = 340"].ID})"]
					call Ship.Approach ${Entity["GroupID = 340"].ID} 2000

					Entity["GroupID = 340"]:Open
					wait 30
					Entity["GroupID = 340"]:GetCargo[ContainerItems]
				}
			}
		}
		ContainerItems:GetIterator[CargoIterator]
		if ${CargoIterator:First(exists)}
		{
			do
			{
				if ${CargoIterator.Value.TypeID} == ${Config.Combat.AmmoTypeID}
				{
					if (${CargoIterator.Value.Quantity} * ${CargoIterator.Value.Volume}) > ${Ship.CargoFreeSpace}
					{
						QuantityToMove:Set[${Math.Calc[(${Ship.CargoFreeSpace} - ${Config.Combat.RestockAmmoFreeSpace}) / ${CargoIterator.Value.Volume} - 1]}]
					}
					else
					{
						QuantityToMove:Set[${CargoIterator.Value.Quantity}]
					}
					UI:UpdateConsole["TransferListToShip: Loading Cargo: ${QuantityToMove} units (${Math.Calc[${QuantityToMove} * ${CargoIterator.Value.Volume}]}m3) of ${CargoIterator.Value.Name}"]
					UI:UpdateConsole["TransferListToShip: Loading Cargo: DEBUG: TypeID = ${CargoIterator.Value.TypeID}, GroupID = ${CargoIterator.Value.GroupID}"]
					if ${QuantityToMove} > 0
					{
						CargoIterator.Value:MoveTo[${MyShip.ID},CargoHold,${QuantityToMove}]
						wait 30
						EVEWindow[ByItemID, ${MyShip.ID}]:StackAll
						wait 10
					}
						if ${Ship.CargoFreeSpace} <= ${Config.Combat.RestockAmmoFreeSpace}
					{
						UI:UpdateConsole["DEBUG: RestockAmmo Done: Ship Cargo: ${Ship.CargoFreeSpace} < ${Config.Combat.RestockAmmoFreeSpace}", LOG_DEBUG]
						break
					}
				}
			}
			while ${CargoIterator:Next(exists)}
		}
		else
		{
			UI:UpdateConsole["DEBUG: obj_Cargo:TransferListToShip: Nothing found to move"]
			UI:UpdateConsole["Debug: Fleeing: No ammo left in can"]
			call This.Flee
			return
		}
	}
}


#endif /* __OBJ_COMBAT__ */