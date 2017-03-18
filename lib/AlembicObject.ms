/***************************************************************************************************
Copyright (C) 2013 - 2017  Gavyn Thompson

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. if not, see <http://www.gnu.org/licenses/>.
***************************************************************************************************/
/***************************************************************************************************
Author:				    Gavyn Thompson
Company:				GTVFX
Website:				https://github.com/gtvfx
Email:				    gftvfx@gmail.com
ScriptVersion:			
Updated:				
[Purpose]

***************************************************************************************************/
/*
__HELP__

Constructor: 
Instantiated Global: 

Methods:



__END__
*/

mxs.Using "MxsPyFns"

python.execute "
from mxs.lib import alembic_api
reload(alembic_api)
"

PYTHON_RETURN = undefined

struct AlembicObject
(
public
	-- required
	abcFile,
	
	--
	objectNames = #(),
	
	
	fn InitializePythonModule =
	(
		local pyCmd = StringStream ""
		
		format "
abcObject = alembic_api.AlembicObject(r'%')
		" this.abcFile to:pyCmd
		
		python.execute ( pyCmd as string )
	),
	
	fn GetAllObjectNames =
	(
		this.objectNames = ::MxsPyFns.ListToArray "abcObject.objectNames"
	),
	
	fn CollectChildrenNameList objName skipNameArr:#() =
	(
		local out = #()
		
		::MxsPyFns.ArrayToList skipNameArr "_skipNameList"
		
		local pyCmd = StringStream ""
		
		format "
__obj__ = abcObject.GetObjectByName('%')
__objNames__ = []
if type(__obj__) == list:
	for each in __obj__:
		__objList__ = abcObject.GetChildrenRecursive(each, childList=[], skipNameList=_skipNameList)
		__objNames__ += abcObject.GetObjectNames(__objList__)
else:
	__objList__ = abcObject.GetChildrenRecursive(__obj__, childList=[], skipNameList=_skipNameList)
	__objNames__ = abcObject.GetObjectNames(__objList__)
		" objName to:pyCmd
		
		local pyExec = python.execute ( pyCmd as string )
		
		if ( pyExec == #success ) then
		(
			out = ::_genPyFns.ListToArray "__objNames__"
		)
		
		out
	),
	
	fn GetModule =
	(
		( GetSourceFileName() )
	),

	fn Help =
	(
		::mxs.GetScriptHelp ( GetSourceFileName() )
	),

private

	fn _init =
	(
		if not ( DoesFileExist this.abcFile ) then
		(
			format "***** abcFile provided does not exist: % *****\n" this.abcFile
			return undefined
		)
		
		this.InitializePythonModule()
		this.GetAllObjectNames()
	),

	__init__ = _init()
)

