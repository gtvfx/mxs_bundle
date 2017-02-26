(
	-- 'Inherit' the main tool
	self = ::_assetCleanse 
	
	
	
	
	if self != undefined then
	(
		deleteObjs = #()
		
		classArr = #()
		
		modClassArr = #(TurboSmooth, Point_Cache)
		
		thirdPartyModArr = #(VRayDisplacementMod)
		
		thirdPartyClassArr = #(RailClone_Pro)
		
		for i in thirdPartyModArr do
		(
			if i != undefined then append modClassArr i
		)
		
		for i in thirdPartyClassArr do
		(
			if i != undefined then append classArr i
		)
		
		fn DeleteTemplateObjs =
		(
			local arr = MakeUniqueArray deleteObjs
			
			local undItem = FindItem arr undefined
			
			if undItem != 0 then DeleteItem arr undItem
			
			if arr.count != 0 then (delete arr)
		)	

		fn CollapseRailCloneObj obj =
		(
			local refsObjs = for i in obj.sobjnode collect i
				
			ConvertToMesh obj
			
			if refsObjs.count != 0 then
			(
				for i in refsObjs do
				(
					append deleteObjs i
				)
			)
		)

		fn CollapseClassArrObjs classArr =
		(
			if classArr.count != 0 then
			(
				for cls in classArr do
				(
					local clsObjArr = #()
					
					for i in (GetClassInstances cls) do
					(
						local refArr = refs.dependentNodes i
						clsObjArr += refArr
					)
					
					if clsObjArr.count != 0 then
					(
						case cls of
						(
							(undefined):
							(
								continue
							)
							(RailClone_Pro):
							(
								for obj in clsObjArr do
								(
									CollapseRailCloneObj obj
									format "***** %: Converted to mesh *****\n" obj.name
								)
							)
							default:
							(
								for obj in clsObjArr do
								(
									ConvertToMesh obj
									format "***** %: Converted to mesh *****\n" obj.name
								)
							)
						)
						
					)
				)
			)
		)

		
		fn CollapseDownToMod _progressBar:self._progressBar =
		(
			/* 
			Collapses the modifiers stack of all objects
			If a turbosmooth modifier is present, then the stack is collapsed below the turbosmooth modifier
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
				
				if not (isDeformable obj) or obj.modifiers.count == 0 then continue
				
				tbIndx = 0
				
				-- We get the index of each TurboSmooth modifier in the stack
				indexArr = for x = 1 to obj.modifiers.count where (findItem modClassArr (classof obj.modifiers[x])) != 0 collect x
				
				-- We get the top-most TurboSmooth mod
				tbIndx = indexArr[1]
					
				case tbIndx of
				(
					(1): -- If the top-most TurboSmooth mod is at the top of the stack we keep the modifer and collapse everything below it
					(
						maxOps.CollapseNodeTo obj (tbIndx+1) True
					)
					default: -- if the modifier is not at the top of the stack then we collapse everything and bake it into the mesh
					(
						if tbIndx != 0 then
						(
							for mod in obj.modifiers where classOf mod == TurboSmooth do
							(
								if mod.useRenderIterations and mod.renderIterations > mod.iterations then
								(
									mod.iterations = mod.renderIterations
								)
							)
						)
						
						ConvertToMesh obj
						-- This try/catch is to catch world space modifiers.
						if obj.modifiers.count != 0 then
						(
							try(maxOps.CollapseNodeTo obj 1 off)catch()
						)
					)
				)
				
				if _progressBar != undefined then _progressBar.Step_Sub()
			)
		)
		
		fn Run =
		(
			CollapseClassArrObjs classArr
			CollapseDownToMod()
			DeleteTemplateObjs()
			self.RefactorObjs()
		)
		
		-- register the plugin
		self.plugManager.Register title:"CollapseTo Logic" method:Run aux:unsupplied active:True description:"Collapses the stack of objects up to a chosen modifier class"
		
	)
	else
	(
		format "***** % could not inherit the main tool *****\n" (GetFileNameFile (GetThisScriptFileName()))
	)
)