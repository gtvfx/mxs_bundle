fn createTapeHelper p1 p2 =
(
	d = distance p1 p2
	t = tape pos:p1.position target:(targetObject pos:p2.position) length:d
	d
)
createTapeHelper selection[1] selection[2]
--createTapeHelper (viewport.getCamera()) selection[1]
	
	
	
