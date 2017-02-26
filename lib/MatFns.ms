/************************************************************************************
Class for dealing with common material methods


************************************************************************************/

_mxs.Using "MeshFns"

struct MatFns
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
	
	fn GetMatByName matName =
	(
		local out = (for i in sceneMaterials where ( SuperclassOf i == Material ) and ( matchPattern i.name pattern:matName ) collect i)[1]
		out
	),
	
	fn CollectUniqueMats objArr =
	(
		local arr = for i in objArr where i.material != undefined collect i.material
		arr = MakeUniqueArray arr
		arr
	),
	
	fn PutMatArrToMedit matArr =
	(
		this.ResetMEdit()
		MatEditor.mode = #basic
		MatEditor.Open()
		
		for i = 1 to 24 do
		(
			if matArr[i] == undefined then exit
			
			meditMaterials[i] = matArr[i]
		)
		
		if matArr.count > 24 then
		(
			messageBox "There were more materials than MEdit slots." title:"MXS Error"
		)
	),
	
	fn PutMatArrToSme matArr =
	(
		
	),
	
	fn PutMatToMedit mat index:activeMeditSlot =
	(
		if index > 24 then
		(
			messageBox "Index out of range\nMust be less than 24" title:"MXS: Invalid Argument"
			return False
		)
		
		MatEditor.mode = #basic
		MatEditor.Open()
		meditMaterials[index] = mat
		True
	),
	
	fn PutMatToActiveMeditSlot mat =
	(
		if selection[1] != undefined and selection[1].material != undefined then
		(
			this.PutMatToMedit selection[1].material index:activeMeditSlot
		)
	),
	
	fn PutSelMatsToMEdit objArr = 
	(
		if objArr.count != 0 then
		(
			local matArr = this.CollectUniqueMats objArr
			
			this.PutMatArrToMedit matArr
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
			local arr = for i in sceneMaterials where ( SuperClassOf i == Material ) collect i
			this.PutMatArrToMedit arr
		)
		else
		(
			messageBox "No materials found in scene." title:"MXS: Error"
		)
	),
	
	fn CreateBlackMaterial =
	(
		local out = undefined
		
		if VrayLightMtl != Undefined and ( VrayIsRenderer() ) then
		(
			out = (VrayLightMtl name:"Black" color:black)
		)
		else
		(
			out = (Standard name:"Black" diffuse:Black selfIllumAmount:100)
		)
		
		out
	),
	
	mapped fn ApplyMaterial objArr mtl:(this.CreateBlackMaterial()) =
	(
		objArr.material = mtl
	),
	
	fn CreateUtilMtls =
	(
		this.ResetMEdit()
		
		local gammaValue = 58
		
		if IDisplayGamma.colorCorrectionMode == #gama then
		(
			gammaValue = (ceil (gammaValue * displayGamma)) as integer
		)
		
		if VRayLightMtl != undefined and ( VRayIsRenderer() ) then
		(
			meditMaterials[1] = ( VrayLightMtl name:"Red" color:Red )
			meditMaterials[2] = ( vrayLightMtl name:"Green" color:Green )
			meditMaterials[3] = ( vrayLightMtl name:"Blue" color:Blue )
			meditMaterials[4] = ( vrayLightMtl name:"Black" color:Black )
			meditMaterials[5] = ( vrayLightMtl name:"White" color:White )
			meditMaterials[6] = ( vrayMtl name:"Diffuse" diffuse:(color gammaValue gammaValue gammaValue) )
			meditMaterials[7] = ( vrayMtl name:"Chrome" diffuse:black reflection:white )
		)
		else
		(
			meditMaterials[1] = ( Standard name:"Red" diffuse:Red selfIllumAmount:100 )
			meditMaterials[2] = ( Standard name:"Green" diffuse:Green selfIllumAmount:100 )
			meditMaterials[3] = ( Standard name:"Blue" diffuse:Blue selfIllumAmount:100 )
			meditMaterials[4] = ( Standard name:"Black" diffuse:Black selfIllumAmount:100 )
			meditMaterials[5] = ( Standard name:"White" diffuse:White selfIllumAmount:100 )
			meditMaterials[6] = ( Standard name:"Diffuse" diffuse:(color gammaValue gammaValue gammaValue) )
			meditMaterials[7] = ( Standard name:"Chrome" diffuse:black reflection:white )
		)
		
		SetMTLMEditFlags meditMaterials[7] #{2,3}
		matEditor.open()
		

	),
	
	fn SaveMatLib matArr _path = 
	(
		if ( DoesFileExist (GetFileNamePath _path) ) then
		(
			saveTempMaterialLibrary ( materialLibrary matArr ) _path
		)
		else
		(
			messageBox "Folder does not exist.\nCheck again" title:"MXS: Error"
		)
	),
	
	fn Ui_SaveMatLib = 
	(
		try(destroyDialog this.ro_SaveMatLib)catch()
		
		rollout ro_SaveMatLib "Save Material Library"
		(
			local self
			local matName = ""
			local finalMatPath = ""	
			local newDirArr = #()
			
			editText edt_Path "To:" text:"Paste in the directory where you want your MatLib saved."
			button btn_svMatLib "Save Material Library" width:120 height:40 pos:[200,40] toolTip:"Saves the shader in slot [Active] to the directory in the text field."
			
			fn _init pself =
			(
				self = pself
			)
			
			on edt_Path entered newText do
			(
				local newDirArr = getDirectories newText
				
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
				local matName = MeditMaterials[activeMeditslot].name
				local finalMatPath = edt_Path.text + "\\" + matName + ".mat"
				
				this.SaveMatLib #(MeditMaterials[activeMeditslot]) finalMatPath
			)
		)
		
		createdialog ro_SaveMatLib width:350 height:100
		ro_SaveMatLib._init self
	),
	
	fn ApplyMaterialFromMatLib objArr matPath =
	(
		if objArr.count != 0 then
		(
			if DoesFileExist matPath then
			(
				LoadMaterialLibrary matPath
				local mat = currentMaterialLibrary[1]
				if mat != undefined and superclassof mat == Material then
				(
					this.ApplyMaterial objArr mtl:(mat) 
					format "***** Material Applied *****\n"
				)
				else
				(
					messageBox "ApplyMatLibToSelection:\nThe material found in the file was invalid." title:"MXS: Error"
				)
				
			)
			else
			(
				messageBox "ApplyMatLibToSelection:\nNo file exists at the supplied path." title:"MXS: Error"
			)
		)
		else
		(
			messageBox "ApplyMaterialFromMatLib:\nExpected a valid node arr as first argument."
		)
	),
	
	fn Ui_ApplyMatLib =
	(
		try(destroyDialog self.ro_ApplyMatLib)catch()
		rollout ro_ApplyMatLib "Apply Material Library" width:450
		(
			local self
			local libPath = undefined
			
			editText edt_Path "Material Library:" text:"Paste in the path to your material library."
			button btn_loadMatLib "Apply Material Library" width:(ro_ApplyMatLib.width-20) height:40 toolTip:"Applies the first material in the supplied matLib to your selection."
			
			fn _init pself =
			(
				self = pself
			)
			
			on edt_Path entered newText do
			(
				if doesFileExist newText and (GetFileNameType newText) == ".mat" then
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
					self.ApplyMaterialFromMatLib (GetCurrentSelection()) libPath
				)
				else
				(
					messageBox "Supply a material library file to proceed."
				)
			)
		)
		
		createdialog ro_ApplyMatLib
		ro_ApplyMatLib._init self
	),
	
	
	
