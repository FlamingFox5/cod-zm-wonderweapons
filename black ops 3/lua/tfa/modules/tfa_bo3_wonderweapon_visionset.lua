
local WonderWeapons = TFA.WonderWeapon

//-------------------------------------------------------------
// Vision Sets
//-------------------------------------------------------------

/* EXAMPLE FUNCTION

WonderWeapons.AddVisionSet("Unique_Name", {
	// Default g_colourmodify table structure
	addred = 0.1,
	addgreen = 0,
	addblue = 0.1,

	brightness = 0,
	contrast = 1.0,
	colour = 1.0,

	mulred = 0,
	mulgreen = 0,
	mulblue = 0,

	// GM:GetMotionBlurValues(), overrides sources built in motion blur that distortes the edges of the screen
	motionblur = true,
	motionblurVertical = 0,
	motionblurForward = 0.1,
	motionblurRoll = 0,

	// Blurs entire screen using "pp/blurscreen"
	visionblur = false,
	visionblurAmount = 2,
	visionblurPasses = 5,

	// Vignette texture built in with GMod
	vignette = false,
	vignettepasses = 1,
})
*/

WonderWeapons.VisionSet = WonderWeapons.VisionSet or {}

local VisionSets = WonderWeapons.VisionSet

function WonderWeapons.AddVisionSet( id, data )
	if not data then return end

	if data.red == nil then
		data.red = 0
	end
	if data.grn == nil then
		data.grn = 0
	end
	if data.blu == nil then
		data.blu = 0
	end
	if data.blur == nil then
		data.blur = false
	end
	if data.blurMul == nil then
		data.blurMul = 0.2
	end
	if data.blurDelay == nil then
		data.blurDelay = 0.01
	end

	VisionSets[ id ] = data
end

function WonderWeapons.VisionSetData( id )
	return VisionSets[ id ] or nil
end

//-------------------------------------------------------------
// Functions
//-------------------------------------------------------------

if SERVER then
	function WonderWeapons.ApplyVisionSet( ply, id, duration, fadetime )
		if not IsValid( ply ) then return end

		if not WonderWeapons.VisionSetData( id ) then return end

		if duration == nil or not isnumber( duration ) or duration < 0 then
			duration = 0
		end
		if fadetime == nil or not isnumber( fadetime ) or fadetime < 0 then
			fadetime = 0
		end

		ply:SetNW2String( "WonderWeapon.VisionSet.Identity", id )
		ply:SetNW2Float( "WonderWeapon.VisionSet.StartTime", CurTime() )
		ply:SetNW2Float( "WonderWeapon.VisionSet.Duration", duration )
		ply:SetNW2Float( "WonderWeapon.VisionSet.FadeTime", fadetime )

		local lastVisionSet = id
		local lastDuration = duration
		local lastFadeTime = fadetime

		local finalTime = duration + fadetime
		if finalTime > 0 then
			local resetTimer = "WonderWeapon.VisionSet.Reset."..ply:EntIndex()
			if timer.Exists( resetTimer ) then
				timer.Remove( resetTimer )
			end

			timer.Create( resetTimer, finalTime, function()
				if not IsValid( ply ) then return end

				local currVisionSet = ply:GetNW2String("WonderWeapon.VisionSet.Identity", "")
				if currVisionSet ~= "" and currVisionSet == lastVisionSet then
					ply:SetNW2String( "WonderWeapon.VisionSet.Identity", "" )
					ply:SetNW2Float( "WonderWeapon.VisionSet.StartTime", 0 )
					ply:SetNW2Float( "WonderWeapon.VisionSet.Duration", 0 )
					ply:SetNW2Float( "WonderWeapon.VisionSet.FadeTime", 0 )
				end
			end )
		end
	end
end

//-------------------------------------------------------------
// Variables
//-------------------------------------------------------------

VisionSets.Types = VisionSets.Types or {}
local VisionSetTypes = VisionSets.Types

VisionSetTypes.DISTANCE = 1
VisionSetTypes.LINE_OF_SIGHT = 2
VisionSetTypes.VISIBILITY = 4

//-------------------------------------------------------------
// Entity Data
//-------------------------------------------------------------

WonderWeapons.VisionSetEntities = WonderWeapons.VisionSetEntities or {}

local VisionSetClasses = WonderWeapons.VisionSetEntities

function WonderWeapons.AddVisionSetEntity( class, data )
	VisionSetClasses[ class ] = data

	if data.LinkedClasses and istable( data.LinkedClasses ) then
		for _, linkedclass in pairs( data.LinkedClasses ) do
			VisionSetClasses[ linkedclass ] = data
		end
	end
