clearlistener ()

fn deleteca obj caname =  -- casesensitive
	(
		defs = for objDef in (custAttributes.getDefs obj) where objdef.name == caname collect objDef
		for DEF in defs do
			(
				custAttributes.delete obj DEF
			)
	)
try
	(
		deleteca $ "General Buttons"
	)
catch ()



AnimationOffset_CA = attributes "Animation Offset"
	(
		parameters main rollout:general
			(
				spn_animOffset 		type:#integer 	ui:spn_UIanimOffset 		default:false
				
/*
				chk_prt 				type:#boolean 		ui:chk_HideParticles 		default:false
				chk_ski 				type:#boolean 		ui:chk_SkinOff 				default:false
				chk_map 				type:#boolean 		ui:chk_MapsOff 				default:false
				chk_blk 				type:#boolean 		ui:chk_blkOff 				default:false
				chk_planeXProxy		type:#integer		ui:plane_typeXProxy
				chk_proxyView 		type:#boolean 		ui:chk_ProxView 				default:false
				chk_dispXrefBB		type:#Boolean		ui:chk_dispBB				default:false
*/
			)
			
			
		rollout	general "general  settings"
			(
				spinner spn_UIanimOffset "Animation Offset:  "
				
				button btn_Offset "Offset Animation" 
				
				local arrObj = #()
						
				
				on 

				
				)
	)

custAttributes.add $ general_ca #unique baseobject:true

	
--( Apply animation controllers to UI tracks	


/*
	
$.chk_rig .controller 				= boolean_float ()
$.chk_prt.controller 				= boolean_float ()
$.chk_ski .controller 			= boolean_float ()
$.chk_map.controller 			= boolean_float ()
		
$.chk_blk.controller 				= boolean_float ()
$.chk_planeXProxy.controller 	= boolean_float ()
$.chk_proxyView.controller 	= boolean_float ()
$.chk_dispXrefBB.controller 	= boolean_float ()

*/
	
--) End Apply animation controllers to UI tracks	
