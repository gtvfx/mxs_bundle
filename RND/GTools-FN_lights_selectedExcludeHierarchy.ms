fn lights_selectedExcludeHierarchy_FN =
	(
		/******************************************************
		Dependencies:
			Requires GToolsStruct:
				GTools.GF_getParentsRecursive
				GTools.GF_getChildrenRecursive
		
		*******************************************************/
		for each in selection where superClassOf each == Light do
			(
				parentArr = #()
				childArr = #()
				
				GTools.GF_getParentsRecursive $ parentArr

				for i in parentArr do
					(
						GTools.GF_getChildrenRecursive i childArr
					)
					
				$.excludeList = (for i in childArr where superClassOf i == geometryClass collect i)
			)
	)


	
lights_selectedExcludeHierarchy_FN()

























/*
<light>.excludeList Array default: #()
Objects in this array are excluded from the effects of the light.

