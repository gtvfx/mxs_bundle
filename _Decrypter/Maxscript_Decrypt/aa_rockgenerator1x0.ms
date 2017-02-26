-- =================================================================
-- 
-- Description 	: hipoly/lowpoly rock generator
-- Date			   : 2010/06/29
-- Last	Update     : 2010/06/29
-- Author		   : Alessandro Ardolino
--
--this function contains the sequence to create an High Poly rock and a low poly normal mapped one
--inspired by a tutorial by sascha henrichs - http://saschahenrichs.blogspot.com/
--best results with default settings using meters as units
-- =================================================================

--vars
global lpNode = "rockLP001"
global hpNode = "rock001"
global aa_rockGen_dlg
global createHProck
global createLProck
global macroCellularMap

spacing = 0.02
out_fileName = (GetDir #image) + "\\nm.tga"
mSize = 512
padding = 4



fn createHProck =
(
--cubo
	rock = Box lengthsegs:5 widthsegs:5 heightsegs:5 length:2 width:2 height:2 mapcoords:on pos:[0,0,0] isSelected:on
	rock.name = uniqueName "rock"
	rock.wirecolor = color 115 115 115
	
	aa_rockGen_dlg.hpPbar.value = 10
	
--speriphy
	modPanel.addModToSelection (Spherify ()) ui:on
		
	aa_rockGen_dlg.hpPbar.value = 20
		
--turboSmooth
	modPanel.addModToSelection (TurboSmooth ()) ui:on
	rock.modifiers[#TurboSmooth].iterations = 4
	rock.modifiers[#TurboSmooth].useRenderIterations = on
	rock.modifiers[#TurboSmooth].renderIterations = 6
		
	aa_rockGen_dlg.hpPbar.value = 30
		
--map cellular MACRO
	macroCellularMap = cellular()
	macroCellularMap.name = "macroCellularMap"
	macroCellularMap.coords.offset = [(random 1 200),0,(random 1 200)]
	macroCellularMap.size = 1.1
	macroCellularMap.spread = 1.5
	macroCellularMap.divColor1 = color 158 158 158
	macroCellularMap.divColor2 = color 112 112 112
	macroCellularMap.cellColor = color 0 0 0
		
	aa_rockGen_dlg.hpPbar.value = 40
		
--displaceMacro1
	modPanel.addModToSelection (Displace ()) ui:on
	rock.modifiers[#Displace].name = "displaceMacro"
	rock.modifiers[#displaceMacro].maptype = 2
	rock.modifiers[#displaceMacro].strength = 1.3
		
	aa_rockGen_dlg.hpPbar.value = 50
		
--apply the map
	rock.modifiers[#displaceMacro].map = macroCellularMap
		
	aa_rockGen_dlg.hpPbar.value =60
		
--perlin Marble MEDIUM map
	mediumMarbleMap = perlinMarble()
	mediumMarbleMap.name = "mediumMarbleMap"
	mediumMarbleMap.size = 5
	mediumMarbleMap.level = 10
	mediumMarbleMap.color1 = color 190 190 190
	mediumMarbleMap.saturation1 = 80
	mediumMarbleMap.color2 = color 90 90 90
	mediumMarbleMap.saturation1 = 50
		
	aa_rockGen_dlg.hpPbar.value = 70
		
--displaceMedium
	modPanel.addModToSelection (Displace ()) ui:on
	rock.modifiers[#Displace].name = "displaceMedium"
	rock.modifiers[#displaceMedium].maptype = 2
	rock.modifiers[#displaceMedium].strength = 0.06
	rock.modifiers[#displaceMedium].map = mediumMarbleMap
		
	aa_rockGen_dlg.hpPbar.value = 80

--micro noise 1
	modPanel.addModToSelection (Noisemodifier ()) ui:on
	rock.modifiers[#Noise].name = "microNoise1"
	rock.modifiers[#microNoise1].scale = 20
	rock.modifiers[#microNoise1].fractal = on
	rock.modifiers[#microNoise1].roughness = 0.1
	rock.modifiers[#microNoise1].iterations = 10
	rock.modifiers[#microNoise1].strength = [0.5,0.5,0.5]
	rock.modifiers[#microNoise1].seed = 0
	
	aa_rockGen_dlg.hpPbar.value = 90

--micro noise 2
	modPanel.addModToSelection (Noisemodifier ()) ui:on
	rock.modifiers[#Noise].name = "microNoise2"
	rock.modifiers[#microNoise2].scale = 1
	rock.modifiers[#microNoise2].fractal = on
	rock.modifiers[#microNoise2].roughness = 0
	rock.modifiers[#microNoise2].iterations = 10
	rock.modifiers[#microNoise2].strength = [0.1,0.1,0.1]
	rock.modifiers[#microNoise2].seed = 0
	
	aa_rockGen_dlg.hpPbar.value = 100
	
--lattice
	modPanel.addModToSelection (FFD_2x2x2 ()) ui:on
		
	deselect $*
	
	return rock.name
)		
--end fn


--this function creates a low poly version of the selected rock and bake some textures on in
--UV manipulation too...
fn createLProck  nome spacing =
(
--create the low poly mesh from the one just created
	deselect $*
	maxOps.CloneNodes (getnodebyname nome) offset:[0,0,0] newNodes: &rockLP
	
	aa_rockGen_dlg.lpPbar.value = 10
	
	deselect $*
	select rockLP
	$.name = uniqueName "rockLP"
	$.modifiers[#TurboSmooth].iterations = 0
	
	aa_rockGen_dlg.lpPbar.value = 30
	
	macros.run "Modifier Stack" "Convert_to_Poly"
	macros.run "PolyTools" "Smooth"
	
	aa_rockGen_dlg.lpPbar.value = 50
	
--adjust the UV
		--add a UVW modifier
			modPanel.addModToSelection (Unwrap_UVW ()) ui:on
		--relax
			$.modifiers[#Unwrap_UVW].relaxByFaceAngle 100.0 0.0 0.1 false
		--pack islands
			$.modifiers[#Unwrap_UVW].pack 1 spacing true true true	
		--scale UVs
			$.modifiers[#unwrap_uvw].unwrap.edit ()
				actionMan.executeAction 0 "40021"  -- Selection: Select All
			$.modifiers[#unwrap_uvw].unwrap2.setFreeFormMode on
			$.modifiers[#unwrap_uvw].unwrap2.ScaleSelectedXY 0.95 0.95 [0.5,0.5,0]
	
	aa_rockGen_dlg.lpPbar.value = 100
			
	return $.name
)



--bake the normal map
fn bakeNmap lp padding mSize hpNode out_fileName = 
(
	--set scanline as render engine
	renderers.production = RendererClass.classes[1]()
	
	select lp
	if($.modifiers[#Projection] == undefined) then
	(
	--add a projection modifier
	modPanel.addModToSelection (Projection ()) ui:on
	$.modifiers[#Projection].addObjectNode (getnodebyname hpNode)
	$.modifiers[#Projection].autowrapCage()
	--$.modifiers[#Projection].pushValue = 0.5
	)
		
	--Clear all render elements 
	lp.iNodeBakeProperties.removeAllBakeElements()
	
	--create the normal map bake element
	nmBakeElement = normalsmap()
	nmBakeElement.outputSzX = nmBakeElement.outputSzY = mSize
	nmBakeElement.fileType = out_fileName
	nmBakeElement.fileName = filenameFromPath nmBakeElement.fileType 
	nmBakeElement.filterOn = true 
	nmBakeElement.enabled = true --enable baking
	
	--Preparing the object (lp) for baking:
	lp.INodeBakeProperties.addBakeElement nmBakeElement --add first element
	lp.INodeBakeProperties.bakeEnabled = true --enabling baking
	lp.INodeBakeProperties.bakeChannel = 1 --channel to bake
	lp.INodeBakeProperties.nDilations = padding
	
	--projection
	lp.INodeBakeProjProperties.enabled = true
	lp.INodeBakeProjProperties.projectionMod = lp.modifiers[#Projection]
	lp.INodeBakeProjProperties.normalSpace = #tangent
	lp.INodeBakeProjProperties.useCage = true
	
	deselect $*
	select lp
	
	--run the renderer
	render rendertype:#bakeSelected vfb:off progressBar:true outputSize:[mSize,mSize] outputfile: nmBakeElement.fileName

	--create and assign the new material and normal map
	m = standardMaterial()
	$.material = m
	--m.DirectX_Manager.enabled = on
	m.bumpMapAmount = 100
	nm =  Normal_Bump ()
	nmFile = bitmaptexture()
	nmFile.filename = out_fileName
	nm.normal_map = nmFile
	m.bumpMap = nm
	
	meditMaterials[1] = m
	meditMaterials[1].DirectX_Manager.dxStdMat = on
	enableHardwareMaterial m true
	showHWTextureMap  m true
)


--bake the AO map
fn bakeAOmap lp padding mSize hpNode out_fileName maxDistance samples spread = 
(
	--set mental ray as render engine
	renderers.production = RendererClass.classes[4]()
	
	select lp
	if($.modifiers[#Projection] == undefined) then
	(
	--add a projection modifier
	modPanel.addModToSelection (Projection ()) ui:on
	)
	$.modifiers[#Projection].addObjectNode (getnodebyname hpNode)
	$.modifiers[#Projection].autowrapCage()
	--$.modifiers[#Projection].pushValue = 0.5
	
	--Clear all render elements 
	$.iNodeBakeProperties.removeAllBakeElements()
	
	--create the AO map bake element
	AOmBakeElement = Ambient_Occlusion()
	AOmBakeElement.outputSzX = AOmBakeElement.outputSzY = mSize
	AOmBakeElement.fileType = out_fileName
	AOmBakeElement.fileName = filenameFromPath AOmBakeElement.fileType 
	AOmBakeElement.filterOn = true 
	AOmBakeElement.enabled = true --enable baking
	AOmBakeElement.maxDistance = maxDistance 
	AOmBakeElement.samples = samples 
	AOmBakeElement.spread  = spread 
	
	--Preparing the object (lp) for baking:
	$.INodeBakeProperties.addBakeElement AOmBakeElement --add first element
	$.INodeBakeProperties.bakeEnabled = true --enabling baking
	$.INodeBakeProperties.bakeChannel = 1 --channel to bake
	$.INodeBakeProperties.nDilations = padding
	
	--projection
	$.INodeBakeProjProperties.enabled = true
	$.INodeBakeProjProperties.projectionMod = $.modifiers[#Projection]
	$.INodeBakeProjProperties.normalSpace = #tangent
	$.INodeBakeProjProperties.useCage = true
	
	deselect $*
	select lp
	
	--run the renderer
	render rendertype:#bakeSelected vfb:off progressBar:true outputSize:[mSize,mSize] outputfile: AOmBakeElement.fileName
)


fn showHelp =
(
	try(destroyDialog helpRlt)catch()
	--create rollout
	rollout helpRlt "aaRockGen help" width:256 height:260
	(
		GroupBox grp8 "aa_rockGen help" pos:[8,8] width:240 height:240
		label lbl1 "copyright 2010 Alessandro Ardolino" pos:[41,224] width:176 height:16
		label lbl4 "procedural rock generator for production and real time environments." pos:[16,24] width:224 height:32
		
		label lbl6 "1 - create a hi-poly rock" pos:[16,56] width:224 height:16
		label lbl7 "2 - tweak the hi-poly rock parameters " pos:[16,72] width:224 height:16
		label lbl8 "3 - create a low-poly version, the spacing value refers to  UV island spacing" pos:[16,88] width:224 height:32
		label lbl9 "4 - choose which kind of map baking. Please note that only one map can be baked each time" pos:[16,117] width:224 height:40
		label lbl10 "NOTE: be sure to set the path every time the script is launched" pos:[16,160] width:224 height:32
		label lbl18 "if you use this script, and find it useful, just drop an email: me@aardolino.com" pos:[16,192] width:224 height:32
	)
	createDialog helpRlt
)


--create UI
try(destroyDialog aa_rockGen_dlg )catch()

rollout aa_rockGen_dlg "aaRockGen - 1.0"
(	
	--all the groupbox here
	groupbox hpGBox "High Poly Rock" pos:[4,4] width:130 height:80
	groupbox lpGBox "Low Poly Rock" pos:[4,90] width:130 height:100
	groupbox bakeGBox "Bake Settings" pos:[4,195] width:130 height:246
	
	groupbox hpOpzGBox "High Poly Rock settings" pos:[140,4] width:130 height:365
	groupbox helpGBox "Help" pos:[140,370] width:130 height:71
	
	--all the widget here
	--hprock
		button hpRock "create" width:116 height:32 pos:[12,20]
		progressBar hpPbar color:red  width:116 pos:[12,60]
	
	--lprock
		spinner islandSpacing "spacing:" range:[0,10,0.02] scale:0.01 type:#float width:98 pos:[30,108]
		button lpRock "create" width:116 height:32 pos:[12,129]
		progressBar lpPbar color:green width:116 pos:[12,168]

	--bake tex
		checkbox nmap_cbox "normal map" checked:true tooltip:"bake normal map" pos:[12,215]
		checkbox ao_cbox "AO map" checked:false tooltip:"bake ambient occlusion" pos:[12,235]
		
		edittext outputPathTxt text:out_fileName pos:[12,255] width:110
		button outputPath "set output path" width: 116 height:16 pos:[12,280] 
		
		spinner tSize "map size:" range:[0,4096,512] type:#integer width:98 pos:[30,300] 
		button s128 "128" width: 52 height:16 pos:[12,320] 
		button s256 "256" width: 52 height:16 pos:[75,320] 
		button s512 "512" width: 52 height:16 pos:[12,340] 
		button s1024 "1024" width: 52 height:16 pos:[75,340] 
		button s2048 "2048" width: 52 height:16 pos:[12,358]
		button s4096 "4096" width: 52 height:16 pos:[75,358]
		spinner paddingSpinner "padding:" range:[0,32,4] type:#integer width:96 pos:[30,380]
		
		button bakeTextures "bake textures" width:116 height:32 pos:[12,402]
		
	--hp rock settings
		--presets
			button stdButton "basic rock" width:116 height:32 pos:[148,20]
			button boulderButton "boulder" width:116 height:32 pos:[148,56]
			button erodedButton "eroded rock" width:116 height:32 pos:[148,92]
			button roseButton "sand rose" width:116 height:32 pos:[148,128]
	
		--parametri
			spinner viewportIt "viewport detail:" range:[1,10,4] type:#integer width:50 pos:[210,168] 
			spinner renderIt "render detail:" range:[1,10,6] type:#integer width:50 pos:[210,190]
			spinner roughnessS "roughness:" range:[1.0,40.0,20.0] scale:0.1 type:#float width:70 pos:[190,212] 
			
			radiobuttons cellType labels:#("circular", "chips") pos:[148, 234]
			checkbox fractal_cbox "fractal" checked:false pos:[148,255]
			spinner fIterations "Iter:" range:[0,10,3] type:#integer width:40 pos:[220,255] 
			colorpicker cellColor "cell color:" color:[0,0,0] pos:[160,278]
			--low mid high
			spinner lowS "L:" range:[0.0,1.0,0.0] scale:0.01 type:#float width:60 pos:[178,304]
			spinner midS "M:" range:[0.0,1.0,0.5] scale:0.01 type:#float width:60 pos:[178,324]
			spinner highS "H:" range:[0.0,1.0,1.0] scale:0.01 type:#float width:60 pos:[178,344] 

		--help
			label help "aa_rockGen 1.0" align:#left width:116 height:22 pos:[148,384]
			button helpB "help" width:116 height:32 pos:[148,402]
	
	on stdButton pressed do
	(
		cellType.state = 1
		macroCellularMap.type = 0
		cellColor.color = color 0 0 0
		macroCellularMap.cellColor = color 0 0 0
		fractal_cbox.checked = false
		macroCellularMap.fractal = off
		lowS.value = 0.0
		midS.value = 0.5
		highS.value = 1.0
		macroCellularMap.lowThresh = 0.0
		macroCellularMap.midThresh = 0.5
		macroCellularMap.highThresh = 1.0
	)
	
	on boulderButton pressed do
	(
		cellType.state = 2
		macroCellularMap.type = 1
		cellColor.color = color 190 190 190
		macroCellularMap.cellColor = color 190 190 190
		fractal_cbox.checked = true
		macroCellularMap.fractal = on
		fIterations.value = 1
		macroCellularMap.iteration = 1
		lowS.value = 0.0
		midS.value = 0.5
		highS.value = 1.0
		macroCellularMap.lowThresh = 0.0
		macroCellularMap.midThresh = 0.5
		macroCellularMap.highThresh = 1.0
	)
	
	on erodedButton pressed do
	(
		cellType.state = 1
		macroCellularMap.type = 0
		cellColor.color = color 0 0 0
		macroCellularMap.cellColor = color 0 0 0
		fractal_cbox.checked = true
		macroCellularMap.fractal = on
		fIterations.value = 3
		macroCellularMap.iteration = 3
		lowS.value = 0.0
		midS.value = 0.5
		highS.value = 1.0
		macroCellularMap.lowThresh = 0.0
		macroCellularMap.midThresh = 0.5
		macroCellularMap.highThresh = 1.0
	)
	
	on roseButton pressed do
	(
		cellType.state = 2
		macroCellularMap.type = 1
		cellColor.color = color 0 0 0
		macroCellularMap.cellColor = color 0 0 0
		fractal_cbox.checked = false
		macroCellularMap.fractal = off
		lowS.value = 0.0
		midS.value = highS.value = 1.0
		macroCellularMap.lowThresh = 0.0
		macroCellularMap.midThresh = macroCellularMap.highThresh = 1.0
	)
	
	on viewportIt changed val do
	(
		deselect $*
		select (getNodeByName hpNode)
		$.modifiers[#TurboSmooth].iterations = val
	)
	
	on renderIt changed val do
	(
		deselect $*
		select (getNodeByName hpNode)
		$.modifiers[#TurboSmooth].renderIterations = val
	)
	
	on roughnessS changed val do
	(
		deselect $*
		select (getNodeByName hpNode)
		$.modifiers[#microNoise1].scale = val
	)
	
	on cellType changed val do 
	(
		if(val == 1) then
			macroCellularMap.type = 0
		else
			macroCellularMap.type = 1
	)
	
	on fIterations changed val do
	(macroCellularMap.iteration = val)
	
	on fractal_cbox changed val do
	(
		if(val == true) then
			macroCellularMap.fractal = on
		else
			macroCellularMap.fractal = off
	)
	
	on cellColor changed val do
	(macroCellularMap.cellColor = val)
	
	on lowS changed val do
	(macroCellularMap.lowThresh = val)
	
	on midS changed val do
	(macroCellularMap.midThresh = val)
	
	on highS changed val do
	(macroCellularMap.highThresh = val)
	
	on hpRock pressed do
	(hpNode = createHProck())
	
	on lpRock pressed do
	(
		lpNode = createLProck hpNode spacing
		deselect $*
	)
	
	on bakeTextures pressed do
	(
		if (nmap_cbox.checked == true) then
		(
			bakeNmap (getnodebyname lpNode) padding mSize hpNode out_fileName
		)
		if(ao_cbox.checked == true)then
		(
			bakeAOmap (getnodebyname lpNode) padding mSize hpNode out_fileName 0.0 32 0.99
		)
	)
	
	on outputPath pressed do
	(
		out_fileName = GetSaveFileName types:"*.tga|*.tga|All Files (*.*)|*.*|"
		outputPathTxt.text = out_fileName
	)
	
	on islandSpacing changed val do
	(spacing = val)
	
	on paddingSpinner changed val do
	(padding = val)
	
	on s128 pressed do
	(mSize = 128;  tSize.value = 128)
	on s256 pressed do
	(mSize = 256;  tSize.value = 256)
	on s512 pressed do
	(mSize = 512;  tSize.value = 512)
	on s1024 pressed do
	(mSize = 1024;  tSize.value = 1024)
	on s2048 pressed do
	(mSize = 2048;  tSize.value = 2048)
	on s4096 pressed do
	(mSize = 4096;  tSize.value = 4096)
	
	on helpB pressed do
	(showHelp())
)

createDialog aa_rockGen_dlg 274 446
