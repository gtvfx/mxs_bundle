(
	-- 'Inherit' the main tool
	self = ::SceneSanityChecks
	
	fn GetAllUnwrapModifiers =
	(
		uw = getClassInstances unwrap_uvw
		out = uw
		/*
		bm = getClassInstances bitmapTexture
		out = #()
		for b in bm do
		(
			deps = refs.dependents b
			for d in deps where (classof d) == unwrap_uvw and (refs.dependentNodes d).count > 0 do append out d
		)
		 */
		out
	)
	
	fn SelectUnwrapModifierObjects =
	(
		mods = GetAllUnwrapModifiers()
		objs = #()
		for m in mods do for o in refs.dependentNodes m do appendifunique objs o
		select objs
	)
	
	fn CollapseToUnwrapModifiers =
	(
		mods = GetAllUnwrapModifiers()
		for m in mods do
		(
			for o in refs.dependentNodes m do
			(
				while true do
				(
					clean = true
					for i=1 to o.modifiers.count do
					(
						if o.modifiers[i] == m then
						(
							maxOps.collapseNodeTo o i true
							clean = false
							exit
						)
					)
					if clean then exit
				)
			)
		)
	)
	
	fn CheckUnwrapModifers =
	(
		mods = GetAllUnwrapModifiers()
		if mods.count != 0 then
		(
			self.msgBuffer = "There are "+mods.count as string+" unwrap mods with bitmap dependencies"
			return false
		)
		true
	)
	
	
	-- register the plugin
	self.plugManager.Register title:"Check For Unwrap Modifiers" method:CheckUnwrapModifers aux:#(SelectUnwrapModifierObjects,CollapseToUnwrapModifiers) active:True description:"Checks for any unwrap modifiers in the scene"
)
