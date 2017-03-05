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


struct qc_DMS_CenterGeomPivots
(
public
    
    super, -- This is a place for a Super Class that is using this class as a plugin
    debug = False,
    
    objArr, -- This is the collection of objects to run on. If left undefined then this will defalut to  ( objects as array )
	
	title = "Check that geometry pivots are centered",
	description = "Checks that the pivot of all geometry objects are centered",
    
	fn ValidateObjArr objArr = 
	(
		local out = for obj in objArr where ( IsValidNode obj ) collect obj
		out
	),
	
	fn FilterObjArrForGeometry objArr =
	(
		objArr = this.ValidateObjArr objArr
		for obj in objArr where ( SuperClassOf obj == GeometryClass ) collect obj
	),
	
	fn GetObjectsWithUncenteredPivots objArr:this.objArr =
	(
		objArr = this.FilterObjArrForGeometry objArr
		
		local out = #()
		
		for obj in objArr do
		(
			if ( ( obj.position as string ) != ( obj.center as string ) ) then
			(
				append out obj
			)
		)
		
		out
	),
	
	fn CheckForObjectsWithUncenteredPivots objArr:this.objArr =
	(		
		local testArr = this.GetObjectsWithUncenteredPivots objArr:objArr
		
		local msg = StringStream ""
        format "There are % object with un-centered pivots\n" testArr.count to:msg
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
	
	fn CenterObjectPivots objArr:this.objArr =
	(
		local testArr = this.GetObjectsWithUncenteredPivots objArr:objArr
		
		for obj in testArr do
		(
			--CenterPivot obj
			--obj.center = obj.position
			obj.pivot = obj.center
		)
	),
	
	fn SelectObjectsWithUncenteredPivots objArr:this.objArr =
	(
		select ( this.GetObjectsWithUncenteredPivots objArr:this.objArr )
	),
	
    fn CheckMethod objArr:this.objArr =
    (
        this.CheckForObjectsWithUncenteredPivots objArr:objArr
    ),
    
    fn FixMethod objArr:this.objArr =
    (
        this.CenterObjectPivots objArr:objArr
    ),
    
    fn SelectMethod objArr:this.objArr =
    (
        this.SelectObjectsWithUncenteredPivots objArr:objArr
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




