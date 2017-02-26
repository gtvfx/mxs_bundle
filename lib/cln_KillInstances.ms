struct cln_KillInstances
(
    aggregate,
    debug = False,
    progBar = undefined,
    objArr,
    
    fn KillInstances objArr:this.objArr =
    ( -- Removes all instancing (Makes all objects unique)
        if objArr == undefined then
        (
            throw "KillInstances needs a valid object array to operate on.\n-- Either define this at the <objArr> class parameter\n-- or use the optional <objArr:> flag on the method."
        )
        
        if objArr.count != 0 then
        (
            InstanceMgr.MakeObjectsUnique objArr #individual 
            True
        )
        else
        (
            False
        )
    ),
    
    fn Run objArr:this.objArr =
    (
        this.KillInstances objArr:objArr
    ),
    
    fn Help =
    (
        format "
---------------
CLASS USAGE:

Constructor = cln_KillInstances
Instantiated Global = N/A

---------------\n"
    ),

    private fn _init =
    (
        -- Pass
    ),

    __init__ = _init()
)

