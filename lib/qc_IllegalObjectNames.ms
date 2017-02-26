

struct qc_IllegalObjectNames
(
    aggregate,
    debug = False,
    
    -- regex with legal characters for object names
	rgx = dotnetobject "System.Text.RegularExpressions.Regex" "[a-zA-Z0-9_.]",
	
	-- regex with legal characters for menu item names
	rgx_menuItem = dotnetobject "System.Text.RegularExpressions.Regex" "[a-zA-Z0-9_]",
	
	fn ValidateMenuItemName _itemName regex:rgx_menuItem =
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
			if not (rgx.isMatch n) then
			(
				_itemName = SubstituteString _itemName n ""
			)
		)
		
		local out = ( "item_" + ( _itemName as string ) + ( ( random 0 9999999 ) as string ) )
	),
	
	fn CollectObjectsWithIllegalChars objArr:( Objects as array ) regex:rgx =
	(
		local out = #()
		
		for obj in objArr do
		(
			-- Collect each character in the object's name as an array
			local nameArr = for i = 1 to obj.name.count collect obj.name[i]
				
			for n in nameArr do
			(
				-- loop through each character and test it against the regex
				if not ( regex.isMatch n ) then
				(
					-- If the test fails then we append the object to the output array
					-- We also exit the loop as soon as we find an illegal character. No need to continue checking the rest if one is found here.
					append out obj
					exit
				)
			)
		)
		
		out
	),
	
	fn SelectObjsWithIllegalNames =
	(
		/* 
		This programatically creates a pop-up menu with the names of all objects containing illegal characters
		
		This code concatenates a string that makes up the code for an rcmenu with a unique item for each object.
		 */
		local badNameArr = this.CollectObjectsWithIllegalChars()
		
		local rcTxt = "rcmenu pop_m\n(\n%\n%)\n"
		local st = stringStream ""
		local items = ""
		local events = ""
		
		for obj in badNameArr do
		(
			local itemStr = stringStream ""
			local mItem = stringStream ""
			local mEvent = stringStream ""
			local itemName = ( this.ValidateMenuItemName obj.name )
			
			format "\tmenuItem %_item \"%\"\n" itemName obj.name to:mItem
			
			format "\ton %_item picked do (select (GetNodeByName (\"%\")))\n" itemName obj.name to:mEvent
			
			format "%\n" ( mItem as string ) to:itemStr
			
			items += itemStr as string 
			events += mEvent as string
			----
		)
		
		format rcTxt items events to:st
		
        if this.debug then
        (
            format "===== PopUp Menu =====\n"
            format "%" ( st as string )
        )
		
		local m = execute ( st as string )
		popUpMenu m pos:mouse.screenPos
	),
	
	fn AutoFixNames regex:rgx =
	(
		local badNameArr = this.CollectObjectsWithIllegalChars()
		
		for obj in badNameArr do
		(
			local nameArr = for i = 1 to obj.name.count collect obj.name[i]
				
			for n in nameArr do
			(
				-- Strip the illegal characters from the object name
				if not ( regex.isMatch n ) then
				(
					obj.name = SubstituteString obj.name n ""
				)
			)
			
			-- Check that the object name doesn't just consist of numbers after stripping the illegal characters
			-- If it does then append "Object_" to the name and ensure the name is unique
			if ( obj.name as integer ) != undefined then
			(
				obj.name = (UniqueName ("Object_" + obj.name))
			)
		)
	),
	
	fn CheckIllegalObjectNames =
	(
		local badNameArr = this.CollectObjectsWithIllegalChars()
        
        local msg = "There are " + ( badNameArr.count as string ) + " objects with illegal names in the scene"
        format "***** % *****\n" msg
        
        if badNameArr.count != 0 then
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
        if not ( this.CheckIllegalObjectNames() ) then
        (
            if ( queryBox "Would you like to fix all illegal object names?" title:"?" ) then
            (
                this.AutoFixNames()
            )
        )
        else
        (
            OK
        )
    ),
    
    fn Help =
    (
        format "
---------------
CLASS USAGE:

Constructor = qc_IllegalObjectNames
Instantiated Global = N/A

---------------\n"
    ),

    private fn _init =
    (
        -- Pass
    ),

    __init__ = _init()
)



