(
	-- 'Inherit' the main tool
	self = ::_assetCleanse 
	
	
	
	
	if self != undefined then
	(
		fn RemoveAnimLayers _progressBar:self._progressBar =
		(
			/*
			remove all layer controller types from the scene if possible...
			*/
			
			classList = 
			#(
				Float_Layer, 
				Point3_Layer, 
				Point4_Layer,
				Position_Layer,
				Rotation_Layer,
				Scale_Layer
			)
				
			for c in classList do 
			(
				inst = (GetClassInstances c asTrackViewPick:True)
				if inst.count == 0 then continue
				for b in inst do
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
			)
			
			origLayerCount = AnimLayerManager.GetLayerCount()
			if origLayerCount == 0 then return true
			animLayerCount = origLayerCount
			
			if _progressBar != undefined then
			(
				_progressBar.UpdateLabel_Sub ""
	
				_progressBar.Start_Sub _steps:origLayerCount
			)
			
			while true do
			(
				for t = 1 to animLayerCount do
				(
					try(AnimLayerManager.DeleteLayer t)catch()
				)
				newLayerCount = AnimLayerManager.GetLayerCount()
				
				if _progressBar != undefined then _progressBar.Step_Sub()
				
				if newLayerCount == animLayerCount then exit
				animLayerCount = newLayerCount
			)
		)
		
		-- register the plugin
		self.plugManager.Register title:"Remove Animation Layers" method:RemoveAnimLayers aux:unsupplied active:True description:"Purges all animation layers"
		
		
	)
	else
	(
		format "***** % could not inherit the main tool *****\n" (GetFileNameFile (GetThisScriptFileName()))
	)
)