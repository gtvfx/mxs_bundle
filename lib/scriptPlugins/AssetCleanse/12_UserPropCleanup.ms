(
	-- 'Inherit' the main tool
	self = ::_assetCleanse 
	
	
	
	if self != undefined then
	(
		mapped fn CleanUserPropBuffer objArr =
		(
			/* 
			Removes empty lines in the User Properties Buffer
			 */
			propBuffer = GetUserPropBuffer objArr
			if propBuffer != "" then
			(
				propBufferArr = FilterString propBuffer "\n"
				for i = 1 to propBufferArr.count do
				(
					newStr = SubstituteString propBufferArr[i] "\r" ""
					propBufferArr[i] = newStr
				)
				cleanBufferArr = for i in propBufferArr where i != "\r" and i != "" collect i
				newPropBuffer = ""
				if cleanBufferArr.count != 0 then
				(
					newPropBuffer = (cleanBufferArr[1] + "\r\n")
					for i = 2 to cleanBufferArr.count do
					(
						newPropBuffer += (cleanBufferArr[i] + "\r\n")
					)
				)
				SetUserPropBuffer objArr newPropBuffer
			)
			else
			(
				False
			)
		)
		
		mapped fn RemoveUserProp_mapped objArr propKey =
		(
			/* 
			Removes the User Property defined by the 'propKey' arg
			 */
			propBuffer = GetUserPropBuffer objArr
			if propBuffer != "" then
			(
				propBufferArr = FilterString propBuffer "\n"
				index = 0
				for i = 1 to propBufferArr.count do
				(
					if MatchPattern propBufferArr[i] pattern:("*"+propKey+"*") then
					(
						index = i
						exit
					)
				)
				if index != 0 then
				(
					DeleteItem propBufferArr index
					cleanBufferArr = for each in propBufferArr where each != "\r" collect each
					newPropBuffer = ""
					if cleanBufferArr.count != 0 then
					(
						newPropBuffer = (cleanBufferArr[1] + "\r\n")
						for i = 2 to cleanBufferArr.count do
						(
							newPropBuffer += (cleanBufferArr[i] + "\r\n")
						)
					)
					SetUserPropBuffer objArr newPropBuffer
				)
				else
				(
					False
				)
			)
			else
			(
				False
			)
		)
		
		fn PurgeData _progressBar:self._progressBar fnArr:#(RemoveUserProp_mapped,CleanUserPropBuffer) =
		(
			/* 
			Cleans out the data that this library stored in the user prop buffer
			 */
			
			if _progressBar != undefined then
			(
				_progressBar.UpdateLabel_Sub ""
	
				_progressBar.Start_Sub _steps:fnArr.count
			)
			
			for i = 1 to fnArr.count do
			(
				case i of
				(
					(1):fnArr[1] self.allObjects (self.nameSpace+"Parent")
					(2):fnArr[2] self.allObjects
				)
				
				if _progressBar != undefined then _progressBar.Step_Sub()
			)
		)
		
		
		
		-- register the plugin
		self.plugManager.Register title:"User Prop Cleanup" method:PurgeData aux:unsupplied active:True description:"Removes User Prop data only used for the AssetCleanse"
		
		
	)
	else
	(
		format "***** % could not inherit the main tool *****\n" (GetFileNameFile (GetThisScriptFileName()))
	)
)