(
	local sysenv = (dotNetClass "System.Environment")
	local startupLib = ( sysenv.GetEnvironmentVariable "MXS_STARTUPPATH" )
	
	if ( startupLib != undefined ) then
	(
		if ( DoesFileExist startupLib ) then
		(
			FileIn startupLib
		)
		else
		(
			MessageBox "File does not exist at path stored in environment variable MXS_STARTUPPATH" title:"MXS Lib Error:"
		)
	)
	else
	(
		MessageBox "Environment Variable MXS_STARTUPPATH is undefined" title:"MXS Lib Error:"
	)
)