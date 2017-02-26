/*
__HELP__

Constructor: StringAutoCompleter
Instantiated Global: N/A



Methods:



__END__
*/




struct StringAutoCompleter
(
	str_items = #(),
	str_hashs = #(),
	
	possibilities = #(),
	
	fn addStrList strList =
	(
		this.str_items = strList
		this.str_hashs = #()
		
		for str_item in this.str_items do
		(
			if str_item != undefined then
			(
				append this.str_hashs (this.get_hash_str_value str_item)
			)
			else
			(
				append this.str_hashs -1
			)
		)
	),
	
	fn get_hash_str_value str =
	(
		local total = 0
		local count = str.count 
		if count > 12 then count = 12
			
		for i = 1 to count do
		(
			local base = (28 as Integer64) ^ (13 - i)
			local val = bit.charAsInt(str[i]) - 95
			
			total += val * base
		)
		
		total
	),
	
	fn GetPossibilities input_str =
	(
		this.possibilities = #()
		local upper_bound_str = input_str + "z"
		local upper_bound_hash = this.get_hash_str_value upper_bound_str
		local input_str_hash = this.get_hash_str_value input_str
		
		for i = 1 to str_items.count do
		(
			local str_item = str_items[i]
			local str_hash = str_hashs[i]
			
			if str_hash <= upper_bound_hash and str_hash >= input_str_hash then
			(
				append this.possibilities str_item
			)
		)
		
		this.possibilities
	)
	
	fn GetModule =
	(
		( GetSourceFileName() )
	),

	fn Help =
	(
		-- Static Method
		::_ilmLibrary.GetScriptHelp ( GetSourceFilename() )
	),

private
    
    fn _init =
	(
		-- Pass
	),

	__init__ = _init()
)



