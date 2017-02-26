global _codeEnv
global _codeRoot
global _startupPath

global WindowsEnvironment = dotNetClass "System.Environment"
	
global mxsConfigFile = WindowsEnvironment.GetEnvironmentVariable "MXS_CONFIG_FILE"


if (mxsConfigFile == undefined) then
(
	format "mxsLib Startup: configFile environment variable undefined, looking for local config file\n"
	
	::mxsConfigFile = (systemTools.getEnvVariable("USERPROFILE") + @"\AppData\Local\Autodesk\3dsMax\2013 - 64bit\ENU\mxsLibConfig.ini")
)
else
(
	format "mxsConfigFile defined by environment variable: \n\t %\n" ::mxsConfigFile
)


if DoesFileExist mxsConfigFile then
(
	format "mxsLib Startup: Found config file at %\n" ::mxsConfigFile
	
	::_codeEnv = GetINISetting ::mxsConfigFile "GLOBALS" "environment"
	
	::_codeRoot = GetINISetting ::mxsConfigFile _codeEnv "coderoot"
	
	::_startupPath = GetINISetting ::mxsConfigFile _codeEnv "startupPath"
	
	local startuplib = (::_startupPath + @"\mxsLibMaxStartup.ms")
	
	if DoesFileExist startupLib then
	(
		format "|==================== Initializing mxsLib Max Startup ====================|\n"
		
		filein startupLib
		
		format "|==================================================================|\n"
	)
	else
	(
		format "|******************** !! Startup Lib Not Found !! ********************|\n"
	)
)
else
(
	::_codeEnv = "Default"
	
	::_codeRoot = @""
	
	::_startupPath = @""
	
	
	format "mxsLib Startup Error: Could not locate config file (%)\n" mxsConfigFile
)

