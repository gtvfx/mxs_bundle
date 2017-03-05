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





Struct qc_UnwrapModsWithMaps
(
public
    
    aggregate,
    debug = False,
    
    fn GetMapLoaders =
    (
        local out = ( GetClassInstances BitMapTexture )
        if VRayHDRi != undefined then
        (
            out += ( GetClassInstances VRayHDRi )
        )
        out
    ),
    
    fn GetAllUnwrapModifiers =
	(
		local bMaps = this.GetMapLoaders()
        
		local out = #()
		for b in bMaps do
		(
			for d in ( refs.dependents b ) where ( classof d ) == unwrap_uvw and ( refs.dependentNodes d ).count > 0 do append out d
		)
        
		out
	),
	
	fn SelectUnwrapModifierObjects =
	(
		local uDubMods = this.GetAllUnwrapModifiers()
        
		local objs = #()
		for m in uDubMods do for o in refs.dependentNodes m do appendifunique objs o
		select objs
	),
	
	fn CollapseToUnwrapModifiers =
	(
		local uDubMods = this.GetAllUnwrapModifiers()
        
		for m in uDubMods do
		(
			for o in ( refs.dependentNodes m ) do
			(
				while True do
				(
					local clean = True
					for i = 1 to o.modifiers.count do
					(
						if o.modifiers[i] == m then
						(
							maxOps.collapseNodeTo o i True
							clean = False
							exit
						)
					)
					if clean then exit
				)
			)
		)
	),
	
	fn CheckUnwrapModifers =
	(
		local uDubMods = this.GetAllUnwrapModifiers()
        
        local msg = "There are " + ( uDubMods.count as string ) + " unwrap mods with bitmap dependencies"
        format "***** % *****\n" msg
        
        if uDubMods.count != 0 then
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
        if not ( this.CheckUnwrapModifers() ) then
        (
            if ( queryBox "Would you like to collapse unwrap mods with bitmap dependencies?" title:"?" ) then
            (
                this.CollapseToUnwrapModifiers()
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




