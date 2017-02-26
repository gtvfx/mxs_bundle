(
	-- 'Inherit' the main tool
	self = ::_assetCleanse 
	
	
	
	
	if self != undefined then
	(
		fn CloseSubObject classArr:#(Editable_Mesh, Editable_Poly, Polymeshobject) _progressBar:self._progressBar _progressLabel:self._progressLabel=
		(
			selArr = (GetCurrentSelection())
			objArr = self.testObjects
			
			SetCommandPanelTaskMode #modify
			cui.commandPanelOpen = False
			
			if _progressLabel != undefined then _progressLabel.text = ("Closing Subobject")
			if _progressBar != undefined then _progressBar.value = 0
			inc = (100.0/objArr.count)
			incU = 0.0
				
			for i = 1 to objArr.count do
			(
				indx = (FindItem classArr (classOf objArr[i]))
			
				case indx of
				(
					(0):
					(
						-- Pass
					)
					default:
					(
						with undo off
						(
							try
							(
								select objArr[i]
								SubObjectLevel = 0
							)
							catch()
						)
					)
				)
				
				if _progressBar != undefined then _progressBar.value = 100*(i as float/objArr.count)
			)
			
			select selArr
			setCommandPanelTaskMode #create
			cui.commandPanelOpen = True
		)
		
		
		-- register the plugin
		self.plugManager.Register title:"Close Subobject" method:CloseSubObject aux:unsupplied active:True description:"Ensures that no objects have a sub-object selection active"
		
		
	)
	else
	(
		format "***** % could not inherit the main tool *****\n" (GetFileNameFile (GetThisScriptFileName()))
	)
)