set NETROOT=G:\
set MXS_CODEROOT=%NETROOT%repos\mxs_bundle
set MXSPATH=%MXS_CODEROOT%\lib
set MXS_TOOLS=%MXSPATH%\tools
set MXS_STARTUPPATH=%MXSPATH%\_mxsStartup.ms

set PYTHONPATH=%MXSPATH%\python;C:\Program Files\Autodesk\3ds Max 2018;C:\Program Files\Autodesk\3ds Max 2018\python;C:\Program Files\Autodesk\3ds Max 2018\python\Lib;C:\Program Files\Autodesk\3ds Max 2018\scripts\Python;C:\_cache\GavynPython

xcopy /s/y "G:\repos\mxs_bundle\mxs_init.ms" "C:\Users\Work\AppData\Local\Autodesk\3dsMax\2018 - 64bit\ENU\scripts\startup"
xcopy /s/y "G:\repos\mxs_bundle\mxs_props\MXS_EditorAbbrev.properties" "C:\Users\Work\AppData\Local\Autodesk\3dsMax\2018 - 64bit\ENU\MXS_EditorAbbrev.properties"
xcopy /s/y "G:\repos\mxs_bundle\mxs_props\MXS_EditorUser.properties" "C:\Users\Work\AppData\Local\Autodesk\3dsMax\2018 - 64bit\MXS_EditorUser.properties"

"C:\Program Files\Autodesk\3ds Max 2018\3dsmax.exe"

REM pause