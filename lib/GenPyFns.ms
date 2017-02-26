/* 
Misc Maxscript-wrapped functions that are commonly used by many tools
*/

_ilmLibrary.load "ilmPathUtils" inReload:False

::PYTHON_RETURN
::_GenPyFns

struct GenPyFns
(	
	fn ListToArray pyList =
	(
		pyCmd = StringStream ""
		
		format "
arr = '#({0})'.format(','.join([str('\"'+n+'\"') for n in %]))
MaxPlus.Core.EvalMAXScript('PYTHON_RETURN = {0}'.format(arr))
		" pyList to:pyCmd
		
		python.execute (pyCmd as string)

		PYTHON_RETURN
	),
	
	fn ArrayToList arr listVarStr =
	(
		/* 
		- listVarStr is a string value that will be defined as the variable in Python that holds the list value
		- This only works for arrays of string values at the moment
		- It could be possible to transfer MaxObjects from an Array to a List using the FPValue. Will need to look into it more.
		 */
		
		pyCmd = StringStream ""
		
		format "
tempList = []
tempStr = '%'
		
tempStr = tempStr.replace('#(', '')
tempStr = tempStr.replace('\")', '')

tempList = tempStr.split(',')
% = tempList
		" arr listVarStr to:pyCmd
		
		python.execute (pyCmd as string)
	),
	
	fn GetGenTaskDir _show =
	(
		pyCmd = StringStream ""
		
		format "
import os
from eco import Settings

def GetGenTaskDir(showName):
	task = 'gen'
	local_site_ext = ''
	settings = None

	site = os.getenv('LFL_SITE')

	if site is not None:
		settings = Settings.use('mktaskdir', project = showName)
		local_site_ext = settings.get('site_to_extension_map').get(site,'')
	else:
		print 'Environment variable LFL_SITE is returned None'
		return task
		
	if local_site_ext != '':
		task = (task + '_' + local_site_ext)
		
	return task
	
_task = GetGenTaskDir(%)

MaxPlus.Core.EvalMAXScript('PYTHON_RETURN = {0}'.format(('\"'+_task+'\"')))
" ("\""+_show+"\"") to:pyCmd

		python.execute (pyCmd as string)

		PYTHON_RETURN
	),
	
	fn MkTaskDir site taskDir =
	(
		/* you can get the current site string from: SystemTools.GetEnvVariable "LFL_SITE" */
		
		if site == undefined or site == "" then return "MkTaskDir requires a valid site string"
		
		taskDir = _ilmPathUtils.LinuxifyPath taskDir
		if (filterString taskDir "/")[1] == "lucas" then
		(
			taskDir = "/"+taskDir
		)
		
		pyCmd = StringStream ""
		
		format "
import remotedir

(return_value,output,error) = remotedir.ensure_taskdir('%', r'%')
		
out = ''
if error != '':
	out = 'error'
else:
	out = 'True'
		
print error
		
MaxPlus.Core.EvalMAXScript('PYTHON_RETURN = \"{0}\"'.format(out))
		" site taskDir to:pyCmd
		
		python.execute (pyCmd as string)

		PYTHON_RETURN
	),
	
	fn RemoveDir dir =
	(
		pyCmd = StringStream ""
		
		format "
import shutil
		
shutil.rmtree(r'%')
		" dir to: pyCmd
		
		python.execute pyCmd
	),
	
	private fn _init =
	(
		format "***** Gen Python Functions *****\n"
	),
	
	__init__ = _init()
)

_GenPyFns = GenPyFns()



