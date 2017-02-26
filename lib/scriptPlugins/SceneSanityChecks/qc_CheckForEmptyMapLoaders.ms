_mxs.Using "CheckForEmptyMapLoaders"

	
-- register the plugin
::_checkForEmptyMapLoaders.agregate = ::_sceneSanity
::_sceneSanity.plugManager.Register title:"Check For Empty BitmapTextures" \
									method:::_checkForEmptyMapLoaders.CheckEmptyMapLoaders \
									aux:#(::_checkForEmptyMapLoaders.RemoveEmptyBitmapTextures) \
									active:True \
									description:"Checks for BitmapTextures with undefined or blank filenames"

