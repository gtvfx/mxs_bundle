(
	-- 'Inherit' the main tool
	self = ::SceneSanityChecks
	
	fn GetUnresolvedXRefMaterials =
	(
		out = for o in getClassInstances xrefmaterial where o.unresolved and (refs.dependentNodes o).count != 0  collect o
		out
	)
	
	fn SelectObjectsWidthUnreslovedXrefsMaterials =
	(
		objs = getUnresolvedXRefMaterials()
		out = #()
		for o in objs do for a in refs.dependentNodes o do appendifunique out a
		select out
	)
	
	fn CheckUnresolvedXRefMaterials =
	(
		objs = getUnresolvedXRefMaterials()
		if objs.count != 0 then
		(
			self.msgBuffer = "There are "+objs.count as string+"unresolved xref Materials"
			return false
		)
		true
	)
	
	
	-- register the plugin
	self.plugManager.Register title:"Check for unresolved xref materials" method:CheckUnresolvedXRefMaterials aux:#(SelectObjectsWidthUnreslovedXrefsMaterials) active:True description:"Checks for unresolved xref materials"
)
