(
	-- 'Inherit' the main tool
	self = ::SceneSanityChecks
	
	fn GetMissingBitmapTextures =
	(
		local bmaps = getclassinstances bitmaptexture asTrackViewPick:on
		local arr = for b in bmaps where b.anim.filename != undefined and not (doesFileExist b.anim.filename) collect b
		arr
	)
	
	fn Warning =
	(
		messageBox "This will only remove bitmap loaders that are attached to your scene, but not linked to a material
		
There may still be Bitmap loaders in the scene that are assigned to a material, but the referenced filename doesn't exist" title:"Warning"
	)
	
	fn RemoveRogueBitmaps bmaps:(GetMissingBitmapTextures()) =
	(
		Warning()
		MatEditor.Close() 
		for b in bmaps do
		(
			for s = 1 to b.client.numsubs do
			(
				if b.client[s] == b.anim then
				(
					b.client[s].value = undefined
					exit
				)
			)
		)
		GC()
		True
	)
	
	fn CheckMissingBitmapTextures =
	(
		local bmaps = GetMissingBitmapTextures()
		if bmaps.count != 0 then
		(
			self.msgBuffer = "There are "+ bmaps.count as string + " missing bitmaps in your scene"
			return False
		)
		
		True
	)
	
	
	-- Register the plugin
	self.plugManager.Register title:"Check For Missing BitmapTextures files" method:CheckMissingBitmapTextures aux:#(RemoveRogueBitmaps) active:True description:"Checks for BitmapTextures referencing files that do not exist"
)
