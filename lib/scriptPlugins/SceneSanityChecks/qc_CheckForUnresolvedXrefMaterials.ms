_mxs.Using "CheckForUnresolvedXrefMaterials"
	
-- register the plugin
::_checkForUnresolvedXrefMaterials.agregate = ::_sceneSanity
::_sceneSanity.plugManager.Register title:"Check for unresolved xref materials" \
									method:::_checkForUnresolvedXrefMaterials.CheckUnresolvedXRefMaterials \
									aux:#(::_checkForUnresolvedXrefMaterials.SelectObjectsWidthUnreslovedXrefsMaterials) \
									active:True \
									description:"Checks for unresolved xref materials"
