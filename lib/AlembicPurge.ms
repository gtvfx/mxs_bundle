/*
__MXSDOC__

[TITLE]
AlembicPurge

[DESCRIPTION]
The goal of this class is to convert all Alembic class objects and contrillers to native Max ones

[USAGE]

[CREATION INFO]
Author: Gavyn Thompson
E-mail: gthompson@ilm.com
Company: Industrial Light and Magic
Date created: 10/01/2015
Last Updated: 10/01/2015

[KEYWORDS]

[VERSION HISTORY]

[SEE ALSO]

__END__
*/

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
	_alembicPurge.objectArray = (GetCurrentSelection())
	_alembicPurge.Run()
	
Notes:
	Preserving animation from Alembic caches is something that still needs to be addressed.



__END__
*/



_ilmLibrary.load "WpfProgressBar"

::AlembicPurge

struct AlembicPurge
(
	objectArray,
	
	fn ConvertTransformController obj ctrl:PRS =
	(
		obj.transform.controller = ctrl()
	),
	
	fn PurgeAlembicTimeControls =
	(
		if AlembicTimeControl != undefined then
		(
			arr = GetClassInstances AlembicTimeControl
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
			if MatchPattern ((ClassOf i) as string) pattern:"*alembic*" then return True
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
	
	fn CollectAlembicObjects objArr:(Objects as array) =
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
			_objProgress = WpfProgressBar caption:"Purging Alembic Objects:" steps:objArr.count
			_objProgress.Start()
			for obj in objArr do
			(
				_objProgress.UpdateLabel obj.name
				
				if (this.AlembicModifierCheck obj) and SuperClassOf obj == GeometryClass then
				(
					if (CanConvertTo obj Editable_Mesh) then
					(
						ConvertTo obj Editable_Mesh
					)
				)
				
				if (this.AlembicControllerCheck obj) then
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
			_ilmLibrary.BlockUi True
			
			this.CollapseAlembicObjs this.objectArray
			this.PurgeAlembicTimeControls()
			
			format "***** Alembic Purged *****\n"
			
			while (_ilmLibrary.BlockUi False).count != 0 do _ilmLibrary.BlockUi False
		)
	),
    
    fn GetModule =
    (
        ( GetThisScriptFileName() )
    ),
    
    fn Help =
    (
        ::_ilmLibrary.GetScriptHelp ( this.GetModule() )
    ),
	
	fn ClassUsage =
	(
		format "
---------------
CLASS USAGE:

Constructor = AlembicPurge
		
Properties:
	objectArray: Array of objects that this tool will operate on
		
Methods:
	- Run():
		If instantiated with the objectArray defined then the Run method will be called automatically

Example:
	_alembicPurge = (AlembicPurge objectArray:(objects as array))

	OR:

	_alembicPurge = AlembicPurge()
	_alembicPurge.objectArray = (GetCurrentSelection())
	_alembicPurge.Run()
	
Notes:
	Preserving animation from Alembic caches is something that still needs to be addressed.

---------------\n"
	),
	
	private fn _init =
	(
		this.Run()
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