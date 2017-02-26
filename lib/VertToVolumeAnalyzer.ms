/*
__MXSDOC__

[TITLE]
VertToVolumeAnalyzer

[DESCRIPTION]
Class for analyzing objects using a ratio derived from volume to vertex count.
- methods for collecting objects within a certion ratio
- purposed for finding objects that are small but dense

[USAGE]
Methods can be called individually or you can use the Run method to launch a UI

[CREATION INFO]
Author: Gavyn Thompson
E-mail: gthompson@ilm.com
Company: Industrial Light and Magic
Date created: 01/06/2016
Last Updated: 01/06/2016

[KEYWORDS]

[VERSION HISTORY]

[SEE ALSO]

__END__
*/

/*
__HELP__

Constructor: VertToVolumeAnalyzer
Instantiated Global: _vtv

Methods:

    CalculateVolumeVertexCount <obj>
        - Calculates the volume of the nodeLocalBoundingBox
        - returns a tuple containing the volume and the vertex count of the object
    
    GetVertToVolumeRatio <obj> multiplier:<10>
        - returns the quotient of ( vertexCount/( volume * multiplier) )

    AnalyzeObjects <objArr>
        - Gets the ratio for each object in objArr
        - Stores an array of tuples to the cacheArr parameter of the class
        - tuples contains the object and ratio
    
    GetObjsByRatio <ratio>
        - Queries the array of tuples in the cacheArr parameter
        - returns the objects with ratios that are greater than or equal to the supplied ratio
    
    Ui
        - Constructs and launches the UI
    
    Run
        - Executes the UI method
    
__END__
*/

try(destroyDialog _vtv.ro)catch()

_ilmLibrary.load "WpfProgressBar"
_ilmLibrary.load "DotNetUi"

struct VertToVolumeAnalyzer
(
	ro,
    showUi = False,
	cacheArr = #(),
    
    fn CalculateVolumeVertexCount obj =
    (
        with undo off 
        (
            if ( isProperty obj #mesh ) and ( isProperty obj.mesh #numverts ) then
            (
                local vertCount = obj.mesh.numVerts
                
                local bBox = nodeLocalBoundingBox obj
                
                local dif = ( bBox[2] - bBox[1] )
                
                local volume = abs( dif.x*dif.y*dif.z )
                
                #( volume, vertCount )
            )
            else
            (
                --format "***** % Does not have a Mesh property *****\n" obj
                undefined
            )
        )
    ),
    
	fn GetVertToVolumeRatio obj multiplier:10 =
	(
		local data = this.CalculateVolumeVertexCount obj
        
        local ratio = 0
        
		if data != undefined then
		(
			local volume = data[1]
			local vertexCount = data[2]
            
			ratio = vertexCount/( volume * multiplier)
		)
        
        ratio
	),
	
	fn AnalyzeObjects objArr =
	(
        ::_ilmLibrary.BlockUi True
        
		this.cacheArr = #()
        
        local _progBar = ::WpfProgressBar caption:"Calculating Vertex to Volume Ratio:" steps:objArr.count
        _progBar.UpdateLabel "Analyzing vertices:"
        _progBar.Start() 
        
		--local arr = #()	
        
		for obj in objArr while not Keyboard.EscPressed do
		(
            _progBar.UpdateLabel ( "Calculating Ratio For: " + obj.name )
            
			local ratio = ( this.GetVertToVolumeRatio obj )
            
			append this.cacheArr #( obj, ratio )
            
            _progBar.Step()
		)
        
        _progBar.End()
        
        ::_ilmLibrary.BlockUi False
	),
	
	fn GetObjsByRatio ratio =
	(
        local out = #()
        
		if this.cacheArr.count != 0 then
		(
			out = for i in this.cacheArr where not ( isDeleted i[1] ) and i[2] >= ratio collect i[1]
		)
		else
		(
			format "***** No Cached Objects *****\n"
		)
        
		out
	),
	
	fn UI =
	(
		rollout ro "Vertex To Volume Ratio" width:400
		(
			local self
            local sliderMax = 2000
            
            slider sld_index "Tolerence:" range:[0,sliderMax,500] type:#float ticks:10 orient:#horizontal offset:[5,0]
            
            label lbl_count "Dense Objects: ?" align:#left across:2
            spinner spn_scale "Slider Scale:" range:[0,999,1] type:#float fieldWidth:40 tooltip:"Use this to adjust the precision of the slider"
            
            group "Objects:"
            (
                checkBox chk_selection ":Selection" checked:False tooltip:"Only analyze the objects in your current selection" across:2
                checkBox chk_scene ":Full Scene" checked:True tooltip:"Aanalyze all objects in your scene"
            )
            
            dotNetControl dNbtn_collect "Button" height:40
			
			fn _init pself =
			(
				self = pself
                
                self.cacheArr = #()
                
                ::_dotNet.InitDnetBtn dNbtn_collect "Analyze Objects" 12 style:#popup colorOffsetInt:10 tooltip:""
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
                
                if objArr.count == 0 then return ( format "Nothing to analyze\n" )
                
				self.AnalyzeObjects objArr
                
                select ( self.GetObjsByRatio sld_index.value )
                lbl_count.text = ( "Dense Objects: " + ( selection.count as string ) )
			)
            
            on sld_index changed val do
			(
				select (self.GetObjsByRatio val)
                lbl_count.text = ( "Dense Objects: " + ( selection.count as string ) )
			)
            
            on spn_scale changed val do
			(
				sld_index.range = [0, ( sliderMax * spn_scale.value ) , sld_index.value]
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

_vtv = VertToVolumeAnalyzer()


/*
for i in geometry where (GetVertToVolumeRatio i) > 10 do delete i


*/
