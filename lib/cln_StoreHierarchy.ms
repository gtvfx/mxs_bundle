::_ilmLibrary.load "UserProps"

struct cln_StoreHierarchy
(
    aggregate,
    debug = False,
    progBar = undefined,
    objArr,
    namespace = "",
    
    fn StoreHierarchy _progressBar:this.progBar _objArr:this.objArr _nameSpace:this.namespace =
    ( -- Stores each objects parent in the User Prop buffer
        if _objArr == undefined then
        (
            throw "StoreHierarchy needs an array of objects.\nEither define the 'objArr' Struct parameter\nor use the '_objArr' flag on the method"
        )
        
        if _progressBar != undefined then
        (
            _progressBar.UpdateLabel_Sub ""
            
            _progressBar.Start_Sub _steps:objArr.count
        )
        
        for obj in _objArr do
        (
            if _progressBar != undefined then _progressBar.UpdateLabel_Sub obj.name
            
            if this.debug then format "***** Storing Hierarchy: % | % *****\n" obj obj.parent
            
            ::_userProps.SetProp obj "Parent" (obj.parent as string) nameSpace:this.nameSpace overwrite:True
            
            if _progressBar != undefined then _progressBar.Step_Sub()
        )
    ),
    
    fn Help =
    (
        format "
---------------
CLASS USAGE:

Constructor = cln_StoreHierarchy
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



