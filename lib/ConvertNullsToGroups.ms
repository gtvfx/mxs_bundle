/* 
class for converting a collection of objects parented to nulls to grouped objects.

*/

_mxs.Using "GenFns" inReload:False
_mxs.Using "CopyPasteAnimation" inReload:False

::ConvertNullsToGroups
::_ConvertNullsToGroups

struct ConvertNullsToGroups
(
	fn CollectNullsForGroup objArr =
	(
		/* Filters the provided array of objects for helper objects that are valid */
		out = for obj in objArr where (superClassOf obj == Helper) and not (isGroupHead obj) and obj.children.count != 0 collect obj
		out
	),
	
	fn CloseAllGroups =
	(
		for i in objects where (isGroupHead i) do SetGroupOpen i False
	),
	
	fn ConvertToGroups objArr =
	(
		if classOf objArr != array then objArr = #(objArr)
		
		local nullArr = (this.CollectNullsForGroup objArr)
		
		local groupArr = #()
		
		format "***** nullArr: % *****\n" nullArr
		
		if nullArr.count != 0 then
		(
			for null in nullArr do
			(
				if (AssetNull != undefined) and (ClassOf null == AssetNull) then
				(
					-- Add logic for handling AssetNulls here
					format "***** Found AssetNull *****\n"
				)
				
				
				-- Recurssively get all children of the null and group all of the collected objects
				local childArr = (_GenFns.GetChildrenRecursive null)
				--local childArr = null.children
				format "***** childArr: % *****\n" childArr
				
				newGroup = group (childArr + null)
				-- BUG: sometimes this returns OK rather than returning the new Dummy for the group head, which crashes the rest of the script
				-- This bug occurs when all of the objects in the array supplied to the group() method do not share a common parent. Sub-hierarchies are
				-- supported, but if a parent of any of the objects is not in the array then it doesn't know what to do
				
				if newGroup == OK then
				(
					Deselect $*
					format "***** arr count: % *****\n" childArr.count
					select childArr
					--throw "Error"
					exit
				)
				
				-- open the group to make sure that we have access to all contained objects while we continue to loop through the nulls
				SetGroupOpen newGroup True
				
				newGroup.name = null.name
				newGroup.pivot = null.pivot
				newGroup.parent = null.parent
				
				-- Transfer any animation from the null to the new group
				if null.isAnimated then
				(
					if _CopyPasteAnimation != undefined then
					(
						_CopyPasteAnimation.CopyPasteAnim null newGroup
					)
					else
					(
						format "***** _CopyPasteAnimation is not defined. Unable to transfer animation to group: % *****\n" newGroup.name
					)
				)
				
				append groupArr newGroup
			)
			
			-- remove the nulls now that we've created the groups
			format "***** deleting nullArr: % *****\n" nullArr
			delete nullArr
			
			this.CloseAllGroups()
		)
		
		RedrawViews()
		groupArr
	),
	
	fn ClassUsage =
	(
		format "
---------------
CLASS USAGE: 
		
Constructor: ConvertNullsToGroups
		
Instantiated Global: _ConvertNullsToGroups
		
Method:
	ConvertToGroups <objArr>
---------------\n"
	),
	
	private fn _init =
	(
		
	),

	__init__ = _init()
)


_ConvertNullsToGroups = ConvertNullsToGroups()




/*
_ConvertNullsToGroups.ConvertToGroups (GetCurrentSelection())




nulls = _ConvertNullsToGroups.CollectNullsForGroup (GetCurrentSelection())
select nulls

newGroups = _ConvertNullsToGroups.ConvertToGroups nulls
	
newGroups = _ConvertNullsToGroups.ConvertToGroups (objects as array)

*/