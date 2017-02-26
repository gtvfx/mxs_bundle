struct cln_CleanScaleValues
(
    aggregate,
    debug = False,
    progBar = undefined,
    objArr,
    
    mapped fn SetTransformController_mapped objArr _controller:PRS =
    (
        objArr.transform.controller = _controller()
    ),
    
    mapped fn SetScaleController_mapped objArr _controller:ScaleXYZ =
    (
        /* 
                Converts the scale controller on all objects to ScaleXYZ.
                This is a more accurate mathematical representation of values and far less prone to precision errors
                */
        if ( classOf objArr.transform.controller ) != PRS then this.SetTransformController_mapped ( objArr as array )
        
        objArr.scale.controller = _controller()
        objArr.scale.controller.value = [1,1,1]
    ),
    
    fn FixHelperScaleValues objArr:#() =
    (
        /* 
                Collects all helpers from the objArr and runs a function to set their scale back to [1,1,1] without scaling thier children
                */
        if ( objArr != undefined ) and ( objArr.count != 0 ) then
        (
            local arr = for i in objArr where ( SuperClassOf i ) == Helper collect i
            this.SetScaleController_mapped arr
        )
    ),
    
    fn FixNonUniformScale _progressBar:this.progBar objArr:this.objArr =
    (
        /* 
                Resets the transform of objects with scale values not equal to [1,1,1]
                */
        
        if objArr != undefined and objArr.count != 0 then
        (
            if _progressBar != undefined then
            (
                _progressBar.UpdateLabel_Sub ""
                
                _progressBar.Start_Sub _steps:objArr.count
            )
            
            for obj in objArr do
            (
                if _progressBar != undefined then _progressBar.UpdateLabel_Sub obj.name
                
               -- if ( classOf obj.transform.controller != PRS ) then this.SetTransformController_mapped #(obj) _controller:PRS
                
                local objScale = obj.scale.controller.value
                local st = objScale as string
                
                if st != "[1,1,1]" then
                (
                    this.SetScaleController_mapped #( obj ) _controller:ScaleXYZ
                    
                    
                    local xmod = xform()
                    
                    case obj.modifiers.count of
                    (
                        (0):addmodifier obj xmod
                        default:addmodifier obj xmod before:obj.modifiers.count
                    )
                    
                    local mtrx_base = matrix3 1
                    local mtrx_xform = matrix3 ( mtrx_base[1]*objScale[1] ) ( mtrx_base[2]*objScale[2] ) ( mtrx_base[3]*objScale[3] ) [0,0,0]
                    
                    xmod.gizmo.transform = mtrx_xform
                    
                    obj.scale.controller.value = [1,1,1]
                    
                    --collapse mod...
                    maxOps.collapseNodeTo obj ( Finditem obj.modifiers xmod ) True
                )
                
                if _progressBar != undefined then _progressBar.Step_Sub()
            )
        )
        else
        (
            throw "FixNonUniformScale needs a valid object array to operate on.\n-- Either define this at the <objArr> class parameter\n-- or use the optional <objArr:> flag on the method." 
        )
    ),
    
    fn RunAsModule =
    (
        if this.aggregate != undefined then
        (
            local helperObjs = if ( IsProperty this.aggregate #excludedObjs ) then this.aggregate.excludedObjs else #()
            
            this.FixHelperScaleValues objArr:helperObjs
            
            
            this.FixNonUniformScale _progressBar:this.progBar objArr:this.objArr
        )
        else
        (
            throw "RunAsModule requires the <aggregate> class parameter to be defined with the aggregated class running the module."
        )
    ),
    
    fn Run objArr:this.objArr =
    (
        this.FixNonUniformScale objArr:objArr
    ),
    
    
    fn Help =
    (
        format "
---------------
CLASS USAGE:

Constructor = 
Instantiated Global = 

---------------\n"
    ),

    private fn _init =
    (
        if ( this.aggregate != undefined ) and ( IsProperty this.aggregate #RefactorObjs ) then this.aggregate.RefactorObjs()
    ),

    __init__ = _init()
)




