/***************************************************************************************************
Copyright (C) 2013 - 2017  Gavyn Thompson

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
Author:				    Gavyn Thompson
Company:				GTVFX
Website:				https://github.com/gtvfx
Email:				    gftvfx@gmail.com
ScriptVersion:			v2.0
Updated:				08/23/2015
[Purpose]:
Set the Out-Of-Range Types for the selected objects
Optionally you can change the tangents on the first and last frames.
This is only for Position, Rotation, Scale, and Visibility
***************************************************************************************************/

/*------------------------------------------------------------------------------------------------
					Using
------------------------------------------------------------------------------------------------*/
mxs.Using "DotNetUi"


try(destroyDialog SetOutOfRangeType.ro)catch()
struct SetOutOfRangeType 
(
	self,
	ro,
	nodeArr = #(),
	propArr = #(),
	showUi = False,
	
	fn SetORT obj conName inType outType =
	(
		case conName of
		(
			#position:
			(
				if inType != #none then setBeforeORT obj.position.controller inType
				if outType != #none then setAfterORT obj.position.controller outType
			)
			#rotation:
			(
				if inType != #none then setBeforeORT obj.rotation.controller inType
				if outType != #none then setAfterORT obj.rotation.controller outType
			)
			#scale:
			(
				if inType != #none then setBeforeORT obj.scale.controller inType
				if outType != #none then setAfterORT obj.scale.controller outType
			)
			#visibility:
			(
				if inType != #none then setBeforeORT obj.visibility.controller inType
				if outType != #none then setAfterORT obj.visibility.controller outType
			)
			default:
			(
				if inType != #none then setBeforeORT (getPropertyController obj conName) inType
				if outType != #none then setAfterORT (getPropertyController obj conName) outType
			)
		)
	),
	
	fn SetStartEndTangents obj conName inType outType =
	(
		case conName of
		(
			#position:
			(
				local keyArr = obj.position.controller.keys
				if keyArr.count != 0 and classOf obj.position.controller == Position_XYZ then
				(
					for i = 1 to 3 do
					(
						if inType != #none then
						(
							local k = obj.position.controller[i].keys[keyArr.count]
							k.outTangentType = outType
							k.inTangentType = inType
						)
						
						if outType != #none then
						(
							local k = obj.position.controller[i].keys[1]
							k.outTangentType = outType
							k.inTangentType = inType
						)
					)
				)
			)
			#rotation:
			(
				local keyArr = obj.rotation.controller.keys
				if keyArr.count != 0 and classOf obj.rotation.controller == Euler_XYZ then
				(
					for i = 1 to 3 do
					(
						if inType != #none then
						(
							local k = obj.rotation.controller[i].keys[keyArr.count]
							k.outTangentType = outType
							k.inTangentType = inType
						)
						
						if outType != #none then
						(
							local k = obj.rotation.controller[i].keys[1]
							k.outTangentType = outType
							k.inTangentType = inType
						)
					)
				)
			)
			#scale:
			(
				local keyArr = obj.scale.controller.keys
				if keyArr.count != 0 then
				(
					case (classOf obj.scale.controller) of
					(
						(bezier_scale):
						(
							if inType != #none then
							(
								local k = obj.scale.controller.keys[keyArr.count]
								k.outTangentType = outType
								k.inTangentType = inType
							)
							
							if outType != #none then
							(
								local k = obj.scale.controller.keys[1]
								k.outTangentType = outType
								k.inTangentType = inType
							)
						)
						(scaleXYZ):
						(
							for i = 1 to 3 do
							(
								if inType != #none then
								(
									local k = obj.scale.controller[i].keys[keyArr.count]
									k.outTangentType = outType
									k.inTangentType = inType
								)
								
								if outType != #none then
								(
									local k = obj.scale.controller[i].keys[1]
									k.outTangentType = outType
									k.inTangentType = inType
								)
							)
						)
						default:
						(
							format "***** Unable to set tangent on scale controller. *****\n"
						)
					)
				)
			)
			#visibility:
			(
				local keyArr = obj.visibility.controller.keys
				if keyArr.count != 0 and classOf obj.visibility.controller == bezier_float then
				(
					if inType != #none then
					(
						local k = obj.visibility.controller.keys[keyArr.count]
						k.outTangentType = outType
						k.inTangentType = inType
					)
					
					if outType != #none then
					(
						local k = obj.visibility.controller.keys[1]
						k.outTangentType = outType
						k.inTangentType = inType
					)
				)
			)
			default:
			(
				local propCtrlr = (getPropertyController obj conName)
				local keyArr = propCtrlr.keys
				if keyArr.count != 0 then
				(
					if inType != #none then
					(
						local k = propCtrlr.keys[keyArr.count]
						k.outTangentType = outType
						k.inTangentType = inType
					)
					
					if outType != #none then
					(
						local k = propCtrlr.keys[1]
						k.outTangentType = outType
						k.inTangentType = inType
					)
				)
			)
		)
	),
	
	fn CollectAnimatedProperties objArr  =
	(
		local propArr = #()
		--objArr = (getCurrentSelection())
		for i in objArr do
		(
			local propNameArr = getPropNames i
			if propNameArr.count == 0 then continue
			for p in propNameArr do
			(
				if not isPropertyAnimatable i p then continue
				local propCtrl = getPropertyController i p
				if propCtrl != undefined and propCtrl.keys.count != 0 then
				(
					appendIfUnique propArr p
				)
			)
		)
		propArr
	),
	
	fn SetOrtByPropName obj propNameArr OrtIn OrtOut tanIn tanOut =
	(
		for i in propNameArr do
		(
			case i of
			(
				#position:
				(
					if not obj.position.isAnimated then continue
					this.SetORT obj #position OrtIn OrtOut
					this.SetStartEndTangents obj #position tanIn tanOut
				)
				#rotation:
				(
					if not obj.rotation.isAnimated then continue
					this.SetORT obj #rotation OrtIn OrtOut
					this.SetStartEndTangents obj #rotation tanIn tanOut
				)
				#scale:
				(
					if not obj.scale.isAnimated then continue
					this.SetORT obj #scale OrtIn OrtOut
					this.SetStartEndTangents obj #scale tanIn tanOut
				)
				#visibility:
				(
					if not obj.visibility.isAnimated then continue
					this.SetORT obj #visibility OrtIn OrtOut
					this.SetStartEndTangents obj #visibility tanIn tanOut
				)
				default:
				(
					propCtrlr = (getPropertyController obj i)
					if propCtrlr == undefined then continue
					this.SetORT obj i OrtIn OrtOut
					this.SetStartEndTangents obj i tanIn tanOut
				)
			)
		)
	),
	
	fn ui =
	(
		rollout ro "Set ORT By GTVFX" width:200
		(
			local self
			local conArr = #("Position","Rotation","Scale","Visibility")
			local typeArr = #(#none,#constant,#cycle,#loop,#pingPong,#linear,#relativeRepeat)
			local tanTypeArr = #(#none,#smooth,#linear,#step,#fast,#slow,#custom,#auto)
			
			dotNetControl dgv_cons "DataGridView" align:#left width:(ro.width-26) height:200
			dotNetControl dNbtn_refresh "Button" width:(ro.width-25) height:18
			
			group "Settings:"
			(
				dropDownList ddl_in "Set Type In:" items:typeArr selection:6
				dropDownList ddl_out "Set Type Out:" items:typeArr selection:6
				dropDownList ddl_first "Set First Frame Tangent:" items:tanTypeArr selection:3
				dropDownList ddl_last "Set Last Frame Tangent:" items:tanTypeArr selection:3
			)
			
			dotNetControl dNbtn_set "Button" width:(ro.width-25) height:40
			hyperLink hyp_website "www.gtvfx.com" color:orange  hoverColor:red visitedColor:orange address:"http://www.gtvfx.com"
			
			fn GetColArr =
			(
				out = #()
				append out #(#text,"Controller:",True,#left)
				out
			)
			
			fn DrawData dgv dataArr =
			(
				dgv.rows.clear()
				for a in dataArr do
				(
					tempRow = dotNetObject "System.Windows.Forms.DataGridViewRow"
					dgv.rows.add tempRow
					tempRow.SetValues #(a)
					case a of
					(
						"Position":
						(
							tempRow.DefaultCellStyle.ForeColor = (dotnetClass "System.Drawing.Color").red
						)
						"Rotation":
						(
							tempRow.DefaultCellStyle.ForeColor = (dotnetClass "System.Drawing.Color").green
						)
						"Scale":
						(
							tempRow.DefaultCellStyle.ForeColor = (dotnetClass "System.Drawing.Color").blue
						)
						"Visibility":
						(
							tempRow.DefaultCellStyle.ForeColor = (dotnetClass "System.Drawing.Color").cyan
						)
					)
				)
			)
			
			fn PosHyperLink posX posY =
			(
				hyp_website.pos = [posX,posY]
			)
			
			fn CellValuesToNameArr dgvRowArr =
			(
				arr = #()
				for i = 0 to (dgvRowArr.count-1) do
				(
					append arr (dgvRowArr.item[i].cells.item[0].value as name)
				)
				arr
			)
			
			fn _init pself =
			(
				self = pself
				::::_dotNet.initDnetBtn dNbtn_refresh "Refresh controller list" 8 style:#flat colorOffsetInt:10 tooltip:"Refresh the controller list for your current selection"
				::::_dotNet.initDnetBtn dNbtn_set "Set ORT for selected properties" 10 style:#popup colorOffsetInt:10 tooltip:"Go through all objects in your selection and\nset the ORT for the selected properties."
				::::_dotNet.initDgv dgv_cons 12 (GetColArr()) multiSelct:True
				
				self.nodeArr = (getCurrentSelection())
				dispCons = #()
				dispCons += conArr
					
				for i in (self.CollectAnimatedProperties self.nodeArr) do
				(
					append dispCons (i as string)
				)
				
				drawData dgv_cons dispCons
			)
			
			on dNbtn_refresh mouseClick arg do
			(
				self.nodeArr = (getCurrentSelection())
				dispCons = #()
				dispCons += conArr
				for i in (self.CollectAnimatedProperties self.nodeArr) do
				(
					append dispCons (i as string)
				)
				drawData dgv_cons dispCons
			)
			
			on dNbtn_refresh mouseEnter arg do
			(
				::::_dotNet.initToolTip dNbtn_refresh dNbtn_refresh.tag
			)
			
			on dNbtn_copy01 MouseLeave arg do
			(
				::_dotNet.destroyToolTip()
			)
			
			on dNbtn_set mouseClick arg do
			(
				if self.nodeArr.count != 0 then
				(
					conArr = CellValuesToNameArr dgv_cons.SelectedRows
					for i in self.nodeArr do
					(
						self.SetOrtByPropName i conArr ddl_in.selected ddl_out.selected ddl_first.selected ddl_last.selected
					)
				)
				else messageBox "You must have objects selected...\nMake a selection and press the refresh button." title:"GTVFX: User Error... :("
			)
			
			on dNbtn_set mouseEnter arg do
			(
				::_dotNet.initToolTip dNbtn_set dNbtn_set.tag
			)
			
			on dNbtn_set MouseLeave arg do
			(
				::_dotNet.destroyToolTip()
			)
			
			on ro open do
			(
				posHyperLink (ro.width/2-40) (ro.height - 20)
			)
		)
		createDialog ro
		ro._init self
	),
	
	fn Run =
	(
		this.Ui()
	),
	
	fn _init =
	(
		self = this
		if showUi then this.Run()
	),
	
	init = _init()
)

SetOutOfRangeType = SetOutOfRangeType()

