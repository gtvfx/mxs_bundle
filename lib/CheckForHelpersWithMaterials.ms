struct CheckForHelpersWithMaterials
(
	agregate,
	
	fn GetAllPointHelpersWithMaterials =
	(
		local out = #()
		for p in (getClassInstances point) do
		(
			local depNodes = refs.dependentNodes p
			for n in depNodes where (isProperty n #material) and (n.material != undefined) do 
			(
				append out n
			)
		)
		out
	),
	
	fn SelectPointHelpersWithMaterials =
	(
		select (this.GetAllPointHelpersWithMaterials())
	),
	
	fn RemoveAllMaterialsFromPointHelpers =
	(
		local pnts = this.GetAllPointHelpersWithMaterials()
		local pl = plane()
		for p in pnts do
		(
			local bo = copy p
			p.baseobject = copy pl.baseobject
			p.material = undefined
			instanceReplace p bo
			delete bo
		)
		delete pl
		select pnts
		True
	),
	
	fn UpdateMsgBuffer _args:#() _str: =
	(
		if ( this.agregate != undefined ) and ( isProperty this.agregate #msgBuffer ) then 
		(
			free this.agregate.msgBuffer
			_str = this.agregate.msgBuffer
		)
		
		format "There are % points with materials in this scene\n" _args[1] to:_str
	),
	
	fn CheckPointHelpersWithMaterials =
	(
		local pnts = this.GetAllPointHelpersWithMaterials()
		
		if pnts.count != 0 then
		(
			this.UpdateMsgBuffer _args:#(pnts.count)
			False
		)
		else
		(
			True
		)
	)
)

_checkForHelpersWithMaterials = CheckForHelpersWithMaterials()