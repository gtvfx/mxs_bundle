/***************************************************************************************************
Copyright (C) 2013 - 2017  Gavyn Thompson

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. if not, see <http://www.gnu.org/licenses/>.
***************************************************************************************************/
/***************************************************************************************************
Author:				Gavyn Thompson
Company:				GTVFX
Website:				https://github.com/gtvfx
Email:				gftvfx@gmail.com
ScriptVersion:			
Updated:				
[Purpose]

***************************************************************************************************/


struct ToolBoxInstall
(
public
	
	scriptsDir = (( GetDir #userscripts) + @"\GTVFX\" ),
	startupDir = (( GetDir #userStartupScripts) + "\\" ),
	macrosDir = (( GetDir #userMacros ) + "\\" ),
	
	source = ( GetFileNamePath ( GetSourceFileName() )),
	source_gtvfx = ( source + "GTVFX" ),
	source_startup = ( source + "Startup" ),
	
	fn CopyFiles fromDir toDir =
	(
		if ( not DoesFileExist fromDir ) then
		(
			return false
		)
		else
		(		
			local sFileArr = GetFiles ( fromDir + @"\*" )
			
			for file in sFileArr do
			(
				CopyFile file ( toDir + ( GetFileNameFile file ) + ( GetFileNameType file ))
			)
		)
		
		true
	),
	
	fn initCallBacks =
	(
		local sFile = ( this.scriptsDir + @"\GTVFX\GTVFX-toolbox_CallbacksLib.ms" )
		if ( DoesFileExist sFile ) then ( Filein sFile ) else return false
		true
	),
	
	fn initMenu =
	(
		local sFile = ( this.scriptsDir + @"\GTVFX\GTVFX-toolbox_MacrosLib.ms" )
		if ( DoesFileExist sFile ) then ( Filein sFile ) else return false
		true
	),
	
	fn Install =
	(
		::gtb = undefined -- added 10/24/2014
		if not ( makeDir scriptsDir ) then return false
		if not ( this.CopyFiles this.source_startup this.startupDir ) then return false
		if not ( this.CopyFiles this.source_gtvfx this.scriptsDir ) then return false
		true
	),
	
	fn Uninstall arr:#() =
	(
		if ( DoesFileExist this.startupDir ) then ( arr += ( GetFiles ( this.startupDir +@"GTVFX\*" )))
		if ( DoesFileExist this.macrosDir ) then ( arr += ( GetFiles ( this.macrosDir + @"GTVFX\*" )))
			
		if ( arr.count != 0 ) then for i in arr do DeleteFile i
			
		if ( doesFileExist scriptsDir ) then ( DosCommand ( "rmdir \"" + this.scriptsDir + "\" /s /q" ))
			
		try( ::layIso.purgeLayIsoItems() )catch()
	),
	
	fn LaunchToolbox =
	(
		format "***** LaunchToolbox *****\n"
		local sFile = ( this.scriptsDir + @"\GTVFX-toolbox_Loader.ms" )
		if ( DoesFileExist sFile ) then ( FileIn sFile ) else ( MessageBox "Cannot find toolbox script file" )
	),
	
	fn UnregisterMenue =
    (
        local maxMenu = menuMan.getMainMenuBar()
        local GTVFX_toolboxMenu = menuMan.findMenu "GTVFX:Toolbox"
        try( menuMan.unRegisterMenu GTVFX_toolboxMenu )catch()
        menuMan.updateMenuBar()
    ),
	
private
	
	fn __init__ =
	(
		this.Uninstall()
		
		if ( this.Install() ) then
		(
			this.initCallBacks()
			this.LaunchToolbox()
			this.initMenu()
			format "***** GTVFX Toolbox library successfully installed *****\n"
		)
		else
		(
			format "***** Could not install the tool. Double check that you have permissions to copy files to the 3ds Max root directory. *****\n"
		)
	),
	
	init = __init__()
)

ToolBoxInstall = ToolBoxInstall()