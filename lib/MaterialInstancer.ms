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

Constructor: MaterialInstancer
Instantiated Global: MaterialInstancer

Methods:



__END__
*/


mxs.Using "WpfProgressBar"


struct MaterialInstancer
(
public

	fn Mat_ResetMEdit_FN =
	(
		macros.run "Medit Tools" "clear_medit_slots"
	),
    
	fn GenPropStream obj stream:undefined =
	(
		local prps = #()
        
		if stream == undefined then stream = StringStream ""
            
		try( prps = GetPropNames obj )catch()
        
		for p in prps do
		(
			local val = try( GetProperty obj p )catch( undefined )
            
            -- move on to the next property if unable to return the property from the object
			if val == undefined then continue
                
			if ( classOf val == ArrayParameter ) then
			(
				format "%:%\n" p "ArrayParameter" to:stream 
			)
			else
			(
				format "%:%\n" p val to:stream
				GenPropStream val stream:stream
			)
		)
        
		stream
	),
    
	fn GenPropStreamForTexmap map stream:undefined =
	(
		if stream == undefined then stream = StringStream ""
            
		local numSubTexmaps = ( GetNumSubTexmaps map )
        
		if numSubTexmaps != 0 then
		(
			for i = 1 to numSubTexmaps do
			(
				tMap = ( GetSubTexmap map i )
				if tMap != undefined then
				(
					GenPropStreamForTexmap tMap stream:stream
				)
			)
		)
        
		--this.GenPropStream map stream:stream
        
		--stream
        
        local out = this.GenPropStream map stream:stream
	),
    
	fn GenPropStreamForMaterial mat stream:undefined =
	(
		if mat == undefined then return False
        
		if SuperClassOf mat != Material then return False
        
		if stream == undefined then stream = StringStream ""
        
		local numSubMats = ( GetNumSubMtls mat )
        
		if numSubMats != 0 then
		(
			for i = 1 to numSubMats do
			(
				GenPropStreamForMaterial ( GetSubMtl mat i ) stream:stream
			)
		)
		
		local numSubTexmaps = ( GetNumSubTexmaps mat )
        
		if numSubTexmaps != 0 then
		(
			for i = 1 to numSubTexmaps do
			(
				local tMap = ( GetSubTexmap mat i )
                
				if tMap != undefined then
				(
					this.GenPropStreamForTexmap tMap stream:stream
				)
			)
		)
		
		--this.GenPropStream mat stream:stream
        
		--stream
        
        local out = this.GenPropStream mat stream:stream
	),
    
	fn GenHashForMat mat =
	(
		local str = this.GenPropStreamForMaterial mat
		str = tolower (str as string)
		local out = ( GetHashValue str 0 )
		out
	),
    
	fn GetHashInstanceArr matArr prg:True =
	(
        /* 
                Creates a nested array
                All objects within the same sub-array are exact matches and should be instanced
                */
		local instArr = #()
		local hashArr = #()
		
		local hashProgress = undefined
        
        if prg then 
        (
            hashProgress = ::WpfProgressBar caption:"Collecting Instance Array" steps:matArr.count
            hashProgress.Start()
        )
        
		for mat in matArr do
		(
			if ( ::Keyboard.EscPressed ) then
			(
				if prg then hashProgress.End()
				return #()
			)
            
			if SuperClassOf mat != material then 
            (
                if prg then hashProgress.Step()
                continue
            )
                
			local hashVal = this.GenHashForMat mat
            
			local indx = finditem hashArr hashVal
            
			case indx of
			(
				0:
				(
					append hashArr hashVal
					append instArr #(mat)
				)
				default:
				(
					append instArr[indx] mat
				)
			)
			
            if prg then hashProgress.Step()
		)
        
		if prg then hashProgress.End()
        
		instArr
	),
    
    fn InstanceMaxObjects instArr =
	(
		for arr in instArr do
		(
			for i = 2 to arr.count do replaceInstances arr[i] arr[1]
		)
	),
    
	fn DummySaveReset =
	(
		local dummyFile = ( (GetDir #temp) + "\\_Temp.max" )
		try( SaveNodes #() dummyFile )catch()
		if ( DoesFileExist dummyFile ) then ( DeleteFile dummyFile )
	),
    
    fn Run =
    (
        -- Pass
    ),
    
private
    
    fn _init =
	(
		-- Pass
	),
	
	public __init__ = _init()
)

MaterialInstancer = MaterialInstancer()



/* Example:

instArr = MaterialInstancer.GetHashInstanceArr (SceneMaterials) prg:True
MaterialInstancer.InstanceMaxObjects instArr


*/

