struct CheckForUnwrapModifierBitmaps
(
	agregate,
	
	fn GetUnwrapModsWithBitmaps =
	(-- this checks for unwrap mods with referenced bitmaps
		local bmaps = GetClassInstances BitmapTexture
		if VRayHdri != undefined then bmaps += (GetClassInstances VRayHdri)
		local out = #()
		
		for b in unwrapMods do
		(
			local deps = refs.dependents b
			for d in deps where (classof d) == unwrap_uvw and (refs.dependentNodes d).count > 0 do append out d
		)
		
		out
	),
	
	fn SelectUnwrapModifierObjects =
	(
		local mods = this.GetUnwrapModsWithBitmaps()
		local objs = #()
		
		for m in mods do
		(
			for o in refs.dependentNodes m do
			(
				appendifunique objs o
			)
		)
		
		select objs
	),
	
	fn CollapseToUnwrapModifiers =
	(
		local mods = this.GetUnwrapModsWithBitmaps()
		
		for m in mods do
		(
			for o in refs.dependentNodes m do
			(
				while true do
				(
					local clean = true
					for i = 1 to o.modifiers.count do
					(
						if o.modifiers[i] == m then
						(
							maxOps.collapseNodeTo o i true
							clean = False
							exit
						)
					)
					if clean then exit
				)
			)
		)
	),
	
	fn UpdateMsgBuffer _args:#() _str: =
	(
		if ( this.agregate != undefined ) and ( isProperty this.agregate #msgBuffer ) then 
		(
			free this.agregate.msgBuffer
			_str = this.agregate.msgBuffer
		)
		
		format "There are % unwrap mods with bitmap dependencies\n" _args[1] to:_str
	),
	
	fn CheckUnwrapModifers =
	(
		mods = GetUnwrapModsWithBitmaps()
		if mods.count != 0 then
		(
			this.UpdateMsgBuffer _args:#(mods.count)
			False
		)
		else
		(
			True
		)
	)
)

_checkForUnwrapModifierBitmaps = CheckForUnwrapModifierBitmaps()