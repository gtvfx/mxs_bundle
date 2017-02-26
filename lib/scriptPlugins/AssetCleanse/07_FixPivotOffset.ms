(
	-- 'Inherit' the main tool
	self = ::_assetCleanse 
	
	
	
	
	if self != undefined then
	(
		
		fn FixPivotOffsets _progressBar:self._progressBar =
		(
			/* 
			Fixes pivot offsets that can skew the position of objects when exporting to external packages or using animation constraints
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
				
				Ops = obj.objectOffsetPos
				Ort = obj.objectOffsetRot
				Osc = obj.objectOffsetScale
				
				st = (Ops as string) + (Ort as string) + (Osc as string)
				
				if st != "[0,0,0](quat 0 0 0 1)[1,1,1]" then
				(
					xmod = xform()
					case obj.modifiers.count of
					(
						(0):addmodifier obj xmod
						default:addmodifier obj xmod before:obj.modifiers.count
					)
					rotM = Ort as matrix3
					mat = matrix3 (rotM[1]*Osc[1]) (rotM[2]*Osc[2]) (rotM[3]*Osc[3]) Ops
					xmod.gizmo.transform = mat
					
					obj.objectOffsetPos = [0,0,0]
					obj.objectOffsetRot = quat 0 0 0 1
					obj.objectOffsetScale = [1,1,1]
					
					--collapse mod...
					maxOps.collapseNodeTo obj (finditem obj.modifiers xmod) true
				)
				
				if _progressBar != undefined then _progressBar.Step_Sub()
			)
			
			self.RefactorObjs()
		)
		
		
		-- register the plugin
		self.plugManager.Register title:"Fix Pivot Offsets" method:FixPivotOffsets aux:unsupplied active:True description:"Fixes non-standard pivot offsets"
		
	)
	else
	(
		format "***** % could not inherit the main tool *****\n" (GetFileNameFile (GetThisScriptFileName()))
	)
)