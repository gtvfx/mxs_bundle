(
	-- 'Inherit' the main tool
	self = ::SceneSanityChecks
	
	illegalChars = #("!","@","#","$","%","^","&","*",";",":",",","?","|")
	
	sceneAssets = Undefined
	
	mapAssets = Undefined
	
	illegalNamesArr = #()
	
	fn CollectAssets =
	(
		fPath = (MaxFilePath+MaxFileName)
		if not (DoesFileExist fPath) then
		(
			sceneAssets = #()
			mapAssets = #()
			False
		)
		else
		(
			sceneAssets = GetMAXFileAssetMetadata fPath
			mapAssets = for i in sceneAssets where i.type == #bitmap collect i
			True
		)
	)
	
	fn GetIllegalNames =
	(
		CollectAssets()
		--newName = mapName
		
		for map in mapAssets do
		(
			mapName = (GetFileNameFile map.filename)
			--newName = mapName
			
			for i = 1 to illegalChars.count do
			(
				char = illegalChars[i]
				case char of
				(
					("*"):
					(
						continue
						--print "*"
						--newName = (SubstituteString newName "*" "")
					)
					("?"):
					(
						continue
					)
					default:
					(
						pat = ("*" + char + "*")
						if matchPattern mapName pattern:pat then
						(
							format "***** mapName:pat % | % *****\n" mapName pat
							append illegalNamesArr mapName
						)
					)
				)
			)
		)
		
		illegalNamesArr
		
	)
	
	fn CheckForIllegalNames =
	(
		illegalNamesArr = #()
		illegalNamesArr = GetIllegalNames()
		if illegalNamesArr.count != 0 then
		(
			self.msgBuffer = "there are "+(illegalNamesArr.count as string)+" illegal map names in the scene"
			False
		)
		else
		(
			True
		)
	)
	
	
	fn SaveCheck =
	(
		if (queryBox "You must save your file to continue.\nWould you like to save now?" title:"Save Check") then
		(
			SaveMaxFile (MaxFilePath+MaxFileName) useNewFile:True quiet:True
			True
		)
		else
		(
			False
		)
	)
	
	fn CleanMapNames =
	(
		if not (SaveCheck()) then return False
			
		if sceneAssets == undefined or mapAssets == undefined then CollectAssets()
		
		for i in mapAssets do
		(
			
			fName = GetFileNameFile i.filename
			newName = fName
			if fName != undefined then for c in illegalChars do
			(
				--format "***** Checking *****\n"
				newName = SubStituteString newName c ""
			)
			--format "***** newName: % *****\n" newName
			if newName != fName then
			(
				
				cFile = ((GetFileNamePath i.filename) + newName + (GetFileNameType i.filename))
				
				--format "***** cFile: % *****\n" cFilecFile
				
				CopyFile i.filename cFile
				
				i.filename = cFile
			)
		)
		
		setMAXFileAssetMetadata (MaxFilePath+MaxFileName) sceneAssets
		
		--try(destroyDialog SceneSanityChecks.ro)catch()
		
		LoadMaxFile (MaxFilePath+MaxFileName) quiet:True
		
		--SceneSanityChecks.Init()
	)
	
	
	-- register the plugin
	self.plugManager.Register title:"Check Map Names" method:CheckForIllegalNames aux:#(CleanMapNames) active:True description:"Checks illegal characters in map names"
)
