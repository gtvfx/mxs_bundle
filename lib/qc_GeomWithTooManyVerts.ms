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




struct qc_DMS_GeomWithTooManyVerts
(
public
    
    super, -- This is a place for a Super Class that is using this class as a plugin
    debug = False,
	quiet = False,
    
    objArr, -- This is the collection of objects to run on. If left undefined then this will defalut to  ( objects as array )
	
	title = "Check meshes with too many verts",
	description = "Checks for mesh objects with more than one million verts",
	
	vertThreshold = 1000000, -- one million
    
	fn ValidateObjArr objArr = 
	(
		local out = for obj in objArr where ( IsValidNode obj ) collect obj
		out
	),
	
	fn GetObjectsWithTooManyVerts objArr:this.objArr =
	(
		objArr = this.ValidateObjArr objArr
		
		local out = #()
		
		for obj in objArr do
		(
			if ( IsProperty obj #mesh ) and ( obj.mesh.numFaces >= this.vertThreshold ) then
			(
				append out obj
			)
		)
		
		out
	),
	
	fn CheckForObjectsWithTooManyVerts objArr:this.objArr =
	(		
		local testArr = this.GetObjectsWithTooManyVerts objArr:objArr
		
		local msg = StringStream ""
        format "There are % object names with CON\n" testArr.count to:msg
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
	
	fn SelectObjectsWithTooManyVerts objArr:this.objArr =
	(
		select ( this.GetObjectsWithTooManyVerts objArr:this.objArr )
	),
	
    fn CheckMethod objArr:this.objArr =
    (
        this.CheckForObjectsWithTooManyVerts objArr:objArr
    ),
    
    fn FixMethod objArr:this.objArr =
    (
        local msg = "There is no auto-fix for this test"
		msg +=  "\n
All mesh oids should have a vertex count of less than
1 000 000.  Single meshes with more than 1 million verts
can cause inefficiencies in the pipeline.

It is recommended that you break this mesh up into multiple
meshes if possible."
		
		if not this.quiet then
		(
			messageBox msg title:"Message:"
		)
		else
		(
			format "********************\n%\n********************\n\n" msg
		)
    ),
    
    fn SelectMethod objArr:this.objArr =
    (
        this.SelectObjectsWithTooManyVerts objArr:objArr
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




