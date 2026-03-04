
AddCSLuaFile()

ENT.Base = "tfa_ww_base"
ENT.PrintName = "Interdimensional Portal"

// Custom Settings

ENT.PortalStart = "TFA_BO3_IDGUN.Portal.Start"
ENT.PortalLoop = "TFA_BO3_IDGUN.Portal.Loop"
ENT.WindLoop = "TFA_BO3_IDGUN.Portal.Wind"

ENT.Life = 5
ENT.LifePaP = 8

ENT.SuccRange = 350

ENT.PortalEffect = "bo3_idgun_portal"
ENT.PortalEffectPaP = "bo3_idgun_portal_2"

// Default Settings

ENT.Delay = 8
ENT.Range = 512

ENT.NoDrawNoShadow = true

ENT.HullMaxs = Vector(4, 4, 4)
ENT.HullMins = ENT.HullMaxs:GetNegated()

ENT.TrailEffect = "bo3_idgun_trail"
ENT.TrailEffectPaP = "bo3_idgun_trail_2"
ENT.TrailAttachType = PATTACH_ABSORIGIN_FOLLOW
ENT.TrailAttachPoint = 1

ENT.ExplosionEffectAngleCorrection = Angle(0,0,0)
ENT.ExplosionEffect = "bo3_idgun_implode"
ENT.ExplosionEffectPaP = "bo3_idgun_implode_2"

ENT.ImpactDecal = "Scorch"

// Explosion Settings

ENT.ExplodeOnKilltimeEnd = true
ENT.ExplosionDamageType = nzombies and DMG_DISSOLVE or bit.bor(DMG_DISSOLVE, DMG_PREVENT_PHYSICS_FORCE)

ENT.ExplosionMaxBlockingMass = 2500

ENT.ScreenShakeAmplitude = 5
ENT.ScreenShakeFrequency = 255
ENT.ScreenShakeDuration = 1
ENT.ScreenShakeRange = 1024

ENT.ExplosionSound1 = "TFA_BO3_IDGUN.Portal.End"
ENT.ExplosionSound2 = "TFA_BO3_IDGUN.Portal.Expl"

// DLight Settings

ENT.Color = Color(185, 20, 255, 255)
ENT.ColorPaP = Color(255, 90, 60, 255)

ENT.DLightBrightness = 1
ENT.DLightDecay = 2000
ENT.DLightSize = 350

ENT.DLightFlashOnRemove = true

ENT.DLightFlashSize = 500
ENT.DLightFlashDecay = 2500
ENT.DLightFlashBrightness = 3

DEFINE_BASECLASS(ENT.Base)

local nzombies = engine.ActiveGamemode() == "nzombies"

local HasStatus = TFA.WonderWeapon.HasStatus
local GiveStatus = TFA.WonderWeapon.GiveStatus
local ShouldDamage = TFA.WonderWeapon.ShouldDamage

function ENT:SetupDataTables()
	BaseClass.SetupDataTables(self)

	self:NetworkVarTFA("Bool", "Activated")
end

function ENT:Draw( ... )
	BaseClass.Draw( self, ... )

	self:AddDrawCallParticle(self:GetUpgraded() and self.PortalEffectPaP or self.PortalEffect, PATTACH_ABSORIGIN_FOLLOW, 1, self:GetActivated())
	self:AddDrawCallParticle("bo3_idgun_portal_bubbles", PATTACH_ABSORIGIN_FOLLOW, 1, self:GetActivated() and self:WaterLevel() > 2)
end

if SERVER then
	function ENT:GravGunPickupAllowed()
		return not self:GetActivated()
	end
end

function ENT:GravGunPunt()
	return not self:GetActivated()
end

