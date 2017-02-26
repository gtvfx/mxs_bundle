fn toggleLayerStateForHierarchy_FN trueFalse =
	(
		if selection.count == 1 then
			(
				masterCTRL = $
				childArr = #()
					
				GTools.GF_getChildrenRecursive masterCTRL childArr
					
				if childArr.count > 0 then
					(
						layerNameArr = #()
							
						for i in childArr do
							(
								appendIfUnique layerNameArr i.layer.name
							)
							
						for i in layerNameArr do
							(
								childLayer = LayerManager.getLayerFromName i
								childLayer.on = trueFalse
							)
					)
				else
					(
						messageBox "Can't find hierarchy."
					)
			)
		else
			(
				messageBox "Select only one object."
			)
	)

/**************
	
toggleLayerStateForHierarchy_FN true
toggleLayerStateForHierarchy_FN false