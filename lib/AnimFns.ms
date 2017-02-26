/*
__HELP__

Constructor: 
Instantiated Global: 



Methods:



__END__
*/


::_mxs.Load "MeshFns"


struct AnimFns
(
    ro_pointCacheHelper,
    ro_offsetKeyframes,
    

    fn SavePointCacheByName objArr dirPath sampleRate:1 fileType:#pc2 recordStart:( animationRange.start - 5 ) recordEnd:( animationRange.end + 5 ) =
	(
		for obj in objArr do
		(
			if ( Validmodifier obj ( Point_CacheSpacewarpModifier() ) ) then
			(
				PCmod = ( Point_CacheSpacewarpModifier name:#World_PC loadType:2 loadTypeSlave:2 \
                                                        fileName:( dirPath +"\\" + obj.name + "." + ( fileType as string ) ) \
                                                        recordStart:recordStart recordEnd:recordEnd \
                                                        sampleRate:sampleRate)
                
				Addmodifier obj PCmod
				CacheOps.RecordCache obj.modifiers[#World_PC]
			)
			else
            (
                format "***** % Will not accept Point Cache modifier *****\n" obj.name
            )
		)
	),
    
	fn LoadPointCacheByName objArr dirPath fileType:#pc2 zeroMatrix:True=
	(
		for obj in objArr do
		(
			local fileName = ( dirPath +"\\" + obj.name + "." + ( fileType as string ) )
			if ( DoesFileExist filename ) then
			(
				obj.parent = undefined 
                
				if zeroMatrix then ::MeshFns.ZeroOutMatrix_mapped obj
                
				AddModifier obj ( Point_Cache name:#Local_PC filename:fileName )
			)
			else
            (
                format "***** % does not have an associated cache file in that folder *****\n" obj.name
            )
		)
	),
    
	mapped fn BakePointToObject objArr =
	(
		createLayerAndSetCurrent "###_Anm_Baked"
		maxOps.GetDefaultTangentType &inType &outType
		maxOps.setDefaultTangentType #flat #flat writeInCfgFile:true
		bakePointArr = #()
		if isProperty objArr "transform" == true then
		(
			bakePoint = point size:10 centerMarker:false cross:false box:true axistripod:true wirecolor:orange name:( objArr.name + "_bakePoint" )
			append bakePointArr bakePoint
			with animate on 
			(
				for t = (animationRange.start - 5f) to (animationrange.end + 5f) do
				(
					at time t 
					(
						bakePoint.transform = objArr.transform
					)
				)
			)
		)	
		maxOps.setDefaultTangentType inType outType writeInCfgFile:true
		bakePointArr
	),
    
	fn AttachPointToObject_FN objArr faceID = 
	(
		attachPointArr = #()
		createLayerAndSetCurrent "###_Atch_Points"
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
    
	fn PointCache_Ui = 
	(
		try(destroyDialog self.ro_pointCacheHelper)catch()
		rollout ro_pointCacheHelper "Point Cache Helper By: GTVFX"
		(
			local self
			local pcPath
			local LCmod
			local cacheXT = "pc2"
			label lbl_setDir "Source Directory:" pos:[15,5] 
			editText edTxt_pcPath "" fieldWidth:330 pos:[10,20] 
			button btn_pcPath "...." width:20 height:20 pos:[350,18] tooltip:"Paste path in text field or use this button to choose path"
			spinner spn_sRate "Sample Rate:" type:#float range:[0,1,1] pos:[265,45] fieldWidth:50 enabled:false toolTip:"Set to a lower value to bake more samples per frame."
			button btn_saveCache "Save Cache" width:120 height:25 pos:[10,45] enabled:false
			button btn_loadCache "Load Cache" width:120 height:25 pos:[10,75] enabled:false
			checkBox chk_XML "XML" pos:[350,70] enabled:false
			checkBox chk_PC2 "PC2" checked:true pos:[350,90] enabled:false
			checkBox chk_matrix "Reset Matrix before load" checked:true pos:[10,110] enabled:false
			hyperLink hyp_website "www.gtvfx.com" color:orange  hoverColor:red visitedColor:orange address:"http://www.gtvfx.com" pos:[310,115]
			fn _init pself =
			(
				self = pself
			)
			fn enableUI =
			(
				spn_sRate.enabled = true
				btn_saveCache.enabled = true
				btn_loadCache.enabled = true
				chk_XML.enabled = true
				chk_PC2.enabled = true
				chk_matrix.enabled = true
			)
			on chk_XML changed state do
			(
				if state then
				(
					chk_PC2.checked = false
					cacheXT = "xml"
				)
			)
			on chk_PC2 changed state do
			(
				if state then
				(
					chk_XML.checked = false
					cacheXT = "pc2"
				)
			)
			on edTxt_pcPath entered newpath do
			(
				pcPath = newpath
				enableUI()
			)
			on btn_pcPath pressed do
			(
				pcPath = getSavePath caption:"** POINT TO YOUR CACHE LOCATION ** " initialDir:maxFilePath
				if pcPath != undefined then
				(
					edTxt_pcPath.text = pcPath
					enableUI()
				)
			)
			on btn_loadCache pressed do
			(
				if selection.count != 0 then
				(
					self.loadPointCache (getCurrentSelection()) pcPath cacheXT resetMatrix:chk_matrix.state
				)
			)
			on btn_saveCache pressed do
			(
				if selection.count != 0 then
				(
					self.savePointCache (getCurrentSelection()) pcPath cacheXT spn_sRate.value
				)
			)
		)
		createdialog ro_pointCacheHelper width:400 height:135
		ro_pointCacheHelper._init self
	),
    
	fn OffsetKeyframeRollout_FN =
	(
		try(destroyDialog self.ro_offsetKeyframes)catch()
		rollout ro_offsetKeyframes "Keyframe Offsetter" width:180 height:120
		(
			local KeyFrameOffsetImg = undefined
			checkBox chk_AllKeys "All Keys" checked:true pos:[10, 10]
			checkBox chk_SelKeys "Selected Keys" pos:[80,10]
			spinner spn_offset "Offset Amount:  " fieldWidth:50 pos:[80,35] width:72 height:16 range:[-10000,10000,0]
			button btn_OffsetKeys "Offset Keys" pos:[10,60] width:160 height:50
			fn bumpTime t delta =
			(
				t + delta
			)
			on chk_SelKeys changed state do
			(
				if chk_SelKeys.checked == true then
				(
					chk_AllKeys.checked = false
				)
			)
			on chk_AllKeys changed state do
			(
				if chk_AllKeys.checked == true then
				(
					chk_SelKeys.checked = false
				)
			)
			on btn_OffsetKeys pressed do
			(
				if chk_AllKeys.state then
				(
					mapKeys selection bumpTime spn_offset.value #allKeys
				)
				else
				(	
					mapKeys selection bumpTime spn_offset.value #selection
				)
			)
		)
		createdialog ro_offsetKeyframes
	),
    
    
    
    
    
    
    
    
    fn GetModule =
    (
        ( GetSourceFileName() )
    ),

    fn Help =
    (
        -- Static Method
        ::_ilmLibrary.GetScriptHelp ( GetSourceFilename() )
    ),

    private fn _init =
    (
        -- Pass
    ),

    __init__ = _init()
)