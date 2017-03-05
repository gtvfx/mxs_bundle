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



struct qc_HelpersWithMaterials
(
public
    
    aggregate,
    debug = False,
    helperClasses = ( helpers as array ), --#(Point, Dummy),
    
    fn GetAllHelpersWithMaterials =
	(
		local out = #()
        
        for h in helperClasses do
        (
            local depNodes = refs.dependentNodes h
            for n in depNodes where ( isProperty n #material ) and ( n.material != undefined ) do
            (
                appendIfUnique out n
            )
        )
        
		out
	),
    
	fn SelectHelpersWithMaterials =
	(
		select ( this.GetAllHelpersWithMaterials() )
	),
    
	fn RemoveAllMaterialsFromHelpers =
	(
		local helperArr = this.GetAllHelpersWithMaterials()
		local pl = Plane()
        
		for h in helperArr do
		(
			local base = copy h
			h.baseobject = copy pl.baseobject
			h.material = undefined
			instanceReplace h base
			delete base
		)
        
		delete pl
	),
    
	fn CheckHelpersWithMaterials =
	(
		local helperArr = this.GetAllHelpersWithMaterials()
        
        local msg = "There are " + ( helperArr.count as string ) + " helpers with materials in this scene"
        format "***** % *****\n" msg
        
        if helperArr.count != 0 then
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
        if not ( this.CheckHelpersWithMaterials() ) then
        (
            if ( queryBox "Would you like to remove all materials from Helpers?" title:"?" ) then
            (
                this.RemoveAllMaterialsFromHelpers()
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
        -- Pass
    ),

    __init__ = _init()
)




