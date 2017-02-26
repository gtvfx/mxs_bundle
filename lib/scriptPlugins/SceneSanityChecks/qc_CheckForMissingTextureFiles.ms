_mxs.Using "CheckForMissingTextureFiles"
	
	
-- Register the plugin
::_checkForMissingTextureFiles.agregate = ::_sceneSanity
::_sceneSanity.plugManager.Register title:"Check For Missing Texture files" \
									method:::_checkForMissingTextureFiles.CheckMissingBitmapTextures \
									aux:#(::_checkForMissingTextureFiles.RemoveRogueBitmaps) \
									active:True \
									description:"Checks for BitmapTextures referencing files that do not exist"

