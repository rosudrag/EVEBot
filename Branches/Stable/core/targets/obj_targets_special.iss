/* Special NPCS */
/*
Officer spawns appear in their home region, or in any region where their
faction normally appears, but *only* in systems with -0.8 or below true
sec rating.

Faction: Guristas/Pithi/Dread Guristas
Home Region: Venal
Officers:
Estamel Tharchon
Vepas Minimala
Thon Eney
Kaikka Peunato


Faction: Angels/Gisi/Domination
Home Region: Curse
Officers:
Tobias Kruzhor
Gotan Kreiss
Hakim Stormare
Mizuro Cybon

Faction: Serpentis/Coreli/Shadow:
Home Region: Fountain
Officers:
Cormack Vaaja
Setele Schellan
Tuvan Orth
Brynn Jerdola

Faction: Sanshas/Centi/True Sansha:
Home Region: Stain
Officers:
Chelm Soran
Vizan Ankonin
Selynne Mardakar
Brokara Ryver

Faction: Blood/Corpi/Dark Blood:
Home Region: Delve
Officers:
Draclira Merlonne
Ahremen Arkah
Raysere Giant
Tairei Namazoth
*/

objectdef obj_targets_special
{
	variable obj_targets_generic GenericTargetsService
       
    method Initialize()
    {
		This.SoundService:Initialize

		This.GenericTargetsService:AddFilteredItemName["Gotan Kreiss"]
		This.GenericTargetsService:AddFilteredItemName["Hakim Stormare"]
		This.GenericTargetsService:AddFilteredItemName["Mizuro Cybon"]
		This.GenericTargetsService:AddFilteredItemName["Tobias Kruzhoryy"]

		; Asteroid Angel Cartel Battleship
		This.GenericTargetsService:AddFilteredItemName["Domination Cherubim"]
		This.GenericTargetsService:AddFilteredItemName["Domination Commander"]
		This.GenericTargetsService:AddFilteredItemName["Domination General"]
		This.GenericTargetsService:AddFilteredItemName["Domination Malakim"]
		This.GenericTargetsService:AddFilteredItemName["Domination Nephilim"]
		This.GenericTargetsService:AddFilteredItemName["Domination Saint"]
		This.GenericTargetsService:AddFilteredItemName["Domination Seraphim"]
		This.GenericTargetsService:AddFilteredItemName["Domination Throne"]
		This.GenericTargetsService:AddFilteredItemName["Domination War General"]
		This.GenericTargetsService:AddFilteredItemName["Domination Warlord"]

		; Asteroid Angel Cartel Battlecruiser
		This.GenericTargetsService:AddFilteredItemName["Domination Legatus"]
		This.GenericTargetsService:AddFilteredItemName["Domination Legionnaire"]
		This.GenericTargetsService:AddFilteredItemName["Domination Praefectus"]
		This.GenericTargetsService:AddFilteredItemName["Domination Primus"]
		This.GenericTargetsService:AddFilteredItemName["Domination Tribuni"]
		This.GenericTargetsService:AddFilteredItemName["Domination Tribunus"]

		; Asteroid Angel Cartel Cruiser
		This.GenericTargetsService:AddFilteredItemName["Domination Breaker"]
		This.GenericTargetsService:AddFilteredItemName["Domination Centurion"]
		This.GenericTargetsService:AddFilteredItemName["Domination Crusher"]
		This.GenericTargetsService:AddFilteredItemName["Domination Defeater"]
		This.GenericTargetsService:AddFilteredItemName["Domination Depredator"]
		This.GenericTargetsService:AddFilteredItemName["Domination Liquidator"]
		This.GenericTargetsService:AddFilteredItemName["Domination Marauder"]
		This.GenericTargetsService:AddFilteredItemName["Domination Phalanx"]
		This.GenericTargetsService:AddFilteredItemName["Domination Predator"]
		This.GenericTargetsService:AddFilteredItemName["Domination Smasher"]

		; Asteroid Angel Cartel Destroyer
		This.GenericTargetsService:AddFilteredItemName["Domination Defacer"]
		This.GenericTargetsService:AddFilteredItemName["Domination Defiler"]
		This.GenericTargetsService:AddFilteredItemName["Domination Haunter"]
		This.GenericTargetsService:AddFilteredItemName["Domination Seizer"]
		This.GenericTargetsService:AddFilteredItemName["Domination Shatterer"]
		This.GenericTargetsService:AddFilteredItemName["Domination Trasher"]

		; Asteroid Angel Cartel Frigate
		This.GenericTargetsService:AddFilteredItemName["Domination Ambusher"]
		This.GenericTargetsService:AddFilteredItemName["Domination Hijacker"]
		This.GenericTargetsService:AddFilteredItemName["Domination Hunter"]
		This.GenericTargetsService:AddFilteredItemName["Domination Impaler"]
		This.GenericTargetsService:AddFilteredItemName["Domination Nomad"]
		This.GenericTargetsService:AddFilteredItemName["Domination Outlaw"]
		This.GenericTargetsService:AddFilteredItemName["Domination Raider"]
		This.GenericTargetsService:AddFilteredItemName["Domination Rogue"]
		This.GenericTargetsService:AddFilteredItemName["Domination Ruffian"]
		This.GenericTargetsService:AddFilteredItemName["Domination Thug"]
		This.GenericTargetsService:AddFilteredItemName["Psycho Ambusher"]
		This.GenericTargetsService:AddFilteredItemName["Psycho Hijacker"]
		This.GenericTargetsService:AddFilteredItemName["Psycho Hunter"]
		This.GenericTargetsService:AddFilteredItemName["Psycho Impaler"]
		This.GenericTargetsService:AddFilteredItemName["Psycho Nomad"]
		This.GenericTargetsService:AddFilteredItemName["Psycho Outlaw"]
		This.GenericTargetsService:AddFilteredItemName["Psycho Raider"]
		This.GenericTargetsService:AddFilteredItemName["Psycho Rogue"]
		This.GenericTargetsService:AddFilteredItemName["Psycho Ruffian"]
		This.GenericTargetsService:AddFilteredItemName["Psycho Thug"]

		; Asteroid Blood Raiders Officers
		This.GenericTargetsService:AddFilteredItemName["Ahremen Arkah"]
		This.GenericTargetsService:AddFilteredItemName["Draclira Merlonne"]
		This.GenericTargetsService:AddFilteredItemName["Raysere Giant"]
		This.GenericTargetsService:AddFilteredItemName["Tairei Namazoth"]

		; Asteroid Guristas Officers
		This.GenericTargetsService:AddFilteredItemName["Estamel Tharchon"]
		This.GenericTargetsService:AddFilteredItemName["Kaikka Peunato"]
		This.GenericTargetsService:AddFilteredItemName["Thon Eney"]
		This.GenericTargetsService:AddFilteredItemName["Vepas Minimala"]

		; Asteroid Sansha's Nation Officers
		This.GenericTargetsService:AddFilteredItemName["Brokara Ryver"]
		This.GenericTargetsService:AddFilteredItemName["Chelm Soran"]
		This.GenericTargetsService:AddFilteredItemName["Selynne Mardakar"]
		This.GenericTargetsService:AddFilteredItemName["Vizan Ankonin"]

		; Asteroid Serpentis Officers
		This.GenericTargetsService:AddFilteredItemName["Brynn Jerdola"]
		This.GenericTargetsService:AddFilteredItemName["Cormack Vaaja"]
		This.GenericTargetsService:AddFilteredItemName["Setele Schellan"]
		This.GenericTargetsService:AddFilteredItemName["Tuvan Orth"]


		This.GenericTargetsService:AddFilteredItemName["Dread Guristas"]
		This.GenericTargetsService:AddFilteredItemName["Shadow Serpentis"]
		This.GenericTargetsService:AddFilteredItemName["True Sansha"]
		This.GenericTargetsService:AddFilteredItemName["Dark Blood"]

		This.GenericTargetsService:AddFilteredItemName["Courier"]
		This.GenericTargetsService:AddFilteredItemName["Ferrier"]
		This.GenericTargetsService:AddFilteredItemName["Gatherer"]
		This.GenericTargetsService:AddFilteredItemName["Harvester"]
		This.GenericTargetsService:AddFilteredItemName["Loader"]
		This.GenericTargetsService:AddFilteredItemName["Bulker"]
		This.GenericTargetsService:AddFilteredItemName["Carrier"]
		This.GenericTargetsService:AddFilteredItemName["Convoy"]
		This.GenericTargetsService:AddFilteredItemName["Hauler"]
		This.GenericTargetsService:AddFilteredItemName["Trailer"]
		This.GenericTargetsService:AddFilteredItemName["Transporter"]
		This.GenericTargetsService:AddFilteredItemName["Trucker"]

        UI:UpdateConsole["obj_targets_special_service: Initialized", LOG_MINOR]
    }

	member:bool IsSpecialTarget(string name)
	{   
		return ${This.GenericTargetsService.IsFilteredItem[${name}]}
	}
}