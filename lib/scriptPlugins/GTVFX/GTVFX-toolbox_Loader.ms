if gtb == undefined then
(
	_init = false
	format "***** Loading in toolbox *****\n"
	toolboxFilePro = (getFiles ((getDir #scripts) + "\GTVFX\*toolbox_pro*.*"))[1]
	toolboxFileLite = (getFiles ((getDir #scripts) + "\GTVFX\*toolbox_lite*.*"))[1]
	if toolboxFilePro != undefined then
	(
		fileIn toolboxFilePro
		_init = true
	)
	else if toolboxFileLite != undefined then
	(
		fileIn toolboxFileLite
		_init = true
	)
	else messageBox "Could not find the toolbox file." title:"GTVFX: Error"

	if _init then
	(
		if gtb != undefined then
		(
			if gtb.startUp then
			(
				gtb.run()
				if doesFileExist gtb.gtbINI then
				(
					gtb.updateUI_FN()
				)
				else
				(
					gtb.saveUI_FN()
					gtb.updateUI_FN()
				)
			)
			else
			(
				format "***** Toolbox initialized without UI *****\n"
			)
		) 
	)
	else format "***** Unable to initialize tooblox: Could not find the script file. *****\n"
)


