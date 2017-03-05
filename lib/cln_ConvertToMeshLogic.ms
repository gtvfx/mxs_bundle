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

Constructor: 
Instantiated Global: 

Methods:



__END__
*/




struct 
(
public

    aggregate,
    debug = False,
    progBar = undefined,
    objArr,
    
    fn ConvertToEditableMesh _progressBar:this.progBar objArr:this.objArr =
    ( -- Converts objects to editable_mesh
        
        if _progressBar != undefined then
        (
            _progressBar.UpdateLabel_Sub ""

            _progressBar.Start_Sub _steps:objArr.count
        )
        
        for obj in objArr do
        (
            if _progressBar != undefined then _progressBar.UpdateLabel_Sub obj.name
            
            if ( ClassOf obj.baseObject ) == Editable_Mesh or not ( CanConvertTo obj Editable_Mesh ) then 
            (
                if this.debug then format "skipping % (%) it's not elgible for be collapse to editbale mesh\n" obj ( classof obj.baseObject )
                continue
            )
            
            if this.debug then format "attempitng to collapse % (%) to editable mesh\n" obj (classof obj.baseobject)
            
            if ( obj.modifiers.count == 0 ) then
            (
                ConvertToMesh obj
            )
            else
            (
                local mods = for m in obj.modifiers collect m
                for i = 1 to obj.modifiers.count do DeleteModifier obj 1
                    
                ConvertToMesh obj
                
                for i = 1 to mods.count do
                (
                    local m = mods[mods.count-(i-1)]
                    if ( ValidModifier obj m ) then
                    (
                        AddModifier obj m
                    )
                    else
                    (
                        format "***** % is no longer a valid modifer for obj: % *****\n" m obj.name
                    )
                )
            )
            
            if _progressBar != undefined then _progressBar.Step_Sub()
        )
    ),

private
    
    fn _init =
    (
        -- Pass
    ),

    __init__ = _init()
)

