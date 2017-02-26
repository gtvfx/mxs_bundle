/***************************************************************************************************
__MXSDOC__
[TITLE]

Previz Cards Helper

[DESCRIPTION]

Speeds up the process of adding texture-mapped cards for previz blocking


[USAGE]

--IMPORTANT--
- This tool operates on every object in your selection and will manipulate multiple materials at once.
--------------

- Will make a unique copy of the selected objects material
- Can set the Start time of the animated texture to the Current Time
- You can manually set the Start Frame, Playback Rate, and End Condition of the animated texture map

[CREATION INFO]
by: Gavyn Thompson

__END__
***************************************************************************************************/

fn getSelMaps objs =
(
	objs = objs as array
	allMaps = getClassInstances Bitmaptexture
	if allMaps.count > 0 then
	(
		selMaps = #()
		for i in allMaps do
		(
			depNodes = (refs.dependentNodes i)
			for i2 in depNodes do
			(
				if findItem objs i2 != 0 then selMaps += #(i)
			)
		)
		makeUniqueArray selMaps
	)
	else
	(
		messageBox "No Bitmaps in Scene"
	)
)

getSelMaps selection 

-----------------------------------------------------------
::VizCards
try(destroyDialog VizCards)catch()
theIniFile = getDir #plugcfg + "\\VizCards.ini"
rollout VizCards "PreViz Cards Helper"
(	
	Label label1 "--- FIRST COPY CARDS ---" 
	button cMtl "!!! Copy Material !!!" width: 140 height: 30
	progressBar pb12 "ProgressBar" pos:[6,60] width:178 height:6 enabled:true value:100 color:(color 128 128 128)
	button btn_sFrame "Start Frame = Current Time" height: 25
	progressBar pb13 "ProgressBar" pos:[6,100] width:178 height:6 enabled:true value:100 color:(color 128 128 128)
	spinner spn_mStart "Start Frame" range:[0,5000,0] type: #integer fieldwidth: 45 
	spinner spn_mPlay "Playback Rate" range:[-100,100,1] fieldwidth: 35 spinner spn_mEnd "End Condition" range:[0,2,0] type: #integer fieldwidth: 25 
	Label label5 "0 = Loop, 1 = Ping Pong, 2 = Hold" style_sunkenedge:true width:180 height:18 pos:[6, 185]
	
	on cMtl pressed do
	(
		for i in selection do
		(
			i.material = copy i.material
		)
		for obj in selection do
		(
			obj.material.name = "mtl_" + obj.name
		)
	)
	
	on btn_sFrame pressed do
	(
		for i in getSelMaps selection do
		(
			i.starttime = currenttime
		)
	)
	
	on spn_mStart changed newV do
	(
		for i in getSelMaps selection do
		(
			i.starttime = spn_mStart.value			
		)
	)
--
	on spn_mPlay changed newV do
	(
		for i in getSelMaps selection do
		(
			i.playBackRate = spn_mPlay.value
		)
	)
--
	on spn_mEnd changed newV do
	(
		for i in getSelMaps selection do
		(
			i.endCondition = spn_mEnd.value			
		)
	)
--	
	on VizCards moved pos do
	(
		setIniSetting theIniFile "Dialog" "Position" (pos as string)
	)
	
) --End rollOut

thePos = execute (getIniSetting theIniFile "Dialog" "Position")
if thePos == OK do thePos = [100,100]
createdialog VizCards width:190 height:220 pos:[thePos.x,thePos.y]