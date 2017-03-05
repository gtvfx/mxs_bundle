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
Author:				    Gavyn Thompson
Company:				GTVFX
Website:				https://github.com/gtvfx
Email:				    gftvfx@gmail.com
ScriptVersion:			
Updated:				
[Purpose]

***************************************************************************************************/

/*
__HELP__

Constructor: AssemblyManager
Instantiated Global: AssemblyManager

Parameters:
    baseDir = ((GetDir #temp) + "\\assemblies\\")

Methods:
    LoadAssembly <path_to_assembly>
        - Supply the full file path to the assembly
        - This method will localize the assembly to the <baseDir> and load it from there


__END__
*/



struct AssemblyManager
(
public
    
	baseDir = ( ( GetDir #temp ) + "\\assemblies\\" ),
    
    fn CreateBaseDir =
    (
        makeDir this.baseDir
    ),
	
	fn GetLocalFile path_to_assembly =
	(
		( this.baseDir + ( FileNameFromPath path_to_assembly ) )
	),
	
	fn ExploreBaseDir =
	(
		if ( DoesFileExist this.baseDir ) then
		(
			shellLaunch this.baseDir ""
		)
	),
	
	fn LocalizeAssembly path_to_assembly =
	(
		if not ( DoesFileExist path_to_assembly ) then
		(
			format "***** Assembly file does not exist: % *****\n" path_to_assembly
			return False
		)
		
		local localFile = this.GetLocalFile path_to_assembly
			
		if ( DoesFileExist localFile ) then
		(
			local success = try( DeleteFile localFile )catch( False )
            
			if not success then
			(
				format "***** % currently loaded *****\n" ( FileNameFromPath localFile )
				return True
			)
		)
		
		CopyFile path_to_assembly localFile
	),
	
	fn LoadAssembly path_to_assembly =
	(
		if not ( this.LocalizeAssembly path_to_assembly ) then
		(
			return False
		)
		
		DotNet.LoadAssembly ( this.GetLocalFile path_to_assembly )
	),
	
    fn GetModule =
    (
        ( GetSourceFileName() )
    ),
    
    fn Help =
    (
        ::mxs.GetScriptHelp ( GetSourceFileName() )
    ),
    
private
	
	fn _init =
	(
		this.CreateBaseDir()
	),

	__init__ = _init()
)

AssemblyManager = AssemblyManager()