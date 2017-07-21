/*
    NPCS to ignore
    
*/

objectdef obj_targets_ignore
{
    variable index:string IgnoreTargets
	variable iterator IgnoreTarget
    
	method Initialize()
	{
		IgnoreTargets:Insert["Blood Raiders Venture"]
		IgnoreTargets:Insert["Blood Raiders Bestore"]

		IgnoreTargets:GetIterator[IgnoreTarget]
        UI:UpdateConsole["obj_targets_ignore: Initialized", LOG_MINOR]
	}

    member:bool IsIgnoredTarget(string name)
	{
        ; Loop through the ignored targets
        if ${IgnoreTarget:First(exists)}
        do
        {
            if ${name.Find[${IgnoreTarget.Value}]} > 0
            {
                return TRUE
            }
        }
        while ${IgnoreTarget:Next(exists)}

        return FALSE
	}
}
