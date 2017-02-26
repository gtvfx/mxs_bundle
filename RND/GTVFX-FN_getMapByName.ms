fn getMapByName mapName =
(
	arr = #()
	for cls in texturemap.classes do
	(
		for i in getClassInstances cls where matchPattern i.name pattern:mapName do append arr i
	)
	format "***** arr: % *****\n" arr
	arr
)