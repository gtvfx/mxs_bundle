struct sceneAssetLib
(
	numAssets,
	assetDic,
	dicItems,
	
	fn printDnetDic hash =
	( 
		DNArray = dotNetObject "System.string[]" hash.keys.count  
		hash.keys.copyTo DNArray 0  
		for i = 0 to (hash.keys.count-1) do
		(
			itemStr = (DNArray.get i)
			format "% = %\n" itemStr hash.item[itemStr]
		)
	),
	fn collectHashItems hash =
	(
		arr = #()
		DNArray = dotNetObject "System.string[]" hash.keys.count  
		hash.keys.copyTo DNArray 0 
		for i = 0 to (hash.keys.count-1) do
		(
			append arr (DNArray.get i)
		)
		arr
	),
	fn assetNumCheck =
	(
		if numAssets == (AssetManager.GetNumAssets()) then True else False
	),
	fn buildAssetDic = 
	(
		tStart = timeStamp()
		assetDic = dotNetObject "System.Collections.Hashtable"
		assetDic.clear()
		for i = 1 to numAssets do
		(
			x = AssetManager.GetAssetByIndex i
			xDic = dotNetObject "System.Collections.Hashtable"
			xDic.add "type" ((x.GetType()) as string)
			xDic.add "index" (i as string)
			xDic.add "id" (x.getAssetId())
			xDic.add "filename" (x.getFileName())
			xPath = ""
			if (x.CanGetFullFilePath (x.getFileName())) then xPath = (x.GetFullFilePath())
			xDic.add "fullpath" xPath
			xDic.add "numref" (AssetManager.GetNumReference (x.getAssetId()))
			assetDic.add ("asset_" + (i as string)) xDic
		)
		format "***** Scene assets collected in % seconds *****\n" ((timeStamp()-tStart)/1000.0)
		assetDic
	),
	fn getAssetByType assetType = --{#Other|#Bitmap|#XRef|#Photometric|#Animation|#VideoPost|#BatchRender|#ExternalLink|#RenderOutput|#PreRenderScript|#PostRenderScript|#Sound|#Container}
	(
		if not (assetNumCheck()) then init
		arr = #()
		for i in dicItems do
		(
			if (assetDic.item[i].item["type"] as name) == assetType then append arr (AssetManager.GetAssetByIndex (aDic.item[i].item["index"] as integer))
		)
		arr
	),
	fn getAssetFileNameByType assetType =
	(
		if not (assetNumCheck()) then init
		arr = #()
		for i in dicItems do
		(
			if (assetDic.item[i].item["type"] as name) == assetType then append arr assetDic.item[i].item["filename"]
		)
		arr
	),
	fn _init =
	(
		numAssets = AssetManager.GetNumAssets()
		buildAssetDic()
		dicItems = collectHashItems assetDic
	),
	init = _init()
)
_sal = sceneAssetLib()
format "***** Struct Instance: _sal *****\n"


/*

getAssetFileNameByType #bitmap

getMapLoaderByFileName (_sal.assetDic.item["asset_1L"].item["filename"])

mapAssets  = _sal.getAssetByType #bitmap
anmAssets = _sal.getAssetByType #animation
mapAssets.count
anmAssets.count


refArr = refs.dependents mapAssets[2] --returns undefined



aDic.keys.count

#bitmap == "bitmap"

aDic = (buildAssetDic())
printDnetDic aDic

printDnetDic aDic.item["asset_1L"]
	
t = AssetManager.GetAssetByIndex (aDic.item["asset_1L"].item["index"] as integer)
t.getFileName()
	

anmArr = collectAssetsByType #Animation
anmArr[1].getFileName()


fArr = collectAssetsByType #Bitmap
fArr[1].GetNumReference ()
(#bitmap as string) as name

 