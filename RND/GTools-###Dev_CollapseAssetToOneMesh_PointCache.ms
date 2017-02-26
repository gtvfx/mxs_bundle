clearListener()
fn cacheRigToSingleMesh_FN =
	(
		for i in selection do
			(	
				snapMesh = snapshot i name:(i.name + "_snapShot") 
				i.parent = undefined
				snapMesh.transform = i.transform
			)
			
		snapShotArr = for i in objects where matchPattern i.name pattern:"*_snapShot" collect i
			
		snapShotArr = for i in snapShotArr where superClassOf i == geometryClass collect i
		if snapShotArr.count < 2 then
			(
				continue
			)
		else
			(
				tStart = timeStamp()
				progressStart "Attaching Objects"
				perc 			= (100.0 / (snapShotArr.count))
				percentu 	= 0	
				j = 1
				undo off
					(
						while snapShotArr.count > 1 do
							(				
								if classof snapShotArr[j] != Edit_Mesh then convertToMesh snapShotArr[j]
								attach snapShotArr[j] snapShotArr[j+1]
								deleteItem snapShotArr (j+1)
								j += 1
								if (j + 1) > snapShotArr.count then j = 1
								if getProgressCancel() == true then exit
								progressUpdate percentu
								percentu += perc
								gc()
							)
					)
				progressEnd()
				tEnd = timeStamp()
				print ("Attach time: " + ((tEnd-tStart)/1000.0) as string + "s")
			)
			
		surfMesh = snapShotArr[1]
			
		meshListArray = selection as array
		addmodifier surfmesh (skin_wrap())
		surfmesh.modifiers[#Skin_Wrap].threshold = 0
		surfmesh.modifiers[#Skin_Wrap].engine = 0
		surfmesh.modifiers[#Skin_Wrap].meshlist = meshListArray
		tStart = timeStamp()
		surfmesh.modifiers[#Skin_Wrap].weightAllVerts = true
		tEnd = timeStamp()
		print ("Weight All Verts time: " + ((tEnd-tStart)/1000.0) as string + "s")
		surfMesh.transform = matrix3 1
		surfMesh.objectOffsetPos = [0,0,0]
		surfMesh.objectOffsetRot = (quat 0 0 0 1)
		surfMesh.objectOffsetScale = [1,1,1] 	
			
		if validmodifier surfmesh (Point_CacheSpacewarpModifier()) then
			(
				WCmod = (Point_CacheSpacewarpModifier())
				WCmod.name = "World_PC"
				WCmod.loadType = 2
				WCmod.loadTypeSlave = 2
				WCmod.name ="World_PC"
				WCmod.filename = ((getSavePath caption:"** POINT TO YOUR CACHE LOCATION ** " initialDir:maxFilePath) +"\\" + surfmesh.name + ".pc2")
				WCmod.recordStart  = animationRange.start - 5f
				WCmod.recordEnd = animationRange.end + 5f
				addmodifier surfmesh WCmod
				cacheOps.RecordCache surfmesh.modifiers[#World_PC]
				deleteModifier surfmesh surfmesh.modifiers[#Skin_Wrap]
				LCmod = (Point_Cache())
				LCmod.name = "Local_PC"
				LCmod.loadType = 2
				LCmod.loadTypeSlave = 2
				LCmod.name ="Local_PC"
				LCmod.filename = WCmod.filename
				addModifier surfMesh LCmod
				deleteModifier surfmesh surfmesh.modifiers[#World_PC]
			)
		else
			(
				return false
			)
			
	)
	
cacheRigToSingleMesh_FN()
	
	
/*