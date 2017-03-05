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






struct qc_UnresolvedXrefMaterials
(
public
    
    aggregate,
    debug = False,
    
    fn GetUnresolvedXRefMaterials =
	(
		local out = for o in ( GetClassInstances xrefmaterial ) where o.unresolved and ( refs.dependentNodes o ).count != 0  collect o
		out
	),
	
	fn SelectObjectsWithUnreslovedXrefMaterials =
	(
		local objs = this.GetUnresolvedXRefMaterials()
		local out = #()
		for o in objs do ( for a in ( refs.dependentNodes o ) do ( appendifunique out a ) )
		select out
	),
	
	fn CheckUnresolvedXRefMaterials =
	(
		local objs = this.GetUnresolvedXRefMaterials()
        
        local msg = "There are " + ( objs.count as string ) + " unresolved xref Materials"
        format "***** % *****\n" msg
        
        if objs.count != 0 then
        (
            if ( this.aggregate != undefined ) and ( isProperty this.aggregate #msgBuffer ) then
            (
                this.aggregate.msgBuffer = msg
            )
            
            False
        )
        else
        (
            True
        )
	),
    
    fn Run =
    (
        if not ( this.CheckUnresolvedXRefMaterials() ) then
        (
            if ( queryBox "Would you like to select objects with Unresolved XRef Materials?" title:"?" ) then
            (
                this.SelectObjectsWidthUnreslovedXrefMaterials()
            )
        )
        else
        (
            OK
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
        -- Pass
    ),

    __init__ = _init()
)
