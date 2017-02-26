/******************************************************************************
library for creating viewport display callbacks for scene data requested by animation department.
******************************************************************************/
struct animDisplayLib
(
	self,
	tColor = ((colorMan.getColor #windowText)*255),
	
	fn displayCamData =
	(
		cam = viewport.getCamera()
		if cam != undefined then 
		(
			tColor = self.tColor
			gw.setTransform (matrix3 1)
			--gw.wtext [32,19,0] cam.name color:tColor
			gw.wtext [32,38,0] ("Lens: " + ((0.5 * (GetRendApertureWidth() / tan(cam.fov/2.0))) as string) + " mm") color:tColor
			gw.wtext [32,57,0] ("FOV: " + (cam.fov as string)) color:tColor
			
			gw.enlargeUpdateRect #whole
			gw.updateScreen()
		)
	),
	fn displayFrameNumber =
	(
		cam = viewport.getCamera()
		if cam != undefined then 
		(
			tColor = self.tColor
			
			posX = (gw.getWinSizeX() - 50)
			posY = (gw.getWinSizeY() -12)
			
			gw.setTransform (matrix3 1)
			gw.wtext [posX,posY,0] ((currentTime as string)) color:tColor
			
			gw.enlargeUpdateRect #whole
			gw.updateScreen()
		)
	),
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
	),
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
	),
	fn registerFn fnName =
	(
		unregisterRedrawViewsCallback fnName
		registerRedrawViewsCallback fnName
		format "***** % registered *****\n" fnName
	),
	fn unRegisterNf fnName =
	(
		unregisterRedrawViewsCallback fnName
		format "***** % unregistered *****\n" fnName
	),
	fn _init =
	(
		self = this
	),
	init = _init()
)
/* 
_adl = animDisplayLib()


_adl.registerFn _adl.displayCamData
_adl.registerFn _adl.displayFrameNumber


 */