_mxs.Using "AssemblyManager" inReload:False

-- DotNet Assemblies need to be loaded at the Global scope

-- load the progress bar library
-- Load the AssemblyManager class and use it to load the custom assembly
if (_mxs.GetPath #assemblies) == "" then
(
	local iniFile = _ilmLibrary.GetUserConfigFile()
	
	if DoesFileExist iniFile then
	(
		local currEnv = (_ilmLibrary.GetCurrEnvironment())
		local maxPythonPath = (GetIniSetting iniFile currEnv "maxpython")
		local assemblyPath = (SubstituteString maxPythonPath "\\python" "\\assemblies")
			
		SetIniSetting iniFile currEnv "assemblies" assemblyPath
			
		_AssemblyManager.LoadAssembly (assemblyPath + "/WpfProgressBar_double.dll")
	)
	else
	(
		format "***** Could not get user config file *****\n"
	)
)
else
(
	_AssemblyManager.LoadAssembly ( ( _mxs.GetPath #assemblies ) + "WpfProgressBar_double.dll" )
)



-- load the WPF Integration library needed to create the ElementHost control
dotNet.loadAssembly @"C:\Program Files (x86)\Reference Assemblies\Microsoft\Framework\v3.0\WindowsFormsIntegration.dll"

::WpfProgressBar_double

struct WpfProgressBar_double
(
	steps = 0,
	sub_steps = 0,
	progBar = dotNetObject "WpfProgressBar_double.UserControl_prgBar",
	maxForm = dotNetObject "MaxCustomControls.MaxForm",
	elmntHost = dotNetObject "System.Windows.Forms.Integration.ElementHost",
	
	caption = "Progress",
	maxForm_width = 300,
	maxForm_height = 30,
	maxForm_startPosition = this.maxForm.startPosition.centerScreen,
	maxForm_formBorderStyle = this.maxForm.formBorderStyle.fixedToolWindow,
	
	fn CreateForm _maxForm _title:this.caption _width:this.maxForm_width _heigth:this.maxForm_height _startPosition:this.maxForm_startPosition _formBorderStyle:this.maxForm_formBorderStyle =
	(
		_maxForm.text = _title
		_maxForm.width = _width
		_maxForm.height = _heigth
		_maxForm.startPosition = _maxForm.startPosition.centerScreen
		_maxForm.formBorderStyle = _maxForm.formBorderStyle.fixedToolWindow
	),
	
	fn Start _steps:this.steps =
	(
		this.maxForm.showModeless()
		this.progBar.Clear()
		this.progBar.Steps = _steps
	),
	
	fn Start_Sub _steps:this.sub_steps =
	(
		this.progBar.Clear_Sub()
		this.progBar.sub_Steps = _steps
	),
	
	fn Step =
	(
		this.progBar.Step()
		(dotNetClass "System.Windows.Forms.Application").DoEvents()
	),
	
	fn Step_Sub =
	(
		this.progBar.Step_Sub()
		(dotNetClass "System.Windows.Forms.Application").DoEvents()
	),
	
	fn GetLabelText =
	(
		this.progBar.GetLabelText()
	),
	
	fn GetLabelText_Sub =
	(
		this.progBar.GetSubLabelText()
	),
	
	fn UpdateLabel strCaption =
	(
		this.progBar.ProgressLabel = strCaption
	),
	
	fn UpdateLabel_Sub strCaption =
	(
		this.progBar.sub_ProgressLabel = strCaption
	),
	
	fn End =
	(
		this.maxForm.Close()
	),
	
	fn ClassUsage =
	(
		format "
---------------
CLASS USAGE:

Constructor = WpfProgressBar_double

instantiate and set properties prior to iterating:
	caption: Progress window title
	steps: Number of loop iterations
		
Use methods:
	GetLabelText:
		Returns the string value of the main label
		
	GetLabelText_Sub:
		Returns the string value of the sub label
		
	UpdateLabel <string>: 
		Pass a string to this method to change the label text.
		You can update the label text at any time while iterating.
		
	UpdateLabel_Sub <string>:
		Pass a string to this method to change the sub label text.
		You can update the sub label text at any time while iterating.
	
	Start <_steps>:
		Use this to envoke the UI prior to iterating
		
	Start_Sub <_steps>:
		Use this to clear the value of the sub progress bar and set the number of steps
	
	Step:
		Call this at the end of each main iteration to increment the main progress value
		
	Step_Sub:
		Call this at the end of each sub iteration to increment the sub progress value
		
	End:
		Call this once you exit the iteration loop to close the UI
---------------\n"
	),
	
	private fn _init =
	(		
		-- define controls
		this.elmntHost.dock = this.elmntHost.dock.fill
		this.maxForm_width = (this.progBar.Width + 16)
		this.maxForm_height = (this.progBar.Height + 34)
		
		this.CreateForm this.maxForm
		
		-- add ElementHost, which holds the WPF control
		this.maxForm.controls.Add this.elmntHost
		-- add the WPF control
		this.elmntHost.child = this.progBar
		
		this.UpdateLabel ""
		this.UpdateLabel_Sub ""
	),

	__init__ = _init()
)




/******* EXAMPLE:

mainArr = for i = 1 to 20 collect i
subArr = for i = 1 to 99 collect i

objProgress = WpfProgressBar_double caption:"Objects Progress:" steps:mainArr.count
objProgress.Start()
for i in mainArr do
(
	objProgress.UpdateLabel (i as string)
	
	objProgress.Sub_Start _steps:subArr.count
	for sub in subArr do
	(
		objProgress.UpdateSubLabel (sub as string)
		objProgress.Sub_Step()
		sleep .01
	)
	
	
	
	objProgress.Step()
	sleep .05
)
objProgress.End()

*********/

