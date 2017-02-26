_mxs.Using "AssemblyManager"

-- DotNet Assemblies need to be loaded at the Global scope
_AssemblyManager.LoadAssembly ( ( _mxs.GetPath #assemblies ) + "/WpfProgressBar.dll")

-- load the WPF Integration library needed to create the ElementHost control
dotNet.loadAssembly @"C:\Program Files (x86)\Reference Assemblies\Microsoft\Framework\v3.0\WindowsFormsIntegration.dll"

struct WpfProgressBar
(
	steps = 0,
	progBar = dotNetObject "WpfProgressBar.UserControl_prgBar",
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
		this.progBar.Steps = _steps
        this.maxForm.ShowModeless()
	),
	
	fn Step =
	(
		this.progBar.Step()
		( dotNetClass "System.Windows.Forms.Application" ).DoEvents()
	),
	
	fn GetLabelText =
	(
		this.progBar.GetLabelText()
	),
	
	fn UpdateLabel strCaption =
	(
		 this.progBar.ProgressLabel = strCaption
	),
	
	fn End =
	(
		this.maxForm.Close()
	),
	
	fn Help =
	(
		format "
---------------
CLASS USAGE:

Constructor = WpfProgressBar

instantiate and set properties prior to iterating:
	caption: Progress window title
	steps: Number of loop iterations
		
Use methods:
	UpdateLabel: Pass a string to this method to change the label text.
				 You can update the label text at any time while iterating.
	
	Start: Use this to envoke the UI prior to iterating
	
	DoStep: Call this at the end of each iteration
		
	End: Call this once you exit the iteration loop to close the UI
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
	),

	__init__ = _init()
)




/******* EXAMPLE:

objArr = Objects as array
objProgress = WpfProgressBar caption:"Objects Progress:" steps:objArr.count

objProgress.Start()
for i in objArr do
(
	objProgress.UpdateLabel i.name
	
	objProgress.Step()
	--sleep .02
)
objProgress.End()

*********/

