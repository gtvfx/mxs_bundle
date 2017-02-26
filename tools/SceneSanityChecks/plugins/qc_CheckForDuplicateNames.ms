(
	-- 'Inherit' the main tool
	self = ::SceneSanityChecks
	
	-- regex with legal characters for object names
	rx = dotnetobject "System.Text.RegularExpressions.Regex" "[a-zA-Z0-9_.]"
	
	-- regex with legal characters for menu item names
	rx_menuItem = dotnetobject "System.Text.RegularExpressions.Regex" "[a-zA-Z0-9_]"
	
	fn ValidateMenuItemName _itemName regex:rx_menuItem =
	(
		/* 
		This function is used during the programatic building of the rcmenu
		
		the _timeName arg is meant to be the Object.name. This function compares each character in the name with a regex and strips out characters that are invalid ofr menu item names
		
		It appends the string 'item_' to the beginning to handle cases where the object name is made up of only numbers.
		It then appends a random number to the end of the item name to help ensure the uniqueness of the name.
		 */
		local nameArr = for i = 1 to _itemName.count collect _itemName[i]
			
		for n in nameArr do
		(
			if not (rx.isMatch n) then
			(
				_itemName = SubstituteString _itemName n ""
			)
		)
		
		local out = ("item_" + (_itemName as string) + ((random 0 9999999) as string))
	)
	
	fn GetDuplicateNames objArr:(objects as array) = 
	(
		local nameArr = #()
		local dupNameArr = #()
		
		for i in objArr do
		(
			local indx = FindItem nameArr i.name
			case indx of
			(
				(0):
				(
					append nameArr i.name
				)
				default:
				(
					appendIfUnique dupNameArr i.name
				)
			)
		)
		
		dupNameArr
	)
	
	fn SelectDuplicateNames =
	(
		/* 
		This programatically creates a pop-up menu with the names of all objects containing illegal characters
		
		This code concatenates a string that makes up the code for an rcmenu with a unique item for each object.
		 */
		
		local dupNameArr = GetDuplicateNames()
		
		local rcTxt = "rcmenu pop_m\n(\n%\n%)\n"
		local st = stringStream ""
		local items = ""
		local events = ""
		
		for d in dupNameArr do
		(
			local itemStr = stringStream ""
			local mItem = stringStream ""
			local mEvent = stringStream ""
			local itemName = (ValidateMenuItemName d)
			
			format "\tmenuItem %_item \"%\"\n" (itemName as string) d to:mItem
			format "\ton %_item picked do (select (GetNodeByName (\"%\") all:True))\n" itemName d to:mEvent
			format "%\n" (mItem as string) to:itemStr
			
			items += itemStr as string 
			events += mEvent as string
			----
		)
		
		format rcTxt items events to:st
		
		--format "===== PopUp Menu =====\n"
		--format "%" (st as string)
		
		m = execute (st as string)
		popUpMenu m pos:mouse.screenPos
	)
	
	fn AutoUniqueNames =
	(
		local dupNameArr = GetDuplicateNames()
		
		for d in dupNameArr do
		(
			local nArr = (GetNodeByName d all:True)
			
			if nArr.count > 1 then
			(
				for n in nArr do
				(
					n.name = UniqueName n.name
				)
			)
		)
		
	)
	
	fn CheckDuplicateNames =
	(
		local dupNameArr = GetDuplicateNames()
		
		if dupNameArr.count != 0 then
		(
			self.msgBuffer = "There are "+(dupNameArr.count as string)+" duplicate names in the scene"
			False
		)
		else
		(
			True
		)
	)
	
	
	-- register the plugin
	self.plugManager.Register title:"Check Duplicate Names" method:CheckDuplicateNames aux:#(SelectDuplicateNames,AutoUniqueNames) active:True description:"Checks for objects with identical names"
)
