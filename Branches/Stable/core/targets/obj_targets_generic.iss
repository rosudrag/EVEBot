/*
    Generic filter for entities by name
*/

objectdef obj_targets_generic
{
    variable index:string FilteredItems
	variable iterator FilteredItem
    
	method Initialize()
	{
	}

    method AddFilteredItemName(string name)
    {
        FilteredItems:Insert[${name}]
    }

    member:bool IsFilteredItem(string name)
	{
        FilteredItems:GetIterator[FilteredItem]
        if ${FilteredItem:First(exists)}
        do
        {
            if ${name.Find[${FilteredItem.Value}]} > 0
            {
                return TRUE
            }
        }
        while ${FilteredItem:Next(exists)}

        return FALSE
	}
}
