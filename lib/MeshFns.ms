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
Updated:				
***************************************************************************************************/
/*
__HELP__

Constructor: 
Instantiated Global: 

[METHODS]

[DESCRIPTION]

[USAGE]

__END__
*/


mxs.Using "WpfProgressBar"
mxs.Using "EventTimer"

struct MeshFns
(
public

    fn IsValidMesh obj =
    (
        if ( isProperty obj #mesh ) and ( isProperty obj.mesh #numfaces ) then
        (
            True
        )
        else
        (
            False
        )
    ),
    
    mapped fn ZeroOutMatrix_mapped objArr =
	(
		objArr.objectOffsetPos = [0,0,0]
		objArr.objectOffsetRot = (quat 0 0 0 1)
		objArr.objectOffsetScale = [1,1,1]
		objArr.transform = matrix3 1
	),

    fn GetUniqueMatIds objArr =
    (
        objArr = ::mxs.EnsureArgIsArray objArr
        
        local out = #()
        
        for obj in objArr do
        (
            if ( this.IsValidMesh obj ) then
            (
                for i = 1 to obj.mesh.numfaces do
                (
                    appendIfUnique out ( GetFaceMatID obj.mesh i )
                )
            )
            else
            (
                format "***** % is not a valid mesh *****\n" obj
            )
        )
        
        ( sort out )
    ),
    
    fn ShowObjMatIDs objArr =
	(
        local idArr = this.GetUniqueMatIds objArr
        
        local str = StringStream ""
        
        if idArr.count != 0 then
        (
            format "MatIds in collection:\n" to:str
            
            for id in idArr do
            (
                format "%...\n" id to:str
            )
        )
        else
        (
            format "No MatIds in collection:\n" to:str
        )
        
        messageBox ( str as string ) title:"GTVFX:"
	),
    
    fn SelectByMatId matId = -- Move to SelectionFns
    (
        
    ),

    fn CheckIfModifiersPresent objArr = 
	(
		out = False
        
		for obj in objArr do 
        (
            if obj.modifiers.count > 0 then
            (
                format "***** % has modifiers *****\n" obj.name
                out = True
                exit
            )
        )
       
		out
	),
    
	mapped fn FastResetXform objArr =
	(
		resetXform objArr
		collapseStack objArr
	),
    
	mapped fn FastCenterPivot objArr =
	(
		CenterPivot objArr
	),
    
    mapped fn ResetXformWithRotation objArr =
	(
		local saveRotation = objArr.rotation.controller.value
		local savePosition = objArr.position.controller.value
        
		objArr.rotation.controller.value = (quat 0 0 0 0)
		objArr.position.controller.value = [0,0,0]
        
		this.FastResetXform objArr
        
		objArr.scale.controller.value = [1,1,1] -- hard code the value after the resetXform to eliminate rounding/precision errors
        
		objArr.rotation.controller.value = saveRotation
		objArr.position.controller.value = savePosition
	),
    
	fn ResetMesh objArr collapseMods:False =
	( 
        objArr = ::mxs.EnsureArgIsArray objArr
        
        ::mxs.BlockUi True
        
        local prg = WpfProgressBar caption:"Reset Mesh:" steps:objArr.count
        prg.Start()
        
		InstanceMgr.MakeObjectsUnique objArr #individual
        
		for obj in objArr do
		(
            prg.UpdateLabel obj.name
            
            local mds = #()
			
			if obj.modifiers.count != 0 then
			(
                if not collapseMods then
                (
                    for m = 1 to obj.modifiers.count do 
                    (
                        if obj.modifiers[m].enabled then
                        (
                            mds[m] = True
                            obj.modifiers[m].enabled = false
                        )
                        else mds[m] = False
                    )
                )
                else
                (
                   CollapseStack obj 
                )
			)
            
			---make a clean shape...
			local bx = box()
            
			objInst = instance obj
            
			convertToPoly bx
            
			bx.transform = obj.transform
			bx.scale.controller = ScaleXYZ()
			bx.scale.controller.value = [1,1,1]
            
			polyOp.attach bx objInst
			polyOp.deleteVerts bx #{1..8}
            
			---fix the tranform
			local conType = classof obj.scale.controller
            
			obj.scale.controller = ScaleXYZ()
			obj.transform = bx.transform
			obj.scale.controller = conType()
			obj.ObjectOffsetPos = [0,0,0]
			obj.ObjectOffsetRot = quat 0 0 0 1
			obj.ObjectOffsetScale = [1,1,1]
			obj.baseObject = copy bx.baseObject
            
            if mds.count != 0 then
            (
                for m = 1 to mds.count do
                (
                    if mds[m] then obj.modifiers[m].enabled = True
                )
            )
			
			delete bx
            
            prg.Step()
			GC()
		)
        
        prg.End()
        
        ::mxs.BlockUi False
	),
    
	fn ReplaceWithInstance objArr type:1 =
	(
		if objArr.count != 0 then
		(
            objArr = ::mxs.EnsureArgIsArray objArr
            
            local srcObj = ( pickObject prompt:"**** Pick Source Object ****\n" )
            format "***** srcObj: % *****\n" srcObj
            
            if srcObj == undefined then return format "Pick Object Failed\n" title:"GTVFX:"
            
			undo label:"GTVFX: Replace With Instance" on
			(
                local srcIndex = ( findItem objArr srcObj )
                
				if srcIndex != 0 then
				(
					deleteItem objArr srcIndex
				)
                
				case type of
				(
					1:
					(
                        local arr = #()
                        
                        arr += srcObj
                        
						local iLayer = LayerManager.getLayerFromName srcObj.layer.name
                        
						for obj in objArr do
						(
							local objInst = instance srcObj wireColor:srcObj.wireColor gbufferChannel:srcObj.gbufferchannel transform:obj.transform
							objInst.parent = obj.parent
							iLayer.addNode objInst
							append arr objInst
						)
                        
						delete objArr
						select arr
					)
					2:
					(
						for obj in objArr do
						(
							instanceReplace obj srcObj
						)
					)
				)
			)
		)
	),
    
	fn ReplaceWithReference objArr arr:#() =
	(
        if objArr.count != 0 then
		(
            objArr = ::mxs.EnsureArgIsArray objArr
            
            local srcObj = ( pickObject prompt:"**** Pick Source Object ****\n" )
            format "***** srcObj: % *****\n" srcObj
            
            if srcObj == undefined then return format "Pick Object Failed\n" title:"GTVFX:"
            
			undo label:"GTVFX: Replace With Instance" on
			(                
				local srcIndex = ( findItem objArr srcObj )
                
				if srcIndex != 0 then
				(
					deleteItem objArr srcIndex
				)
                
                for obj in objArr do
                (
                    referenceReplace obj srcObj
                )
            )
        )
	),
    
	mapped fn ConvertToMesh_mapped objArr =
	(
		ConvertToMesh objArr
	),
    
	fn ConvertToMeshWithModifierStack objArr:( GetCurrentSelection() ) = 
	(
		::mxs.BlockUi True
        
        objArr = ::mxs.EnsureArgIsArray objArr
        
		objArr = for obj in objArr where ( superclassof obj.baseobject == geometryClass ) and ( isGroupMember obj == false ) collect obj
            
		for obj in objArr do
		(
			addmodifier obj ( Mesh_Select() ) before:obj.modifiers.count
			maxOps.CollapseNodeTo obj obj.modifiers.count off
			GC()
		)
		
        ::mxs.BlockUi False
        
		select objArr
	),
    
	fn AddSmoothModWithStack objArr collapseToMod:True = 
	(
        ::mxs.BlockUi True
        
        objArr = ::mxs.EnsureArgIsArray objArr
        
		objArr = for obj in objArr where ( superclassof obj.baseobject == geometryClass ) and ( isGroupMember obj == false ) collect obj
            
		for obj in selArray do
		(
			addmodifier obj ( smooth autoSmooth:on ) before:obj.modifiers.count
			if collapseToMod then maxOps.CollapseNodeTo obj obj.modifiers.count off
		)
        
		::mxs.BlockUi False
        
		select objArr
	),
    
    fn EnsureClassOfObj obj targetClass =
    (
        if ( ClassOf Obj.baseObject ) != targetClass then
		(
            if ( CanConvertTo obj targetClass ) then
            (
                ConvertTo obj targetClass
            )
            else
            (
                format "***** EnsureClassOfObj cannot convert % to % *****\n" obj targetClass
                obj = undefined
            )
		)
        
        obj
    ),
    
    fn EnsureEditMesh obj =
	(
        obj = this.EnsureClassOfObj obj Editable_Mesh
	),
    
    fn EnsureEditPoly obj =
    (
        obj = this.EnsureClassOfObj obj Editable_Poly
    ),
    
    fn EnsureEditSpline obj =
    (
        obj = this.EnsureClassOfObj obj Edit_Spline
    ),
	
	fn AttachObjs objArr garbageCollect:false =
	(
		if objArr.count < 2 then
		(
			messagebox "Must have at least 2 objects selected!"
		)
		else
		(
			with undo off
			(
				::mxs.BlockUi True
                
                objArr = ::mxs.EnsureArgIsArray objArr
                
                InstanceMgr.MakeObjectsUnique objArr #individual
                
                local atachTime = ::EventTimer caption:"AttachObjs"
                
                local prg = ::WpfProgressBar caption:"Attaching Objects:" steps:objArr.count
                
                objArr = for obj in objArr where ( this.IsValidMesh obj ) collect obj
                
				while objArr.count > 1 do
				(	
					for i = objArr.count to 2 by -2 do 
					(
						if keyboard.escpressed then
						(
							exit
						)
						
						attach ( this.EnsureEditMesh objArr[i] ) ( this.EnsureEditMesh objArr[i-1] )
						
						deleteItem objArr (i-1)
                        
                        prg.Step()
                        
						if garbageCollect then gc()
					)
				)
                
                prg.End()
                atachTime.End()
                
				select objArr[1]
                
				::mxs.BlockUi False
			)
		)
	),
    
	fn DetachMeshElements sourceObj =
	(
        if not ( this.IsValidMesh sourceObj ) then return ( format "***** % is not a valid mesh *****\n" sourceObj )
        
		::mxs.BlockUi True
        
        sourceObj = this.EnsureEditPoly sourceObj
        
		local faceCount = sourceObj.getnumfaces()
		local faceTest = ((sourceObj.getnumfaces()) != 0)
        
		with undo label:"GTVFX: Detach" on
		(
            local prg = ::WpfProgressBar caption:"Detaching Elements" steps:faceCount
            
			for i in 1 to faceCount while FaceTest do
			(
				if keyboard.escpressed then
				(
					exit
				)
                
				local newName = ( uniquename sourceObj.name )
                
				sourceObj.EditablePoly.SetSelection #Face #{1}
				sourceObj.selectElement()
                
				local targetElement = polyop.GetFaceSelection sourceObj
                
				polyop.detachFaces sourceObj targetElement asNode:true name:newName
                
				local newObj = GetNodeByName newName
                
                this.ResetMesh newObj collapseMods:True 
                
				faceTest = ((sourceObj.getnumfaces()) != 0)
                
                prg.Step()
			)
            
			Delete sourceObj
            prg.End()
		)
        
        ::mxs.BlockUi False
	),
    
	fn DetachSplineElements sourceObj =
	(
        ::mxs.BlockUi True
        
		local splineCount = numsplines sourceObj 	
        
		with undo label:"GTVFX: Detach" on
		(
			local prg = ::WpfProgressBar catption:"Detaching Spline Elements"
            
			for i = 1 to splineCount do
			(
				if keyboard.escpressed then
				(
					exit
				)
                
				local tempMaster = copy sourceObj 
				tempMaster.name = ( sourceObj.name + "_Element_" + ( i as string ) )
                
				select tempMaster 
				setFirstSpline tempMaster i
                
				for x = splineCount to 2 by -1 do DeleteSpline tempMaster x
                
				select sourceObj
				prg.End()
			)
            
			delete sourceObj
			prg.End()
		)
		
        ::mxs.BlockUi False
	),
    
	fn DetachElements objArr =
	(
        objArr = ::mxs.EnsureArgIsArray objArr
        
		if objArr.count != 0 then
		(
			for obj in objArr do with redraw off
			(
				case ( SuperClassOf obj ) of
				(
					(GeometryClass):this.DetachMeshElements obj
					(Shape):this.DetachSplineElements obj
					default:format "***** % is of an unsupoorted object type. *****\n" obj.name
				)
			)
			CompleteRedraw()
		)
		else
        (
            messageBox "Nothing Selected!" title:"GTVFX: :("
        )
	),
    
	fn QuadrifySelection objArr = 
	(
        ::mxs.BlockUi True
        
        objArr = ::mxs.EnsureArgIsArray objArr
        
		for obj in objArr do
		(
            obj = this.EnsureEditPoly obj
            if obj != undefined then
            (
                select obj
                macros.run "PolyTools" "Quadrify"
            )
		)
		select objArr
        
        ::mxs.BlockUi False
	),
    
    fn GetModule =
    (
        ( GetSourceFileName() )
    ),

    fn Help =
    (
        ::mxs.GetScriptHelp ( this.GetModule() )
    ),

private
    
    fn _init =
    (
        -- Pass
    ),

    __init__ = _init()
)


MeshFns = MeshFns()