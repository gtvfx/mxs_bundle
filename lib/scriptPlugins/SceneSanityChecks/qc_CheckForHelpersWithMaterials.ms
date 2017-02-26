_mxs.Using "CheckForHelpersWithMaterials"


-- register the plugin
::_checkForHelpersWithMaterials.agregate = ::_sceneSanity
_sceneSanity.plugManager.Register title:"Check Helpers with materials" \
									method:::_checkForHelpersWithMaterials.CheckPointHelpersWithMaterials \
									aux:#(::_checkForHelpersWithMaterials.SelectPointHelpersWithMaterials,::_checkForHelpersWithMaterials.RemoveAllMaterialsFromPointHelpers) \
									active:True \
									description:"Checks for helper objects with materials applied"



