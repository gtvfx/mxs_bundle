/*
Would like to set up call backs that display the PXM Profile that is being used as well as the full maxFilePath.

*/
struct applicationTitleStruct
(
	--self,
	callBackId = #PXM_AppTitle,
	fileData,
	enabled = True,
	
	fn getProfile =
	(
		out = "LAX Workstation Max 2012"
	),
	fn setTitle =
	(
		profile = getProfile()
		if doesFileExist (fName = maxfilepath + maxfilename) then cui.setAppTitle (profile + " | " + fName)
	),
	fn preAction =
	(
		d = callbacks.notificationparam()
		fileData = if d[1] < 2 then d
	),
	fn postAction =
	(
		if fileData != undefined and enabled then cui.setAppTitle (getProfile() + " | " + fileData[2])
	),
	on create do
	(
		format "***** Create Event *****\n"
		--self = this --not needed yet
		
		callbacks.removescripts id:callBackId
		callbacks.addscript #filePreOpenProcess "PXM_AppTitle.preAction()" id:callBackId
		callbacks.addscript #filePreSaveProcess "PXM_AppTitle.preAction()" id:callBackId
		callbacks.addscript #filePostOpenProcess "PXM_AppTitle.postAction()" id:callBackId
		callbacks.addscript #filePostSaveProcess "PXM_AppTitle.postAction()" id:callBackId
		if enabled then setTitle()
	)
)

::PXM_AppTitle = applicationTitleStruct()

