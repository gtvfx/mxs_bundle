_mxs.Using "CheckForUnwrapModifierBitmaps"
	
-- register the plugin
::_checkForUnwrapModifierBitmaps.agregate = ::_sceneSanity
::_sceneSanity.plugManager.Register title:"Check For Unwrap Modifiers" \
									method:::_checkForUnwrapModifierBitmaps.CheckUnwrapModifers \
									aux:#(::_checkForUnwrapModifierBitmaps.SelectUnwrapModifierObjects,::_checkForUnwrapModifierBitmaps.CollapseToUnwrapModifiers) \
									active:True \
									description:"Checks for any unwrap modifiers in the scene"

