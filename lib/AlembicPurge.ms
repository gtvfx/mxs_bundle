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
[Purpose]

***************************************************************************************************/

/*
__HELP__

Constructor: AlembicPurge
		
Properties:
	objectArray: Array of objects that this tool will operate on
		
Methods:
	- Run():
		If instantiated with the objectArray defined then the Run method will be called automatically

Example:
	_alembicPurge = (AlembicPurge objectArray:(objects as array))

	OR: 

	_alembicPurge = AlembicPurge()
	_alembicPurge.objectArray = ( GetCurrentSelection() )
	_alembicPurge.Run()
	
Notes:
	Preserving animation from Alembic caches is something that still needs to be addressed.



__END__
*/



mxs.load "WpfProgressBar"


struct AlembicPurge
(
public
    
	objectArray,
	
	fn ConvertTransformController obj ctrl:PRS =
	(
		obj.transform.controller = ctrl()
	),
	
	fn PurgeAlembicTimeControls =
	(
		if AlembicTimeControl != undefined then
		(
			local arr = GetClassInstances AlembicTimeControl
			if arr.count != 0 then
			(
				for i in arr do
				(
					delete (refs.dependentNodes i)
				)
			)
		)
		else
		(
			format "***** AlembicTimeControl is not a defined class *****\n"
		)
	),

	fn AlembicModifierCheck obj =
	(
		for i in obj.modifiers do
		(
			if ( MatchPattern ( ( ClassOf i ) as string ) pattern:"*Alembic*" ) then
            (
                return True
			)
		)
		
		False
	),
	
	fn AlembicControllerCheck obj =
	(
		if ( MatchPattern (tolower (obj.controller as string)) pattern:"*alembic*" ) then return True
			
		if ( isProperty obj #position ) and ( MatchPattern (tolower (obj.position.controller as string)) pattern:"*alembic*" ) then return True
			
		if ( isProperty obj #rotation ) and ( MatchPattern (tolower (obj.rotation.controller as string)) pattern:"*alembic*" ) then return True
			
		if ( isProperty obj #scale ) and ( MatchPattern (tolower (obj.scale.controller as string)) pattern:"*alembic*" ) then return True
			
		False
	),
	
	fn CollectAlembicObjects objArr:( objects as array ) =
	(
		local out = #()
        
		for obj in objArr do
		(
			if ( this.AlembicModifierCheck obj ) then
			(
				append out obj
			)
			else if ( this.AlembicControllerCheck obj ) then
			(
				append out obj
			)
		)
        
		out
	),

	fn CollapseAlembicObjs objArr =
	(
		if objArr.count != 0 then
		(
            objArr = this.CollectAlembicObjects objArr:objArr
            
			local _objProgress = WpfProgressBar caption:"Purging Alembic Objects:" steps:objArr.count
			_objProgress.Start()
            
            for obj in objArr do with undo off
			(
				_objProgress.UpdateLabel obj.name
				
				if ( this.AlembicModifierCheck obj ) and SuperClassOf obj == GeometryClass then
				(
					if ( CanConvertTo obj Editable_Mesh ) then
					(
						ConvertTo obj Editable_Mesh
					)
				)
				
				if ( this.AlembicControllerCheck obj ) then
				(
					this.ConvertTransformController obj ctrl:PRS
				)
				
				_objProgress.Step()
			)
            
			_objProgress.End()
		)
	),
	
	fn Run =
	(
		if this.objectArray != undefined then
		(
			cui.commandPanelOpen = False
			::mxs.BlockUi True
			
			this.CollapseAlembicObjs this.objectArray
			this.PurgeAlembicTimeControls()
			
			format "***** Alembic Purged *****\n"
			
			while ( ::mxs.BlockUi False ).count != 0 do ::mxs.BlockUi False
			cui.commandPanelOpen = True
		)
        else
        (
            
        )
	),
    
    fn GetModule =
    (
        ( GetSourceFilename() )
    ),
    
    fn Help =
    (
        ::mxs.GetScriptHelp ( GetSourceFilename() )
    ),
	
private
    
    fn _init =
	(
		-- pass
	),
	
	__init__ = _init()
)



/****** EXAMPLE:
_alembicPurge = (AlembicPurge objectArray:(objects as array))

OR:

_alembicPurge = AlembicPurge()
_alembicPurge.objectArray = (GetCurrentSelection())
_alembicPurge.Run()

********/