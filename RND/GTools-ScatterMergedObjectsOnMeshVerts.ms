/***************************************************************************************************
__MXSDOC__
[TITLE]
ScatterMergedObjectsOnMeshVerts

[DESCRIPTION]
- Collects objects from a given directory of Max files and randomly scatters them accross the verts of a selected mesh.
- Works well for scattering VRay Proxies.
- ** Currently applies a random rotation to all scatter objects **

[USAGE]
- Set up a directory with Max files containing the objects you want scattered accross your mesh.
- Use the tool to select this directory
- Use the "Vetex Offset" spinner to adjust the density of the scattered objects.
- Use the tool to pick the base mesh
- Finally press the button to scatter the objects

[CREATION INFO]
by: Gavyn Thompson
gthompson@gtvfx.com
gavyn.thompson@pixomondo.com
Skype: gftvfx

[KEYWORDS]
scatter

[VERSION HISTORY]
11/15/2011 - creation


__END__
***************************************************************************************************/

try(destroyDialog scatterProxies_RO)catch()
clearListener()

rollout scatterProxies_RO "Scatter Proxies" width:500 height:200
(
	label lbl_proxyPath "Path to proxies:" pos:[18,10]
	editText edt_proxyPath "" fieldWidth:425
	button btn_fileBrowse "..." width:30 height:20 pos:[450,27] tooltip:"Paste path in text field or use this button to choose path"
	spinner spn_vertOffset "Vertex Offset:" fieldWidth:40 pos:[15,60] type:#integer range:[1,100,2]
	button btn_baseMesh "Select Base Mesh" width:100 height:30 pos:[15,90] toolTip:"Pick object to scatter proxies on."
	label lbl_baseMesh "...No Base Mesh Selected..." pos:[150,100] align:#left
	button btn_scatterProxies "Scatter Proxies" width:180 height:60 pos:[155,130] enabled:false toolTip:"Select Base Mesh First"
	
	local proxyPath 		= "C:\\_cache\\temp\\_proxy"--undefined
	local proxyFiles 		= undefined
	local scatterBase 	= undefined
	local proxiesArr 		= #()
	local vertOffset 		= 2
	
	fn collectProxies_FN =
		(
			if proxyPath != undefined then
				(
					proxyFiles = getFiles (proxyPath + "\\*.max")
					for i in proxyFiles do
						(
							fileProxies = getMAXFileObjectNames i quiet: true
							for each in fileProxies do
								(
									appendIfUnique proxiesArr each
								)
							mergeMaxFile i
						)
				)
		)

	fn scatterProxies_FN =
		(
			if proxyFiles != undefined then
				(
					vertCount = getNumVerts scatterBase.mesh
					
					for i = 1 to vertCount by vertOffset do
						(
							newPos = getVert scatterBase.mesh i
							newPos = newPos * scatterBase.transform
							proxyRandom = (getNodeByName proxiesArr[(random 1 proxiesArr.count)])
							proxyMesh = instance proxyRandom
							proxyMesh.wireColor = proxyRandom.wireColor
							--proxyMesh.rotation = (quat 0 0 (random (-1 as float) (1 as float)) 1)
							proxyMesh.pos = newPos
							
						)
						
					for i in proxiesArr do
						(
							delete (getNodeByName i)
						)
				)
		)
		
	on edt_proxyPath entered	newText do
		(
			proxyPath = newTxt
		)
		
	on btn_fileBrowse pressed do
		(
			proxypath = getSavePath caption:"** Get Maxscript File ** " initialDir:maxFilePath
			
			if proxypath != undefined then
				(
					edt_proxyPath.text = proxypath
				)
		)
		
	on spn_vertOffset changed newVal do
		(
			vertOffset = newVal
		)
		
	on btn_baseMesh pressed do
		(
			print "Pick Base Mesh"
			scatterBase = pickObject()
			lbl_baseMesh.text = scatterBase.name
			btn_scatterProxies.enabled = true
		)		
	
	on btn_scatterProxies pressed do
		(
			collectProxies_FN()
			scatterProxies_FN()
		)		
)

createDialog scatterProxies_RO


--X:\snowwhite_snw-2114\_library\assets\characters\chr_black-knight\mdl\_proxy\GM_BlackKnight_sword_pr0015_proxy_002.vrmesh