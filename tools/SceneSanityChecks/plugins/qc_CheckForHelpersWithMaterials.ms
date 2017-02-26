(
	-- 'Inherit' the main tool
	self = ::SceneSanityChecks
	
	fn GetAllPointHelpersWithMaterials =
	(
		out = #()
		for p in (getClassInstances point) do
		(
			depNodes = refs.dependentNodes p
			out = for n in depNodes where (isProperty n #material) and (n.material != undefined) collect n
		)
		out
	)
	fn SelectPointHelpersWithMaterials =
	(
		select (GetAllPointHelpersWithMaterials())
	)
	fn RemoveAllMaterialsFromPointHelpers =
	(
		pnts = GetAllPointHelpersWithMaterials()
		pl = plane()
		for p in pnts do
		(
			bo = copy p
			p.baseobject = copy pl.baseobject
			p.material =  undefined
			instanceReplace p bo
			delete bo
		)
		delete pl
		select pnts
		true
	)
	fn CheckPointHelpersWithMaterials =
	(
		pnts = GetAllPointHelpersWithMaterials()
		if pnts.count != 0 then
		(
			self.msgBuffer = "There are "+pnts.count as string+" points with materials in this scene"
			return false
		)
		true
	)
	
	-- register the plugin
	self.plugManager.Register title:"Check Helpers with materials" method:CheckPointHelpersWithMaterials aux:#(SelectPointHelpersWithMaterials,RemoveAllMaterialsFromPointHelpers) active:True description:"Checks for helper objects with materials applied"
)

