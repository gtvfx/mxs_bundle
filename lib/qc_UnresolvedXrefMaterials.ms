
struct qc_UnresolvedXrefMaterials
(
    aggregate,
    debug = False,
    
    fn GetUnresolvedXRefMaterials =
	(
		local out = for o in ( GetClassInstances xrefmaterial ) where o.unresolved and ( refs.dependentNodes o ).count != 0  collect o
		out
	),
	
	fn SelectObjectsWidthUnreslovedXrefsMaterials =
	(
		local objs = this.GetUnresolvedXRefMaterials()
		local out = #()
		for o in objs do ( for a in ( refs.dependentNodes o ) do ( appendifunique out a ) )
		select out
	),
	
	fn CheckUnresolvedXRefMaterials =
	(
		local objs = this.GetUnresolvedXRefMaterials()
        
        local msg = "There are " + ( objs.count as string ) + " unresolved xref Materials"
        format "***** % *****\n" msg
        
        if objs.count != 0 then
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
        if not ( this.CheckUnresolvedXRefMaterials() ) then
        (
            if ( queryBox "Would you like to select objects with Unresolved XRef Materials?" title:"?" ) then
            (
                this.SelectObjectsWidthUnreslovedXrefsMaterials()
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

Constructor = qc_UnresolvedXrefMaterials
Instantiated Global = N/A

---------------\n"
    ),

    private fn _init =
    (
        -- Pass
    ),

    __init__ = _init()
)
