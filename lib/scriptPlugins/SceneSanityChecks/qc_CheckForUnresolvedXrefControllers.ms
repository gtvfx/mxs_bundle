_mxs.Using "CheckForUnresolvedXrefControllers"
	
-- register the plugin
::_checkForUnresolvedXrefControllers.agregate = ::_sceneSanity
::_sceneSanity.plugManager.Register title:"Check for unresolved xref controllers" \
									method:::_checkForUnresolvedXrefControllers.CheckUnresolvedXRefControllers \
									aux:#(::_checkForUnresolvedXrefControllers.SelectObjectsWithUnresolvedXrefControllers) \
									active:True \
									description:"Checks for unresolved xref controllers"


