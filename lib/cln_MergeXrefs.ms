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




struct cln_MergeXrefs
(
public

    aggregate,
    debug = False,
    progBar = undefined,
    objArr,
    
    fn MergeXrefObjects _progressBar:this.progBar _objArr:this.objArr =
    (
        if _objArr == undefined then
        (
            throw "MergeXrefObjects needs an array of objects.\nEither define the 'objArr' Struct parameter\nor use the '_objArr' flag on the method"
        )
        
        format "----- Merge XRef Objects -----\n"
        
        local xObjs = For i in _objArr where (ClassOf i == XrefObject) collect i
        
        if _progressBar != undefined then
        (
            _progressBar.UpdateLabel_Sub ""

            _progressBar.Start_Sub _steps:xObjs.count
        )
        
        if xObjs.count != 0 then
        (
            for obj in xObjs do 
            (
                if _progressBar != undefined then _progressBar.UpdateLabel_Sub obj.name
                
                if obj.useProxy then obj.useProxy = False
                ObjXRefMgr.MergeXRefItemsIntoScene obj.baseObject
                
                if _progressBar != undefined then _progressBar.Step_Sub()
            )
        )
        
        if this.aggregate != undefined and ( isProperty this.aggregate #RefactorObjs ) then this.aggregate.RefactorObjs()
    ),
    
    fn MergeXrefControllers _progressBar:this.progBar =
    (
        format "----- Merge XRef Controllers -----\n"
        local cons = ( GetClassInstances XRef_Controller )
        
        if _progressBar != undefined then
        (
            _progressBar.UpdateLabel_Sub ""

            _progressBar.Start_Sub _steps:cons.count
        )
        
        if cons.count != 0 then
        (
            for con in cons do 
            (
                local conNode = try( ( refs.dependentNodes con )[1] )catch( "" )
                
                if _progressBar != undefined then _progressBar.UpdateLabel_Sub ( ( con as string ) + " | " + ( conNode as string ) )
                
                ObjXRefMgr.MergeXRefItemsIntoScene con
                
                if _progressBar != undefined then _progressBar.Step_Sub()
            )
        )
    ),
    
    fn MergeXrefs _progressBar:self._progressBar =
    (
        this.MergeXrefObjects _progressBar:_progressBar
        this.MergeXrefControllers _progressBar:_progressBar
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


