struct CheckForUnresolvedXrefObjects
(
	agregate,
	
	fn GetUnresovledXRefObjects =
	(
		local objs = for o in GetClassInstances xrefobject where o.unresolved collect o
		objs
	),
	
	fn SelectUnresolvedXRefObjects =
	(
		local out = #()
		
		for i in (this.GetUnresovledXRefObjects()) do
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
	
	fn UpdateMsgBuffer _args:#() _str: =
	(
		if ( this.agregate != undefined ) and ( isProperty this.agregate #msgBuffer ) then 
		(
			free this.agregate.msgBuffer
			_str = this.agregate.msgBuffer
		)
		
		format "There are % unresolved Xref objects\n" _args[1] to:_str
	),
	
	fn CheckUnresolvedXRefObjects =
	(
		objs = getUnresovledXRefObjects()
		if objs.count != 0 then
		(
			this.UpdateMsgBuffer _args:#(objs.count)
			False
		)
		else
		(
			True
		)
	)	
)

_checkForUnresolvedXrefObjects = CheckForUnresolvedXrefObjects()