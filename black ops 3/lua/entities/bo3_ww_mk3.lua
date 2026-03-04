
AddCSLuaFile()

ENT.Base = "tfa_ww_base"
ENT.PrintName = "Raygun Mk3"

// Custom Settings

ENT.Impacted = false

ENT.ImpactSound = "TFA_BO3_MK2.Impact"

// Default Settings

ENT.Delay = 10

ENT.NoDrawNoShadow = true

ENT.HullMaxs = Vector(1, 1, 1)
ENT.HullMins = ENT.HullMaxs:GetNegated()

ENT.TrailEffect = "bo3_mk2_trail"
ENT.TrailEffectPaP = "bo3_mk2_trail_2"
ENT.TrailAttachType = PATTACH_ABSORIGIN_FOLLOW
ENT.TrailAttachPoint = 1

ENT.ImpactDecal = "FadingScorch"

ENT.ImpactBubbles = true
ENT.ImpactBubblesSize = 64
ENT.ImpactBubblesMagnitude = 1

// Explosion Settings

ENT.ScreenShakeAmplitude = 5
ENT.ScreenShakeFrequency = 255
ENT.ScreenShakeDuration = 0.6
ENT.ScreenShakeRange = 96

// DLight Settings

ENT.Color = Color(90, 255, 10)
ENT.ColorPaP = Color(255, 40, 10)

ENT.DLightBrightness = 1
ENT.DLightDecay = 2000
ENT.DLightSize = 200

ENT.DLightFlashOnRemove = true

ENT.DLightFlashSize = 200
ENT.DLightFlashDecay = 2000
ENT.DLightFlashBrightness = 2

DEFINE_BASECLASS(ENT.Base)

local nzombies = engine.ActiveGamemode() == "nzombies"

function ENT:SetupDataTables()
	self:NetworkVar("Bool", 0, "Upgraded")
	self:NetworkVar("Vector", 0, "HitPos")
end

function ENT:PhysicsCollide(data, phys)
	if self.Impacted then return end
	self.Impacted = true

	sound.Play(self.ImpactSound, data.HitPos)

	local trace = self:CollisionDataToTrace(data)
	local direction = data.OurOldVelocity:GetNormalized()
	local hitEntity = trace.Entity

	self:DoImpactEffect(trace)

	if trace.Hit and IsValid(hitEntity) and TFA.WonderWeapon.ShouldDamage(hitEntity, self:GetOwner(), self) then
		local hitDamage = DamageInfo()
		hitDamage:SetDamage(self.Damage)
		hitDamage:SetAttacker(IsValid(self:GetOwner()) and self:GetOwner() or self)
		hitDamage:SetInflictor(IsValid(self.Inflictor) and self.Inflictor or self)
		hitDamage:SetDamageType(nzombies and DMG_BULLET or DMG_ENERGYBEAM)
		hitDamage:SetDamageForce(direction*2000)
		hitDamage:SetDamagePosition(trace.HitPos)
		hitDamage:SetReportedPosition(trace.StartPos)

		hitEntity:DispatchTraceAttack(hitDamage, trace, direction)

		self:SendHitMarker(hitEntity, hitDamage, trace)
	end

	self:ScreenShake(data.HitPos)

	ParticleEffect(self:GetUpgraded() and "bo3_mk3_impact_2" or "bo3_mk3_impact", data.HitPos, data.HitNormal:Angle() - Angle(90,0,0))

	self:PhysicsStop(phys)

	self:Remove()
end

function ENT:EntityCollide(trace)
	if self.Impacted then return end

	sound.Play(self.ImpactSound, trace.HitPos)

	self:DoImpactEffect(trace)

	local hitEntity = trace.Entity
	local direction = trace.Normal

	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		direction = phys:GetVelocity():GetNormalized()
	end

	local hitDamage = DamageInfo()
	hitDamage:SetDamage(self.Damage)
	hitDamage:SetAttacker(IsValid(self:GetOwner()) and self:GetOwner() or self)
	hitDamage:SetInflictor(IsValid(self.Inflictor) and self.Inflictor or self)
	hitDamage:SetDamageType(nzombies and DMG_BULLET or DMG_ENERGYBEAM)
	hitDamage:SetDamageForce(direction*math.random(2000,6000))
	hitDamage:SetDamagePosition(trace.HitPos)
	hitDamage:SetReportedPosition(trace.StartPos)

	if trace.HitGroup == HITGROUP_HEAD then
		hitDamage:SetDamage(self.Damage*4)
	end

	hitEntity:DispatchTraceAttack(hitDamage, trace, trace.Normal)

	self:SendHitMarker(hitEntity, hitDamage, trace)

	ParticleEffect(self:GetUpgraded() and "bo3_mk3_hitzomb_2" or "bo3_mk3_hitzomb", trace.HitPos, trace.HitNormal:Angle())
end
