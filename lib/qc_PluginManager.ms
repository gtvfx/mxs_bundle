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

Constructor: 
Instantiated Global: 

[METHODS]


[DESCRIPTION]


[USAGE]


__END__
*/



struct qc_Plugin
( -- Construct for plugin object
    super,
	title = "",
	check = unsupplied,
	fix = unsupplied,
	sel = unsupplied,
	active = False,
	description = "",
    
    fn ResetObjArr =
    (
        if ( IsProperty this.super #objArr ) then
        (
            this.super.objArr = undefined
        )
    ),
    
    fn SetObjArr objArr =
    (
        if ( IsProperty this.super #objArr ) then
        (
            this.super.objArr = objArr
        )
    )
)

struct qc_PluginManager
( -- The Plugin manager is inherited by the main tool and handles the plugins
    
	_resourcePath, -- Path to folder containing plugin files
	_pluginsLoaded = False,
	_plugins = #(), -- Array of qc_Plugin objects
	
	fn Register super:undefined title: check: fix: sel: active:true description:"" =
	( 
		local success = True
        
		if title == unsupplied or check == unsupplied then
		(
			format "***** Plugin Load Failed *****\n"
			return False
		)
    
        
		format "***** Loading Plugin: % *****\n" title
		append this._plugins ( ::qc_Plugin super:super title:title check:check fix:fix sel:sel active:active description:description )
	),
    
    fn ReloadPlugins dir:_resourcePath =
    (
        format "--------------------------------------------------------------------------------------------------------------\n"
        format "===== Loading Plugins... =====\n"
        
        this._plugins = #()
        local fileArr = ( GetFiles ( this._resourcePath + "*.ms" ) )
        
        for f in fileArr do
        (
            filein f
        )
        
        format "--------------------------------------------------------------------------------------------------------------\n"
    )
)
