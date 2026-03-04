
AddCSLuaFile()

ENT.Base = "tfa_ww_base"
ENT.PrintName = "Shrink Ray"

// Custom Settings

ENT.Impacted = false

// Default Settings

ENT.Delay = 10

ENT.NoDrawNoShadow = true

ENT.HullMaxs = Vector(1, 1, 1)
ENT.HullMins = ENT.HullMaxs:GetNegated()

ENT.FluxSound = "TFA_BO3_JGB.Flux"
ENT.FluxSoundPaP = "TFA_BO3_JGB.FluxUpg"

ENT.TrailEffect = "bo3_jgb_trail"
ENT.TrailEffectPaP = "bo3_jgb_trail_2"
ENT.TrailAttachType = PATTACH_ABSORIGIN_FOLLOW
ENT.TrailAttachPoint = 1

ENT.ImpactDecal = "FadingScorch"

// Explosion Settings

ENT.ScreenShakeAmplitude = 5
ENT.ScreenShakeFrequency = 255
ENT.ScreenShakeDuration = 1
ENT.ScreenShakeRange = 200

// DLight Settings

ENT.Color = Color(255, 225, 30)
ENT.ColorPaP = Color(255, 80, 20)

ENT.DLightBrightness = 2
ENT.DLightDecay = 5000
ENT.DLightSize = 200

ENT.DLightFlashOnRemove = true

ENT.DLightFlashSize = 300
ENT.DLightFlashDecay = 1000
ENT.DLightFlashBrightness = 2

DEFINE_BASECLASS(ENT.Base)

local nzombies = engine.ActiveGamemode() == "nzombies"

function ENT:PhysicsCollide(data)
	if self.Impacted then return end
	self.Impacted = true

	local direction = data.OurOldVelocity:GetNormalized()
	local trace = self:CollisionDataToTrace(data)

	self:DoImpactEffect(trace)

	ParticleEffect(self:GetUpgraded() and "bo3_jgb_impact_2" or "bo3_jgb_impact", data.HitPos, data.HitNormal:Angle() - Angle(90,0,0))

	self:ScreenShake(data.HitPos)

	self:PhysicsStop(phys)

	self:Remove()
end
