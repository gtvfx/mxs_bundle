fn pickDistFromCam =
(
	pDist = distance (getActiveCamera()) (pickObject())
	formDist = units.formatValue pDist
	setClipBoardText formDist
	format "***** Distance copied to clipboard *****\n"
	formDist
)
pickDistFromCam()