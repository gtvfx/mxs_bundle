
::mxs
::_maxInit

::_codeEnv
::_codeRoot

(
	local sysenv = (dotNetClass "System.Environment")
	
	if ( sysenv.GetEnvironmentVariable "MXS_PATH" != undefined ) then
	(
		::_codeEnv = "SYS"
		::_codeRoot = sysenv.GetEnvironmentVariable "MXS_CODEROOT"
	)
	else if ( sysenv.GetEnvironmentVariable "MXS_CONFIG_FILE" != undefined ) then
	(
		local mxsConfigFile = ( sysenv.GetEnvironmentVariable "MXS_CONFIG_FILE" )
		::_codeEnv = GetINISetting mxsConfigFile "GLOBALS" "environment"
		::_codeRoot = GetINISetting mxsConfigFile _codeEnv "coderoot"
	)
)


struct DefaultInit
(
	fn LoadFilesFromDir dir fileType:".ms*" =
	(
		local fileArr = (GetFiles (dir + ("\\*"+fileType)))
		if fileArr.count != undefined then
		(
			for i in fileArr do
			(
				if (DoesFileExist i) then
				(
					format "Loading File: %\n" (GetFileNameFile i)
					filein i
				)
			)
			True
		)
		else
		(
			False
		)
	),

	fn LoadScriptedPlugins =
	(
		/* 
		load all files in the scripted plugins dir
		 */
		format "|=============== Loading Scripted Plugins ===============|\n"
		local sPluginDir = (::_codeRoot + @"\Lib\ScriptPlugins")
		if ( DoesFileExist sPluginDir ) then
		(
			this.LoadFilesFromDir sPluginDir
		)
		else
		(
			format "***** Directory does not exist: % *****\n" sPluginDir
		)
	),
	
	fn _init =
	(
		this.LoadScriptedPlugins()
	),
	
	init = _init()
)

-----------------------------------------------------------------------------------------------------------------------------------

struct WorkstationInit
(
	_defInit = DefaultInit(),
	_tabInit = False,
	
	fn LoadFilesFromDir dir fileType:".ms*" =
	(
		_defInit.LoadFilesFromDir dir fileType:fileType
	),
	
	fn LoadRequiredLibs = 
	(
		fileIn ( ::_codeRoot + @"\lib\__mxsLib.ms" )
		::mxs.printStatus = True
		fileIn ( ::_codeRoot + @"\lib\mxsString.ms" )
	),
	
	fn PrepTempDir =
	(
		local tempDir = (sysInfo.tempDir + "ToolList\\")
		if ( DoesFileExist tempDir ) then
		(
			local tempFiles = getFiles (tempDir + "*.ms")
			for tempFile in tempFiles do deleteFile tempFile
		)
		else
		(
			makeDir tempDir
		)
	),
	
	fn LoadStartupLibs =
	(
		format "|=============== Loading Startup Scripts ===============|\n"
		
		local startupDir = (::_codeRoot + @"\lib\startup")
		
		if ( DoesFileExist startupDir ) then
		(
			this.LoadFilesFromDir startUpDir
		)
	),
	
	fn DisableWindowsGhosting =
	(
		format "========== Disabling windows ghosting ==========\n"
		local sFile = ( ::_codeRoot + @"\lib\systemLibs\user32DLL.ms" )
		if doesFileExist sFile then
		(
			fileIn sFile
			True
		)
		else False
	),
	
	fn InitTabMenu =
	(
		format "========== Initializing tab menu library ==========\n"
		local sFile = ( ::_codeRoot + @"\lib\userInterface\mxsTabMenu.ms" )
		if ( DoesFileExist sFile ) then
		(
			FileIn sFile
			True
		)
		else False
	),
	
	fn _init =
	(
		format "|==================== ILM Max Starup ====================|\n"
		
		this.LoadRequiredLibs()
		
		this.PrepTempDir()
		
		this.LoadStartupLibs()
		
		if not ( this.DisableWindowsGhosting() ) then throw "ilmMaxStartUp Error:Failed to disable Windows ghosting"
			
		if not ( this.InitTabMenu() ) then throw "ilmMaxStartUp Error:Failed to load the tab menu"
			
		if this._tabInit then ::TabMenu.Run() -- Allows for bypassing the Tab Menu Display
			
		format "|========================================================|\n"
	),
	
	init = _init()
)






if (GetQuietMode()) then
(
	::_maxInit = DefaultInit()
)
else
(
	::_maxInit = WorkstationInit()
)
