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

Constructor: CopyPaste
Instantiated Global: CopyPaste

Methods:



__END__
*/




struct CopyPaste
(
    localDir = ( ( GetDir #temp )+ @"\copypaste\" ),
    networkDir,
    
    fn Copy fileName objArr:( GetCurrentSelection() ) location:this.localDir =
	(
        makeDir location
        
        if objArr.count > 0 then
        (
            SaveNodes objArr ( location + fileName )
        )
        else
        (
            messagebox "Nothing selected......" title:"GTVFX: Error"
        )
	),
    
    fn Paste filename location:this.localDir =
    (
        local file = ( location + fileName )
        
        if ( DoesFileExist file ) then
        (
            mergeMaxFile file #select
        )
        else
        (
            messagebox "Could not find a file to paste..." title:"GTVFX: Error"
        )
    ),
    
    fn GetModule =
    (
        ( GetSourceFilename() )
    ),

    fn Help =
    (
        ::mxs.GetScriptHelp ( this.GetModule() )
    ),

    private fn _init =
    (
        -- Pass
    ),

    __init__ = _init()
)

CopyPaste = CopyPaste()