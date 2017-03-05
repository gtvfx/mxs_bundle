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




struct qc_DMS_ObjectNamesEndingInCON
(
public
    
    super, -- This is a place for a Super Class that is using this class as a plugin
    debug = False,
    
    objArr, -- This is the collection of objects to run on. If left undefined then this will defalut to  ( objects as array )
	
	title = "Check for object names ending in CON",
	description = "Checks that there are no objects with \"CON\" on the end of their names",
	
    
	fn ValidateObjArr objArr = 
	(
		local out = for obj in objArr where ( IsValidNode obj ) collect obj
		out
	),
	
	fn GetObjectsWithNamesEndingInCON objArr:this.objArr =
	(
		objArr = this.ValidateObjArr objArr
		
		local conPattern = "*CON"
		local out = #()
		
		for obj in objArr do
		(
			if ( MatchPattern obj.name pattern:conPattern ) then
			(
				append out obj
			)
		)
		
		out
	),
	
	fn CheckForObjectNamesEndingInCON objArr:this.objArr =
	(		
		local conArr = this.GetObjectsWithNamesEndingInCON objArr:objArr
		
		local msg = StringStream ""
        format "There are % object names with CON\n" conArr.count to:msg
        print ( msg as string )
		
		if conArr.count != 0 then
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
	
	fn RemoveCONfromObjectNames objArr:this.objArr =
	(
		local conArr = this.GetObjectsWithNamesEndingInCON objArr:objArr
		
		for obj in conArr do
		(
			obj.name = ( replace obj.name ( obj.name.count - 2 ) 3 "" )
		)
	),
	
	fn SelectObjectsEndingInCON objArr:this.objArr =
	(
		select ( this.GetObjectsWithNamesEndingInCON objArr:this.objArr )
	),
	
    fn CheckMethod objArr:this.objArr =
    (
        this.CheckForObjectNamesEndingInCON objArr:objArr
    ),
    
    fn FixMethod objArr:this.objArr =
    (
        this.RemoveCONfromObjectNames objArr:objArr
    ),
    
    fn SelectMethod objArr:this.objArr =
    (
        this.SelectObjectsEndingInCON objArr:objArr
    ),
    
    fn Run objArr:this.objArr =
    (
        if not ( this.CheckMethod objArr:objArr ) then
        (
            if ( queryBox "Would you like to automatically remove CON from object names?" title:"?" ) then
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




