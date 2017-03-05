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




struct cln_RemoveAnimationLayers
(
public

    aggregate,
    debug = False,
    progBar = undefined,
    objArr,
    classList = #(
                        Float_Layer, 
                        Point3_Layer, 
                        Point4_Layer,
                        Position_Layer,
                        Rotation_Layer,
                        Scale_Layer
                    ),
    
    fn RemoveAnimLayers _progressBar:this.progBar =
    ( -- remove all layer controller types from the scene if possible...
        local origAnimLayerCount = AnimLayerManager.GetLayerCount()
        if origAnimLayerCount == 0 then return True
        
        /* 
        for c in this.classList do 
        (
            local inst = ( GetClassInstances c asTrackViewPick:True )
            
            if inst.count == 0 then continue
                
            for b in inst do
            (
                for s = 1 to b.client.numsubs do
                (
                    if b.client[s] == b.anim then
                    (
                        b.client[s].value = undefined
                        exit
                    )
                )
            )
        )
        */
        
        local animLayerCount = origAnimLayerCount
        
        if _progressBar != undefined then
        (
            _progressBar.UpdateLabel_Sub ""
            
            _progressBar.Start_Sub _steps:animLayerCount
        )
        
        while true do
        (
            for t = 1 to animLayerCount do
            (
                try( AnimLayerManager.DeleteLayer t )catch()
            )
            
            local newLayerCount = AnimLayerManager.GetLayerCount()
            
            if _progressBar != undefined then _progressBar.Step_Sub()
            
            if newLayerCount == 1 then exit
                
            animLayerCount = newLayerCount
        )
        
        format "***** Removed % animation layers *****\n" ( origAnimLayerCount - animLayerCount )
    ),
    
    fn Run =
    (
        this.RemoveAnimLayers _progressBar:this.progBar
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


