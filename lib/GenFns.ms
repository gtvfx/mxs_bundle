/* 
Misc functions that are commonly used by many tools
*/



struct GenFns
(
	
--( File Operations
	
	fn TransferFiles _fromDir: _toDir: fileArr:#all deleteAfter:False =
	(
		if _toDir == unsupplied then return (messageBox "TransferFiles requires you to supply a valid directory to transfer files: use the _toDir arg" title:"Missing args:")
		if not (DoesFileExist _toDir) then return (messageBox "The _toDir arg supplied to TransferFiles does not exist" title:"Invalid Directory:")
		if fileArr == #all and _fromDir == unsupplied then return (messageBox "TransferFiles requires you to supply a valid directory to collect files to transfer: use the _fromDir arg" title:"Missing args:")
		
		
		if fileArr == #all then
		(
			fileArr = GetFiles (_fromDir+"/*")
		)
		else
		(
			local arr = #()
			for i in fileArr do
			(
				if not DoesFileExist i then
				(
					format "***** File does not exist: % *****\n" i
					append arr i
				)
			)
			
			for i in arr do
			(
				DeleteItem fileArr (FindItem fileArr i)
			)
		)
		
		if fileArr.count != 0 then
		(
			for i in fileArr do
			(
				CopyFile i (_toDir + "/" + (FileNameFromPath i))
			)
		)
		
		if deleteAfter then
		(
			for i in fileArr do
			(
				deleteFile i
			)
		)
		
		
		format "***** % files transfered *****\n" fileArr.count
	),
	
	fn CopyMaxFilePathToClipboard =
	(
		SetClipBoardText (maxFilePath + maxFileName)
	),
	
	fn OpenMaxFileLocation =
	(
		ShellLaunch "explorer" maxfilepath 
	),
	
	fn OpenRenderLocation =
	(
		if DoesFileExist (GetFilenamePath rendOutputFilename) then ShellLaunch "explorer" (GetFilenamePath rendOutputFilename) else messageBox "Unable to access render path directory." title:"Error:"
	),
	
	fn OpenTempDir =
	(
		ShellLaunch "explorer" (GetDir #temp)
	),

	fn GetLatestFile filePath ext pattern:"" = 
	(			
		local fileList = (getfiles (filePath + "\\*." + ext))
		local assumedLatestFile = ""
		local latestWriteTime = 0L
	
		for newFile in fileList do 
		(
			if matchPattern newFile pattern:("*" + pattern + "*" ) then 
			(
				local FileInfo = dotNetObject "System.IO.FileInfo" newFile
				if FileInfo != undefined then 
				(
					local fileTime = FileInfo.LastWriteTime.Ticks
					if fileTime > latestWriteTime then 
					(
						assumedLatestFile = newFile
						latestWriteTime = FileInfo.LastWriteTime.Ticks
					)
				)
			)
		)
		assumedLatestFile
	),
	
--) End File Operations
	
--( System Helpers
	
	fn SetHeapSize mem =
	( -- 200000000
		if HeapSize < mem then HeapSize = (mem as integer)
	),
    
    fn IncreaseHeapSize _increment =
    (
        HeapSize += _increment
    ),
	
	fn getScreenResolution =
	(
		/* 
		Get the screen resolution to determine the width of the toolbar
		 */
		scr = (dotNetClass "System.Windows.Forms.Screen").PrimaryScreen.Bounds
		[scr.Width, scr.Height]
	),
	
--)
	
--( Site data and validation
	
	fn GetLocation =
	(
		/* 
		This variable holds the local site designation. Used to perform site specific tasks.
		 */
		out = SystemTools.GetEnvVariable "LFL_SITE"
		out
	),
	
	fn IsValidRsa =
	(
		/* 
		This method validates the existense of the RSA token file used to create the connection from
		a users Windows PC to thier Linux workstation.
		 */
		user = sysInfo.username
		
		rsaFile = "//" + (this.GetLocation()) + "/home/" + user + "/.ssh/id_rsa"
		
		(DoesFileExist rsaFile)
	),
	
	fn CheckShowInfoGlobals globalsArr:#(ilmShow,ilmSeq,ilmShot,ilmTaskDir) =
	(
		/*****************************************************************************(
		[ARGUMENTS]
		globalsArr:
		An array of global variables being set by other tools
		[DESCRIPTION]
		A quck check to see if Show pertinent data is set
		[RETURN]
		Returns True if none of the Globals return undefined
		)*****************************************************************************/
		
		format "ilmShow: % | ilmSeq: % | ilmShot: % | ilmTaskDir: % \n" ilmShow ilmSeq ilmShot ilmTaskDir
		
		if FindItem globalsArr undefined != 0 then False else True
	),
	
--) END: Site data and validation

--( Hierarchies
	
	mapped fn SetParent_mapped objArr obj _replace:False =
	(
		/* 
		Set the parent of each object in objArr to obj
		
		using the _replace argument will flatten the hierarchy of objArr and directly parent
		each object to obj
		 */
		if _replace then
		(
			objArr.parent = obj
		)
		else
		(
			if objArr.parent == undefined then objArr.parent = obj
		)
	),
	
	fn Set_Parent objArr obj _replace:False =
	(
		/* 
		Set the parent of each object in objArr to obj
		
		using the _replace argument will flatten the hierarchy of objArr and directly parent
		each object to obj
		
		This method wraps the mapped function so that we can also perform an unmapped operation
		to see if any of the objects in the provided array have a parent outside of the selection.
		 */
		
		if not _replace then
		(
			for i in objArr where i.parent != undefined and (finditem objArr i.parent) == 0 do i.parent = obj
		)
		
		this.SetParent_mapped objArr obj _replace:_replace 
	),
	
	mapped fn RemoveParent_mapped objArr =
	(
		/* 
		Sets the parent of each object in the supplied array to 'undefined'
		 */
		
		objArr.parent = undefined
	),
	
	fn GetTopLevelParent obj =
	(
		/* 
		Recursses up through the objects hierarchy and returns the top-most object
		 */
		
		if not (IsValidNode obj) then
		(
			throw ("GetTopLevelParent() expected a valid object node.\n-- Got: " + (obj as string))
		)
		
		if obj.parent != undefined then
		(
			obj = GetTopLevelParent obj.parent
		)
		obj
	),
	
	fn GetParentsRecursive obj arr:#() skipNamePattern: skipClass: skipSuperClass: =
	(
		/* 
		recurses upstream through a node's hierarchy collecting all nodes above obj
		 */
        
        -- A boolean that will exit the recurse if set to true
		local skipCase = False
        
		if obj.parent != undefined then
		(
			if finditem arr obj.parent == 0 then
			(
                if ( skipNamePattern != unsupplied ) and ( classOf skipNamePattern == String ) then
				(
					exitCase = ( matchPattern obj.parent.name pattern:skipNamePattern )
				)
				
				if ( skipClass != unsupplied ) and ( skipClass != undefined ) then
				(
					exitCase = ((classOf obj.parent) == skipClass)
				)
				
				if ( skipSuperClass != unsupplied ) and ( skipSuperClass != undefined ) then
				(
					exitCase = ( (SuperClassOf obj.parent) == skipSuperClass )
				)
                
				if not skipCase then
				(
					append arr obj.parent
				)
			)
			this.GetParentsRecursive obj.parent arr:arr skipNamePattern:skipNamePattern skipClass:skipClass skipSuperClass:skipSuperClass
		)
		arr
	),
	
	fn GetChildrenRecursive obj arr:#() skipNamePattern: skipClass: skipSuperClass: =
	(
		/* 
		recurses downstream through a node's hierarchy collecting all nodes below obj
                */
		
		-- A boolean that will exit the recurse if set to true
		local skipCase = False
		
		if obj.children.count != 0 then
		(
			for c in obj.children do
			(
				if ( skipNamePattern != unsupplied ) and ( classOf skipNamePattern == String ) then
				(                    
					skipCase = ( matchPattern c.name pattern:skipNamePattern )
				)
				
				if ( skipClass != unsupplied ) and ( skipClass != undefined ) then
				(
					skipCase = ((classOf c) == skipClass)
				)
				
				if ( skipSuperClass != unsupplied ) and ( skipSuperClass != undefined ) then
				(
					skipCase = ((SuperClassOf c) == skipSuperClass)
				)
                
				if not skipCase then
				(
					append arr c
					this.GetChildrenRecursive c arr:arr skipNamePattern:skipNamePattern skipClass:skipClass skipSuperClass:skipSuperClass
				)
			)
		)
        
		arr
	),
	
	fn GetNodeHierarchyTree obj =
	(
		/* 
		Collects all parents and children and return a combined arr including the obj
		 */
		parentArr = this.GetParentsRecursive obj
		childArr = this.GetChildrenRecursive obj
		
		out = (parentArr + childArr + obj)
	),
	
	fn GetNodeHierarchyAsPath obj =
	(
		/* 
		- Concotenates a path to the object through it's hierarch
		- Used for the Alembic export and Material collection
		 */
        
		if IsValidNode obj then
		(
			local str = stringstream ""
			local worldRoot = "/root/world/geo/"
            
			format "%" worldRoot to:str
            
			local parentArr = #()
			this.GetParentsRecursive obj arr:parentArr
            
			for i = parentArr.count to 1 by -1 do format "%/" parentArr[i].name to:str
                
			format "%" obj.name to:str
            
			str as string
		)
		else
		(
			undefined
		)
	),


	fn ConvertStrArrToNodeArr theStringArr parentObjName = 
	(
		local tmpArrStr = execute(theStringArr)
		local tmpArrNode = #()
        
		for objName in tmpArrStr do 
		(
			try
			(
				local objSel = getnodebyname objName all:true
				for obj in objSel where (this.GetTopLevelParent obj).name == parentObjName do append tmpArrnode obj
			)
			catch()
		)
        
		tmpArrNode
	),
	
--) END: Hierarchies
	
--( Layers
	
	mapped fn AddObjectsToLayer_mapped objArr layer =
	(
		layer.addNode objArr
	),
    
    fn GetLayerFromName layerName makeNew:False =
    (
        layer = undefined
        if LayerManager.getLayerFromName layerName == undefined and makeNew then
        (
            layer = layermanager.newLayerFromName layerName
        )
        else
        (
            layer = LayerManager.getLayerFromName layerName
        ) 
        layer
    ),
    
    fn StoreObjectLayerRelationship objArr =
    (
        /* 
                Returns a dictionary formated as:
                Key = LayerName
                Value = Array of object names
                */
        
        local dic = dotNetObject "System.Collections.Hashtable"
        
        local layerNameArr = for i in objArr collect i.layer.name
        layerNameArr = MakeUniqueArray layerNameArr
        
        for layerName in layerNameArr do
        (
            local layer = LayerManager.getLayerFromName layerName
            local layerNodes = #()
            layer.nodes &layerNodes
            
            local layerObjNames = for obj in layerNodes collect obj.name
            layerObjNames = MakeUniqueArray layerObjNames
            
            dic.add layerName layerObjNames
        )
        
        dic
    ),
    
    fn RestoreObjectLayerRelationship objArr dic =
    (
        /* 
                Takes the dictionary from StoreObjectLayerRelationship()
                Creates layers if necessary
                Collects objects by name and sets their layer based on the dictionary key/value pairing
                */
        
        local layerNameArr = this.GetHashtableKeys dic
        
        for layerName in layerNameArr do
        (
            local layer = this.GetLayerFromName layerName makeNew:True
            
            for objName in dic.item[layerName] do
            (
                local nodeArr = (GetNodeByName objName all:True)
                
                for n in nodeArr where (FindItem objArr n) != 0 do
                (
                    this.AddObjectsToLayer_mapped nodeArr layer
                )
            )
        )
    ),
	
	
--) END: Layers
	
--( Materials
	
	fn ApplyGreyMat objArr =
	(
		greyMat = (Standard name:"default" diffuse:(color 128 128 128))
		for i in objArr do i.material = greyMat
		True
	),
	
	fn HasMultipleMats objArr =
	(
		/* 
		Collects the material from the first object in the supplied array and then
		tests against the materials of every other object in the array.
		
		returns True if there is more than the one material used
		returns False if all of the objects share the same material
		 */
		testMat = objArr[1].material
		for i in objArr do
		(
			if i.material != testMat then return True
		)
		False
	),
	
	fn HasMultiMatte objArr =
	(
		/* 
		Test each object in the supplied array to see if its' material is a MultiMaterial
		 */
		arr = for i in objArr where classof i.material == MultiMaterial collect i
		if arr.count == 0 then False else True
	),
	
	fn CollectObjectsByMaterial objArr mat =
	(
		/* 
		Filters through the objects in objArr to find only the objects with mat applied
		 */
		arr = for i in objArr where i.material == mat collect i
		arr
	),
	
	fn ExportMatLib matArr exportPath =
	(
		/* 
		Creates a material library from matarr and exports it to exportPath
		 */
		if matArr.count != 0 then
		(
			matLib = materialLibrary()
			for i in matArr where i != undefined do append matLib i
			if (doesFileExist (GetFileNamePath exportPath)) == true then
			(
				saveTempMaterialLibrary matLib exportPath
			)
		)
	),
	
	fn CollectMaterials objArr =
	(
		/* 
		Collect all materials applied to the objects in the objArr
		 */
		arr = #()
		for i in objArr where i.material != undefined do
		(
			AppendIfUnique arr i.material
		)
		arr
	),
    
    fn GetFinalMapLoader mapLoader =
    (
        local numSubTexmaps = (GetNumSubTexmaps mapLoader)
            
        if numSubTexmaps != 0 then
        (
            tMap = (GetSubTexmap mapLoader 1)
            if ( GetNumSubTexmaps tMap ) != 0 then
            (
                GetFinalMapLoader tMap
            )
            
            return tMap
        )
        
        mapLoader
    ),
	
--) END: Materials
    
--( Map Methods
  
    fn GetFileFromMapLoader mapLoader = 
    (
        out = undefined
        
        case ( ClassOf mapLoader ) of
        (
            ( VRayHdri ):
            (
                out = mapLoader.HdriMapName
            )
            ( BitmapTexture ):
            (
                out = mapLoader.Filename
            )
        )
        
        out
    ),    

--)
	
--( Mesh operations
    
    fn DeleteAll =
    (
        SetCommandPanelTaskMode #create
        ::_ilmLibrary.BlockUi True
        delete $*
        ::_ilmLibrary.BlockUi False
    ),
	
	fn GetLocalizedBasePoint objArr =
	(
		/* 
		Retuns a Point3 value representing the worlspace coordinate at the X and Y center of the objects and the minimum Z coordinate.
		 */
		local out
		
		if classof objArr != ObjectSet then
		(
			ClearSelection()
			Select objArr
		)
		
		local minPoint = selection.min
		local maxPoint = selection.max
		
		out = [(minPoint.x + ((maxPoint.x - minPoint.x)/2)),(minPoint.y + ((maxPoint.y - minPoint.y)/2)),minPoint.z]
	),
	
	mapped fn AutoProOptimize objArr perc:25 optArr:#() =
	(
		/* 
		Creates a ProOptimize Mod on every object in objArr and sets the vertexPercent to perc
		
		optArr needs to be fed an empty array assigned to a variable
		This function varifies each object in objArr is valid for the ProOptimzer mod and appends all valid objects to optArr
		*/
		
		SetCommandPanelTaskMode #create
		
		if ValidModifier objArr (ProOptimizer()) and SuperClassOf objArr == GeometryClass then
		(
			if objArr.modifiers[#Auto_ProOptimizer] == undefined then
			(
				AddModifier objArr (ProOptimizer name:#Auto_ProOptimizer vertexPercent:perc)
			)
			append optArr objArr
		)
		--else format "***** % is not a valid object for ProOptimizer *****\n" objArr.name
	),
	
	mapped fn CalculateProOptModifiers classArr =
	(
		/* 
		Setting the calculate property has to be done after the object has been re-evaluated. 
		That's why this is in a function by itself
		*/
		classArr.calculate = True
	),
	
	fn AlignPivotToObject sourceObj targetObj = 
	(
		/* 
		Aligning pivots in Max is tricking, esecially if trying to maintain a clean transform and object offset
		
		This method stores the world position of each vertex of the sourceObj
		It then sets the sourceObj transform to the targetObj transfrom (This aligns the pivot)
		Then it goes through and moves each vertex back to their stored transform
		 */
		if CanConvertTo sourceObj Editable_Poly then 
		(
			if classof sourceObj != Editable_Poly then convertToPoly sourceObj
			
			vertsPosArr = For i = 1 to (polyOp.getNumverts sourceObj) collect (polyOP.getvert sourceObj i)
			
			sourceObj.transform = targetObj.transform
			
			for i = 1 to vertsPosArr.count do polyOP.setvert sourceObj i vertsPosArr[i]
				
			ConvertToMesh sourceObj
		)
	),
	
	fn AttachObjs objArr garbageCollect:false =
	(
		/* 
		- Attaches all geo objects in objArr into a single mesh
		- Creates a single MultiMat for the resultant obj
		
		- Returns the collapsed object
		 */
		if objArr.count < 2 then
		(
			messagebox "Must have at least 2 objects selected!"
		)
		else
		(
			with undo off
			(
				with redraw off
				(
					--tStart = timeStamp()
					nonGeoArr = for i in objArr where superClassOf i != GeometryClass or classof i == TargetObject collect i
					for i in nonGeoArr do
					(
						--format "***** % is not a mesh object. It will be ignored. *****\n" i.name
						deleteItem objArr (findItem objArr i)
					)							
					while objArr.count > 1 do
					(	
						for i = objArr.count to 2 by -2 do 
						(
							--format "***** objname: % *****\n" objArr[i].name
							InstanceMgr.MakeObjectsUnique #(objArr[i], objArr[i-1]) #individual
							case (classOf objArr[i]) of
							(
								(Editable_Poly):
								(
									polyOp.attach objArr[i] objArr[i-1]
								)
								(PolymeshObject):
								(
									polyOp.attach objArr[i] objArr[i-1]
								)
								(Editable_Mesh):
								(
									attach objArr[i] objArr[i-1]
								)
								default:
								(
									if (classOf objArr[i]) != Editable_Mesh then convertToMesh objArr[i]
									attach objArr[i] objArr[i-1]
								)
							)
							deleteItem objArr (i-1)
							if garbageCollect then gc()
						)
					)
					cui.commandPanelOpen = true
					--format "Attach time: %s\n" ((timeStamp()-tStart)/1000.0) as string
					if (classOf objArr[1]) != Editable_Mesh then convertToMesh objArr[1]
					objArr[1]
				)
			)
		)
	),
	
	fn CondenseObjects objArr tolerance:1000 =
	(
		/* 
		- tolerance is the number of objects to collapse together
		
		 */
		format "***** Condensing Objects *****\n"
		
		local newObjArr = #()
		
		while objArr.count != 0 do
		(
			local subArr = #()
			
			for i = 1 to (tolerance as integer) do
			(
				if objArr[i] == undefined then exit
				append subArr objArr[i]
				deleteItem objArr i
			)
			
			if subArr.count > 1 then
			(
				local newObj = this.AttachObjs subArr
				append newObjArr newObj
			)
			else
			(
				newObjArr += subArr
			)
		)
		
		newObjArr
	),
	
	mapped fn CollapseModifierStack objArr =
	(
		/* 
		Collapses the whole modifier stack
		*/
		
		with undo off
		(
			maxOps.CollapseNode objArr True
		)
	),
	
	
--) END: Mesh operations
	
--( Export Helper Methods
	
	fn SaveCheck =
	(
		/* 
		Presents a Yes/No/Cancel box asking if the user would like to save the file.
		
		If #yes then we run the SaveIncrement tool from the Library.
		Options #yes and #no return True
		#cancel returns false allowing us to escape the operation
		 */
		test = YesNoCancelBox "!!!-- Any work since your last save will be lost --!!!\n\nWould you like to save the file before continuing?" title:"Save Check:"
		case test of
		(
			#yes:_ilmLibrary.RunTool "SaveIncrement"
			#cancel: return False
		)
		True
	),
	
	mapped fn SetRenderByLayer objArr state:True =
	(
		/* 
		Meant to be run on each assetnull's AssetObjects
		This sets all objects to the RenderByLayer state that the tool RenderLayers requires
		 */
		objarr.renderByLayer = state
	),
	
	fn RemoveRenderElements =
	(
		/* 
		- Removes all render elements
		- The material collection export sees render elements as texture paths so we remove these to avoid that confusion
		 */
		(maxOps.GetCurRenderElementMgr()).removeallrenderelements()
		True
	),
	
	mapped fn ConvertToDummy_mapped objArr =
	(
		/* 
		- Converts all helper objects to Dummy helpers
		- Simplifying the objects helps the Alembic export
		 */
		if SuperClassOf objArr == Helper and ClassOf objArr != Dummy then
		(
			local repDummy = (Dummy name:objArr.name)
			
			repDummy.scale.controller = (ScaleXYZ())
			if ClassOf objArr.scale.controller != ScaleXYZ then objArr.scale.controller = (ScaleXYZ())
				
			try
			(
				replaceInstances objArr repDummy
			)
			catch
			(
				objArr.baseObject = repDummy
			)
			
			try(delete repDummy)catch()
		)
    ),
	
	fn CleanSaveNodes objArr fpath =
	(
		/* 
		The SaveNodes method in Max keeps a lot of unrelated garbage data in the scene. (Layers, metadata references, etc...)
		
		This method does a SaveNodes and then does a HoldMaxFile while it does a reset and merges the new objects into a fresh
		scene (This gets rid of all the garbage data). It then saves this clean file to the suppled fpath and then Fetches the file back.
		 */
		local tempDir = (getDir #temp)
		local tempFile
		if (DoesFileExist tempDir) then
		(
			format "***** Cleaning Exported Scene *****\n"
			with redraw off
			(
				objArr = for i in objArr where not isDeleted i collect i
				
				tempFile = (tempDir + @"\cleansavenodes.max")
				SaveNodes objArr tempFile quiet:True
				HoldMaxFile()
				ResetMaxFile #noPrompt
				Try(Delete (objects as array))Catch()
				MergeMaxFile tempFile #noRedraw quiet:True
				SaveMaxFile fpath useNewFile:False quiet:True
				DeleteFile tempFile
				FetchMaxFile quiet:True
			)
		)
		else
		(
			Throw "Unable to access temp directory"
		)
	),
    
    fn GetFaceCount objArr =
    (
        local numFaces = 0
        
		for obj in objArr do
		(
			if ( ClassOf obj != TargetObject ) and ( IsProperty obj #mesh ) then
			(
				numFaces += ( GetNumFaces obj.mesh )
			)
		)
        
		numFaces 
    ),
	
	fn ExportVrmesh objArr pName exportDir:unsupplied parent:undefined customMesh:undefined =
	(
		/* 
		- Attaches all objects in objArr to a single mesh and exports a vrmesh of that object
		- If separate "topnulls" exist within the objArr hierarchy then this function is run on the children of each topnull separately
		- Otherwise this is run on the whole objArr
		 */
		
		if exportDir == unsupplied or not (DoesFileExist exportDir) then
		(
			throw "ExportVrmesh() expects an existing directory for 'exportDir'"
		)
		
        -- The VrayMeshExport method assumes instanced objects share the same material so here we just kill all instancing to avoid wrong material assignments
        InstanceMgr.MakeObjectsUnique objArr #individual
        
		-- The VrayMeshExport method is limited in the number of objects it's able to export, so this CondenseObjects method is used to
		-- reduce the object count prior to export.        
		if objArr.count > 7000 then objArr = this.CondenseObjects objArr tolerance:1000
		
		local numFaces = this.GetFaceCount objArr
        
		-- This is a sort of logic for optimizing the face count display of the proxy object
		if numFaces < 10000 then numFaces = numFaces/3
		while numFaces > 50000 do numFaces = numFaces/2
		if numFaces > 30000 then numFaces = 30000
		
		local meshFilePath = (exportDir + pName + ".vrmesh")
		local matLibPath = (substituteString meshFilePath ".vrmesh" ".mat")

		format "***** VRProxy ObjArr: % *****\n" objArr
		if customMesh == undefined then customMesh = unsupplied
		local vProxy = (VrayMeshExport meshFile:meshFilePath autoCreateProxies:True exportMultiple:False animation:off maxPreviewFaces:numFaces previewMesh:customMesh nodes:objArr createMultiMtl:True condenseMultiMtl:True)[1]
		
		vProxy.parent = parent
		vProxy.name = pName
		vProxy.material.name = pName
		vProxy.force_first_map_channel = False
		
		-- export a matlib of the material applied to the VRayProxy object
		this.ExportMatLib #(vProxy.material) matLibPath
		
		vProxy
	),
	
	fn GetAlembicExportString _filename:unsupplied _exportSelected:False _in:1 
		_out:1 _step:1 _subStep:1 _particleSystemToMeshConversion:True _automaticinstancing:True 
		_facesets:"partitioningFacesetsOnly" _purePointCache:False _normals:True _uvs:True 
		_materialIDs:True _flattenHierarchy:False _transformCache:False _validateMeshTopology:False 
		_storageFormat:"ogawa" _objects:unsupplied =
	(
		/* 
		- This function formats a string of values used by the Alembic export function
		- The arugments expose all the values that can be supplied to the string
		 */
		local str = StringStream ""
		local xStr = ""
		-- filename
		if _filename == unsupplied then
		(
			messageBox "GetAlembicExportString expects the _filename argument to be supplied" title:"Args Missing:"
			return False
		)
		--
		format "filename=%;exportSelected=%;in=%;out=%;step=%;substep=%;particleSystemToMeshConversion=%;automaticinstancing=%;" _filename _exportSelected _in _out _step _subStep _particleSystemToMeshConversion _automaticinstancing to:str
		xStr += (str as string)
		-- facesets
		if _facesets != unsupplied then
		(
			str = StringStream ""
			format "facesets=%;" _facesets to:str
			xStr += (str as string)
		)
		--
		str = StringStream ""
		format "purePointCache=%;normals=%;uvs=%;materialIDs=%;flattenHierarchy=%;transformCache=%;validateMeshTopology=%;storageFormat=%" _purePointCache _normals _uvs _materialIDs _flattenHierarchy _transformCache _validateMeshTopology _storageFormat to:str
		xStr += (str as string)
		-- objects
		if _objects != unsupplied then
		(
			str = StringStream ""
			format ";objects=%" _objects to:str
			xStr += (str as string)
		)
		xStr
	),
	
--) END: Export Helper Methods
	
--( External File Methods
	
	fn DumpStringToFile str pPath =
	(
		/* 
		A simplified method to format a string into a text file
		 */
		if (doesfileExist pPath) then deletefile pPath
		local strm = openFile pPath mode:"w"
		format (str as string) to:strm
		close strm
	),
	
--) END: External File Methods

	
	private fn _init =
	(
		this.SetHeapSize 400000000
		
		format "
---------------
CLASS USAGE: Gen Functions

instantiated global = _GenFns
---------------\n"
	),
	
	__init__ = _init()
)

_GenFns = GenFns()