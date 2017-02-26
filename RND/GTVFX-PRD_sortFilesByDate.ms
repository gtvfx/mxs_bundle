struct sortPhotosByDate_struct
(
	homeDir,
	filesArr,
	datesArr,
	folderArr,
	
	fn collectPhotoFiles dir =
	(
		filesArr = getFiles (dir + "*")
	),
	fn collectFileDates arr =
	(
		datesArr = #()
		for i in arr do
		(
			appendIfUnique datesArr (filterString (getFileModDate i) " ")[1]
		)
	),
	fn createFolders arr =
	(
		folderArr = #()
		for i in arr do
		(
			partArr = filterString i "//"
			for i in 1 to partArr.count do if partArr[i].count == 1 then partArr[i] = ("0"+partArr[i])
			appendIfUnique folderArr (partArr[3]+"-"+partArr[1]+"-"+partArr[2])
		)
		for i in folderArr do
		(
			makeDir (homeDir + i)
		)
	),
	fn sortFilesToFolders =
	(
		for i in folderArr do
		(
			dateMatchArr = filterString i "-"
			dateMatch = (dateMatchArr[2]+"/"+dateMatchArr[3]+"/"+dateMatchArr[1])
			curFiles = getFiles (homeDir + "*")
			fileMatchArr = for c in curFiles where matchPattern (filterString (getFileModDate c) " ")[1] pattern:dateMatch collect c
			for each in fileMatchArr do
			(
				renameFile each ((getFileNamePath each) + i + "\\" + (getFileNameFile each) + (getFileNameType each))
			)
		)
	),
	fn run =
	(
		this.collectPhotoFiles homeDir
		this.collectFileDates filesArr
		this.createFolders datesArr
		this.sortFilesToFolders()
	)
)
sbd = sortPhotosByDate_struct()
sbd.homeDir = @"C:\_cache\test\"
sbd.run()



