(
	-- 'Inherit' the main tool
	self = ::_assetCleanse 
	
	
	
	
	if self != undefined then
	(
		
		fn ConvertToEditableMesh _progressBar:self._progressBar =
		(
			/* 
			Converts objects to editable_mesh
			 */
			
			if _progressBar != undefined then
			(
				_progressBar.UpdateLabel_Sub ""
	
				_progressBar.Start_Sub _steps:self.testObjects.count
			)
			
			for obj in self.testObjects do
			(
				--local obj = self.testObjects[i]
				if _progressBar != undefined then _progressBar.UpdateLabel_Sub obj.name
				
				if (ClassOf obj.baseObject) == Editable_Mesh or not (CanConvertTo obj Editable_Mesh) then 
				(
					--format "skipping % (%) it's not elgible for be collapse to editbale mesh\n" obj (classof obj.baseObject)
					continue
				)
				
				--format "attempitng to collapse %  (%) to editable mesh\n" obj (classof obj.baseobject)
				indx = obj.modifiers.count
				case indx of
				(
					(0):ConvertToMesh obj
					default:
					(
						--the old method was throwing system execeptions...
						
						mods = for m in obj.modifiers collect m
						for i = 1 to obj.modifiers.count do DeleteModifier obj 1
							
						ConvertToMesh obj
						
						for i = 1 to mods.count do
						(
							m = mods[mods.count-(i-1)]
							if ValidModifier obj m then
							(
								AddModifier obj m
							)
							else
							(
								format "***** % is no longer a valid modifer for obj: % *****\n" m obj.name
							)
						)
						
						/*Old method*/
						--addmodifier obj (edit_mesh()) before:indx
						--maxOps.collapseNodeTo obj (indx+1) false
					)
				)
				
				if _progressBar != undefined then _progressBar.Step_Sub()
			)
		)
		
		
		-- register the plugin
		self.plugManager.Register title:"Convert To Mesh Logic" method:ConvertToEditableMesh aux:unsupplied active:True description:"Logically converts geo objects ot Editable Mesh"
		
		
	)
	else
	(
		format "***** % could not inherit the main tool *****\n" (GetFileNameFile (GetThisScriptFileName()))
	)
)