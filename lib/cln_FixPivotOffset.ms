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



struct cln_FixPivotOffset
(
public

    aggregate,
    debug = False,
    progBar = undefined,
    objArr,
    
    fn FixPivotOffsets _progressBar:this.progBar objArr:this.objArr =
    ( -- Fixes pivot offsets that can skew the position of objects when exporting to external packages or using animation constraints
        
        if _progressBar != undefined then
        (
            _progressBar.UpdateLabel_Sub ""
            
            _progressBar.Start_Sub _steps:objArr.count
        )
        
        for obj in objArr do
        (
            --local obj = self.testObjects[i]
            
            if _progressBar != undefined then _progressBar.UpdateLabel_Sub obj.name
            
            local Ops = obj.objectOffsetPos
            local Ort = obj.objectOffsetRot
            local Osc = obj.objectOffsetScale
            
            local st = (Ops as string) + (Ort as string) + (Osc as string)
            
            if st != "[0,0,0](quat 0 0 0 1)[1,1,1]" then
            (
                local xmod = xform()
                
                case obj.modifiers.count of
                (
                    (0):addmodifier obj xmod
                    default:addmodifier obj xmod before:obj.modifiers.count
                )
                
                local rotM = Ort as matrix3
                
                local mat = matrix3 ( rotM[1]*Osc[1] ) ( rotM[2]*Osc[2] ) ( rotM[3]*Osc[3] ) Ops
                
                xmod.gizmo.transform = mat
                
                obj.objectOffsetPos = [0,0,0]
                obj.objectOffsetRot = quat 0 0 0 1
                obj.objectOffsetScale = [1,1,1]
                
               -- This method is known to shift the Gizmo of UVW Modifiers. :(
                maxOps.collapseNodeTo obj ( Finditem obj.modifiers xmod ) True
            )
            
            if _progressBar != undefined then _progressBar.Step_Sub()
        )
        
        if ( this.aggregate != undefined ) and ( IsProperty this.aggregate #RefactorObjs ) then this.aggregate.RefactorObjs()
    ),
    
    fn Run objArr:this.objArr =
    (
        this.FixPivotOffsets objArr:objArr
    ),

private
    
    fn _init =
    (
        if this.aggregate != undefined and ( isProperty this.aggregate #_progressBar ) then 
        (
            this.progBar = this.aggregate._progressBar
        )
    ),

    __init__ = _init()
)


