struct CheckForGroups
(
	agregate,
	
	fn GetAllGroupHeads =
	(
		local out = for i in objects where isGroupHead i collect i
		out
	),
	
	fn SelectAllGroupHeads =
	(
		select (this.GetAllGroupHeads())
	),
	
	fn ConvertGroupsToTopNulls =
	(
		for g in (this.GetAllGroupHeads()) do
		(
			local tPoint = [(g.min.x + ((g.max.x - g.min.x)/2)),(g.min.y + ((g.max.y - g.min.y)/2)),g.max.z]
			local tNull = point transform:g.transform pos:tPoint name:g.name cross:False box:True axisTripod:True
			if g.parent != undefined then tNull.parent = g.parent
			local arr = for child in g collect child
			setGroupOpen g True
			delete g
			for i in arr where isValidNode i do i.parent = tNull
		)
		
		True
	),
	
	fn UpdateMsgBuffer _args:#() _str: =
	(
		if ( this.agregate != undefined ) and ( isProperty this.agregate #msgBuffer ) then 
		(
			free this.agregate.msgBuffer
			_str = this.agregate.msgBuffer
		)
		
		format "There are % groups in this scene\n" _args[1] to:_str
	),
	
	fn CheckForGoups =
	(
		local arr = this.GetAllGroupHeads()
		if arr.count != 0 then
		(
			this.UpdateMsgBuffer _args:#(arr.count)
			False
		)
		else
		(
			True
		)
	)
)

_checkForGroups = CheckForGroups()