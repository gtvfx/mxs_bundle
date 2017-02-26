fn CleanSaveNodes objArr fpath =
(
	local tempDir = (getDir #temp)
	local tempFile
	
	
	if (DoesFileExist tempDir) then
	(
		format "***** Cleaning Exported Scene *****\n"
		with redraw off
		(
			tempFile = (tempDir + @"\cleansavenodes.max")
			SaveNodes objArr tempFile quiet:True
			
			HoldMaxFile()
			
			ResetMaxFile #noPrompt
			Delete $*
			
			MergeMaxFile tempFile #mergeDups #useMergedMtlDups #alwaysReparent quiet:True
			
			SaveMaxFile fpath useNewFile:False quiet:True
			
			DeleteFile tempFile
			
			FetchMaxFile quiet:True
		)
	)
	else
	(
		Throw "Unable to acces temp directory"
	)
)


fPath = @"D:\tempsphere001.max"

CleanSaveNodes (GetCurrentSelection()) fPath