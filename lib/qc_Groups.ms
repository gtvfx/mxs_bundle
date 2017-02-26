_ilmLibrary.Load "ilmEventTimer"
_ilmLibrary.load "CopyPasteAnimation"

struct qc_Groups
(
	aggregate,
    debug = False,
	
	fn GetAllGroupHeads =
	(
		local groupArr = for i in objects where isGroupHead i collect i
		groupArr
	),
	
	fn SelectAllGroupHeads =
	(
		select (this.GetAllGroupHeads())
	),
		
	fn ConvertGroupsToNulls =
	(
		local groupConvert = EventTimer caption:"Converting groups"
		SetCommandPanelTaskMode #Create
		::_ilmLibrary.BlockUi True
		
		local groupHeadArr = (this.GetAllGroupHeads())
			
		for g in groupHeadArr do
		(
			setGroupOpen g True
			
			local tNull = point transform:g.transform name:g.name cross:False box:True axisTripod:True
			
			if g.parent != undefined then tNull.parent = g.parent
				
			local groupObjArr = for i in g collect i
				
			if g.isAnimated then
			(
				::_CopyPasteAnimation.CopyPasteAnim g tNull
			)
			
			for i in groupObjArr where (isValidNode i) and (i.parent == g) do i.parent = tNull
		)
		
		delete groupHeadArr
		
		groupConvert.End()
		
		::_ilmLibrary.BlockUi False
		True
	),
	
	fn CheckForGroups =
	(
		local arr = this.GetAllGroupHeads()
        
        local msg = "There are "+arr.count as string+" groups in this scene"
        format "***** % *****\n" msg
        
		if arr.count != 0 then
		(
			if ( this.aggregate != undefined ) and ( isProperty this.aggregate #msgBuffer ) then
			(
				this.aggregate.msgBuffer = msg
			)
			
			False
		)
		else
		(
			True
		)
	),
    
    fn Run =
    (
        if ( this.CheckForGroups() ) then
        (
            if ( queryBox "Would you like to convert all groups to nulls?" title:"?" ) then
            (
                this.ConvertGroupsToNulls()
            )
        )
    ),
	
	fn ClassUsage =
	(
		format "
---------------
CLASS USAGE:

Constructor = qc_Groups
Instantiated Global = N/A

---------------\n"
	),
	
	private fn _init =
	(
		-- Pass
	),

	__init__ = _init()
)
