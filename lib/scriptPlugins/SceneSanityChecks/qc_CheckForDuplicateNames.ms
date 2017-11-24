::mxs.Using "CheckForDuplicateNames"

	
-- register the plugin
::_checkDupObjNames.agregate = ::_sceneSanity
::_sceneSanity.plugManager.Register title:"Check Duplicate Names" \
									method:::_checkDupObjNames.CheckDuplicateNames \
									aux:#(::_checkDupObjNames.SelectDuplicateNames,::_checkDupObjNames.AutoUniqueNames) \
									active:True \
									description:"Checks for objects with identical names"

