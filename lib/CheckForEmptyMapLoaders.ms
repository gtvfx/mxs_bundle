struct CheckForEmptyMapLoaders
(
	agregate,
	
	fn GetAllEmptyMapLoaders =
	(
		local bm = getclassinstances bitmaptexture asTrackViewPick:on
		if VRayHdri != undefined then bm += (GetClassInstances VRayHdri asTrackViewPick:on)
		out = for b in bm where b.anim.filename == undefined or b.anim.filename == "" collect b
		out
	),
	
	fn RemoveBitmapTextures bm =
	(
		MatEditor.Close()
		for b in bm do
		(
			for s=1 to b.client.numsubs do
			(
				if b.client[s] == b.anim then
				(
					b.client[s].value = undefined
					exit
				)
			)
		)
		True
	),
	
	fn RemoveEmptyBitmapTextures =
	(
		local bm = this.GetAllEmptyMapLoaders()
		this.RemoveBitmapTextures bm
	),
	
	fn UpdateMsgBuffer _args:#() _str: =
	(
		
		if this.agregate != undefined and ( isProperty this.agregate #msgBuffer ) then 
		(
			free this.agregate.msgBuffer
			_str = this.agregate.msgBuffer
		)
		
		format "There are % Empty Bitmap Textures\n" _args[1] to:_str
	),
	
	fn CheckEmptyMapLoaders =
	(
		bm = this.GetAllEmptyMapLoaders()
		if bm.count != 0 then
		(
			this.UpdateMsgBuffer _args:#(bm.count)
			
			False
		)
		else
		(
			True
		)
	)
)

_checkForEmptyMapLoaders = CheckForEmptyMapLoaders()