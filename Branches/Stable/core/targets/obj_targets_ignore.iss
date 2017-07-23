/*
    NPCS to ignore
    
*/

objectdef obj_targets_ignore
{
    variable obj_targets_generic GenericTargetsService
    
	method Initialize()
	{
        This.GenericTargetsService:Initialize
        This.GenericTargetsService:AddFilteredItemName["Blood Raiders Venture"]
        This.GenericTargetsService:AddFilteredItemName["Blood Raiders Bestower"]
        This.GenericTargetsService:AddFilteredItemName["Blood Raiders Impel"]
        This.GenericTargetsService:AddFilteredItemName["Blood Raiders Skiff"]
        This.GenericTargetsService:AddFilteredItemName["Blood Raiders Exhumer"]
        This.GenericTargetsService:AddFilteredItemName["Blood Raiders Retriever"]
        This.GenericTargetsService:AddFilteredItemName["Exhumer"]
        This.GenericTargetsService:AddFilteredItemName["Skiff"]
        This.GenericTargetsService:AddFilteredItemName["Retriever"]
        This.GenericTargetsService:AddFilteredItemName["Impel"]
        This.GenericTargetsService:AddFilteredItemName["Autothysian Lancer"]
        This.GenericTargetsService:AddFilteredItemName["Autothysian"]

        UI:UpdateConsole["obj_targets_ignore: Initialized", LOG_MINOR]
	}

    member:bool IsIgnoredTarget(string name)
	{
        return ${This.GenericTargetsService.IsFilteredItem[${name}]}
	}
}
