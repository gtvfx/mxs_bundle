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
***************************************************************************************************/
/*
__HELP__

Constructor: 
Instantiated Global: 

[METHODS]
    UpdateLabel: Pass a string to this method to change the label text.
				 You can update the label text at any time while iterating.
	
	Start: Use this to envoke the UI prior to iterating
	
	DoStep: Call this at the end of each iteration
		
	End: Call this once you exit the iteration loop to close the UI

[DESCRIPTION]
This is a WPF widget wrapped in Maxscript methods

This is much simpler to use than the internal 3dsmax progress bar

[USAGE]
instantiate and set properties prior to iterating:
	caption: Progress window title
	steps: Number of loop iterations

__END__
*/




/*
__MXSDOC__

[TITLE]
WpfProgressBar

[DESCRIPTION]


[USAGE]
See Help()

[CREATION INFO]
Author: Gavyn Thompson
E-mail: gthompson@ilm.com
Company: Industrial Light and Magic
Date created: 
Last Updated: 

[KEYWORDS]


[VERSION HISTORY]


[SEE ALSO]

__END__
*/

/


mxs.Using "AssemblyManager"

-- DotNet Assemblies need to be loaded at the Global scope

-- load the progress bar library
-- Load the AssemblyManager class and use it to load the custom assembly

AssemblyManager.LoadAssembly ((mxs.GetPath #assemblies) + "WpfProgressBar.dll")


-- load the WPF Integration library needed to create the ElementHost control
dotNet.loadAssembly @"C:\Program Files (x86)\Reference Assemblies\Microsoft\Framework\v3.0\WindowsFormsIntegration.dll"


struct WpfProgressBar
(
public
    
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
		try(this.progBar.Step())catch(this.progBar.DoStep())
		(dotNetClass "System.Windows.Forms.Application").DoEvents()
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
	
	fn GetModule =
    (
        ( GetSourceFileName() )
    ),

    fn Help =
    (
        ::mxs.GetScriptHelp ( GetSourceFilename() )
    ),
	
private
    
    fn _init =
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

