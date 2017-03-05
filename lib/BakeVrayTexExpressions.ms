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

Constructor: BakeVRayTexExpressions
Instantiated Global: BakeVRayTexExpressions

Methods:


__END__
*/

mxs.Using "HashTableMethods"
mxs.Using "UserProps"

struct BakeVRayTexExpressions
(
private
    
    debug = False,
    objectArray,
	    
    fn GetMapLoaderByFileNamePattern loaderArr pattern =
    (
        local vArr = for i in loaderArr where classOf i == VRayHDRi and ( matchPattern i.HDRiMapName pattern:pattern ) collect i
		local bArr = for i in loaderArr where classOf i == BitmapTexture and ( matchPattern i.filename pattern:pattern ) collect i
		local out = ( vArr + bArr )
		out
    ),
    
    fn CollectObjsFromNameArr nameArr = 
    (
        local out = #()
        for n in nameArr do
        (
            append out ( GetNodeByName n )
        )
        out
    ),
    
    fn Bake obj =
    (
        if obj.material == undefined then
        (
            format "---------- % has no material and is being skipped ----------\n" obj.name
            return undefined
        )
        
        local objPropsDic = ::_userProps.UserPropBufferToDictionary obj
        
        if this.debug then format "***** objPropsDic: % *****\n" objPropsDic
        
        local mapVariables = ::_hash.GetDicKeys objPropsDic
        
        if this.debug then format "***** mapVariables: % *****\n" mapVariables
        
        local newMat = copy obj.material
        newMat.name = ( newMat.name + "_" + ( ( GetHashValue obj.name 0 ) as string ) )
        
        if this.debug then format "***** newMat name: % *****\n" newMat.name
        
        local matMapsArr = ( GetClassInstances VRayHDRi target:newMat )
        
        if this.debug then format "***** matMapsArr: % *****\n" matMapsArr
        
        for var in mapVariables do
        (
            if this.debug then format "***** var: % *****\n" var
            
            local varPattern = ("*<"+var+">*")
            
            if this.debug then format "***** varPattern: % *****\n" varPattern
            
            local trgtMapArr = ( this.GetMapLoaderByFileNamePattern matMapsArr varPattern )
            
            if this.debug then format "***** trgtMapArr: % *****\n" trgtMapArr
            
            if trgtMapArr.count != 0 then
            (
                for map in trgtMapArr do
                (
                    if this.debug then format "***** map: % *****\n" map
                    
                    local mapName = map.HdriMapName
                    
                    if this.debug then format "***** mapName: % *****\n" mapName
                    
                    local newMapName = ( SubstituteString mapName ("<"+var+">") objPropsDic.item[var] )
                    
                    if this.debug then format "***** newMapName: % *****\n" newMapName
                    
                    map.HdriMapName = newMapName
                )
            )
        )
        
        obj.material = newMat
        newMat
    ),
    
    fn FilterObjectArray objArr =
    (
        for obj in objArr where obj.material != undefined collect obj
    ),
    
    fn Run =
    (
        if this.objectArray == undefined then
        (
            messageBox "Supply an array of objects to the 'objectArray' parameter" title:"Property Undefined:"
            return Undefined
        )
        
        this.objectArray = this.FilterObjectArray this.objectArray
        
        if this.objectArray.count != 0 then
        (
            local matGroupDic = ::_userProps.SortObjectsByUserPropBuffer this.objectArray
            
            local uniqueGroupArr = ::_hash.GetDicKeys matGroupDic
            
            for item in uniqueGroupArr do
            (
                if item == "" then continue
                
                local itemObjArr = this.CollectObjsFromNameArr matGroupDic.item[item]
                
                if itemObjArr == undefined then continue
                    
                if this.debug then format "***** itemObjArr: % *****\n" itemObjArr
                
                local itemMat = this.Bake itemObjArr[1]
                
                if this.debug then format "***** itemMat: % *****\n" itemMat
                
                for obj in itemObjArr do
                (
                    obj.material = itemMat
                )
            )
        )
        else
        (
            messageBox "The 'objectArray' property needs to be assigned an array of objects to operate on" title:"Missing Property:"
        )
    ),
    
    fn GetModule =
    (
        ( GetSourceFileName() )
    ),
    
    fn Help =
    (
        ::mxs.GetScriptHelp ( GetSourceFileName() )
    ),
	
private 
    
    fn _init =
	(
		-- Pass
	),
	
	__init__ = _init()
)


BakeVRayTexVariables = BakeVRayTexVariables objectArray:( GetCurrentSelection() )

BakeVRayTexVariables.Run()