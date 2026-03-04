
AddCSLuaFile()

ENT.Base = "tfa_ww_base"
ENT.PrintName = "Microwave"

// Custom Settings

ENT.Impacted = false

// Default Settings

ENT.Delay = 6
ENT.Range = 240

ENT.NoDrawNoShadow = true

ENT.HullMaxs = Vector(1, 1, 1)
ENT.HullMins = ENT.HullMaxs:GetNegated()

ENT.TrailEffect = "bo3_wavegun_trail"
ENT.TrailEffectPaP = "bo3_zapgun_right_beam"
ENT.TrailAttachType = PATTACH_ABSORIGIN_FOLLOW
ENT.TrailAttachPoint = 1

ENT.ImpactDecal = "FadingScorch"

// Explosion Settings

ENT.ScreenShakeAmplitude = 6
ENT.ScreenShakeFrequency = 255
ENT.ScreenShakeDuration = 0.5
ENT.ScreenShakeRange = 300

// DLight Settings

ENT.Color = Color(140, 40, 255)
ENT.ColorPaP = Color(255, 90, 100)

ENT.DLightBrightness = 2
ENT.DLightDecay = 2000
ENT.DLightSize = 200

ENT.DLightFlashOnRemove = true

ENT.DLightFlashSize = 250
ENT.DLightFlashDecay = 1500
ENT.DLightFlashBrightness = 2

DEFINE_BASECLASS(ENT.Base)

local nzombies = engine.ActiveGamemode() == "nzombies"
local dlight_cvar = GetConVar("cl_tfa_fx_wonderweapon_dlights")
local SinglePlayer = game.SinglePlayer()

function ENT:PhysicsCollide(data, phys)
	if self.Impacted then return end
	self.Impacted = true

	local trace = self:CollisionDataToTrace(data)
	local hitEntity = trace.Entity
	local direction = data.OurOldVelocity:GetNormalized()

	if IsValid(hitEntity) and hitEntity:GetClass() == "func_button" then
		local damage = DamageInfo()
		damage:SetAttacker(IsValid(self:GetOwner()) and self:GetOwner() or self)
		damage:SetInflictor(self)
		damage:SetDamage(hitEntity:Health())
		damage:SetDamageType(DMG_ENERGYBEAM)

		hitEntity:TakeDamageInfo(damage)
	end

	self:DoImpactEffect(trace)

	if IsValid(hitEntity) and TFA.WonderWeapon.ShouldDamage(hitEntity, self:GetOwner(), self) then
		local hitDamage = DamageInfo()
		hitDamage:SetDamage(10)
		hitDamage:SetAttacker(IsValid(self:GetOwner()) and self:GetOwner() or self)
		hitDamage:SetInflictor(IsValid(self.Inflictor) and self.Inflictor or self)
		hitDamage:SetDamageType(bit.bor(DMG_DISSOLVE, DMG_ENERGYBEAM))
		hitDamage:SetDamageForce(direction*2000)
		hitDamage:SetDamagePosition(trace.HitPos)
		hitDamage:SetReportedPosition(trace.StartPos)

		hitEntity:DispatchTraceAttack(hitDamage, trace, direction)

		self:SendHitMarker(hitEntity, hitDamage, trace)
	end

	sound.Play("TFA_BO3_ZAPGUN.Flux", data.HitPos)

	ParticleEffect(self:GetUpgraded() and "bo3_zapgun_impact_right" or "bo3_zapgun_impact_pap", data.HitPos, data.HitNormal:Angle() - Angle(90,0,0))

	self:ScreenShake(data.HitPos)

	self:PhysicsStop(phys)

	self:Remove()
end

function ENT:EntityCollide(trace)
	if self.Impacted then return end

	self:DoImpactEffect(trace)

	local hitEntity = trace.Entity
	if ( hitEntity:IsNPC() or hitEntity:IsNextBot() or hitEntity:IsPlayer() ) then
		ParticleEffect(self:GetUpgraded() and "bo3_zapgun_impact_right" or "bo3_zapgun_impact_pap", trace.HitPos, trace.HitNormal:Angle() - Angle(90,0,0))
	end
end
