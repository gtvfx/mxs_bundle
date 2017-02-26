(
	-- 'Inherit' the main tool
	self = ::SceneSanityChecks
	
	invalidChars = #(#("ä","ae"),#("ü","ue"),#("ö","oe"),#("ß","ss"),#("Ä","AE"),#("Ü","UE"),#("Ö","OE"))
	
	fn StringHasInvalidChars pString =
	(
		for p in invalidChars do
		(
			if matchPattern pString pattern:("*"+p[1]+"*") then
			(
				append out b
				return true
			)
		)
		false
	)
	
	fn GetTexturePathsWithInvalidChars =
	(
		local bmAr = getClassInstances bitmaptexture
		if vrayhdri != undefined then bmAr += getClassInstances vrayhdri
		local out = #()
		
		for b in bmAr do
		(
			local fileName = case (classof b) of
			(
				(bitmaptexture):b.filename
				(vrayhdri):b.HDRIMapName
			)
			if fileName == undefined then continue
			if stringHasInvalidChars fileName then append out b
		)
		
		out
	)
	
	fn FixTexturePathsWithInvalidChars =
	(
		objs = getTexturePathsWithInvalidChars()
		for o in objs do
		(
			ogName = case (classof o) of
			(
				(bitmaptexture):o.filename
				(vrayhdri):b.HDRIMapName
			)
			newFileName = ogName
			for p in invalidChars do
			(
				newFileName = substituteString newFileName p[1] p[2]
			)
			if not (doesFileExist newFilename) then
			(
				format "MSG fixTexturePathsWithInvalidChars: copying copying duplicating texture to %\n" newFilename
				if not (doesFileExist ogName) then
				(
					format "WARNING fixTexturePathsWithInvalidChars:Could not fix path % becuse this file does not exist on disk\n" ogName
					continue
				)
				copyFile ogname newfilename
			)
			case (classof o) of
			(
				(bitmaptexture):o.filename = newFileName
				(vrayhdri):b.HDRIMapName = newFileName
			)
		)
		true
	)
	
	fn CheckTexturePathsWithInvalidChars =
	(
		objs = getTexturePathsWithInvalidChars()
		if objs.count != 0 then
		(
			self.msgBuffer = "There are "+objs.count as string+" bitmap textures using invlaid characters"
			return false
		)
		true
	)
	
	
	-- register the plugin
	self.plugManager.Register title:"Check for texture paths with invalid characters" method:CheckTexturePathsWithInvalidChars aux:#(FixTexturePathsWithInvalidChars) active:True description:"Checks for texture file paths with invalid characters"
)
