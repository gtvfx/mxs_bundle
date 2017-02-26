sFile = (getFiles ((getDir #scripts) + "\GTVFX\*GTVFX-toolbox_MacrosLib*.*"))[1]
if doesFileExist sFile then filein sFile else messageBox "Could not find menu script file"