fn setViewportToCamera_FN =
	(
		viewport.setCamera (for i in objects where superClassOf i == Camera collect i)[1]
	)
	
setViewportToCamera_FN()