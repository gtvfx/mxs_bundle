mxs.Using "CheckForEmptyMapLoaders"

-- register the plugin
::_checkForEmptyMapLoaders.agregate = ::SceneSanityChecks
::SceneSanityChecks.plugManager.Register title:"Check For Empty Map Loaders" method:::_checkForEmptyMapLoaders.CheckEmptyMapLoaders aux:#(::_checkForEmptyMapLoaders.RemoveEmptyBitmapTextures) active:True description:"Checks for BitmapTextures with undefined or blank filenames"
