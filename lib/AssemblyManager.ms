/*
__MXSDOC__

[TITLE]
AssemblyManager

[DESCRIPTION]
Manages the loading of DotNet assemblies from the SandBox by copying them down to the user's local machine
to avoid locking the files in the SandBox and preventing them from being updated.

[USAGE]

[CREATION INFO]
Author: Gavyn Thompson
E-mail: gthompson@ilm.com
Company: Industrial Light and Magic
Date created: 10/2015
Last Updated: 01/011/2016

[KEYWORDS]

[VERSION HISTORY]

[SEE ALSO]

__END__
*/

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
	baseDir = ((GetDir #temp) + "\\assemblies\\"),
	
	fn GetLocalFile path_to_assembly =
	(
		( this.baseDir + ( FileNameFromPath path_to_assembly ) )
	),
	
	fn ExploreBaseDir =
	(
		if DoesFileExist this.baseDir then
		(
			shellLaunch this.baseDir ""
		)
	),
	
	fn LocalizeAssembly path_to_assembly =
	(
		if not DoesFileExist path_to_assembly then
		(
			format "***** Assembly file does not exist: % *****\n" path_to_assembly
			return False
		)
		
		local localFile = this.GetLocalFile path_to_assembly
			
		if DoesFileExist localFile then
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
		
		dotNet.loadAssembly ( this.GetLocalFile path_to_assembly )
	),
	
    fn GetModule =
    (
        ( GetThisScriptFileName() )
    ),
    
    fn Help =
    (
        ::_ilmLibrary.GetScriptHelp ( this.GetModule() )
    ),
	
	private fn _init =
	(
		makeDir this.baseDir
	),

	__init__ = _init()
)

_AssemblyManager = AssemblyManager()