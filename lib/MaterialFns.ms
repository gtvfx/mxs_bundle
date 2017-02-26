


_mxs.Using "MeshFns"


struct MaterialFns
(
    ro_SaveMatLib,
    ro_ApplyMatLib,
    
    fn ResetMEdit =
	(
		macros.run "Medit Tools" "clear_medit_slots"
	),
    
	fn RestoreMedit =
	(
		macros.run "Medit Tools" "restore_medit_slots"
	),
    
	fn PutMatToActiveMeditSlot obj:( selection[1] ) =
	(
		MatEditor.mode = #basic
        
		if ( obj != undefined ) and ( obj.material != undefined ) then
		(
			meditMaterials[activeMeditslot] = selection[1].material
		)
        else
        (
            format "***** PutMatToActiveMeditSlot could not collect a valid material *****\n"
        )
	),
    
    fn CollectMats objArr =
    (
        local out = #()
        
        for obj in objArr where obj.material != undefined do
        (
            appendIfUnique out obj.material
        )
        
        out
    ),
    
	fn PutSelMatsToMEdit objArr:( GetCurrentSelection() ) = 
	(
		if ( objArr.count != 0 ) then
		(
			MatEditor.mode = #basic
            
            local matArr = this.CollectMats objArr
                
            for i = 1 to matArr.count do
            (
                if i > meditMaterials.count then exit
                
                meditMaterials[i] = matArr[i]
            )
            
			if matArr.count > meditMaterials.count then messageBox "There were more materials than MEdit slots."
		)
		else
        (
            messagebox "Nothing selected......"
        )
	),
    
	fn PutSceneMatsToMEdit =
	(
		if sceneMaterials.count != 0 then
		(
			MatEditor.mode = #basic
			for t = 1 to meditMaterials.count do
            (
                if scenematerials[t] == undefined then
                (
                    exit
                )
                else
                (
                    meditmaterials[t] = scenematerials[t]
                )
            )
            
			if sceneMaterials.count > meditMaterials.count do messageBox "There are more materials than MEdit slots." title:"GTVFX"
		)
        else
        (
            messageBox "No materials found in scene." title:"GTVFX: Error"
        )
	),
    
	fn BlackMaterial =
	(
		local out
        
		if ( VrayLightMtl != undefined ) then
		(
			out = ( VrayLightMtl name:"Black" color:black )
		)
		else
		(
			out = ( Standard diffuse:Black selfIllumAmount:100 )
		)
        
		out
	),
    
    mapped fn ApplyMaterial objArr mat =
    (
        objArr.material = mat
    ),
    
	fn ApplyBlackMaterial objArr =
	(
		this.ApplyMaterial objArr this.BlackMaterial()
	),
    
	fn CreateUtilMtls =
	(
		this.ResetMEdit()
        
        if ( VRay != undefined ) then
        (
            meditMaterials[1] = vrayLightMtl name:"Red" color:Red
            meditMaterials[2] = vrayLightMtl name:"Green" color:Green
            meditMaterials[3] = vrayLightMtl name:"Blue" color:Blue
            meditMaterials[4] = vrayLightMtl name:"Black" color:Black
            meditMaterials[5] = vrayLightMtl name:"White" color:White
            meditMaterials[6] = vrayMtl name:"Diffuse" color:(color 58 58 58)
            meditMaterials[7] = vrayMtl name:"Chrome" color:Black reflection:White
        )
        else
        (
            meditMaterials[1] = Standard name:"Red" diffuse:Red selfIllumAmount:100
            meditMaterials[2] = Standard name:"Green" diffuse:Green selfIllumAmount:100
            meditMaterials[3] = Standard name:"Blue" diffuse:Blue selfIllumAmount:100
            meditMaterials[4] = Standard name:"Black" diffuse:Black selfIllumAmount:100
            meditMaterials[5] = Standard name:"White" diffuse:White selfIllumAmount:100
            meditMaterials[6] = Standard name:"Diffuse" diffuse:(color 58 58 58)
        )
		
		setMTLMEditFlags meditMaterials[7] #{2,3}
		matEditor.open()
	),
    
	fn SaveMatLib_Ui = 
	(
		try(destroyDialog this.ro_SaveMatLib)catch()
        
		rollout ro_SaveMatLib "Save Material Library" width:350
		(
			local maxName = getfileNameFile maxFileName 
			local matName = ""
			local finalMatPath = ""	
			local newDirArr = #() 
            
			editText edt_Path "To:" text:"Paste in the directory where you want your MatLib saved."
			button btn_svMatLib "Save Material Library" width:( ro_SaveMatLib.width - 20 ) height:40 toolTip:"Saves the shader in slot [Active] to the directory in the text field."
			
            on edt_Path entered newText do
			(
				local newDirArr = GetDirectories newText
                
				if newDirArr.count == 1 then
				(
					format "***** Directory Accepted. *****\n"
				)
				else
				(
					MessageBox "Cannot parse the folder path.\nMake sure the folder path is correct and try again."
					edt_Path.text = ""
				)
			)
            
			on btn_svMatLib pressed do
			(
				if doesFileExist edt_Path.text == true then
				(
                    local matName = MeditMaterials[activeMeditslot].name
                    local finalMatPath = edt_Path.text + "\\" + matName + ".mat"
                    local newMatLib = MaterialLibrary MeditMaterials[activeMeditslot]
                    
					SaveTempMaterialLibrary newMatLib finalMatPath
				)
				else
				(
					messageBox "Folder does not exist.\nCheck again" title:"GTVFX: Error"
				)
			)
		)
        
		createdialog ro_SaveMatLib
	),
    
	fn ApplyMatLibToSelection matLibPath =
	(
        if not ( DoesFileExist matLibPath ) then
        (
            return ( format "***** ApplyMatLibToSelection could not find the supplied file *****\n" )
        )
        
		if selection.count != 0 then
		(
			loadMaterialLibrary matLibPath
			local appMat = currentMaterialLibrary[1]
			for each in ( GetCurrentSelection() ) do each.material = appMat
            
			format "***** Material Library Applied *****\n"
		)
		else
		(
			messageBox "Select the objects you want the material applied to."
		)
	),
    
	fn ApplyMatLib_Ui =
	(
		try(destroyDialog this.ro_ApplyMatLib)catch()
        
		rollout ro_ApplyMatLib "Apply Material Library" width:350
		(
			local self
			local libPath = undefined
            
			editText edt_Path "To:" text:"Paste in the directory where you want your MatLib saved."
			button btn_loadMatLib "Apply Material Library" width:( ro_ApplyMatLib.width - 20 ) height:40 toolTip:"Applies the first material in the supplied matLib to your selection."
			
            fn _init pself =
			(
				self = pself
			)
            
			on edt_Path entered newText do
			(
				if ( DoesFileExist newText ) and ( GetFileNameType newText ) == ".mat" then
				(
					libPath = newText
					format "**** Material Library Accepted ****\n"
				)
				else
				(
					MessageBox "Cannot parse the file path.\nMake sure to past the full path to the file."
					edt_Path.text = ""
					libPath = undefined
				)
			)
            
			on btn_loadMatLib pressed do
			(
				if libPath != undefined then
				(
					self.ApplyMatLibToSelection libPath
				)
				else
				(
					messageBox "Supply a material library file to proceed."
				)
			)
		)
        
		createdialog ro_ApplyMatLib
		ro_ApplyMatLib._init this
	),
    
    fn SME_GetSmeFile dirNames:#(#plugcfg, #plugcfg_ln) =
	(
		local fileArr = #()
        
		for dir in dirNames do
		(
			fileArr += ( GetFiles ( ( GetDir dir ) + "\\*" ) )
		)
        
		local ini = ( for file in fileArr where ( matchPattern ( fileNameFromPath file ) pattern:"SME.ini" ) collect file )[1]
        
		ini
	),
    
	fn SME_DisableRendering =
	(
		local smeIni = this.SME_GetSmeFile()
		if smeIni != undefined and (doesFileExist smeIni) then
		(
			setIniSetting smeIni "Common" "EnableRendering" "0"
		)
		else
		(
			messageBox "Unable to edit SME.ini\nCould not find the file." title:"GTVFX: Error"
		)
	),
    
	fn SME_DeleteAllViews_FN =
	(
		MatEditor.mode = #advanced
		local numViews = trackViewNodes[#sme].numsubs
		for i = 1 to numViews do sme.DeleteView 1 false
	),
    
	fn SME_CreateViewForMat mat =
	(
		if ( sme.GetViewByName mat.name ) == 0 then
		(
            MatEditor.mode = #advanced
            MatEditor.Open()
            
			sme.CreateView mat.name
			local newView = sme.GetView ( sme.GetViewByName mat.name )
			newView.CreateNode mat [0,0]
			True
		)
		else
		(		
            if queryBox ("Node view..." + mat.name + "...already exists.\nDo you want to replace it?") then
            (
                sme.DeleteView ( sme.GetViewByName mat.name ) false
                
                this.SME_CreateViewForMat mat
            )
		)
	),
    
	fn SME_CreatenodeViewForObjs objArr =
	(
		local arr = #()
        
		if ( selection.count != 0 ) then
		(
			MatEditor.mode = #advanced
			MatEditor.Open()
            
			local matArr = This.CollectMats objArr
            
			for mat in matArr do
			(
				this.SME_createViewForMat mat
			)
		)
		else
		(
			messageBox "**** You must have an object selected ****"
		)
	),
    
	fn SME_CreateNodeViewByFaceID obj:( Selection[1] )=
	(
		if obj == undefined then
		(
			messageBox "SME_CreateNodeViewByFaceID expects an obj to be passed.\nBy default this is the first object in Selection."
		)
		else
		(
            if obj == Selection[1] then
            (
                format "***** SME_CreateNodeViewByFaceID only works on a single object *****\n"
            )
            
			MatEditor.mode = #advanced
			MatEditor.Open()
            
			local masterMat = obj.material
            
			if ( ClassOf masterMat ) == multiMaterial then
			(
                local faceIdArr = ::MeshFns.GetUniqueMatIds obj
                
                for id in faceIdArr do
                (
                    local iMat = obj.material.materialList[id]
                    
                    this.SME_CreateViewForMat iMat
                )
			)
			else
			(
				messageBox "The object's material is not a Multi/Sub material."
			)
		)
	),
    
	fn SME_CreateNodeViewForEachSceneMaterial =
	(
		if sceneMaterials.count != 0 then
		(
			MatEditor.mode = #advanced
			--this.SME_deleteAllViews()
			MatEditor.Open()
            
			for mat in sceneMaterials do
			(
				this.SME_CreateViewForMat mat
			)
		)
		else
        (
            messageBox "No materials found in scene."
        )
	),
    
    fn GetModule =
    (
        ( GetSourceFilename() )
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

MaterialFns = MaterialFns()