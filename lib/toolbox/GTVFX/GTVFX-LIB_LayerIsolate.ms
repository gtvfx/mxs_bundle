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
Updated:				03/12/2014
[Purpose]
Hides all layers except for the layers of the selected objects
***************************************************************************************************/
struct layerIsolate_lib
(
	self,
	ro,
	roPos,
	layIso_ini = ((getDir #plugCFG)+@"\GTVFX_layIso.ini"),
	layerStateArr = #(),
	
	fn macroFromString macroName mcrCategory buttonText stringCommand =
	(
		str = stringStream ""
		format ("macroScript %\ncategory:\"%\"\nbuttonText:\"%\"\n(\n\t%\n)\n") \
		macroName mcrCategory buttonText stringCommand to:str
		seek str 0
		readExpr str
	),
	fn findMenuItemIndex mnu strName =
	(
		if mnu != undefined and mnu.numItems() != 0 then
		(
			for i in 1 to mnu.numItems() do
			(
				if ((mnu.getItem i).getTitle() == strName) then return i
			)
			false
		)
		else
		(
			format "***** No items could be collected *****\n"
			return undefined
		)
	),
	fn layIso_macro =
	(
		macroFromString "'GTVFX-layIso'" "GTVFX" "Isolate By Layer: GTVFX" "if layIso != undefined then layIso.run() else messageBox \"Unable to access layerIsolate_lib.\" title:\"GTVFX: File Access Error\""
	),
	fn purgeLayIsoItems =
	(
		quadMnu = menuMan.findQuadMenu "Default Viewport Quad"
		quadMnu_2 = quadMnu.getMenu 2
		itemArr = #()
		for i in 1 to quadMnu_2.numItems() do
		(
			if matchPattern ((quadMnu_2.getItem i).getTitle()) pattern:"*Isolate By Layer*" then appendIfUnique itemArr (quadMnu_2.getItem i)
		)
		if itemArr.count != 0 then
		(
			for i in itemArr do
			(
				quadMnu_2.removeItem i
			)
		)
	),
	fn layIso_quadMenuItem =
	(
		quadMnu = menuMan.findQuadMenu "Default Viewport Quad"
		quadMnu_2 = quadMnu.getMenu 2
		if findMenuItemIndex quadMnu_2 "Isolate By Layer: GTVFX" != false then return false
		indx = findMenuItemIndex quadMnu_2 "Isolate Selection"
		if indx != undefined then
		(
			actItm = menuMan.createActionItem "GTVFX_layIso" "GTVFX"
			quadMnu_2.addItem actItm indx
		)
		else
		(
			format "***** Could not add layIso menu item... *****\n"
		)
	),
	fn layIso_startupScript =
	(
		startUpFile = ((getDir #userStartupScripts) + @"\GTVFX-LIB_layIsoStartUp.ms")
		if doesFileExist startUpFile then return false
		str = stringStream ""
		format "sFile = (getFiles ((getDir #scripts) + @\"\GTVFX\GTVFX-LIB_layerIsolate.*\"))[1]\nif doesFileExist sFile then filein sFile else messageBox \"Unable to access layerIsolate_lib\"" to:str
		fileStrm = openfile startUpFile mode:"w"
		format (str as string) to:fileStrm
		close fileStrm
		true
	),
	fn isolateLayersByObjSelection objArr =
	(
		if objArr.count != 0 then
		(
			layerArr = #()
			for i in objArr do
			(
				appendIfUnique layerArr i.layer
			)
			for i in 0 to layerManager.count-1 do
			(
				iLayer = layerManager.getLayer i
				if findItem layerArr iLayer == 0 then iLayer.on = false
			)
		)
		else
		(
			messageBox "Nothing selected... :(" title:"GTVFX:"
		)
	),
	fn saveLayerStates layerStateArr =
	(
		if classOf layerStateArr == array then
		(
			for i in 0 to layerManager.count-1 do
			(
				iLayer = layerManager.getLayer i
				append layerStateArr #(iLayer.name, iLayer.on)
			)
		)
	),
	fn restoreLayerStates layerStateArr =
	(
		if layerStateArr != undefined and layerStateArr.count != 0 then
		(
			for i in layerStateArr do
			(
				(layerManager.getLayerFromName i[1]).on = i[2]
			)
		)
	),
	fn ui =
	(
		rollout ro "Layer Isolate By GTVFX"
		(
			local self
			checkButton cBtn_isolate "Layers Isolated" checked:true width:(ro.width-20) height:40 
			
			fn _init pself =
			(
				self = pself
			)
			on cBtn_isolate changed arg do
			(
				self.restoreLayerStates self.layerStateArr
				destroyDialog ro
			)
			on ro moved pos do
			(
				setIniSetting self.layIso_ini "UI" "Position" (pos as string)
			)
		)
		createDialog ro width:180 pos:roPos
		ro._init self
	),
	fn run =
	(
		if selection.count != 0 then
		(
			if doesFileExist layIso_ini and hasIniSetting layIso_ini "UI" "Position" then
			(
				roPos = (execute (getIniSetting layIso_ini "UI" "Position")) 
			)
			else roPos = [850,420]
			ui()
			saveLayerStates layerStateArr
			isolateLayersByObjSelection (getCurrentSelection())
		)
		else
		(
			messageBox "Nothing Selected...:(" title:"GTVFX:"
		)
	),
	fn _init =
	(
		self = this
		purgeLayIsoItems()
		layIso_macro()
		layIso_startupScript()
		layIso_quadMenuItem()
	),
	init = _init()
)
try(destroyDialog layIso.ro)catch()
::layIso = layerIsolate_lib()
