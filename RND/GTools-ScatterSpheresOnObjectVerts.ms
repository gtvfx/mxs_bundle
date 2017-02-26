fn scatterProxies_FN =
	(
		mySphere = sphere()
		mySphere.segments = 5
		mySphere.radius = 50.0
		theMaterial = vrayLightMtl()
		theMaterial.color = white
		theMaterial.name = "White"
		mySphere.material = theMaterial
		
		for each in selection do
			(
				vertCount = getNumVerts each.mesh
				mySphere = sphere()
				mySphere.segments = 5
				mySphere.radius = 50.0
				theMaterial = vrayLightMtl()
				theMaterial.color = white
				theMaterial.name = "White"
				mySphere.material = theMaterial
		
				for i = 1 to vertCount do
					(
						newPos = getVert each.mesh i
						newPos = newPos * each.transform
						theSphere = instance mySphere
						theSphere.wireColor = red
						--proxyMesh.rotation = (quat 0 0 (random (-1 as float) (1 as float)) 1)
						theSphere.pos = newPos
						theSphere.parent = each
					)
			)
		
	)
scatterProxies_FN()