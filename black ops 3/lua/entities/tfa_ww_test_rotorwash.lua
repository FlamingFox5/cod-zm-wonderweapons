
AddCSLuaFile()

ENT.Base = "tfa_ww_base"
ENT.PrintName = "Rotor Wash"
ENT.Purpose = "Test projectile base 'Rotorwash' module."
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.Category = "Testing"

// Default Settings

ENT.Delay = 60
ENT.Range = 0
ENT.Damage = 0

ENT.SpawnGravityEnabled = false

ENT.DefaultModel = "models/dav0r/hoverball.mdl"

ENT.HullMaxs = Vector(2, 2, 2)
ENT.HullMins = ENT.HullMaxs:GetNegated()

ENT.ImpactBubbles = true
ENT.ImpactBubblesSize = 128
ENT.ImpactBubblesMagnitude = 1

// Rotorwash Settings

ENT.ShouldDoRotorWash = true
ENT.ShouldRotorWashPushVPhysics = true
ENT.RotorWashWaterSurfaceOnly = false // rotor wash effect over water only
ENT.RotorWashPushMaxObjects = 6
ENT.RotorWashPushRadius = 256
ENT.RotorWashAltitude = BASECHOPPER_WASH_ALTITUDE
ENT.RotorBlastSound = "NPC_AttackHelicopter.RotorBlast"

DEFINE_BASECLASS(ENT.Base)

local nzombies = engine.ActiveGamemode() == "nzombies"

function ENT:SpawnFunction( ply, tr, ClassName )
	if ( !tr.Hit ) then return end

	local size = 32
	local SpawnPos = tr.HitPos + tr.HitNormal * size

	-- Make sure the spawn position is not out of bounds
	local oobTr = util.TraceLine( {
		start = tr.HitPos,
		endpos = SpawnPos,
		mask = MASK_SOLID_BRUSHONLY
	} )

	if ( oobTr.Hit ) then
		SpawnPos = oobTr.HitPos + oobTr.HitNormal * ( tr.HitPos:Distance( oobTr.HitPos ) / 2 )
	end

	local ent = ents.Create( ClassName )
	ent:SetPos( SpawnPos )
	ent:SetAngles( tr.HitNormal:Angle() )

	ent.Inflictor = ent

	ent.SpawnMenuCreated = true

	ent:Spawn()
	ent:Activate()

	local phys = ent:GetPhysicsObject()
	if IsValid( phys ) then
		phys:SetMass( 5 )
		phys:SetBuoyancyRatio( 0 )
		phys:Wake()
	end

	return ent
end

function ENT:GravGunPunt( ply )
	local phys = self:GetPhysicsObject()
	if IsValid( phys ) then
		phys:EnableDrag( true )
		phys:EnableGravity( true )
	end
	return true
end

function ENT:PhysicsCollide( data, phys )
	phys:SetVelocityInstantaneous(Vector())
	phys:Sleep()
end

function ENT:Initialize( ... )
	BaseClass.Initialize( self, ... )

	self:SetMaterial( "models/weapons/tfa_bo3/gersch/lambert1" )
end
