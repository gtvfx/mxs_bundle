fn LaunchPythonApplication PythonScript PythonExe:@"C:\Python27\python.exe" =
(
	if not DoesFileExist PythonExe then return format "***** Could not find Python EXE at: % *****\n" PythonExe
	if not DoesFileExist PythonScript then return format "***** Could not find Python Script at: % *****\n" PythonScript
	ShellLaunch PythonEXE PythonScript
)


sPath = ((_ilmLibrary.GetPath #pythonworkspace)+@"tools\CreateMyTabEntry\ilm_CreateMyTabEntry.py")

LaunchPythonApplication sPath PythonExe:@"\\lucas\ilm\dept\digimatte\gthompson\Python27\python.exe"