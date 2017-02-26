struct cln_FlattenHierarchy
(
    aggregate,
    debug = False,
    progBar = undefined,
    objArr,
    
    fn FlattenHierarchy _progressBar:this.progBar _objArr:this.objArr =
    (
        if _objArr == undefined then
        (
            throw "FlattenHierarchy needs an array of objects.\nEither define the 'objArr' Struct parameter\nor use the '_objArr' flag on the method"
        )
        
        if _progressBar != undefined then
        (
            _progressBar.UpdateLabel_Sub ""
            
            _progressBar.Start_Sub _steps:self.allObjects.count
        )
        
        for obj in _objArr do
        (
            if _progressBar != undefined then _progressBar.UpdateLabel_Sub obj.name
            
            obj.parent = undefined
            
            if _progressBar != undefined then _progressBar.Step_Sub()
        )
    ),
    
    fn Help =
    (
        format "
---------------
CLASS USAGE:

Constructor = cln_FlattenHierarchy
Instantiated Global = N/A

---------------\n"
    ),

    private fn _init =
    (
        if this.aggregate != undefined and ( isProperty this.aggregate #_progressBar ) then 
        (
            this.progBar = this.aggregate._progressBar
        )
    ),

    __init__ = _init()
)





