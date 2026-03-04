//-------------------------------------------------------------
// Vision Sets
//-------------------------------------------------------------

local WonderWeapons = TFA.WonderWeapon

WonderWeapons.AddVisionSet("BO3_Ragnarok_Vortex", {
	addred = 0,
	addgreen = 0.2,
	addblue = 0.3,

	contrast = 0.1,
	colour = 1.2,

	motionblur = true,
	motionblurVertical = 0,
	motionblurForward = 0.04,
	motionblurRoll = 0,

	vignette = true,
	vignettealpha = 96,
	vignettepasses = 1,

	vignetteblur = true,
})

WonderWeapons.AddVisionSet("BO3_GKZ_MK3_Vortex", {
	addred = 0.1,
	addgreen = 0.05,
	addblue = 0.2,

	contrast = 0.1,
	colour = 1.2,

	motionblur = true,
	motionblurVertical = 0,
	motionblurForward = 0.02,
	motionblurRoll = 0,

	vignette = true,
	vignettealpha = 96,
	vignettepasses = 1,

	vignetteblur = true,
})

WonderWeapons.AddVisionSet("BO3_GKZ_Vortex", {
	addred = 0.1,
	addgreen = 0.1,
	addblue = 0.025,

	contrast = 0.1,
	colour = 1.2,

	motionblur = true,
	motionblurVertical = 0,
	motionblurForward = 0.02,
	motionblurRoll = 0,

	vignette = false,
	vignettealpha = 96,
	vignettepasses = 1,

	vignetteblur = true,
})

WonderWeapons.AddVisionSet("BO3_Black_Hole", {
	addred = 0.065,
	addgreen = 0,
	addblue = 0.2,

	addred_upgraded = 0.2,
	addgreen_upgraded = 0,
	addblue_upgraded = 0,

	contrast = 0,
	colour = 1,

	motionblur = true,
	motionblurVertical = 0,
	motionblurForward = 0.05,
	motionblurRoll = 0,

	vignette = true,
	vignettealpha = 128,
	vignettepasses = 1,

	vignetteblur = true,
})

WonderWeapons.AddVisionSet("BO3_Interdimensional_Portal", {
	addred = 0.2,
	addgreen = 0,
	addblue = 0.3,

	addred_upgraded = 0.25,
	addgreen_upgraded = 0,
	addblue_upgraded = 0,

	contrast = 0.1,
	colour = 1.1,

	motionblur = true,
	motionblurVertical = 0,
	motionblurForward = 0.05,
	motionblurRoll = 0,

	vignette = true,
	vignettealpha = 128,
	vignettepasses = 1,

	vignetteblur = true,
})

//-------------------------------------------------------------
// Vision Set Entities
//-------------------------------------------------------------

local VisionType = WonderWeapons.VisionSet.Types

WonderWeapons.AddVisionSetEntity("bo3_special_dg4", {
	visionset = "BO3_Ragnarok_Vortex",
	range = 400,
	fade = 200,

	colormodType = VisionType.DISTANCE,
	motionblurType = bit.bor( VisionType.DISTANCE, VisionType.LINE_OF_SIGHT ),
	vignetteType = VisionType.DISTANCE,
	vignetteblurType = bit.bor( VisionType.DISTANCE, VisionType.VISIBILITY ),

	LinkedClasses = {"bo4_specialist_dg5"}
})

WonderWeapons.AddVisionSetEntity("bo3_ww_gkzmk3_bh", {
	visionset = "BO3_GKZ_MK3_Vortex",
	range = 400,
	fade = 200,

	colormodType = VisionType.DISTANCE,
	motionblurType = bit.bor( VisionType.DISTANCE, VisionType.LINE_OF_SIGHT ),
	vignetteType = VisionType.DISTANCE,
	vignetteblurType = bit.bor( VisionType.DISTANCE, VisionType.VISIBILITY ),
})

WonderWeapons.AddVisionSetEntity("bo3_ww_gkz", {
	visionset = "BO3_GKZ_Vortex",
	range = 300,
	fade = 200,

	colormodType = VisionType.DISTANCE,
	motionblurType = bit.bor( VisionType.DISTANCE, VisionType.LINE_OF_SIGHT ),
	vignetteType = VisionType.DISTANCE,
	vignetteblurType = bit.bor( VisionType.DISTANCE, VisionType.VISIBILITY ),
})

WonderWeapons.AddVisionSetEntity("bo3_tac_gersch", {
	visionset = "BO3_Black_Hole",
	range = 600,
	fade = 300,
	upgrade = true,

	colormodType = VisionType.DISTANCE,
	motionblurType = bit.bor( VisionType.DISTANCE, VisionType.LINE_OF_SIGHT ),
	vignetteType = VisionType.DISTANCE,
	vignetteblurType = bit.bor( VisionType.DISTANCE, VisionType.VISIBILITY ),

	LinkedClasses = {"nz_bo3_tac_gersch"}
})

WonderWeapons.AddVisionSetEntity("bo3_ww_idgun", {
	visionset = "BO3_Interdimensional_Portal",
	range = 400,
	fade = 100,
	upgrade = true,

	colormodType = VisionType.DISTANCE,
	motionblurType = bit.bor( VisionType.DISTANCE, VisionType.LINE_OF_SIGHT ),
	vignetteType = VisionType.DISTANCE,
	vignetteblurType = bit.bor( VisionType.DISTANCE, VisionType.VISIBILITY ),
})
