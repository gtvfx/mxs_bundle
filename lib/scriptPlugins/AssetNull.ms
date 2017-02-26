plugin helper AssetNull
name:"AssetNull"
classID:#(0x337dc07, 0x692b8cfe)
category:"ILM_Helpers"
extends:point
replaceUI:True
version:1.0
(
	local me
	local bBoxDummy
	local DispColor = (color 255 0 255)
	local UserPropNameSpace = "Asset:"
	local _assetCheckin
	local ro_display
	local ro_info
	local ro_options
	-- Dot Net Variables
	local dnTooltip
	local clrWindow = ((colorMan.getColor #window)*255)
	local clrText = ((colorMan.getColor #text)*255)
	local clrDnetText = (dotnetClass "System.Drawing.Color").FromARGB clrText.x clrText.y clrText.z
	local ClrBackGround = ((colorMan.getColor #background)*255)
	local updateClr = (dotnetClass "System.Drawing.Color").Lime
	local outdateClr = (dotnetClass "System.Drawing.Color").Tomato
	local clrDef = (dotnetClass "System.Drawing.Color").SkyBlue
	
	--local Asset_Objects = #()
	local layerStateDic
	--
	
	parameters prm_display rollout:ro_display
	(
		Display_Size type:#float animatable:False ui:spn_size
		Display_Proxy type:#boolean animatable:False default:False ui:chk_disProxy
		Display_Bbox type:#boolean animatable:False default:False ui:chk_disBox
		
		on Display_Size set val do if (this.GetMe()) != undefined then this.SizePointHelper val
		on Display_Proxy set state do if (this.GetMe()) != undefined then this.DisplayProxy bool:State
		on Display_Bbox set state do if (this.GetMe()) != undefined then this.DisplayAsBox bool:State
			
		/* 
		- The idea behind this property is to display a single bounding box for a complex asset.
		- I worked out a way to create a bounding box display using a Dummy object calculated to the bounding box of all asset objects.
		- In order to role this feature out though I'll need to work out how to ensure the asset is displayed at render time.
		===============================
		Display_SingleBox type:#boolean animatable:False default:False --ui:chk_singleBox
		on Display_SingleBox set state do if (this.GetMe()) != undefined then this.DisplaySingleBoundingBox state
		===============================
		
		
		- Hiding objects from the parameter bock caused problems originating from the load event. Object hidden state would constantly be reset to the parameter state regardless of current scene state.
		- Disabled until I can find a way to work it out.
		===============================
		Display_HideObjs type:#boolean animatable:False default:False ui:chk_disHide
		on Display_HideObjs set state do if (this.GetMe()) != undefined then print "HideObjs Set"--this.HideObjs bool:State
		===============================
		 */
	)
	
	parameters prm_info rollout:ro_info
	(
		--exposed in UI
		Asset_Version type:#string ui:dNtxt_version default:"0.0"
		Asset_FullName type:#string ui:dNtxt_fullname default:"Full Name"
		Asset_ShortName type:#string ui:dNtxt_shortname default:"Short Name"
		Asset_Type type:#string ui:dNtxt_type default:"Type"
		
		
		--on Asset_Objects tabChanged #append 0 -1 do Print "Tab Changed"
		on Asset_Version set val do this.ro_info.dNtxt_version.text = val
		on Asset_FullName set val do this.ro_info.dNtxt_fullname.text = val
		on Asset_ShortName set val do this.ro_info.dNtxt_shortname.text = val
		on Asset_Type set val do this.ro_info.dNtxt_type.text = val
			
		/* 
		- Storing the objects on the parameter block was causing some problems. 
		- The perfomance benefit is negligable in an average sized asset. A performance gain would be seen in an asset with a thousand plus objects.
		- We can revisit this if we find a need to increase the performance of object collection down the road.
		===============================
		Asset_Objects type:#nodeTab tabSizeVariable:true animatable:false
		===============================
		 */
	)
	
	parameters prm_options rollout:ro_options
	(
		Proxy type:#node ui:dNbtn_proxy
		
		on Proxy set val do this.ProxyButtonDisplay val
	)
	
	parameters prm_data
	(
		_show type:#string default:""
		_seq type:#string default:""
		_shot type:#string default:""
		_taskDir type:#string default:""
		_nst type:#boolean animatable:False default:False
		_exporting type:#boolean animatable:False default:False
		_cloning type:#boolean animatable:False default:False
		_transform type:#matrix3
		
		FileType type:#string default:"work"
		
		-- NST Required data
		instanceAsset type:#string default:""
		instanceAssetRevision type:#string default:""
		instanceAssetTrack type:#string default:""
		textureFile type:#string default:""
		geometryFile type:#string default:""
		proxyFile type:#string default:""
		loresProxyFile type:#string default:""

		
		
		-- Still playing around with these parameters. Not sure what to do with them just yet.
		CheckInType type:#string default:"show" -- "show","shot","gen"
		ResourceId type:#integer animatable:false default:0 
		ResourceName type:#string default:"none" 
		ResourceProject type:#string default:"none"
		ResourceVersion type:#string default:"none" 
		ResourceInFileVersion type:#string default:"none"
		ResourceComment type:#string default:"..void.." 
		ResourceFileName type:#filename  Asset_Type:#ExternalLink defualt:""
		AuxFiles type:#stringTab tabSizeVariable:True
		FlagUpdate type:#boolean animatable:false default:false 
		InstanceID type:#integer animatable:false default:1
	)
		
	---------( DotNet Functions
	fn ChangeTxtBoxColor txtBox newcolor =
	(
		txtBox.forecolor = newcolor
	)
	
	fn InitToolTip dNetObj caption =
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
		dnToolTip
	)
	
	fn DestroyToolTip =
	(
		dnToolTip
		if dnToolTip != undefined then
		(
			dnToolTip.RemoveAll()
			dnToolTip.Dispose()
			dnToolTip = undefined
		)
		True
	)
	
	fn NormalizeRGB val =
	(
		if val < 0 then val = 0 else if val > 255 then val = 255
		val
	)
	
	fn SetDotNetWidget dNobj caption fontSize colorOffsetInt:0 fontStyle:#bold _forecolor: =
	(
		dNobj.text = caption
		if _forecolor == unsupplied then
		(
			dNobj.forecolor = dNobj.forecolor.FromArgb clrText.x clrText.y clrText.z
		)
		else
		(
			dNobj.forecolor = _forecolor
		)
		dNobj.backColor = dNobj.backcolor.FromArgb (normalizeRGB (ClrBackGround.x+colorOffsetInt)) (normalizeRGB (ClrBackGround.y+colorOffsetInt)) (normalizeRGB (ClrBackGround.z+colorOffsetInt))
		dNobj.Font = dotNetObject "System.Drawing.Font" "Tahoma" fontSize ((dotNetClass "System.Drawing.FontStyle").bold)
	)
	
	fn InitDnetBtn dNbtn caption fontSize style:#popup _forecolor: colorOffsetInt:0 tooltip:"" = 
	(
		case style of
		(
			#flat:(dNbtn.flatStyle = dNbtn.flatStyle.flat)
			#popup:(dNbtn.flatStyle = dNbtn.flatStyle.popup)
			#system:(dNbtn.flatStyle = dNbtn.flatStyle.system)
		)
		SetDotNetWidget dNbtn caption fontSize colorOffsetInt:colorOffsetInt _forecolor:_forecolor
		dNbtn.tag = tooltip
		dNbtn.update()
	)
	
	fn InitTxtBx tbx caption fontSize fontStyle:#bold =
	(
		tbx.BorderStyle = (dotNetClass "System.Windows.Forms.BorderStyle").FixedSingle
		tbx.MultiLine = false
		tbx.AcceptsReturn = false
		tbx.AcceptsTab = false
		tbx.WordWrap = false
		tbx.readonly = True
		
		SetDotNetWidget tbx caption fontSize colorOffsetInt:0 fontStyle:fontStyle
		
		tbx.backcolor = tbx.backcolor.FromArgb clrWindow.x clrWindow.y clrWindow.z
		
		tbx.update()
	)
	
	------------) 
		
	fn GetMe refactor:False=
	(
		/* 
		This is a method to return the shape node from the class object
		Important for accessing node properties of itself
		And a quck way to get the node from a GetClassInstance call
		 */
		if me == undefined or (isDeleted me) or refactor then me = (refs.dependentNodes delegate)[1]
		me
	)
	
	fn SceneRedraw state = -- state = #on or #off
	(
		/* 
		Toggle scene redraw
		Takes into account the level to which redraw was previously disabled
		 */
		case state of
		(
			#on:
			(
				while isSceneRedrawDisabled() do
				(
					EnableSceneRedraw()
				)
			)
			#off:DisableSceneRedraw()
		)
	)
	
	fn VerPadding inString:"" _number: Pad: =
	(
		if (inString != unsupplied) and (_number != unsupplied) and (Pad != unsupplied) do
		(
			ZeroString = ""
			for x = 1 to (Pad - (_number as string).count) do (ZeroString = ZeroString + "0")
			(inString + (ZeroString + (_number as string)))
		)
	)
	
	fn GetUniqueInstanceID =
	(
		local assetArr = (GetClassInstances AssetNull)
		local instArr = for i in assetArr where i.Asset_FullName == Asset_FullName collect i.instanceid
		--format "***** instArr: % *****\n" instArr
		if instArr.count == 1 then return 1
		local uniqueID = 1
		for i in instArr do
		(
			if i >= uniqueID then uniqueID = (i+1)
		)
		uniqueID
	)
	
	fn NameByInstanceId =
	(
		GetMe()
		
		this.InstanceID = GetUniqueInstanceID()
			
		me.name = (me.Asset_ShortName + (instanceid as string))
			
		local geomNulls = for i in me.children where matchpattern i.name pattern:"geom*" collect i
			
		local rx = dotnetobject "System.Text.RegularExpressions.Regex" "[0-9]"
		
		if geomNulls.count != 0 then
		(
			for null in geomNulls do
			(
				charArray = #()
				for x = 1 to null.name.count do
				(
					
					if (rx.IsMatch null.name[x]) then
					(
						appendIfUnique charArray null.name[x]
					)
				)
				for char in charArray do
				(
					null.name = SubstituteString null.name char ""
				)
				
				if null.children.count == 1 then
				(
					null.children[1].name = (ToUpper me.Asset_Fullname)
				)
				else
				(
					format "***** geom null has more than one child *****\n"
				)
			)
		)
	)
	
	mapped fn SetParent_mapped objArr obj =
	(
		objArr.parent = obj
	)
	
	fn SetAssetProp obj propKey propVal nameSpace:UserPropNameSpace =
	(
		/* 
		Use to set user properties on the Asset_Objects denoted by a proper name space
		 */
		SetUserProp obj (nameSpace+propKey) (propVal as string)
	)
	
	fn GetAssetProp obj propKey nameSpace:UserPropNameSpace =
	(
		/* 
		Use to get user properties on the Asset_Objects denoted by a proper name space
		*/
		GetUserProp obj (nameSpace+propKey)
	)
	
	mapped fn SetPropVals_mapped objArr =
	(
		/* 
		Put asset propterties to the user prop buffer of the Asset_Objects
		*/
		SetAssetProp objArr "Transform" (objArr.transform.controller.value)
		SetAssetProp objArr "Parent" (objArr.parent)
	)
	
	fn GetNodeNameFromObjectStr Str =
	(
		/* 
		Separates the name from the string value of a Max Node
		ie...$Point_Helper:HKBbrownApartmentCtopNull @ [0.000000,348.199097,196.928101]
		wiill return "HKBbrownApartmentCtopNull"
		 */
		out = (FilterString Str ":")[2]
		out = (FilterString out " ")[1]
		out
	)
	
	mapped fn ResetFromUserProps_mapped objArr =
	(
		/* 
		Use the values stored in the user prop buffer to reset those properties
		 */
		SceneRedraw #off
		pName = (GetAssetProp objArr "Parent")
		if (pName as string) != "undefined" then
		(
			pNode = (GetNodeByName (GetNodeNameFromObjectStr pName))
			objArr.parent = pNode
		)
		aTrans = GetAssetProp objArr "Transform"
		if aTrans as string != "undefined" then objArr.transform.controller.value = (Execute aTrans)
		SceneRedraw #on
	)
	
	mapped fn SetTrackViewLocks objArr state children:True =
	(
		/* 
		Locks all the controllers (Differs from transform flags)
		 */
		LockedTracksMan.setLocks state #(objArr[3][1], objArr[3][2], objArr[3][3]) #(objArr[3], objArr[3], objArr[3]) #(1,2,3) children
	)
	
	fn GetParentsRecursive obj arr:#() =
	(
		if obj.parent != undefined do
		(
			if finditem arr obj.parent == 0 do 
			(
				append arr obj.parent
			)
			GetParentsRecursive obj.parent arr:arr
		)
		arr
	)
	
	fn GetAssetObjs obj arr:#() =
	(
		if obj.children.count != 0 then
		(
			for c in obj.children do
			(
				if ClassOf c == AssetNull then continue -- Skip asset downstream
				append arr c
				GetAssetObjs c arr:arr
			)
		)
		arr
	)
	
	fn GetParents =
	(
		GetParentsRecursive (GetMe())
	)
	
	fn GetChildAssets obj: arr:#() =
	(
		if obj == unsupplied then obj = (GetMe())
		
		if obj.children.count != 0 then
		(
			for c in obj.children where (ClassOf c == AssetNull) do
			(
				append arr c
				GetChildAssets obj:c arr:arr
			)
		)
		
		arr
	)
	
	fn CollectAssetObjs refactor:False =
	(
		/* 
		Method to always grab the Asset_Objects from the parameter block and have it retun an Array instead of an ArrayParameter
		 */
		/* 
		if refactor or Asset_Objects.count == 0 then
		(
			format "***** Collecting Asset Objects *****\n"
			Asset_Objects = GetAssetObjs (GetMe())
		)
		Asset_Objects as array
		 */
		
		Asset_Objects = GetAssetObjs (GetMe())
	)
	
	fn RefactorAssetObjects =
	(
		/*
		Method to collect new asset objects and set property values
		*/
		(GetMe()).SetPropVals_mapped ((GetMe()).CollectAssetObjs refactor:True)
	)
	
	mapped fn AddObjectsToLayer_mapped objArr layer =
	(
		layer.addNode objArr
	)
	
	fn AddObjectsToMyLayer objArr =
	(
		/* 
		Method to add objects to the AssetNulls current layer
		 */
		iLayer = LayerManager.getLayerFromName (GetMe()).layer.name
		AddObjectsToLayer_mapped objArr iLayer
	)
	
	fn ZeroObjPosRotScale obj =
	(
		/* 
		Method to zero out the values of an objects controllers.
		Not being used yet
		 */
		case (ClassOf obj.position.controller) of
		(
			(Position_XYZ):
			(
				obj.position.controller[1].value = 0
				obj.position.controller[2].value = 0
				obj.position.controller[3].value = 0
			)
			default:
			(
				format "***** No Method For Position Controller: % *****\n" (try(ClassOf obj.position.controller)catch(undefined))
			)
		)
		case (ClassOf obj.rotation.controller) of
		(
			(Euler_XYZ):
			(
				obj.rotation.controller[1].value = 0
				obj.rotation.controller[2].value = 0
				obj.rotation.controller[3].value = 0
			)
			default:
			(
				format "***** No Method For Rotation Controller: % *****\n" (try(ClassOf obj.rotation.controller)catch(undefined))
			)
		)
		case (ClassOf obj.scale.controller) of
		(
			(bezier_scale):
			(
				obj.scale = [1,1,1]
			)
			(ScaleXYZ):
			(
				obj.scale.controller[1].value = 1
				obj.scale.controller[2].value = 1
				obj.scale.controller[3].value = 1
			)
			default:
			(
				format "***** No Method For Scale Controller: % *****\n" (try(ClassOf obj.scale.controller)catch(undefined))
			)
		)
	)
	
	fn HasProxy =
	(
		case FileType of
		(
			"3dsmax":
			(
				True
			)
			default:
			(
				False
			)
		)
	)
	
	mapped fn DisplayXrefProxy_mapped objArr bool:True =
	(
		if ClassOf objArr == XRefObject then
		(
			objArr.useProxy = bool
		)
	)
	
	fn DisplayProxy bool:True =
	(
		case FileType of
		(
			"3dsmax":
			(
				--st = timeStamp()
				objArr = CollectAssetObjs()
				DisplayXrefProxy_mapped objArr bool:bool
				Display_Proxy = bool
				--GC()
				--fTime =  (timeSTamp()-st)/1000.0
				--format "Total time setting XRef proxy was % seconds\n" fTime
			)
			default:
			(
				Display_Proxy = False
				ro_display.chk_disProxy.enabled = False
			)
		)
	)
	
	mapped fn DisplayAsBox_mapped objArr bool:True =
	(
		objArr.boxmode = bool
	)
	
	fn DisplayAsBox bool:True =
	(
		/* 
		Sets the BoxMode display of all the Asset_Objects
		 */
		objArr = CollectAssetObjs()
		DisplayAsBox_mapped objArr bool:bool
		Display_Bbox = bool
	)
	
	mapped fn HideObjs_mapped objArr bool:True =
	(
		objArr.isHidden = bool
	)
	
	fn HideObjs bool:True =
	(
		/* 
		Sets the Hidden state of all the Asset_Objects
		 */
		objArr = CollectAssetObjs()
		HideObjs_mapped objArr bool:bool
		--Display_HideObjs = bool
	)
	
	fn DrawSingleBoundingBox =
	(
		arr = for i in (CollectAssetObjects()) where superClassOf i != Helper collect i
		if arr.count != 0 then
		(
			SceneRedraw #off
			select arr
			pointArr = #()
			maxPoint = selection.max
			minPoint = selection.min
			minPointXmax = [maxPoint.x,minPoint.y,minPoint.z]
			minPointXZmax = [maxPoint.x,minPoint.y,maxPoint.z]
			minPointZmax = [minPoint.x,minPoint.y,maxPoint.z]
			maxPointZmin = [maxPoint.x,maxPoint.y,minPoint.z]
			maxPointXmin = [minPoint.x,maxPoint.y,maxPoint.z]
			maxPointXZmin = [minPoint.x,maxPoint.y,minPoint.z]
			coordArr = #(maxPoint,minPoint,minPointXmax,minPointXZmax,minPointZmax,maxPointZmin,maxPointXmin,maxPointXZmin)
			for i in coordArr do
			(
				p = point pos:i
				append pointArr p
			)
			select pointArr
			GetMe()
			bBoxDummy = dummy name:(me.name + "_bBox") boxsize:(selection.max - selection.min)
			bBoxDummy.transform = me.transform
			bBoxDummy.pos = selection.center
			transCtrl = Link_Constraint()
			bBoxDummy.transform.controller = transCtrl
			transCtrl.addTarget me (AnimationRange.Start - 5)
			SetTrackViewLocks #(bBoxDummy) True 
			AddObjectsToMyLayer #(bBoxDummy)
			delete pointArr
			HideObjs()
			select me
			SceneRedraw #on
		)
	)
	
	fn DeleteBboxDummy =
	(
		format "***** bBoxDummy: % *****\n" bBoxDummy
		try(Delete bBoxDummy)catch()
		bBoxDummy = undefined
	)
	
	fn DisplaySingleBoundingBox state =
	(
		/* 
		WIP:
		Creates a single bounding box display for the whole asset
		 */
		format "***** Display Single Bounding Box Call *****\n"
		if state then
		(
			if bBoxDummy == undefined then DrawSingleBoundingBox()
		)
		else
		(
			DeleteBboxDummy()
		)
		Display_SingleBox = state
	)
	
	fn InitChangeHandlers =
	(
		/* 
		(GetMe())
			
		-- This change handler Refactors the asset when ever objects are added or removed from the hierarchy.
		when children me change handleAt:#redrawViews id:#Change_AssetChildren do
		(
			--format "***** Children Changing *****\n"
			me.RefactorAssetObjects()
		)
		 */
	)
	
	fn RemoveChangeHandlers =
	(
		DeleteAllChangeHandlers id:#Change_AssetChildren
	)
	
	fn GetImporterFromMeshObject obj =
	(
		deps = refs.dependents obj
		arr = for i in deps where classOf i == AssetNull collect i
		if arr.count != 0 then
		(
			arr[1]
		)
		else
		(
			undefined
		)
	)
	
	fn SizePointHelper val ui:True =
	(
		/* 
		Method to link a UI spinner with the Point_Helper display size
		 */
		this.Point_Helper.size = val
		Display_Size = val
		if not ui then this.ro_display.spn_size.value = val
	)
	
	fn DefaultDisplay =
	(
		/* 
		Method called on AttachToNode that sets the default display values for the AssetNull
		I haven't figured out how to set the WireColor yet
		 */
		this.point_helper.CenterMarker = False
		this.point_helper.AxisTripod = True
		this.point_helper.Cross = False
		this.point_helper.Box = True
		Display_Size = this.point_helper.size
		--this.WireColor = (color 255 0 255)
		--format "***** Display Set *****\n"
	)
	
	fn MergeXrefObjects =
	(
		objArr = CollectAssetObjs()
		for i = 1 to objArr.count do 
		(
			if ClassOf objArr[i] != XrefObject then continue
				
			ObjXRefMgr.MergeXRefItemsIntoScene objArr[i].baseObject
		)
	)
	
	fn initAssetCheckinLib =
	(
		-- bring in the exporter lib
		/******** _ilmLibrary is not available on the farm ********/
		if ::_ilmLibrary != undefined then
		(
			--format "***** _ilmLibrary Defined *****\n"
			if ::AssetCheckin_Lib == undefined then
			(
				local checkinLib = ((::_ilmLibrary.GetToolPath()) + @"Asset_AssetCheckin\_resource\AssetCheckin_lib.ms")
				if DoesFileExist checkinLib then
				(
					--format "***** Loading AssetExporter_Lib *****\n"
					FileIn checkinLib
				)
			)
			_assetCheckin = ::AssetCheckin_Lib showui:False
			True
		)
		else
		(
			False
		)
	)
	
	fn Export_As_Almebic =
	(
		initAssetCheckinLib()
		if _assetCheckin != undefined then
		(
			fSavePath = getSaveFileName caption:"Save Alembic File" types:".abc"
			if fSavePath == undefined then return messageBox "Invalid export path" title:"Export Error:"
			
			if getFileNameType fSavePath != ".abc" then fSavePath += ".abc"
			
			
			SceneRedraw #off
			SetCommandPanelTaskMode #create
			HoldMaxFile()
			exp_asset = (GetMe())
			MergeXrefObjects()
			_assetCheckin.checkinPath = (GetFileNamePath fSavePath)
			_assetCheckin.GetExportPathsDic exp_asset  fName:(GetFileNameFile fSavePath) pathKeys:#("alembic")
			_assetCheckin.ExportAlembic exp_asset _fileName:fSavePath _exportSelected:True
			FetchMaxFile quiet:True
			SceneRedraw #on
			
		)
		else
		(
			messageBox "Unable to load AssetExporter_lib" title:"Code library not found:"
			
			return False
		)
		
		True
	)
	
	fn RestoreTransform =
	(
		GetMe()
		if me != undefined then
		(
			me.transform = me._transform
		)
	)
	
	fn InstanceMe _transform:me.transform =
	(
		local assetObjArr = ((CollectAssetObjs()) + me)
		local actArr = #()
		local instArr = #()
		
		local sceneObjCount = objects.count
		
		inst = maxOps.CloneNodes assetObjArr expandHierarchy:True cloneType:#instance actualNodeList:actArr newNodes:instArr
		
		if inst then
		(
			newObjs = for i = sceneObjCount+1 to objects.count collect objects[i]
			newAssetNull = (for i in newObjs where ClassOf i == AssetNull collect i)[1]
			
			newAssetNull.transform = _transform
			
			InstanceMgr.MakeObjectsUnique newAssetNull #individual
			newAssetNull.GetMe refactor:True
			newAssetNull.CollectAssetObjs refactor:True
			select newAssetNull
			newAssetNull
		)
		else
		(
			format "***** Nothing was instanced... *****\n"
		)
	)
	
	fn StoreLayerStates =
	(
		layerStateDic = dotNetObject "System.Collections.Hashtable"
		for i = 0 to layermanager.count-1 do
		(
			layerStateDic.add (i as string) ((layermanager.GetLayer i).on as string)
		)
		layerStateDic
	)
	
	fn RestoreLayerStates = 
	(
		
	)
	
	fn ProxyButtonDisplay obj =
	(
		Proxy = obj
		
		if Proxy != undefined then
		(
			ro_options.dNbtn_proxy.text = Proxy.name
			try(ro_options.dNbtn_proxy.forecolor = outdateClr)catch()
		)
		else
		(
			ro_options.dNbtn_proxy.text = ro_options.proxyLabel
			try(ro_options.dNbtn_proxy.forecolor = clrDnetText)catch()
		)
	)
	
	fn GetProxyObject =
	(
		fn shapeFilt o = (superClassOf o == geometryClass)
		
		
		local obj = (PickObject message:"Pick the custom object" prompt:"Pick it now!" filter:shapeFilt forceListenerFocus:True )
		
		if obj != undefined then
		(
			format "%\n" obj.name
			Proxy = obj
			ProxyButtonDisplay()
		)
		else
		(
			format "undefined\n"
			Proxy = undefined
			ProxyButtonDisplay()
		)
	)
	
	fn __init__ =
	(
		
	)
		
	fn TestUI =
	(
		rollout ro_options "Options" width:200
		(
			local self
			group "Testing UI"
			(
				dotNetControl dNbtn_testing "button" height:30 offset:[0,10]
			)
			fn _init_ pself =
			(
				self = pself
				self.initDnetBtn dNbtn_testing "Testing UI" 10 colorOffsetInt:15 tooltip:"Testing this shit!"
			)
			on dNbtn_testing mouseClick args do
			(
				Self.ResetFromUserProps_mapped (self.CollectAssetObjs())
				try(destroydialog ro_options)catch()
			)
			on dNbtn_testing MouseEnter arg do
			(
				self.initToolTip dNbtn_testing dNbtn_testing.tag
			)
			on dNbtn_testing MouseLeave arg do
			(
				self.destroyToolTip()
			)
		)
		createDialog ro_options
		ro_options._init_ this
	)
		
	rollout ro_display "Display"
	(
		spinner spn_size "Display Size: " range:[0.1,9999,this.Point_Helper.size] type:#float
		group "Display Options:"
		(
			--checkbox chk_singleBox ":Single Bounding Box"
			checkbox chk_disProxy ":Display Proxy" enabled:(HasProxy())
			checkbox chk_disBox ":Display as Box" 
			--checkbox chk_disHide ":Hide Objects"
		)
		
		on spn_size changed val do
		(
			Display_Size = val
		)
		on chk_singleBox changed state do
		(
			--Display_SingleBox = state
		)
		on chk_disBox changed state do
		(
			Display_Bbox = state
		)
		/* 
		on chk_disHide changed state do
		(
			Display_HideObjs = state
		)
		 */
	)
		
	rollout ro_info "Asset Info" 
	(
		local lblHeight = 12
		local txtHeight = 22
		
		dotNetControl dNlbl_version "label" height:lblHeight across:2 offset:[0,5]
		dotNetControl dNtxt_version"Textbox" height:txtHeight width:50 --offset:[-5,0]
		
		dotNetControl dNlbl_fullname "label" height:lblHeight
		dotNetControl dNtxt_fullname"Textbox" height:txtHeight --width:50
		
		dotNetControl dNlbl_shortname "label" height:lblHeight
		dotNetControl dNtxt_shortname "Textbox" height:txtHeight --width:50
		
		dotNetControl dNlbl_type "label" height:lblHeight
		dotNetControl dNtxt_type"Textbox" height:txtHeight --width:50
		
		--dotNetControl dNbtn_execute "button" height:25 offset:[0,10]
	
		on dNbtn_execute mouseClick args do
		(
			format "***** Pressed *****\n"
			OptionsUI()
		)
		on dNbtn_execute MouseEnter arg do
		(
			initToolTip dNbtn_execute dNbtn_execute.tag
		)
		on dNbtn_execute MouseLeave arg do
		(
			destroyToolTip()
		)
		
		on ro_info open do
		(
			--print "RO Open"
			SetDotNetWidget dNlbl_version "Version:" 8
			SetDotNetWidget dNlbl_fullname "Fullname:" 8
			SetDotNetWidget dNlbl_shortname "Shortname:" 8
			SetDotNetWidget dNlbl_type "Asset Type:" 8
			
			InitTxtBx dNtxt_version Asset_Version 10 fontStyle:#bold
			InitTxtBx dNtxt_fullname Asset_FullName 8 fontStyle:#bold
			InitTxtBx dNtxt_shortname Asset_ShortName 8 fontStyle:#bold
			InitTxtBx dNtxt_type Asset_Type 8 fontStyle:#bold
			
			--initDnetBtn dNbtn_execute "Test Button" 10 colorOffsetInt:15 tooltip:"Execute the selected option."
			
			ChangeTxtBoxColor dNtxt_version updateClr
		)
	)
		
	rollout ro_options "Options"
	(
		local proxyLabel = "Pick Proxy Object"
		
		group "Custom VRay Poxy Display:"
		(
			dotNetControl dNbtn_proxy "button" height:20
		)
		
		
		dotNetControl dNbtn_restoreObjs "button" height:20
		dotNetControl dNbtn_trans "button" height:20
		
		group "Export:"
		(
			dotNetControl dNbtn_exp_alembic "button" height:20 --offset:[0,10]
		)
		
		dotNetControl dNbtn_instance "button" height:20
		
		on dNbtn_proxy mouseClick args do
		(
			ProxyButtonDisplay (PickObject message:"Pick the custom object" prompt:"Pick it now!" filter:shapeFilt forceListenerFocus:True )
		)
		
		on dNbtn_restoreObjs mouseClick args do
		(
			--format "***** Pressed *****\n"
			ResetFromUserProps_mapped (CollectAssetObjs())
		)
		
		on dNbtn_restoreObjs MouseEnter arg do
		(
			initToolTip dNbtn_restoreObjs dNbtn_restoreObjs.tag
		)
		
		on dNbtn_restoreObjs MouseLeave arg do
		(
			destroyToolTip()
		)
		
		on dNbtn_trans mouseClick args do
		(
			--format "***** Pressed *****\n"
			RestoreTransform()
		)
		
		on dNbtn_trans MouseEnter arg do
		(
			initToolTip dNbtn_trans dNbtn_trans.tag
		)
		
		on dNbtn_trans MouseLeave arg do
		(
			destroyToolTip()
		)
		
		on dNbtn_exp_alembic mouseClick args do
		(
			Export_As_Almebic()
		)
		
		on dNbtn_exp_alembic MouseEnter arg do
		(
			initToolTip dNbtn_exp_alembic dNbtn_exp_alembic.tag
		)
		
		on dNbtn_exp_alembic MouseLeave arg do
		(
			destroyToolTip()
		)
		
		on dNbtn_instance mouseClick args do
		(
			InstanceMe()
		)
		
		on dNbtn_instance MouseEnter arg do
		(
			initToolTip dNbtn_instance dNbtn_instance.tag
		)
		
		on dNbtn_instance MouseLeave arg do
		(
			destroyToolTip()
		)
		
		on ro_options open do
		(
			initDnetBtn dNbtn_proxy proxyLabel 8 colorOffsetInt:15 tooltip:"Pick a custom object to substitute for the VRayProxy display"
			
			initDnetBtn dNbtn_restoreObjs "Restore Objects" 8 colorOffsetInt:15 tooltip:"Restores the transform of each object to it's transform relative to the AssetNull"
			
			initDnetBtn dNbtn_trans "Restore Transform" 8 colorOffsetInt:15 tooltip:"Restores the transform from when the asset was checked in"
			
			initDnetBtn dNbtn_exp_alembic "Export Alembic" 8 colorOffsetInt:15 tooltip:"Export an Alembic cache of the asset"
			
			initDnetBtn dNbtn_instance "Instance Asset" 8 colorOffsetInt:15 _forecolor:clrDef tooltip:"Use this to make a safe instance of the asset"
		
			this.ProxyButtonDisplay this.Proxy
		)
	)
	
	on Create do
	(
		--format "***** Create *****\n"
		DefaultDisplay()
		__init__()
	)
	
	on PostCreate do
	(
		--format "***** Post Create *****\n" 
		
		--iName = (GetMe()).name
	)
	
	on Load do
	(
		--format "***** Load : % *****\n" (GetMe()).name
		if not _exporting then InitChangeHandlers()
		__init__()
	)
	
	on PostLoad do
	(
		--format "***** Post Load *****\n"
	)
	
	on Update do
	(
		--format "***** Asset Null Updated *****\n"
	)
	
	on attachedToNode nodeArg do
	(
		--format "***** Attach To Node: % *****\n" nodeArg
		if not _exporting then InitChangeHandlers()
		
		if _cloning then
		(
			format "***** Cloning % *****\n" nodeArg
			
			GetMe refactor:True
			
			-- make the AssetNull shape unique
			-- This will still allow the AssetObjs to be instanced
			--InstanceMgr.MakeObjectsUnique me #individual 
			
			NameByInstanceId()
			
			_cloning = False
		)
	)
	
	on detachedFromNode nodeArg do
	(
		--format "***** Detach From Node: % *****\n" nodeArg
	)
	
	on Clone orig do
	(
		--format "cloned: % : % : % : %\n" this orig (this == orig) (delegate == orig.delegate)
		
		this._cloning = True
		--format "***** Cloning: % *****\n" this._cloning
		
		--SetPropVals_mapped (CollectAssetObjs refactor:True)
	)
	
	on deleted do
	(
		--format "***** Deleted Asset Null: % *****\n" this
	)
	
)