

struct UtilityFns
(
    ro_ObjId,
    
    fn DeleteEmptyLayers =
	(
		local currLayer = LayerManager.current
        
		( LayerManager.getLayer 0 ).current = true
        
		LayerManager.closeDialog()
		local emptyLayers =#()
        
		for i = 0 to layerManager.count-1 do
		(
			local ilayer = layerManager.getLayer i
			local layerName = ilayer.name 
			local layer = ILayerManager.getLayerObject i
            
            local layerNodesArr
			layer.Nodes &layerNodesArr
            
			if layerNodesArr.count == 0 then
			(
				append emptyLayers ( layerName as string )
			)
		)
        
		with PrintAllElements on format "***** Empty Layers: % \n" emptylayers
            
		for i = 1 to emptyLayers.count do
		( 
			layermanager.deleteLayerByName emptyLayers[i]
		)
        
		LayerManager.closeDialog()
		layermanager.editlayerbyname ""
	),
    
	fn HideLayersByObj objArr =
	(
		if objArr.count != 0 then
		(
			for i in objArr do
			(
				i.layer.on = false
			)
		)
		else
		(
			messageBox "Nothing selected... :(" title:"GTVFX:"
		)
	),
    
    fn GarbageCollect =
	(
		for i = 1 to 5 do GC()
	),
    
	fn FreeSceneBitmaps =
	(
		for i = 1 to 5 do FreeSceneBitmaps()
	),
    
    fn Get_Names name a =
	(
		append a name
	),
    
	fn CollectMissingFiles =
	(
        local out = #()
        
		EnumerateFiles this.Get_Names out #missing
        
		if out.count != 0 then 
        (
            print "============ Missing Files ============"
            for i in arr do print i
        )
		else
        (
            messageBox "***** No missing files *****"
        )
        
		out
	),
    
	fn DeleteObjArr objArr iFeelLucky:False =
	(
		if queryBox "Are you sure?" == true then
		(
			with undo off
			(
				if iFeelLucky then disableRefMsgs()
                
                delete objArr
                
				if iFeelLucky then enableRefMsgs()
			)
		)			
	),
    
	fn QuickPickParent =
	(
		with Undo "QuickPickParent" on
		(
			local parentObj = ( pickObject() )
            
            if parentObj != undefined then
            (
                local objArr = ( GetCurrentSelection() )
                
                local delIndex = ( FindItem objArr parentObj )
                
                if delIndex != 0 then
                (
                    DeleteItem objArr delIndex
                )
                
                objArr.parent = parentObj
                
                select parentObj
            )
		)
	),
    
	fn ParentToPickObjParent =
	(
		with Undo "ParentToPickObjParent" on
		(
			local obj = ( pickObject() )
            
            if ( obj != undefined ) and ( obj.parent != undefined ) then
            (
                $.parent = obj.parent
                select obj.parent
            )
		)
	),
    
	fn AlignAndLink objArr withRotation:True =
	(
		parentObj = ( pickObject() )
        
        if parentObj != undefined then
        (
            local delIndex = ( FindItem objArr parentObj )
            
            if delIndex != 0 then
            (
                DeleteItem objArr delIndex
            )
            
            objArr.parent = parentObj
            
            for obj in objArr do
            (
                if withRotation then obj.rotation.controller.value = (quat 0 0 0 1)
                obj.position.controller.value = [0,0,0]
            )
            
            select parentObj
        )
	),
    
	fn ToggleBoxMode objArr:( GetCurrentSelection() ) =
	(
        local state = objArr[1].boxmode
        
        for obj in objArr do
        (
            obj.boxmode = not state
        )
	),
    
	mapped fn SetObjId objArr id =
	(
		objArr.gbufferchannel = id	
	),
    
	fn ObjId_Rollout =
	(
		try(destroyDialog self.ro_ObjId)catch()
		rollout ro_ObjId "Object ID" width:170
		(
			local self
            -- As of 10/24/2015 the value 65535 is the current maximum integer value that is valid for the gbuffer channel
			spinner spn_objId "Object ID:" range:[0,65535,0] type:#integer
			button btn_objId "Set ID" width:(ro_ObjId.width-20) height:35
			checkBox chk_Quick "Super Fast Mode!" triState:1 tooltip:"Updates the Obj ID of your selection as you update the spinner"
			fn _init pself =
			(
				self = pself
			)
			on spn_objId changed newV do
			(
				if chk_Quick.checked then
				(
					self.SetObjId selection spn_objId.value
				)
			)
			on btn_objId pressed do
			(
				self.SetObjId selection spn_objId.value
			)
		)
		createdialog ro_ObjId
		ro_ObjId._init self
	),
    
	fn TransformLockToggle objArr:( GetCurrentSelection() ) =
	(
		if ( GetTransformLockFlags objArr[1] )[1] == False then
		(
			for obj in objArr do setTransformLockFlags obj #all
			format "***** Transform Locked *****\n"
		)
		else
		(
			for obj in objArr do setTransformLockFlags obj #none
			format "***** Transform Unlocked *****\n"
		)
	),
    
	fn LockAllCams =
	(
		for cam in cameras do SetTransformLockFlags cam #all
		format "***** Cameras Locked *****\n"
	),
    
    fn GetModule =
    (
        ( GetThisScriptFileName() )
    ),

    fn Help =
    (
        ::_ilmLibrary.GetScriptHelp ( this.GetModule() )
    ),

    private fn _init =
    (
        -- Pass
    ),

    __init__ = _init()
)

UtilityFns = UtilityFns()