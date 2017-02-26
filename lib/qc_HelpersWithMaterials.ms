

struct qc_HelpersWithMaterials
(
    aggregate,
    debug = False,
    helperClasses = #(Point, Dummy),
    
    fn GetAllHelpersWithMaterials =
	(
		local out = #()
        
        for helperClass in this.helperClasses do
        (
            for h in ( GetClassInstances helperClass ) do
            (
                local depNodes = refs.dependentNodes h
                for n in depNodes where ( isProperty n #material ) and ( n.material != undefined ) do
                (
                    appendIfUnique out n
                )
            )
        )
        
		out
	),
    
	fn SelectHelpersWithMaterials =
	(
		select ( this.GetAllHelpersWithMaterials() )
	),
    
	fn RemoveAllMaterialsFromHelpers =
	(
		local helperArr = this.GetAllHelpersWithMaterials()
		local pl = Plane()
        
		for h in helperArr do
		(
			local base = copy h
			h.baseobject = copy pl.baseobject
			h.material = undefined
			instanceReplace h base
			delete base
		)
        
		delete pl
		--select helperArr
	),
    
	fn CheckHelpersWithMaterials =
	(
		local helperArr = this.GetAllHelpersWithMaterials()
        
        local msg = "There are " + ( helperArr.count as string ) + " helpers with materials in this scene"
        format "***** % *****\n" msg
        
        if helperArr.count != 0 then
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
        if not ( this.CheckHelpersWithMaterials() ) then
        (
            if ( queryBox "Would you like to remove all materials from Helpers?" title:"?" ) then
            (
                this.RemoveAllMaterialsFromHelpers()
            )
        )
    ),
    
    fn Help =
    (
        format "
---------------
CLASS USAGE:

Constructor = qc_HelpersWithMaterials
Instantiated Global = N/A

---------------\n"
    ),

    private fn _init =
    (
        -- Pass
    ),

    __init__ = _init()
)




