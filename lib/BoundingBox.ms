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

Constructor: BoundingBox
Instantiated Global: N/A

Methods:



__END__
*/



struct BoundingBox
(
public
	-- required fields
	obj, -- Single object, Array of objects, or ObjectSet
	
	-----------------------------------
	
	nodeLocal = False,
	
	minPoint,
	maxPoint,
	
	cenPoint,
	
	minPointXmax,
	minPointXZmax,
	minPointZmax,
	
	maxPointZmin,
	maxPointXmin,
	maxPointXZmin,
	
	midPointYminZmax,
	midPointYminZmin,
	midPointXminYmin,
	midPointXmaxYmin,
	midPointXminYmax,
	midPointXmaxYmax,
	midPointYmaxZmax,
	midPointYmaxZmin,
	midPointXminZmin,
	midPointXminZmax,
	midPointXmaxZmin,
	midPointXmaxZmax,
	
	cenPointZmax,
	cenPointZmin,
	cenPointXmax,
	cenPointXmin,
	cenPointYmax,
	cenPointYmin,
	
	length,
	width,
	height,
	size,
	
	fn ReInit =
	(
		this.GetMinMax()
		this.GetGrid()
		this.GetLength()
		this.GetWidth()
		this.GetHeight()
		this.GetSize()
		OK
	),
	
	fn DrawHelper coord propName:"" multiplier:1 =
	(
		local p = point pos:( coord * multiplier ) name:( uniqueName ( "boundingPoint_" + ( propName as string )+"_001" ) ) cross:True box:False axisTripod:False
		p
	),
	
	fn DrawHelperGrid =
	(
		--bBox = BoundingBox minPoint:objOrObjectSet.min maxPoint:objOrObjectSet.max
		local prps = GetPropNames this
		
		for p in prps where ( MatchPattern p pattern:"*Point*" ) do
		(
			this.DrawHelper ( GetProperty this p ) propName:p
		)
	),
	
	fn DrawNodeLocalHelperGrid obj =
	(
		local minMaxArr = in coordSys local (nodeLocalBoundingBox obj)
		
		this.minPoint = minMaxArr[1]
		this.maxPoint = minMaxArr[2]
		
		this.GetGrid()
		
		local prps = GetPropNames this
		
		for p in prps where matchPattern p pattern:"*Point*" do
		(
			this.DrawHelper ( GetProperty this p ) propName:p multiplier:obj.transform
		)
		
		this.ReInit()
	),
	
	fn DrawBox =
	(
		local b = Box pos:this.cenPointZmin length:this.length width:this.width height:this.height
	),
	
	fn GetLength =
	(
		this.length = ( Distance this.minPoint this.maxPointXZmin )
		this.length
	),
	
	fn GetWidth =
	(
		this.width = ( Distance this.minPoint this.minPointXmax )
		this.width
	),
	
	fn GetHeight = 
	(
		this.height = ( Distance this.minPoint this.midPointXminZmax )
		this.height
	),
	
	fn GetSize =
	(
		this.size = [this.width, this.length, this.height]
		this.size
	),
	
	fn GetMinMax obj:this.obj =
	(
		case ( ClassOf obj ) of
		(
			( Array ):
			(
				local currSelection = ( GetCurrentSelection() )
				
				select obj
				
				this.minPoint = selection.min
				this.maxPoint = selection.max
				
				select currSelection
			)
			( ObjectSet ):
			(
				this.minPoint = obj.min
				this.maxPoint = obj.max
				
				this.obj = ( this.obj as array )
			)
			default:
			(
				if ( SuperClassOf obj == GeometryClass ) then
				(
					this.minPoint = obj.min
					this.maxPoint = obj.max
				)
				else
				(
					local str = StringStream ""
					format "Unable to min/max from provided object: %\n" obj to:str
					messageBox ( str as string ) title:"Invalid Type:"
				)
			)
		)
	),
	
	fn GetGrid =
	(
		in coordSys local
		(
			this.cenPoint = [ ( this.minPoint.x + ( ( this.maxPoint.x - this.minPoint.x) / 2 ) ), ( this.minPoint.y + ( ( this.maxPoint.y - this.minPoint.y ) / 2 ) ), ( this.minPoint.z + ( ( this.maxPoint.z - this.minPoint.z ) / 2 ) ) ]
			
			this.minPointXmax = [ this.maxPoint.x, this.minPoint.y, this.minPoint.z ]
			this.minPointXZmax = [ this.maxPoint.x, this.minPoint.y, this.maxPoint.z ]
			this.minPointZmax = [ this.minPoint.x, this.minPoint.y, this.maxPoint.z ]
			
			this.maxPointZmin = [ this.maxPoint.x, this.maxPoint.y, this.minPoint.z ]
			this.maxPointXmin = [ this.minPoint.x, this.maxPoint.y, this.maxPoint.z ]
			this.maxPointXZmin = [ this.minPoint.x, this.maxPoint.y, this.minPoint.z ]
			
			this.midPointYminZmax = [ ( this.minPoint.x + ( ( this.maxPoint.x - this.minPoint.x ) / 2 ) ), this.minPoint.y, this.maxPoint.z]
			this.midPointYminZmin = [ ( this.minPoint.x + ( ( this.maxPoint.x - this.minPoint.x ) / 2 ) ), this.minPoint.y, this.minPoint.z]
			this.midPointXminYmin = [ this.minPoint.x, this.minPoint.y, ( this.minPoint.z + ( ( this.maxPoint.z - this.minPoint.z ) / 2 ) ) ]
			this.midPointXmaxYmin = [ this.maxPoint.x, this.minPoint.y, ( this.minPoint.z + ( ( this.maxPoint.z - this.minPoint.z ) / 2 ) ) ]
			this.midPointXminYmax = [ this.minPoint.x, this.maxPoint.y, ( this.minPoint.z + ( ( this.maxPoint.z - this.minPoint.z ) / 2 ) ) ]
			this.midPointXmaxYmax = [ this.maxPoint.x, this.maxPoint.y, ( this.minPoint.z + ( ( this.maxPoint.z - this.minPoint.z ) / 2 ) ) ]
			this.midPointYmaxZmax = [ ( this.minPoint.x + ( ( this.maxPoint.x - this.minPoint.x ) / 2 ) ), this.maxPoint.y, this.maxPoint.z ]
			this.midPointYmaxZmin = [ ( this.minPoint.x + ( ( this.maxPoint.x - this.minPoint.x ) / 2 ) ), this.maxPoint.y, this.minPoint.z ]
			this.midPointXminZmin = [ this.minPoint.x, ( this.minPoint.y + ( ( this.maxPoint.y - this.minPoint.y ) / 2 ) ), this.minPoint.z ]
			this.midPointXminZmax = [ this.minPoint.x,( this.minPoint.y + ( ( this.maxPoint.y - this.minPoint.y ) / 2 ) ), this.maxPoint.z ]
			this.midPointXmaxZmin = [ this.maxPoint.x, ( this.minPoint.y + ( ( this.maxPoint.y - this.minPoint.y ) / 2 ) ), this.minPoint.z ]
			this.midPointXmaxZmax = [ this.maxPoint.x, ( this.minPoint.y + ( ( this.maxPoint.y - this.minPoint.y ) / 2 ) ), this.maxPoint.z ]
			
			this.cenPointZmax = [ ( this.minPoint.x + ( ( this.maxPoint.x - this.minPoint.x ) / 2 ) ), ( this.minPoint.y + ( ( this.maxPoint.y - this.minPoint.y ) / 2 ) ), this.maxPoint.z ]
			this.cenPointZmin = [ ( this.minPoint.x + ( ( this.maxPoint.x - this.minPoint.x ) / 2 ) ), ( this.minPoint.y + ( ( this.maxPoint.y - this.minPoint.y ) / 2 ) ), this.minPoint.z ]
			this.cenPointXmax = [ this.maxPoint.x, ( this.minPoint.y + ( ( this.maxPoint.y - this.minPoint.y ) / 2 ) ), ( this.minPoint.z + ( ( this.maxPoint.z - this.minPoint.z ) / 2 ) ) ]
			this.cenPointXmin = [ this.minPoint.x, ( this.minPoint.y + ( ( this.maxPoint.y - this.minPoint.y ) / 2 ) ), ( this.minPoint.z + ( ( this.maxPoint.z - this.minPoint.z ) / 2 ) ) ]
			this.cenPointYmax = [ ( this.minPoint.x + ( ( this.maxPoint.x - this.minPoint.x ) / 2 ) ), this.maxPoint.y, ( this.minPoint.z + ( ( this.maxPoint.z - this.minPoint.z ) / 2 ) ) ]
			this.cenPointYmin = [ ( this.minPoint.x + ( ( this.maxPoint.x - this.minPoint.x ) / 2 ) ), this.minPoint.y, ( this.minPoint.z + ( ( this.maxPoint.z - this.minPoint.z ) / 2 ) ) ]
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
	
	fn _init obj:this.obj =
	(
		if obj != undefined then
		(
			this.GetMinMax()
		)
		else if ( this.minPoint == undefined ) or ( this.maxPoint == undefined ) then 
		(
			messageBox "BoundingBox requires a valid value for the <obj> field\nSingle object, Object Array, or ObjectSet" title:"GTVFX:"
		)
		
		if ( this.minPoint != undefined ) and ( this.maxPoint != undefined ) then
		(
			this.GetGrid()
			this.GetLength()
			this.GetWidth()
			this.GetHeight()
			this.GetSize()
		)
		else
		(
			format "***** Pass Min and Max values to the struct *****\n"
		)
	),
	
	init = _init()
)

