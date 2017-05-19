
mxs.Using "Menu_Lib"

(
	local menuDir = ( ::_codeRoot + @"\lib\userinterface\menus\" )
	
	global MXS_MENUS = ::Menu_Lib sourceDir:menuDir default_category:"mxs" str_global:"MXS_MENUS"
)