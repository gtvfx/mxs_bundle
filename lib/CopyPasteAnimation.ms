/******************************************************************************************
Class for copying the animation from one object onto another


******************************************************************************************/

::_CopyPasteAnimation

struct CopyPasteAnimation
(
	private fn CopyAnimation obj =
	(
		out = #()
		--position
		append out obj.pos.x_position.controller.keys
		append out obj.pos.y_position.controller.keys
		append out obj.pos.z_position.controller.keys
		
		--rotation
		append out obj.rotation.x_rotation.controller.keys
		append out obj.rotation.y_rotation.controller.keys
		append out obj.rotation.z_rotation.controller.keys
		
		--scale
		obj.Scale.Controller = ScaleXYZ()
		append out obj.scale.x_scale.controller.keys
		append out obj.scale.y_scale.controller.keys
		append out obj.scale.z_scale.controller.keys
		
		out
	),

	private fn AppendKeys from_obj_anim to_obj_anim =
	(
		for x = 1 to from_obj_anim.count do
		(
			for i = 1 to from_obj_anim[x].count do
			(
				appendKey to_obj_anim[x] from_obj_anim[x][i]
			)
		)
		
	),

	public fn CopyPasteAnim from_obj to_obj =
	(
		deleteKeys to_obj #allKeys
		
		from_obj_anim = CopyAnimation from_obj
		to_obj_anim = CopyAnimation to_obj
		
		AppendKeys from_obj_anim to_obj_anim
	),
	
	private fn _init =
	(
				format "
---------------
CLASS USAGE:
		
Use <CopyPasteAnim from_obj to_obj> 
---------------\n"
	),

	__init__ = _init()
)

_CopyPasteAnimation = CopyPasteAnimation()


