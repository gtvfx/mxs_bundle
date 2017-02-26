/*
__HELP__

Constructor: 
Instantiated Global: 



Methods:



__END__
*/





struct FileFns
(
    fn TransferFiles _fromDir: _toDir: fileArr:#all deleteAfter:False =
	(
		if _toDir == unsupplied then return (messageBox "TransferFiles requires you to supply a valid directory to transfer files: use the _toDir arg" title:"Missing args:")
		if not (DoesFileExist _toDir) then return (messageBox "The _toDir arg supplied to TransferFiles does not exist" title:"Invalid Directory:")
		if fileArr == #all and _fromDir == unsupplied then return (messageBox "TransferFiles requires you to supply a valid directory to collect files to transfer: use the _fromDir arg" title:"Missing args:")
		
		
		if fileArr == #all then
		(
			fileArr = GetFiles (_fromDir+"/*")
		)
		else
		(
			local arr = #()
			for i in fileArr do
			(
				if not DoesFileExist i then
				(
					format "***** File does not exist: % *****\n" i
					append arr i
				)
			)
			
			for i in arr do
			(
				DeleteItem fileArr (FindItem fileArr i)
			)
		)
		
		if fileArr.count != 0 then
		(
			for i in fileArr do
			(
				CopyFile i (_toDir + "/" + (FileNameFromPath i))
			)
		)
		
		if deleteAfter then
		(
			for i in fileArr do
			(
				deleteFile i
			)
		)
		
		
		format "***** % files transfered *****\n" fileArr.count
	),
	
	fn CopyMaxFilePathToClipboard =
	(
		SetClipBoardText (maxFilePath + maxFileName)
	),
	
	fn OpenMaxFileLocation =
	(
		ShellLaunch "explorer" maxfilepath 
	),
	
	fn OpenRenderLocation =
	(
		if DoesFileExist (GetFilenamePath rendOutputFilename) then ShellLaunch "explorer" (GetFilenamePath rendOutputFilename) else messageBox "Unable to access render path directory." title:"Error:"
	),
	
	fn OpenTempDir =
	(
		ShellLaunch "explorer" (GetDir #temp)
	),

	fn GetLatestFile filePath ext pattern:"" = 
	(			
		local fileList = (getfiles (filePath + "\\*." + ext))
		local assumedLatestFile = ""
		local latestWriteTime = 0L
	
		for newFile in fileList do 
		(
			if matchPattern newFile pattern:("*" + pattern + "*" ) then 
			(
				local FileInfo = dotNetObject "System.IO.FileInfo" newFile
				if FileInfo != undefined then 
				(
					local fileTime = FileInfo.LastWriteTime.Ticks
					if fileTime > latestWriteTime then 
					(
						assumedLatestFile = newFile
						latestWriteTime = FileInfo.LastWriteTime.Ticks
					)
				)
			)
		)
		assumedLatestFile
	),
    
    
    
    
    
    
    
    
    
    fn GetModule =
    (
        ( GetSourceFileName() )
    ),

    fn Help =
    (
        ::_ilmLibrary.GetScriptHelp ( this.GetModule() )
    ),

    private fn _init =
    (
        -- Pass
    ),

    __init__ = _init()
)

FileFns = FileFns()