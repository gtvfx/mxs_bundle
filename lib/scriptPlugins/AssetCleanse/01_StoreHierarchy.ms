(
	-- 'Inherit' the main tool
	self = ::_assetCleanse 
	
	if self != undefined then
	(
		
		fn SetAssetProp obj propKey propVal nameSpace:"" =
		(
			/* 
			Use to set user properties on the AssetObjects denoted by a proper name space
			 */
			SetUserProp obj (nameSpace+propKey) (propVal as string)
		)
		
		
		fn StoreHierarchy _progressBar:self._progressBar =
		(
			/* 
			Stores each objects parent in the User Prop buffer
			 */
			
			if _progressBar != undefined then
			(
				_progressBar.UpdateLabel_Sub ""
	
				_progressBar.Start_Sub _steps:self.allObjects.count
			)
			
			for obj in self.allObjects do
			(
				if _progressBar != undefined then _progressBar.UpdateLabel_Sub obj.name
				
                format "***** Storing Hierarchy: % | % *****\n" obj obj.parent
                
				SetAssetProp obj "Parent" (obj.parent as string) nameSpace:self.nameSpace
				
				if _progressBar != undefined then _progressBar.Step_Sub()
			)
		)
		
		
		-- register the plugin
		self.plugManager.Register title:"Store Hierarchy" method:StoreHierarchy aux:unsupplied active:True description:"Writes parent info of each object into the User Props"
		
		
	)
	else
	(
		format "***** % could not inherit the main tool *****\n" (GetFileNameFile (GetThisScriptFileName()))
	)
	
)