_mxsLib.Using "CheckForGroups"

	
-- register the plugin
::_checkForGroups.agregate = ::_sceneSanity
_sceneSanity.plugManager.Register title:"Check For Groups" \
									method:_checkForGroups.CheckForGoups \
									aux:#(_checkForGroups.SelectAllGroupHeads,_checkForGroups.ConvertGroupsToTopNulls) \
									active:True \
									description:"Checks for any groups in the scene"

