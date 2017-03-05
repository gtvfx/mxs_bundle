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



struct cln_FlattenHierarchy
(
public

    aggregate,
    debug = False,
    progBar = undefined,
    objArr,
    
    fn FlattenHierarchy _progressBar:this.progBar _objArr:this.objArr =
    (
        if _objArr == undefined then
        (
            throw "FlattenHierarchy needs an array of objects.\nEither define the 'objArr' Struct parameter\nor use the '_objArr' flag on the method"
        )
        
        if _progressBar != undefined then
        (
            _progressBar.UpdateLabel_Sub ""
            
            _progressBar.Start_Sub _steps:self.allObjects.count
        )
        
        for obj in _objArr do
        (
            if _progressBar != undefined then _progressBar.UpdateLabel_Sub obj.name
            
            obj.parent = undefined
            
            if _progressBar != undefined then _progressBar.Step_Sub()
        )
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





