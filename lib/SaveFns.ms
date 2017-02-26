/************************************************************************************
Class for dealing with common save methods


************************************************************************************/


struct SaveFns
(
	fn VerPadding inString: Number: Pad: =
	(
		if (inString != unsupplied) and (Number != unsupplied) and (Pad != unsupplied) do
		(
			ZeroString = ""
			for x = 1 to (Pad - (Number as string).count) do (ZeroString = ZeroString + "0")
			(inString + (ZeroString + (Number as string)))
		)
	),
	
	fn SaveMajorVersion_FN userInit:false=
	(
		maxPreName = getFileNameFile maxFileName
		maxPreNameArr = filterString maxPreName "_"
		maxRootName = maxPreNameArr[1]
		for x = 2 to (maxPreNameArr.count - 2) do
		(
			maxRootName = maxRootName + "_" +  maxPreNameArr[x]
		)
		if not userInit then
		(
			curVersionNumber = ((filterString maxPreNameArr[maxPreNameArr.count - 1] "v")[1] as integer)
			userInit = maxPreNameArr[maxPreNameArr.count]
			newVersionNumber = VerPadding inString:"v" Number:(curVersionNumber + 1) Pad:3
			finalMaxFileName = maxfilepath + maxRootName + "_" + newVersionNumber + "_" + userInit + ".max"
		)
		else
		(
			curVersionNumber = ((filterString maxPreNameArr[maxPreNameArr.count] "v")[1] as integer)
			newVersionNumber = VerPadding inString:"v" Number:(curVersionNumber + 1) Pad:3
			finalMaxFileName = (maxfilepath + maxRootName + "_" + newVersionNumber + ".max")
		)
		if doesFileExist finalMaxFileName then
		(
			messageBox "You are not in the most recent file. \n If you need to create a major version from this file do so manually."
		)
		else
		(
			saveMaxFile finalMaxFileName useNewFile:true
		)
	),
	
	fn SaveIncrement_FN =
	(
		makeDir (maxfilepath + "_incrementalSave")
		maxPreName = getFileNameFile maxFileName
		verSaveFiles = (getfiles (maxFilePath + "_incrementalSave" + "\\" + maxPreName + "*.max"))
		verSaveFilesArr = 	for v in verSaveFiles collect (getFileNameFile v)
		verNum = (verSaveFilesArr.count + 1)
		if verNum < 10 then verNumPadding = "00"
		if verNum >= 10 and verNum < 100 then verNumPadding = "0"
		if verNum >= 100 then verNumPadding = ""
		verMaxFileName = maxFilePath + "_incrementalSave\\" + maxPreName  + "_" + verNumPadding + (verNum as string) + ".max"
		newSaveFile = maxFilePath + maxFileName
		renameFile newSaveFile verMaxFileName
		saveMaxFile newSaveFile useNewFile:true
	),
	
	fn CancelShutdown =
	(
		dosCommand "shutdown /a"
	),
	
	fn LaunchDeadlineSlave =
	(
		if not (shellLaunch "deadlineSlave.exe" "") then messageBox "Unable to lauch Deadline Slave." title:"GTVFX: Application Launch Error"
	),
	
	fn LaunchBackburnerSlave =
	(
		if not (shellLaunch "Slave.exe" "") then messageBox "Unable to lauch Deadline Slave." title:"GTVFX: Application Launch Error"
	),
	
	fn SaveAndCloseMax slave_dl:false slave_bb:false=
	(
		saveIncrement_FN()
		if slave_dl then launchDeadlineSlave()
		else if slave_bb then launchBackburnerSlave()
		quitMax #noPrompt
	),
	
	fn SaveAndRestart =
	(
		saveIncrement_FN()
		dosCommand "shutdown -t 30 -f -r -d up:125:1 -c \"Save & Close By GTVFX: 30 Seconds to restart...\""
		quitMax #noPrompt
	),
	
	fn SaveAndShutdown =
	(
		saveIncrement_FN()
		dosCommand "shutdown -t 30 -f -s -d up:125:1 -c \"Save & Close By GTVFX: 30 Seconds to shutdown...\""
		quitMax #noPrompt
	),
	
	fn SaveAndClose_ui =
	(
		rollout ro "Save & Close By GTVFX" width:300 
		(
			local self
			local clrWindow = ((colorMan.getColor #window)*255)
			local clrText = ((colorMan.getColor #text)*255)
			local ClrBackGround = ((colorMan.getColor #background)*255)
			group "Save And Close Options:"
			(
				dropDownList ddl_option items:#("Quit Max","Quit Max and Launch Deadline Slave","Restart","Shutdown")
			)
			dotNetControl dNbtn_execute "button" height:40 
			hyperLink hyp_website "www.gtvfx.com" color:orange  hoverColor:red visitedColor:orange address:"http://www.gtvfx.com" offset:[ro.width/2-50,0]
			
			fn _init pself =
			(
				self = pself
				self.initDnetBtn dNbtn_execute "Save & Close" 12 colorOffsetInt:15 tooltip:"Execute the selected option."
			)
			on dNbtn_execute mouseClick do
			(
				case ddl_option.selected of
				(
					("Quit Max"): self.saveAndCloseMax()
					("Quit Max and Launch Deadline Slave"): self.saveAndCloseMax slave:true
					("Restart"): self.saveAndRestart()
					("Shutdown"): self.saveAndShutdown()
				)
			)
			on dNbtn_execute MouseEnter arg do
			(
				self.initToolTip dNbtn_execute dNbtn_execute.tag
			)
			on dNbtn_execute MouseLeave arg do
			(
				self.destroyToolTip()
			)
		)
		createDialog ro
		ro._init self
	),
	
	private fn __init__ =
	(
		self = this
	),
	
	_init = __init__()
)

_saveFns = SaveFns()