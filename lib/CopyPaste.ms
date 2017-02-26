/*
__HELP__

Constructor: CopyPaste
Instantiated Global: CopyPaste

Methods:



__END__
*/




struct CopyPaste
(
    localDir = ( ( GetDir #temp )+ @"\copypaste\" ),
    networkDir,
    
    fn Copy fileName objArr:( GetCurrentSelection() ) location:this.localDir =
	(
        makeDir location
        
        if objArr.count > 0 then
        (
            SaveNodes objArr ( location + fileName )
        )
        else
        (
            messagebox "Nothing selected......" title:"GTVFX: Error"
        )
	),
    
    fn Paste filename location:this.localDir =
    (
        local file = ( location + fileName )
        
        if ( DoesFileExist file ) then
        (
            mergeMaxFile file #select
        )
        else
        (
            messagebox "Could not find a file to paste..." title:"GTVFX: Error"
        )
    ),
    
    fn GetModule =
    (
        ( GetSourceFilename() )
    ),

    fn Help =
    (
        ::_ilmLibrary.GetScriptHelp ( this.GetModule() )
    ),

    private fn _init =
    (
        -- Pass
    ),

    __init__ = _init()
)

CopyPaste = CopyPaste()