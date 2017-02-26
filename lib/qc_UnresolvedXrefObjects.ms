struct qc_UnresolvedXrefObjects
(
    aggregate,
    debug = False,
    
    fn GetUnresovledXRefObjects =
	(
		local objs = for o in ( GetClassInstances xrefobject ) where o.unresolved collect o
		objs
	),
	
	fn SelectUnresolvedXRefObjects =
	(
		local out = #()
		for i in ( this.GetUnresovledXRefObjects() ) do
		(
			local refsArr = refs.dependentNodes i
			for ref in refsArr do
			(
				if IsValidNode ref then
				(
					append out ref
				)
			)
		)
        
		select out
	),
	
	fn CheckUnresolvedXRefObjects =
	(
		local objs = this.GetUnresovledXRefObjects()
        
        local msg = "There are " + ( objs.count as string ) + " unresolved XRef Objects"
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
        if not ( this.CheckUnresolvedXRefObjects() ) then
        (
            if ( queryBox "Would you like to select Unresolved XRef Objects?" title:"?" ) then
            (
                this.SelectUnresolvedXRefObjects()
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

Constructor = qc_UnresolvedXrefObjects
Instantiated Global = N/A

---------------\n"
    ),

    private fn _init =
    (
        -- Pass
    ),

    __init__ = _init()
)


