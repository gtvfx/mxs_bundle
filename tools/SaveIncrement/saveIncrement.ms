/*
__MXSDOC__

[TITLE]
SaveIncrement.ms

[DESCRIPTION]
Facilitates a workflow where files are never overwritten.

Every time you save a backup of the file is moved to an "_incrementalSave" folder in the current directory.

[USAGE]
You can run this tool from any 3dsmax file.

[CREATION INFO]
Author: Gavyn Thompson
E-mail: gthompson@ilm.com
Company: Industrial Light and Magic
Last Updated: 10-07-2014

[Category]
Utility

[KEYWORDS]
Save
increment

[VERSION HISTORY]


[DEPENDENCIES]
none

[SEE ALSO]
Save Major

__END__
*/

fn saveIncrement =
(
	if maxFileName == "" then return False
	makeDir (maxfilepath + "_incrementalSave")
	maxPreName = getFileNameFile maxFileName
	verSaveFiles = (getfiles (maxFilePath+"_incrementalSave\\"+maxPreName+"*.max"))
	verSaveFilesArr = 	for v in verSaveFiles collect (getFileNameFile v)
	verNum = (verSaveFilesArr.count + 1)
	if verNum < 10 then verNumPadding = "00"
	if verNum >= 10 and verNum < 100 then verNumPadding = "0"
	if verNum >= 100 then verNumPadding = ""
	verMaxFileName = maxFilePath+"\\_incrementalSave\\"+maxPreName+"_"+verNumPadding+(verNum as string)+".max"
	newSaveFile = maxFilePath + maxFileName
	renameFile newSaveFile verMaxFileName
	saveMaxFile newSaveFile useNewFile:true
	format "***** Save Successful *****\n"
)
saveIncrement()
