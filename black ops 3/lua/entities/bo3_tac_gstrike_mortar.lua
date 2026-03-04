
AddCSLuaFile()

ENT.Base = "tfa_ww_base"
ENT.PrintName = "Mortar"

// Custom Settings

ENT.Impacted = false

// Default Settings

ENT.ForcedKillTime = 10

ENT.Delay = 3
ENT.Range = 200
ENT.Damage = 200

ENT.DefaultModel = "models/weapons/tfa_bo3/qed/w_maxgl_proj.mdl"

ENT.InfiniteDamage = true

ENT.HullMaxs = Vector(2, 2, 2)
ENT.HullMins = ENT.HullMaxs:GetNegated()

ENT.ImpactDecal = "Rollermine.Crater"

ENT.StartSound = "TFA_BO3_GSTRIKE.Launch"

ENT.TrailSound = "TFA_BO3_GSTRIKE.Incoming"

ENT.ExplosionEffectAngleCorrection = Angle(0,0,0)
ENT.ExplosionEffect = "doi_mortar_explosion"

// Explosion Settings

ENT.ExplodeOnKilltimeEnd = true

ENT.ExplosionBubbles = true
ENT.ExplosionBubblesSize = 240
ENT.ExplosionBubblesMagnitude = 4

ENT.ExplosionMaxBlockingMass = 350
ENT.ExplosionDamageType = nzombies and DMG_BLAST or bit.bor(DMG_BLAST, DMG_AIRBOAT)
ENT.ExplosionHeadShotScale = 3 
ENT.ExplosionHitsOwner = nzombies and false or true
ENT.ExplosionOwnerDamage = 50

ENT.WaterBlockExplosions = false

ENT.ScreenShakeAmplitude = 10
ENT.ScreenShakeFrequency = 255
ENT.ScreenShakeDuration = 1.25
ENT.ScreenShakeRange = 400

ENT.ExplosionSound1 = "TFA_BO3_GSTRIKE.Exp"
ENT.ExplosionSound2 = "TFA_BO3_GSTRIKE.Exp.Debris"
ENT.ExplosionSound3 = "TFA_BO3_GRENADE.ExpClose"
ENT.ExplosionSound4 = "TFA_BO3_GRENADE.Flux"

DEFINE_BASECLASS(ENT.Base)

local nzombies = engine.ActiveGamemode() == "nzombies"

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end

function ENT:SetupDataTables()
	BaseClass.SetupDataTables(self)

	self:NetworkVarTFA("Vector", "LandingSpot")
end

if SERVER then
	function ENT:GravGunPickupAllowed()
		return true
	end
end

function ENT:GravGunPunt()
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)

	return true
end

function ENT:PhysicsCollide(data, phys)
	if self.Impacted then return end
	self.Impacted = true

	self:StoreCollisionEventData(data)

	self:Explode( data.HitPos - data.OurOldVelocity:GetNormalized() )

	util.Decal("Scorch", data.HitPos, data.HitPos + data.HitNormal*4)

	self:Remove()
end

function ENT:CreateRocketTrail()
	if not SERVER then return end

	local rockettrail = ents.Create("env_rockettrail")
	rockettrail:DeleteOnRemove(self)

	rockettrail:SetPos( self:GetPos() - self:GetForward()*12 )
	rockettrail:SetAngles( self:GetAngles() )
	rockettrail:SetParent( self )
	rockettrail:SetMoveType( MOVETYPE_NONE )
	rockettrail:AddSolidFlags( FSOLID_NOT_SOLID )

	rockettrail:SetSaveValue("m_Opacity", 0.2)
	rockettrail:SetSaveValue("m_SpawnRate", 200)
	rockettrail:SetSaveValue("m_ParticleLifetime", 1)
	rockettrail:SetSaveValue("m_StartColor", Vector(0.1, 0.1, 0.1))
	rockettrail:SetSaveValue("m_EndColor", Vector(1, 1, 1))
	rockettrail:SetSaveValue("m_StartSize", 12)
	rockettrail:SetSaveValue("m_EndSize", 32)
	rockettrail:SetSaveValue("m_SpawnRadius", 4)
	rockettrail:SetSaveValue("m_MinSpeed", 16)
	rockettrail:SetSaveValue("m_MaxSpeed", 32)
	rockettrail:SetSaveValue("m_nAttachment", 1)
	rockettrail:SetSaveValue("m_flDeathTime", CurTime() + self.Delay)

	rockettrail:Activate()
	rockettrail:Spawn()
end

function ENT:Initialize(...)
	BaseClass.Initialize(self, ...)

	self:SetSolid( SOLID_NONE )
	self:SetCollisionGroup( COLLISION_GROUP_NONE )

	if CLIENT then return end

	self:CreateRocketTrail()
end

function ENT:Think()
	if SERVER then
		if self.GetLandingSpot and not self:GetLandingSpot():IsZero() then
			if self:GetPos():DistToSqr(self:GetLandingSpot()) <= 64^2 and self:VisibleVec(self:GetLandingSpot()) then
				self:SetSolid( SOLID_VPHYSICS )
				self:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
			end
		end
	end

	return BaseClass.Think(self)
end
