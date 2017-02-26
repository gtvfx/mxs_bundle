struct CheckMapNames
(
	agregate,
	sceneAssets = #(),
	mapAssets = #(),
	
	-- regex with legal characters for object names
	rx = dotnetobject "System.Text.RegularExpressions.Regex" "[a-zA-Z0-9_.]",
	
	fn CollectAssets =
	(
		this.sceneAssets = #()
		this.mapAssets = #()
		
		local fPath = ( MaxFilePath + MaxFileName )
		if ( DoesFileExist fPath ) then
		(
			this.sceneAssets = ( GetMAXFileAssetMetadata fPath )
			this.mapAssets = for i in this.sceneAssets where i.type == #bitmap collect i
		)
		
	),
	
	fn GetIllegalNames regex:this.rx =
	(
		this.CollectAssets()
		local out = #()
		
		for map in this.mapAssets do
		(
			local mapName = (GetFileNameFile map.filename)
			--newName = mapName
			
			local nameArr = for i = 1 to mapName.count collect mapName[i]
				
			for n in nameArr do
			(
				-- loop through each character and test it against the regex
				if not (regex.isMatch n) then
				(
					-- If the test fails then we append the object to the output array
					-- We also exit the loop as soon as we find an illegal character. No need to continue checking the rest if one is found here.
					append out map
					exit
				)
			)
		)
		
		out
	),
	
	fn UpdateMsgBuffer _args:#() _str: =
	(
		if ( this.agregate != undefined ) and ( isProperty this.agregate #msgBuffer ) then 
		(
			free this.agregate.msgBuffer
			_str = this.agregate.msgBuffer
		)
		
		format "There are % illegal map names in the scene\n" _args[1] to:_str
	),
	
	fn CheckForIllegalNames =
	(
		local illegalNamesArr = this.GetIllegalNames()
		if illegalNamesArr.count != 0 then
		(
			this.UpdateMsgBuffer _args:#(illegalNamesArr.count)
			False
		)
		else
		(
			True
		)
	),
	
	fn SaveCheck =
	(
		if ( queryBox "You must save your file to continue.\nWould you like to save now?" title:"Save Check" ) then
		(
			SaveMaxFile (MaxFilePath+MaxFileName) useNewFile:True quiet:True
			True
		)
		else
		(
			False
		)
	),
	
	fn CleanMapNames regex:this.rx =
	(
		if not (this.SaveCheck()) then return False
			
		if this.sceneAssets.count == 0 or this.mapAssets.count == 0 then this.CollectAssets()
		
		for i in this.mapAssets do
		(
			local fName = GetFileNameFile i.filename
			local newName = fName
			
			local nameArr = for i = 1 to newName.count collect newName[i]
				
			for n in nameArr do
			(
				-- Strip the illegal characters from the object name
				if not (regex.isMatch n) then
				(
					newName = SubstituteString newName n ""
				)
			)
			
			
			
			if newName != fName then
			(
				
				local cFile = ((GetFileNamePath i.filename) + newName + (GetFileNameType i.filename))
				
				--format "***** cFile: % *****\n" cFilecFile
				
				CopyFile i.filename cFile
				
				i.filename = cFile
			)
		)
		
		SetMAXFileAssetMetadata (MaxFilePath+MaxFileName) this.sceneAssets 
		
		--try(destroyDialog ilm_sceneSanity.ro)catch()
		
		LoadMaxFile (MaxFilePath+MaxFileName) quiet:True
		
		--ilm_sceneSanity.Init()
	)
)

_checkMapNames = CheckMapNames()