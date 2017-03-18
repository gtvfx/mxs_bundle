sFile = (getFiles ((getDir #scripts) + @"\GTVFX\GTVFX-LIB_layerIsolate.*"))[1]
if doesFileExist sFile then filein sFile else messageBox "Unable to access layerIsolate_lib"