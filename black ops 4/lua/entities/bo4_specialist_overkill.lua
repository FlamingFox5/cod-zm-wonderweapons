
AddCSLuaFile()

ENT.Base = "tfa_ww_base"
ENT.PrintName = "Impact Grenade"

// Custom Settings

ENT.Impacted = false

// Default Settings

ENT.Delay = 3
ENT.Range = 200
ENT.Damage = 200
ENT.SpawnGravityEnabled = true

ENT.DefaultModel = "models/weapons/tfa_bo3/qed/w_maxgl_proj.mdl"

ENT.HullMaxs = Vector(2, 2, 2)
ENT.HullMins = ENT.HullMaxs:GetNegated()

ENT.ImpactDecal = "Scorch"

ENT.ImpactBubbles = false

ENT.SpriteTrailMaterial = "trails/smoke"
ENT.SpriteTrailResolution = 0.1
ENT.SpriteTrailLifetime = 0.5
ENT.SpriteTrailStartWidth = 8
ENT.SpriteTrailEndWidth = 0
ENT.SpriteTrailAdditive = true
ENT.SpriteTrailColor = Color(200, 200, 200, 200)
ENT.SpriteTrailAttachment = 1

// Explosion Settings

ENT.ExplosionBubbles = true
ENT.ExplosionBubblesSize = 240
ENT.ExplosionBubblesMagnitude = 4

ENT.MaxExplosionBlockingMass = 350
ENT.ExplosionDamageType = nzombies and DMG_BLAST or bit.bor(DMG_BLAST, DMG_AIRBOAT)
ENT.ExplosionHeadShotScale = 3 
ENT.ExplosionHitsOwner = true
ENT.ExplosionOwnerDamage = 45
ENT.ExplosionOwnerRange = 100

ENT.WaterBlockExplosions = false

ENT.ScreenShakeAmplitude = 10
ENT.ScreenShakeFrequency = 255
ENT.ScreenShakeDuration = 0.65
ENT.ScreenShakeRange = 400

ENT.ExplosionSound1 = "TFA_BO3_GRENADE.Dist"
ENT.ExplosionSound2 = "TFA_BO3_GRENADE.Exp"
ENT.ExplosionSound3 = "TFA_BO3_GRENADE.ExpClose"
ENT.ExplosionSound4 = "TFA_BO3_GRENADE.Flux"

// DLight Settings

ENT.Color = Color( 255, 160, 80 )

ENT.DLightBrightness = 0
ENT.DLightSize = 0

ENT.DLightFlashOnRemove = true

ENT.DLightFlashSize = 250
ENT.DLightFlashDecay = 2000
ENT.DLightFlashBrightness = 1

DEFINE_BASECLASS(ENT.Base)

local nzombies = engine.ActiveGamemode() == "nzombies"

function ENT:PhysicsCollide(data, phys)
	if self.Impacted then return end
	self.Impacted = true

	local trace = self:CollisionDataToTrace(data)
	local direction = data.OurOldVelocity:GetNormalized()
	local hitEntity = trace.Entity

	self:StoreCollisionEventData(data, trace)

	self:DoImpactEffect(trace)

	if trace.Hit and IsValid(hitEntity) and TFA.WonderWeapon.ShouldDamage(hitEntity, self:GetOwner(), self) then
		local myDamage = self:GetTrueDamage(hitEntity)

		local hitDamage = DamageInfo()
		hitDamage:SetDamage(myDamage)
		hitDamage:SetAttacker(IsValid(self:GetOwner()) and self:GetOwner() or self)
		hitDamage:SetInflictor(IsValid(self.Inflictor) and self.Inflictor or self)
		hitDamage:SetDamageType(nzombies and DMG_BLAST or bit.bor(DMG_BLAST, DMG_ALWAYSGIB))
		hitDamage:SetDamageForce(direction*math.random(9000,14000))
		hitDamage:SetDamagePosition(trace.HitPos)
		hitDamage:SetReportedPosition(trace.StartPos)

		if trace.HitGroup == HITGROUP_HEAD then
			hitDamage:SetDamage(myDamage*5)
		end

		hitEntity:DispatchTraceAttack(hitDamage, trace, direction)

		self:SendHitMarker(hitEntity, hitDamage, trace)
	end

	self:Explode(trace.HitPos - direction, self.Range, trace.HitNormal)

	self:PhysicsStop(phys) // always call last

	self:Remove()
end

function ENT:EntityCollide(trace)
	if self.Impacted then return end
	self.Impacted = true

	self:DoImpactEffect(trace)

	local direction = self:GetPhysicsObject():GetVelocity():GetNormalized()
	local hitEntity = trace.Entity

	local hitDamage = DamageInfo()
	hitDamage:SetDamage(self.Damage)
	hitDamage:SetAttacker(IsValid(self:GetOwner()) and self:GetOwner() or self)
	hitDamage:SetInflictor(IsValid(self.Inflictor) and self.Inflictor or self)
	hitDamage:SetDamageType(nzombies and DMG_BLAST or bit.bor(DMG_BLAST, DMG_ALWAYSGIB))
	hitDamage:SetDamageForce(direction*math.random(9000,14000))
	hitDamage:SetDamagePosition(trace.HitPos)
	hitDamage:SetReportedPosition(trace.StartPos)

	if trace.HitGroup == HITGROUP_HEAD then
		hitDamage:SetDamage(self.Damage*5)
	end

	hitEntity:DispatchTraceAttack(hitDamage, trace, trace.Normal)

	self:SendHitMarker(hitEntity, hitDamage, trace)

	self:Explode(trace.HitPos - trace.Normal, self.Range, trace.HitNormal)

	self:PhysicsStop() // always call last

	self:Remove()
end
