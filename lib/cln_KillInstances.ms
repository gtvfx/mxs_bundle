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

Constructor: 
Instantiated Global: 

Methods:



__END__
*/


struct cln_KillInstances
(
public

    aggregate,
    debug = False,
    progBar = undefined,
    objArr,
    
    fn KillInstances objArr:this.objArr =
    ( -- Removes all instancing (Makes all objects unique)
        if objArr == undefined then
        (
            throw "KillInstances needs a valid object array to operate on.\n-- Either define this at the <objArr> class parameter\n-- or use the optional <objArr:> flag on the method."
        )
        
        if objArr.count != 0 then
        (
            InstanceMgr.MakeObjectsUnique objArr #individual 
            True
        )
        else
        (
            False
        )
    ),
    
    fn Run objArr:this.objArr =
    (
        this.KillInstances objArr:objArr
    ),

private
    
    fn _init =
    (
        -- Pass
    ),

    __init__ = _init()
)

