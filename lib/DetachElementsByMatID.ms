/*
__MXSDOC__

[TITLE]
DetachElementsByMatID

[DESCRIPTION]

[USAGE]

[CREATION INFO]
Author: Gavyn Thompson
E-mail: gthompson@ilm.com
Company: Industrial Light and Magic
Date created: 08/17/2015
Last Updated: 01/11/2016

[KEYWORDS]

[VERSION HISTORY]

[SEE ALSO]

__END__
*/

/*
__HELP__

Constructor: DetachElementsByMatID
Instantiated Global: 

Parameters:
	objectArray <undefined>:
		Array of objects that this tool will run on
		
	parseMaterial <True>:
		If True then the Multimaterial of each object will be parsed to the correct material list item
		
	debug <False>:
		- If True then several elements will print to the listener
		
Methods:
	Run():
		You can use this method with default values.
			objectArray will become your current selection
			all other props will pass their default values
		
		You can set properties prior to running and then use Run() to begin.



__END__
*/

try( DestroyDialog _detachByMatId.ro )catch()


_ilmLibrary.load "WpfProgressBar" inReload:True

struct DetachElementsByMatID
(
    ro,
	debug = False,
    showUi = False,
	
	fn CollectUniqueFaceIds obj =
	(
		local out = #()
        
		for i = 1 to ( polyop.getnumfaces obj ) do
		(
			appendIfUnique out ( polyop.getFaceMatID obj i )
		)
        
		out
	),

	fn CollectFacesById obj id =
	(
		local out = #{}
        
		for i = 1 to ( polyop.getnumfaces obj ) do
		(
			if polyop.getFaceMatID obj i == id then append out i
		)
        
		out
	),
	
	fn BreakMultMatByObj obj id =
	(
		if ( classOf obj.material == multiMaterial ) then
		(
			if obj.material[id] != undefined then
			(
				obj.material = obj.material[id]
			)
			else
			(
				format "***** id(%) did not match a material of obj: % *****\n" id obj
				obj.material = obj.material.materialList[1]
			)
		)
	),
	
	fn DetachElementById obj parseMaterial:True =
	(
		with Redraw off
		(
			SetCommandPanelTaskMode #create
			
			local objArr = #()
			local idArr = this.CollectUniqueFaceIds obj
			if this.debug then format "***** idArr: % *****\n" idArr
			
			for id in idArr do
			(
				if (polyop.getnumfaces obj) == 0 then
				(
					Delete obj
					exit
				)
				
				local faceArr = this.CollectFacesById obj id
				if this.debug then format "***** faceArr: % | % *****\n" faceArr.count faceArr
				
				local newName = ( uniquename ( obj.name as string ) )
					
				obj.EditablePoly.SetSelection #Face faceArr
					
				local targetFaces = polyop.getFaceSelection obj
				
				polyop.detachFaces obj targetFaces asNode:true name:newName
					
				local newObj = getnodebyname newName
					
				if this.debug then format "***** newObj: % *****\n" newObj
					
				if parseMaterial then
				(
					this.BreakMultMatByObj newObj id
				)
					
				append objArr newObj
				newObj.wireColor = obj.wirecolor
				newObj.parent = obj.parent
				newObj.gbufferchannel = obj.gbufferchannel
				
				centerpivot newObj
				ResetXForm newObj 
				ConvertTo newObj (Editable_Mesh)
			)
			
			if (polyop.getnumfaces obj) == 0 then
			(
				Delete obj
			)
			
			objArr
		)
	),
	
	fn KillInstances objArr =
	(
		/*  Removes all instancing (Makes all objects unique) */
		InstanceMgr.MakeObjectsUnique objArr #individual 
	),
		
	fn ValidateObj obj =
	(
		if (CanConvertTo obj Editable_Poly) then
		(
			if obj.modifiers.count != 0 then
			(
				CollapseStack obj
			)
			
			if (ClassOf obj != Editable_Poly) then
			(
				ConvertTo obj Editable_Poly
			)
			
			True
		)
		else
		(
			format "***** % is not a valid object *****\n" obj.name
			False
		)
	),
    
    fn Batch objArr parseMaterial:True =
    (
        objArr = for obj in objArr where ( this.ValidateObj obj ) collect obj
        
        if objArr.count == 0 then return ( format "Nothing to analyze\n" )
        
        if this.debug then format "***** Passed objArr: % *****\n" objArr
        
        ::_ilmLibrary.BlockUi True
        
        format "|---------- Killing Instances ----------|\n"
        this.KillInstances objArr
        
        local objProgress = WpfProgressBar caption:"Detach Elements by Material ID:" steps:objArr.count
        objProgress.Start()
        
        for obj in objArr do
        (
            objProgress.UpdateLabel obj.name
            
            this.DetachElementById obj parseMaterial:parseMaterial
            GC()
            
            objProgress.Step()
        )
        
        objProgress.End()
        
        while ( ::_ilmLibrary.BlockUi False ).count != 0 do ::_ilmLibrary.BlockUi False
    ),
	
	fn Ui =
    (
        rollout ro "Detach Elements by MatId:" width:400
		(
			local self
            
            group "Objects:"
            (
                checkBox chk_selection ":Selection" checked:True tooltip:"Only analyze the objects in your current selection" across:2
                checkBox chk_scene ":Full Scene" checked:False tooltip:"Aanalyze all objects in your scene"
            )
            
            group "Options:"
            (
                checkBox chk_parse ":Separate Multimat" checked:True tooltip:"Separate the multimaterial into its separate materials"
            )
            
            dotNetControl dNbtn_collect "Button" height:40
			
			fn _init pself =
			(
				self = pself
                
                ::_dotNet.InitDnetBtn dNbtn_collect "Detach Elements" 12 style:#popup colorOffsetInt:10 tooltip:""
			)
            
            on chk_selection changed state do
            (
                chk_scene.state = not state
            )
            
            on chk_scene changed state do
            (
                chk_selection.state = not state
            )
			
			on dNbtn_collect mouseClick args do
			(
                local objArr = case chk_selection.state of
                (
                    ( True ): ( GetCurrentSelection() )
                    default: ( objects as array )
                )
                
                self.Batch objArr parseMaterial:chk_parse.state
			)
		)
        
		createDialog ro
		ro._init this
    ),
    
    fn Run =
	(
		this.Ui()
	),
    
    fn GetModule =
    (
        ( GetThisScriptFileName() )
    ),
    
    fn Help =
    (
        ::_ilmLibrary.GetScriptHelp ( this.GetModule() )
    ),
    
	private fn _init =
	(
		if this.showUi then
        (
            this.Run()
        )
	),
    
	__init__ = _init()
)

_detachByMatId = DetachElementsByMatID()



