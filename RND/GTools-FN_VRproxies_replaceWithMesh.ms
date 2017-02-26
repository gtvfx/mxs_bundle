struct replaceVRproxiesWithMesh_lib
(
	ro
	fn replaceVRproxiesWithMesh_FN =
	(	
		vrProxiesArr = #()
		for i in selection where classOf i == VRayProxy do
			(
				proxyArr = #()
				ilayer = i.layer
				ilayer.current = true
				proxyArr = vrayMeshImport proxy:i explicitNormals:2 weldVertices:2
				proxyArr[1].rotation = i.rotation
				proxyArr[1].position = i.position
				proxyArr[1].scale = i.scale
				proxyArr[1].material = i.material
				proxyArr[1].wireColor = i.wireColor
				if i.parent != undefined then proxyArr[1].parent = i.parent
				append vrProxiesArr i
			)
		delete vrProxiesArr
	),
	fn ui =
	(
		rollout ro "Collapse Progress" width:600 height:20
		(
			progressBar pg1 "" height:10
		)
		createDialog ro
	),
	fn run =
	(
		ui()
		replaceVRproxiesWithMesh_FN()
		destroyDialog ro
	)
)
	

	
	
	
/*
