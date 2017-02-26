(
	-- 'Inherit' the main tool
	self = ::_assetCleanse 
	
	
	
	if self != undefined then
	(
	
		fn FlattenHierarchy _progressBar:self._progressBar =
		(
			if _progressBar != undefined then
			(
				_progressBar.UpdateLabel_Sub ""
	
				_progressBar.Start_Sub _steps:self.allObjects.count
			)
			
			
			for obj in self.allObjects do
			(
				if _progressBar != undefined then _progressBar.UpdateLabel_Sub obj.name
				
				obj.parent = undefined
				
				if _progressBar != undefined then _progressBar.Step_Sub()
			)
		)
		
		
		
		-- register the plugin
		self.plugManager.Register title:"Flatten Hierarchy" method:FlattenHierarchy aux:unsupplied active:True description:"Sets the parent of each object to 'undefined'"
		
		
	)
	else
	(
		format "***** % could not inherit the main tool *****\n" (GetFileNameFile (GetThisScriptFileName()))
	)
)