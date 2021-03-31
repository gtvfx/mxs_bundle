@echo off

:: %DEV_PATH% is a user environment variable with a path to the code repository


:: Set a variable within this contxt for concatenation
set HOST_VERSION="2019"


:: Look for a MAX_HOST_VERSION variable in the environment
if not "%1" == "" {
    HOST_VERSION=%1
} else if not "%MAX_HOST_VERSION%" == "" {
    HOST_VERSION=%MAX_HOST_VERSION%
}


set NETROOT=E:\
set MXS_CODEROOT=%DEV_PATH%\mxs_bundle
set MXSPATH=%MXS_CODEROOT%\lib
set MXS_TOOLS=%MXSPATH%\tools
set MXS_STARTUPPATH=%MXSPATH%\_mxsStartup.ms
set MAXEXE="C:\Program Files\Autodesk\3ds Max %HOST_VERSION%\3dsmax.exe"

:: Set the PYTHONPATH to a clean environment with the bundle namespace as well as the 3dsmax paths
:: You should be able to prepend or append any additional paths here
:: Caret symbol (^) used to split lines
set PYTHONPATH=^
%MXSPATH%\python;^
C:\Program Files\Autodesk\3ds Max %HOST_VERSION%;^
C:\Program Files\Autodesk\3ds Max %HOST_VERSION%\python;^
C:\Program Files\Autodesk\3ds Max %HOST_VERSION%\python\Lib;^
C:\Program Files\Autodesk\3ds Max %HOST_VERSION%\scripts\Python

xcopy /s/y "%DEV_PATH%\mxs_bundle\mxs_init.ms" "%LOCALAPPDATA%\Autodesk\3dsMax\%HOST_VERSION% - 64bit\ENU\scripts\startup"
xcopy /s/y "%DEV_PATH%\mxs_bundle\mxs_props\MXS_EditorAbbrev.properties" "%LOCALAPPDATA%\Autodesk\3dsMax\%HOST_VERSION% - 64bit\ENU\MXS_EditorAbbrev.properties"
xcopy /s/y "%DEV_PATH%\mxs_bundle\mxs_props\MXS_EditorUser.properties" "%LOCALAPPDATA%\Autodesk\3dsMax\%HOST_VERSION% - 64bit\MXS_EditorUser.properties"


call %MAXEXE%
