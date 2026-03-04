
AddCSLuaFile()

ENT.Base = "tfa_ww_base"
ENT.PrintName = "Raygun"

// Custom Settings

ENT.Impacted = false

// Default Settings

ENT.Delay = 10
ENT.Range = 100

ENT.NoDrawNoShadow = true

ENT.HullMaxs = Vector(2, 2, 2)
ENT.HullMins = ENT.HullMaxs:GetNegated()

ENT.FluxSound = "TFA_BO3_RAYGUN.Flux"

ENT.TrailSound = "TFA_BO3_RAYGUN.Loop"
ENT.TrailEffect = "bo3_raygun_trail"
ENT.TrailEffectPaP = "bo3_raygun_trail_2"
ENT.TrailAttachType = PATTACH_ABSORIGIN_FOLLOW
ENT.TrailAttachPoint = 1

ENT.ImpactDecal = "FadingScorch"

ENT.ImpactBubbles = false // we explode on impact which has bubbles

// Explosion Settings

ENT.ExplosionBubbles = true
ENT.ExplosionBubblesSize = 128
ENT.ExplosionBubblesMagnitude = 2

ENT.ExplosionMaxBlockingMass = 350
ENT.ExplosionDamageType = nzombies and DMG_BLAST or bit.bor(DMG_BLAST, DMG_AIRBOAT)
ENT.ExplosionHeadShotScale = 7
ENT.ExplosionHitsOwner = true
ENT.ExplosionOwnerDamage = 50
ENT.ExplosionScreenShake = true

ENT.WaterBlockExplosions = false

ENT.ScreenShakeAmplitude = 5
ENT.ScreenShakeFrequency = 255
ENT.ScreenShakeDuration = 0.8
ENT.ScreenShakeRange = 240

ENT.ExplosionEffectAngleCorrection = Angle(-90,0,0)
ENT.ExplosionEffect = "bo3_raygun_impact"
ENT.ExplosionEffectPaP = "bo3_raygun_impact_2"

ENT.ExplosionSound1 = "TFA_BO3_RAYGUN.Exp"
ENT.ExplosionSound2 = "TFA_BO3_RAYGUN.ExpCl"

// DLight Settings

ENT.ColorPaP = Color(255, 40, 20)
ENT.Color = Color(50, 235, 30)

ENT.DLightBrightness = 1
ENT.DLightDecay = 2000
ENT.DLightSize = 200

ENT.DLightFlashOnRemove = true

ENT.DLightFlashSize = 250
ENT.DLightFlashDecay = 2000
ENT.DLightFlashBrightness = 2

DEFINE_BASECLASS(ENT.Base)

local nzombies = engine.ActiveGamemode() == "nzombies"

function ENT:PhysicsCollide(data, phys)
	if self.Impacted then return end
	self.Impacted = true

	self:StopSound( self.TrailSound )

	local trace = self:CollisionDataToTrace(data)
	local direction = data.OurOldVelocity:GetNormalized()
	local hitEntity = trace.Entity

	self:DoImpactEffect(trace)

	if trace.Hit and IsValid(hitEntity) and TFA.WonderWeapon.ShouldDamage(hitEntity, self:GetOwner(), self) then
		local hitDamage = DamageInfo()
		hitDamage:SetDamage(self.Damage)
		hitDamage:SetAttacker(IsValid(self:GetOwner()) and self:GetOwner() or self)
		hitDamage:SetInflictor(IsValid(self.Inflictor) and self.Inflictor or self)
		hitDamage:SetDamageType(nzombies and DMG_BLAST_SURFACE or bit.bor(DMG_BLAST_SURFACE, DMG_ALWAYSGIB))
		hitDamage:SetDamageForce(direction * 2000)
		hitDamage:SetDamagePosition(trace.HitPos)
		hitDamage:SetReportedPosition(trace.StartPos)

		if trace.HitGroup == HITGROUP_HEAD then
			hitDamage:SetDamage(self.Damage * 7)
		end

		local nLastHealth = hitEntity:Health()

		hitEntity:DispatchTraceAttack(hitDamage, trace, direction)

		if hitEntity:Health() < nLastHealth then
			self:SendHitMarker(hitEntity, hitDamage, trace)
		end
	end

	self:Explode(trace.HitPos - direction, self.Range, trace.HitNormal)

	self:CreateGlowSprite(-0.4, self.Color, 255, 0.4, nil, nil, nil, self:GetHitPos())

	self:PhysicsStop(phys) // always call last

	self:Remove()
end

function ENT:EntityCollide(trace)
	if self.Impacted then return end
	self.Impacted = true

	self:StopSound(self.TrailSound)

	local hitEntity = trace.Entity
	local direction = trace.Normal

	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		direction = phys:GetVelocity():GetNormalized()
	end

	self:DoImpactEffect(trace)

	local hitDamage = DamageInfo()
	hitDamage:SetDamage(self.Damage)
	hitDamage:SetAttacker(IsValid(self:GetOwner()) and self:GetOwner() or self)
	hitDamage:SetInflictor(IsValid(self.Inflictor) and self.Inflictor or self)
	hitDamage:SetDamageType(nzombies and DMG_BLAST_SURFACE or bit.bor(DMG_BLAST_SURFACE, DMG_ALWAYSGIB))
	hitDamage:SetDamageForce(direction*math.random(6000,12000))
	hitDamage:SetDamagePosition(trace.HitPos)
	hitDamage:SetReportedPosition(trace.StartPos)

	if trace.HitGroup == HITGROUP_HEAD then
		hitDamage:SetDamage(self.Damage*7)
	end

	local nLastHealth = hitEntity:Health()

	hitEntity:DispatchTraceAttack(hitDamage, trace, trace.Normal)

	if hitEntity:Health() < nLastHealth then
		self:SendHitMarker(hitEntity, hitDamage, trace)
	end

	self:Explode(trace.HitPos - trace.Normal, self.Range, trace.HitNormal)

	self:CreateGlowSprite(-0.4, self.Color, 255, 0.4, nil, nil, nil, trace.HitPos)

	self:PhysicsStop() // always call last

	self:Remove()
	return false
end
