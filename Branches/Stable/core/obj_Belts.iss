objectdef obj_Belts
{
	variable string SVN_REVISION = "$Rev$"
	variable int Version

	variable index:entity beltIndex
	variable iterator beltIterator

	method Initialize()
	{		
		UI:UpdateConsole["obj_Belts: Initialized", LOG_MINOR]
	}
	
	method ResetBeltList()
	{
		EVE:QueryEntities[beltIndex, "GroupID = GROUP_ASTEROIDBELT"]
		beltIndex:GetIterator[beltIterator]	
		UI:UpdateConsole["obj_Belts: ResetBeltList found ${beltIndex.Used} belts in this system.", LOG_DEBUG]
	}
	
	member:bool IsAtBelt()
	{
		if !${Me.InSpace}
		{
			return FALSE
		}
		; Are we within 150km of the bookmark?
		if ${beltIterator.Value.ItemID} > -1
		{
			if ${Me.ToEntity.DistanceTo[${beltIterator.Value.ItemID}]} < WARP_RANGE
			{
				return TRUE
			}
		}
		elseif ${Math.Distance[${Me.ToEntity.X}, ${Me.ToEntity.Y}, ${Me.ToEntity.Z}, ${beltIterator.Value.X}, ${beltIterator.Value.Y}, ${beltIterator.Value.Z}]} < WARP_RANGE
		{
			return TRUE
		}
		
		return FALSE
	}
	
	; TODO - logic is duplicated inside WarpToNextBelt -- CyberTech
	method NextBelt()
	{
		if ${beltIndex.Used} == 0 
		{
			This:ResetBeltList
		}

		if !${beltIterator:Next(exists)}
			beltIterator:First(exists)

		return
	}
	
	function WarpTo(int WarpInDistance=0)
	{
		call This.WarpToNextBelt ${WarpInDistance}
	}
	
	function WarpToNextBelt(int WarpInDistance=0, bool ReverseOrder=FALSE)
	{
		if ${beltIndex.Used} == 0 
		{
			This:ResetBeltList
		}		
		
		; This is for belt bookmarks only
		;if ${beltIndex.Get[1](exists)} && ${beltIndex.Get[1].SolarSystemID} != ${Me.SolarSystemID}
		;{
		;	This:ResetBeltList
		;}
		
		if ${ReverseOrder}
		{
			if !${beltIterator:Previous(exists)}
			{
				beltIterator:Last
			}
		}
		else
		{
			if !${beltIterator:Next(exists)}
			{
				beltIterator:First
			}
		}
		
		if ${beltIterator.Value(exists)}
		{
			;UI:UpdateConsole["obj_Belts: DEBUG: Warping to ${beltIterator.Value.Name}", LOG_CRITICAL]
			call Ship.WarpToID ${beltIterator.Value.ID} ${WarpInDistance}
		}
		else
		{
			UI:UpdateConsole["obj_Belts:WarpToNextBelt ERROR: beltIterator does not exist"]
		}
	}
}
