sFile = (getFiles ((getDir #scripts) + @"\GTVFX\GTVFX-toolbox_Loader.*"))[1]
if doesFileExist sFile then filein sFile else messageBox "Cannot find toolbox script file"