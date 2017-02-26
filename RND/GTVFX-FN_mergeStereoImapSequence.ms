fn mergeStereoImapSequence seqDir01 seqDir02 saveDir =
(
	/* ========================================================
		seqDir01: Directory path to first vrmap sequence
		seqDir02: Directory path to second vrmap sequence
		saveDir: Directory path to where the combined map will be saved
		
		vrmap is currently named the same as the maps from seqDir01
	 ======================================================== */ 
	iMapViewer = @"C:\Program Files\Chaos Group\V-Ray\3dsmax 2012 for x64\tools\imapviewer.exe"
	if not doesFileExist iMapViewer then
	(
		format "***** Could not find imapviewer.exe *****\n"
		return false
	)
	seq01Arr = getFiles (seqDir01+"\*.vrmap")
	seq02Arr = getFiles (seqDir02+"\*.vrmap")
	if seq01Arr.count != seq02Arr.count then
	(
		format "***** vrmap sequences do not have the same number of files *****\n"
		return false
	)
	if not doesFIleExist saveDir then makeDir saveDIr
	for i in 1 to seq01Arr.count do
	(
		finalMap = (saveDir+"\\"+(getFileNameFile seq01Arr[i])+".vrmap")
		str = stringStream ""
		format "\"%\" -load % -load % -save % -nodisplay" iMapViewer seq01Arr[i] seq02Arr[i] finalMap to:str
		dosCommand (str as string)
	)
)




/* Example 

mergeStereoImapSequence @"C:\_cache\IrradianceMapTest\fullres_L\vrmap\" @"C:\_cache\IrradianceMapTest\fullres_R\vrmap\" @"C:\_cache\IrradianceMapTest\master\vrmap\"

