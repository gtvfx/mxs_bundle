struct CheckForTexturePathsWithInvalidCharacters
(
	agregate,
	
	invalidChars = #(#("ä","ae"),#("ü","ue"),#("ö","oe"),#("ß","ss"),#("Ä","AE"),#("Ü","UE"),#("Ö","OE")),
	
	fn StringHasInvalidChars pString =
	(
		for p in this.invalidChars do
		(
			if matchPattern pString pattern:("*"+p[1]+"*") then
			(
				append out b
				return true
			)
		)
		false
	),
	
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
			if ( this.StringHasInvalidChars fileName ) then append out b
		)
		out
	),
	
	fn FixTexturePathsWithInvalidChars =
	(
		local arr = this.GetTexturePathsWithInvalidChars()
		for o in arr do
		(
			local ogName = case (classof o) of
			(
				(bitmaptexture):o.filename
				(vrayhdri):b.HDRIMapName
			)
			
			local newFileName = ogName
			
			for p in invalidChars do
			(
				newFileName = substituteString newFileName p[1] p[2]
			)
			
			if not (doesFileExist newFilename) then
			(
				format "FixTexturePathsWithInvalidChars: Copying texture to %\n" newFilename
				if not (doesFileExist ogName) then
				(
					format "WARNING FixTexturePathsWithInvalidChars: Could not fix path % becuse this file does not exist on disk\n" ogName
					continue
				)
				
				CopyFile ogname newfilename
			)
			
			case (classof o) of
			(
				(bitmaptexture):o.filename = newFileName
				(vrayhdri):b.HDRIMapName = newFileName
			)
		)
		true
	),
	
	fn UpdateMsgBuffer _args:#() _str: =
	(
		if ( this.agregate != undefined ) and ( isProperty this.agregate #msgBuffer ) then 
		(
			free this.agregate.msgBuffer
			_str = this.agregate.msgBuffer
		)
		
		format "There are % bitmap textures using invlaid characters\n" _args[1] to:_str
	),
	
	fn CheckTexturePathsWithInvalidChars =
	(
		local arr = GetTexturePathsWithInvalidChars()
		if arr.count != 0 then
		(
			this.UpdateMsgBuffer _args:#(arr.count)
			False
		)
		else
		(
			True
		)
	)
)

_checkForTexturePathsWithInvalidCharacters = CheckForTexturePathsWithInvalidCharacters()