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
[Purpose]

***************************************************************************************************/
/*
__HELP__

Constructor: CombineMaterials
Instantiated Global: CombineMaterials


Methods:
    Run <objArr> mtlName:""
        - Provide an array of objects to create a MultiMaterial for
        - if a string is passed to mtlName then the new MultiMaterial will have this name otherwise it will be named "CombinedMaterial"

Example:
    CombineMaterials.Run ( GetCurrentSelection() ) mtlName:"New_MulitMat"

__END__
*/


mxs.Using "MxsCommonFns"
mxs.Using "DetachElementsByMatID" -- _detachByMatId


struct CombineMaterials
(
public
    
    debug = False,
    
    fn QsortNodeAphlabetical v1 v2 =
    (
        local v = v1.name
        local vv = v2.name
        case of
        (
            (v < vv): -1
            (v > vv): 1
            default: 0
        )
    ),
    
    fn FilterObjArr objArr =
    (
        local out = for obj in objArr where ( CanConvertTo obj Editable_Poly ) collect obj
        out
    ),
    
    fn ExplodeMultiMat mat arr:#() =
    (
        if ( ClassOf mat ) == MultiMaterial then
        (
            for each in mat.materialList do
            (
                this.ExplodeMultiMat each arr:arr
            )
        )
        else 
        (
            if mat != undefined then appendIfUnique arr mat
        )
        
        arr
    ),
    
    fn CollectUniqueMaterials objArr arr:#() =
    (
        for obj in objArr where ( obj.material != undefined ) do
        (
            this.ExplodeMultiMat obj.material arr:arr
        )
        
        arr
    ),
    
    fn GetSubMatById multiMat id =
    ( -- Returns the material
        local index = ( FindItem multiMat.materialIDList id )
        
        local out = undefined
        
        if index != 0 then
        (
            out = multiMat.materialList[index]
        )
        
        out
    ),

    fn FindMatIndexInMultMat multiMat mat =
    ( -- Returns the index of the mat
        local index = ( FindItem multiMat.materialList mat )
        
        local out = undefined 
        
        if index != 0 then
        (
           out = index
        )
        
        out
    ),
    
    -- Build a new MulitMaterial with newly assigned ID's
    fn BuildMultiMat matArr mtlName:"" =
    (
        -- sort the material array alphabetically, because it's nice to look at ;)
        qsort matArr this.QsortNodeAphlabetical
        
        local out = MultiMaterial name:( if mtlName == "" then "CombineMaterial" else mtlName )
        
        out.count = matArr.count
        out.materialList = matArr
        
        out
    ),
    
    fn Run objArr mtlName:"" = 
    (
        --SetCommandPanelTaskMode #create
        ::mxs.BlockUi True
        
        objArr = this.FilterObjArr objArr
        
        local matArr = this.CollectUniqueMaterials objArr

        local newMat = this.BuildMultiMat matArr mtlName:mtlName

        for obj in objArr do
        (
            if this.debug then format "***** Converting To Poly *****\n"
            --
            ::MxsCommonFns.ConvertBaseObject obj type:#poly
            
            if this.debug then format "***** Disabling Modifiers *****\n"
            --
            local mdsArr = #()
            if obj.modifiers.count != 0 then
            (
                for m = 1 to obj.modifiers.count do 
                (
                    -- Store the enabled state of the modifier
                    mdsArr[m] = obj.modifiers[m].enabled
                    -- Disable the modifier
                    obj.modifiers[m].enabled = False
                )
            )
            
            if this.debug then format "***** Building remapArr *****\n"
            --
            local remapArr = #()
            local idArr = ::_detachByMatId.CollectUniqueFaceIds obj
            local curMat = obj.material
            
            for id in idArr do
            (
                -- Need to collect and store the mesh faces that correspond with the new id
                -- If it's done in-line with getting the newId, there's a potential to overlap the id assignment
                
                local curSubMat = if ( ClassOf curMat ) == MultiMaterial then ( GetSubMatById curMat id ) else curMat
                
                local newId = this.FindMatIndexInMultMat newMat curSubMat
                
                local faceArr = ::_detachByMatId.CollectFacesById obj id
                
                append remapArr #(newId, faceArr)
            )
            
            if this.debug then format "***** Apply remapping *****\n"
            -- Apply the remapping of the id's
            for each in remapArr do
            (
                if this.debug then format "***** each: % *****\n" each
                --
                polyop.SetFaceMatId obj each[2] each[1]
            )
            
            if this.debug then format "***** Apply new Material *****\n"
            --
            obj.material = newMat
            
            if this.debug then format "***** Enable modifiers *****\n"
            --
            for m = 1 to mdsArr.count do
            (
                -- Set the enabled state of the modifier to the stored state
                obj.modifiers[m].enabled = mdsArr[m]
            )
            
            ::MxsCommonFns.ConvertBaseObject obj type:#mesh
        )
        
        ::mxs.BlockUi False
        
        newMat
    ),
    
    fn GetModule =
    (
        ( GetSourceFileName() )
    ),

    fn Help =
    (
        ::mxs.GetScriptHelp ( GetSourceFilename() )
    ),

private

    fn _init =
    (
        -- Pass
    ),

    __init__ = _init()
)

CombineMaterials = CombineMaterials()