--( Slate Editor
	
	fn SME_GetSMEini dirNames:#(#plugcfg, #plugcfg_ln) =
	(
		local fileArr = #()
		
		for i in dirNames do
		(
			fileArr += (getFiles ((getDir i) + "\\*"))
		)
		
		ini = (for i in fileArr where matchPattern (FileNameFromPath i) pattern:"SME.ini" collect i)
		
		if ini.count > 1 then format "Multiple SME.ini files found.\n%\n" ini
		
		ini[1]
	),
	
	fn SME_DisableRendering =
	(
		local smeIni = this.SME_GetSMEini()
		if smeIni != undefined and (DoesFileExist smeIni) then
		(
			SetIniSetting smeIni "Common" "EnableRendering" "0"
		)
		else
		(
			messageBox "Unable to edit SME.ini\nCould not find the file." title:"MXS: Error"
			False
		)
	),
	
	fn SME_DeleteAllViews =
	(
		MatEditor.mode = #advanced
		local numViews = trackViewNodes[#sme].numsubs
		for i = 1 to numViews do sme.DeleteView 1 False
	),
	
	fn SME_DeleteViewByName _name =
	(
		local smeView = sme.GetViewByName _name
		if smeView != 0 then
		(
			sme.DeleteView smeView False
		)
	),
	
	fn SME_CreateViewForMat mat =
	(
		MatEditor.mode = #advanced
		MatEditor.Open()
		
		if (sme.GetViewByName mat.name) == 0 then
		(
			sme.CreateView mat.name
			local newView = sme.GetView (sme.GetViewByName mat.name)
			newView.CreateNode mat [0,0]
			True
		)
		else
		(	
			if queryBox ("Node view..." + mat.name + "...already exists.\nDo you want to delete it?") then
			(
				this.SME_DeleteViewByName mat.name
				sme.CreateView mat.name
				local newView = sme.GetView (sme.GetViewByName mat.name)
				newView.CreateNode mat [0,0]
				True
			)
			else
			(
				False
			)
		)
	),
	
	fn SME_CreateViewsForMatArr matArr =
	(
		for mat in matArr do
		(
			this.SME_createViewForMat mat
		)
	),
	
	fn SME_CreateViewForObjs objArr =
	(
		if objArr != 0 then
		(
			MatEditor.mode = #advanced
			MatEditor.Open()
			
			this.SME_CreateViewsForMatArr (this.CollectUniqueMats objArr )
		)
		else
		(
			throw "SME_CreateViewForObjs expected a collection of objects"
		)
	),
	
	fn SME_CreateViewByFaceID objArr =
	(
		if objArr.count != 0 then
		(
			MatEditor.Close()
			MatEditor.mode = #advanced
			
			for obj in objArr do
			(
				local masterMat = obj.material
				
				if masterMat == undefined then
				(
					continue
				)
				
				if classOf masterMat != MultiMaterial then
				(
					this.SME_CreateViewForMat masterMat
					continue
				)
			
				local faceIdArr = _meshFns.CollectFaceIds obj
				
				for faceID in faceIdArr do
				(
					local theMat = obj.material.materialList[faceID]
					
					this.SME_CreateViewForMat theMat
				)
			)
			
			MatEditor.Open()
		)
	),
	
	fn SME_CreateFromSceneMaterials =
	(
		if sceneMaterials.count != 0 then
		(
			MatEditor.Close()
			MatEditor.mode = #advanced
			this.SME_DeleteAllViews()
			
			for mat in sceneMaterials do
			(
				this.SME_CreateViewForMat mat
			)
			
			MatEditor.Open()
		)
		else
		(
			messageBox "No materials found in scene."
		)
	),
	
--)
	
	fn ClassUsage =
	(
		format "
Common material functions
		
Constructor: MatFns
Instantiated Global: _MatFns
		"
	),
	
	private fn __init__ =
	(
		self = this
	),
	
	_init = __init__()
)

_matFns = MatFns()


