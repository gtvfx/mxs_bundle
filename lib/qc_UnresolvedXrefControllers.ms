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




Struct qc_UnresolvedXrefControllers
(
Public
    
    aggregate,
    debug = False,
    
    fn GetUnresolvedXrefControllers =
	(
		local out = for i in ( GetClassInstances xref_controller ) where i.unresolved collect i
		out
	),
	
	fn SelectObjectsWithUnresolvedXrefControllers =
	(
		local objs = this.GetUnresolvedXrefControllers()
		local out = #()
		for o in objs do ( for a in ( refs.dependentNodes o ) do ( appendifunique out o ) )
		select out
	),
	
	fn CheckUnresolvedXRefControllers =
	(
		local objs = this.GetUnresolvedXrefControllers()
        
        local msg = "There are " + ( objs.count as string ) + " unresolved xref controllers"
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
        if not ( this.CheckUnresolvedXRefControllers() ) then
        (
            if ( queryBox "Would you like to select objects with Unresolved XRef Controllers?" title:"?" ) then
            (
                this.SelectObjectsWithUnresolvedXrefControllers()
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

Private
    
    fn _init =
    (
        -- Pass
    ),

    __init__ = _init()
)



