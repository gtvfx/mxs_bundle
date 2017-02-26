struct CheckForUnresolvedXrefControllers
(
	agregate,
	
	fn GetUnresolvedXrefControllers =
	(
		local out = for o in getClassInstances xref_controller where o.unresolved collect o
		out
	),
	
	fn SelectObjectsWithUnresolvedXrefControllers =
	(
		local objs = this.GetUnresolvedXrefControllers()
		local out = #()
		
		for o in objs do
		(
			for a in refs.dependentNodes o do
			(
				appendifunique out o
			)
		)
		
		select out
	),
	
	fn UpdateMsgBuffer _args:#() _str: =
	(
		if ( this.agregate != undefined ) and ( isProperty this.agregate #msgBuffer ) then 
		(
			free this.agregate.msgBuffer
			_str = this.agregate.msgBuffer
		)
		
		format "There are % unresolved xref controllers\n" _args[1] to:_str
	),
	
	fn CheckUnresolvedXRefControllers =
	(
		local objs = this.GetUnresolvedXrefControllers()
		
		if objs.count != 0 then
		(
			this.UpdateMsgBuffer _args:#(objs.count)
			
			False
		)
		else
		(
			True
		)
	),
	
	fn Run =
	(
		True
	)
)


_checkForUnresolvedXrefControllers = CheckForUnresolvedXrefControllers()