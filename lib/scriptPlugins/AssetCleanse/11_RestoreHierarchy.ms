(
	-- 'Inherit' the main tool
	self = ::_assetCleanse 
	
	
	
	
	if self != undefined then
	(
		fn GetNodeNameFromObjectStr Str =
		(
			/* 
			Separates the name from the string value of a Max Node
			ie...$Point_Helper:HKBbrownApartmentCtopNull @ [0.000000,348.199097,196.928101]
			wiill return "HKBbrownApartmentCtopNull"
			 */
			out = (FilterString Str ":")[2]
			out = (FilterString out " ")[1]
			out
		)
		
		fn RestoreHierarchy _progressBar:self._progressBar =
		(
			/* 
			Sets the .parent property of allObjects from the value stored in the user property buffer
			 */
			
			if _progressBar != undefined then
			(
				_progressBar.UpdateLabel_Sub ""
	
				_progressBar.Start_Sub _steps:self.allObjects.count
			)
			
			
			local aNull = undefined
			
			for obj in self.allObjects do
			(
				if _progressBar != undefined then _progressBar.UpdateLabel_Sub obj.name
				
				obj.parent = undefined
				pName = (GetUserProp obj (self.nameSpace+"Parent"))
					
				if pName == undefined then
				(
					format "***** No parent user prop for % *****\n" obj.name
					continue
				)
				
				if matchpattern pName pattern:"$AssetNull:*" then
				(
					aNull = (GetNodeByName (GetNodeNameFromObjectStr pName))
					continue
				)
				
				if (pName as string) != "undefined" then
				(
					pNode = (GetNodeByName (GetNodeNameFromObjectStr pName))
					obj.parent = pNode
				)
				
				if _progressBar != undefined then _progressBar.Step_Sub()
			)
			
			if aNull != undefined then
			(
				--aNull.RefactorAssetObjects()
				for i in self.allObjects where ClassOf i != AssetNull and i.parent == undefined do i.parent = aNull
			)
		)
		
		
		-- register the plugin
		self.plugManager.Register title:"Restore Hierarchy" method:RestoreHierarchy aux:unsupplied active:True description:"Restores the parent of each object from data in the User Prop buffer"
		
		
	)
	else
	(
		format "***** % could not inherit the main tool *****\n" (GetFileNameFile (GetThisScriptFileName()))
	)
)