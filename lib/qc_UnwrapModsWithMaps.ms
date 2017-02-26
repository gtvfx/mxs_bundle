struct qc_UnwrapModsWithMaps
(
    aggregate,
    debug = False,
    
    fn GetMapLoaders =
    (
        out = ( GetClassInstances BitMapTexture )
        if VRayHDRi != undefined then
        (
            out += ( GetClassInstances VRayHDRi )
        )
        out
    ),
    
    fn GetAllUnwrapModifiers =
	(
		local bMaps = this.GetMapLoaders()
        
		out = #()
		for b in bMaps do
		(
			for d in ( refs.dependents b ) where ( classof d ) == unwrap_uvw and ( refs.dependentNodes d ).count > 0 do append out d
		)
        
		out
	),
	
	fn SelectUnwrapModifierObjects =
	(
		local uDubMods = this.GetAllUnwrapModifiers()
        
		local objs = #()
		for m in uDubMods do for o in refs.dependentNodes m do appendifunique objs o
		select objs
	),
	
	fn CollapseToUnwrapModifiers =
	(
		local uDubMods = this.GetAllUnwrapModifiers()
        
		for m in uDubMods do
		(
			for o in ( refs.dependentNodes m ) do
			(
				while True do
				(
					local clean = True
					for i = 1 to o.modifiers.count do
					(
						if o.modifiers[i] == m then
						(
							maxOps.collapseNodeTo o i True
							clean = False
							exit
						)
					)
					if clean then exit
				)
			)
		)
	),
	
	fn CheckUnwrapModifers =
	(
		local uDubMods = this.GetAllUnwrapModifiers()
        
        local msg = "There are " + ( uDubMods.count as string ) + " unwrap mods with bitmap dependencies"
        format "***** % *****\n" msg
        
        if uDubMods.count != 0 then
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
        if not ( this.CheckUnwrapModifers() ) then
        (
            if ( queryBox "Would you like to collapse unwrap mods with bitmap dependencies?" title:"?" ) then
            (
                this.CollapseToUnwrapModifiers()
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

Constructor = qc_UnwrapModsWithMaps
Instantiated Global = N/A

---------------\n"
    ),

    private fn _init =
    (
        -- Pass
    ),

    __init__ = _init()
)




