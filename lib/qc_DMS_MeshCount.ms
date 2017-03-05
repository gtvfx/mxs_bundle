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

Constructor: qc_DMS_MeshCount
Instantiated Global: 

[METHODS]


[DESCRIPTION]


[USAGE]


__END__
*/




struct qc_DMS_MeshCount
(
public
    
    super, -- This is a place for a Super Class that is using this class as a plugin
    debug = False,
    
    objArr, -- This is the collection of objects to run on. If left undefined then this will defalut to  ( objects as array )
	
	title = "Check for too many geom meshes",
	description = "Checks that the geom object count of the asset fits within the set threshold",
	
	meshCountThreshold = 40000,
    
	fn ValidateObjArr objArr = 
	(
		local out = for obj in objArr where ( IsValidNode obj ) collect obj
		out
	),
	
	fn GetGeomObjectCount objArr:this.objArr = 
	(
		objArr = this.ValidateObjArr objArr
		-- Filter to only geometry
		objArr = for obj in objArr where ( SuperClassOf obj == GeometryClass ) collect obj
		
		objArr.count
	),
	
	fn CheckForTooManyGeomObjects objArr:this.objArr =
	(		
		local objCount = this.GetGeomObjectCount objArr:objArr
		
		local msg = StringStream ""
        format "There are % geom objects\n" objCount to:msg
        print ( msg as string )
		
		if objCount > this.meshCountThreshold then
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
	
    fn CheckMethod objArr:this.objArr =
    (
        this.CheckForTooManyGeomObjects objArr:objArr
    ),
    
    fn FixMethod objArr:this.objArr =
    (
        format "***** Method not implemented *****\n"
    ),
    
    fn SelectMethod objArr:this.objArr =
    (
        format "***** Method not implemented *****\n"
    ),
    
    fn Run objArr:this.objArr =
    (
        if not ( this.CheckMethod objArr:objArr ) then
        (
            format "***** Geom Object Threshold Exceeded *****\n"
        )
		else
		(
			format "***** Geom Object Count is Within Threshold *****\n"
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




