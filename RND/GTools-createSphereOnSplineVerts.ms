

vertCount = numKnots $ 1	
proxyBase = sphere()

for i = 1 to vertCount do
	(
		newPos = getKnotPoint $ 1 i
		--newPos = newPos * $.transform
		proxyBase.name = uniqueName "ProxySphere_"
		proxyMesh = instance proxyBase
		proxyMesh.wireColor = green
		proxyMesh.pos = newPos
	)
	

delete proxyBase
	
	

	
	
	
	
	
	
/*
	
show $
$.vertex[1]
	
	
getKnotPoint 
  
getKnotPoint $ 1 1



  for s = 1 to (numSplines $) do
  (
    for k = 1 to (numKnots $ s) do
    (
      knt = getKnotPoint $ s k
      in_vec = getInVec $ s k
      out_vec = getOutVec $ s k
      knt.z = in_vec.z = out_vec.z = new_z
      setInVec $ s k in_vec
      setOutVec $ s k out_vec
      setKnotPoint $ s k knt
    )--end k loop
  )--end s loop
  updateshape $