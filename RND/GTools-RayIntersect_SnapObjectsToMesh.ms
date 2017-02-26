fn snapObjectsToMesh axi baseObject offset:0.0 wrap:false =
(
	rayAxi = case axi of
	(
		"+X":([1,0,0])
		"-X":([-1,0,0])
		"+Y":([0,1,0])
		"-Y":([0,-1,0])
		"+Z":([0,0,1])
		"-Z":([0,0,-1])
	)
	if wrap then
	(
		for i in selection do
		(
			convertTo i PolyMeshObject
			progressStart ("Snapping Vertices for Mesh: " + i.name)
			inc = 100.0/$.verts.count
			incU = inc
			for v in i.verts do
			(
				format "Starting vertex operation on %\n" v
				IntersectedRay = intersectRay baseObject (ray v.pos rayAxi)
				if IntersectedRay != undefined then v.pos = IntersectedRay.pos + (rayAxi)*(-1)*offset									
				progressUpdate incU
				incU += inc
			)
			progressEnd()
		)
	)
	else
	(
		progressStart "Snapping Objects"
		inc = 100.0/selection.count
		incU = inc
		for i in selection do
		(
			IntersectedRay = intersectRay BaseObject (ray i.position rayAxi)
			i.position = IntersectedRay.pos + (rayAxi)*(-1)*offset
			progressUpdate incU
			incU += inc
		)
		progressEnd()
	)
)
snapObjectsToMesh "-Z" (pickObject()) wrap:true





