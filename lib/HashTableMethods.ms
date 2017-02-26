struct HashTableMethods
(
    fn PrintDnetDic dic toStr: =
	( --Print out the Key/Value pairs of a DotNet Hashtable
		local DNArray = dotNetObject "System.string[]" dic.keys.count  
		dic.keys.copyTo DNArray 0 
        
		for i = 0 to ( dic.keys.count-1 ) do
		(
			local itemStr = ( DNArray.get i )
			case toStr of
            (
                (unsupplied):format "% = %\n" itemStr dic.item[itemStr] 
                default:format "% = %\n\r" itemStr dic.item[itemStr] to:toStr
            )
		)
	),
    
	fn GetDicKeys dic =
	( -- Collect the keys of a hash table. Returns an array of string values.
		local DNArray = dotNetObject "System.string[]" dic.keys.count  
		dic.keys.copyTo DNArray 0
        
		local out = #()
        
		for i = 0 to ( dic.keys.count-1 ) do
		(
			local itemStr = (DNArray.get i)
			append out itemStr
		)
        
		out
	),

	fn GetDicValues dic =
	(
		local DNArray = dotNetObject "System.string[]" dic.keys.count  
		dic.keys.copyTo DNArray 0
        
		local arr = #()
		for i = 0 to (dic.keys.count-1) do
		(
			local itemStr = ( DNArray.get i )
			append arr dic.item[itemStr]
		)
        
		arr
	),

	fn GetKeyFromValue dic val =
	(
		local DNArray = dotNetObject "System.string[]" dic.keys.count  
		dic.keys.copyTo DNArray 0
		
		for i = 0 to ( dic.keys.count-1 ) do
		(
			local itemStr = ( DNArray.get i )
			if dic.item[itemStr] == val then
            (
                return itemStr
            )
		)

		undefined
	),
    
    
    fn Help =
    (
        format "
---------------
CLASS USAGE:

Constructor = HashTableMethods
Instantiated Global = _hash
        
Methods:
    PrintDnetDic dic toStr:
        - Will print all key/value pairs to the listener
        - If toStr is supplied as a StringStream it will print to thtat stream.
        
    GetDicKeys dic
        - Returns a string array of all hash table keys
        
    GetDicValues dic
        - Returns an array of all the values in the hash table
        
    GetKeyFromValue dic val
        - A reverse lookup
        - Retuns the key string of the supplied value
        
---------------\n"
    ),
    
    
    
    private fn _init =
    (
        -- Pass
    ),

    __init__ = _init()
)

_hash = HashTableMethods()