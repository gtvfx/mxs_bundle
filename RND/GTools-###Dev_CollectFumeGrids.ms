$.getPath "default"
$.getPath "wavelet"
$.getPath "retimer"


fumeObjs = for i in objects where classOf i == fumeFX collect i
	
fumeObjs[1].getPath "default"

fumePathArr = filterString (fumeObjs[1].getPath "default") "\\"
fumePath = fumePathArr[1]
for i in 2 to fumePathArr.count - 1 do fumePath += ("\\" + fumePathArr[i])
fumePath += "\\*.*"

fumeFiles = getFiles fumePath 
fumeFiles.count