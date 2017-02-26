/******************************************
Author:				Gavyn Thompson
Company:				GTVFX
Website:				www.gtvfx.com
Email:				gthompson@gtvfx.com
ScriptVersion:			v1.00
Updated:				<DATE>
[Purpose]

******************************************/
try(destroyDialog itm.ro)catch()
::TapeGradeSettings
::TapeGradeEnabled
struct intervalTapeMeasurement
(
	self,
	ro,
	fn displayTapeIncrements  =
	(
		gw.setTransform(matrix3 1)
		for o in helpers where not o.isHidden and classOf o == tape do
		(
			cnt = 0
			for dist = 0 to o.targetDistance by TapeGradeSettings[3] do
			(
				vert1 = [0,0,-dist]*o.transform
				dashLength = TapeGradeSettings[1]
				if cnt/TapeGradeSettings[4] == ceil(cnt/TapeGradeSettings[4] as float) then
				(
					dashLength *= TapeGradeSettings[2]
					gw.text vert1 (units.formatValue (cnt*TapeGradeSettings[3])) color:yellow
				)
				vert2 = [dashLength,0,-dist]*o.transform
				gw.setColor #line (color 0 255 255)
				gw.polyline #(vert1, vert2) false 
				cnt += 1
			)
		)
		gw.enlargeUpdateRect #whole
		gw.updateScreen()
	),
	fn toggleTapeGrade enabled:true =
	(
		if enabled then
		(
			unregisterRedrawViewsCallback displayTapeIncrements
			registerRedrawViewsCallback displayTapeIncrements
			displayTapeIncrements()
		)
		else
		(
			unregisterRedrawViewsCallback displayTapeIncrements
			max views redraw
		)
	),
	fn ui =
	(
		rollout ro "Tape Grade Settings" width:200 height:130
		(
			local self
			spinner spn_dashSize "Minor Line Length:" fieldwidth:50 range:[0.01,100.0,TapeGradeSettings[1]]
			spinner spn_majorFactor "Major Lines Factor:" fieldwidth:50 range:[1.0,10,TapeGradeSettings[2]]
			spinner spn_minorEvery "Minor Line Every:" fieldwidth:50 range:[1,100,TapeGradeSettings[3]] type:#integer
			spinner spn_majorEvery "Major Line Every:" fieldwidth:50 range:[1,100.0,TapeGradeSettings[4]] type:#integer
			checkButton cBtn_enable "Enable Tape Grade" width:150 height:30
			fn _init pself =
			(
				self = pself
				cBtn_enable.state = TapeGradeEnabled
			)
			on spn_dashSize changed val do (TapeGradeSettings[1] = val; max views redraw)
			on spn_majorFactor changed val do (TapeGradeSettings[2] = val; max views redraw)
			on spn_minorEvery changed val do (TapeGradeSettings[3] = val; max views redraw)
			on spn_majorEvery changed val do (TapeGradeSettings[4] = val; max views redraw)
			on cBtn_enable changed state do
			(
				self.toggleTapeGrade enabled:state
				TapeGradeEnabled = state
			)
		)
		createDialog ro
		ro._init self
	),
	fn _init =
	(
		self = this
		if TapeGradeSettings == undefined then TapeGradeSettings = #(4,2.0,1,10)
		if TapeGradeEnabled == undefined then TapeGradeEnabled = false
		ui()
	),
	init = _init()
)

itm = intervalTapeMeasurement()


/*


macroScript TCH_tapeGrade category:"GTVFX"
(
	global TapeGradeEnabled = false
	persistent global TapeGradeSettings
	if TapeGradeSettings == undefined then TapeGradeSettings = #(4,2.0,1,10)
	fn displayTapeIncrements  =
	(
		gw.setTransform(matrix3 1)
		for o in helpers where not o.isHidden and classOf o == tape do
		(
			cnt = 0
			for dist = 0 to o.targetDistance by TapeGradeSettings[3] do
			(
				vert1 = [0,0,-dist]*o.transform
				dashLength = TapeGradeSettings[1]
				if cnt/TapeGradeSettings[4] == ceil(cnt/TapeGradeSettings[4] as float) then
				(
					dashLength *= TapeGradeSettings[2]
					gw.text vert1 (units.formatValue (cnt*TapeGradeSettings[3])) color:red
				)
				vert2 = [dashLength,0,-dist]*o.transform
				gw.polyline #(vert1, vert2) false
				cnt += 1
			)
		)
		gw.enlargeUpdateRect #whole
		gw.updateScreen()
	)
	on isChecked return TapeGradeEnabled
	on execute do
	(
		TapeGradeEnabled = not TapeGradeEnabled
		if TapeGradeEnabled then
		(
			unregisterRedrawViewsCallback displayTapeIncrements
			registerRedrawViewsCallback displayTapeIncrements
			displayTapeIncrements()
		)
		else
		(
			unregisterRedrawViewsCallback displayTapeIncrements
			max views redraw
		)
	)
)
macroScript TCH_setTapeGrade category:"GTVFX"
(
	global TapeGradeEnabled = false
	persistent global TapeGradeSettings
	if TapeGradeSettings == undefined then TapeGradeSettings = #(4,2.0,1,10)
	rollout ro_tapeGrade "Set Tape Grade" width:180 height:90
	(
		spinner spn_dashSize "Minor Line Length:" fieldwidth:50 range:[0.01,100.0,TapeGradeSettings[1]]
		spinner spn_majorFactor "Major Lines Factor:" fieldwidth:50 range:[1.0,10,TapeGradeSettings[2]]
		spinner spn_minorEvery "Minor Line Every:" fieldwidth:50 range:[1,100,TapeGradeSettings[3]] type:#integer
		spinner spn_majorEvery "Major Line Every:" fieldwidth:50 range:[1,100.0,TapeGradeSettings[4]] type:#integer
		on spn_dashSize changed val do (TapeGradeSettings[1] = val; max views redraw)
		on spn_majorFactor changed val do (TapeGradeSettings[2] = val; max views redraw)
		on spn_minorEvery changed val do (TapeGradeSettings[3] = val; max views redraw)
		on spn_majorEvery changed val do (TapeGradeSettings[4] = val; max views redraw)
			
	)
	try(destroyDialog ro_tapeGrade)catch()
	
	
	on execute do
	(
		TapeGradeEnabled = not TapeGradeEnabled
		if not TapeGradeEnabled then macros.run "GTVFX" "tapeGrade"
		createDialog ro_tapeGrade
	)
)

/*
units.formatValue 100