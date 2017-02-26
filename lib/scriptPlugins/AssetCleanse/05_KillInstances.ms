(
	-- 'Inherit' the main tool
	self = ::_assetCleanse 
	
	
	
	
	if self != undefined then
	(
		fn KillInstances =
		(
			/* 
			Removes all instancing (Makes all objects unique)
			 */
			if self.allObjects.count != 0 then
			(
				InstanceMgr.MakeObjectsUnique self.allObjects #individual 
				True
			)
			else
			(
				False
			)
		)
		
		
		-- register the plugin
		self.plugManager.Register title:"Kill Instances" method:KillInstances aux:unsupplied active:True description:"Makes all objects unique"
		
		
	)
	else
	(
		format "***** % could not inherit the main tool *****\n" (GetFileNameFile (GetThisScriptFileName()))
	)
)