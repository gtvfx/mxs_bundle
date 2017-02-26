_mxs.Using "CheckIllegalObjectNames"
	
-- register the plugin
::_checkIllegalObjectNames.agregate = ::_sceneSanity
::_sceneSanity.plugManager.Register title:"Check For Illegal Object Names" \
									method:::_checkIllegalObjectNames.CheckIllegalObjectNames \
									aux:#(::_checkIllegalObjectNames.SelectObjsWithIllegalNames,::_checkIllegalObjectNames.AutoFixNames) \
									active:True \
									description:"Checks for objects with identical names"

