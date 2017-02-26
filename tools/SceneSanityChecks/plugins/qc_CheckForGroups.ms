(
	-- 'Inherit' the main tool
	self = ::SceneSanityChecks
	
	fn GetAllGroupHeads =
	(
		groupArr = for i in objects where isGroupHead i collect i
		groupArr
	)
	
	fn SelectAllGroupHeads =
	(
		select (GetAllGroupHeads())
	)
	
	fn ConvertGroupsToTopNulls =
	(
		for g in (GetAllGroupHeads()) do
		(
			tPoint = [(g.min.x + ((g.max.x - g.min.x)/2)),(g.min.y + ((g.max.y - g.min.y)/2)),g.max.z]
			tNull = point transform:g.transform pos:tPoint name:g.name cross:False box:True axisTripod:True
			if g.parent != undefined then tNull.parent = g.parent
			arr = for i in g collect i
			setGroupOpen g True
			delete g
			for i in arr where isValidNode i do i.parent = tNull
		)
		True
	)
	
	fn CheckForGoups =
	(
		arr = GetAllGroupHeads()
		if arr.count != 0 then
		(
			self.msgBuffer = "There are "+arr.count as string+" groups in this scene"
			return false
		)
		true
	)
	
	
	-- register the plugin
	self.plugManager.Register title:"Check For Groups" method:CheckForGoups aux:#(SelectAllGroupHeads,ConvertGroupsToTopNulls) active:True description:"Checks for any groups in the scene"
)
