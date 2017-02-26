


struct LayerIsolate
(
    ro,
    storedLayerStateArr,
    
    fn SaveLayerStates =
	(
        local out = #()
        
        for i = 0 to layerManager.count-1 do
        (
            local iLayer = layerManager.getLayer i
            append out #(iLayer.name, iLayer.on)
        )
        
        out
	),
    
	fn RestoreLayerStates layerStateArr =
	(
		if layerStateArr != undefined and layerStateArr.count != 0 then
		(
			for i in layerStateArr do
			(
				( layerManager.getLayerFromName i[1] ).on = i[2]
			)
		)
		else 
        (
            format "***** Error with layerStateArr: % *****\n" layerStateArr
        )
	),
    
    fn IsolateLayersByObj objArr =
	(
        objArr = ::_mxs.EnsureArgIsArray objArr
        
		if objArr.count != 0 then
		(
			local layerArr = #()
            
			for i in objArr do
			(
				appendIfUnique layerArr i.layer
			)
            
			for i = 0 to layerManager.count-1 do
			(
				local iLayer = layerManager.getLayer i
				if ( findItem layerArr iLayer == 0 ) then iLayer.on = false
			)
            
			True
		)
		else
		(
			messageBox "Nothing selected... :(" title:"GTVFX:"
			False
		)
	),

    fn Ui =
	(
		rollout ro "Layer Isolate By GTVFX" width:180
		(
			local self
			checkButton cBtn_isolate "Layers Isolated" checked:true width:(ro.width-20) height:40 
			
			fn _init pself =
			(
				self = pself
			)
            
			fn ExitIso =
			(
				self.RestoreLayerStates self.storedLayerStateArr
				destroyDialog ro
			)
            
			on cBtn_isolate changed arg do
			(
				exitIso()
			)
            
			on ro_layIso moved pos do
			(
				try( SetIniSetting ::_mxs.UiSettingsIni "layIso_UI" "Position" ( pos as string ) )catch()
			)
            
			on ro_layIso close do
			(
				ExitIso()
			)
		)
        
		local roPos = [850,420]
        
        if ::mxs != undefined then
        (
            if ( DoesFileExist ::_mxs.UiSettingsIni ) and ( HasIniSetting ::_mxs.UiSettingsIni "layIso_UI" "Position" ) then
            (
                roPos = ( execute ( GetIniSetting ::_mxs.UiSettingsIni "layIso_UI" "Position" ) ) 
            )
            else 
            (
                roPos = [850,420]
            )
        )
		
		createDialog ro pos:roPos
		ro._init this
	),
    
    fn Run =
    (
        this.storedLayerStateArr = this.SaveLayerStates()
		
		if not ( this.IsolateLayersByObj ( GetCurrentSelection() ) ) then return false
        
        this.Ui()
    ),
    
    fn GetModule =
    (
        ( GetSourceFileName() )
    ),

    fn Help =
    (
        ::_mxs.GetScriptHelp ( this.GetModule() )
    ),

    private fn _init =
    (
        -- Pass
    ),

    __init__ = _init()
)

_layIso = LayerIsolate()