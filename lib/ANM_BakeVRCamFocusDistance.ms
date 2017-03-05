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
ScriptVersion:			
Updated:				08/29/2013
[Purpose]
Constains a point to a selected object and bakes the cameras focus distance to that point.

*************************************************************************************/


mxs.Using "MxsCommonFns"

try(destroyDialog _bakeVRCamFocus.ro)catch()
struct BakeVrayCameraFocus
(
	self,
	meshArr = #(),
	attachPointArr,
	bakePointArr,
	curCam,
	ro,
	showUi = False,
	
	fn VRcamera_filt obj = isKindOf obj VRayPhysicalCamera,
	
	fn CollectCamNames vrayCam:false=
	(
		if vrayCam then
		(
			arr = for i in cameras where classOf i == VRayPhysicalCamera collect i.name
		)
		else
		(
			arr = for i in cameras where classOf i != Targetobject and classOf i != VRayPhysicalCamera collect i.name
		)
		arr
	),
	
	fn CollectCamsFromNames nameArr arr:#()=
	(
		for i in nameArr do append arr (getNodeByName i)
		arr
	),
	
	fn AttachPointToObject_FN objArr faceID = 
	(
		attachPointArr = #()
		_GenFns.CreateLayerAndSetCurrent "###_Atch_Points"
		for i in objArr do
		(
			atPoint = point name:(i.name + "_Atch") size:10 centerMarker:false cross:false box:true axistripod:true wirecolor:(color 255 0 255)
			atPoint.position.controller = attachment node:i align:true
			AttachCtrl.addNewKey atPoint.position.controller 1
			theKey = AttachCtrl.getKey atPoint.position.controller 1
			theKey.time = animationRange.start
			theKey.face = faceID
			theKey.coord = [0,1]
			append attachPointArr atPoint
		)
		select attachPointArr
		attachPointArr
	),
	
	fn BakePointToObject objArr =
	(
		_GenFns.CreateLayerAndSetCurrent "###_Anm_Baked"
		maxOps.setDefaultTangentType #flat #flat writeInCfgFile:true -- Sets the New Key value to Auto
		bakePointArr = #()
		for i in objArr do
		(
			if isProperty i "transform" == true then
			(
				bakePoint = point size:10 centerMarker:false cross:false box:true axistripod:true wirecolor:orange name:(i.name + "_bakePoint")
				append bakePointArr bakePoint
				with animate on 
				(
					for t = (animationRange.start - 5f) to (animationrange.end + 5f) do
					(
						at time t 
						(
							bakePoint.transform = i.transform
						)
					)
				)
			)	
		)
		bakePointArr
	),
	
	fn BakeCamFocusDistance_FN camArr obj =
	(
		if camArr.count != 0 do
		(
			for i in camArr do
			(
				i.specify_focus = true
				with animate on 
				(
					for t = (animationRange.start - 5f) to (animationrange.end + 5f) do
					(
						at time t 
						(
							i.focus_distance = (distance i obj)
						)
					)
				)
			)
		)
	),
	
	fn ui =
	(
		rollout ro "Bake VRay Cam Focus Distance By GTVFX"
		(
			local self
			label lbl_cam "Camera: " align:#left
			multiListBox mlb_cams height:10
			
			group "Select Object"
			(
				button btn_pickObject "Pick Focus Object" width:250 height:40 toolTip:"Hit the button, then select the object you wish to focus on."
				label lbl_object "Focus Obj: " 
			)
			
			group "Bake Focus Distance"
			(
				button btn_Bake "Bake It!" width:250 height:45 toolTip:"Bake the cameras focus distance." enabled:false
			)
			
			hyperLink hyp_website "www.gtvfx.com" color:orange  hoverColor:red visitedColor:orange address:"http://www.gtvfx.com" pos:[(ro.width/2-40),(ro.height - 23)]
			
			fn _init pself =
			(
				self = pself
				mlb_cams.items = self.collectCamNames vrayCam:true
				mlb_cams.selection = #{1}
			)
			
			on btn_pickObject pressed do
			(
				clearSelection()
				print "**** Select Focus Object ***"
				self.meshArr = #()
				self.meshArr += pickObject()
				lbl_object.text = "Focus Obj: "
				lbl_object.text += self.meshArr[1].name
				btn_Bake.enabled = true
			)
			
			on btn_Bake pressed do
			(
				camNameArr = for i in mlb_cams.selection collect mlb_cams.items[i]
				self.attachPointToObject_FN self.meshArr 1
				self.bakePointToObject self.attachPointArr
				delete self.attachPointArr
				_GenFns.DeleteLayerByName "###_Atch_Points"
				self.bakeCamFocusDistance_FN (self.collectCamsFromNames camNameArr) self.bakePointArr[1]
			)
		)
		
		createdialog ro width:350 height:350
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


BakeVrayCameraFocus = BakeVrayCameraFocus()
