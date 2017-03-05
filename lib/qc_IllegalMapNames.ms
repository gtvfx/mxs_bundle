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



mxs.Using "MapHelper"


struct qc_IllegalMapNames
(
public
    
    super,
	objArr,
	debug = False,
	
	title = "Check For Illegal Map Names",
	description = "Checks for texture maps with illegal characters in their names",
	
    rgx = dotnetobject "System.Text.RegularExpressions.Regex" "[a-zA-Z0-9_.-<>]",
	
	mapLoaderArr = #(),
	textureMapArr = #(),
	illegalNamesArr = #(),
    
	fn ClearValues =
	(
		this.mapLoaderArr = #()
		this.textureMapArr = #()
		--this.illegalNamesArr = #()
	),
	
	fn GetFileByName filename =
	(
		local out = ( for file in this.textureMapArr where ( GetFileNameFile file ) == filename collect file )[1]
		out
	),
	
	fn CollectMapLoaders objArr:this.objArr =
	(
		local mapArr = #()
		
		for obj in objArr where ( obj.material != undefined ) do
		(
			mapArr += ( GetClassInstances BitmapTexture target:obj.material )
			
			if ( VRayHDRi != undefined ) then
			(
				mapArr += ( GetClassInstances VRayHDRi target:obj.material )
			)
		)
		
		this.mapLoaderArr = mapArr
		
		mapArr
	),

	fn CollectTextureFiles objArr:this.objArr =
	(
		local mapArr = this.CollectMapLoaders objArr:objArr
		
		mapArr = ( MakeUniqueArray mapArr )
		
		local fileArr = ::MapHelper.GetMapLoaderFileNames mapLoaderArr:mapArr 
		
		fileArr = ( MakeUniqueArray fileArr )
		
		fileArr
	),
	
	fn CollectUsedMaps objArr:this.objArr =
	(
		/* 
		This method is more elegant and should work, however it misses some files that the other methods collect.
		*/
		local mapArr = #()
		
		for obj in objArr do
		(
			mapArr += UsedMaps obj
		)
		
		mapArr = ( MakeUniqueArray mapArr )
		
		mapArr
	),
	
	fn GetIllegalNames objArr:this.objArr =
	(
		this.ClearValues()
		
        local out = #()
        
		this.textureMapArr = this.CollectTextureFiles objArr:objArr
		
		for map in this.textureMapArr do
		(
			local mapName = ( GetFileNameFile map )
			
			local nameArr = for i = 1 to mapName.count collect mapName[i]
			
			for n in nameArr do
			(
				if not ( this.rgx.isMatch n ) then
				(
					append out mapName
					exit
				)
			)
		)
		
		out
	),
	
	fn CheckForIllegalNames objArr:this.objArr =
	(
		this.illegalNamesArr = this.GetIllegalNames objArr:objArr
        
        local msg = "there are " + ( this.illegalNamesArr.count as string ) + " illegal map names"
        print ( msg as string )
        
        if this.illegalNamesArr.count != 0 then
        (
            if ( this.super != undefined ) and ( isProperty this.super #msgBuffer ) then
            (
                this.super.msgBuffer = msg
            )
            
            False
        )
        else
        (
            True
        )
	),
	
	fn CleanMapNames objArr:this.objArr =
	(
		if this.illegalNamesArr.count == 0 then this.CheckForIllegalNames objArr:objArr
		--this.CheckForIllegalNames objArr:objArr
		
		for mapName in this.illegalNamesArr do
		(
			local newName = mapName
            
            local nameArr = for i = 1 to newName.count collect newName[i]
			
            for n in nameArr do
            (
                if not (this.rgx.isMatch n) then
                (
                    newName = SubstituteString newName n ""
                )
            )
            
			if newName != mapName then
			(
                local mapPath = this.GetFileByName mapName
                
				local cFile = ( ( GetFileNamePath mapPath ) + newName + ( GetFileNameType mapPath ) )
				
				-- Copy the texture file and save it with the new name.
				CopyFile mapPath cFile
				
				-- get all loaders by the filename and set them all to the new filename
				local loaderArr = ::MapHelper.GetMapLoadersByFileName mapPath mapLoaderArr:this.mapLoaderArr
				
				for each in loaderArr do
				(
					::MapHelper.SetMapLoaderFilename each cFile
				)
			)
		)
	),
	
	fn ShowIllegalFiles =
	(
		if this.illegalNamesArr.count != 0 then
		(
			local illegalFilesArr = #()
			
			for filename in this.illegalNamesArr do
			(
				append illegalFilesArr ( this.GetFileByName filename )
			)
			
			local str = StringStream ""
			
			for file in illegalFilesArr do
			(
				format "%\n" file to:str
			)
			
			messageBox ( str as string ) title:"Illegally Named Files:"
		)
	),
    
    fn CheckMethod objArr:this.objArr =
    (
        this.CheckForIllegalNames objArr:objArr
    ),
    
    fn FixMethod objArr:this.objArr =
    (
        this.CleanMapNames objArr:objArr
    ),
    
    fn SelectMethod objArr: =
    (
        format "***** No Select Method *****\n"
		this.ShowIllegalFiles()
        undefined
    ),
    
    fn Run =
    (
        if not ( this.CheckMethod() ) then
        (
            if ( queryBox "Would you like to fix map names?" title:"?" ) then
            (
                this.FixMethod()
            )
        )
        else
        (
            OK
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
		format "***** Closing Material Editor *****\n"
		MatEditor.Close()
        if this.objArr == undefined then
        (
            this.objArr = ( objects as array )
        )
    ),

    __init__ = _init()
)


