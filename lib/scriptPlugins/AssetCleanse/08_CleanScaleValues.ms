(
	-- 'Inherit' the main tool
	self = ::_assetCleanse 
	
	
	if self != undefined then
	(
		self.RefactorObjs()
		
		mapped fn SetTransformController_mapped objArr _controller:PRS =
		(
			trnsCtrl = _controller()
			objArr.transform.controller = trnsCtrl
		)
		
		mapped fn SetScaleController_mapped objArr _controller:ScaleXYZ =
		(
			/* 
			Converts the scale controller on all objects to ScaleXYZ.
			This is a more accurate mathematical representation of values and far less prone to precision errors
			 */
			if classOf objArr.transform.controller != PRS then SetTransformController_mapped (objArr as array)
			 
			scaleCtrl = _controller()
			objArr.scale.controller = scaleCtrl
			scaleCtrl.value = [1,1,1]
		)
		
		fn FixHelperScaleValues objArr:self.excludedObjs =
		(
			/* 
			Collects all helpers from the objArr and runs a function to set their scale back to [1,1,1] without scaling thier children
			 */
			arr = for i in objArr where (SuperClassOf i) == Helper collect i
			SetScaleController_mapped arr
		)
		
		fn FixNonUniformScale _progressBar:self._progressBar =
		(
			/* 
			Resets the transform of objects with scale values not equal to [1,1,1]
			 */
			
			if self.testObjects != undefined and self.testObjects.count != 0 then
			(
				if _progressBar != undefined then
				(
					_progressBar.UpdateLabel_Sub ""
		
					_progressBar.Start_Sub _steps:self.testObjects.count
				)
				
				FixHelperScaleValues()
				for obj in self.testObjects do
				(
					--local obj = self.testObjects[i]
					if _progressBar != undefined then _progressBar.UpdateLabel_Sub obj.name
					
					if classOf obj.transform.controller != PRS then SetTransformController_mapped #(obj) _controller:PRS
					
					
					objScale = obj.scale.controller.value
					st = objScale as string
					if st != "[1,1,1]" then
					(
						obj.scale.controller = scaleXyz()
						xmod = xform()
						case obj.modifiers.count of
						(
							(0):addmodifier obj xmod
							default:addmodifier obj xmod before:obj.modifiers.count
						)
						mtrx_base = matrix3 1
						mtrx_xform = matrix3 (mtrx_base[1]*objScale[1]) (mtrx_base[2]*objScale[2]) (mtrx_base[3]*objScale[3]) [0,0,0]
						xmod.gizmo.transform = mtrx_xform
						obj.scale.controller.value = [1,1,1]
						--collapse mod...
						maxOps.collapseNodeTo obj (finditem obj.modifiers xmod) true
					)
					
					if _progressBar != undefined then _progressBar.Step_Sub()
				)
			)
			
		)
		
		-- register the plugin
		self.plugManager.Register title:"Clean Scale Values" method:FixNonUniformScale aux:unsupplied active:True description:"Fix object scale values that aren't [1,1,1]"
	)
	else
	(
		format "***** % could not inherit the main tool *****\n" (GetFileNameFile (GetThisScriptFileName()))
	)
)
