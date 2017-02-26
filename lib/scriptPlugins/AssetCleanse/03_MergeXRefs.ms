(
	-- 'Inherit' the main tool
	self = ::_assetCleanse 
	
	
	
	
	if self != undefined then
	(
	
		fn MergeXrefObjects _progressBar:undefined =
		(
			format "----- Merge XRef Objects -----\n"
			
			local xObjs = For i in self.allObjects where (ClassOf i == XrefObject) collect i
			
			if _progressBar != undefined then
			(
				_progressBar.UpdateLabel_Sub ""
	
				_progressBar.Start_Sub _steps:xObjs.count
			)
			
			if xObjs.count != 0 then
			(
				for obj in xObjs do 
				(
					if _progressBar != undefined then _progressBar.UpdateLabel_Sub obj.name
					
					if obj.useProxy then obj.useProxy = False
					ObjXRefMgr.MergeXRefItemsIntoScene obj.baseObject
					
					if _progressBar != undefined then _progressBar.Step_Sub()
				)
			)
			
			self.RefactorObjs()
		)
		
		fn MergeXrefControllers _progressBar:undefined =
		(
			format "----- Merge XRef Controllers -----\n"
			local cons = GetClassInstances XRef_Controller
			
			if _progressBar != undefined then
			(
				_progressBar.UpdateLabel_Sub ""
	
				_progressBar.Start_Sub _steps:cons.count
			)
			
			if cons.count != 0 then
			(
				for con in cons do 
				(
					local conNode = try((refs.dependentNodes con)[1])catch("")
					
					if _progressBar != undefined then _progressBar.UpdateLabel_Sub ((con as string) + " | " + (conNode as string))
					
					ObjXRefMgr.MergeXRefItemsIntoScene con
					
					if _progressBar != undefined then _progressBar.Step_Sub()
				)
			)
		)
		
		fn MergeXrefs _progressBar:self._progressBar =
		(
			MergeXrefObjects _progressBar:_progressBar
			MergeXrefControllers _progressBar:_progressBar
		)
		
		
		
		-- register the plugin
		self.plugManager.Register title:"Merge XRefs" method:MergeXrefs aux:unsupplied active:True description:"Merges XRef objects and XRef Controllers"
		
		
	)
	else
	(
		format "***** % could not inherit the main tool *****\n" (GetFileNameFile (GetThisScriptFileName()))
	)
)