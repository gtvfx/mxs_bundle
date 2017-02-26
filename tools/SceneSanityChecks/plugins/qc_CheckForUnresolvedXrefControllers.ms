(
	-- 'Inherit' the main tool
	self = ::SceneSanityChecks
	
	fn GetUnresolvedXrefControllers =
	(
		out = for o in getClassInstances xref_controller where o.unresolved collect o
		out
	)
	
	fn SelectObjectsWithUnresolvedXrefControllers =
	(
		objs = getUnresolvedXrefControllers()
		out = #()
		for o in objs do for a in refs.dependentNodes o do appendifunique out o
		select out
	)
	
	fn CheckUnresolvedXRefControllers =
	(
		objs = getUnresolvedXrefControllers()
		if objs.count != 0 then
		(
			self.msgBuffer = "There are "+objs.count as string+"unresolved xref controllers"
			return false
		)
		true
	)
	
	
	-- register the plugin
	self.plugManager.Register title:"Check for unresolved xref controllers" method:CheckUnresolvedXRefControllers aux:#(SelectObjectsWithUnresolvedXrefControllers) active:True description:"Checks for unresolved xref controllers"
)
