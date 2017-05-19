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
	
	fn CollectObjectsWithIllegalChars objArr:(Objects as array) regex:rx =
	(
		out = #()
		
		for obj in objArr do
		(
			-- Collect each character in the object's name as an array
			local nameArr = for i = 1 to obj.name.count collect obj.name[i]
				
			for n in nameArr do
			(
				-- loop through each character and test it against the regex
				if not (regex.isMatch n) then
				(
					-- If the test fails then we append the object to the output array
					-- We also exit the loop as soon as we find an illegal character. No need to continue checking the rest if one is found here.
					append out obj
					exit
				)
			)
		)
		
		out
	)
	
	fn SelectObjsWithIllegalNames =
	(
		/* 
		This programatically creates a pop-up menu with the names of all objects containing illegal characters
		
		This code concatenates a string that makes up the code for an rcmenu with a unique item for each object.
		 */
		local badNameArr = CollectObjectsWithIllegalChars()
		
		local rcTxt = "rcmenu pop_m\n(\n%\n%)\n"
		local st = stringStream ""
		local items = ""
		local events = ""
		
		for obj in badNameArr do
		(
			local itemStr = stringStream ""
			local mItem = stringStream ""
			local mEvent = stringStream ""
			local itemName = (ValidateMenuItemName obj.name)
			
			format "\tmenuItem %_item \"%\"\n" itemName obj.name to:mItem
			
			format "\ton %_item picked do (select (GetNodeByName (\"%\")))\n" itemName obj.name to:mEvent
			
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
	
	fn AutoFixNames regex:rx =
	(
		local badNameArr = CollectObjectsWithIllegalChars()
		
		for obj in badNameArr do
		(
			local nameArr = for i = 1 to obj.name.count collect obj.name[i]
				
			for n in nameArr do
			(
				-- Strip the illegal characters from the object name
				if not (regex.isMatch n) then
				(
					obj.name = SubstituteString obj.name n ""
				)
			)
			
			-- Check that the object name doesn't just consist of numbers after stripping the illegal characters
			-- If it does then append "Object_" to the name and ensure the name is unique
			if (obj.name as integer) != undefined then
			(
				obj.name = (UniqueName ("Object_" + obj.name))
			)
		)
	)
	
	fn CheckIllegalObjectNames =
	(
		local badNameArr = CollectObjectsWithIllegalChars()
		if badNameArr.count != 0 then
		(
			self.msgBuffer = "there are "+(badNameArr.count as string)+" objects with illegal names in the scene"
			False
		)
		else
		(
			True
		)
	)
	
	
	-- register the plugin
	self.plugManager.Register title:"Check For Illegal Object Names" method:CheckIllegalObjectNames aux:#(SelectObjsWithIllegalNames,AutoFixNames) active:True description:"Checks for objects with identical names"
)
