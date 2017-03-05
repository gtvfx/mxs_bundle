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






Struct qc_UnresolvedXrefObjects
(
Public
    
    aggregate,
    debug = False,
    
    fn GetUnresovledXRefObjects =
	(
		local objs = for o in ( GetClassInstances xrefobject ) where o.unresolved collect o
		objs
	),
	
	fn SelectUnresolvedXRefObjects =
	(
		local out = #()
		for i in ( this.GetUnresovledXRefObjects() ) do
		(
			local refsArr = refs.dependentNodes i
			for ref in refsArr do
			(
				if IsValidNode ref then
				(
					append out ref
				)
			)
		)
        
		select out
	),
	
	fn CheckUnresolvedXRefObjects =
	(
		local objs = this.GetUnresovledXRefObjects()
        
        local msg = "There are " + ( objs.count as string ) + " unresolved XRef Objects"
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
        if not ( this.CheckUnresolvedXRefObjects() ) then
        (
            if ( queryBox "Would you like to select Unresolved XRef Objects?" title:"?" ) then
            (
                this.SelectUnresolvedXRefObjects()
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


