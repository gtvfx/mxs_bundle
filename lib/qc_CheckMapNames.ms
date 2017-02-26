

struct qc_CheckMapNames
(
    aggregate,
    rgx = dotnetobject "System.Text.RegularExpressions.Regex" "[a-zA-Z0-9_.-<>]",
	sceneAssets,
	mapAssets,
	illegalNamesArr = #(),
    debug = False,
    
    fn CollectFileMetaData =
	(
		local fPath = ( MaxFilePath+MaxFileName )
		if not ( DoesFileExist fPath ) then
		(
            format "***** Unable to collect scene assets *****\n"
			this.sceneAssets = #()
			this.mapAssets = #()
			False
		)
		else
		(
			this.sceneAssets = ( GetMAXFileAssetMetadata fPath )
			this.mapAssets = for i in this.sceneAssets where i.type == #bitmap collect i
			True
		)
	),
	
	fn GetIllegalNames =
	(
        local out = #()
        
		if not ( this.CollectFileMetaData() ) then
        (
            return #()
        )
		
		for map in this.mapAssets do
		(
			local mapName = ( GetFileNameFile map.filename )
            
            local nameArr = for i = 1 to mapName.count collect mapName[i]
			
            for n in nameArr do
            (
                if not (this.rgx.isMatch n) then
                (
                    append out mapName
                    exit
                )
            )
		)
		
		out
	),
	
	fn CheckForIllegalNames =
	(
		this.illegalNamesArr = this.GetIllegalNames()
        
        local msg = "there are " + ( this.illegalNamesArr.count as string ) + " illegal map names in the scene"
        format "***** % *****\n" msg
        
        if this.illegalNamesArr.count != 0 then
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
	
	fn CleanMapNames =
	(
        this.SaveCheck()
        
		if this.sceneAssets == undefined or this.mapAssets == undefined then this.CollectFileMetaData()
		
		for map in this.mapAssets do
		(
			local fName = ( GetFileNameFile ( map.filename ) )
            
			local newName = fName
            
            local nameArr = for i = 1 to newName.count collect newName[i]
			
            for n in nameArr do
            (
                if not (this.rgx.isMatch n) then
                (
                    newName = SubstituteString newName n ""
                )
            )
            
			if newName != fName then
			(
                local mapPath = ( map.filename )
                
				local cFile = ( ( GetFileNamePath mapPath ) + newName + ( GetFileNameType mapPath ) )
				
				CopyFile mapPath cFile
				
                map.filename = cFile
			)
		)
		
		SetMAXFileAssetMetadata ( MaxFilePath + MaxFileName ) this.sceneAssets
		
		LoadMaxFile ( MaxFilePath + MaxFileName ) quiet:True
	),
    
    fn Run =
    (
        if not ( this.CheckForIllegalNames() ) then
        (
            if ( queryBox "Would you like to fix map names?" title:"?" ) then
            (
                this.CleanMapNames()
            )
        )
        else
        (
            OK
        )
    ),
	
    fn Help =
    (
        format "
---------------
CLASS USAGE:

Constructor = qc_CheckMapNames
Instantiated Global = N/A

---------------\n"
    ),

    private fn _init =
    (
        -- Pass
    ),

    __init__ = _init()
)


