fn getCamLensFromFov fov =
(
	lens = 0.5 * (GetRendApertureWidth() / tan(fov/2.0))
	lens
)

fn getCamFovFromLens lens =
(
	fov = 2.0* atan(GetRendApertureWidth()/lens*0.5)
	fov
)


/* 
where
Lens is in mm
FOV is in degrees
*/