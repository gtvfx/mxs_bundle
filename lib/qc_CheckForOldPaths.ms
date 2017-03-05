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

Constructor: qc_CheckForOldPaths
Instantiated Global: 

[METHODS]


[DESCRIPTION]
This is a QC module designed to be loaded by a plugin object, but suited for stand-alone calls as well.

This module relies on a hard-coded dictionary made up of keys values that are the 'old' path string and values that are the 'new' path string replacement
 - This could easily be setup to use an external ini file if that is desired.

[USAGE]
Use the 'Run' method to automatically check for and replace old path values.

__END__
*/


mxs.Using "HashTableMethods"


struct qc_CheckForOldPaths
(
public
    
    aggregate,
	sceneAssets = #(),
    debug = False,
    keyDic = dotNetObject "System.Collections.Hashtable",
    keyDicKeys = #(),
    maxFile,
    quiet = True,
    
    fn SaveCheck =
	(
        -- CheckForSave()
		if ( queryBox "You must save your file to continue.\nWould you like to save now?" title:"Save Check" ) then
		(
			SaveMaxFile ( MaxFilePath + MaxFileName ) useNewFile:True quiet:True
			True
		)
		else
		(
			False
		)
	),
    
    fn GetMaxFile filePath:( MaxFilePath + MaxFileName ) quiet:this.quiet =
    (
        if ( DoesFileExist filePath ) and ( IsMaxFile filePath ) then
        (
            this.maxFile = filePath
        )
        else
        (
            if quiet then
            (
                format "!!!!! Error: The filePath supplied is not a valid 3dsmax file !!!!!\n"
            )
            else
            (
                messageBox "The filePath supplied is not a valid 3dsmax file" title:"File Error:"
            )
            
            this.maxFile = undefined
        )
        
        this.maxFile
    ),
    
    fn GetKeyDic =
    (
        -- pathConfig.convertPathToUnc
        this.keyDic.add "\\\\san" "\\\\lucas\\ilm"
        this.keyDic.add "I:" "\\\\lucas\\ilm"
        this.keyDic.add "P:" "\\\\lucas\\ilm\\show"
        this.keyDic.add "S:" "\\\\lucas\\ilm\\sww"
        
        this.keyDicKeys = ::_hash.GetDicKeys this.keyDic
    ),
    
    fn GetSceneAssets filePath:this.maxFile quiet:this.quiet =
    (
        if filePath == undefined then filePath = this.GetMaxFile()
        
        if filePath != undefined and ( DoesFileExist filePath ) then
        (
            this.sceneAssets = ( GetMaxFileAssetMetaData filePath )
        )
        else
        (
            if quiet then
            (
                format "!!!!! Error: GetSceneAssets requires a valid 3dsmax file. !!!!!\n"
            )
            else
            (
                messageBox "GetSceneAssets requires a valid 3dsmax file." title:"Error:"
            )
            
            this.sceneAssets = #()
        )
    ),
    
    fn CollectOldPaths refactor:False =
    (
        if this.sceneAssets.count == 0 or refactor then this.GetSceneAssets()
        
        local out = #()
        
        for data in this.sceneAssets do
        (
            local fName = data.filename
            
            for item in this.keyDicKeys do
            (
                if ( matchPattern fName pattern:( item + "*" ) ) then
                (
                    append out data.filename
                    
                    exit
                )
            )
        )
        
        out
    ),
    
    fn CheckForOldPaths refactor:False =
    (
        local oldPaths = this.CollectOldPaths refactor:refactor
        
        local msg = "there are " + ( oldPaths.count as string ) + " old paths in the scene"
        format "***** % *****\n" msg
        
        if oldPaths.count != 0 then
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
    
    fn FilePathIsCurrentFile filePath =
    (
        if filePath == ( MaxFilePath + MaxFileName ) then
        (
            True
        )
        else
        (
            False
        )
    ),
    
    fn FixOldPaths refactor:False filePath:this.maxFile =
    (
        if this.sceneAssets.count == 0 or refactor then this.GetSceneAssets()
        if filePath == undefined then filePath = this.GetMaxFile()
        
        local curFile = ( this.FilePathIsCurrentFile filePath )
        
        if curFile then
        (
            if not ( this.SaveCheck() ) then
            (
                messageBox "Cannot fix the paths in the current 3dsmax file without saving first." title:"Error:"
                return undefined
            )
        )
        
        for data in this.sceneAssets do
        (
            local fName = data.filename
            local nName = fName
            
            for item in this.keyDicKeys do
            (
                if ( matchPattern fName pattern:( item + "*" ) ) then
                (
                    nName = substituteString nName item this.keyDic.item[item]
                    
                    
                    exit
                )
            )
            
            data.filename = nName
        )
        
        if this.debug then format "***** Setting Metadata *****\n"
        SetMAXFileAssetMetadata filePath this.sceneAssets
        
        if curFile then 
        (
            LoadMaxFile filePath quiet:True
        )
    ),
    
    fn CheckMethod objArr: =
    (
        this.CheckForOldPaths refactor:True
    ),
    
    fn FixMethod objArr: =
    (
        this.FixOldPaths()
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
            this.FixMethod()
        )
    ),
    
    fn GetModule =
    (
        ( GetSourceFileName() )
    ),

    fn Help =
    (
        ::mxs.GetScriptHelp ( GetSourceFilename() )
    ),

private
    
    fn _init =
    (
        this.GetKeyDic()
    ),

    __init__ = _init()
)



/*
testPath = @"I:\show"

x = pathConfig.convertPathToUnc testPath
x


*/