end

function WonderWeapons.VisionSetEntityData( class )
	return VisionSetClasses[ class ] or nil
end

//-------------------------------------------------------------
// Clientside Only Below
//-------------------------------------------------------------

if SERVER then return end

//-------------------------------------------------------------
// Visuals
//-------------------------------------------------------------

local nzombies = engine.ActiveGamemode() == "nzombies"

local cl_screenvisuals = GetConVar("cl_tfa_bo3ww_screen_visuals")

local VisionTable = {
	["$pp_colour_addr"] = 0,
	["$pp_colour_addg"] = 0,
	["$pp_colour_addb"] = 0,
	["$pp_colour_brightness"] = 0.0,
	["$pp_colour_contrast"] = 1.0,
	["$pp_colour_colour"] = 1.0,
	["$pp_colour_mulr"] = 0,
	["$pp_colour_mulg"] = 0,
	["$pp_colour_mulb"] = 0,
}

// Credit to Rubat for vignette texture

local PixVis = {}
local VisionEntities = {}

local MatVignette, MatBlur
local DrawVignetteOverlay

local classData, visionData

local ColorMod = 0
local VignetteMod = 0
//local VignetteBlurMod = 0
local MotionMod = 0
local BlurMod = 0
local BlockSight = 0
local BlockVision = 0
local EntityClass

local function BuildMaterials()
	MatBlur = Material("pp/blurscreen")
	MatVignette = Material( "vgui/overlay/vignette.png" )
end

hook.Add("InitPostEntity", "TFA.BO3WW.FOX.VisionSet.BuildMaterials", function()
	BuildMaterials()
end)

// lua refresh
hook.Add("Think", "TFA.BO3WW.FOX.VisionSet.ReBuildMaterials", function()
	hook.Remove("Think", "TFA.BO3WW.FOX.VisionSet.ReBuildMaterials")
	BuildMaterials()
end)

hook.Add("OnEntityCreated", "TFA.BO3WW.FOX.VisionSet.EntityCreated", function( entity )
	if WonderWeapons.VisionSetEntityData( entity:GetClass() ) then
		timer.Simple(0, function()
			if not IsValid( entity ) or entity:IsMarkedForDeletion() then return end
			table.insert( VisionEntities, entity )
		end)
	end
end)

hook.Add("EntityRemoved", "TFA.BO3WW.FOX.VisionSet.EntityRemoved", function( entity, bFullUpdate )
	if ( bFullUpdate ) then return end

	if WonderWeapons.VisionSetEntityData( entity:GetClass() ) then
		for i = 1, #VisionEntities do
			if VisionEntities[i] == entity then
				if PixVis[entity] then
					PixVis[entity] = nil
				end

				table.remove(VisionEntities, i)
				break
			end
		end
	end
end)

