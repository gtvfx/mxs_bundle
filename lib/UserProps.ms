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

Constructor: UserProps
Instantiated Global: UserProps

[METHODS]


[DESCRIPTION]


[USAGE]


__END__
*/



mxs.Using "HashTableMethods"


struct UserProps
(
public
    
    debug = False,
    
    fn QsortAphlabetical str1 str2 =
    (
        case of
        (
            (str1 < str2): -1
            (str1 > str2): 1
            default: 0
        )
    ),
    
    fn HasNameSpace str =
    (
        out = ( MatchPattern str pattern:"*:*" )
    ),
    
    fn EnsurePropBuffer obj =
    (
        local propBuffer = ( GetUserPropBuffer obj )

        if ( propBuffer[propBuffer.count] != "\n" ) then
        (
            SetUserPropBuffer obj ( propBuffer + "\n" )
        )
    ),
    
    fn EnsureNameSpace nameSpaceStr =
    (
        if ( nameSpaceStr != "" ) and ( nameSpaceStr[nameSpaceStr.count] != ":" ) then ( nameSpaceStr += ":" )
        
        nameSpaceStr
    ),
    
    fn ClearUserPropBuffer obj =
    (
        SetUserPropBuffer obj ""
    ),
    
    fn HashPropBufferString propStr =
    (
        local out = ( dotNetObject "System.String" ( propStr as string ) ).GetHashCode()
        ( out as string )
    ),
    
    fn SetProp obj propKey propVal nameSpace:"" overwrite:True =
    (
        nameSpace = this.EnsureNameSpace nameSpace
        
        propKey = ( nameSpace + propKey )
        
        if not overwrite then
        (
            local propDic = this.UserPropBufferToDictionary obj
            
            if ( propDic.ContainsKey propKey ) then
            (
                format "***** % is already a property of % *****\n" propKey obj.name
                return True
            )
        )
        
        SetUserProp obj ( propKey ) ( propVal as string )
    ),
    
    fn GetProp obj propKey nameSpace:"" =
    (
		nameSpace = this.EnsureNameSpace nameSpace
        format "PropKey: %\n" ( nameSpace + propKey )
        GetUserProp obj ( nameSpace + propKey )
    ),
    
    fn PropBufferStringToDictionary propString =
    (		
		local propStringArr = ( FilterString propString "\n\r" )
		
		local dic = dotNetObject "System.Collections.Hashtable"
        
		for i in propStringArr do
		(
			local keyVal = ( FilterString i "=" )
            
            if keyVal[1][keyVal[1].count] == " " then keyVal[1] = ( replace keyVal[1] keyVal[1].count 1 "" )
            
            if keyVal[2][1] == " " then keyVal[2] = ( replace keyVal[2] 1 1 "" )
            
			if not ( dic.ContainsKey keyVal[1] ) then
			(
				dic.add keyVal[1] keyVal[2]
			)
		)
        
		dic
    ),
    
    fn UserPropBufferToDictionary obj =
	(
		this.PropBufferStringToDictionary ( GetUserPropBuffer obj )
	),
    
    fn DictionaryToUserPropBuffer dic obj overwrite:True clearBuffer:False =
    (
        local keyArr = ::_hash.GetDicKeys dic
        Qsort keyArr this.QsortAphlabetical
        
        if clearBuffer then
        (
            this.ClearUserPropBuffer obj
        )
        
        for k in keyArr do
        (
            this.SetProp obj k dic.item[k] nameSpace:"" overwrite:overwrite 
        )
    ),
    
    fn FormatPropStringFromDic propDic = 
    (
        local keyArr = ::_hash.GetDicKeys propDic
        Qsort keyArr this.QsortAphlabetical
        
        local str = StringStream ""
        
        for k in keyArr do
        (
            format "% = %\n\r" k propDic.item[k] to:str
        )
        
        if this.debug then format "%\n" (str as string)
        
        ( str as string )
    ),
    
    fn FilterPropBufferDic obj nameSpace:"" =
    ( -- Returns a dictionary containing only the userPropBuffer items that match the supplied nameSpace
        
        local propDic = this.UserPropBufferToDictionary obj
        
        local dicKeyArr = ::_hash.GetDicKeys propDic
        
        for dicKey in dicKeyArr do
        (
            if not ( matchPattern dicKey pattern:( nameSpace + "*" ) ) then
            (
                propDic.Remove dicKey
            )
        )
        
        propDic
    ),
    
    fn SortPropBuffer obj =
    (
        local propDic = this.UserPropBufferToDictionary obj
        local newPropBuffer = this.FormatPropStringFromDic propDic
        local keyArr = ::_hash.GetDicKeys propDic
        Qsort keyArr this.QsortAphlabetical
        
        this.ClearUserPropBuffer obj
        
        for k in keyArr do
        (
            this.SetProp obj k propDic.item[k]
        )
    ),

    fn SortObjectsByUserPropBuffer objArr mode:#hash nameSpace:"" = -- mode = #hash, or #name
    (
        /* 
                This returns a dictionary
                Key = ( Unique User Prop Buffer )
                
                mode can be either #hash or #name
                
                Depending on mode:
                    Value:
                        #hash = ( Array of node hash values from the GetHandleByAnim method )
                        #name = ( Array of object names )
                */
        
        local dic = dotNetObject "System.Collections.Hashtable"
        
        for obj in objArr do
        (
            local propBufferDic = this.FilterPropBufferDic obj nameSpace:nameSpace
            local propBuffer = this.FormatPropStringFromDic propBufferDic
            
            if ( propBuffer == "" ) or ( propBuffer == OK ) then
            (
                propBuffer = "empty"
            )
            
            local val = undefined
                
            case mode of 
            (
                ( #hash ):val = ( GetHandleByAnim obj )
                ( #name ):val = ( obj.name )
            )
            
            local hashKey = this.HashPropBufferString propBuffer
            
            if dic.ContainsKey hashKey then
            (
                local valArr = dic.item[hashKey]
                
                dic.Remove hashKey
                
                append valArr val
                
                dic.add hashKey valArr
            )
            else
            (
                dic.add hashKey #(val)
            )
        )
        
        dic
    ),
    
    fn RemoveNameSpaceGroup obj nameSpace =
    (
        if ( nameSpace != "" ) and ( namespace[nameSpace.count] != ":" ) then ( nameSpace += ":" )
        
        local propDic = this.UserPropBufferToDictionary obj
        local keyArr = ::_hash.GetDicKeys propDic
        
        for k in keyArr do
        (
            if ( matchPattern k pattern:( namespace + "*" ) ) then
            (
                propDic.Remove k
            )
        )
        
        this.ClearUserPropBuffer obj
        this.DictionaryToUserPropBuffer propDic obj overwrite:True
    ),
    
    fn RemoveUserPropItem obj propKey =
    (
        local propDic = this.UserPropBufferToDictionary obj
        
        if ( propDic.ContainsKey propKey ) then
        (
            propDic.Remove propKey
            
            this.DictionaryToUserPropBuffer propDic obj overwrite:True
        )
        else
        (
            format "***** Object prop buffer doesnot contain the value: % *****\n" propKey
        )
    ),
    
    fn CollectAllNameSpaces propDic =
    (
        local keyArr = ::_hash.GetDicKeys propDic
        
        local nameSpaceArr = #()
        
        for k in keyArr do
        (
            if ( MatchPattern k pattern:"*:*" ) then
            (
                local strArr = ( FilterString k ":" )
                
                AppendIfUnique nameSpaceArr strArr[1]
            )
        )
        
        nameSpaceArr
    ),
    
    fn GetModule =
    (
        ( GetSourceFilename() )
    ),
    
    fn Help =
    (
        ::mxs.GetScriptHelp ( GetSourceFilename() )
    ),
    
private

    fn _init =
    (
        -- Pass
    ),

    __init__ = _init()
)

UserProps = UserProps()