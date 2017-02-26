_mxs.Using "GenFns"

struct CreateTopNull_struct
(
	fn FileterObjArrForTopLevelNodes objArr =
	(
		out = #()
		
		for i in objArr do
		(
			if i.parent == undefined then
			(
				append out i
			)
			else
			(
				if (findItem objArr i.parent == 0) then
				(
					append out i
				)
			)
		)
		out
	),
	
	fn CreateTopNull objArr =
	(
		local objArr = this.FileterObjArrForTopLevelNodes objArr
		
		
		if objArr.count == 0 then
		(
			self.msg = "The objects for the top null are not defined\nYou need to make a selection"
			return undefined
		)
		
		_mxs.blockui True
		
		
		local cenPointZmin = _GenFns.GetLocalizedBasePoint objArr
		
		
		pCtrl = Point name:(uniqueName "_TopNull") pos:cenPointZmin wirecolor:(color 0 255 255)
		
		
		_GenFns.SetParent_mapped objArr pCtrl _replace:True
		
		
		while (_mxs.blockui False).count != 0 do _mxs.blockui False
		
		
		pCtrl
	),
	
	
	fn ClassUsage =
	(
		format "
---------------
CLASS USAGE:

Constructor = CreateTopNull_struct
Instantiated Global = _createTopNull
		
Methods:
	CreateTopNull <objArr> :
		-Takes an array of objects as an argument
		-The objArr is filtered to return top level nodes within the objArr
		-A point helper is created at the Center/Min point of the objArr bounding box
		-The filtered nodes are set as the children of the new point helper
		-The point helper name is set to \"_topNull\" and should be manually changed

---------------\n"
	),
	
	
	private fn _init =
	(
		this.ClassUsage()
	),

	__init__ = _init()
)
	
_createTopNull = CreateTopNull_struct()
