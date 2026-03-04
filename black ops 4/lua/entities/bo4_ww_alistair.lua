
AddCSLuaFile()

ENT.Base = "tfa_ww_base"
ENT.PrintName = "Goo"

// Custom Settings

ENT.Impacted = false

// Default Settings

ENT.Delay = 10
ENT.Range = 100

ENT.NoDrawNoShadow = true

ENT.HullMaxs = Vector(1, 1, 1)
ENT.HullMins = ENT.HullMaxs:GetNegated()

ENT.ImpactDecal = "Dark"

ENT.ImpactBubbles = false // we explode on impact which has bubbles

ENT.TrailEffect = "bo4_alistairs_trail_base"
ENT.TrailEffectTier2 = "bo4_alistairs_trail_base_2"
ENT.TrailEffectTier3 = "bo4_alistairs_trail_base_3"

// Explosion Settings

ENT.ExplosionBubbles = true
ENT.ExplosionBubblesSize = 128
ENT.ExplosionBubblesMagnitude = 2

ENT.MaxExplosionBlockingMass = 350
ENT.ExplosionDamageType = nzombies and DMG_BLAST or bit.bor(DMG_BLAST, DMG_AIRBOAT)
ENT.ExplosionHeadShotScale = 7
ENT.ExplosionHitsOwner = false
ENT.ExplosionOwnerDamage = 50
ENT.ExplosionScreenShake = true

ENT.WaterBlockExplosions = false

ENT.ScreenShakeAmplitude = 5
ENT.ScreenShakeFrequency = 255
ENT.ScreenShakeDuration = 0.6
ENT.ScreenShakeRange = 240

ENT.ExplosionEffectAngleCorrection = Angle(-90,0,0)
ENT.ExplosionEffect = "bo4_alistairs_impact"
ENT.ExplosionEffectTier2 = "bo4_alistairs_impact_2"
ENT.ExplosionEffectTier3 = "bo4_alistairs_impact_3"

ENT.ExplosionSound = "TFA_BO4_ALISTAIR.Impact"
ENT.ExplosionSoundPaP = "TFA_BO4_ALISTAIR.Impact.Charged"

// DLight Settings

ENT.Color = Color(20, 200, 20, 255)
ENT.ColorTier2 = Color(0, 225, 127, 255)
ENT.ColorTier3 = Color(100, 75, 255, 255)

ENT.DLightBrightness = 1
ENT.DLightDecay = 2000
ENT.DLightSize = 200

ENT.DLightFlashOnRemove = true

ENT.DLightFlashSize = 250
ENT.DLightFlashDecay = 2000
ENT.DLightFlashBrightness = 2

DEFINE_BASECLASS(ENT.Base)

local nzombies = engine.ActiveGamemode() == "nzombies"

local ShouldDamage = TFA.WonderWeapon.ShouldDamage
local Impulse = TFA.WonderWeapon.CalculateImpulseForce

function ENT:SetupDataTables()
	BaseClass.SetupDataTables( self )

	self:NetworkVarTFA("Int", "Upgrade")
end

function ENT:PhysicsCollide(data, phys)
	if self.Impacted then return end
	self.Impacted = true

	local trace = self:CollisionDataToTrace(data)
	local direction = data.OurOldVelocity:GetNormalized()
	local hitEntity = trace.Entity

	self:StoreCollisionEventData(data, trace)

	self:DoImpactEffect(trace)

	if trace.Hit and IsValid(hitEntity) and ShouldDamage(hitEntity, self:GetOwner(), self) then
		local hitDamage = DamageInfo()
		hitDamage:SetDamage(self.Damage)
		hitDamage:SetAttacker(IsValid(self:GetOwner()) and self:GetOwner() or self)
		hitDamage:SetInflictor(IsValid(self.Inflictor) and self.Inflictor or self)
		hitDamage:SetDamageType(DMG_BLAST)
		hitDamage:SetDamageForce(direction * Impulse( hitEntity, 200 ))
		hitDamage:SetDamagePosition(trace.HitPos)
		hitDamage:SetReportedPosition(trace.StartPos)

		hitEntity:DispatchTraceAttack(hitDamage, trace, direction)

		self:SendHitMarker(hitEntity, hitDamage, trace)
	end

	self:Explode(data.HitPos)

	self:PhysicsStop( phys )

	self:Remove()
end

function ENT:EntityCollide(trace)
	if self.Impacted then return end
	self.Impacted = true

	local direction = trace.Normal
	local hitEntity = trace.Entity

	local phys = self:GetPhysicsObject()
	if IsValid( phys ) then
		direction = phys:GetVelocity():GetNormalized()
	end

	self:DoImpactEffect(trace)

	local hitCharacter = (hitEntity:IsNPC() or hitEntity:IsNextBot() or hitEntity:IsPlayer() or hitEntity:IsRagdoll())

	local hitDamage = DamageInfo()
	hitDamage:SetDamage(self.Damage)
	hitDamage:SetAttacker(IsValid(self:GetOwner()) and self:GetOwner() or self)
	hitDamage:SetInflictor(IsValid(self.Inflictor) and self.Inflictor or self)
	hitDamage:SetDamageType(DMG_BLAST)
	hitDamage:SetDamageForce(hitCharacter and direction * Impulse( hitEntity, 200 ) or vector_origin)
	hitDamage:SetDamagePosition(trace.HitPos)
	hitDamage:SetReportedPosition(trace.StartPos)

	hitEntity:DispatchTraceAttack(hitDamage, trace, direction)

	self:SendHitMarker(hitEntity, hitDamage, trace)

	self:Explode(trace.HitPos - direction)

	self:PhysicsStop()

	self:Remove()
	return false
end

function ENT:Initialize()
	local nTier = self:GetUpgrade()
	if nTier == 1 then
		self.Color = self.ColorTier2
		self.TrailEffect = self.TrailEffectTier2
		self.ExplosionSound = self.ExplosionSoundPaP
	elseif nTier == 2 then
		self.Color = self.ColorTier3
		self.TrailEffect = self.TrailEffectTier3
		self.ExplosionSound = self.ExplosionSoundPaP
	end

	BaseClass.Initialize(self)
end
