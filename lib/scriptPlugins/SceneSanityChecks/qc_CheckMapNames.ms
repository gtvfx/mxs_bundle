_mxs.Using "CheckMapNames"
	
	
-- register the plugin
::_checkMapNames.agregate = ::_sceneSanity
::_sceneSanity.plugManager.Register title:"Check Map Names" \
									method:::_checkMapNames.CheckForIllegalNames \
									aux:#(::_checkMapNames.CleanMapNames) \
									active:True \
									description:"Checks illegal characters in map names"

