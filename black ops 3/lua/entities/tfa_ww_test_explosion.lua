
AddCSLuaFile()

ENT.Base = "tfa_ww_base"
ENT.PrintName = "Explosion"
ENT.Purpose = "Test projectile base 'Explosion' module."
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.Category = "Testing"

// Default Settings

ENT.Delay = 0
ENT.Range = 144
ENT.Damage = 100

ENT.SpawnGravityEnabled = false

ENT.NoDrawNoShadow = true

ENT.DefaultModel = "models/weapons/tfa_bo3/grenade/grenade_prop.mdl"

ENT.HullMaxs = Vector(2, 2, 2)
ENT.HullMins = ENT.HullMaxs:GetNegated()

ENT.ImpactBubbles = false

// Explosion Settings

ENT.ExplodeOnKilltimeEnd = true

ENT.ExplosionBubbles = true
ENT.ExplosionBubblesSize = 240
ENT.ExplosionBubblesMagnitude = 4

ENT.ExplosionMaxBlockingMass = 350
ENT.ExplosionDamageType = nzombies and DMG_BLAST or bit.bor(DMG_BLAST, DMG_AIRBOAT)
ENT.ExplosionHeadShotScale = 3
ENT.ExplosionHitsOwner = true
ENT.ExplosionOwnerDamage = 75

ENT.WaterBlockExplosions = false

ENT.ScreenShakeAmplitude = 5
ENT.ScreenShakeFrequency = 255
ENT.ScreenShakeDuration = 1
ENT.ScreenShakeRange = 200

ENT.ExplosionSound1 = "TFA_BO3_GRENADE.Dist"
ENT.ExplosionSound2 = "TFA_BO3_GRENADE.Exp"
ENT.ExplosionSound3 = "TFA_BO3_GRENADE.ExpClose"
ENT.ExplosionSound4 = "TFA_BO3_GRENADE.Flux"

// DLight Settings

ENT.Color = Color( 255, 160, 80 )

ENT.DLightBrightness = 0
ENT.DLightSize = 0

ENT.DLightFlashOnRemove = true

ENT.DLightFlashSize = 256
ENT.DLightFlashDecay = 2000
ENT.DLightFlashBrightness = 1

DEFINE_BASECLASS(ENT.Base)

local nzombies = engine.ActiveGamemode() == "nzombies"

function ENT:SpawnFunction( ply, tr, ClassName )
	if ( !tr.Hit ) then return end

	local ent = ents.Create( ClassName )
	ent:SetPos( tr.HitPos )
	ent:SetAngles( tr.HitNormal:Angle() )
	ent:SetOwner(ply)
	
	ent.Delay = 0
	ent.Range = 144
	ent.Damage = 100
	ent.mydamage = 100
	ent.Direction = tr.HitNormal

	ent.Inflictor = ent

	ent.SpawnMenuCreated = true

	ent:Spawn()
	ent:Activate()
	ent:Explode()

	local phys = ent:GetPhysicsObject()
	if IsValid( phys ) then
		phys:SetMass( 5 )
		phys:SetBuoyancyRatio( 0 )
		phys:SetVelocity( tr.HitNormal )
	end

	return ent
end

if SERVER then
	function ENT:GravGunPickupAllowed()
		return false
	end
end

function ENT:GravGunPunt()
	return false
end

function ENT:PhysicsCollide(data, phys)
end

function ENT:EntityCollide(trace)
end

function ENT:Initialize(...)
	BaseClass.Initialize( self, ... )

	self:SetMoveType( MOVETYPE_NONE )
	self:AddSolidFlags( FSOLID_NOT_SOLID )
	self:SetCollisionGroup( COLLISION_GROUP_IN_VEHICLE )
	self:PhysicsStop()
end