hook.Add( "RenderScreenspaceEffects", "TFA.BO3WW.FOX.VisionSet.RenderScreenspaceEffects", function()
	local ply = LocalPlayer()
	if not IsValid( ply ) then return end

	if IsValid( ply:GetObserverTarget() ) then
		ply = ply:GetObserverTarget()
	end

	local position = GetViewEntity():GetPos()

	local DistanceRatio = 0
	local SightRatio = 0
	local VisibilityRatio = 0

	classData = nil
	visionData = nil

	EntityClass = nil
	ColorMod = 0
	VignetteMod = 0
	//VignetteBlurMod = 0
	MotionMod = 0
	BlurMod = 0

	if cl_screenvisuals and (cl_screenvisuals:GetInt() ~= 1 and ( cl_screenvisuals:GetInt() == 2 or cl_screenvisuals:GetInt() == 0 ) ) then
		return
	end

	local Upgraded = false

	for index, entity in pairs( VisionEntities ) do
		if not IsValid( entity )  then
			table.remove( VisionEntities, index )
			continue
		end

		local flDistance = position:Distance( entity:GetPos() )

		if flDistance > 1000 then
			table.remove( VisionEntities, index )
			continue
		end

		local class = entity:GetClass()

		local data = WonderWeapons.VisionSetEntityData( class )

		if not data.visionset then continue end

		classData = nil
		visionData = nil

		EntityClass = nil

		ColorMod = 1
		VignetteMod = 1
		//VignetteBlurMod = 1
		MotionMod = 1
		BlurMod = 1

		if flDistance <= data.range and entity.GetActivated and entity:GetActivated() then
			if not PixVis[ entity ] then
				PixVis[ entity ] = util.GetPixelVisibleHandle()

				entity:CallOnRemove("TFA.WonderWeapon.VisionSet.PixVisFix."..entity:EntIndex(), function( removed )
					if PixVis[ removed ] then
						PixVis[ removed ] = nil
					end
				end)

				continue
			end

			EntityClass = class

			local range = data.range
			local fade = data.fade

			BlockSight = math.Clamp( BlockSight + ( FrameTime() * ( ply:IsLineOfSightClear( entity:GetPos() ) and -1 or 1 ) ), 0, 1 )

			local vecMins, vecMaxs = entity:GetCollisionBounds()

			local flVisibility = util.PixelVisible( entity:GetPos(), math.max(vecMaxs[1], vecMaxs[2], 8), PixVis[ entity ] )
			if flVisibility > 0 then
				BlockVision = math.Clamp( Lerp( FrameTime() * 4, BlockVision, flVisibility ), 0, 1 )
			elseif BlockVision > 0 then
				BlockVision = math.Clamp( BlockVision - FrameTime() * 4, 0, 1 )
			end

			DistanceRatio = ( 1 - math.Clamp( ( flDistance - range + fade ) / fade, 0, 1 ) )

			SightRatio = ( 1 - math.Remap( BlockSight, 0, 1, 0, 0.8 ) )

			VisibilityRatio = ( 1 - BlockVision )

			local colorType = data.colormodType
			if colorType then
				if bit.band(colorType, VisionSetTypes.DISTANCE) ~= 0 then
					ColorMod = ColorMod * DistanceRatio
				end
				if bit.band(colorType, VisionSetTypes.LINE_OF_SIGHT) ~= 0 then
					ColorMod = ColorMod * SightRatio
				end
				if bit.band(colorType, VisionSetTypes.VISIBILITY) ~= 0 then
					ColorMod = ColorMod * VisibilityRatio
				end
			end

			local motionblurType = data.motionblurType
			if motionblurType then
				if bit.band(motionblurType, VisionSetTypes.DISTANCE) ~= 0 then
					local RealRatio = 1 - math.Clamp( flDistance / range, 0, 1 )
					MotionMod = MotionMod * RealRatio
				end
				if bit.band(motionblurType, VisionSetTypes.LINE_OF_SIGHT) ~= 0 then
					MotionMod = MotionMod * SightRatio
				end
				if bit.band(motionblurType, VisionSetTypes.VISIBILITY) ~= 0 then
					MotionMod = MotionMod * VisibilityRatio
				end
			end

			local vignetteType = data.vignetteType
			if vignetteType then
				if bit.band(vignetteType, VisionSetTypes.DISTANCE) ~= 0 then
					VignetteMod = VignetteMod * DistanceRatio
				end
				if bit.band(vignetteType, VisionSetTypes.LINE_OF_SIGHT) ~= 0 then
					VignetteMod = VignetteMod * SightRatio
				end
				if bit.band(vignetteType, VisionSetTypes.VISIBILITY) ~= 0 then
					VignetteMod = VignetteMod * VisibilityRatio
				end
			end

			/*local vignetteblurType = data.vignetteblurType
			if vignetteblurType then
				if bit.band(vignetteblurType, VisionSetTypes.DISTANCE) ~= 0 then
					VignetteBlurMod = VignetteBlurMod * DistanceRatio
				end
				if bit.band(vignetteblurType, VisionSetTypes.LINE_OF_SIGHT) ~= 0 then
					VignetteBlurMod = VignetteBlurMod * SightRatio
				end
				if bit.band(vignetteblurType, VisionSetTypes.VISIBILITY) ~= 0 then
					VignetteBlurMod = VignetteBlurMod * VisibilityRatio
				end
			end*/

			local blurType = data.visionblurType
			if blurType then
				if bit.band(blurType, VisionSetTypes.DISTANCE) ~= 0 then
					BlurMod = BlurMod * DistanceRatio
				end
				if bit.band(blurType, VisionSetTypes.LINE_OF_SIGHT) ~= 0 then
					BlurMod = BlurMod * SightRatio
				end
				if bit.band(blurType, VisionSetTypes.VISIBILITY) ~= 0 then
					BlurMod = BlurMod * VisibilityRatio
				end
			end

			classData = WonderWeapons.VisionSetEntityData( EntityClass )
			visionData = WonderWeapons.VisionSetData( classData.visionset )

			if ( classData.upgrade or visionData.upgrade ) and entity.GetUpgraded and entity:GetUpgraded() then
				Upgraded = true
			end
		end
	end

	local playerVisionSet = ply:GetNW2String( "WonderWeapon.VisionSet.Identity", "" )
	local playerVisionStart = ply:GetNW2Float( "WonderWeapon.VisionSet.StartTime", 0 )
	local playerVisionDuration = ply:GetNW2Float( "WonderWeapon.VisionSet.Duration", 0 )
	local playerVisionFade = ply:GetNW2Float( "WonderWeapon.VisionSet.FadeTime", 0 )

	if ( playerVisionSet ~= "" and playerVisionStart > 0 ) or EntityClass then
		if playerVisionSet ~= "" then
			local ct_ = CurTime()
			local visionEnd = ( playerVisionStart + playerVisionDuration )
			local visionFadeEnd = ( visionEnd + playerVisionFade )
			local visionRatio = ct_ > visionEnd and 1 or math.Clamp( ( visionFadeEnd - ct_ ) / playerVisionFade, 0, 1 )

			ColorMod = visionRatio
			VignetteMod = visionRatio
			//VignetteBlurMod = visionRatio
			MotionMod = visionRatio
			BlurMod = visionRatio

			classData = nil
			visionData = WonderWeapons.VisionSetData( playerVisionSet )
		elseif EntityClass then
			classData = WonderWeapons.VisionSetEntityData( EntityClass )
			visionData = WonderWeapons.VisionSetData( classData.visionset )
		end

		if visionData then
			VisionTable[ "$pp_colour_addr" ] = ColorMod * visionData.addred
			VisionTable[ "$pp_colour_addg" ] = ColorMod * visionData.addgreen
			VisionTable[ "$pp_colour_addb" ] = ColorMod * visionData.addblue

			if visionData.contrast then
				VisionTable[ "$pp_colour_contrast" ] = 1 - math.Clamp( ColorMod * visionData.contrast, 0, visionData.contrast )
			end

			if visionData.colour then
				VisionTable[ "$pp_colour_colour" ] = math.Clamp( ColorMod * visionData.colour, 1, visionData.colour )
			end

			if visionData.brightness then
				VisionTable[ "$pp_colour_brightness" ] = math.Clamp( ColorMod * visionData.brightness, 0, visionData.colour )
			end

			if Upgraded then
				VisionTable[ "$pp_colour_addr" ] = ColorMod * ( visionData.addred_upgraded or 0.25 )
				VisionTable[ "$pp_colour_addg" ] = ColorMod * ( visionData.addgreen_upgraded or 0 )
				VisionTable[ "$pp_colour_addb" ] = ColorMod * ( visionData.addblue_upgraded or 0 )
			end

			DrawColorModify( VisionTable )

			if ( ( classData and classData.visionblur ) or visionData.visionblur ) and BlurMod > 0 then
				if not MatBlur then
					BuildMaterials()
				else
					render.UpdateScreenEffectTexture()

					surface.SetMaterial( MatBlur )
					surface.SetDrawColor( 255, 255, 255, 255 )

					local passes = ( visionData.visionblurPasses or 3 )
					for i = 1, passes do
						MatBlur:SetFloat( "$blur", ( i / passes ) * ( BlurMod * ( visionData.visionblurAmount or 2 ) ) )
						MatBlur:Recompute()

						render.PushRenderTarget( render.GetScreenEffectTexture() )
						render.DrawScreenQuad( render.SetMaterial( MatBlur ) )
						render.PopRenderTarget()
						render.SetMaterial( MatBlur )
						render.DrawScreenQuad( render.SetMaterial( MatBlur ) )
					end
				end
			end

			if ( classData and classData.vignette ) or visionData.vignette then
				DrawVignetteOverlay( ( visionData.vignettepasses or 1), ( visionData.vignettealpha or 200 ) * VignetteMod )
			end
		end
	end
end )

hook.Add( "GetMotionBlurValues", "TFA.BO3WW.FOX.VisionSet.GetMotionBlurValues", function( x, y, fwd, spin )
	local ply = LocalPlayer()
	if IsValid(ply) and ( visionData and visionData.motionblur ) and ply:Alive() and ( !nzombies or ( nzombies and ply:GetNotDowned() ) ) then
		return x, y + ( ( visionData.motionblurVertical or 0) * MotionMod ), fwd + ( ( visionData.motionblurForward or 0.05 ) * MotionMod ), spin + ( ( visionData.motionblurRoll or 0) * MotionMod )
	end
end )

function DrawVignetteOverlay( passes, alpha )
	if not MatVignette then
		BuildMaterials()
	end

	surface.SetDrawColor( 255, 255, 255, ( alpha or 100 ) )
	surface.SetMaterial( MatVignette )

	for i=1, ( passes or 1 ) do
		surface.DrawTexturedRect( -1, -1, ScrW() + 2, ScrH() + 2 )
	end
end
