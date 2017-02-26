/*!
	\file		mxsString.ms

	\remarks	this is an appropriation of the blurString library
	
	V0.01 -- RAM 			-- First Boilerplate, added padnumber function
	V0.02 -- RAM 			-- Fixed Search and replace to handle search and replace for similar string
	V0.03 -- RAM 			-- Added ShortenTo function
	V0.04 -- EKH 05/23/06 	-- Reorganized library, added functions:
							-- BuildFileName, GetAsID, GetAsStringVersion, HasSearchString, HasVersion, RemoveVersion
							-- Removed RTrim function because it didnt have any code within it
							-- Removed 2nd toBool function (combined it with the first toBool function - one converted "1" to True the other "true" to True...)

*/


global _mxsString = #uninitialized
global _mxsStringOutput = ""

struct mxsString
(
	elementSpacer 	= "_",
	componentSpacer 	= "-",
	generatedID		= "",
	uiGenerateIDROLL,
	
	-------------------------------------------------------------------------------------------------------------
	--									CONVERSION FUNCTIONS
	-------------------------------------------------------------------------------------------------------------
	fn Color_to_OLE color = ( return ((color.b *65536) + (color.g *256) + color.r) ), -- Convert the inputed color value to an OLE color
	
	fn FrameNumber_to_TimeCode Frame FPS =
	(
		/*------------------------------------------------------------------------------------------------------------
		--	Prototype:
		--				FUNCTION _mxsString.FrameNumber_to_TimeCode Frame FPS
		--
		--	Remarks:
		--				Convert 30 to 00:00:01:00 at 30fps or 00:00:01:08 at 24fps
		--	Parameters:
		--				Frame		<integer>
		--				FPS			<float>
		--	Returns:
		--				<string>
		-----------------------------------------------------------------------------------------------------------*/
		
		--hour
		hr = Frame / (FPS*3600)
		Frame -= hr * (FPS*3600)
		--minutes
		min =  Frame / (FPS*60)
		Frame -= min * (FPS*60)
		--seconds
		sec =  Frame / FPS
		Frame -= sec * FPS
		--format it in time code string
		local timeCodeString =
		( 
			_mxsString.Integer_to_PaddedString hr 2 + ":" + 
			_mxsString.Integer_to_PaddedString min 2 + ":" + 
			_mxsString.Integer_to_PaddedString sec 2 + ":"+
			_mxsString.Integer_to_PaddedString Frame 2
		)
		return timeCodeString 
	),
	
	fn generateIDRollout =
	(
		rollout uiGenerateIDROLL "Generate ID" width:328 height:103
		(
			local self
			local id
			-------------------------------------------------------------------------------------------------------------
			--								UI DEFINITIONS
			-------------------------------------------------------------------------------------------------------------
			groupBox uiIDGRP "" pos:[7,7] width:310 height:60
			editText uiNameTXT "Name:" pos:[12,20] width:291 height:16
			label uiIDLBL "ID: " pos:[16,44] width:286 height:15
			button uiOkBTN "Ok" pos:[130,75] width:93 height:20 enabled:False;
			button uiCancelBTN "Cancel" pos:[228,75] width:93  height:20
			
			-------------------------------------------------------------------------------------------------------------
			--								ROLLOUT DEFINITIONS
			-------------------------------------------------------------------------------------------------------------
			fn _init pself =
			(
				self = pself
			)
			
			on uiNameTXT changed inText do
			( 
				id = self.GetAsElement uiNameTXT.text
				uiIDLBL.text = "ID: " + id
				uiOkBTN.enabled = id != ""
			)
			
			on uiOKBTN pressed do
			(
				this.generatedID = id
				destroyDialog uiGenerateIDROLL
			)
			
			on uiCancelBTN pressed do
			(
				destroyDialog uiGenerateIDROLL
			)
		)
		
		createDialog uiGenerateIDROLL modal:True
		uiGenerateIDROLL._init this
	),
	
	fn UserGenerateID =
	(
		this.generatedID = ""
		try( destroyDialog generateIDRollout )catch()
		this.generateIDRollout()
		return this.generatedID
	),
	
	fn GetAsID inString inSetToLower:True inIDSeparator:this.elementSpacer =
	(
		------------------------------------------------------------------------------
		--	Prototype:
		--				FUNCTION _mxsString.GetAsID inString
		--
		--	Remarks:
		--				Converts the inputed string to an ID value - removes invalid
		--				characters, and replaces spaces with underscores, returning
		--				the whole thing as lower case.
		--	Parameters:
		--				inString		<string>
		--	Returns:
		--				<string>
		--	History:
		--				- Created: EKH 04/19/06
		------------------------------------------------------------------------------
		if ( inString == undefined or inString == "" ) then
		(
			return ""
		)
			
		local tStrList = filterstring inString "!@#$%^&*(){}/?><,.;:'[]\\|`~+\"\"="
		local outStr = tStrList[1]
		
		for i = 2 to tStrList.count do
		(
			outStr += tStrList[i]
		)
		
		local tSplitStr = " " + this.elementSpacer + this.componentSpacer
			
		tStrList = filterstring outStr " _"
		outStr = tStrList[1]
		
		for i = 2 to tStrList.count do
		(
			outStr += inIDSeparator + tStrList[i]
		)
		
		if ( inSetToLower ) then
		(
			return ( toLower outStr )
		)
		else
		(
			return outStr
		)
	),
	
	fn GetAsElement inString = 
	(
		this.GetAsID inString inSetToLower:False inIDSeparator:this.componentSpacer
	),
	
	fn GetAsStringVersion inNumber inNewVersion:False =
	(
		/*------------------------------------------------------------------------------------------------------------
		--	Prototype:
		--				FUNCTION _mxsString.GetAsStringVersion inNumber
		--
		--	Remarks:
		--				Takes the inputed number and converts it to a naming convension version string ( "v00-00" )
		--	Parameters:
		--				inNumber		<integer> || <float>
		--	Returns:
		--				<string>
		--	History:
		--				- Created: EKH 05/23/06
		-----------------------------------------------------------------------------------------------------------*/
		local outStrVersion = "v"
		local tFloatSplit = filterstring ( _mxsString.PadNumber numberInput:( inNumber ) padInt:2 padDec:2 inNewVersion:inNewVersion ) "."
		outStrVersion += tFloatSplit[1] + "-" + tFloatSplit[2]
		return outStrVersion
	),
	
	fn GetVersion inString =
	(
		inString = GetFileNameFile ( inString as string )
		
		local tFileList = _mxsString.GetElements inString
		
		if ( tFileList.count > 0 ) then
		(
			local tVersionList = filterString tFileList[ tFileList.count ] "-"
			
			try
			(
				if ( tVersionList.count != 2 ) then
				(
					if ( toLower ( tFileList[ tFileList.count - 1 ][1] ) == "v" ) then
					(
						tVersionList = #( tFileList[ tFileList.count - 1 ], tFileList[ tFileList.count ] )
					)
					else if ( tFileList.count > 2 and toLower ( tFileList[ tFileList.count - 2 ] ) == "v" ) then
					(
						tVersionList = #( "v" + tFileList[ tFileList.count - 1 ], tFileList[ tFileList.count ] )
					)
					else
					(
						local tMajor = ( tFileList[ tFileList.count - 1 ] )
						local tMinor = ( tFileList[ tFileList.count ] )
						if ( ( tMajor as integer ) != undefined and ( tMinor as integer ) != undefined ) then
						(
							return ( ( tMajor + "." + tMinor ) as float )
						)
					)
				)
				if ( tVersionList.count == 2 ) then 
				(
					if ( toLower ( tVersionList[1][1] ) == "v" ) then 
					(
						local tMajor = subString tVersionList[1] 2 ( tVersionList.count )
						local tMinor = tVersionList[2]
						if ( ( tMajor as integer ) != undefined and ( tMinor as integer ) != undefined ) then
						(
							return ( ( tMajor + "." + tMinor ) as float )
						)
					)
				)
			)
			catch()
		)
		return -0.1
	),
	
	fn Integer_to_PaddedString num padCount padChar:"0" =
	(
		/*------------------------------------------------------------------------------------------------------------
		--	Prototype:
		--				FUNCTION _mxsString.Integer_to_PaddedString num padCount padChar:"0"
		--
		--	Remarks:
		--				Converts an inputed number value to a padded string.
		--				Examples:
		--							30 to "0030"
		--							3.0 to "03.0"
		--	Parameters:
		--				num			<integer> || <float>
		--				padCount	<integer>
		--				padChar		<string>		Default:"0"
		--	Returns:
		--				<string>
		-----------------------------------------------------------------------------------------------------------*/
		local snum = num as string
		while snum.count < padCount do snum = padChar + snum
		return snum
	),
	
	fn TimeCode_to_FrameNumber inString FPS =
	(
		/*------------------------------------------------------------------------------------------------------------
		--	Prototype:
		--				FUNCTION _mxsString.TimeCode_to_FrameNumber inString FPS
		--
		--	Remarks:
		--				Convert 00:00:01:00 to 30 at 30fps
		--	Parameters:
		--				inString		<string>
		--				FPS				<float>
		--	Returns:
		--				<integer>
		--	History:
		--				- Created: EKH 05/23/06
		-----------------------------------------------------------------------------------------------------------*/
		
		local stringParts = filterString inString ":;"
		hr = stringParts[1] as integer
		min = stringParts[2] as integer
		sec = stringParts[3] as integer
		frms = stringParts[4] as integer

		--change it to frames
		local frames = 0
		frames +=  hr * (FPS*3600)
		frames += min * (FPS*60)
		frames += sec * FPS
		frames += frms
		return frames
	),
	
	fn ToBool str =
	(
		/*------------------------------------------------------------------------------------------------------------
		--	Prototype:
		--				FUNCTION _mxsString.ToBool str
		--
		--	Remarks:
		--				Takes an inputed string value and converts it to a boolean value - "1" or "true" returns
		--				True, otherwise the function returns False.
		--	Parameters:
		--				str		<string>
		--	Returns:
		--				<boolean>
		--	History:
		--				- Created: John Burnett
		-----------------------------------------------------------------------------------------------------------*/
		-- Uses MAXScript function ToUpper not the _mxsString one....
		if ( ToUpper str == "TRUE") or ( str == "1" ) then True else False
	),
	
	fn hasUpper str =
	(
		local hasUpper = false
		
		for i in 1 to str.count do
		(
			local charVal = bit.CharAsInt str[i]
			if (charVal > 64 and charVal < 91) do ( hasUpper = True )
		)
		hasUpper
	),
	
	fn ToInteger str = ( ( toUpper str ) as integer ),
	
	fn ToFloat str = ( ( toUpper str ) as float ),
	
	-------------------------------------------------------------------------------------------------------------
	--									EDITING FUNCTIONS
	-------------------------------------------------------------------------------------------------------------
	fn AddPadding inString: Number: Pad: =
	(
		/****************************************************************************************************************
		__BFNDOC__
		AddPadding
		[Description Usage and Variables]
		Use to adding padding to a string.
		_mxsString.AddPadding inString: Number: Pad:
			inString	The string to append the number to
			Number	The number to append to the string
			Pad		The length of the number appended to the string.
		__END__
		****************************************************************************************************************/
		if (inString != unsupplied) and (Number != unsupplied) and (Pad != unsupplied) do
		(
			ZeroString = ""
			for x = 1 to (Pad - (Number as string).count) do (ZeroString = ZeroString + "0")
			return (inString + (ZeroString + (Number as string)))
		)
	),
	
	fn BuildFileName inUserFileName inVersion:1.0 inPath:"" inExtension:"" inUseVersion:True inRemoveUserVersion:True =
	(
		/*------------------------------------------------------------------------------------------------------------
		--	Prototype:
		--				FUNCTION _mxsString.BuildFileName inUserFileName inVersion:1.0 inPath:"" inExtension:"max" inUseVersion:True inRemoveUserVersion:True
		--
		--	Remarks:
		--				Builds a file name based on the inputed parameters within the proper naming convention.
		--	Parameters:
		--				inUserFileName			<string>
		--				inVersion				<float>			Default:1.0
		--				inPath					<string>		Default:""
		--				inExtension				<string>		Default:"max"
		--				inUseVersion			<boolean>		Default:True
		--				inRemoveUserVersion		<boolean>		Default:True
		--	Returns:
		--				<string>
		--	History:
		--				- Created: EKH 05/23/06
		-----------------------------------------------------------------------------------------------------------*/
		local outFileName = getFileNameFile inUserFileName
		if ( outFileName == "" ) then
		(
			outFileName = "<undefined>"
		)
		
		if ( inUseVersion ) then
		(
			if ( inRemoveUserVersion ) then
			(
				outFileName = _mxsString.RemoveVersion outFileName
			)
			outFileName = _mxsString.JoinStrings #( outFileName, ( _mxsString.GetAsStringVersion inVersion ) ) inJoinChar:this.elementSpacer;
		)
		
		if ( inPath == "" ) then
		(
			inPath = getFileNamePath inUserFileName
			if ( inPath == "" ) then
			(
				inPath = "<undefined>"
			)
		)
			
		if ( inExtension == "" ) then
		(
			inExtension = getFileNameType inUserFileName
			if ( inExtension == "" ) then
			(
				inExtension = "max"
			)
			else
			(
				inExtension = ( filterstring inExtension "." )[1]
			)
		)
		
		if ( inPath[ inPath.count ] != "/" and inPath[ inPath.count ] != "\\" ) then
		(
			inPath += "/"
		)
		
		inPath = _mxsString.FindReplaceString inPath "\\" "/"
		
		return ( _mxsString.JoinStrings #( inPath, outFileName, ".", inExtension ) )
		
	),
	
	fn CapFirstandAfterSpaceDashLine PassText: =
	(
		/****************************************************************************************************************
		__BFNDOC__
		CapFirstandAfterSpaceDashLine
		[Description Usage and Variables]
		Use to capitalize the first letter and evert letter after a space dash or line.
		_mxsString.CapFirstandAfterSpaceDashLine PassText:
			PassText	The string to pass to the function.
		__END__
		****************************************************************************************************************/
		PassText = (_mxsString.ToUpper (PassText[1]) + ( substring PassText 2 100 ) )
		
		TempNewName = ""
		doNext = true
		
		for x = 1 to PassText.count do
		(
			if doNext then
			(
				TempNewName = TempNewName + PassText[ x ]
				if PassText[x] == " " and PassText[x+1] != undefined then
				(
					TempNewName = TempNewName + (_mxsString.ToUpper PassText[ x+1] )
					doNext = false
				)
			)
			else 
			(
				doNext = true
			)
		)
		PassText = TempNewName
		
		TempNewName = ""
		doNext = true
		
		for x = 1 to PassText.count do
		(
			if doNext then
			(
				TempNewName = TempNewName + PassText[ x ]
				if PassText[x] == "_" and PassText[x+1] != undefined then
				(
					if PassText[x+1] == "_" and PassText[x+1] != undefined then
					(
						TempNewName = TempNewName
						doNext = true
					)
					else
					(
						TempNewName = TempNewName + (_mxsString.ToUpper PassText[ x+1] )
						doNext = false
					)
				)
			)
			else
			(doNext = true)
		)
		
		PassText = TempNewName
		
		TempNewName = ""
		doNext = true
		
		for x = 1 to PassText.count do
		(
			if doNext then
			(
				TempNewName = TempNewName + PassText[ x ]
				if PassText[x] == "-" and PassText[x+1] != undefined then
				(
					if PassText[x+1] == "-" and PassText[x+1] != undefined then
					(
						TempNewName = TempNewName
						doNext = true
					)
					else
					(
						TempNewName = TempNewName + (_mxsString.ToUpper PassText[ x+1] )
						doNext = false
					)
				)
			)
			else
			(
				(doNext = true)
			)
		)
		
		PassText = TempNewName
		return PassText
	),
	
	fn ChopEnd str num:undefined = ( return (substring str 2 (str.count-1)) ), -- Remove 1 or num characters from the left side of the string
		
	fn ChopStart str num:undefined = ( return (substring str 1 (str.count-1)) ), -- Remove 1 or num characters from the right side of the string
		
	fn JoinStrings inStringList inJoinChar:"" =
	(
		/*------------------------------------------------------------------------------------------------------------
		--	Prototype:
		--				FUNCTION _mxsString.Join inStringList inJoinChar:this.elementSpacer
		--
		--	Remarks:
		--				Joins the inputed string elements together based on the inputed join character.
		--	Parameters:
		--				inStringList		<array>[ <string>, ... ]
		--				inJoinChar			<string>		Default: ""
		--	Returns:
		--				<string>
		--	History:
		--				- Created: EKH 05/23/06
		-----------------------------------------------------------------------------------------------------------*/
		local outStr = ""
		
		if ( inJoinChar == #ElementSpacer ) then
		(
			inJoinChar = this.elementSpacer
		)
		else if ( inJoinChar == #ComponentSpacer ) then
		(
			inJoinChar = this.componentSpacer
		)
		else
		(
			inJoinChar = ( inJoinChar as string )
		)
			
		if ( inStringList.count > 0 ) then
		(
			outStr = inStringList[1] as string
			for i = 2 to inStringList.count do
			(
				outStr += inJoinChar + ( inStringList[i] as string )
			)
		)
		return outStr
	),
	
	fn LTrim str =
	(
		/*------------------------------------------------------------------------------------------------------------
		--	Prototype:
		--				FUNCTION _mxsString.LTrim str
		--
		--	Remarks:
		--				Remove whitespace from the left side of the string
		--	Parameters:
		--				str		<string>
		--	Returns:
		--				<string>
		-----------------------------------------------------------------------------------------------------------*/
		while str[1] == " " do str = substring str 2 str.count
		return str
	),
	
	fn ShortenTo str ilength showEnd:true =
	(
		/*--------------------------------------------------------------------------------------------------------------------------------------------------
		--	Prototype: 
		--		FUNCTION _mxsString.ShortenTo <string> <integer> showEnd:<boolean>
		--
		--	Remarks:
		-- 		Cuts the length of the inputed string to the desired length.  If showEnd is true, then it cuts off the beginning characters, if not, it cuts
		--		off from the end.
		--	Parameters:
		--		
		--	Return Value:
		--		Returns the shortened string	
		--------------------------------------------------------------------------------------------------------------------------------------------------*/
		if ilength < 1 then return str
		
		if str.count > ilength then
		(
			if showEnd then
			(
				local tStr = "..."
				
				for i = ( str.count - ilength ) to str.count do
				(
					tStr += str[i]
				)
				return tStr
			)
			else
			(
				local tStr = ""
				for i = 1 to iLength do
				(
					tStr += str[i]
				)
				tStr += "..."
				return tStr
			)
		)
		return str
	),
	
	fn PadNumber numberInput:undefined padInt:4 padDec:0 inNewVersion:False =
	(
		/*------------------------------------------------------------------------------------------------------------
		--	Prototype:
		--				FUNCTION _mxsString.PadNumber numberInput:undefined padInt:4 padDec:0
		--
		--	Remarks:
		--				Pads the inputed number, allowing the user to designate the number of padding spaceskew
		--				for the integer and decimal parts seperatly.
		--				Example:
		--						Convert 30 to "0030.00"
		--	Parameters:
		--				numberInput		<integer> || <float> 		Default:undefined
		--				padInt			<integer>					Default:4
		--				padDec			<integer>					Default:0
		--	Returns:
		--				<string>
		-----------------------------------------------------------------------------------------------------------*/
		tokenStringArray = filterString (numberInput as string) "."
		
		if ( inNewVersion ) then
		(
			if ( tokenStringArray.count == 2 ) then
			(
				append tokenStringArray "0"
			)
			
			tokenStringArray[1] = ( ( tokenStringArray[1] as integer ) + 1 ) as string
			tokenStringArray[2] = "0"
		)
		
		while tokenStringArray[1].count < padInt do
		(
			tokenStringArray[1] = "0" + tokenStringArray[1]
		)
		
		if tokenStringArray.count == 1 then tokenStringArray[2] = ""
			
		if padDec != 0 do
		(
			while tokenStringArray[2].count < padDec do
			(
				tokenStringArray[2] = tokenStringArray[2] + "0"
			)
		)
		if tokenStringArray[2].count > 0 do tokenStringArray[2] = "." + tokenStringArray[2]
			
		return (tokenStringArray[1] + tokenStringArray[2])
	),
	
	fn RemoveVersion inString =
	(
		/*------------------------------------------------------------------------------------------------------------
		--	Prototype:
		--				FUNCTION _mxsString.RemoveVersion inString
		--
		--	Remarks:
		--				Removes the version ( format "v00-00" ) from the end of the inputed string.
		--	Parameters:
		--				inString		<string>
		--	Returns:
		--				<string>
		--	History:
		--				- Created: EKH 05/23/06
		-----------------------------------------------------------------------------------------------------------*/
		local outString = inString
		
		if ( _mxsString.HasVersion outString ) then
		(
			local tStringList = _mxsString.GetElements inString
			outString = tStringList[1]
			for i = 2 to ( tStringList.count - 1 ) do
			(
				outString += this.elementSpacer + tStringList[i]
			)
		)
		return outString
	),
	
	-------------------------------------------------------------------------------------------------------------
	--									PARSING FUNCTIONS
	-------------------------------------------------------------------------------------------------------------
	fn GetElements 	inString = ( return ( filterstring inString this.elementSpacer ) ),	-- EKH 05/23/06
	
	fn GetComponents 	inString = ( return ( filterstring inString this.componentSpacer ) ),	-- EKH 05/23/06
	
	-------------------------------------------------------------------------------------------------------------
	--								SEARCH AND REPLACE FUNCTIONS
	-------------------------------------------------------------------------------------------------------------
	fn SearchReplaceString CurrentString: SearchString: ReplaceString: fromIndex:1 lengthIndex:0 caseSensitive:false =
	(
		/****************************************************************************************************************
		__BFNDOC__
		SearchReplaceString
		[Description Usage and Variables]
		Use this script to search and replace text in a string
		_mxsString.SearchReplaceString CurrentString: SearchString: ReplaceString: fromIndex:1 lengthIndex:0 caseSensitive:false
			CurrentString	The current string you want to seach and replace
			SearchString	The string to search for in the current string
			ReplaceString	The string you want to use to replace the text in the current string
			fromIndex		The starting point in the string to search. The default is 1
			lengthIndex	The length of the string you want to search. The default is 0
			caseSensitive	Toggel case sensitivity on/off.  The default is false
		__END__
		****************************************************************************************************************/
		if ReplaceString == undefined do (ReplaceString = "")
		
		if CurrentString == "" then return CurrentString
			
		if fromIndex > CurrentString.count then return undefined
			
		if lengthIndex == 0 then lengthIndex = (CurrentString.count - fromIndex + 1)
		
		local newStr = copy CurrentString
		
		tempString = "&`~^"
		
		while (idx = findString newStr SearchString) != undefined do
		(
			newStr = replace newStr idx SearchString.count tempString
			if keyboard.escPressed then exit
		)
		
		while (idx = findString newStr tempString) != undefined do
		(
			newStr = replace newStr idx tempString.count ReplaceString
			if keyboard.escPressed then exit
		)
		
		return newStr
	),
	
	fn FindReplaceString inString inFindString inReplaceString =
	(
		/*------------------------------------------------------------------------------------------------------------
		--	Prototype:
		--				FUNCTION _mxsString.FindReplaceString inString inFindString inReplaceString
		--
		--	Remarks:
		--				Searches the inputed inString for the given searchString, replacing it with the given
		--				replace string if found.
		--	Parameters:
		--				inString			<string>
		--				inFindString		<string>
		--				inReplaceString		<string>
		--	Returns:
		--				<string>
		-----------------------------------------------------------------------------------------------------------*/
		local findIndex = (findString inString inFindString )
		
		if findIndex != undefined then 
		(
			findReplaceString (replace inString findIndex inFindString.count inReplaceString ) inFindString inReplaceString 
		)
		else return inString 
	),
	
	fn HasVersion inString =
	(
		/*------------------------------------------------------------------------------------------------------------
		--	Prototype:
		--				FUNCTION _mxsString.HasVersion inString
		--
		--	Remarks:
		--				Checks to see if the inputed string has a version at the end of it in the form of:
		--				"v00-00"
		--	Parameters:
		--				inString		<string>
		--	Returns:
		--				<boolean>
		--	History:
		--				- Created: EKH 05/23/06
		-----------------------------------------------------------------------------------------------------------*/
		return ( GetVersion inString != -0.1 )
	),
	
	fn HasSearchString inRootString inSearchString inCaseSensitive:False inFindAllStrings:False =
	(
		/*------------------------------------------------------------------------------------------------------------
		--	Prototype:
		--				FUNCTION _mxsString.HasSearchString inRootString inSearchString inCaseSensitive:False
		--
		--	Remarks:
		--				Goes through the inputed root string checking to see if the inputed search string exists
		--				within it, being case sensitive as supplied.  The keys for the search string are "*", where
		--				no asterix means the function returns true only if the search string is found at the beginning
		--				of the root string, if there is an asterix at the end of the root string, or if there is an
		--				asterix at the beginning and end of the search string then it will return true if the search
		--				string is found anywhere within the root string.  One can supply multiple search strings by
		--				seperating the search string with commas, and the function will return true if any search strings
		--				are found within the root, or if all are found and the flag to verify all is True.
		--				Examples:
		--							inRootString:"Testing"
		--								inSearchString: "ting"			Returns:False
		--								inSearchString: "*ting"			Returns:True
		--								inSearchString: "*EST*"			Returns:True ( if inCaseSensitive == False )
		--								inSearchString: "Test,*sting"	Returns:True
		--								inSearchString: "Test,sting"	Returns:True ( if inFindAllStrings == False )
		--	Parameters:
		--				inRootString		<string>
		--				inSearchString		<string>
		--				inCaseSensitive		<boolean>		Default:False
		--				inFindAllStrings	<boolean>		Default:False
		--	Returns:
		--				<boolean>
		--	History:
		--				- Created: EKH 05/23/06
		-----------------------------------------------------------------------------------------------------------*/
		if ( inRootString == undefined or inSearchString == undefined ) then
		(
			return False
		)
		
		inRootString = inRootString as string
		
		if ( inSearchString == undefined or inSearchString == "" or inSearchString == "*" ) then
		(
			return True
		)
		
		if ( not inCaseSensitive ) then
		(
			inRootString = _mxsString.toUpper inRootString
		)
			
		local tFoundOnce = False
		local tFoundAll = True
		
		for tSearchString in ( filterstring ( inSearchString as string ) "," ) do
		(
			if ( not inCaseSensitive ) then
			(
				tSearchString 	= _mxsString.toUpper tSearchString
			)
				
			if ( tSearchString[1] == "*" and tSearchString[ tSearchString.count ] == "*" ) then
			(
				local tSearchStr = subString tSearchString 2 ( tSearchString.count - 2 )
				
				if ( findString inRootString tSearchStr != undefined ) then
				(
					tFoundOnce = True
				)
				else
				(
					tFoundAll = False
				)
			)
			else if ( tSearchString[1] == "*" ) then
			(
				local tSearchStr = subString tSearchString 2 ( tSearchString.count - 1 )
				if ( findString inRootString tSearchStr == ( inRootString.count - ( tSearchStr.count - 1 ) ) ) then
				(
					tFoundOnce = True
				)
				else
				(
					tFoundAll = False
				)
			)
			else if ( tSearchString[ inSearchString.count ] == "*" ) then
			(
				local tSearchStr = subString inSearchString 1 ( tSearchString.count - 1 )
				if ( findString inRootString tSearchStr == 1 ) then
				(
					tFoundOnce = True
				)
				else
				(
					tFoundAll = False
				)
			)
			else
			(
				if ( findString inRootString tSearchString == 1 ) then
				(
					tFoundOnce = True
				)
				else
				(
					tFoundAll = False
				)
			)
		)
		if ( inFindAllStrings ) then
		(
			return tFoundAll
		)
		else
		(
			return tFoundOnce
		)
	),
	
	fn FilterString2 inString inSearchString =
	(
		/*------------------------------------------------------------------------------------------------------------
		--	Prototype:
		--				FUNCTION _mxsString.FilterString2 inString inSearchString
		--
		--	Remarks:
		--				Parses string based on inSearchString and returns an array of strings. FilterString splits 
		--				the input string into substrings based on the string given in inSearchString
		--	Parameters:
		--				inString		<string>
		--				inSearchString	<string>
		--	Returns:
		--				<array>
		--	History:
		--				- Created: DGH 07/13/06
		-----------------------------------------------------------------------------------------------------------*/			
		local returnArray = #()
		local id = findstring inString inSearchString
	
		if (id == undefined) then 
		(
			append returnArray inString
			return returnArray 
		)
		else
		(
			append returnArray (substring inString 1 (id-1))
			join returnArray ( FilterString2 (substring inString (id + inSearchString.count) inString.count) inSearchString )
		)
		return returnArray 
	),
	
	fn SoundEx word length = 
	(
		/*--------------------------------------------------------------------------------------------------------------------
			\brief 
				Implementation of SoundEx algorithm
				
			\remarks
				Soundex is a phonetic algorithm for indexing names by their sound when pronounced in English. The basic aim 
				is for names with the same pronunciation to be encoded to the same string so that matching can occur despite 
				minor differences in spelling. Soundex is the most widely known of all phonetic algorithms and is often used 
				(incorrectly) as a synonym for "phonetic algorithm".
				
		--------------------------------------------------------------------------------------------------------------------*/
		
		
		-- Value to return
		local result = ""
				
		-- Size of the word to process
		local size = word.count
				
		-- Make sure the word is at least two characters in length
		if (size > 1) then
		(
			-- Convert the word to all uppercase
			word = ToUpper word
						
			-- Convert the word to character array for faster processing
			local chars = word
						
			-- Buffer to build up with character codes
			local buffer = ""
			
			-- The current and previous character codes
			local prevCode = 0
			local currCode = 0					
			
			-- Append the first character to the buffer
			buffer += chars[1]
						
			-- Loop through all the characters and convert them to the proper character code
			local zeroBased = #("A", "E", "I", "O", "U", "H", "W", "Y")
			local oneBased = #("B","F","P","V")
			local twoBased = #("C","G","J","K","Q","S","X","Z")
			local threeBased = #("D", "T")
			local fourBased = #("L")
			local fiveBased = #("M", "N")
			local sixBased = #("R")
		
			local sCode = #( zeroBased , oneBased , twoBased , threeBased , fourBased , fiveBased , sixBased )		
			
			for i = 2 to size do
			(
				for j = 1 to sCode.count do
				(
					if finditem sCode[j] chars[i] != 0 then
					(
						currCode = (j-1)
						exit
					)
				)
						
				-- Check to see if the current code is the same as the last one
				if (currCode != prevCode) then
				(
					-- Check to see if the current code is 0 (a vowel) do not process vowels
					if (currCode != 0) then
					(
						buffer += (currCode as string)
					)
				)
	
				-- Set the new previous character code
				prevCode = currCode
								
				-- If the buffer size meets the length limit, then exit the loop
				if (buffer.count == length) then exit
			)
			
			-- Pad the buffer, if required
			size = buffer.count
			if (size < length) then
			(
				for i = 1 to (length-size) do buffer += "0"
			)
			
			-- Set the result to return
			result = buffer
		)
		
		-- Return the result
		return result
	),
	
	fn makePythonSafe str =
	( 
		str = substitutestring str "\\\\" "\\"
	),
	
	fn SplitString str splitchr =
	(
		str = this.makePythonSafe str
		splitchr = this.makePythonSafe splitchr
		
		python.execute ("word = '" + str + "'")
		python.execute ("word = word.split('" + splitchr + "')")
		python.execute ("newword = '#(\"' + word[0] + '\"'")
		python.execute ("for w in word[1:]: newword += ',\"' + w + '\"'")
		python.execute ("newword += ')'")
		python.execute ("MaxPlus.Core.EvalMAXScript('_mxsStringOutput = ' + newword)")
		_mxsStringOutput
	),
	
	fn GetModule =
    (
        ( GetSourceFileName() )
    ),

    fn Help =
    (
        ::_mxs.GetScriptHelp ( this.GetModule() )
    ),

    private fn _init =
    (
        -- Pass
    ),

    __init__ = _init()
)

_mxsString = mxsString()
