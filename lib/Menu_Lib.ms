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


***************************************************************************************************/
/*
__HELP__

Constructor: Menu_Lib
Instantiated Global:  N/A

Fields:
	sourceDir>
		Source directory where the lib will find the Menu structure directories
		
	default_category>
		This is the category for the macros that the lib will create to populate the menus
		
	str_global>
		This should be filled out with a string value of the global used to instantiate the lib.
		This is needed for the callback to unregister the menu when closing 3dsmax.

Methods:
	This module is designed to automatically generate the menus upon instantiation using the data from the required fields.
    
    
[DESCRIPTION]
This module creates system menu from directory structures
Allows for quick updates to tool menus without the need to update any code
Remove menu items by deleting the scipt file on disk. Remove a menu by deleting it's directory.

[USAGE]
Load the module then instantiate it with sourceDir, default_category, and str_global values

A good idea is to have an init script for this in the startup routine


__END__
*/




struct Menu_Lib
(
public

	-- Required fields --
	sourceDir,
	default_category,
	str_global,
	-------------------------
	mainMenuBar = menuMan.getMainMenuBar(),
	menuDirs,
	menuTitles,
	menus = #(),
	
	debug = False,
	
	rgx_prefix = ( dotnetobject "System.Text.RegularExpressions.Regex" "[0-9_]" ),
	
	fn TrimNumericPrefix str =
	(
		/* 
                    Trims the numeric prefix e.g. "00_" from the name.
                    The numeric prefix is used to put the tools in a specific order on the menu
                */
        
        local out = str
        
		for i = 1 to str.count do
		(            
            if not ( this.rgx_prefix.IsMatch str[i] ) then exit
            
            out = ( SubstituteString out str[i] "" )
		)
        
        out
	),
	
	fn CollectSubDirs dir =
	(
		GetDirectories ( dir + "*" )
	),
	
	fn GetMenuDirs =
	(
		/* 
		Collects all the directories in the root of the sourceDir
		All directories here will be a menu added to the main menu bar
		*/
		this.menuDirs = this.CollectSubDirs this.sourceDir
	),
	
	fn GetMenuTitlesFromDirs =
	(
		/* 
		Must be run post GetMenuDirs
		The directory names will be the title of the menus
		*/
		this.menuTitles = for dir in ( this.GetMenuDirs() ) collect ( TrimRight ( pathConfig.stripPathToLeaf dir ) "\\" )
	),
	
	fn GetMenuDirFromTitle title =
	(
		/* 
		A reverse lookup. Get the directory of the menu from it's title
		*/
		local out = for dir in this.menuDirs where ( MatchPattern ( pathConfig.stripPathToLeaf dir ) pattern:( title + "\\" ) ) collect dir
		
		if out.count != 0 then 
		(
			out[1]
		)
		else
		(
			undefined
		)
	),
	
	fn GetMenus =
	(
		/* 
		Must be run post GetMenuTitlesFromDirs
		Creates the main menu items for each collect title/dir
		*/
		for title in this.menuTitles do
		(
			this.UnregisterMenuByName title
			
			local newMenu = menuMan.createMenu title
			append this.menus newMenu
		)
	),
	
	fn CollectScriptsFromDir dir =
	(
		local out = #()
		if this.debug then format "***** CollectScriptsFromDir dir: % *****\n" dir
		if ( dir != undefined ) and ( DoesFileExist dir ) then
		(
			out = ( GetFiles ( dir + "*.ms" ) )
		)
		
		if out.count != 0 then sort out
		
		out
	),
	
	fn GetButtonTextFromMacro sFile =
	(
		/* 
		When laying out the script files for the menu items designers can place a commented line of text in the script file that will be used as the title of the menu item
		
		example -> --buttontext:"Item Title"
		
		if this commented string is not found then the name of the file will be used as the menu item title
		*/
		if ( DoesFileExist sFile ) then
		(
			local str = OpenFile sFile mode:"r"
			local mString = ""
			
			while not ( eof str ) do
			(
				local iLine = readLine str
				
				if ( MatchPattern iLine pattern:"*buttontext:*" ) then
				(
					Close str
					local colonLocation = FindString iLine ":"
					mString = Replace iLine 1 colonLocation ""
					mString = SubstituteString mString "\"" ""
					
					exit
				)
			)
			
			Close str
			
			mString
		)
		else
		(
			messageBox "Macro file provided does not exist" title:"File Does Not Exist:"
		)
	),
	
	fn FormatMacro macroName sFile category:this.default_category buttonText:"" =
	(
		/* 
		We format a simple macro for the menu items that is registered to the supplied category for us to easily track.
		The macro simply does a FileIn of the supplied script file
		*/
		local str = StringStream ""
		
		format "
macroScript %
category:\"%\" 
buttonText:\"%\"
(
    on execute do  
    (
        FileIn @\"%\"
    )
)
		" macroName category buttonText sFile to:str
		
		seek str 0
		readExpr str
	),
	
	fn AddMacroItem menu macroName macroCategory macroText =
	(
		/* 
		Macro must be created before running this method
		Add a menu item from the provided macro name and category to the provided menu
		*/
		local menuAction = menuMan.createActionItem macroName macroCategory
		menuAction.setTitle macroText
		menuAction.setUseCustomTitle true
		menu.addItem menuAction -1
	),
	
	fn PurgeMacros category:this.default_category =
	(
		/* 
		Removes the auto-generated macros created by this lib
		*/
		local libMacros = GetFiles ( ( GetDir #UserMacros ) + "\\" + category + "*.mcr" )
		if libMacros != undefined then for i in libMacros do DeleteFile i
	),
	
	fn CreateMenuItemFromScript menu script =
	(
		local macroName = this.TrimNumericPrefix ( GetFileNameFile script )
		
		if macroName == "sep" then
		(
			/* 
			Designers can create empty .ms files named "<numeric prefix>_sep.ms" in sequence with the rest of the menu items.
			Macros will not be created for these files, but instead a Menu Separated will be created
			*/
			local sepItem = menuMan.createSeparatorItem()
			menu.addItem sepItem -1
		)
		else
		(
			local buttonText = this.GetButtonTextFromMacro script
			if ( buttonText == undefined ) or ( buttonText == "" ) then
			(
				buttonText = macroName
			)
			
			this.FormatMacro macroName script category:this.default_category buttonText:buttonText
			this.AddMacroItem menu macroName this.default_category buttonText
		)
	),
	
	fn BuildSubMenu menu dir =
	(
		/* 
		This method handles directories within the primary menu dirs
		Sub menus are created for each subsequent directory within the tree
		This method is recursive
		*/
		if this.debug then format "***** BuildSubMenu dir: % *****\n" dir
		local title = ( TrimRight ( pathConfig.stripPathToLeaf dir ) "\\" )
		local scriptItems = this.CollectScriptsFromDir dir
		
		local subMenu = menuMan.createMenu title
		
		for script in scriptItems do
		(
			this.CreateMenuItemFromScript subMenu script
		)
		
		local subDirs = for sdir in ( this.CollectSubDirs dir ) where not ( MatchPattern sdir pattern:"*_resource*" ) collect sdir
		
		if subDirs.count != 0 then
		(
			for dir in subDirs do
			(
				this.BuildSubMenu subMenu dir
			)
		)
		
		if ( scriptItems.count == 0 ) and ( subDirs.count == 0 ) then
		(
			return False
		)
		
		menu.addItem ( menuMan.createSubMenuItem title subMenu ) -1
	),
	
	fn BuildMenu menu =
	(
		local title = menu.GetTitle()
		if this.debug then format "***** title: % *****\n" title
		
		local menuDir = this.GetMenuDirFromTitle title
				
		if this.debug then format "***** BuildMenu dir: % *****\n" menuDir
		local scriptItems = this.CollectScriptsFromDir menuDir
		
		for script in scriptItems do
		(
			this.CreateMenuItemFromScript menu script
		)
		
		local subDirs = for dir in ( this.CollectSubDirs menuDir ) where not ( MatchPattern dir pattern:"*_resource*" ) collect dir
		
		if subDirs.count != 0 then
		(
			for dir in subDirs do
			(
				this.BuildSubMenu menu dir
			)
		)
		
		local newMenu = menuMan.createSubMenuItem title menu
		this.mainMenuBar.addItem newMenu -1
		menuMan.updateMenuBar()
	),
	
	fn BuildAllMenus =
	(
		if this.debug then format "***** Menus: % *****\n" this.menus
		
		for menu in this.menus do
		(
			this.BuildMenu menu
		)
	),
	
	fn UnregisterMenu menu =
	(
		local menuName = menu.GetTitle()
		local sMenu = menuMan.findMenu menuName
		try( menuMan.unRegisterMenu sMenu )catch()
		menuMan.updateMenuBar()
	),
	
	fn UnregisterMenuByName menuName =
	(
		local menu = menuMan.findMenu menuName
		if ( menu != undefined ) then this.UnregisterMenu menu
	),
	
	fn UnRegisterAllMenus =
	(
		format "!-!-!-!-!- Unregistering Custom Menus -!-!-!-!-!\n"
		
		for menu in this.menus do
		(			
			this.UnregisterMenu menu
		)
	),
	
	fn AddUnRegisterCallback strGlobal:this.str_global =
	(
		/********
		This callback removes the menu from Max.
		To be run at preSystemShutdown.
		
		strGlobal should be a string holding the global variable of the Menu_Lib instantiation
		********/
		
		--callbacks.addScript #preSystemShutdown "( ::Menu_Lib.UnRegisterAllMenus() )" id:#Menu_Lib_unregister
		
		local str = stringStream ""
		format "callbacks.addScript #preSystemShutdown \"::%.UnRegisterAllMenus()\" id:( ( \"%_unregister\" ) as name)" strGlobal strGlobal to:str
        if this.debug then format "!!!!! Callback String: % !!!!!\n" (str as string)
		seek str 0
		readExpr str
	),
	
	fn AddPurgeMacrosCallback strGlobal:this.str_global =
	(
		local str = stringStream ""
		format "callbacks.addScript #preSystemShutdown \"::%.PurgeMacros()\" id:( ( \"%_purgeMacros\" ) as name)" strGlobal strGlobal to:str
        if this.debug then format "!!!!! Callback String: % !!!!!\n" (str as string)
		seek str 0
		readExpr str
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
		if ( this.sourceDir == undefined ) or not ( DoesFileExist this.sourceDir ) then
		(
			format "***** Menu_Lib instance requires a valid sourceDir *****\n"
			return False
		)
		
		if ( this.default_category == undefined ) or ( this.default_category == "" ) then
		(
			format "***** Menu_Lib requires a valid default_category for the macroscripts *****\n"
			return False
		)
		
		if ( this.str_global == undefined ) or ( this.str_global == "" ) then
		(
			format "***** Menu_Lib requires a valid strGlobal in order to unregister the menus properly *****\n"
			return False
		)
		
		if this.debug then format "***** % Purging Old Macros *****\n" this.str_global
		this.PurgeMacros()
		
		if this.debug then format "***** % Collecting Menus *****\n" this.str_global
		this.GetMenuTitlesFromDirs()
		this.GetMenus()
		
		if this.debug then format "***** % Building Menus *****\n" this.str_global
		this.BuildAllMenus()
		
		if this.debug then format "***** % Adding Unregister Callback *****\n" this.str_global
		this.AddUnRegisterCallback()
		
		if this.debug then format "***** % Adding purgeMacros Callback *****\n" this.str_global
		this.AddPurgeMacrosCallback()
	),
	
	init = _init()
)


-- Menu_Lib = Menu_Lib()

