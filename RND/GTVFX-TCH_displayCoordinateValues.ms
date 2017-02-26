unregisterRedrawViewsCallback displayCoordinateValues

fn displayCoordinateValues  =
(
	gw.setTransform(matrix3 1)
	for i = -1000 to 1000 by 50 do
	(
		gw.text [i,0,0] (units.formatValue i) color:red
		gw.text [0,i,0] (units.formatValue i) color:green
		gw.text [0,0,i] (units.formatValue i) color:blue
	)
	gw.enlargeUpdateRect #whole
	gw.updateScreen()
)

registerRedrawViewsCallback displayCoordinateValues




/*
units.formatValue 100