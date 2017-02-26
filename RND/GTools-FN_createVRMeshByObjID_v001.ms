fn createVRMeshByObjID_FN ID =
(
	objIDarr = for i in objects where i.gBufferChannel == ID and i.isHidden == false and i.wirecolor != red collect i -- specifically excluded red objects for unique purpose
		
	if ID != undefined and ID == integer do
		(	
			for i in 2 to objIDarr.count do
				(
					attach objIDarr[1] objIDarr[i]
				)
				
			centerPivot objIDarr[1]
				
			meshFileName		= (maxFilePath + "_cache\\" + "ObjID_" + (ID as string) + ".vrmesh")
				
				
			select objIDarr[1]
			vrayMeshExport meshFile:meshFileName autoCreateProxies:true exportMultiple:false animation:off maxPreviewFaces:3000
			print "VICTORY"
		)
)


createVRMeshByObjID_FN 11

