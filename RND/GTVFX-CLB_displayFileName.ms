unregisterRedrawViewsCallback displayFileName

fn displayFileName =
(
	cam = viewport.getCamera()
	if cam != undefined then 
	(
		tColor = ((colorMan.getColor #windowText)*255)
		
		posX = (gw.getWinSizeX()/2)
		posY = 19--(gw.getWinSizeY() -12)
		
		gw.setTransform (matrix3 1)
		
		gw.wtext [posX,posY,0] (getFileNameFile maxFileName) color:tColor
		
		gw.enlargeUpdateRect #whole
		gw.updateScreen()
	)
)


registerRedrawViewsCallback displayFileName

