struct cln_RemoveAnimationLayers
(
    aggregate,
    debug = False,
    progBar = undefined,
    objArr,
    classList = 
    #(
        Float_Layer, 
        Point3_Layer, 
        Point4_Layer,
        Position_Layer,
        Rotation_Layer,
        Scale_Layer
    ),
    
    fn RemoveAnimLayers _progressBar:this.progBar =
    ( -- remove all layer controller types from the scene if possible...
        local origAnimLayerCount = AnimLayerManager.GetLayerCount()
        if origAnimLayerCount == 0 then return True
        
        /* 
        for c in this.classList do 
        (
            local inst = ( GetClassInstances c asTrackViewPick:True )
            
            if inst.count == 0 then continue
                
            for b in inst do
            (
                for s = 1 to b.client.numsubs do
                (
                    if b.client[s] == b.anim then
                    (
                        b.client[s].value = undefined
                        exit
                    )
                )
            )
        )
        */
        
        local animLayerCount = origAnimLayerCount
        
        if _progressBar != undefined then
        (
            _progressBar.UpdateLabel_Sub ""
            
            _progressBar.Start_Sub _steps:animLayerCount
        )
        
        while true do
        (
            for t = 1 to animLayerCount do
            (
                try( AnimLayerManager.DeleteLayer t )catch()
            )
            
            local newLayerCount = AnimLayerManager.GetLayerCount()
            
            if _progressBar != undefined then _progressBar.Step_Sub()
            
            if newLayerCount == 1 then exit
                
            animLayerCount = newLayerCount
        )
        
        format "***** Removed % animation layers *****\n" ( origAnimLayerCount - animLayerCount )
    ),
    
    
    fn Run =
    (
        this.RemoveAnimLayers _progressBar:this.progBar
    ),
    
    
    fn Help =
    (
        format "
---------------
CLASS USAGE:

Constructor = cln_RemoveAnimationLayers
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


