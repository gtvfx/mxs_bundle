struct CheckForUnresolvedXrefMaterials
(
	agregate,
	
	fn GetUnresolvedXRefMaterials =
	(
		local out = for o in getClassInstances xrefmaterial where o.unresolved and (refs.dependentNodes o).count != 0  collect o
		out
	),
	
	fn SelectObjectsWidthUnreslovedXrefsMaterials =
	(
		local objs = this.GetUnresolvedXRefMaterials()
		local out = #()
		
		for o in objs do
		(
			for a in refs.dependentNodes o do
			(
				appendifunique out a
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
		
		format "There are % unresolved Xref materials\n" _args[1] to:_str
	),
	
	fn CheckUnresolvedXRefMaterials =
	(
		local objs = GetUnresolvedXRefMaterials()
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

_checkForUnresolvedXrefMaterials = CheckForUnresolvedXrefMaterials()