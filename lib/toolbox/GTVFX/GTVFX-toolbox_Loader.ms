if ( ::gtb == undefined ) then
(
	local toolboxFile = (( GetDir #userscripts) + @"\GTVFX\GTVFX-toolbox_pro.ms")
	
	if ( DoesFileExist toolboxFile ) then
	(
		FileIn toolboxFile
		
		if ::gtb != undefined then
		(
			if ::gtb.startUp then
			(
				::gtb.run()
				if ( DoesFileExist ::gtb.gtbINI ) then
				(
					::gtb.updateUI_FN()
				)
				else
				(
					::gtb.saveUI_FN()
					::gtb.updateUI_FN()
				)
			)
			else
			(
				format "***** Toolbox initialized without UI *****\n"
			)
		) 
	)
	else 
	(
		format "***** Unable to initialize tooblox: Could not find the script file. *****\n"
	)
)


