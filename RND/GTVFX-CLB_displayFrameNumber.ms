unregisterRedrawViewsCallback displayFrameNumber

fn displayFrameNumber =
	(
		cam = viewport.getCamera()
		if cam != undefined then 
		(
			tColor = ((colorMan.getColor #windowText)*255)
			
			posX = (gw.getWinSizeX() - 50)
			posY = (gw.getWinSizeY() -12)
			
			gw.setTransform (matrix3 1)
			gw.wtext [posX,posY,0] ((currentTime as string)) color:tColor
			
			gw.enlargeUpdateRect #whole
			gw.updateScreen()
		)
	)


registerRedrawViewsCallback displayFrameNumber

