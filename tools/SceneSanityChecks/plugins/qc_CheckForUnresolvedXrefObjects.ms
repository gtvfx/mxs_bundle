(
	-- 'Inherit' the main tool
	self = ::SceneSanityChecks
	
	fn GetUnresovledXRefObjects =
	(
		objs = for o in getClassInstances xrefobject where o.unresolved collect o
		objs
	)
	
	fn SelectUnresolvedXRefObjects =
	(
		out = #()
		for i in (GetUnresovledXRefObjects()) do
		(
			refsArr = refs.dependentNodes i
			for ref in refsArr do
			(
				if IsValidNode ref then
				(
					append out ref
				)
			)
		)
		select out
	)
	
	fn CheckUnresolvedXRefObjects =
	(
		objs = getUnresovledXRefObjects()
		if objs.count != 0 then
		(
			self.msgBuffer = "There are "+objs.count as string+"unresolved xref objects"
			return false
		)
		true
	)
	
	
	
	self.plugManager.Register title:"Check for unresolved xrefs" method:CheckUnresolvedXRefObjects aux:#(SelectUnresolvedXRefObjects) active:True description:"Checks for unresolved xrefs"
)