function ENT:PhysicsCollide(data, phys)
	if self:GetActivated() then return end
	self:SetActivated(true)

	local trace = self:CollisionDataToTrace(data)
	local hitEntity = trace.Entity
	local direction = data.OurOldVelocity:GetNormalized()

	if trace.Hit and IsValid(hitEntity) and ShouldDamage(hitEntity, self:GetOwner(), self) then
		local hitDamage = DamageInfo()
		hitDamage:SetDamage(hitEntity:Health() + 666)
		hitDamage:SetAttacker(IsValid(self:GetOwner()) and self:GetOwner() or self)
		hitDamage:SetInflictor(IsValid(self.Inflictor) and self.Inflictor or self)
		hitDamage:SetDamageType(DMG_DISSOLVE)
		hitDamage:SetDamageForce(direction*2000)
		hitDamage:SetDamagePosition(trace.HitPos)
		hitDamage:SetReportedPosition(trace.StartPos)

		hitEntity:DispatchTraceAttack(hitDamage, trace, direction)

		self:SendHitMarker(hitEntity, hitDamage, trace)
	end

	self:DoImpactEffect(trace)

	self:ScreenShake(data.HitPos)

	if data.HitNormal:Dot(Vector(0, 0, -1)) > 0.6 then
		timer.Simple(0, function()
			if not IsValid(self) then return end
			self:SetPos(data.HitPos + self:GetUp()*64)
			self:SetMoveType(MOVETYPE_NONE)
			self:SetAngles(Angle(0,90,0))
		end)
	end

	self:Portal()

	self:PhysicsStop(phys) // always call last
end

function ENT:EntityCollide(trace)
	//if self:GetActivated() then return end

	local hitEntity = trace.Entity
	if HasStatus( hitEntity, "BO3_Portal_Pull" ) then return end

	if hitEntity:IsNPC() or hitEntity:IsNextBot() or hitEntity:IsPlayer() then
		self:DoImpactEffect(trace)

		local hitDamage = DamageInfo()
		hitDamage:SetDamage(self.Damage)
		hitDamage:SetAttacker(IsValid(self:GetOwner()) and self:GetOwner() or self)
		hitDamage:SetInflictor(IsValid(self.Inflictor) and self.Inflictor or self)
		hitDamage:SetDamageType(nzombies and DMG_DISSOLVE or bit.bor(DMG_PREVENT_PHYSICS_FORCE, DMG_DISSOLVE))
		hitDamage:SetDamageForce(trace.Normal*math.random(6000,12000))
		hitDamage:SetDamagePosition(trace.HitPos)
		hitDamage:SetReportedPosition(trace.StartPos)

		hitEntity:DispatchTraceAttack(hitDamage, trace, trace.Normal)

		self:SendHitMarker(hitEntity, hitDamage, trace)
	end
end

function ENT:Portal()
	self.BlockCollisionTrace = true

	self:StopParticles()

	self.killtime = CurTime() + self.Life

	self:EmitSound("TFA_BO3_IDGUN.Portal.Start")

	self:EmitSound(self.PortalLoop)
	self:EmitSound(self.WindLoop)

	if not self:GetActivated() then
		self:SetActivated(true)
	end
end

function ENT:Initialize(...)
	BaseClass.Initialize(self, ...)

	if self:GetUpgraded() then
		self.Life = self.LifePaP
	end
end

function ENT:Think()
	if SERVER and self:GetActivated() then
		util.ScreenShake( self:GetPos(), 8, 255, 0.2, self.SuccRange )

		for k, v in pairs( ents.FindInSphere( self:GetPos(), self.SuccRange ) ) do
			if v:IsNPC() or v:IsNextBot() then
				if !ShouldDamage( v, ply, self ) then continue end

				if ( v.NZBossType or v.IsMooBossZombie or v.IsMooMiniBoss ) then continue end

				if HasStatus( v, "BO3_Portal_Pull" ) then continue end

				if not v:VisibleVec( self:GetPos() ) then continue end

				GiveStatus( v, "BO3_Portal_Pull", 2, self:GetOwner(), self.Inflictor, self:GetPos() - v:OBBCenter() )
			end
		end
	end

	return BaseClass.Think(self)
end

function ENT:Explode(...)
	self:StopParticles()

	BaseClass.Explode(self, ...)
end

function ENT:PreExplosionDamage( hitEntity, explosionTrace, damageinfo )
	damageinfo:SetDamage(hitEntity:Health() + 666)

	if nzombies and ( hitEntity.NZBossType or hitEntity.IsMooBossZombie or hitEntity.IsMooMiniBoss ) then
		damageinfo:SetDamage( math.max( 2000, hitEntity:GetMaxHealth() / 8 ) )
	end
end

function ENT:OnRemove()
	BaseClass.OnRemove(self)

	self:StopSound( self.PortalLoop )
	self:StopSound( self.WindLoop )
end
