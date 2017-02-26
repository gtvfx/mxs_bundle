/*************************************************************************************
__MXSDOC__

Author:				Gavyn Thompson
Company:				GTVFX
Website:				www.gtvfx.com
Email:				gthompson@gtvfx.com
ScriptVersion:			v1.2
Updated:				03/11/2014
[Purpose]
Menu creating library for generating the GTVFX menu

__END__
*************************************************************************************/

struct GTVFXmacros_lib
(
	GTVFX_toolboxMenu,
	GTVFX_UImenu,
	ANM_Menu,
	SCA_Menu,
	MSH_Menu,
	MTL_Menu,
	PRD_Menu,
	SEL_Menu,
	TCH_Menu,
	UTL_Menu,
	libMacros = #(),
	
	fn testGTB =
	(
		if gtb == undefined then false else true
	),
	fn formatMacro_FN macroName mcrCategory sFile stream =
	(
		format ("macroScript %\ncategory:\"%\"\nbuttonText:\"%\"\n(\n\tfileIn (getFiles ((getDir #scripts)+\"\\\\GTVFX\\\\\"+\"%\"+\".*\"))[1]\n)\n") \
		macroName mcrCategory macroName sFile to:stream
	),
	fn macroFromString macroName mcrCategory stringCommand =
	(
		str = stringStream ""
		format ("macroScript %\ncategory:\"%\"\nbuttonText:\"%\"\n(\n\t%\n)\n") \
		macroName mcrCategory macroName stringCommand to:str
		seek str 0
		readExpr str
	),
	fn fileIn_FN filePath =
	(
		if doesFileExist filePath then
		(
			fileIn filePath
		)
		else return false
		true
	),
	fn errorMessage index =
	(
		case index of
		(
			1: messageBox "Unable to find file." title:"GTVFX Error Message:"
			2: messageBox "GTVFX Toolbox is not initialized for some reason..." title:"GTVFX Error Message:"
			default: messageBox "Something went wrong..." title:"GTVFX Error Message:"
		)
	),
	fn addMacroItem menu macroName macroCategory macroText =
	(
		menuAction = menuMan.createActionItem macroName macroCategory
		menuAction.setTitle macroText
		menuAction.setUseCustomTitle true
		menu.addItem menuAction -1
	),
	fn purgeMacros =
	(
		GTVFX_macros = getFiles ((getDir #usermacros) + "\\GTVFX-*.mcr")
		if GTVFX_macros != undefined then for i in GTVFX_macros do deleteFile i
	),
	fn createLibMacros =
	(
		sFileArr = getFiles ((getDir #scripts) + @"\GTVFX\*.*")
		for i in sFileArr where not matchPattern i pattern:"*GTVFX-toolbox*" and not matchPattern i pattern:"*GTVFX-LIB*" do
		(
			fileName = substituteString (getFileNameFIle i) "GTVFX-" ""	
			append libMacros fileName
			stream = stringStream ""
			formatMacro_FN fileName "GTVFX" (getFileNameFile i) stream
			seek stream 0
			readExpr stream
		)
		libMacros
	),
	fn createToolboxMacros =
	(
		macroFromString "toolBox" "GTVFX" "if gtb != undefined then\n(\n\ttry(cui.unRegisterDialogBar gtb.ro_toolbox)catch()\n\ttry(destroyDialog gtb.ro_toolbox)catch()\n\tgtb.run()\n\tgtb.updateUI_FN()\n)\nelse GTVFXmacros.errorMessage 2\n"
		macroFromString "Manage_Callbacks" "GTVFX" "if gtb != undefined then gtb.callBacksUi() else GTVFXmacros.errorMessage 2"
		macroFromString "Save_Utility" "GTVFX" "if gtb != undefined then gtb.breakOffRollout 1 else GTVFXmacros.errorMessage 2"
		macroFromString "Copy_Paste" "GTVFX"  "(if gtb != undefined then gtb.breakOffRollout 2 else GTVFXmacros.errorMessage 2)"
		macroFromString "Material_Tools" "GTVFX" "if gtb != undefined then gtb.breakOffRollout 3 else GTVFXmacros.errorMessage 2"
		macroFromString "Slate_Tools" "GTVFX" "if gtb != undefined then gtb.breakOffRollout 4 else GTVFXmacros.errorMessage 2"
		macroFromString "Utilities" "GTVFX" "if gtb != undefined then gtb.breakOffRollout 5 else GTVFXmacros.errorMessage 2"
		macroFromString "Render" "GTVFX" "if gtb != undefined then gtb.breakOffRollout 6 else GTVFXmacros.errorMessage 2"
		macroFromString "Mesh_Tools" "GTVFX" "if gtb != undefined then gtb.breakOffRollout 7 else GTVFXmacros.errorMessage 2"
		macroFromString "Wire_Color" "GTVFX" "if gtb != undefined then gtb.breakOffRollout 8 else GTVFXmacros.errorMessage 2"
		macroFromString "Selection_Tools" "GTVFX" "if gtb != undefined then gtb.breakOffRollout 9 else GTVFXmacros.errorMessage 2"
		macroFromString "Anim_Tools" "GTVFX" "if gtb != undefined then gtb.breakOffRollout 10 else GTVFXmacros.errorMessage 2"
		macroFromString "File_Operations" "GTVFX" "if gtb != undefined then gtb.breakOffRollout 11 else GTVFXmacros.errorMessage 2"
		macroFromString "Object_Props" "GTVFX" "if gtb != undefined then gtb.breakOffRollout 12 else GTVFXmacros.errorMessage 2"
		macroFromString "VRay_Props" "GTVFX" "if gtb != undefined then gtb.breakOffRollout 13 else GTVFXmacros.errorMessage 2"
		macroFromString "UI_Options" "GTVFX" "if gtb != undefined then gtb.breakOffRollout 14 else GTVFXmacros.errorMessage 2"
	),
	fn sortMacroItems category arr:#()=
	(
		arr = for i in libMacros where matchPattern i pattern:("*"+category+"_*") collect i
		arr
	),
	fn genMenuFromArr menuID mcrArr menuName =
	(
		menuID = menuMan.createMenu menuName
		for i in mcrArr do
		(
			addMacroItem menuID i "GTVFX" i
		)
	),
	fn genLibMenus =
	(
		createLibMacros()
		ANMitems = sortMacroItems "ANM"
		SCAitems = sortMacroItems "SCA"
		PRDitems = sortMacroItems "PRD"
		SELitems = sortMacroItems "SEL"
		MSHitems = sortMacroItems "MSH"
		MTLitems = sortMacroItems "MTL"
		TCHitems = sortMacroItems "TCH"
		UTLitems = sortMacroItems "UTL"
		
		ANM_Menu = menuMan.createMenu "Animation"
		for i in ANMitems do addMacroItem ANM_Menu i "GTVFX" (replace i 1 4 "")
		SCA_Menu = menuMan.createMenu "Scene Assembly"
		for i in SCAitems do addMacroItem SCA_Menu i "GTVFX" (replace i 1 4 "")
		MSH_Menu = menuMan.createMenu "Mesh Operations"
		for i in MSHitems do addMacroItem MSH_Menu i "GTVFX" (replace i 1 4 "")
		MTL_Menu = menuMan.createMenu "Material Tools"
		for i in MTLitems do addMacroItem MTL_Menu i "GTVFX" (replace i 1 4 "")
		TCH_Menu = menuMan.createMenu "Technical Artist"
		for i in TCHitems do addMacroItem TCH_Menu i "GTVFX" (replace i 1 4 "")
		PRD_Menu = menuMan.createMenu "Production"
		for i in PRDitems do addMacroItem PRD_Menu i "GTVFX" (replace i 1 4 "")
		SEL_Menu = menuMan.createMenu "Selection"
		for i in SELitems do addMacroItem SEL_Menu i "GTVFX" (replace i 1 4 "")
		UTL_Menu = menuMan.createMenu "Utilities"
		for i in UTLitems do addMacroItem UTL_Menu i "GTVFX" (replace i 1 4 "")
	),
	fn genUImenu =
	(
		if GTVFX_UImenu == undefined do
		(
			GTVFX_UImenu = menuMan.createMenu "Toolbox:UI"
			addMacroItem GTVFX_UImenu "Save_Utility" "GTVFX" "Save Utility"
			addMacroItem GTVFX_UImenu "Copy_Paste" "GTVFX" "Copy/Paste"
			addMacroItem GTVFX_UImenu "Material_Tools" "GTVFX" "Material Tools"
			addMacroItem GTVFX_UImenu "Slate_Tools" "GTVFX" "Slate Tools"
			addMacroItem GTVFX_UImenu "Utilities" "GTVFX" "Utilities"
			addMacroItem GTVFX_UImenu "Render" "GTVFX" "Render"
			addMacroItem GTVFX_UImenu "Mesh_Tools" "GTVFX" "Mesh Tools"
			addMacroItem GTVFX_UImenu "Wire_Color" "GTVFX" "Wire Color"
			addMacroItem GTVFX_UImenu "Selection_Tools" "GTVFX" "Selection Tools"
			addMacroItem GTVFX_UImenu "Anim_Tools" "GTVFX" "Anim Tools"
			addMacroItem GTVFX_UImenu "File_Operations" "GTVFX" "File Operations"
			addMacroItem GTVFX_UImenu "Object_Props" "GTVFX" "Object Props"
			addMacroItem GTVFX_UImenu "VRay_Props" "GTVFX" "VRay Props"
			addMacroItem GTVFX_UImenu "UI_Options" "GTVFX" "UI Options"
		)
	),
	fn genToolBoxMenu =
	(
		genUImenu()
		genLibMenus()
		maxMenu = menuMan.getMainMenuBar()
		GTVFX_toolboxMenu = menuMan.findMenu "GTVFX:Toolbox"
		if GTVFX_toolboxMenu != undefined do
		(
			menuMan.unRegisterMenu GTVFX_toolboxMenu
			menuMan.updateMenuBar()
			GTVFX_toolboxMenu = undefined
		)
		if GTVFX_toolboxMenu == undefined do
		(
			GTVFX_toolboxMenu = menuMan.createMenu "GTVFX:Toolbox"
			----
			addMacroItem GTVFX_toolboxMenu "toolBox" "GTVFX" "Toolbox"
			addMacroItem GTVFX_toolboxMenu "Manage_Callbacks" "GTVFX" "Manage Callbacks"
			----
			theAction = menuMan.createSeparatorItem()
			GTVFX_toolboxMenu.addItem theAction -1
			----
			GTVFX_toolboxMenu.addItem (menuMan.createSubMenuItem "Toolbox:UI" GTVFX_UImenu) -1
			----
			theAction = menuMan.createSeparatorItem()
			GTVFX_toolboxMenu.addItem theAction -1
			--
			GTVFX_toolboxMenu.addItem (menuMan.createSubMenuItem "Animation" ANM_Menu) -1
			GTVFX_toolboxMenu.addItem (menuMan.createSubMenuItem "Scene Assembly" SCA_Menu) -1
			GTVFX_toolboxMenu.addItem (menuMan.createSubMenuItem "Mesh Operations" MSH_Menu) -1
			GTVFX_toolboxMenu.addItem (menuMan.createSubMenuItem "Material Tools" MTL_Menu) -1
			GTVFX_toolboxMenu.addItem (menuMan.createSubMenuItem "Technical Artist" TCH_Menu) -1
			GTVFX_toolboxMenu.addItem (menuMan.createSubMenuItem "Production" PRD_Menu) -1
			GTVFX_toolboxMenu.addItem (menuMan.createSubMenuItem "Selection" SEL_Menu) -1
			GTVFX_toolboxMenu.addItem (menuMan.createSubMenuItem "Utilities" UTL_Menu) -1
			--
			theSubMenu = menuMan.createSubMenuItem "GTVFX:Toolbox" GTVFX_toolboxMenu
			maxMenu.addItem theSubMenu -1
			menuMan.updateMenuBar()
		)
	),
	fn unregisterMenue =
	(
		/********
		This callback removes the menu from Max.
		To be run at preSystemShutdown.
		********/
		maxMenu = menuMan.getMainMenuBar()
		GTVFX_toolboxMenu = menuMan.findMenu "GTVFX:Toolbox"
		try(menuMan.unRegisterMenu GTVFX_toolboxMenu)catch()
		menuMan.updateMenuBar()
	),
	fn loadExternalMacroLibs =
	(
		fileIn_FN (getFiles ((getDir #scripts) + @"\GTVFX\GTVFX-LIB_layerIsolate*"))[1]
	),
	fn initToolbox =
	(
		if gtb == undefined then
		(
			toolboxFile = (getFiles ((getDir #scripts) + "\GTVFX\*toolbox_pro*"))[1]
			if toolboxFile != undefined and doesFIleExist toolboxFile then
			(
				fileIn toolboxFIle
				true
			)
			else
			(
				format "***** Unable to initialize the main toolbox. *****\n"
				false
			)
		)
		else true
	),
	fn addCallBackFromString =
	(
		str = stringStream ""
		format "callbacks.addScript #preSystemShutdown \"GTVFXmacros.unregisterMenue()\" id:#unregisterMenue" to:str
		seek str 0
		readExpr str
	),
	fn _init =
	(
		if not initToolbox() then return errorMessage 2
		purgeMacros()
		createToolboxMacros()
		loadExternalMacroLibs()
		genToolBoxMenu()
		addCallBackFromString()
	),
	init = _init()
)

GTVFXmacros = GTVFXmacros_lib()
