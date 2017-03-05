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




struct qc_EmptyMapLoaders
(
public
    
    aggregate,
    debug = False,
    
    fn GetAllEmptyMapLoaders =
	(
		local bitMapArr = for b in ( Getclassinstances bitmaptexture asTrackViewPick:on ) where b.anim.filename == undefined or b.anim.filename == "" collect b
        
		if VrayHdri != undefined then
        (
            local vrArr = for v in ( Getclassinstances VrayHdri asTrackViewPick:on ) where v.anim.HdriMapName == undefined or v.anim.HdriMapName == "" collect v
            bitMapArr += vrArr
        )
        
        bitMapArr
	),
	
	fn RemoveMapLoaders mapLoaderArr =
	(
		MatEditor.Close()
		for map in mapLoaderArr do
		(
			for i = 1 to map.client.numsubs do
			(
				if map.client[i] == map.anim then
				(
					map.client[i].value = undefined
					exit
				)
			)
		)
	),
	
	fn CheckEmptyMapLoaders =
	(
		local emptyLoaderArr = this.GetAllEmptyMapLoaders()
        
        local msg = "There are " + ( emptyLoaderArr.count as string ) + " empty map loaders"
        format "***** % *****\n" msg
        
        if emptyLoaderArr.count != 0 then
        (
            if ( this.aggregate != undefined ) and ( isProperty this.aggregate #msgBuffer ) then
            (
                this.aggregate.msgBuffer = msg
            )
            
            False
        )
        else
        (
            True
        )
	),
    
    fn RemoveEmptyMapLoaders =
	(
		local emptyLoaderArr = this.GetAllEmptyMapLoaders()
		this.RemoveMapLoaders emptyLoaderArr
	),
    
    fn CheckMethod objArr: =
    (
        this.CheckEmptyBitmapTextures()
    ),
    
    fn FixMethod objArr: =
    (
        this.RemoveEmptyMapLoaders()
    ),
    
    fn SelectMethod objArr: =
    (
        format "***** No Select Method *****\n"
        undefined
    ),
    
    fn Run =
    (
        if not ( this.CheckMethod() ) then
        (
            if ( queryBox "Would you like to remove all empty bitmap loaders?" title:"?" ) then
            (
                this.FixMethod()
            )
        )
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
        -- Pass
    ),

    __init__ = _init()
)


