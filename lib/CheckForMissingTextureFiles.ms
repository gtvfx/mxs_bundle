struct CheckForMissingTextureFiles
(
	agregate,
	
	fn GetMissingBitmapTextures =
	(
		local bmaps = GetClassInstances bitmaptexture asTrackViewPick:on
		if VRayHdri != undefined then (bmaps += (GetClassInstances VRayHdri asTrackViewPick:on))
		local arr = for b in bmaps where b.anim.filename != undefined and not (doesFileExist b.anim.filename) collect b
		arr
	),
	
	fn Warning =
	(
		messageBox "This will only remove bitmap loaders that are attached to your scene, but not linked to a material
		
There may still be Bitmap loaders in the scene that are assigned to a material, but the referenced filename doesn't exist" title:"Warning"
	),
	
	fn RemoveRogueBitmaps _bmaps: =
	(
		if _bmaps == unsupplied then
		(
			_bmaps = ( this.GetMissingBitmapTextures() )
		)
		
		this.Warning()
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
		
		GC quiet:True
		True
	),
	
	fn UpdateMsgBuffer _args:#() _str: =
	(
		if ( this.agregate != undefined ) and ( isProperty this.agregate #msgBuffer ) then 
		(
			free this.agregate.msgBuffer
			_str = this.agregate.msgBuffer
		)
		
		format "There are % missing bitmaps in this scene\n" _args[1] to:_str
	),
	
	fn CheckMissingBitmapTextures =
	(
		local bmaps = this.GetMissingBitmapTextures()
		if bmaps.count != 0 then
		(
			this.UpdateMsgBuffer _args:#(bmaps.count)
			False
		)
		else
		(
			True
		)
	)
)

_checkForMissingTextureFiles = CheckForMissingTextureFiles()