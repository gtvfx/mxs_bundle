/* 
    By: Gavyn Thompson
    gthompson@ilm.com
    
    Class to find objects in the scene with identical names.
    
    Methods to programatically create a popUp menu to display names of duplicates and selct the objects with those names
    and also to automatically rename offending objects with the 'unqueName' method builtin to Maxscript.
*/

struct qc_DuplicateObjectNames
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
			if not ( regex.isMatch n ) then
			(
				_itemName = SubstituteString _itemName n ""
			)
		)
		
		local out = ( "item_" + ( _itemName as string ) + ( ( random 0 9999999 ) as string) )
	),
	
	fn GetDuplicateNames objArr:( objects as array ) = 
	(
		local nameArr = #()
		local dupNameArr = #()
		
		for obj in objArr do
		(
			local indx = ( FindItem nameArr obj.name )
			case indx of
			(
				(0):
				(
					append nameArr obj.name
				)
				default:
				(
					appendIfUnique dupNameArr obj.name
				)
			)
		)
		
		dupNameArr
	),
	
	fn SelectDuplicateNames =
	(
		/* 
		This programatically creates a pop-up menu with the names of all objects containing illegal characters
		
		This code concatenates a string that makes up the code for an rcmenu with a unique item for each object.
		 */
		
		local dupNameArr = this.GetDuplicateNames()
		
		local rcTxt = "rcmenu pop_m\n(\n%\n%)\n"
		local st = stringStream ""
		local items = ""
		local events = ""
		
		for d in dupNameArr do
		(
			local itemStr = stringStream ""
			local mItem = stringStream ""
			local mEvent = stringStream ""
			local itemName = (this.ValidateMenuItemName d)
			
			format "\tmenuItem %_item \"%\"\n" (itemName as string) d to:mItem
			format "\ton %_item picked do (select (GetNodeByName (\"%\") all:True))\n" itemName d to:mEvent
			format "%\n" ( mItem as string ) to:itemStr
			
			items += itemStr as string 
			events += mEvent as string
			----
		)
		
		format rcTxt items events to:st
		
        if this.debug then
        (
            format "===== PopUp Menu Code =====\n"
            format "%" (st as string)
        )
		
		local m = execute (st as string)
		popUpMenu m pos:mouse.screenPos
	),
	
	fn AutoUniqueNames =
	(
		local dupNameArr = this.GetDuplicateNames()
		
		for d in dupNameArr do
		(
			local nArr = ( GetNodeByName d all:True )
			
			if nArr.count > 1 then
			(
				for n in nArr do
				(
					n.name = UniqueName n.name
				)
			)
		)
	),
	
	fn CheckDuplicateNames =
	(
		local dupNameArr = this.GetDuplicateNames()
		        
        local msg = "There are " + ( dupNameArr.count as string ) + " duplicate names in the scene"
        format "***** % *****\n" msg
        
        if dupNameArr.count != 0 then
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
        if not ( this.CheckDuplicateNames() ) then
        (
            if ( queryBox "Would you like to automatically rename objects with duplicate names?" title:"?" ) then
            (
                this.AutoUniqueNames()
            )
        )
    ),
    
    
    fn Help =
    (
        format "
---------------
CLASS USAGE:

Constructor = qc_DuplicateObjectNames
Instantiated Global = N/A

---------------\n"
    ),

    private fn _init =
    (
        -- Pass
    ),

    __init__ = _init()
)




