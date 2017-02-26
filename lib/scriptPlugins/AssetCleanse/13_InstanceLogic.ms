(
	-- 'Inherit' the main tool
	self = ::_assetCleanse 
	
	
	
	
	if self != undefined then
	(
		local labelText = ""
		
		
		fn GetDicKeys hash =
		(  
			--spit the posible keys out  
			DNArray = dotNetObject "System.string[]" hash.keys.count  
			hash.keys.copyTo DNArray 0  
			out = for i = 0 to hash.keys.count-1 collect (DNArray.get i)  
			out
		)
		
		fn ReplaceWithInstance repNode sourceNode =
		(
			/* 
			Replaces the repNode with an instance of sourceNode
			
			Here we replace the whole node with a new instanced node. We don't just instance the shape over.
			 */
			childNodes = for i in repNode.children collect i
			
			iLayer = LayerManager.GetLayerFromName repNode.layer.name
			objInst = Instance sourceNode name:repNode.name wireColor:repNode.wireColor gbufferChannel:repNode.gbufferchannel transform:repNode.transform
			objInst.parent = repNode.parent
			objInst.material = repNode.material
			iLayer.addNode objInst
			for i in childNodes do i.parent = objInst
			delete repNode
		)
		
		fn GenHash obj prec:1.0 adaptive:True =
		(
			/* 
			Generates a hash code from a string value consisting of the transforms of the vertices in an obj
			
			prec tells the function how precise to be. 1.0 would get the transform of all vertices.
			 */
			
			--format "ClassOf obj: %\n" ( ClassOf obj )
			
			tmesh = obj.mesh
			vertCode = stringStream ""
			numVerts = tmesh.verts.count
			
			if adaptive then
			(
				if numVerts < 200 then
				(
					prec = 1.0
				)
				else if numVerts < 1000 then
				(
					prec = 2.0
				)
				else if numVerts < 5000 then
				(
					prec = 3.0
				)
				else
				(
					prec = 5.0
				)
			)
			
			for i = 1 to numVerts by (prec as float) do format "%" (GetVert tmesh i) to:vertCode
			out = (dotNetObject "System.String" (vertCode as string)).GetHashCode()
			out as string
		)
		
		fn CollectUniqueHash objArr _progressBar:self._progressBar _progressLabel: =
		(
			/* 
			Creates a dictionary with the hash codes generated for all objects. 
			Each key contains an array of anim handles for the individual nodes
			Each node in the array is identical and therefore eligible to be instanced
			 */
			
			--if _progressLabel != undefined then _progressLabel.text = (labelText+": Generating Instancing Dictionary")
			--if _progressBar != undefined then _progressBar.value = 0
			--inc = (100.0/objArr.count)
			--incU = 0.0
			
			if _progressBar != undefined then
			(
				_progressBar.UpdateLabel_Sub ("Generating Instancing Dictionary")
	
				_progressBar.Start_Sub _steps:objArr.count
			)
				
			dic = dotNetObject "System.Collections.Hashtable" 
			
			for obj in objArr do
			(
				hashKey = GenHash obj
				case (dic.ContainsKey hashKey) of
				(
					(true):
					(
						keyValue = dic.item[hashKey]
						dic.remove hashKey
						dic.add hashKey (keyValue + #(GetHandleByAnim obj))
					)
					default:dic.add hashKey #(GetHandleByAnim obj)
				)
				
				--incU += inc
				--if _progressBar != undefined then _progressBar.value = incU
				if _progressBar != undefined then _progressBar.Step_Sub()
			)
			
			dic
		)
		
		fn InstanceLogic _progressBar:self._progressBar _progressLabel: =
		(
			/* 
			Uses the dictionary of hash codes to collect objects that are identical to one another and makes them instances
			 */
			--labelText = self._progressLabel.text
			--local labelText = (_progressBar.GetSubLabelText())
			local baseLabel = ""
				
				
			hashDic = CollectUniqueHash self.testObjects _progressBar:_progressBar
			hashArr = (GetDicKeys hashDic)
			
			--if _progressBar != undefined then_progressBar.value = 0
			
			if _progressBar != undefined then
			(
				baseLabel = ("Generating instances")
				_progressBar.UpdateLabel_Sub baseLabel
			)
			
			for i = 1 to hashArr.count do
			(
				instArr = for id in hashDic.item[hashArr[i]] collect (GetAnimByHandle id)
				
				if _progressBar != undefined then
				(
					_progressBar.Start_Sub _steps:instArr.count
					_progressBar.UpdateLabel_Sub (baseLabel+" | "+instArr[1].name)
				)
				
				--if _progressBar != undefined then _progressLabel.text = (baseLabel+" | "+instArr[1].name)
				
				
				for x = 2 to instArr.count do
				(
					ReplaceWithInstance instArr[x] instArr[1]
					if _progressBar != undefined then
					(
						_progressBar.Step_Sub()
					)
					--if _progressBar != undefined then _progressBar.value = 100*(x as float/instArr.count)
				)
			)
		)
		
		
		
		-- register the plugin
		self.plugManager.Register title:"Instance Logic" method:InstanceLogic aux:unsupplied active:True description:"Checksum each object and assess which are instances"
		
		
	)
	else
	(
		format "***** % could not inherit the main tool *****\n" (GetFileNameFile (GetThisScriptFileName()))
	)
)