unregisterRedrawViewsCallback displayUserName

fn displayUserName =
(
	cam = viewport.getCamera()
	if cam != undefined then 
	(
		tColor = ((colorMan.getColor #windowText)*255)
		
		posX = (gw.getWinSizeX() - 150)
		posY = 19--(gw.getWinSizeY() -12)
		
		gw.setTransform (matrix3 1)
		
		gw.wtext [posX,posY,0] (sysInfo.userName) color:tColor
		
		gw.enlargeUpdateRect #whole
		gw.updateScreen()
	)
)


registerRedrawViewsCallback displayUserName

