
AddCSLuaFile()

ENT.Base = "tfa_ww_base"
ENT.PrintName = "Ice Arrow"

// Custom Settings

ENT.Impacted = false

// Default Settings

ENT.Delay = 12
ENT.Range = 200

ENT.SpawnGravityEnabled = true
ENT.ShouldUseCollisionModel = true

ENT.HullMaxs = Vector(1, 1, 1)
ENT.HullMins = ENT.HullMaxs:GetNegated()

ENT.FluxSound = "TFA_BO3_STAFF_ICE.Flux"

ENT.TrailEffect = "bo3_icestaff_trail"
ENT.TrailAttachType = PATTACH_ABSORIGIN_FOLLOW
ENT.TrailAttachPoint = 1

ENT.ImpactDecal = "snow_grenade"

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

	self:NetworkVarTFA("Bool", "Charged")
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
		hitDamage:SetDamageType(nZSTORM and DMG_VEHICLE or bit.bor(DMG_SONIC, DMG_PREVENT_PHYSICS_FORCE))
		hitDamage:SetDamageForce(direction)
		hitDamage:SetDamagePosition(trace.HitPos)
		hitDamage:SetReportedPosition(trace.StartPos)

		if trace.HitGroup == HITGROUP_HEAD then
			hitDamage:SetDamage(self.Damage*4)
		end

		hitEntity:DispatchTraceAttack(hitDamage, trace, direction)

		self:SendHitMarker(hitEntity, hitDamage, trace)
	end

	self:DoImpactEffect(trace)

	self:PhysicsStop(phys)

	self:Remove()
end

function ENT:EntityCollide(trace)
	if self.Impacted then return end
	self.Impacted = true

	self:DoImpactEffect(trace)

	local hitDamage = DamageInfo()
	hitDamage:SetDamage(self.Damage)
	hitDamage:SetAttacker(IsValid(self:GetOwner()) and self:GetOwner() or self)
	hitDamage:SetInflictor(IsValid(self.Inflictor) and self.Inflictor or self)
	hitDamage:SetDamageType(nZSTORM and DMG_VEHICLE or bit.bor(DMG_SONIC, DMG_PREVENT_PHYSICS_FORCE))
	hitDamage:SetDamageForce(trace.Normal*math.random(9000,12000))
	hitDamage:SetDamagePosition(trace.HitPos)
	hitDamage:SetReportedPosition(trace.StartPos)

	if trace.HitGroup == HITGROUP_HEAD then
		hitDamage:SetDamage(self.Damage*4)
	end

	hitEntity:DispatchTraceAttack(hitDamage, trace, trace.Normal)

	self:SendHitMarker(hitEntity, hitDamage, trace)

	self:PhysicsStop()

	self:Remove()
	return false
end

function ENT:Initialize()
	BaseClass.Initialize(self)
end

function ENT:Think()
	return BaseClass.Think(self)
end
