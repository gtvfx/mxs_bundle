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



mxs.Using "EventTimer"
mxs.Using "CopyPasteAnimation"


Struct qc_Groups
(
Public
    
	aggregate,
    debug = False,
	
	fn GetAllGroupHeads objArr:( objects as array ) =
	(
		local groupArr = for obj in objArr where ( isGroupHead obj ) collect obj
		groupArr
	),
	
	fn SelectAllGroupHeads objArr:( objects as array ) =
	(
		select ( this.GetAllGroupHeads objArr:objArr )
	),
		
	fn ConvertGroupsToNulls objArr:( objects as array ) =
	(
		local groupConvert = ::EventTimer caption:"Converting groups"
		SetCommandPanelTaskMode #Create
		::_ilmLibrary.BlockUi True
		
		local groupHeadArr = ( this.GetAllGroupHeads objArr:objArr )
			
		for g in groupHeadArr do
		(
			SetGroupOpen g True
			
			local tNull = point transform:g.transform name:g.name cross:False box:True axisTripod:True
			
			if g.parent != undefined then tNull.parent = g.parent
				
			local groupObjArr = for i in g collect i
				
			if g.isAnimated then
			(
				::_CopyPasteAnimation.CopyPasteAnim g tNull
			)
			
			for i in groupObjArr where ( isValidNode i ) and ( i.parent == g ) do i.parent = tNull
		)
		
		delete groupHeadArr
		
		groupConvert.End()
		
		::_ilmLibrary.BlockUi False
		True
	),
	
	fn CheckForGroups objArr:( objects as array ) =
	(
		local arr = this.GetAllGroupHeads objArr:objArr
        
        local msg = "There are "+arr.count as string+" groups in this scene"
        format "***** % *****\n" msg
        
		if arr.count != 0 then
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
    
    fn Run objArr:( objects as array ) =
    (
        if ( this.CheckForGroups objArr:objArr ) then
        (
            if ( queryBox "Would you like to convert all groups to nulls?" title:"?" ) then
            (
                this.ConvertGroupsToNulls objArr:objArr
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
	
Private
    
    fn _init =
	(
		-- Pass
	),

	__init__ = _init()
)


