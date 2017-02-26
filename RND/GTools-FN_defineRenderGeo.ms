fn defineRenderGeo_FN =
(
	renderGeo = #()
	st = animationrange.start
	et = animationrange.end
	for t = st to et by 10 do 
	(
		at time t 
		(
			sliderTime = currentTime
			visibleObjs = boxPickNode (box2 [0,0] (getViewSize()))
			for each in visibleObjs do
			(
				appendIfUnique renderGeo each
			)
		)
	)
	if currentTime != et then
	(
		sliderTime = et
		visibleObjs = boxPickNode (box2 [0,0] (getViewSize()))
		for each in visibleObjs do
		(
			appendIfUnique renderGeo each
		)
	)
	if renderGeo.count > 0 then
	(
		deleteObjs = for i in objects where superClassOf i != Helper and superClassOf i != camera and findItem renderGeo i == 0 collect i
		select deleteObjs
	)
	else
	(
		messageBox "No geometry found beyond camera view"
	)
)
defineRenderGeo_FN()
	
	