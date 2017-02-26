unregisterRedrawViewsCallback displayObjData

fn displayObjData =
(
	gw.setTransform(matrix3 1)
	for o in objects where not o.isHidden do
	(
		gw.text (o.pos) o.name color:orange
	)
	gw.enlargeUpdateRect #whole
	gw.updateScreen()
)

registerRedrawViewsCallback displayObjData

/*
displayData()