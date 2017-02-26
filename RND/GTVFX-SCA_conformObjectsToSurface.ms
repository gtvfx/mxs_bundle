/***************************************************************************************************
Copyright (C) 2013 - 2014  Gavyn Thompson

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. if not, see <http://www.gnu.org/licenses/>.
***************************************************************************************************/
/***************************************************************************************************
Author:				Gavyn Thompson
Company:				GTVFX
Website:				www.gtvfx.com
Email:				gthompson@gtvfx.com
ScriptVersion:			v1.00
Updated:				<DATE>
[Purpose]

***************************************************************************************************/
try(destroyDialog conSurf.ro)catch()
struct conformToSurface_lib
(
	self,
	ro,
	
	fn snapObjectsToMesh axis baseMesh offset:0.0 wrap:false =
	(
		rayaxis = case axis of
		(
			"+X":([1,0,0])
			"-X":([-1,0,0])
			"+Y":([0,1,0])
			"-Y":([0,-1,0])
			"+Z":([0,0,1])
			"-Z":([0,0,-1])
			default:axis
		)
		if wrap then
		(
			for i in selection do
			(
				objClass = classOf i
				convertTo i PolyMeshObject
				progressStart ("Snapping Vertices to Mesh: " + i.name)
				inc = 100.0/i.verts.count
				incU = inc
				for v in i.verts do
				(
					IntersectedRay = intersectRay baseMesh (ray v.pos rayaxis)
					if IntersectedRay != undefined then
					(
						IntersectedRay.pos = IntersectedRay.pos + (rayaxis)*(-1)*offset
						v.pos = IntersectedRay.pos					
					)
					else
					(
						format "***** No intersection found for vertex: % *****\n" v
					)
					progressUpdate incU
					incU += inc
				)
				try(convertTo i objClass)catch(format "***** Unable to convert object back to % *****\n" objClass)
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
				IntersectedRay = intersectRay baseMesh (ray i.position rayaxis)
				if IntersectedRay != undefined then
				(
					i.position = IntersectedRay.pos + (rayaxis)*(-1)*offset
				)
				else
				(
					messageStr = stringStream ""
					format "***** Pivot axis % does not intersect % *****\n" axis baseMesh.name to:messageStr
					messageBox (messageStr as string) title:"GTVFX:"
				)
				
				progressUpdate incU
				incU += inc
			)
			progressEnd()
		)
	),
	fn tapeFilter obj = isKindOf obj tape,
	fn ui =
	(
		rollout ro "Conform Object to Surface by GTVFX" width:300 height:320
		(
			local self
			local dnToolTip
			local clrWindow = ((colorMan.getColor #window)*255)
			local clrText = ((colorMan.getColor #text)*255)
			local ClrBackGround = ((colorMan.getColor #background)*255)
			local rdoBtnArr = #()
			local cfmBtnArr = #()
			local baseMesh
			local userRay
			
			dotNetControl dNrdo_pick "radiobutton" width:(ro.width-20) height:40 offset:[-3,0]
			group "Conform Options:"
			(
				dotNetControl dNrdo_pivot "radiobutton" across:2
				dotNetControl dNrdo_vertices "radiobutton"
			)
			group "World Axis Direction:"
			(
				dotNetControl dNrdo_posX "radiobutton" width:70 offset:[10,0] across:3
				dotNetControl dNrdo_posY "radiobutton" width:70 offset:[20,0]
				dotNetControl dNrdo_posZ "radiobutton" width:70 offset:[30,0]
				dotNetControl dNrdo_negX "radiobutton" width:70 offset:[10,0] across:3
				dotNetControl dNrdo_negY "radiobutton" width:70 offset:[20,0]
				dotNetControl dNrdo_negZ "radiobutton" width:70 offset:[30,0]
				dotNetControl dNrdo_userRay "radiobutton" width:(ro.width-40) height:20 offset:[7,0]
				
				dotNetControl dNrdo_viewPort "radiobutton" width:(ro.width-40) height:20 offset:[7,0]
			)
			dotNetControl dNspn_offset "NumericUpDown" width:60 height:20 across:2
			dotNetControl dNlbl_offset "Label" width:140 height:20 offset:[-75,8]
			dotNetControl dNbtn_execute "button" width:(ro.width-20) height:40 offset:[-3,0]
			hyperLink hyp_website "www.gtvfx.com" color:orange  hoverColor:red visitedColor:orange address:"http://www.gtvfx.com" pos:[(ro.width/2-40),(ro.height - 23)]
			
			fn initToolTip dNetObj caption =
			(
				if dnTooltip == undefined then
				(
					dnToolTip = dotnetobject "ToolTip"
					dnToolTip.AutoPopDelay = 5000
					dnToolTip.InitialDelay = 300
					dnToolTip.ReshowDelay = 300
					dnToolTip.ShowAlways = true
					dnToolTip.IsBalloon = true
				)
				dnToolTip.SetToolTip dNetObj caption
			)
			fn setDotNetWidget dNobj caption fontSize colorOffsetInt:0 =
			(
				dNobj.text = caption
				dNobj.forecolor = dNobj.forecolor.FromArgb clrText.x clrText.y clrText.z
				dNobj.backColor = dNobj.backcolor.FromArgb (ClrBackGround.x+colorOffsetInt) (ClrBackGround.y+colorOffsetInt) (ClrBackGround.z+colorOffsetInt)
				dNobj.Font = dotNetObject "System.Drawing.Font" "Tahoma" fontSize ((dotNetClass "System.Drawing.FontStyle").bold)
			)
			fn initDnetChk dNchk caption fontsize useAsButton:false tooltip:"" =
			(
				setDotNetWidget dNchk caption fontSize
				initToolTip dNchk tooltip
			)
			fn initDnetRdo dNrdo caption fontsize useAsButton:false tooltip:"" =
			(
				if useAsButton then
				(
					dNrdo.appearance = dNrdo.appearance.button
					dNrdo.flatstyle = dNrdo.flatstyle.flat
					dNrdo.textAlign = (dotNetClass "System.Drawing.ContentAlignment").middleCenter
					dNrdo.FlatAppearance.checkedBackColor = (dotnetClass "System.Drawing.Color").dodgerBlue
				)
				else
				(
					dNrdo.appearance = dNrdo.appearance.normal
				)
				setDotNetWidget dNrdo caption fontSize
				initToolTip dNrdo tooltip
			)
			fn initDnetBtn dNbtn caption fontSize style:#popup check:false colorOffsetInt:0 tooltip:"" = 
			(
				case style of
				(
					#flat:(dNbtn.flatStyle = dNbtn.flatStyle.flat)
					#popup:(dNbtn.flatStyle = dNbtn.flatStyle.popup)
					#system:(dNbtn.flatStyle = dNbtn.flatStyle.system)
				)
				setDotNetWidget dNbtn caption fontSize colorOffsetInt:colorOffsetInt
				initToolTip dNbtn tooltip
			)
			fn checkRdoBtn btnArr rdoBtn =
			(
				for i in btnArr do
				(
					case i of
					(
						(rdoBtn):(i.checked = true;dNrdo_userRay.text = "User Defined Ray")
						default:(i.checked = false)
					)
				)
			)
			fn drawUserRay =
			(
				obj01 = pickObject prompt:"Pick object to draw away from"
				obj02 = pickObject prompt:"Pick object to draw towards" forceListenerFocus:true
				if obj01 != undefined and obj02 != undefined then
				(
					userRay = self.createTapeHelper obj01 obj02
					dNrdo_userRay.text = userRay.name
					checkRdoBtn rdoBtnArr #none
				)
				else
				(
					messageBox "Could not define start and end points for tape object." title:"GTVFX:"
					dNrdo_userRay.text = "User Defined Ray"
					checkRdoBtn rdoBtnArr dNrdo_negZ
				)
			)
			fn _init pself =
			(
				self = pself
				rdoBtnArr = #(dNrdo_negX,dNrdo_negY,dNrdo_negZ,dNrdo_posX,dNrdo_posY,dNrdo_posZ)
				cfmBtnArr = #(dNrdo_pivot,dNrdo_vertices)
				initDnetRdo dNrdo_pick "Pick Base Surface" 8 useAsButton:true tooltip:"Pick the base object you want to snap to"
				
				initDnetChk dNrdo_pivot "Conform Pivot Only" 8 tooltip:"Snap the object, from it's pivot, to the surface"
				dNrdo_pivot.checked = true
				initDnetChk dNrdo_vertices "Conform All Vertices" 8 tooltip:"Snap each vertices to the surface"
				
				initDnetChk dNrdo_negX "-X" 10
				initDnetChk dNrdo_negY "-Y" 10
				initDnetChk dNrdo_negZ "-Z" 10
				dNrdo_negZ.checked = true
				initDnetChk dNrdo_posX "+X" 10
				initDnetChk dNrdo_posY "+Y" 10
				initDnetChk dNrdo_posZ "+Z" 10
				
				initDnetRdo dNrdo_userRay "User Defined Ray" 8 useAsButton:true tooltip:"Pick an existing Tape Helper to us as the Ray direction"
				
				initDnetRdo dNrdo_viewPort "User Defined Ray" 8 useAsButton:true tooltip:""
				
				initDnetChk dNspn_offset "" 8 tooltip:"Offset the resulting object position from the base surface by this amount\n(System Units)"
				dNspn_offset.text = "0.0"
				dNspn_offset.DecimalPlaces = 1
				dNspn_offset.Increment = 0.1
				dNspn_offset.BorderStyle = (dotNetClass "System.Windows.Forms.BorderStyle").FixedSingle
				initDnetChk dNlbl_offset ":Offset Conform Position" 8
				
				initDnetBtn dNbtn_execute "Execute" 10 style:#flat colorOffsetInt:5
			)
			on dNrdo_pivot Click arg do
			(
				checkRdoBtn cfmBtnArr dNrdo_pivot
			)
			on dNrdo_vertices Click arg do
			(
				checkRdoBtn cfmBtnArr dNrdo_vertices
			)
			on dNrdo_negX Click arg do
			(
				checkRdoBtn rdoBtnArr dNrdo_negX
			)
			on dNrdo_negY Click arg do
			(
				checkRdoBtn rdoBtnArr dNrdo_negY
			)
			on dNrdo_negZ Click arg do
			(
				checkRdoBtn rdoBtnArr dNrdo_negZ
			)
			on dNrdo_posX Click arg do
			(
				checkRdoBtn rdoBtnArr dNrdo_posX
			)
			on dNrdo_posY Click arg do
			(
				checkRdoBtn rdoBtnArr dNrdo_posY
			)
			on dNrdo_posZ Click arg do
			(
				checkRdoBtn rdoBtnArr dNrdo_posZ
			)
			on dNrdo_pick mouseDown arg do
			(
				if arg.button == dNrdo_pick.mouseButtons.left then
				(
					dNrdo_pick.checked = true
					dNrdo_pick.ForeColor = (dotnetClass "System.Drawing.Color").darkRed
					dNrdo_pick.text = "...Select Object from Scene..."
					baseMesh = pickObject()
					if baseMesh != undefined then
					(
						dNrdo_pick.text = baseMesh.name
					)
				)
				else if arg.button == dNrdo_pick.mouseButtons.right then
				(
					dNrdo_pick.checked = false
					initDnetRdo dNrdo_pick "Pick Base Surface" 8 useAsButton:true tooltip:"Pick the base object you want to snap to"
					baseMesh = undefined
					dNrdo_pick.text = "Pick Base Surface"
				)
			)
			on dNrdo_userRay Click arg do
			(
				if arg.button == dNrdo_userRay.mouseButtons.left then
				(
					dNrdo_userRay.ForeColor = (dotnetClass "System.Drawing.Color").darkRed
					dNrdo_userRay.text = "...Select tape object..."
					userRay = pickObject prompt:"Select a Tape object" filter:self.tapeFilter forceListenerFocus:true
					dNrdo_userRay.text = userRay.name
					checkRdoBtn rdoBtnArr #none
				)
			)
			on dNspn_offset MouseDown arg do
			(
				if arg.button == dNspn_offset.mouseButtons.right then
				(
					dNspn_offset.text = "0"
				)
			)
			on dNbtn_execute mouseClick arg do
			(
				if baseMesh != undefined then
				(
					axis = (for i in rdoBtnArr where i.checked collect i)[1]
					if axis != undefined then axis = axis.text else axis = (userRay as ray).dir
					self.snapObjectsToMesh axis baseMesh offset:(dNspn_offset.text as float) wrap:dNrdo_vertices.checked
				)
				else
				(
					messageBox "Pick a Base Surface first... :(" title:"GTVFX:"
				)
			)
			on ro help do
			(
				format "***** Help coming soon *****\n"
			)
		)
		createDialog ro
		ro._init self
	),
	fn _init =
	(
		self = this
		ui()
	),
	init = _init()
)

conSurf = conformToSurface_lib()








