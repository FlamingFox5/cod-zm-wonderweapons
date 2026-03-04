
AddCSLuaFile()

ENT.Base = "tfa_ww_base"
ENT.PrintName = "Cursed Arrow"

// Custom Settings

ENT.Impacted = false

// Default Settings

ENT.Delay = 12
ENT.Range = 200

ENT.SpawnGravityEnabled = true
ENT.ShouldUseCollisionModel = true

ENT.HullMaxs = Vector(1, 1, 1)
ENT.HullMins = ENT.HullMaxs:GetNegated()

ENT.TrailEffect = "bo3_zmbbow_trail"
ENT.TrailAttachType = PATTACH_ABSORIGIN_FOLLOW
ENT.TrailAttachPoint = 1

ENT.ImpactDecal = "Scorch"

ENT.ExplodeOnKilltimeEnd = true

// Explosion Settings

ENT.ExplosionBubblesSize = 256
ENT.ExplosionBubblesMagnitude = 6

ENT.ExplosionMaxBlockingMass = 350
ENT.ExplosionDamageType = nzombies and DMG_BLAST or bit.bor(DMG_BLAST, DMG_AIRBOAT)
ENT.ExplosionHeadShotScale = 7
ENT.ExplosionHitsOwner = false
ENT.ExplosionOwnerDamage = 50
ENT.ExplosionScreenShake = true

ENT.WaterBlockExplosions = true

ENT.ScreenShakeAmplitude = 5
ENT.ScreenShakeFrequency = 255
ENT.ScreenShakeDuration = 0.8
ENT.ScreenShakeRange = 240

ENT.ExplosionEffectAngleCorrection = Angle(-90,0,0)
ENT.ExplosionEffect = "bo3_zmbbow_impact_small"
ENT.ExplosionEffectCharged = "bo3_zmbbow_impact_big"

ENT.ExplosionSound1 = "TFA_BO3_ZMBBOW.Impact"
ENT.ExplosionSound2 = "TFA_BO3_ZMBBOW.Explode"

// DLight Settings

ENT.Color = Color(255, 220, 40, 255)

ENT.DLightBrightness = 1
ENT.DLightDecay = 2000
ENT.DLightSize = 250

DEFINE_BASECLASS(ENT.Base)

local nzombies = engine.ActiveGamemode() == "nzombies"
local dlight_cvar = GetConVar("cl_tfa_fx_wonderweapon_dlights")
local SinglePlayer = game.SinglePlayer()

function ENT:SetupDataTables()
	BaseClass.SetupDataTables(self)

	self:NetworkVarTFA("Float", "Mult")
	self:NetworkVarTFA("Float", "Charge")
end

function ENT:PhysicsCollide(data, phys)
	if self.Impacted then return end
	self.Impacted = true

	self.HitPos = data.HitPos
	self.HitNormal = data.HitNormal

	self:SetHitPos(self.HitPos)

	local trace = self:CollisionDataToTrace(data)
	local direction = data.OurOldVelocity:GetNormalized()
	local hitEntity = trace.Entity

	if trace.Hit and IsValid(hitEntity) and TFA.WonderWeapon.ShouldDamage(hitEntity, self:GetOwner(), self) then
		local hitDamage = DamageInfo()
		hitDamage:SetDamage(self.Damage)
		hitDamage:SetAttacker(IsValid(self:GetOwner()) and self:GetOwner() or self)
		hitDamage:SetInflictor(IsValid(self.Inflictor) and self.Inflictor or self)
		hitDamage:SetDamageType(nzombies and DMG_BLAST or bit.bor(DMG_BLAST_SURFACE, DMG_ALWAYSGIB))
		hitDamage:SetDamageForce(direction*math.random(9000,12000))
		hitDamage:SetDamagePosition(trace.HitPos)
		hitDamage:SetReportedPosition(trace.StartPos)

		hitEntity:DispatchTraceAttack(hitDamage, trace, direction)

		self:SendHitMarker(hitEntity, hitDamage, trace)
	end

	self:DoImpactEffect(trace)

	self:Explode(data.HitPos)

	self:PhysicsStop(phys)

	self:Remove()
end

function ENT:EntityCollide(trace)
	if self.Impacted then return end
	self.Impacted = true

	self:DoImpactEffect(trace)

	local hitEntity = trace.Entity
	if not (hitEntity:IsPlayer() or hitEntity:IsNPC() or hitEntity:IsNextBot()) then
		util.Decal("Scorch", trace.HitPos, trace.HitPos + trace.Normal*4)
	end

	local hitDamage = DamageInfo()
	hitDamage:SetDamage(self.Damage)
	hitDamage:SetAttacker(IsValid(self:GetOwner()) and self:GetOwner() or self)
	hitDamage:SetInflictor(IsValid(self.Inflictor) and self.Inflictor or self)
	hitDamage:SetDamageType(nzombies and DMG_BLAST or bit.bor(DMG_BLAST_SURFACE, DMG_ALWAYSGIB))
	hitDamage:SetDamageForce(trace.Normal*math.random(9000,12000))
	hitDamage:SetDamagePosition(trace.HitPos)
	hitDamage:SetReportedPosition(trace.StartPos)

	if trace.HitGroup == HITGROUP_HEAD then
		hitDamage:SetDamage(self.Damage*7)
	end

	hitEntity:DispatchTraceAttack(hitDamage, trace, trace.Normal)

	self:SendHitMarker(hitEntity, hitDamage, trace)

	self:Explode(trace.HitPos)

	self:PhysicsStop()

	self:Remove()
	return false
end

function ENT:Initialize()
	if self:GetCharge() >= 1 then
		self.ExplosionEffect = self.ExplosionEffectCharged
		self.ExplosionSound3 = "TFA_BO3_ZMBBOW.ExplodeSwt"
	end

	BaseClass.Initialize(self)

	if self:GetCharge() >= 1 then
		self:EmitSound("TFA_BO3_ZMBBOW.FullCharge")
	end

	self.Range = self.Range * self:GetMult()
	self.DLightSize = self.Range + (50*self:GetMult())
end

function ENT:Think()
	local phys = self:GetPhysicsObject()
	if IsValid( phys ) then
		local vecVelocity = phys:GetVelocity()

		phys:SetAngles(vecVelocity:Angle())
		phys:SetVelocity(vecVelocity)
	end

	return BaseClass.Think(self)
end

function ENT:PreExplosionDamage( hitEntity, explosionTrace, damageinfo )
	if nzombies and (hitEntity.NZBossType or string.find(hitEntity:GetClass(), "zombie_boss")) then
		damageinfo:SetDamage(math.max(self.Damage, hitEntity:GetMaxHealth() / 14))
	end
end

function ENT:OnRemove()
	BaseClass.OnRemove(self)

	if CLIENT and dlight_cvar:GetBool() and DynamicLight then
		self.DLight = self.DLight or DynamicLight(self:EntIndex())
		if (self.DLight) then
			self.DLight.pos = !self:GetHitPos():IsZero() and self:GetHitPos() or self:GetPos()
			self.DLight.r = self.Color.r
			self.DLight.g = self.Color.g
			self.DLight.b = self.Color.b
			self.DLight.brightness = 1 + (2*self:GetMult())
			self.DLight.Decay = 2000 - (500*self:GetMult())
			self.DLight.Size = 200 + (150*self:GetMult())
			self.DLight.DieTime = CurTime() + (0.5 + (0.5*self:GetMult()))
		end
	end
end