/******************************************
Copyright (C) 2013 - 2014  Gavyn Thompson

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
******************************************/
/******************************************
Author:				Gavyn Thompson
Company:				GTVFX
Website:				www.gtvfx.com
Email:				gthompson@gtvfx.com
ScriptVersion:			v1.00
Updated:				<DATE>
[Purpose]
Displays object relevant data in the viewport at the objects location.
******************************************/
try(destroyDialog objData.ro)catch()
::objDataDisplay
--::objDataSpacing
struct objData
(
	self,
	ro,
	spacing = 10,
	
	fn displayObjData =
	(
		gw.setTransform(matrix3 1)
		textCnt = 5
		for o in objects where not o.isHidden do
		(
			if superClassOf o == geometryClass then try(t = snapShotAsMesh o)catch(t = undefined) else t = undefined
			if t != undefined then faceNum = (t.numFaces as string) else faceNum = "* None *"
			m = if o.material != undefined then o.material.name else "undefined"
			gw.text ([o.pos.x,o.pos.y,(o.max.z+(9*spacing))]) ("Obj Name: "+o.name) color:red
			gw.text ([o.pos.x,o.pos.y,(o.max.z+(7*spacing))]) ("Obj Class: "+((classOf o) as string)) color:green
			gw.text ([o.pos.x,o.pos.y,(o.max.z+(5*spacing))]) ("Material: "+m) color:yellow
			gw.text ([o.pos.x,o.pos.y,(o.max.z+(3*spacing))]) ("Face Count: "+faceNum) color:yellow
			gw.text ([o.pos.x,o.pos.y,(o.max.z+(1*spacing))]) ("Scale: "+(o.scale as string)) color:yellow
			try(delete t)catch()
		)
		gw.enlargeUpdateRect #whole
		gw.updateScreen()
	),
	fn toggleCallback state:true =
	(
		if state then
		(
			objDataDisplay = true
			registerRedrawViewsCallback self.displayObjData
			gw.updateScreen()
		)
		else
		(
			objDataDisplay = false
			unregisterRedrawViewsCallback self.displayObjData
			gw.updateScreen()
		)
	),
	fn ui =
	(
		rollout ro "Object Data Display By GTVFX" width:230 --height:90
		(
			local self
			
			checkButton cBtn_enable "Enable Object Data Display" width:150 height:30
			
			on cBtn_enable changed state do
			(
				self.toggleCallback state:state
			)
			
			fn _init pself =
			(
				self = pself
				if objDataDisplay == undefined then objDataDisplay = true
				if objDataDisplay then
				(
					cBtn_enable.state = true
					self.toggleCallback state:cBtn_enable.state
				)
			)
			on ro close do
			(
				unregisterRedrawViewsCallback self.displayObjData
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
objData = objData()








/*
displayData()

$.numFaces