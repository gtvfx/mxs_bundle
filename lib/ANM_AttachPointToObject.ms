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
ScriptVersion:			v1.20
Updated:				08/23/2015
[Purpose]
Creates an attachment constrain from one object to another. By default this tool generates
a point helper to attach to another object. 
This is useful if you need a locator to follow a deforming mesh such as a point-cached character.
***************************************************************************************************/
_mxs.Using "DotNetUi" inReload:False

try(destroyDialog _atch.ro)catch()
struct attachPointStruct
(
	self,
	ro,
	atchObj,
	atchPoint,
	showUi = False,
	
	fn GetAtchPoint =
	(
		this.atchPoint = point name:("_Attachment") centermarker:false cross:false box:true axistripod:true wireColor:(color 255 0 255)
	),
	
	fn AttachPointToObject_FN obj _pointHelper: face:1 = 
	(
		if _pointHelper == unsupplied then
		(
			_pointHelper = this.GetAtchPoint()
		)
		
		_pointHelper.name = UniqueName (obj.name + "_Attachment")
		_pointHelper.position.controller = attachment()
		_pointHelper.position.controller.node = obj
		_pointHelper.position.controller.align = true
		
		AttachCtrl.addNewKey _pointHelper.position.controller 1
		
		local atchKey = AttachCtrl.getKey _pointHelper.position.controller 1
		atchKey.time = animationRange.start
		atchKey.face = face
		atchKey.coord = [0,1]
	),
	
	fn UpdateAtchFace obj pnt face =
	(
		local atchCtrl = pnt.position.controller
		local numFaces = getNumFaces obj.mesh
		local atchKey = AttachCtrl.getKey atchCtrl 1
		atchKey.face = face
		atchKey.coord = [0,1]
		atchCtrl.manupdate = True
		AttachCtrl.update atchCtrl
		atchCtrl.manupdate = False
	),
	
	fn ui =
	(
		rollout ro "Attach Point to Object By GTVFX" width:300
		(
			local self
			local dnToolTip
			local clrWindow = ((colorMan.getColor #window)*255)
			local clrText = ((colorMan.getColor #text)*255)
			local ClrBackGround = ((colorMan.getColor #background)*255)
			local btnText01 = "Attach to this object..."
			local btnText02 = "Point helper..."
			
			checkBox chk_autoPoint ":Auto generate point helper"
			dotNetControl dNbtn_this "Button" width:(ro.width-25) height:25
			dotNetControl dNbtn_toThis "Button" width:(ro.width-25) height:30
			
			group "Attachment Settings:"
			(
				spinner spn_face "Face:" range:[1,999999999,1] type:#integer align:#left fieldWidth:50 across:2
				spinner spn_size "Point Size:" range:[-999999999,999999999,1.] type:#float align:#left fieldWidth:50
			)
			
			dotNetControl dNbtn_atch "Button" width:(ro.width-25) height:40
			
			hyperLink hyp_website "www.gtvfx.com" color:orange  hoverColor:red visitedColor:orange address:"http://www.gtvfx.com"
			
			fn geomFilt obj = (superClassOf obj == geometryClass)
			
			fn dNetPickObj dNbtn objFilter:False _filter: =
			(
				local bText = dNbtn.text
				local obj = undefined
				
				dNbtn.text = "*** Pick object from scene ***"
				
				if not objFilter then
				(
					obj = pickObject()
				)
				else
				(
					obj = pickObject filter:_filter
				)
				
				if obj != undefined then
				(
					dNbtn.text = obj.name
				)
				else
				(
					dNbtn.text = bText
				)
				
				obj
			)
			
			fn PosHyperLink posX posY =
			(
				hyp_website.pos = [posX,posY]
			)
			
			fn CheckReady =
			(
				if self.atchObj == undefined then return False
				True
			)
			
			fn EnableAtchSettings =
			(
				if self.atchPoint == undefined then return False
				if classOf self.atchPoint != point then
				(
					spn_size.enabled = False
				)
				else
				(
					spn_size.value = self.atchPoint.size
					spn_size.enabled = True
				)
				spn_face.enabled = True
				True
			)
			
			fn _init pself =
			(
				self = pself
				chk_autoPoint.checked = True
				
				_dotNet.initDnetBtn dNbtn_this btnText02 10 style:#popup colorOffsetInt:10 tooltip:"Press this button, then pick the object you want to attach"
				_dotNet.initDnetBtn dNbtn_toThis btnText01 10 style:#popup colorOffsetInt:10 tooltip:"Press this button, then pick the object you want to attach to"
				_dotNet.initDnetBtn dNbtn_atch "Attach Point" 11 style:#popup colorOffsetInt:10 tooltip:"Apply the attach constraint"
				
				dNbtn_atch.enabled = checkReady()
				dNbtn_this.enabled = False
				spn_face.enabled = False
				spn_size.enabled = False
			)
			
			on chk_autoPoint changed state do
			(
				dNbtn_this.enabled = not state
				if not state then btnText02 = "Pick object to constrain..." else btnText02 = "Point helper..."
				dNbtn_this.text = btnText02
			)
			
			on dNbtn_this mouseClick do
			(
				self.atchPoint = (dNetPickObj dNbtn_this)
				if self.atchPoint == undefined then dNbtn_this.text = btnText02
			)
			
			on dNbtn_this mouseEnter arg do
			(
				_dotNet.initToolTip dNbtn_this dNbtn_this.tag
			)
			
			on dNbtn_this MouseLeave arg do
			(
				_dotNet.destroyToolTip()
			)
			
			on dNbtn_toThis mouseClick do
			(
				self.atchObj = (dNetPickObj dNbtn_toThis objFilter:True _filter:geomFilt)
				
				dNbtn_atch.enabled = checkReady()
				if self.atchObj == undefined then dNbtn_toThis.text = btnText01
			)
			
			on dNbtn_toThis mouseEnter arg do
			(
				_dotNet.initToolTip dNbtn_toThis dNbtn_toThis.tag
			)
			
			on dNbtn_toThis MouseLeave arg do
			(
				_dotNet.destroyToolTip()
			)
			
			on spn_face changed val do
			(
				self.updateAtchFace self.atchObj self.atchPoint val
			)
			
			on spn_size changed val do
			(
				self.atchPoint.size = val
			)
			
			on dNbtn_atch mouseClick do
			(
				self.attachPointToObject_FN self.atchObj face:1 auto:chk_autoPoint.state
				enableAtchSettings()
			)
			
			on dNbtn_atch mouseEnter arg do
			(
				_dotNet.initToolTip dNbtn_atch dNbtn_atch.tag
			)
			
			on dNbtn_atch MouseLeave arg do
			(
				_dotNet.destroyToolTip()
			)
			
			on ro open do
			(
				PosHyperLink (ro.width/2-40) (ro.height - 20)
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

_atch = attachPointStruct()