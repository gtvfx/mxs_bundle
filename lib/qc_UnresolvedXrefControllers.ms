

struct qc_UnresolvedXrefControllers
(
    aggregate,
    debug = False,
    
    fn GetUnresolvedXrefControllers =
	(
		local out = for i in ( GetClassInstances xref_controller ) where i.unresolved collect i
		out
	),
	
	fn SelectObjectsWithUnresolvedXrefControllers =
	(
		local objs = this.GetUnresolvedXrefControllers()
		local out = #()
		for o in objs do ( for a in ( refs.dependentNodes o ) do ( appendifunique out o ) )
		select out
	),
	
	fn CheckUnresolvedXRefControllers =
	(
		local objs = this.GetUnresolvedXrefControllers()
        
        local msg = "There are " + ( objs.count as string ) + " unresolved xref controllers"
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
        if not ( this.CheckUnresolvedXRefControllers() ) then
        (
            if ( queryBox "Would you like to select objects with Unresolved XRef Controllers?" title:"?" ) then
            (
                this.SelectObjectsWithUnresolvedXrefControllers()
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

Constructor = qc_UnresolvedXrefControllers
Instantiated Global = N/A

---------------\n"
    ),

    private fn _init =
    (
        -- Pass
    ),

    __init__ = _init()
)



