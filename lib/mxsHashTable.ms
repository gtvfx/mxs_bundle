/* 
Hash table constructor that makes accessing data a bit easier
 */
 
 
 
struct mxsHashTable
(
    _hashTable = dotNetObject "System.Collections.HashTable",
	keys = #(),

    fn Add key value =
	(
        _hashTable.Add(dotNetObject "System.String" (key as string)) (value)
		append keys key
		value
    ),

    fn Clear =
	(
        _hashTable.Clear()
    ),

    fn ContainsKey key =
	(
        _hashTable.ContainsKey (key as string)
    ),

    fn ContainsValue value =
	(
        _hashTable.ContainsValue (value as string)
    ),

    fn Remove key =
	(
        _hashTable.Remove (key as string)
		"Removed"
    ),

    fn Lookup key =
	(
	   _hashTable.item[(dotNetObject "System.String" (key as string))]
    ),

    fn Modify key value =
	(
        remove key
        add key value
    ),

    fn Size =
	(
        _hashTable.count
    )
)