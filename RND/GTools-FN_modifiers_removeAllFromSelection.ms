fn modifiers_removeAllFromSelection_FN =
	(
		for i in selection where superClassOf i == geometryClass do
			(
				while i.modifiers.count > 0 do
					(
						for each in i.modifiers do
							(
								deleteModifier i each
							)
					)
			)
	)

modifiers_removeAllFromSelection_FN()