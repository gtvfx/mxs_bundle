_ilmLibrary.Load "GenFns"
_ilmLibrary.Load "GenPyFns"
_ilmLibrary.Load "ilmEventTimer"
_ilmLibrary.Load "ilmUnity"
_ilmLibrary.Load "ilmMaterialLookDev"
_ilmLibrary.load "ilmTextureXML"
_ilmLibrary.load "ilmAtlas"


struct Asset_Fns
(
	nullValue = "------",
	
	defaultTrack = "dmsAuto",
	defaultApplication = "max",
	defaultTag = "genTag",
	defaultFiletype = "3dsmax",
	
	trackArr = #("dms","dmsAuto","primary"),
	applicationArr = #("max", "alembic"),
	tagArr = #("genTag", "hiTag"),
	fileKeys = #("3dsmax","proxy25","max_proxy25","vrproxy","work", "Alembic"),
	
	clr_asset = (dotnetClass "System.Drawing.Color").SkyBlue,
	clr_set = (dotnetClass "System.Drawing.Color").sandyBrown,
	clr_options = (dotnetClass "System.Drawing.Color").lightGreen,
	
	tempDir = ((GetDir #temp) + "/gencheckin/"),
	
	
	fn CollectAssetNulls =
	(
		local out = ( GetClassInstances AssetNull )
	),
	
	fn GetShapeFromClassInstance classInstance =
	(
		local deps = refs.dependentNodes classInstance
		if deps.count > 1 then
		(
			format "***** There are % dependent nodes for % *****\n" deps.count classInstance
		)
		deps[1]
	),
	
	fn CollectAtomicAssets =
	(
		local out = for i in ( this.CollectAssetNulls() ) where not ( this.AssetIsSet i ) collect ( this.GetShapeFromClassInstance i )
	),
	
	fn CollectSets =
	(
		local out = for i in ( GetClassInstances AssetNull ) where ( this.AssetIsSet i ) collect ( this.GetShapeFromClassInstance i )
	),
	
	fn CollectAssetsByLongname longname =
	(
		local out = for i in ( this.CollectAssetNulls() ) where i.Asset_Fullname == longname collect ( this.GetShapeFromClassInstance i )
	),
	
	fn CollectUniqueAssets assets =
	(
		local out = #()
		local assetNames = #()
        
		for i in assets do
		(
			if ( FindItem assetNames i.Asset_Fullname ) == 0 then
			(
				append out i
				append assetNames i.Asset_Fullname
			)
			
		)
        
		out
	),
	
	fn GetAssetShape asset =
	(
		local out = asset
		if not ( isProperty asset #baseobject ) then out = ( this.GetShapeFromClassInstance asset )
		out
	),
	
	fn GetAssetNullByAnimHandle animHandleArr =
	(
		local assetArr = ( this.CollectAssetNulls() )
        local out = #()
        
        if ( ClassOf animHandleArr != Array ) then animHandleArr = #(animHandleArr)
		
        for asset in assetArr do
        (
            if ( Finditem animHandleArr ( GetHandleByAnim ( refs.dependentNodes asset )[1] ) ) != 0 then
            (
                append out ( refs.dependentNodes asset )[1]
            )
        )
        
		out
	),
	
	fn ValidateAssetNullNames assetArr =
	(
		local validNames = ::EventTimer caption:"Validating asset names"
        
		assetArr = for i in assetArr collect ( this.GetAssetShape i )
		
		for i in assetArr do i.CleanDmsNullNames()
        
		validNames.End()
	),
	
	fn AssetNullCheck =
	(
		if AssetNull != undefined then
		(
			True
		)
		else
		(
			messageBox "AssetNull plugin not loaded.\nUnable to continue" title:"ILM Plugin Error:"
			False
		)
	),
	
	fn AssetIsSet asset =
	(
		local fullName = case ( classOf asset ) of
        (
            ( String ):
            (
                asset
            )
            ( AssetNull ):
            (
                asset.Asset_Fullname
            )
            default:""
        )
		
		if fullName != "" then
        (
            if ( toLower ( fullName[1] + fullName[2] + fullName[3] ) ) == "set" then True else False
        )
        else
        (
            False
        )
	),
	
	fn GetLatestVersionNumberFromPython =
	(
		::PYTHON_RETURN = undefined
		
		local pyCmd = StringStream ""
		
		format "
test = False
try:
	version
	test = True
except:
	print 'false'
		
if test:
	MaxPlus.Core.EvalMAXScript('PYTHON_RETURN = \"' + str(version.version_num) + '\"')
		" to:pyCmd
		
		local out = ::PYTHON_RETURN
		if out == undefined then out = "None"
		out
	),
	
	fn TranslateFileKey file_key =
	(
		local out
        
		case file_key of
		(
			("3dsmax"):
			(
				out = "source"
			)
			("Alembic"):
			(
				out = "default"
			)
			("source"):
			(
				out = "3dsmax"
			)
			("default"):
			(
				out = "Alembic"
			)
			default:
			(
				out = file_key
			)
		)
        
		out 
	),
	
	fn GetAssetInfoDic asset =
	(
		/* 
		- Create a dictionary using values from the Asset Null props
		- This is used to concotenate the export paths for CheckIn
		 */
		local dic = dotNetObject "System.Collections.Hashtable"
		dic.add "netroot" ( _ilmLibrary.GetNetRoot() )
		dic.add "show" asset._show
		dic.add "seq" asset._seq
		dic.add "shot" asset._shot
		dic.add "task" ( ::_GenPyFns.GetGenTaskDir asset._show )
		dic
	),
	
	fn DeleteAsset asset =
	(
		local objs = asset.CollectAssetObjs()
		 
		Delete objs
		Delete asset
		
		GC()
	),
	
	fn SwapProxyDisplay asset bool:False =
	(
		asset.Display_Proxy = bool
	),
	
	fn DeInstanceAssetNulls =
	(
		local opArr = #()
		local assetArr = ( this.CollectAssetNulls() )
		if assetArr.count != 0 then 
        (
            for i in assetArr do
            (
                opArr += (refs.dependentNodes i)
            )
        )
		if opArr.count > 1 then InstanceMgr.MakeObjectsUnique opArr #individual
            
		True
	),
	
	fn ValidateAssetVersions =
	(
		local assetArr = for i in ( this.CollectAssetNulls() ) collect ( this.GetShapeFromClassInstance i )
		
		if assetArr.count != 0 then
		(
			for i in assetArr do
			(
				if ( i.Asset_Version as integer ) == undefined then
				(
					i.Asset_Version = "0.0"
				)
			)
		)
	),
	
	fn CollectAssetMaterials asset =
	(
		/* 
		Collect all materials applied to the objects that make up the asset
		 */
		local arr = #()
		for i in ( asset.CollectAssetObjs() ) where ( i.material != undefined ) do
		(
			AppendIfUnique arr i.material
		)
		arr
	),
    
    fn SetAssetNullMetaData asset version_number: filetype: _track: _tag: _filters: =
    (
        asset = this.GetAssetShape asset
        
        if asset != undefined then
        (
            if version_number != unsupplied then asset.Asset_Version = ( version_number as string )
            if filetype != unsupplied then asset.filetype = filetype
            if _track != unsupplied then asset._track = _track
            if _tag != unsupplied then asset._tag = _tag
            if _filters != unsupplied then asset.variation = ( _filters as string )
            
            asset.NameByInstanceId()
            True
        )
        else
        (
            False
        )
    ),
    
    fn ExecutePostImportScript asset =
    (
        local lookDevPath = ::_ilmPathUtils.generateLookdevLocation asset._show
        local postImportScript = undefined  
        local assetLookDevPath = lookDevPath + asset.Asset_Fullname
        
        if ( doesFileExist assetLookDevPath ) then 
		(
			postImportScript = ::_GenFns.GetLatestFile assetLookDevPath "ms" pattern:"postImport"
        )
        
        if ( postImportScript != undefined ) and ( doesFileExist postImportScript ) then 
        (
            format "***** Applying Post-Import Script *****\n"
            
            fileIn postImportScript
            True
        )
        else
        (
            False
        )
    ),

	--JJ Function to Assign Look dev
	fn AssignAssetLookDev geoms _show _assetName _lookDev = 
	(
		local lookDevPath = ::_ilmPathUtils.generateLookdevLocation _show
		local matXML = undefined 
		local matLib = undefined
		local returnVal = false
 		local assetLookDevPath = lookDevPath + _assetName
 		local useUnifiedSrf = false
        local assetMatLibApplied = False

        if ( doesFileExist assetLookDevPath ) then 
		(
			matLib = ::_GenFns.GetLatestFile assetLookDevPath "mat" pattern:_lookDev
			matXML = ::_GenFns.GetLatestFile assetLookDevPath "xml" pattern:_lookDev
        )
        
        if ( matLib == "" ) or ( matXML == "" ) then 
        (
            matLib = ::_GenFns.GetLatestFile assetLookDevPath "mat" pattern:""
            matXML = ::_GenFns.GetLatestFile assetLookDevPath "xml" pattern:""
        )
        
        if ( matLib != undefined ) and ( doesFileExist matLib ) then 
        (
            format "***** Loading Lookdev Material Library: % *****\n" matLib
            
            ::_ilmMaterialLookdev.loadMaterialLib matLib
            assetMatLibApplied = True
            returnVal = true
        ) 
        else 
        (
            format "Material Lib not selected or doesn't exist\n"
        )
        
        if ( matXML != undefined ) and ( doesFileExist matXML ) then 
        (
            format "***** Assigning Material XML *****\n"
            
            ::_ilmMaterialLookdev.assignMaterialXML matXML assign_objs:geoms
            returnVal = true	
        ) 
        else 
        (
            format "Material XML path not selected or doesn't exist\n"
        )
        
        
        if ( not assetMatLibApplied ) then
        (
            local showGlobalsIni = ( (::_ilmLibrary.GetNetRoot()) + "\\dept\\digimatte\\3dsmax_files\\"+::ilmshow+"\\3dsmax_globalsettings.txt" )
            
            if ( DoesFileExist showGlobalsIni ) then
            (
                if ( HasIniSetting showGlobalsIni "Globals" "useUnifiedSrf" ) then
                (
                    useUnifiedSrf = ( ( GetIniSetting showGlobalsIni "Globals" "useUnifiedSrf" ) as BooleanClass )
                )
            )
            
            if useUnifiedSrf then
            (
                format "***** Applying Unified Srf...*****\n"
                
                local assetShortName = ::_ilmUnity.GetAssetShortname _show _assetName
                local libFile = @"\\lucas\ilm\show\" + _show + "\shared\gen\matlib\3dsmax_material_library.mat"
                
                if ( DoesFileExist libFile ) then
                (
                    local assetObjs =  execute("($'"+assetShortName+"'*...*)")
                    
                    assetObjs.material = undefined
                    
                    LoadMaterialLibrary libFile
                    
                    assetObjs.material = CurrentMaterialLibrary["iML_unified_simplesrf"]
                    
                    returnVal = true
                )
            )
        )
        
		returnVal			
	),
	
	--JJ Function to Import Modifier Sets
	fn importModifierSets _show _assetName topNull =
	(
		local modSetPath = ( ::_ilmPathUtils.generateLookdevLocation _show ) + _assetName
		local modFile = ::_GenFns.GetLatestFile modSetPath "ini" pattern:"modsets"
        
		local modDBFile = ( ( ::_ilmLibrary.GetNetRoot() ) + "\\show\\gengen\\shared\\gen\\assets\\modifierDatabase.ini" )
     
		if ( DoesFileExist modFile ) then 
		(
			local modArr = execute(getINISetting modFile "MODIFIERSETS" "array")
            
            if modArr.count != 0 then 
            (
                for i = 1 to modArr.count do 
                (
                    local numArrCount = (GetINISetting modFile modArr[i] "NumArrs") as integer 
                    local selSetName = (GetINISetting modFile modArr[i] "Name")
                    local modName = (GetINISetting modFile modArr[i] "modName")
                    
                    local tmpArr = #()
                    
                    for j = 1 to numArrCount do 
                    (
                        append tmpArr ( ::_GenFns.ConvertStrArrToNodeArr (getINISetting modFile modArr[i] ("arr_" + j as string )) topNull )
                    )
                    
                    local allObjNodeArr = #()
                    
                    for obj in tmpArr do 
                    (
                        for subObj in obj do 
                        (
                            if subObj != undefined do append allObjNodeArr subObj
                        )
                        
                    )
                    
                    print allObjNodeArr.count
                    selectionsets[selSetName] = allObjNodeArr
                    
                    if modName != "SELECTIONSET" do 
                    (
                        local modDBArr = execute(GetINISetting modDBFile "ASSETS" modName)
                        
                        local newMod = execute(getINISetting modDBFile "TYPES" modName)
                        local propArr = (getPropNames newMod)
                        for k = 1 to propArr.count do 
                        (
                            try 
                            (
                                setProperty newMod propArr[k] modDBArr[k]
                            )
                            catch()
                        )
                        addModifier selectionsets[selSetName] (newMod)
                    )
                )
            )
		)
		else 
		(
			print ( "No Asset Modifier Sets found for asset " + _assetName + "\n" )
		)
	),

	fn ApplyLookDev _show asset _lookdev:unsupplied method:"standard"  = 
	(
		if ( asset != undefined ) then 
		(
			local geoms = asset.CollectAssetObjs()
			local lookDevAssigned = false
        	local assetName = asset.Asset_FullName
        	local fileKey = asset.filetype
        	local verNum = asset.Asset_Version
        	local _tag = asset._tag
            
            -- Set the version number to the highest possible value, the method will automatically return the latest version
            if verNum == this.nullValue then verNum = "999.9"
            
        	local txtXML = ::_ilmAtlas.getAssetTextureXML assetName verNum _tag "dmsAuto"
            format "***** txtXML: % *****\n" txtXML
            
    		if ( DoesFileExist txtXML ) then
    		(
	        	::_ilmMaterialLookdev.parseTextureXML txtXML
                
	        	if ( ( ::_ilmTextureXML.sceneTextureObjects.items() ).count == 1 ) then
    			(
                    method = "UDIM"
                )
                
				if ( _lookdev != unsupplied ) then
		        (
		        	if ( fileKey == "Alembic" ) and ( _lookDev == "" ) or ( _lookdev == this.nullValue ) then 
			        (
			            _lookDev = "default"
			        )
                    
                    ::_ilmMaterialLookdev.applyTextureXML geoms apply_hidden:true mari_lookdev:true create_materials:false method:method
                    lookDevAssigned = this.AssignAssetLookDev geoms _show assetName _lookdev
        		)
                
		       	if not lookDevAssigned and ( fileKey == "Alembic" ) then
		        (
		        	::_ilmMaterialLookdev.applyTextureXML geoms apply_hidden:true mari_lookdev:true create_materials:true method:method
                    True
		        )	
	        )
            else
            (
                format "***** No XML file found for: % % % % *****\n" assetName verNum _tag "dmsAuto"
                False
            )
	    )
	),
    
    fn ConvertAlembicAssetToVrproxy asset =
    (
        if not ( isProperty asset #baseObject ) then asset = ( this.GetShapeFromClassInstance asset )
        
        local abcObjArr = ( for obj in (asset.CollectAssetObjs()) where ( obj.modifiers[#'Alembic Mesh Geometry'] != undfefined ) collect obj )
        --format "***** abcObjArr: % *****\n" abcObjArr
            
        local numFaces = ::_GenFns.GetFaceCount abcObjArr
        --format "***** numFaces: % *****\n" numFaces
            
        -- This is a sort of logic for optimizing the face count display of the proxy object
        if numFaces < 10000 then numFaces = numFaces/3
        while numFaces > 50000 do numFaces = numFaces/2
        if numFaces > 30000 then numFaces = 30000
        --format "***** numFaces: % *****\n" numFaces
        
        local abcPath = ( abcObjArr[1].modifiers[#'Alembic Mesh Geometry'].path )
        
        if abcPath == undefined then
        (
            format "!!!!!!!!!! Unable to get the abcPath for this asset: % !!!!!!!!!!\n" asset.name
            return False
        )
        --format "***** abcPath: % *****\n" abcPath
        
        local texPath = undefined
        for i = 1 to abcObjArr.count do
        (
            texPath = ( GetUserProp abcObjArr[i] "texturePath" )
            if texPath != undefined then exit
        )
        
        
        if texPath == undefined then
        (
            format "!!!!!!!!!! Unable to get the texturePath for this asset: % !!!!!!!!!!\n" asset.name
            --return False
        )
        --format "***** texPath: % *****\n" texPath  
            
        local vproxy = VrayProxy name:( asset.Asset_Fullname + "_vrproxy") filename:abcPath display:3 flip_axis:True use_alembic_offset:True \
                            num_preview_faces_alembic:numFaces subdiv_level_alembic:0 force_first_map_channel:True first_map_channel:1 visibility_lists_type:0
        
        vproxy.material = abcObjArr[1].material
        
        local assetParent = asset.children[1].children[1]
        if assetParent != undefined then vproxy.parent = assetParent
        
        SetUserProp vproxy "texturePath" texPath
        
        vproxy.transform = asset.transform
        
        local nullArr = ::_GenFns.GetChildrenRecursive assetParent skipNamePattern:vproxy.name
        
        Delete nullArr
        
        GC quiet:True
        
        vproxy
    ),

	fn ZeroOutAsset asset =
	(
		if ( isProperty asset #Proxy ) and ( IsValidNode asset.Proxy ) then
		(
			::_GenFns.AlignPivotToObject asset.Proxy asset
			
			asset.Proxy.transform = matrix3 1
		)
		
		asset.parent = undefined
		asset.transform.controller.value = matrix3 1
	),
	
	fn GetAssetFile _show _track asset_name version_number file_key _tag:"" =
	(
		local out = undefined
		if version_number == "<latest>" then
		(
			out = ::_ilmUnity.get_file_from_latest_version _show _track _tag asset_name file_key
		)
		else
		(
			out = ::_ilmUnity.get_file_from_version_num _show _track _tag asset_name version_number file_key
		)
		out
	),
    
    fn Help =
    (
        format "
---------------
CLASS USAGE:

Constructor = Asset_Fns
instantiated global = _assetFns
---------------\n"
    ),
	
	private fn _init =
	(
		this.Help()
	),

	__init__ = _init()
)

::_assetFns = Asset_Fns()