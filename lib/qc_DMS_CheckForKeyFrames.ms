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



struct qc_DMS_CheckForKeyFrames
(
public
    
    super, -- This is a place for a Super Class that is using this class as a plugin
    debug = False,
	quiet = False,
    
    objArr, -- This is the collection of objects to run on. If left undefined then this will defalut to  ( objects as array )
	
	title = "Check for key frames",
	description = "Checks for animation on any objects",
	
    
	fn ValidateObjArr objArr = 
	(
		local out = for obj in objArr where ( IsValidNode obj ) collect obj
		out
	),
	
	fn GetPointCacheObjects objArr:this.objArr =
	(
		local out = #()
		
		for obj in objArr do
		(
			for m in obj.modifiers where ( ClassOf m == Point_Cache ) or ( ClassOf m == Point_CacheSpacewarpModifier ) do append out obj
		)
		
		out
	),
	
	fn GetAnimatedObjects objArr:this.objArr =
	(
		local out = for obj in objArr where ( IsProperty obj #IsAnimated ) and ( obj.IsAnimated == True ) collect obj
		out
	),
	
	fn GetObjectsWithAnimation objArr:this.objArr =
	(
		objArr = this.ValidateObjArr objArr
		
		local out = #()
		
		out += this.GetPointCacheObjects objArr:objArr
		out += this.GetAnimatedObjects objArr:objArr
		
		out
	),
	
	fn CheckForObjectsWithAnimation objArr:this.objArr =
	(		
		local testArr = this.GetObjectsWithAnimation objArr:objArr
		
		local msg = StringStream ""
        format "There are % objects with animation\n" testArr.count to:msg
        print ( msg as string )
		
		if testArr.count != 0 then
        (
            if ( this.super != undefined ) and ( isProperty this.super #msgBuffer ) then
            (
                this.super.msgBuffer = ( msg as string )
            )
            
            False
        )
        else
        (
            True
        )
	),
	
	fn RemoveAnimation objArr:this.objArr =
	(
		deleteKeys ( this.GetAnimatedObjects objArr:objArr ) #allKeys
		
		for obj in ( this.GetPointCacheObjects objArr:objArr ) do
		(
			CollapseStack obj
		)
	),
	
	fn SelectObjectsWithAnimation objArr:this.objArr =
	(
		select ( this.GetObjectsWithAnimation objArr:this.objArr )
	),
	
    fn CheckMethod objArr:this.objArr =
    (
        this.CheckForObjectsWithAnimation objArr:objArr
    ),
    
    fn FixMethod objArr:this.objArr =
    (
		this.RemoveAnimation objArr:objArr
    ),
    
    fn SelectMethod objArr:this.objArr =
    (
        this.SelectObjectsWithAnimation objArr:objArr
    ),
    
    fn Run objArr:this.objArr =
    (
        if not ( this.CheckMethod objArr:objArr ) then
        (
            if ( queryBox "Would you like to automatically center object pivots?" title:"?" ) then
            (
                this.FixMethod()
            )
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
        if this.objArr == undefined then
        (
            this.objArr = ( objects as array )
        )
    ),

    __init__ = _init()
)




