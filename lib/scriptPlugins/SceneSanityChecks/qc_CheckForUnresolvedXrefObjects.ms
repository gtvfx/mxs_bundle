_mxs.Using "CheckForUnresolvedXrefObjects"

-- register the plugin
::_CheckForUnresolvedXrefObjects.agregate = ::_sceneSanity
::_sceneSanity.plugManager.Register title:"Check for unresolved xrefs" \
									method:::_CheckForUnresolvedXrefObjects.CheckUnresolvedXRefObjects \
									aux:#(::_CheckForUnresolvedXrefObjects.SelectUnresolvedXRefObjects) \
									active:True \
									description:"Checks for unresolved xrefs"

