/*
    Targets to prioritise
    
*/

objectdef obj_targets_priority
{
    variable obj_targets_generic GenericTargetsService
    
	method Initialize()
	{
        This.GenericTargetsService:Initialize
        
        This.GenericTargetsService:AddFilteredItemName["Factory Defense Battery"] 		/* web/scram */
		This.GenericTargetsService:AddFilteredItemName["Dire Pithi Arrogator"] 		/* web/scram */
		This.GenericTargetsService:AddFilteredItemName["Dire Pithi Despoiler"] 		/* Jamming */
		This.GenericTargetsService:AddFilteredItemName["Dire Pithi Imputor"] 		/* web/scram */
		This.GenericTargetsService:AddFilteredItemName["Dire Pithi Infiltrator"] 	/* web/scram */
		This.GenericTargetsService:AddFilteredItemName["Dire Pithi Invader"] 		/* web/scram */
		This.GenericTargetsService:AddFilteredItemName["Dire Pithi Saboteur"] 		/* Jamming */
		This.GenericTargetsService:AddFilteredItemName["Dire Pithi Annihilator"] 	/* Jamming */
		This.GenericTargetsService:AddFilteredItemName["Dire Pithi Killer"] 			/* Jamming */
		This.GenericTargetsService:AddFilteredItemName["Dire Pithi Murderer"] 		/* Jamming */
		This.GenericTargetsService:AddFilteredItemName["Dire Pithi Nullifier"] 		/* Jamming */
		This.GenericTargetsService:AddFilteredItemName["Dire Guristas Arrogator"] 		/* web/scram */
		This.GenericTargetsService:AddFilteredItemName["Dire Guristas Despoiler"] 		/* Jamming */
		This.GenericTargetsService:AddFilteredItemName["Dire Guristas Imputor"] 		/* web/scram */
		This.GenericTargetsService:AddFilteredItemName["Dire Guristas Infiltrator"] 	/* web/scram */
		This.GenericTargetsService:AddFilteredItemName["Dire Guristas Invader"] 		/* web/scram */
		This.GenericTargetsService:AddFilteredItemName["Dire Guristas Saboteur"] 		/* Jamming */
		This.GenericTargetsService:AddFilteredItemName["Dire Guristas Annihilator"] 	/* Jamming */
		This.GenericTargetsService:AddFilteredItemName["Dire Guristas Killer"] 			/* Jamming */
		This.GenericTargetsService:AddFilteredItemName["Dire Guristas Murderer"] 		/* Jamming */
		This.GenericTargetsService:AddFilteredItemName["Dire Guristas Nullifier"] 		/* Jamming */

		This.GenericTargetsService:AddFilteredItemName["Guristas Nullifier"]

		This.GenericTargetsService:AddFilteredItemName["Arch Angel Hijacker"]
		This.GenericTargetsService:AddFilteredItemName["Arch Angel Outlaw"]
		This.GenericTargetsService:AddFilteredItemName["Arch Angel Rogue"]
		This.GenericTargetsService:AddFilteredItemName["Arch Angel Thug"]
		This.GenericTargetsService:AddFilteredItemName["Sansha's Loyal"]

		This.GenericTargetsService:AddFilteredItemName["Guardian Agent"]		    /* web/scram */
		This.GenericTargetsService:AddFilteredItemName["Guardian Initiate"]		    /* web/scram */
		This.GenericTargetsService:AddFilteredItemName["Guardian Scout"]		    /* web/scram */
		This.GenericTargetsService:AddFilteredItemName["Guardian Spy"]			    /* web/scram */
		This.GenericTargetsService:AddFilteredItemName["Crook Watchman"]		    /* damp */
		This.GenericTargetsService:AddFilteredItemName["Guardian Watchman"]		    /* damp */
		This.GenericTargetsService:AddFilteredItemName["Serpentis Watchman"]	    /* damp */
		This.GenericTargetsService:AddFilteredItemName["Crook Patroller"]		    /* damp */
		This.GenericTargetsService:AddFilteredItemName["Guardian Patroller"]	    /* damp */
		This.GenericTargetsService:AddFilteredItemName["Serpentis Patroller"]	    /* damp */

		This.GenericTargetsService:AddFilteredItemName["Elder Blood Upholder"]	    /* web/scram */
		This.GenericTargetsService:AddFilteredItemName["Elder Blood Worshipper"]    /* web/scram */
		This.GenericTargetsService:AddFilteredItemName["Elder Blood Follower"]	    /* web/scram */
		This.GenericTargetsService:AddFilteredItemName["Elder Blood Herald"]	    /* web/scram */
		This.GenericTargetsService:AddFilteredItemName["Blood Wraith"]	            /* web/scram */
		This.GenericTargetsService:AddFilteredItemName["Blood Disciple"]	        /* web/scram */

		This.GenericTargetsService:AddFilteredItemName["Strain Decimator Drone"]    /* web/scram */
		This.GenericTargetsService:AddFilteredItemName["Strain Infester Drone"]     /* web/scram */
		This.GenericTargetsService:AddFilteredItemName["Strain Render Drone"]       /* web/scram */
		This.GenericTargetsService:AddFilteredItemName["Strain Splinter Drone"]     /* web/scram */
        UI:UpdateConsole["obj_targets_priority: Initialized", LOG_MINOR]
	}

    member:bool IsPriorityTarget(string name)
	{
        return ${This.GenericTargetsService.IsFilteredItem[${name}]}
	}
}
