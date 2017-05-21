set NETROOT=G:\
set MXS_PATH=G:\repos\mxs_bundle\lib
set MXS_CODEROOT=G:\repos\mxs_bundle
set MXS_LIB=G:\repos\mxs_bundle\lib
set MXS_TOOLS=G:\repos\mxs_bundle\tools
set MXS_STARTUPPATH=G:\repos\mxs_bundle\lib\mxsLibMaxStartup.ms
set MXS_ASSEMBLIES=G:\repos\mxs_bundle\assemblies

set PYTHONPATH=G:\repos\mxs_bundle\lib\python;C:\Program Files\Autodesk\3ds Max 2018;C:\Program Files\Autodesk\3ds Max 2018\python;C:\Program Files\Autodesk\3ds Max 2018\python\Lib;C:\Program Files\Autodesk\3ds Max 2018\scripts\Python;C:\_cache\GavynPython


xcopy /s/y "G:\repos\mxs_bundle\mxs_init.ms" "C:\Users\Work\AppData\Local\Autodesk\3dsMax\2018 - 64bit\ENU\scripts\startup"


"C:\Program Files\Autodesk\3ds Max 2018\3dsmax.exe"

REM pause