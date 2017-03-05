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


struct qc_IllegalObjectNames
(
public
    
    super,
    debug = False,
    
    objArr, -- This is the collection of objects to run on. If left undefined then this will defalut to  ( objects as array )
	
	title = "Check For Illegal Object Names",
	description = "Checks for object names with illegal characters",
    
    -- regex with legal characters for object names
	rgx = dotnetobject "System.Text.RegularExpressions.Regex" "[a-zA-Z0-9_.]",
	
	fn CollectObjectsWithIllegalChars objArr:this.objArr regex:rgx =
	(
		local out = #()
		
		for obj in objArr do
		(
			-- Collect each character in the object's name as an array
			local nameArr = for i = 1 to obj.name.count collect obj.name[i]
				
			for n in nameArr do
			(
				-- loop through each character and test it against the regex
				if not ( regex.isMatch n ) then
				(
					-- If the test fails then we append the object to the output array
					-- We also exit the loop as soon as we find an illegal character. No need to continue checking the rest if one is found here.
					append out obj
					exit
				)
			)
		)
		
		out
	),
	
	fn SelectObjsWithIllegalNames objArr:this.objArr =
	(
		::pMenu.SelectionMenu ( this.CollectObjectsWithIllegalChars objArr:objArr )
	),
	
	fn AutoFixNames objArr:this.objArr regex:this.rgx =
	(
		local badNameArr = this.CollectObjectsWithIllegalChars objArr:objArr
		
		for obj in badNameArr do
		(
			local nameArr = for i = 1 to obj.name.count collect obj.name[i]
				
			for n in nameArr do
			(
				-- Strip the illegal characters from the object name
				if not ( regex.isMatch n ) then
				(
					obj.name = SubstituteString obj.name n ""
				)
			)
			
			-- Check that the object name doesn't just consist of numbers after stripping the illegal characters
			-- If it does then append "Object_" to the name and ensure the name is unique
			if ( obj.name as integer ) != undefined then
			(
				obj.name = (UniqueName ("Object_" + obj.name))
			)
		)
	),
	
	fn CheckIllegalObjectNames objArr:this.objArr =
	(
		local badNameArr = this.CollectObjectsWithIllegalChars objArr:objArr
        
        local msg = "There are " + ( badNameArr.count as string ) + " objects with illegal names"
        print ( msg as string )
        
        if badNameArr.count != 0 then
        (
            if ( this.super != undefined ) and ( isProperty this.super #msgBuffer ) then
            (
                this.super.msgBuffer = msg
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
        this.CheckIllegalObjectNames objArr:objArr
    ),
    
    fn FixMethod objArr:this.objArr =
    (
        this.AutoFixNames objArr:this.objArr regex:this.rgx
    ),
    
    fn SelectMethod objArr:this.objArr =
    (
        this.SelectObjsWithIllegalNames objArr:objArr
    ),
	
	fn ResetMethod =
	(
		format "***** Reseting Class Values *****\n"
		this.objArr = ( objects as array )
	),
    
    fn Run objArr:this.objArr =
    (
        if not ( this.CheckMethod objArr:objArr ) then
        (
            if ( queryBox "Would you like to fix all illegal object names?" title:"?" ) then
            (
                this.FixMethod objArr:objArr
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
        if this.objArr == undefined then
        (
            this.objArr = ( objects as array )
        )
    ),

    __init__ = _init()
)



