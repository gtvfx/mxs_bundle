/*!
	\file			mxsLib.ms

	\remarks		GTVFX appropriation of blur 3dsmax code library. 
	
	\author		Gavyn Thompson
	\author		Email: gthompson@gtvfx.com
	\author		Company:gtvfx
	\date			05/11/2015
	
*/

--global _ToolListXML
global MONTHS = #("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")


global mxs

(
	struct SimpleDict
	(
		m_keys = #(),
		m_values = #(),
		count = 0,
		
		fn Clear = 
		(
			m_keys = #()
			m_values = #()
			count = 0
		),
		
		fn GetValue inKey =
		(
			for i = 1 to m_keys.count do
			(
				if ( toLower ( inKey as string ) == toLower ( m_keys[i] as string ) ) then
				(
					return ( m_values[i] )
				)
			)
			return ""
		),
		
		fn HasKey inKey =
		(
			local out = undefined
			if ( ::mxs.debugLevel > 0 ) then
			(
				format "HasKey() searching m_keys for inKey: %\n" inKey inValue
				print ("m_keys: " + m_keys as string)
			)
			out = ( findItem m_keys ( toLower ( inKey as string ) ) != 0 )
			out
		),
		
		fn keys = ( return m_keys ),
		
		fn SetValue inKey inValue =
		(
			if ( ::mxs.debugLevel > 0 ) then format "::mxs.SetValue() inkey: % inValue: %\n " inKey inValue
			for i = 1 to m_keys.count do
			(
				if ( toLower ( inKey as string ) == toLower ( m_keys[i] as string ) ) then
				(
					m_values[i] = inValue
					return True
				)
			)
			append m_keys inKey
			append m_values inValue
			count = m_keys.count
		),
		
		fn values = ( return m_values )
	)
	
	struct mxsCallback
	(
		type,
		command = "",
		id,
		filename
	)
	
	-------------------------------------------------------------------------------------------------------------
	--								DEFINE LIBRARY FUNCTIONALITY
	-------------------------------------------------------------------------------------------------------------
	
	struct externalLibraryStruct
	(
		/*!--------------------------------------------------------------------
			\remarks Tracks externally loaded _libraries
		---------------------------------------------------------------------*/
		name = "",
		relativePath = ""
	)
	
	struct EnvironmentClass
	(
		/*!--------------------------------------------------------------------
			\remarks Stores environment paths
		---------------------------------------------------------------------*/
		name			= "",
		paths			= SimpleDict(),
		
		fn GetPath pathID =
		( 
			/*!--------------------------------------------------------------------
				\remarks	
					Gets the path whose ID matches the inputed string, or an empty
					string if none is found
				
				\param		pathID		<string>
			
				\history
					- EKH 11/16/06: Created
			
				\return				
					<string>
			---------------------------------------------------------------------*/
			pathID = toLower ( pathID as string )
			
			if ( paths.HasKey pathID ) then
			(
				return paths.GetValue pathID
			)
			
			return ""
		),
		
		fn GetPathIDs =
		(
			/*!--------------------------------------------------------------------
				\remarks	
					Returns the paths keys - path IDs for this environment
				\history
					- EKH 11/16/06: Created
				\return				
					<array>[ <string>, .. ]
			---------------------------------------------------------------------*/
			return paths.keys()
		),
		
		fn SetPath pathID path =
		(
			/*!--------------------------------------------------------------------
				\remarks	
					Sets the path ID's path value ( all path ID's are converted
					to lower case strings )
				
				\param		pathID		<string>
				\param		path		<string>
			
				\history
					- EKH 11/16/06: Created
			---------------------------------------------------------------------*/
			paths.SetValue ( toLower ( pathID as string ) ) path
		)
	)
	
	struct mxsLibraryStruct
	(
		------------------------------------------------------------------------------
		--							PUBLIC MEMBERS
		------------------------------------------------------------------------------
		configFile,
		
		max_version = ( MaxVersion() )[1],
		
		major = 0,
		minor = 1,
		reloadedLibs = #(),
		classID = "mxsLib",
		printStatus = false,
		debugLevel = 0,
		
		toollist = #(),
		
		------------------------------------------------------------------------------
		--							PRIVATE MEMBERS
		------------------------------------------------------------------------------
		_environments = SimpleDict(),
		_activeEnvironment = "",
		
		_libraries = #(),
		_constantLibraries = #( "mxsLib", "mxsString" ),
		_externals = #(),
		
		_callbackTypes = #(),
		_callbackIDs = #(),
		_callbackArray = #(),
		
		_blockCount_matEditor = 0,
		_blockCount_renderSceneDialog = 0,
		_blockState_renderSceneDialog = undefined,
		_blockCount_sceneRedraw = 0,
		_blockCount_cmdPanel = 0,
		_blockState_cmdPanel = undefined,
		_blockCount_cursor = 0,
		_blockStack = #(),
		------------------------------------------------------------------------------
		--							PUBLIC METHODS
		------------------------------------------------------------------------------
		
		fn _normEnv environmentID =
		(
			/*!--------------------------------------------------------------------
				\remarks	
					Normalizes inputed environmentID.  Function is setup for backwards
					compatibility, setting code path 'local' and 'network' to work with
					new environments and turns the ID to lowercase
				
				\param		environmentID 		<string>
			
				\history
					- EKH 11/16/06: Created
			
				\return				
					<string>
			---------------------------------------------------------------------*/
			if ( this.debugLevel > 4 ) then format "_normEnv() environmentID: %\n" (if environmentID == "" then "\"\"" else environmentID)
			
			if ( environmentID == "" ) then
			(
				if ( this.debugLevel > 4 ) then format "\tenvironmentID blank, assuming _activeEnvironment: %\n" this._activeEnvironment
				environmentID = this._activeEnvironment
			)
			
			if ( this.debugLevel > 4 ) then format "\tnormalized environmentID: %\n" (if environmentID == "" then "\"\"" else environmentID)

			outEnvironmentID = toLower environmentID
			
			if ( this.debugLevel > 4 ) then format "\tout: %" (if outEnvironmentID == "" then "\"\"" else outEnvironmentID)
				
			return outEnvironmentID
		),
		
		fn _normPath inPath inPathSeparator:"/" =
		(
			/*!--------------------------------------------------------------------
				\remarks	
					Normalizes the inputed path, separating folders by the given
					string
				
				\param		inPath				<string>
				\param		inPathSeparator		<string>
				
				\history
						- Created: EKH 04/17/06
				
				\return				
					<string>
			---------------------------------------------------------------------*/
			if ( inPath == "" or inPath == undefined ) then
			(
				return ""
			)
				
			local tUNCHeader = ""
			
			if ( inPath[1] == "\\" and inPath[2] == "\\" ) then
			(
				tUNCHeader = "\\\\"
			)
				
			local tPathList = filterstring inPath "\\/"
			
			outPath = tUNCHeader
			
			for i = 1 to tPathList.count do
			(
				outPath += tPathList[i] + inPathSeparator
			)
			
			return outPath
		),
		
		fn blockUi state flags:unsupplied =
		(
			/*!--------------------------------------------------------------------
			\remarks
				stacks calls to disable common ui elements
				
			\param		state		<boolean>
			\param		state		<name>|<nameArray>
				
			\return
				<array>
			---------------------------------------------------------------------*/
	 		flags = if flags == unsupplied then #(#all) else flags
	 		if classof flags != Array then flags = #(flags)	

			if ( state ) then
			(
				if ( finditem flags #all != 0 ) then
				(
					flags = #(#mateditor,#renderSceneDialog,#sceneRedraw,#cmdPanel)
				)
				append _blockStack flags

				-- store each flag option as its own counter.  for dialogs that open and close, only add the count 
				-- if the dialog is open or there's already a count in progress.
				( _blockCount_cursor += 1 )
				
				-- for any counter that just became 1, block the ui
				if _blockCount_cursor == 1 then
				(
					setWaitCursor()
				)
				
				if ( findItem flags #sceneRedraw != 0 ) then
				( 
					_blockCount_sceneRedraw += 1 
					if _blockCount_sceneRedraw == 1 then
					(
						disablesceneredraw()
					)
				)
				
				if ( findItem flags #cmdPanel != 0 ) then
				( 
					_blockCount_cmdPanel += 1
					if _blockCount_cmdPanel == 1 then
					(
						_blockState_cmdPanel = getCommandPanelTaskMode()
						if _blockState_cmdPanel != #create then setCommandPanelTaskMode #create
					)
				)
				
				if ( findItem flags #mateditor != 0 and (_blockCount_matEditor > 0 or matEditor.isOpen()) ) then
				( 
					_blockCount_matEditor += 1
					if _blockCount_matEditor == 1 then
					(
						matEditor.close()
					)					
				)
				
				if ( findItem flags #renderSceneDialog 	!= 0 and (_blockCount_renderSceneDialog > 0 or renderSceneDialog.isOpen()) ) then
				( 
					_blockCount_renderSceneDialog += 1
					if _blockCount_renderSceneDialog == 1 then
					(
						_blockState_renderSceneDialog = ( tabbedDialogs.getCurrentPage #render )
						renderSceneDialog.close()
					)
				)
			)
			else if ( _blockStack.count > 0 ) then
			( -- make sure we have some stuff to unblock
				
				local lastFlagSet = _blockStack[_blockStack.count]
				
				-- remove the last item from the stack
				deleteItem _blockStack _blockStack.count
				
				-- decrement any of the flags if they aren't already at 0
				if ( findItem lastFlagSet #sceneRedraw 	!= 0 and _blockCount_sceneRedraw 	> 0 ) then
				(
					_blockCount_sceneRedraw -= 1
					-- if the item just became 0, unblock it/open it
					if _blockCount_sceneRedraw 	== 0 then
					(
						while isSceneRedrawDisabled() do enableSceneRedraw()
						-- GK 10/14/11 this call is not updating the viewport camera label (max 2010) so it appears that the camera has not switched
						-- trying a safeframe toggle to work around this
						redrawViews()
						max safeframe toggle
						max safeframe toggle
					)
				)
				
				if ( findItem lastFlagSet #cmdPanel != 0 and _blockCount_cmdPanel > 0 ) then
				( 
					_blockCount_cmdPanel -= 1
					if _blockCount_cmdPanel == 0 then
					(
						setCommandPanelTaskMode _blockState_cmdPanel
						_blockState_cmdPanel = undefined
					)
				)
				
				if ( findItem lastFlagSet #mateditor != 0 and _blockCount_matEditor > 0 ) then
				( 
					_blockCount_MatEditor -= 1 
					if _blockCount_matEditor == 0 then
					(
						matEditor.open()
					)
				)
				
				if ( findItem lastFlagSet #renderSceneDialog != 0 and _blockCount_renderSceneDialog > 0 ) then
				(
					_blockCount_renderSceneDialog -= 1
					if _blockCount_renderSceneDialog == 0 then
					(
						renderSceneDialog.open()
						tabbedDialogs.SetCurrentPage #render _blockState_renderSceneDialog
						_blockState_renderSceneDialog = undefined
					)
				)
				
				if _blockCount_cursor > 0 then
				(
					_blockCount_cursor -= 1
					if _blockCount_cursor == 0 then
					(
						setArrowCursor()
					)
				)
			)
			
			_blockStack
		),
		
		fn ClearGlobal inString =
		( 
			/*!--------------------------------------------------------------------
				\remarks	
					Clears the global value by setting it to undefined
				
				\param		inString		<string>
				
				\history
						- EKH 04/17/06: Created
						- EKH 11/28/06: Now uses globalVars struct
			---------------------------------------------------------------------*/
			
			execute ( ( inString as string ) + " = undefined" )
		),
		
		fn ClearLibrary inLibName =
		(
			/*!--------------------------------------------------------------------
				\remarks	
					Clears the global variable associated with the inputed library
					name, thus setting it to undefined and removing it from data.
					Also removes the library ID from the library list
				
				\param		inLibName		<string>
				
				\history
						- EKH 04/17/06: Created
				
				\return				
					<boolean>
			---------------------------------------------------------------------*/
			local tIndex = findItem this._libraries inLibName
			
			if ( tIndex > 0 ) then
			(
				if ( this.printStatus ) then
				(
					print ( "Clearing Library: " + inLibName + "." )
				)
				
				this.ClearGlobal inLibName
				deleteItem this._libraries tIndex
				return True
			)
			
			return False
		),
		
		fn ClearExternalLibrary inLibName =
		(
			/*!--------------------------------------------------------------------
				\remarks	
					Clears the external library (not found withing the root
					library path) from data and from the externals list
				
				\param		inLibName		<string>
				
				\history
						- Created: EKH 04/17/06
				
				\return				
					<boolean>
			---------------------------------------------------------------------*/
			local tIndex = 0
			
			for i = 1 to this._externals.count do
			(
				if ( this._externals[i].name == inLibName ) then
				(
					tIndex = i
					exit
				)
			)
			
			if ( tIndex > 0 ) then
			(
				if ( this.printStatus ) then
				(
					print ( "Clearing External: " + inLibName + "." )
				)
				
				this.ClearGlobal inLibName inIsLibrary:True
				
				deleteItem this._externals tIndex
				return True
			)
			
			return False
		),
		
		fn ClearLibraries inClearLocals:True inClearExternals:True =
		(
			/*!--------------------------------------------------------------------
				\remarks	
					Sets all the global library variables that are loaded to being
					undefined and then clears the library array.
				
				\param		inClearLocals		<boolean>
				\param		inClearExternals	<boolean>
				
				\history
						- Created: EKH 04/17/06
			---------------------------------------------------------------------*/
			if ( this.debugLevel > 0 ) then 	format "ClearLibraries() inClearLocals: % inClearExternals: %\n" inClearLocals inClearExternals
			
			if inClearLocals then
			(
				for index = this._libraries.count to 1 by -1 do
				(
					local tLibName = this._libraries[index]
					this.ClearLibrary tLibName
				)
			)
			
			if inClearExternals then
			(
				for tExternal in this._externals do
				(
					this.ClearExternalLibrary tExternal.name
				)
			)
		),
		
		fn Dir inLibName inPrintTo: =
		(
			/*!--------------------------------------------------------------------
				\remarks	
					Displays info about the library specified
				
				\param		inLibName		<string>
				\param		printTo			<windostream> | <filestream> | <stringstream>
				
				\history
					- Created: DGH 06/16/06
				
				\return				
					<string>
			---------------------------------------------------------------------*/
			local libinfo = stringstream ""
				
			local tLibraryStr = inLibName
			if (execute tLibraryStr == undefined ) then
			(
				this.load inLibName
			)
			
			local tLib = execute tLibraryStr
			
			if (ClassOf tLib) == StructDef then
			(
				tLib = tLib()
			)
		
			local pFuncs = #()
			local pPrivateFuncs = #()
			local pVars = #()
			local pPrivateVars = #()
			
			local pNames = getpropnames tLib
			for p in pNames do
			(
				p = p as string
				local pValue = getproperty tLib p
				if (classof pValue == MAXScriptFunction) then
				(
					if (findstring p "__" != undefined)	then
					(
						append pPrivateFuncs p
					)
					else
					(
						append pFuncs p
					)
				)
				else
				(
					if (findstring p "__" != undefined)	then
					(
						append pPrivateVars p
					)
					else
					(
						append pVars p
					)
				)
			)			
			-- print all the info collected about the library
			format "---------------------------------------\n" to:libinfo 
			format "MXS Library: %\n" inLibName  to:libinfo 
			format "---------------------------------------\n" to:libinfo 
			
			for p in pPrivateFuncs do
			(	
				local pValue = getproperty tLib p
				format "[PrivateFN] %\n" (p as string) to:libinfo 
			)
			
			for p in pPrivateVars do
			(	
				local pValue = getproperty tLib p
				format "[Private Var] % = %\n" (p as string) pValue to:libinfo 
			)
			
			for p in pVars do
			(	
				local pValue = getproperty tLib p
				format "[Var] % = %\n" (p as string) pValue to:libinfo 
			)
			
			for p in pFuncs do
			(	
				local pValue = getproperty tLib p
				format "[FN] %\n" (p as string) to:libinfo 
			)
			
			if inPrintTo == unsupplied then
			(
				inPrintTo = Listener
			)
			
			format "%\n" libinfo to:inPrintTo
			
			--return libinfo 		
		),
		
		fn Debug inItem inIncludeHead:true inIndent:"" inPrintTo: =
		(
			/*!--------------------------------------------------------------------
				\remarks	
					Displays info about the item specified
				
				\param		inItem			<object> | <property> | <struct>	Item to debug
				\param		inIncludeHead	<boolean>							Includes info about the item name
				\param		inIndent		<string>							Amount of indentation
				\param		inPrintTo		<windostream> | <filestream> | <stringstream>
				
				\history
					- Created: DGH 06/27/06
				
				\return				
					<string>
			---------------------------------------------------------------------*/
			
			local info = stringstream ""
			
			if inPrintTo == unsupplied then
			(
				info = listener
			)
				
			local pFuncs = #()
			local pPrivateFuncs = #()
			local pVars = #()
			local pStructs = #()
			local pPrivateVars = #()
			
			local pNames = try(getpropnames inItem)catch(#())
				
			for p in pNames do
			(
				p = p as string
				local pValue = getproperty inItem p
				if (classof pValue == MAXScriptFunction) then
				(
					if (findstring p "__" != undefined)	then
					(
						append pPrivateFuncs p
					)
					else
					(
						append pFuncs p
					)
				)
				else if (superclassof pValue == StructDef) or (classof pValue == StructDef) then
				(
					append pStructs p
				)
				else
				(
					if (findstring p "__" != undefined)	then
					(
						append pPrivateVars p
					)
					else
					(
						append pVars p
					)
				)
			)
			
			with printAllElements on
			(
				-- print all the info collected about the library
				if (includeHead == true) then 
				(
					format "%---------------------------------------\n" inIndent to:info 
					if (superclassof inItem == StructDef) then
					(
						format "%%\n" inIndent ((filterstring ((classof inItem) as string) "#:(")[2]) to:info
					)
					else if (classof inItem == StructDef) then
					(
						format "%%\n" inIndent ((filterstring (inItem as string) "#:(")[2]) to:info
					)
					else
					(
						format "%%\n" inIndent inItem  to:info
					)
					format "%---------------------------------------\n" inIndent to:info 
				)
			
				if (pPrivateFuncs.count >0) then
				(
					format "\n" to:info
				)
				
				for p in pPrivateFuncs do
				(	
					local pValue = getproperty inItem p
					format "%[PrivateFN] %\n" inIndent (p as string) to:info 
				)
			
				if (pPrivateVars.count >0) then
				(
					format "\n" to:info
				)
				
				for p in pPrivateVars do
				(	
					local pValue = getproperty inItem p
					format "%[Private Var] % = %\n" inIndent (p as string) pValue to:info 
				)	
			
				if (pVars.count >0) then
				(
					format "\n" to:info
				)
				
				for p in pVars do
				(	
					local pValue = getproperty inItem p
					format "%[%] % = %\n" inIndent (classof pValue) (p as string) pValue to:info 
				)
			
				if (pFuncs.count >0) then
				(
					format "\n" to:info
				)
				
				for p in pFuncs do
				(	
					local pValue = getproperty inItem p
					format "%[FN] %\n" inIndent (p as string) to:info 
				)
				
				if (pStructs.count >0) then
				(
					format "\n" to:info
				)
				
				for p in pStructs do
				(	
					local pValue = getproperty inItem p
					local pStructStr = this.debug pValue inIndent:(inIndent + "\t") inIncludeHead:false inPrintTo:info
					format "%[STRUCT] %\n%\n" inIndent ((filterstring ((classof pValue) as string) "#:(")[2]) (pStructStr as string) to:info 
					--format "[FN] %\n" (p as string) to:info 
				)
			)
			
			return (info as string)		
		),
		
		fn GetCodeDataPath inEnvironment:"" =
		(
			/*!--------------------------------------------------------------------
				\remarks	
					Returns the global code root data directory
			
				\history
						- EKH 04/17/06: Created
						- EKH 11/16/06: Added inEnvironment variable - works with latest config setup
				
				\sa GetPath
				
				\return				
					<string>
			---------------------------------------------------------------------*/
			return ( this.GetPath #dataRoot inEnvironment:inEnvironment )
		),
		
		fn GetCodePath inEnvironment:"" =
		(
			/*!--------------------------------------------------------------------
				\remarks	
					Returns the current code root path directory
			
				\history
					- EKH 04/17/06: Created
					- EKH 11/16/06: Changed to work with GetPath for the codeRoot key
				
				\sa GetPath
			
				\return				
					<string>
			---------------------------------------------------------------------*/
			pathconfig.NormalizePath ( this.GetPath #MXS_CODEROOT inEnvironment:inEnvironment )
		),
		
		fn GetCurEnv =
		(
			/*!--------------------------------------------------------------------
				\remarks	
					Returns the current active environment ID
			
				\history
					- EKH 04/17/06: Created
			
				\return				
					<string>
			---------------------------------------------------------------------*/
			return ( this._ActiveEnvironment )
		),
		
		fn GetToolPath inEnvironment:"" =
		(
			/*!--------------------------------------------------------------------
				\remarks	
					Returns the current code root path directory
			
				\history
					- EKH 04/17/06: Created
					- EKH 11/16/06: Changed to work with GetPath for the codeRoot key
				
				\sa GetPath
			
				\return
					<string>
			---------------------------------------------------------------------*/
			
			local codePath = this.GetCodePath()
			--codePath = (substituteString (PathConfig.removePathLeaf codePath) "\\" "/")
			
			pathConfig.NormalizePath (codePath + "/tools/")
		),
		
		fn GetUserDir env:#local =
		(
			local userDir = undefined
			
			case env of
			(
				(#network):
				(
					userDir = (( this.GetNetRoot() ) + @"" + sysInfo.userName )
					if not doesFileExist userDir then makeDir userDir
					userDir
				)
				(#local):
				(
					userDir = systemTools.getEnvVariable "USERPROFILE"
					userDir
				)
			)
		),
		
		fn GetLibPath =
		(
			/*!--------------------------------------------------------------------
				\remarks	
					Returns the current Lib root path directory
			
				\history
					-  10/20/2014: Created
				
				\sa GetCodePath
			
				\return				
					<string>
			---------------------------------------------------------------------*/
			(this.GetCodePath() + "Lib/")
		),
		
		fn GetPyLibPath =
		(
			out = ((this.GetPath #maxpython)+@"\lib")
			if DoesFileExist out then out else Undefined
		),
		
		fn GetSysEnv =
		(
			(dotNetClass "System.Environment")
		),
		
		fn GetEnvTarget =
		(
			(dotNetClass "System.EnvironmentVariableTarget")
		),
		
		fn GetUserConfigFile =
		(
			--out = (systemTools.getEnvVariable("USERPROFILE") + @"\AppData\Local\Autodesk\3dsMax\2013 - 64bit\ENU\mxsLibConfig.ini")
			if DoesFileExist ::mxsConfigFile then ::mxsConfigFile else messageBox ("Config file does not exist at\n"+ out) title:"File not found:"
		),
		
		fn GetNetRoot =
		(
			/*!--------------------------------------------------------------------
				\remarks	
					Returns the network root
					
				\history
					-  10/20/2014: Created
					
				\sa GetCodePath
					
				\return			
					<string>
			---------------------------------------------------------------------*/
			
			local out = undefined
			
			if ( this.max_version > 18000 ) then
			(
				
			)
			else
			(
				out = ( GetINISetting ( this.GetUserConfigFile() ) (this.GetCurEnv()) "netRoot" )
			)
			
			out
		),
		
		fn EnsureArgIsArray arg =
		(
			if ( ClassOf arg ) == ObjectSet then
			(
				arg = ( arg as array )
			)
			else if ( ClassOf arg ) != Array then
			(
				arg = #(arg)
			)
			
			arg
		),
		
		fn GetScriptHeader scriptFile =
		(
			GetStringBlock scriptFile "*__MXSDOC__*" "*__END__*" filterFromStr:True filterToStr:True
		),

		fn GetScriptHelp scriptFile =
		(
			GetStringBlock scriptFile "*__Help__*" "*__END__*" filterFromStr:False filterToStr:True
		),
		
		fn OpenUserConfigFile =
		(
			shellLaunch "notepad++.exe" (this.GetUserConfigFile())
		),
		
		fn ImportPythonFile fName =
		(
			local libPath = this.GetPyLibPath()
			if libPath != undefined then
			(
				local pyFile = (libPath+"\\"+fName+".py")
				if DoesFileExist pyFile then
				(
					python.executefile (libPath+"\\"+fName+".py")
				)
				else
				(
					undefined
				)
			)
			else
			(
				undefined
			)
		),
		
		fn GetEnvironment inEnvironment:"" =
		(
			/*!--------------------------------------------------------------------
				\remarks	
					Gets the environment instance that matches the inputed ID, if
					one exists, otherwise returns undefined
				
				\param		inEnvironmentID 	<string>
			
				\history
					- EKH 04/17/06: Created
					- EKH 11/16/06: Environments are no longer single string dictionaries,
									no longer returns string, returns EnvironmentClass
			
				\return				
					<EnvironmentClass> | undefined
			---------------------------------------------------------------------*/
			local out = undefined
			
			if ( this.debugLevel > 0 ) then print ("GetEnvironment() inEnvironment: " + (if inEnvironment == "" then "unsupplied" else inEnvironment))
				
			local inEnvironmentID = this._normEnv inEnvironment
				
			if ( this._environments.HasKey inEnvironmentID ) then
			(				
				out = this._environments.GetValue inEnvironmentID
			)
			
			if ( this.debugLevel > 0 ) then print ("GetEnvironment() out: " + out as string)
			
			out
		),
		
		fn GetExternalLibrary inLibName =
		(
			/*!--------------------------------------------------------------------
				\remarks	
					Gets the external library instance whose name matches the
					inputed string
				
				\param		inLibName		<string>
			
				\history
					- EKH 04/17/06: Created
					
				\sa GetExternalLibraryIndex
			
				\return				
					<externalLibraryStruct> | undefined
			---------------------------------------------------------------------*/
			
			local tIndex = this.GetExternalLibraryIndex inLibName
			local out = undefined
			if ( tIndex > 0 ) then
			(
				out = this._externals[ tIndex ]
			)
			out
		),
		
		fn GetExternalLibraryIndex inLibName =
		(
			/*!--------------------------------------------------------------------
				\remarks	
					Gets the index of the library struct instance in the _externals
					list whose name matches the inputed string.  Returns 0 if not
					found
				
				\param		inLibName		<string>
				
				\history
					- EKH 11/16/06: Created
				
				\return		
					<integer>
			--------------------------------------------------------------------*/
			local out = 0
			
			for tIndex = 1 to this._externals.count do
			(
				if this._externals[ tIndex ].name == inLibName then
				(
					out = tIndex
					exit
				)
			)
			
			out
		),
		
		fn GetLoadedLibraries inIncludeLocals:True inIncludeConstants:True inIncludeExternals:True =
		(
			/*!--------------------------------------------------------------------
				\remarks	
					Returns the names of the libraries that are currently loaded
				
				\param		inIncludeLocals		<boolean>		Includes the local libraries in the output list
				\param		inIncludeConstants	<boolean>		Includes the constant libraries in the output list
				\param		inIncludeExternals	<boolean>		Includes the external libraries in the output list
			
				\history
					- EKH 04/17/06: Created
			
				\return				
					<array>[ <string>, .. ]
			---------------------------------------------------------------------*/
			local outList = #()
			
			if ( inIncludeLocals ) then
			(
				join outList this._libraries
			)
			if ( inIncludeConstants ) then
			(
				join outList this._constantLibraries
			)
			if ( inIncludeExternals ) then
			(
				join outList ( for tExternal in this._externals collect tExternal.name )
			)
				
			return outList
		),
		
		fn GetPlugPath inEnvironment:"" inAutoGenerate:False =
		(
			/*!--------------------------------------------------------------------
				\remarks	
					Gets the max plugin path in the given environment.  If the auto generate
					variable is set to true, then the plugin folder will automatically be
					created if it doesnt already exist.
				
				\param		inEnvironment		<string>
				\param		inAutoGenerate		<boolean>
			
				\history
					- EKH 04/17/06: Created
					- EKH 11/16/06: Added inEnvironment variable to set what environment to get the path from
			
				\return				
					<string>
			---------------------------------------------------------------------*/
			local codePlugPath = this.GetPath #maxPlugPath inEnvironment:inEnvironment
			
			if ( inAutoGenerate and not DoesFileExist( codePlugPath ) ) then
			(
				local tFileArr = filterString codePlugPath "/"
				local tDir = ""
				for tPart in tFileArr do
				(
					tDir += tPart + "/"
					if ( not DoesFileExist( tDir ) ) then
					(
						makeDir ( tDir )
					)
				)
			)
			return codePlugPath
		),
		
		fn GetPath inPathID inEnvironment:"" inPathSeparator:"/" =
		(
			/*!--------------------------------------------------------------------
				\remarks	
					Gets the path value for the given ID.  If no environment is specified
					then the current active environment is used, seperating the outpued
					folders/path using the given string
				
				\param		inPathID			<string>
				\param		inEnvironment		<string>
				\param		inPathSeparator		<string>
			
				\history
					- EKH 04/17/06: Created
					- EKH 11/16/06: Added inEnvironment variable to get paths of a different environment
			
				\return				
					<string>
			---------------------------------------------------------------------*/
			if ( this.debugLevel > 0 ) then
			(
				print ("[mxsLib] " + getSourceFilename())
				format "GetPath() inPathID: % inEnvironment: %\n" inPathID inEnvironment
			)
			
			local out = undefined
			
			local outPath 		= ""
			local tEnvironment 	= this.GetEnvironment inEnvironment:inEnvironment
			
			if ( tEnvironment != undefined ) then
			(
				outPath = tEnvironment.GetPath inPathID
			)
			
			if ( outPath == "" ) then
			(
				tDefaultEnv = this.GetEnvironment inEnvironment:"default"
				if ( tDefaultEnv != undefined ) then
				(
					outPath = tDefaultEnv.GetPath inPathID
				)
			)
			
			if ( this.debugLevel > 0 ) then format "\toutPath: %\n" outPath
			
			outPath = ( this.RemovePathTemplates outPath inEnvironment:inEnvironment )
			
			out = this._normPath outPath inPathSeparator:inPathSeparator
			out
		),
		
		fn GetPathIDs inEnvironment:"" =
		( 
			/*!--------------------------------------------------------------------
				\remarks	
					Gets the path IDs available for the given environment, using the current
					active environment if non is specified
				
				\param		inEnvironment		<string>
			
				\history
					- EKH 04/17/06: Created
					- EKH 11/16/06: Updated to work with the new Environment model
			
				\return				
					<array>[ <string>, .. ]
			---------------------------------------------------------------------*/
			local tEnvironment = this.GetEnvironment inEnvironment:inEnvironment
			local tDefaultEnv = this.GetEnvironment inEnvironment:::_codeEnv -- "default"
			
			local outPathIDs = tDefaultEnv.GetPathIDs()
			
			if ( tEnvironment != undefined ) then
			(
				for tPathID in tEnvironment.GetPathIDs() where ( findItem outPathIDs tPathID == 0 ) do
				(
					append outPathIDs tPathID
				)
			)
			
			return outPathIDs
		),
		
		fn GetEnvironmentIDs =
		( 
			/*!--------------------------------------------------------------------
				\remarks	
					Gets the loaded environment IDs
			
				\history
					- EKH 04/17/06: Created
			
				\return				
					<array>[ <string>, .. ]
			---------------------------------------------------------------------*/
			return this._environments.keys()
		),
		
		fn IsLoaded inString =
		( 
			/*!--------------------------------------------------------------------
				\remarks	
					Checks to see if the given string variable is assigned
				
				\param		inString		<string>
			
				\history
					- EKH 04/17/06: Created
			
				\return				
					<boolean>
			---------------------------------------------------------------------*/
			return ( execute ( ( inString as string ) + " != undefined " ) )
		),
		
		fn IsOffsite =
		( 
			/*!--------------------------------------------------------------------
				\remarks	
					Checks to see if the current active environment is offline
			
				\history
					- EKH 04/17/06: Created
			
				\return				
					<boolean>
			---------------------------------------------------------------------*/
			return this._activeEnvironment == "offline"
		),
		
		fn IsPath pathID inEnvironment:"" =
		(
			/*!--------------------------------------------------------------------
				\remarks	
					Checks to see if the inputed string is a path ID in the given
					environment, using the active environment if none is specified
				
				\param		pathID			<string>
				\param		inEnvironment	<string>
			
				\history
					- EKH 11/16/06: Created
				
				\sa GetPathIDs
				
				\return				
					<boolean>
			---------------------------------------------------------------------*/
			return ( findItem ( this.GetPathIDs inEnvironment:inEnvironment ) ( toLower ( pathID as string ) ) != 0 )
		),
		
		fn GetMaxPlugPath = 
		(
			local tPlugPath = this.GetPath #pluginsroot
			
			if tPlugPath == "" then
			(
				tPlugPath = ( (GetDir #maxroot) + "plugins" )
			)
				
			return tPlugPath 	
		),
		
		fn FindLibFile inLibName inRelativePath:unsupplied =
		(
			local pathArr = ( FilterString ( this.GetPath #MXS_PATH ) "," )
			
			for p in pathArr do
			(
				if p[p.count] != "/" then p = ( p + "/" )
				
				local fileArr = GetFiles ( p + "*.ms*" )
				local nameFileArr = for f in fileArr where ( matchPattern ( GetFileNameFile f ) pattern:inLibName ) collect f
				
				if nameFileArr.count == 1 then
				(
					return nameFileArr[1]
				)
				else if nameFileArr.count > 1 then
				(
					format "More than one file matching that name was found.\n%\n" nameFileArr
				)
			)
			
			undefined
		),
		
		fn Load inLibName inAbsPath:unsupplied inRelativePath:unsupplied inLoadAsConstant:False inReload:( keyboard.escPressed ) =
		(
			/*!--------------------------------------------------------------------
				\remarks	
					Loads the inputed library ( if the file exists ) from the 
					current code path library directory, only if that library
					is not currently loaded or if the Reload flag is true.  If
					the inputed string is flagged as not being a library file,
					then the function will load the inputed string file using
					the current code path as the base.
				
				\param	inLibName			<string>
				\param	inRelativePath		<string>	Default:"Lib/"
				\param	inOLESignature		<string>	Default:""
				\param	inLoadAsConstant	<boolean>	Default:False
				\param	inReload			<boolean>	Default:False
			
				\history
					- EKH 04/17/06: Created
					- EKH 11/28/06: Now uses globalVars for variable definition and returns library variable
			
				\return				
					<variant> LibraryVariable | undefined Failure
			---------------------------------------------------------------------*/
			
			local tLoadAsExternal = ( inRelativePath != unsupplied )
			local tFileStr = undefined
			
			if ( inAbsPath != unsupplied ) and ( DoesFileExist inAbsPath ) then
			(
				tFileStr = ( inAbsPath + "\\" + inLibName + ".ms" )
				if ( not DoesFileExist tFileStr ) then
				(
					return ( messageBox ( "File does not exist:\n" + tFileStr ) title:"MXS Lib" )
				)
			)
			else
			(
				tFileStr = this.FindLibFile inLibName inRelativePath:inRelativePath
			)
			
			if tFileStr == undefined then
			(
				messageBox ( "No module found matching name: " + inLibName )
				return undefined
			)
			
			if ( DoesFileExist tFileStr ) then
			(
				if ( not this.IsLoaded inLibName or inReload ) then
				(
					if ( this.printStatus ) then
					(
						format "mxsLib Loading Library: %\n" inLibName
					)
					
					execute ( "global " + inLibName + " = undefined" )
					
					fileIn tFileStr
				)
				
				if ( tLoadAsExternal ) then
				(
					if ( this.GetExternalLibrary inLibName == undefined ) then
					(
						if ( this.printStatus ) then
						(
							print ( "Adding to Externals: " + inLibName )
						)
						
						local tExternalLib = externalLibraryStruct()
						
						tExternalLib.name = inLibName
						tExternalLib.relativePath = inRelativePath
						
						append this._externals tExternalLib
					)
				)
				else if ( inLoadAsConstant ) then
				(
					if ( findItem this._constantLibraries inLibName == 0 ) then
					(
						if ( this.printStatus ) then
						(
							print ( "Adding to Constants Array: " + inLibName )
						)
						
						local tIndex = findItem this._libraries inLibName
						
						if ( tIndex != 0 ) then
						(
							deleteItem this._libraries tIndex
						)
						
						append this._constantLibraries inLibName
					)
				)
				else
				(
					if ( findItem this._constantLibraries inLibName ) == 0 and ( findItem this._libraries inLibName ) == 0 then
					(
						if ( this.printStatus ) then
						(
							print ( "Adding to Libraries Array: " + inLibName )
						)
						
						append this._libraries inLibName
					)
				)
				
				if ( this.printStatus ) then
				(
					print inLibName
				)
				
				--return ( globalVars.get tLibraryStr )
				return (format "Using %\n" inLibName)
			)
			else
			(
				print ( "[mxsLib ERROR] Could not find library file: " + tFileStr )
				return undefined
			)
		),
		
		fn Using inLibName inAbsPath:unsupplied inRelativePath:unsupplied inLoadAsConstant:False inReload:( keyboard.escPressed ) =
		(
			this.Load inLibName inAbsPath:inAbsPath inRelativePath:inRelativePath inLoadAsConstant:inLoadAsConstant inReload:inReload
		),
		
		fn GetHashtableKeys hash =
		(
			/* 
			Get an array of keys in a DotNet Hashtable
			 */
			--spit the posible keys out  
			DNArray = dotNetObject "System.string[]" hash.keys.count  
			hash.keys.copyTo DNArray 0  
			out = for i = 1 to hash.keys.count collect (DNArray.get (i-1))
			out
		),
		
		fn GetScriptDependencies scriptFile =
        (
            if not ( DoesFileExist scriptFile ) then
            (
                format "***** GetStringBlock was unable to find the supplied file: % *****\n" scriptFile
                return ""
            )
            
            local out = #()
            
            local strm = ( openFile scriptFile mode:"r" )
            
            while not ( eof strm ) do
            (
                local l = readLine strm
                if ( matchPattern l pattern:"*_ilmLibrary.Load*" ) then
                (
                    local lineStrArr = ( filterString l "\"" )
                    
                    if lineStrArr != undefined and lineStrArr.count > 1 then
                    (
                        appendIfUnique out lineStrArr[2]
                    )
                )
            )
            
            out
        ),
        
        fn GetStringBlock textFile fromStr toStr filterFromStr:True filterToStr:True =
        (
            if not ( DoesFileExist textFile ) then
            (
                format "***** GetStringBlock was unable to find the supplied file: % *****\n" textFile
                return ""
            )
                
            local strBlock = stringStream ""
            local strm = ( openFile textFile mode:"r" )
            local begin = False
            
            while not ( eof strm ) do
            (
                local l = readLine strm
                if ( matchPattern l pattern:fromStr ) then begin = True
                if begin then
                (
                    format (l + "\n") to:strBlock
                    if matchPattern l pattern:toStr then exit
                )
            )
            
            close strm
            strBlock = ( strBlock as string )
            
            if filterFromStr then
            (
                local iFromStr = SubStituteString fromStr "*" ""
                strBlock = ( SubstituteString strBlock iFromStr "" )
            )
            
            if filterToStr then
            (
                local iToStr = SubStituteString toStr "*" ""
                strBlock = ( SubstituteString strBlock iToStr "" )
            )
            
            format "======================================\n%\n======================================\n" strBlock
        ),
        
        fn GetScriptHeader scriptFile =
        (
            GetStringBlock scriptFile "*__MXSDOC__*" "*__END__*" filterFromStr:True filterToStr:True
        ),
        
        fn GetScriptHelp scriptFile =
        (
            GetStringBlock scriptFile "*__Help__*" "*__END__*" filterFromStr:False filterToStr:True
        ),
		
		fn LoadEnvData =
		(
			/* 
			Work in progress to get envrionment data (paths) from system environment variables
			 */
			
			local sysEnv = this.GetSysEnv()
			local varDic = sysEnv.GetEnvironmentVariables()
			local keyArr = this.GetHashtableKeys varDic
			
			local mxsVars = for key in keyArr where matchPattern (tolower key) pattern:"mxs_*" collect key
				
			if mxsVars.count != 0 then
			(
				
			)
			else
			(
				return False
			)
		),
		
		fn LoadConfigData =
		(
			/*!--------------------------------------------------------------------
				\remarks	
					Loads the configuration file for the environments and paths
					mxsConfigFile is a global variable defined in the mxsStartup
					library
				
				\history
					- EKH 04/17/06: Created
			
				\return				
					<boolean>
			---------------------------------------------------------------------*/
			
			this._environments.Clear()
			
			if ( ::_codeEnv == "SYS" ) then
			(
				this._activeEnvironment = ::_codeEnv
				
				local tEnvironment = EnvironmentClass()
				
				local sysenv = this.GetSysEnv()
				
				tEnvironment.SetPath "NETROOT" ( sysenv.GetEnvironmentVariable "NETROOT" )
				tEnvironment.SetPath "MXS_PATH" ( sysenv.GetEnvironmentVariable "MXS_PATH" )
				tEnvironment.SetPath "MXS_CODEROOT" ( sysenv.GetEnvironmentVariable "MXS_CODEROOT" )
				tEnvironment.SetPath "MXS_LIB" ( sysenv.GetEnvironmentVariable "MXS_LIB" )
				tEnvironment.SetPath "MXS_TOOLS" ( sysenv.GetEnvironmentVariable "MXS_TOOLS" )
				tEnvironment.SetPath "MXS_STARTUPPATH" ( sysenv.GetEnvironmentVariable "MXS_STARTUPPATH" )
				tEnvironment.SetPath "MXS_ASSEMBLIES" ( sysenv.GetEnvironmentVariable "MXS_ASSEMBLIES" )
				tEnvironment.SetPath "PYTHONPATH" ( sysenv.GetEnvironmentVariable "PYTHONPATH" )
				
				tEnvironment.name = ::_codeEnv
				
				this._environments.SetValue ( toLower( ::_codeEnv ) ) tEnvironment
				
				return True
			)
			else
			(
				throw "Trying to get UserConfigFile"
				
				local configFile = this.GetUserConfigFile()
				
				if ( DoesFileExist configFile ) then
				(
					this._activeEnvironment = getINISetting configFile "GLOBALS" "environment"
					
					for tSection in getINISetting configFile do
					(
						if ( tSection != "GLOBALS" ) then
						(
							local tEnvironment = EnvironmentClass()
							
							for tKey in getINISetting configFile tSection do
							(
								tEnvironment.SetPath tKey ( getINISetting configFile tSection tKey )
							)
							
							tEnvironment.name = tSection
							
							this._environments.SetValue ( toLower( tSection ) ) tEnvironment
						)
					)
					
					this.SetCodePath this._activeEnvironment
					
					return True
				)
			)
			
			
			return False
		),
		
		fn SaveConfigData =
		(
			/*!--------------------------------------------------------------------
				\remarks	
					Saves the configuration file for the environments and paths
					mxsConfigFile is a global variable defined in the mxsStartup
					library
				
				\history
					-GK 01/30/14: Created
			
				\return				
					<boolean>
			---------------------------------------------------------------------*/
			--this._environments.Clear();
			if ( DoesFileExist ::mxsConfigFile ) then
			(
				setINISetting ::mxsConfigFile "GLOBALS" "environment" (this._activeEnvironment)
				return True
			)
			return False
		),
		
		fn LocalCodePathExists =
		(
			/*!--------------------------------------------------------------------
				\remarks	
					Checks to see if the local code path exists on this machine
				\history
					- EKH 04/17/06: Created
			
				\return				
					<boolean>
			---------------------------------------------------------------------*/
			return ( DoesFileExist ( this.GetPath #codeRoot inEnvironment:"development" ) )
		),
		
		fn ReloadAll inReloadLibraries:True inReloadConstants:True inReloadExternal:True =
		(
			/*!--------------------------------------------------------------------
				\remarks	
					Takes the current libraries that have been loaded and reloads them
					using the latest environment
				
				\param		inReloadLibraries			<boolean>
				\param		inReloadConstants			<boolean>
				\param		inReloadExternal			<boolean>
			
				\history
					- EKH 04/17/06: Created
			
				\return				
					<void>
			---------------------------------------------------------------------*/
			if ( inReloadLibraries ) then
			(
				for tLibName in this._libraries do
				(
					this.Load tLibName inReload:True
				)
			)
			
			if ( inReloadConstants ) then
			(
				for tLibName in this._constantLibraries do
				(
					if ( tLibName != this.classID ) then
					(
						this.Load tLibName inReload:True inLoadAsConstant:True
					)
				)
			)
			
			if ( inReloadExternal ) then
			(
				for tExternal in this._externals do
				(
					this.Load tExternal.name inRelativePath:tExternal.relativePath inReload:True
				)
			)
		),
		
		fn RemovePathTemplates inPath inEnvironment:"" inCustomKeys:#() inCustomValues:#() =
		(
			/*!--------------------------------------------------------------------
				\remarks	
					Removes templates from the inputed path string
				
				\param		inPath			<string>
				\param		inEnvironment	<string>
				\param		inCustomKeys	<array>[ <string>, .. ]
				\param		inCustomValues	<array>[ <string>, .. ]
			
				\history
					- EKH 04/17/06: Created
					- EKH 11/16/06: Added inEnvironment tag to use with the template replacement
				
				\sa GetPath
			
				\return				
					<string>
			---------------------------------------------------------------------*/
			
			local tSplit = filterstring inPath "[]"
			local outName = ""
			
			for tPart in tSplit do
			(
				if ( toLower tPart == "username" ) then
				(
					tPart = sysinfo.username
				)
				else if ( this.IsPath tPart ) then
				(
					tPart = this.GetPath tPart inEnvironment:inEnvironment
				)
				else if ( findItem inCustomKeys tPart != 0 ) then
				(
					tPart = ( inCustomValues[ findItem inCustomKeys tPart ] as string )
				)
				outName += tPart
			)
			return outName
		),
		
		fn GetToolList =
		(
			local dirArr = GetDirectories ( ( this.GetToolPath() ) + "*" )
			
			this.toollist = for dir in dirArr where ( GetFiles ( dir + "\\*.ms" )).count != 0 collect ( TrimRight ( pathConfig.stripPathToLeaf dir ) "\\" )
		),
		
		fn GetTool toolName =
		(
			if ( FindItem this.toollist toolName ) != 0 then
			(
				local toolDir = for dir in ( GetDirectories ( ( this.GetToolPath() ) + "*" )) where ( MatchPattern ( pathConfig.StripPathToLeaf dir ) pattern:( toolName + "*" )) collect dir
				
				if ( toolDir.count != 0 ) then
				(
					toolDir = toolDir[1]
					
					local sFile = ( GetFiles (toolDir + "\\*.ms" ))[1]
					
					if DoesFileExist sFile then
					(
						return sFile
					)
				)
				else
				(
					MessageBox ( "Could not find the directory for the given tool name: " + ( toolName as string ) title:"mxs Error" )
				)
			)
			else
			(
				MessageBox ( "No tool matches the given name: " + ( toolName as string )) title:"mxs Error"
			)
			
			undefined
		),
		
		fn RunTool toolName =
		(
			local sFile = this.getTool toolName
			
			if sFile != undfefined then
			(
				FileIn sFile
			)
		),
		
		fn SetActiveEnvironment environmentID =
		(
			/*!--------------------------------------------------------------------
				\remarks	
					Sets the current active environment to the given location
				
				\param		environmentID
			
				\history
					- EKH 11/16/06: Created
			
				\return				
					<boolean>
			---------------------------------------------------------------------*/
			local out = false
			local tNormEnv = this._normEnv environmentID
			
			if ( this.debugLevel > 0 ) then print ("[mxsLib].SetActiveEnvironment (" + getSourceFilename() + ")")
			if ( this.debugLevel > 0 ) then format "thisSetActiveEnvironment() environmentID: % NormEnv: %\n" environmentID tNormEnv
			
			if ( tNormEnv != this._activeEnvironment ) then
			(
				if ( this._environments.HasKey tNormEnv ) then
				(
					this._activeEnvironment = tNormEnv
					if ( this.debugLevel > 0 ) then print ("activeEnvironment is: " + tNormEnv)
					out = true
				)
				else ( format "mxs Library: did not set environment: % (environment not found!)\n" tNormEnv )
			)
			else ( format "mxs Library: did not set environment: % (environment already set.)\n" tNormEnv )
			
			out
		),
		
		fn SetCodePath inEnvironment setDefault:false =
		(
			/*!--------------------------------------------------------------------
				\remarks	
					Sets the current active environment to the given value and
					reloads the libraries to the latest path
				
				\param		inEnvironment		<string>
			
				\history
					- EKH 04/17/06: Created
					- EKH 11/16/06: Added call to SetActiveEnvironment
			
				\return				
					<string>
			---------------------------------------------------------------------*/
			local out = undefined
			
			if ( this.debugLevel > 0 ) then
			(
				print ("[mxsLib] SetCodePath() (" + getSourceFilename() + ")")
				format "\nSetCodePath() inEnvironment: %\n" inEnvironment
			)
			
			local success = this.SetActiveEnvironment inEnvironment

			if ( success ) then
			(
				if ( this.debugLevel > 0 ) then ( format "\n\tsuccess!\n" )
				if setDefault then this.SaveConfigData()
				
				--globalVars.set #toolboxDir ( this.GetCodePath() )
				--global toolboxDir = this.GetCodePath()
				local toolboxDir = this.GetCodePath()
			
				-- Store the current libraries so they can be reloaded after clearing.
				local currentLibraries = deepcopy this._libraries
				this.ClearLibraries()
				
				-- Setting this will ensure that ReloadAll will actually reload the libraries that were loaded originally.
				this._libraries = currentLibraries
				this.ReloadAll()
				
				
				format "code Path: %" toolboxDir
				out = toolboxDir
			)
			if ( this.debugLevel > 0 ) then format "\nSetCodePath() out: %\n" out
						
			out			
		),
		
		-------------------------------------------------------------------------------------------------------------
		-- 									mxs CALLBACK DEFINITIONS
		-------------------------------------------------------------------------------------------------------------
		fn BroadcastmxsCallback inCallback_type_name =
		(
			/*!--------------------------------------------------------------------
				\remarks	
					This method provides a way for you to simulate one of the 
					events and have all the callback scripts for it executed
				
				\param		inCallback_type_name		<string>
			
				\history
					- DGH 05/05/06: Created
			---------------------------------------------------------------------*/
			
			for c in this._callbackArray where (c.type == inCallback_type_name) do
			(
				if (c.filename == undefined) then
				(
					execute ( c.command )
				)
				else
				(
					filein c.filename
				)
			)
		),
		
		fn ShowCallbacks =
		(
			/*!--------------------------------------------------------------------
				\remarks	
					This method lists out the current callback scripts in the 
					Listener window.
				\history
					- DGH 05/05/06: Created
			---------------------------------------------------------------------*/
			
			for c in this._callbackArray do
			(
				format "mxsCallback type:% command:\"%\" id:% filename:%\n" c.type c.command c.id (if c.filename != undefined then ("\"" + c.filename + "\"") else "undefined")
			)
		),
		
		fn RegisterCallback inCallback_type_name inExecuteString id: filename:undefined =
		(
			/*!--------------------------------------------------------------------
				\remarks	
					This method is used to register a new callback script. Requires 
					as the first argument a name that specifies which type of notify 
					event this script is associated with 
					The script is supplied either as a direct String or StringStream 
					value containing the text of the script to run, or as a 
					fileName: keyword argument, in which case the named file is 
					loaded and run whenever the event notification callback occurs. 
					You can specify either a direct string or a fileName:, but not both
					The optional id: parameter lets you tag one or a group of callbacks 
					with a unique name so that you can remove them all as a group 
					without interfering with other callbacks, perhaps registered by 
					other scripted tools.
				
				\param		inCallback_type_name 	<name>
				\param		inExecuteString 		<string>
				\param		id						<anme>
			
				\history
					- DGH 05/05/06: Created
			---------------------------------------------------------------------*/		
			if (finditem this._callbackTypes inCallback_type_name == 0) then
			(
				local mxsCallbackID = ("mxs" + (inCallback_type_name as string) ) as name
				
				callbacks.addScript inCallback_type_name ("BroadcastmxsCallback #"+ (inCallback_type_name as string) ) id:mxsCallbackID
				append this._callbackTypes inCallback_type_name
				append this._callbackIDs mxsCallbackID
			)
			
			append this._callbackArray ( mxsCallback type:inCallback_type_name command:inExecuteString id:id filename:filename )
			return true
		),
		
		fn UnRegisterCallback callbackType: id: =
		(
			/*!--------------------------------------------------------------------
				\remarks	
					This method is used to unregister and remove one or more 
					callback scripts. Specifying just a callback event type name 
					removes all the callback scripts for that event. Specifying 
					just an id:<name> removes all callback scripts in all events 
					with that ID. Specifying both limits the ID-based removal to 
					the specified event type.
					Specifying none remove all the mxs callbacks
				
				\param		callbackType 	<name>
				\param		id			 	<name>
			
				\history
					- DGH 05/05/06: Created
			---------------------------------------------------------------------*/
			
			-- no callbacks ? , nothing to do here!
			if (this._callbackArray.count == 0) then
			(
				return ok
			)
			
			if (callbackType == unsupplied and id == unsupplied) then
			( -- remove all the mxs Callbacks if nothing is passed to the function
				this._callbackArray = #()
			)
			else if (callbackType != unsupplied and id == unsupplied) then
			(-- remove only by type
				for i = this._callbackArray.count to 1 by -1 do
				(
					local callback = this._callbackArray[i]
					if (callback.type == callbackType) then
					(
						deleteItem this._callbackArray i
					)
				)
			)
			else if (callbackType == unsupplied and id != unsupplied) then
			(-- remove only by id
				for i = this._callbackArray.count to 1 by -1 do
				(
					local callback = this._callbackArray[i]
					if (callback.id == id) then
					(
						deleteItem this._callbackArray i
					)
				)
			)
			else if (callbackType != unsupplied and id != unsupplied) then
			(-- remove by type & id
				for i = this._callbackArray.count to 1 by -1 do
				(
					local callback = this._callbackArray[i]
					if (callback.id == id) and (callback.type == callbackType) then
					(
						deleteItem this._callbackArray i
					)
				)
			)
			
			-- if there is no more mxs callbacks for a type given then remove the real callbackFn
			local existingCallbackIDs = for c in this._callbackArray collect c.type
			
			for i = this._callbackTypes.count to 1 by -1 do
			(-- if we don't find anymore callbacks with a specific type , then remove the real callback
				if (finditem existingCallbackIDs this._callbackTypes[i] == 0) then
				(
					local mxsCallbackID = this._callbackIDs[i]
					callbacks.removescripts this._callbackTypes[i] id:mxsCallbackID
					deleteItem this._callbackTypes i
					deleteItem this._callbackIDs i
				)
			)
		),
		
		
		/*!--------------------------------------------------------------------
			\remarks	
				log functions used to automatically log pipeline events
		---------------------------------------------------------------------*/			
		
		fn DateTime localTimeStr: separatorDate:"/" separatorTime:":" =
		(
			/*!--------------------------------------------------------------------
				\remarks	
					To conform log files to CLF format file we need the date in specific format. This function converts the current time to the 
					CLF date format file
					
					[dd/MMM/yyyy:hh:mm:ss +-hhmm]
					dd is the day of the month
					MMM is the month
					yyy is the year
					:hh is the hour
					:mm is the minute
					:ss is the seconds
					+-hhmm is the time zone
				
				\param		localTimeStr: 			<string>	date&time string to be converted. Defaults to the current date time
				\JJ - 16/5/2014
			
				\return				
					<string>		
					
				\history
					- DGH 02/08/07: Created
			---------------------------------------------------------------------*/			
			
			if localTimeStr == unsupplied then localTimeStr = localtime
			
			--Modified to use getlocaltime fn to account for different date formats
			local infoArray = getLocalTime() 
			local monthStr = (months[infoArray[2] as integer]) as string
			local dayStr = infoArray[4] as string
			local yearStr = infoArray[1] as string
			local hourStr = infoArray[5] as string
			local minutesStr = infoArray[6] as string
			local secondsStr = infoArray[7] as string
			
			-- fill the gaps to conform to the datetime format
			if dayStr.count < 2 then dayStr = "0" + dayStr 
			if monthStr.count < 3 then dayStr = "00" + dayStr 
			if monthStr.count < 2 then dayStr = "0" + dayStr 
		
			-- for now timezone is fixed
			local timezoneStr = "-0800"
			
			local dateTimeStr = stringStream ""
			format "%%%%%%%%%%%%" dayStr separatorDate monthStr separatorDate yearStr separatorTime hourStr separatorTime minutesStr separatorTime secondsStr timezoneStr to:dateTimeStr
			dateTimeStr as string
		),

		fn PrintToLog message host:sysinfo.computername rfc931:"-" username:sysinfo.username date:(this.dateTime()) request:"" status:"" details:"" toFile:undefined = 
		(
			if toFile == undefined then toFile = listener
			format "% % % [%] \"%\" \"%\" \"%\"\n" host rfc931 username date message status details to:toFile
		)
	)
	
	::mxs = mxsLibraryStruct()
	
	::mxs.LoadConfigData()
	::mxs.GetToolList()
)

--::mxs.load "ToolListXML"
