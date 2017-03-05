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

Constructor: ViewportMapDisplay
Instantiated Global: ViewportMapDisplay

[METHODS]
    DisableMapsInViewport
	
	EnableMapsInViewport

[DESCRIPTION]


[USAGE]


__END__
*/





struct ViewportMapDisplay
(
public

	mClassArr,
	
	fn GetMaterialClasses refactor:False =
	(
		if mClassArr == undefined or refactor then
		(
			this.mClassArr = material.classes
		)
		
		this.mClassArr
	),
	
	fn ToggleSubMapDisplay mat_or_map state:False sourceMat:undefined =
    ( -- recurssive
		if ( sourceMat == undefined ) then 
		(
			sourceMat = mat_or_map
		)
		
        local numSubTexmaps = ( GetNumSubTexmaps mat_or_map )
        
        for i = 1 to numSubTexmaps do
        (
            local tMap = ( GetSubTexmap mat_or_map i )
            
            if tMap != undefined then
            (
				this.ToggleSubMapDisplay tMap state:state sourceMat:sourceMat
                ShowTextureMap sourceMat tMap state
            )
        )
    ),

	mapped fn SetViewPortDisplay_mapped mArr state:False =
	(
		if ( IsProperty mArr #showInViewport ) then
		(
			mArr.showInViewport = state
			
			if not state then
			(
				this.ToggleSubMapDisplay mArr state:state
			)
		)
	),
	
	fn ToggleMapDisplay state:False =
	(
		this.GetMaterialClasses()
		
		for mClass in mClassArr do
		(
			local mArr = GetClassInstances mClass
			
			if mArr != undefined and mArr.count != 0 then
			(
				this.SetViewPortDisplay_mapped mArr state:state
			)
		)
	),
	
	fn DisableMapsInViewport =
	(
		this.ToggleMapDisplay state:False
	),
	
	fn EnableMapsInViewport =
	(
		this.ToggleMapDisplay state:True
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
		this.GetMaterialClasses()
	),

	__init__ = _init()
)

ViewportMapDisplay = ViewportMapDisplay()




