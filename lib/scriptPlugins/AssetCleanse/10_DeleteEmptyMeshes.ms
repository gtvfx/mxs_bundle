(
	-- 'Inherit' the main tool
	self = ::_assetCleanse 
	
	
	
	
	if self != undefined then
	(
		
		fn DeleteEmptyMeshObjects _progressBar:self._progressBar =
		(
			/* 
			- Deletes any mesh objects in the scene without any vertices
			- This funciton will error if the object tested is not a mesh object.
			- The testObjects array should be filtered by the Excluded Super Class array and the Excluded Class Array
			 */
			
			local emptyMeshArr = for obj in self.testObjects where ( isProperty obj #mesh ) and ( isProperty obj.mesh #numversts ) and ( obj.mesh.numverts == 0 ) collect obj
			
			if emptyMeshArr.count != 0 then
			(
				if _progressBar != undefined then
				(
					_progressBar.UpdateLabel_Sub ""
		
					_progressBar.Start_Sub _steps:emptyMeshArr.count
				)
				
				for obj in emptyMeshArr do
				(
					format "***** % had 0 verts and was deleted *****\n" obj.name
					Delete obj
					
					if _progressBar != undefined then _progressBar.Step_Sub()
				)
			)
			
			self.RefactorObjs()
		)
		
		
		-- register the plugin
		self.plugManager.Register title:"Delete Empty Mesh Objects" method:DeleteEmptyMeshObjects aux:unsupplied active:True description:"Deletes mesh objects without any vertices"
		
		
	)
	else
	(
		format "***** % could not inherit the main tool *****\n" (GetFileNameFile (GetThisScriptFileName()))
	)
)