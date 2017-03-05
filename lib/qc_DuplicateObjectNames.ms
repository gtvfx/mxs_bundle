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
Class to find objects in the scene with identical names.

Methods to programatically create a popUp menu to display names of duplicates and selct the objects with those names
and also to automatically rename offending objects with the 'unqueName' method builtin to Maxscript.

[USAGE]


__END__
*/



mxs.Using "ProceduralRcMenu"


struct qc_DuplicateObjectNames
(
public
    
    super, -- This is a place for a Super Class that is using this class as a plugin
    debug = False,
    
    objArr, -- This is the collection of objects to run on. If left undefined then this will defalut to  ( objects as array )
	
	title = "Check For Duplicate Object Names",
	description = "Checks for objects with identical names",
    
    -- regex with legal characters for object names
	rgx = dotnetobject "System.Text.RegularExpressions.Regex" "[a-zA-Z0-9_.]",
	
	fn ValidateObjArr objArr = 
	(
		local out = for obj in objArr where ( IsValidNode obj ) collect obj
		out
	),
	
	fn GetDuplicateNames objArr:this.objArr = 
	(
		objArr = this.ValidateObjArr objArr
		
		local nameArr = #()
		local dupNameArr = #()
		
		for obj in objArr do
		(
			local indx = ( FindItem nameArr obj.name )
			case indx of
			(
				(0):
				(
					append nameArr obj.name
				)
				default:
				(
					appendIfUnique dupNameArr obj.name
				)
			)
		)
		
		dupNameArr
	),
	
	fn SelectDuplicateNames objArr:this.objArr =
	(
		/* 
		This programatically creates a pop-up menu with the names of all objects containing illegal characters
		
		This code concatenates a string that makes up the code for an rcmenu with a unique item for each object.
		 */
		
		local dupNameArr = this.GetDuplicateNames objArr:objArr
		
		local rcTxt = "rcmenu pop_m\n(\n%\n%)\n"
		local st = stringStream ""
		local items = ""
		local events = ""
		
		for d in dupNameArr do
		(
			local itemStr = stringStream ""
			local mItem = stringStream ""
			local mEvent = stringStream ""
			local itemName = (::pMenu.ValidateMenuItemName d)
			
			format "\tmenuItem %_item \"%\"\n" (itemName as string) d to:mItem
			format "\ton %_item picked do (select (GetNodeByName (\"%\") all:True))\n" itemName d to:mEvent
			format "%\n" ( mItem as string ) to:itemStr
			
			items += itemStr as string 
			events += mEvent as string
			----
		)
		
		format rcTxt items events to:st
		
        if this.debug then
        (
            format "===== PopUp Menu Code =====\n"
            format "%" (st as string)
        )
		
		local m = execute (st as string)
		popUpMenu m pos:mouse.screenPos
	),
	
	fn AutoUniqueNames objArr:this.objArr =
	(
		objArr = this.ValidateObjArr objArr
		
		local dupNameArr = this.GetDuplicateNames objArr:objArr
		
		for d in dupNameArr do
		(
			local nArr = ( GetNodeByName d all:True )
            
			if nArr.count > 1 then
			(
				for n in nArr do
				(
                    if ( FindItem objArr n ) != 0 then
                    (
                        n.name = UniqueName n.name
                    )
				)
			)
		)
	),
	
	fn CheckDuplicateNames objArr:this.objArr =
	(
		objArr = this.ValidateObjArr objArr
		
		local dupNameArr = this.GetDuplicateNames objArr:objArr
        
        local msg = StringStream ""
        format "There are % duplicate names" dupNameArr.count to:msg
        print ( msg as string )
        
        if dupNameArr.count != 0 then
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
        this.CheckDuplicateNames objArr:objArr
    ),
    
    fn FixMethod objArr:this.objArr =
    (
        this.AutoUniqueNames objArr:objArr
    ),
    
    fn SelectMethod objArr:this.objArr =
    (
        this.SelectDuplicateNames objArr:objArr
    ),
    
    fn Run objArr:this.objArr =
    (
        if not ( this.CheckMethod objArr:objArr ) then
        (
            if ( queryBox "Would you like to automatically rename objects with duplicate names?" title:"?" ) then
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




