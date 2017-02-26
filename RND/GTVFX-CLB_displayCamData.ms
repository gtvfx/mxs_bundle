unregisterRedrawViewsCallback displayCamData

fn displayCamData =
(
	cam = viewport.getCamera()
	if cam != undefined then 
	(
		tColor = ((colorMan.getColor #windowText)*255)
		gw.setTransform (matrix3 1)
		--gw.wtext [32,19,0] cam.name color:orange
		gw.wtext [32,38,0] ("Lens: " + ((0.5 * (GetRendApertureWidth() / tan(cam.fov/2.0))) as string) + " mm") color:tColor
		gw.wtext [32,57,0] ("FOV: " + (cam.fov as string)) color:tColor
		
		gw.enlargeUpdateRect #whole
		gw.updateScreen()
	)
)


registerRedrawViewsCallback displayCamData

