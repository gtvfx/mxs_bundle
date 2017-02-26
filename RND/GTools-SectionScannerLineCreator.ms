/************************************************************

First create a section shape and animate it through the geometry in your scene
When ready to render, run this script to create a series of shapes at each frame with animated visibility

*************************************************************/



st = animationRange.start
et = animationRange.end
theSection = $SCANNER_LINE


sectionArray = #()

for t in st to et do
	(
		--sliderTime = t
		--print theSection.position.x
		--/*
		--print t
		at time t do
			(
				tSection = copy theSection
				deleteKeys tSection.transform.controller #allKeys
				tSection.name = (theSection.name + "_" + (t as string))
				tSection.visibility = 0
				tSection.render_renderable = true
				tSection.sides = 3
					
				convertToSplineShape tSection
				append sectionArray tSection
			)
		--*/
	)

	

with animate on
	(
		for t in st to et do
			(
				at time t 
					(
						for i in sectionArray do
							(
								i.visibility = true
								i.visibility = false
								if matchPattern i.name pattern:("*" + (t as string) + "*") == true then
									(
										i.visibility = true
									)
								else
									(
										i.visibility = false
									)
							)
					)
			)
	)		

/*	
sectionArray = selection as array	
	
t = currentTime
matchPattern $.name pattern:("*" + (t as string) + "*")
	$.visibility = false
$.render_thickness = 1

delete sectionArray
sectionArray[1].name
showProperties $
