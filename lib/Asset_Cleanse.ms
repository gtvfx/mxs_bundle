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


mxs.Using "EventTimer"
mxs.Using "WpfProgressBar_double"



struct AssetPlugin
( -- Construct for plugin object
	title = "",
	method = unsupplied,
	aux = unsupplied,
	active = False,
	description = ""
)

struct AssetPluginManager
(-- The Plugin manager is aggregated by the main tool and handles the plugins
	_resourcePath, -- Path to folder containing plugin files
	_pluginsLoaded = False,
	_plugins = #(), -- Array of AssetPlugin objects
	
	fn Register title:unsupplied method:unsupplied aux:unsupplied active:true description:"" =
	( 
		local success = True
		if title == unsupplied or method == unsupplied then
		(
			format "***** Plugin Load Failed *****\n"
			return False
		)
		format "***** Loading Plugin: % | active:% *****\n" title active
		append this._plugins (AssetPlugin title:title method:method aux:aux active:active description:description)
	),
	
	fn init refresh:false =
	(
		if (not this._pluginsLoaded or refresh) then
		(
			-- Load Plugins
			format "--------------------------------------------------------------------------------------------------------------\n"
			format "===== Loading Plugins... =====\n"
			
			this._plugins = #()
			
			-- Load Plugin Files
			local filenames = getFiles (this._resourcePath + "*.ms")
			sort filenames
			for filename in filenames do filein filename
			
			format "--------------------------------------------------------------------------------------------------------------\n"
		)
	)
)



-- asset cleanse is a script to automatically cleanse mesh objects from technicall imperfections that can bug up the pipeline.


struct Asset_Cleanse
(
	ro,
	
	nameSpace = "AssetCleanse:",
	_progressLabel,
	_progressBar,
	
	testList = #(),
	
	excludeSuperClassArr = #( Helper, Light, Camera ),
	excludeClassArr = #( TargetObject ), -- see the init function for additional third party classes
	complete = False,
	-----
    objArr = #(),
	allObjects = this.objArr,
	testObjects = #(),
	excludedObjs = #(),
	-----
	resourcePath = ( GetFileNamePath ( GetThisScriptFilename() ) ) + @"ScriptPlugins\AssetCleanse\",
	plugManager = ( ::AssetPluginManager _resourcePath:resourcePath ),
		
	------

	
	fn IsExcludedSuperClass obj =
	(
		/* 
		A function to filter out objects by superclass
		defined in the struct variable excludeSuperClassArr
		 */
		local type = ( SuperClassOf obj )
		local out = case ( FindItem this.excludeSuperClassArr type ) of
		(
			(0):False
			default:True
		)
        
		out
	),
	
	fn IsExcludedClass obj =
	(
		/* 
		A function to filter out objects by class
		defined in the struct variable excludeClassArr
		 */
		local type = ( ClassOf obj )
		local out = case ( FindItem this.excludeClassArr type ) of
		(
			(0):False
			default:True
		)
        
		out
	),
	
	fn IsExcluded obj =
	( -- Tests if the object is cleared for proceeding with the cleansing process
		if ( this.IsExcludedSuperClass obj ) then
		(
			AppendIfUnique this.excludedObjs obj
			True
		)
		else if ( this.IsExcludedClass obj ) then
		(
			AppendIfUnique this.excludedObjs obj
			True
		)
		else 
		(
			False
		)
	),
	
	fn RefactorObjs = 
	(
		/* 
		Re-evaluates the allObjects array
		This needs to be run periodically throughout the process as scene objects change
		 */
		if this.allObjects.count != 0 then
		(
			this.allObjects = for i in this.allObjects where ( not isDeleted i ) collect i
			this.testObjects = for i in this.allObjects where ( not isDeleted i ) and ( i != undefined ) and not ( this.IsExcluded i ) collect i
			this.excludedObjs = for i in this.excludedObjs where ( not isDeleted i ) collect i
			True
		)
		else
		(
			this.allObjects = #()
			this.testObjects = #()
			this.excludedObjs = #()
			False
		)
	),
	
	fn RunPlugins =
	(
		if this.plugManager._plugins.count != 0 then
		(
			local cleanseTime = ::EventTimer caption:"Total asset cleanse"
			
			local activePlugins = for i in this.plugManager._plugins where i.active collect i
				
			this._progressBar = ::WpfProgressBar_double caption:"Asset Cleanse:" steps:activePlugins.count
			this._progressBar.Start() 
			
			for i = 1 to activePlugins.count do
			(
				this._progressBar.UpdateLabel activePlugins[i].title
				
				format "---------- % ----------\n" activePlugins[i].title
				
				local plugStart = ::EventTimer caption:activePlugins[i].title
				
				activePlugins[i].method()
					
				plugStart.End()
				
				this._progressBar.Step()
			)
			
			this._progressBar.End()
			
			cleanseTime.End()
		)
	),
	
	fn Run =
	(
		if this.allObjects.count != 0 then
		(
			::mxs.BlockUi True
			setCommandPanelTaskMode #create 
			
			this.RefactorObjs()
			
			this.plugManager.init()
			
			this.RunPlugins()
			
			::mxs.BlockUi False
		)
		else
		(
			format "***** AssetCleanse requires a collection of objects be passed to the 'allObjects' parameter at instantiation *****\n"
		)
	),
    
    fn Help =
    (
        format "
---------------
CLASS USAGE: 

Constructor = Asset_Cleanse
instantiated global = _assetCleanse		

You must provide an object array to the 'allObjects' property
use Run() method to begin cleanse process
---------------\n"
    ),
	
	private fn _init =
	(
		-- Check for 3rd Party plugin classes that we need to exclude
		local testClassArr = #(Forest_Pro, VRayFur)
        
		for i in testClassArr where i != undefined do
		(
			append this.excludeClassArr i
		)
	),
	
	public __init__ = _init()
)

_assetCleanse = Asset_Cleanse()




/*
-- ASSET
_assetCleanse.allObjects = ( objects as array )
_assetCleanse.run()
	
*/