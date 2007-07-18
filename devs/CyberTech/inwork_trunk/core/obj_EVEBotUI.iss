
objectdef obj_EVEBotUI
{
	;; global variables (used in UI display)
	variable string CharacterName
	variable string MyTarget
	variable string MyRace
	variable string MyCorp
	variable int TotalRuns = 0						/* Total Times we've had to transfer to hanger */

; TODO This doesn't belong here. - CyberTech
	variable bool ForcedReturn = FALSE					/* A variable for forced return */

; TODO These don't belong here - CyberTech
	variable int MinShieldPct = 50              /* What shields need to reach before entering combat */
	variable int MinStructurePct = 80              /* Min Structure that we should have, if we get into combat */

	variable int FrameCounter
	
	method Initialize()
	{
		Event[OnFrame]:AttachAtom[This:Pulse]
		This.CharacterName:Set[${Me.Name}]
		This.MyRace:Set[${Me.ToPilot.Type}]
		This.MyCorp:Set[${Me.Corporation}]
	}


	method Pulse()
	{
		FrameCounter:Inc
		
		if ${Math.Calc[${FrameCounter % 80}]} == 0
		{
			This:Update_Display_Values
		}
	}

	method Update_Display_Values()
	{
 
		; Some variables just aren't going to change...they should be set initially and left alone
   
		if (${Me.ActiveTarget(exists)})
		{
			This.MyTarget:Set[${Me.ActiveTarget}]
		}
		else
		{
			This.MyTarget:Set[None]
		}
   }
}
