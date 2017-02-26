struct PurgeAlembic
(
	objArr = objects,
	
	fn SceneRedraw state = -- state = #on or #off
	(
		/* 
		Toggle scene redraw
		Takes into account the level to which redraw was previously disabled
		 */
		case state of
		(
			#on:
			(
				while IsSceneRedrawDisabled() do
				(
					EnableSceneRedraw()
				)
			)
			#off:DisableSceneRedraw()
		)
	),
	
	fn ConvertTransformController obj ctrl:PRS =
	(
		obj.transform.controller = ctrl()
	),
	
	fn PurgeAlembicTimeControls =
	(
		if AlembicTimeControl != undefined then
		(
			arr = GetClassInstances AlembicTimeControl
			if arr.count != 0 then
			(
				for i in arr do
				(
					delete (refs.dependentNodes i)
				)
			)
		)
		else
		(
			format "***** AlembicTimeControl is not a defined class *****\n"
		)
	),

	fn AlembicModifierCheck obj =
	(
		for i in obj.modifiers do
		(
			if MatchPattern ((ClassOf i) as string) pattern:"*alembic*" then return True
		)
		False
	),

	fn CollapseAlembicObjs objArr =
	(
		if objArr.count != 0 then
		(
			for i in objArr do
			(
				if (AlembicModifierCheck i) and SuperClassOf i == GeometryClass then
				(
					if (CanConvertTo i Editable_Mesh) then
					(
						format "***** Converting to mesh: % *****\n" i.name
						ConvertTo i Editable_Mesh
					)
					if (classof i.transform.controller != PRS) then
					(
						ConvertTransformController i ctrl:PRS
					)
				)
			)
		)
	),
	
	fn _init =
	(
		SceneRedraw #off
		SetCommandPanelTaskMode #create
		CollapseAlembicObjs objArr
		PurgeAlembicTimeControls()
		SceneRedraw #on
	),
	__init__ = _init()
)


_alembicPurge = (PurgeAlembic objArr:objects)

