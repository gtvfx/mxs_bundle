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

Constructor = HashTableMethods
Instantiated Global = _hash
        
Methods:
    PrintDnetDic dic toStr:
        - Will print all key/value pairs to the listener
        - If toStr is supplied as a StringStream it will print to thtat stream.
        
    GetDicKeys dic
        - Returns a string array of all hash table keys
        
    GetDicValues dic
        - Returns an array of all the values in the hash table
        
    GetKeyFromValue dic val
        - A reverse lookup
        - Retuns the key string of the supplied value


__END__
*/



struct HashTableMethods
(
    fn PrintDnetDic dic toStr: =
	( --Print out the Key/Value pairs of a DotNet Hashtable
        local denum = dic.GetEnumerator()
        
        while ( denum.MoveNext() ) do
        (
            local iKey = denum.Current
            
            case toStr of
            (
                (unsupplied):format "% = %\n" iKey.Key iKey.Value
                default:format "% = %\n\r" iKey.Key iKey.Value to:toStr
            )
        )
	),
    
	fn GetDicKeys dic =
	( -- Collect the keys of a hash table. Returns an array of string values.
        local denum = dic.GetEnumerator()
        local out = #()
        
        while ( denum.MoveNext() ) do
        (
            local iKey = denum.Current
            
            append out iKey.Key
        )
        
		out
	),

	fn GetDicValues dic =
	(
		local denum = dic.GetEnumerator()
        local out = #()
        
        while ( denum.MoveNext() ) do
        (
            local iKey = denum.Current
            
            append out iKey.Value
        )
        
		out
	),

	fn GetKeyFromValue dic val =
	(
        local denum = dic.GetEnumerator()
        
        while ( denum.MoveNext() ) do
        (
            local iKey = denum.Current
            
            if iKey.Value == val then
            (
                return iKey.Key
            )
        )

		undefined
	),
	
	fn MakeDict keys:#() vals:#() =
	(
		if keys.count != vals.count then
		(
			messageBox "MakeDict:\nThere must be the same number of items for both \"keys\" and \"vals\"" title:"HashTableMethods:"
			return undefined
		)
		
		local dict = dotNetObject "System.Collections.Hashtable"
		
		for i = 1 to keys.count do
		(
			dict.Add keys[i] vals[i] 
		)
		
		out
	),
    
    fn GetModule =
    (
        ( GetThisScriptFileName() )
    ),
    
    fn Help =
    (
        ::mxs.GetScriptHelp ( GetThisScriptFileName() )
    ),
    
    private fn _init =
    (
        -- Pass
    ),

    __init__ = _init()
)

_hash = HashTableMethods()