fn findModifierObjs objArr modtype arr:#() =
(
	for each in objArr do
	(
		for i in 1 to each.modifiers.count do
		(
			if classOf each.modifiers[i] == modtype then append arr each
			maxOps.CollapseNodeTo each (i+2) off
			
		)
	)
	if arr.count != 0 then
	(
		for each in arr do
		(
			modNum = (each.modifiers.count + 1)
			modPanel.setCurrentObject each.baseObject
			modPanel.addModToSelection (Mesh_Select ()) ui:on
			maxOps.CollapseNodeTo each modNum off
		)
	)
	select arr
	arr
)

findModifierObjs selection turboSmooth