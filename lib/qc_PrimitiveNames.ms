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


mxs.Using "ProceduralRcMenu"


struct qc_PrimitiveNames
(
public
    
    super, -- This is a place for a Super Class that is using this class as a plugin
    debug = False,
	quiet = False,
    
    objArr, -- This is the collection of objects to run on. If left undefined then this will defalut to  ( objects as array )
	
	title = "Check for default primitive names",
	description = "Checks that the geom object count of the asset fits within the set threshold",
	
	rgx,
	
	primGeoArr = #(Box, Cone, Sphere, Geosphere, Cylinder, Tube, Torus, Pyramid, Teapot, Plane, "Line"),
    primNullArr = #(Dummy, Point),
    
	fn ValidateObjArr objArr = 
	(
		local out = for obj in objArr where ( IsValidNode obj ) collect obj
		out
	),
	
	fn GetRegExpression =
	(
		local str = StringStream ""
		
		format "(" to:str
		
		for item in primGeoArr do
		(
			format "%[0-9]{3}|" item to:str
		)
		
		str = ( str as string )
		str = Replace str str.count 1 ""
		str = str + ")"
		
		if this.debug then format "***** rgx string: % *****\n" str
		
		this.rgx = dotnetobject "System.Text.RegularExpressions.Regex" str
	),
	
	mapped fn CollectObjectsByRegex objArr arr =
	(
		if this.rgx.IsMatch objArr.name then
		(
			append arr objArr
		)
	),
	
	fn GetObjectsWithPrimitiveNames objArr:this.objArr = 
	(
		objArr = this.ValidateObjArr objArr
		
		local arr = #()
		
		this.CollectObjectsByRegex objArr arr
		
		arr
	),
	
	fn CheckForObjectsWithPrimitiveNames objArr:this.objArr =
	(		
		local primObjArr = this.GetObjectsWithPrimitiveNames objArr:objArr
		
		local msg = StringStream ""
        format "There are % objects with primitive names" primObjArr.count to:msg
        print ( msg as string )
		
		if primObjArr.count != 0 then
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
	
	fn SelectObjsWithPrimitiveNames objArr:this.objArr =
	(
		::pMenu.SelectionMenu ( this.GetObjectsWithPrimitiveNames objArr:objArr )
	),
	
    fn CheckMethod objArr:this.objArr =
    (
        this.CheckForObjectsWithPrimitiveNames objArr:objArr
    ),
    
    fn FixMethod objArr:this.objArr =
    (
		if not this.quiet then
		(
			messageBox "There is no Auto-Fix for this test" title:"Not Implemented:"
		)
		else
		(
			format "***** Method not implemented *****\n"
		)
    ),
    
    fn SelectMethod objArr:this.objArr =
    (
        this.SelectObjsWithPrimitiveNames objArr:objArr
    ),
    
    fn Run objArr:this.objArr =
    (
        if not ( this.CheckMethod objArr:objArr ) then
        (
            format "*****  *****\n"
        )
		else
		(
			format "***** *****\n"
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
		
		this.GetRegExpression()
    ),

    __init__ = _init()
)




