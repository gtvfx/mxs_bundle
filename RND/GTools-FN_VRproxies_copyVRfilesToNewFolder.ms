fn copyVRfilesToNewFolder_FN newPath=
	(	
		for i in selection where classOf i == VRayProxy do
			(
				meshFile = i.fileName
				copyFile meshFile (newPath + (getFileNameFile i.fileName) + (getFileNameType i.fileName))
			)
	)

myPath = @"C:\localize_it\rb_344_prodStill\vrmesh\"
	
copyVRfilesToNewFolder_FN myPath
	
	
/*
$.fileName
	
getFileNameFile $.fileName
getFileNameType $.fileName
	
	
(myPath + (getFileNameFile $.fileName) + (getFileNameType $.fileName))