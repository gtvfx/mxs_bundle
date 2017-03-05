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


[DESCRIPTION]


[USAGE]


__END__
*/



struct qc_DMS_ObjectNames
(
public
    
    super, -- This is a place for a Super Class that is using this class as a plugin
    debug = False,
    
    objArr, -- This is the collection of objects to run on. If left undefined then this will defalut to  ( objects as array )
	
	title = "Check For DMS Conform Object Names",
	description = "Checks that object names conform to the DMS naming convention",
	
	suffixArr = #("GEO", "SDM", "PLY", "AN", "COL", "ENV", "NUL", "MSH", "NON", "NST", "PRT"),
    
	fn ValidateObjArr objArr = 
	(
		local out = for obj in objArr where ( IsValidNode obj ) collect obj
		out
	),
	
	fn DoesObjectNameConform obj =
	(
		local suffix = obj.name[obj.name.count - 2] + obj.name[obj.name.count - 1] + obj.name[obj.name.count]
		
		if ( FindItem this.suffixArr suffix) != 0 then
		(
			True
		)
		else
		(
			False
		)
	),
	
	fn GetNonConformObjectss objArr:this.objArr = 
	(
		objArr = this.ValidateObjArr objArr
		-- Filter to only geometry
		objArr = for obj in objArr where ( SuperClassOf obj == GeometryClass ) collect obj
		
		local out = #()
		
		for obj in objArr do
		(
			if not ( this.DoesObjectNameConform obj ) then
			(
				append out obj
			)
		)
		
		out
	),
	
	fn CheckForNonConformObjects objArr:this.objArr =
	(		
		local nonConformArr = this.GetNonConformObjectss objArr:objArr
		
		local msg = StringStream ""
        format "There are % non-conform names\n" nonConformArr.count to:msg
        print ( msg as string )
		
		if nonConformArr.count != 0 then
        (
            if ( this.super != undefined ) and ( isProperty this.super #msgBuffer ) then
            (
                this.super.msgBuffer = ( msg as string )
            )
            
            False
        )
        else
        (
            True
        )
	),
	
	fn AutoConformObjects objArr:this.objArr =
	(
		local nonConformArr = this.GetNonConformObjectss objArr:objArr
		
		if nonConformArr.count != 0 then
		(
			for obj in nonConformArr do
			(
				-- Right now the only applicable suffix for geo coming from Gen is PLY
				-- This may change once we start using OpenSubDiv
				
				local geoSuffix = "PLY"
				local nullSuffix = "NUL"
				
				case ( SuperClassOf obj ) of
				(
					( GeometryClass ):
					(
						obj.name = ( obj.name + geoSuffix )
					)
-- 					( Helper ):
-- 					(
						-- Not able to separate the Named Asset hierarchy form transform nulls within the asset
-- 						obj.name = ( obj.name + nullSuffix )
-- 					)
				)
				
			)
		)
	),
	
	fn SelectNonConformObjects objArr:this.objArr =
	(
		select ( this.GetNonConformObjectss objArr:objArr )
	),
    
    fn CheckMethod objArr:this.objArr =
    (
        this.CheckForNonConformObjects objArr:objArr
    ),
    
    fn FixMethod objArr:this.objArr =
    (
        this.AutoConformObjects objArr:objArr
    ),
    
    fn SelectMethod objArr:this.objArr =
    (
        this.SelectNonConformObjects objArr:objArr
    ),
    
    fn Run objArr:this.objArr =
    (
        if not ( this.CheckMethod objArr:objArr ) then
        (
            if ( queryBox "Would you like to automatically conform object names?" title:"?" ) then
            (
                this.FixMethod()
            )
        )
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
        if this.objArr == undefined then
        (
            this.objArr = ( objects as array )
        )
    ),

    __init__ = _init()
)




