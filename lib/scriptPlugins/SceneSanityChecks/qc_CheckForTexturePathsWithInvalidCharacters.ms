_mxs.Using "CheckForTexturePathsWithInvalidCharacters"
	
-- register the plugin
_checkForTexturePathsWithInvalidCharacters.agregate = ::_sceneSanity
::_sceneSanity.plugManager.Register title:"Check for texture paths with invalid characters" \
									method:_checkForTexturePathsWithInvalidCharacters.CheckTexturePathsWithInvalidChars \
									aux:#(_checkForTexturePathsWithInvalidCharacters.FixTexturePathsWithInvalidChars) \
									active:True \
									description:"Checks for texture file paths with invalid characters"
