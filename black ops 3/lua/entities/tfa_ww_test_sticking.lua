
AddCSLuaFile()

ENT.Base = "tfa_ww_base"
ENT.PrintName = "Sticking"
ENT.Purpose = "Test projectile base 'Sticking' module."
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.Category = "Testing"

// Default Settings

ENT.Delay = 60
ENT.Range = 0
ENT.Damage = 0

ENT.SpawnGravityEnabled = true

ENT.DefaultModel = "models/dav0r/hoverball.mdl"

ENT.HullMaxs = Vector(0.1, 0.1, 0.1)
ENT.HullMins = ENT.HullMaxs:GetNegated()

ENT.ImpactDecal = "GlassBreak"

ENT.ImpactBubbles = true
ENT.ImpactBubblesSize = 128
ENT.ImpactBubblesMagnitude = 2

// Sticking Settings

ENT.ShouldLodgeProjectile = true

ENT.StopTransmitToParent = true

ENT.ParentOffset = -1
//ENT.ParentAlign = true
//ENT.ParentAlignOffset = Angle(180, 0, 0)

local mImpactMaterials = TFA.WonderWeapon.BoltImpactSoundMaterials

DEFINE_BASECLASS(ENT.Base)

local nzombies = engine.ActiveGamemode() == "nzombies"

function ENT:SpawnFunction( ply, tr, ClassName )
	if ( !tr.Hit ) then return end

	local size = 32
	local SpawnPos = tr.HitPos + tr.HitNormal * size

	local oobTr = util.TraceLine( {
		start = tr.HitPos,
		endpos = SpawnPos,
		mask = MASK_SOLID_BRUSHONLY
	} )

	if ( oobTr.Hit ) then
		SpawnPos = oobTr.HitPos + oobTr.HitNormal * ( tr.HitPos:Distance( oobTr.HitPos ) / 2 )
	end

	local flDist = (ply:GetShootPos() - tr.HitPos):Length()
	local direction = tr.HitNormal:Angle()
	local velocity = Vector()

	if flDist <= 2048 then
		SpawnPos = ply:GetShootPos() + ply:GetAimVector()

		local time = 1.4 * math.Clamp( flDist / 2048, 0, 1 )
		local diff = tr.HitPos - SpawnPos --subtract the vectors

		local velx = diff.x/time -- x velocity
		local vely = diff.y/time -- y velocity
		local velz = (diff.z - 0.5*(-GetConVarNumber( "sv_gravity"))*(time^2))/time --  x = x0 + vt + 0.5at^2 conversion

		velocity:SetUnpacked(velx, vely, velz)
		direction = velocity:GetNormalized()
	end

	local ent = ents.Create( ClassName )
	ent:SetPos( SpawnPos )
	ent:SetAngles( direction:Angle() )

	ent.Inflictor = ent

	ent.SpawnMenuCreated = true

	ent:Spawn()
	ent:Activate()

	local phys = ent:GetPhysicsObject()
	if IsValid( phys ) then
		phys:SetMass( 5 )
		phys:SetBuoyancyRatio( 0 )
		phys:Wake()

		phys:SetVelocity( velocity )
	end

	return ent
end

if SERVER then
	function ENT:GravGunPickupAllowed()
		return !IsValid(self:GetParent())
	end
end

function ENT:GravGunPunt( ply )
	if IsValid(self:GetParent()) then
		return false
	end

	local phys = self:GetPhysicsObject()
	if IsValid( phys ) then
		phys:EnableDrag( true )
		phys:EnableGravity( true )
	end
	return true
end

function ENT:PhysicsCollide( data, phys )
	if self.Impacted then return end
	self.Impacted = true

	self:EmitSound("physics/metal/metal_box_impact_bullet"..math.random(3)..".wav", SNDLVL_NORM, math.random(97, 103), 1, CHAN_ITEM)

	local trace = self:CollisionDataToTrace( data )

	self:LodgeProjectile( trace )

	self:DoImpactEffect( trace )

	local fac = math.Clamp( data.Speed / 100, 1, 5 )

	util.ScreenShake(data.HitPos, 1 * fac, 5, 0.3 * (fac/2.5), 60 * fac)
end

function ENT:EntityCollide( trace )
	if self.Impacted then return end
	self.Impacted = true

	self:EmitSound("physics/metal/metal_box_impact_bullet"..math.random(3)..".wav", SNDLVL_NORM, math.random(97, 103), 1, CHAN_ITEM)

	self:DoImpactEffect( trace )

	local fac = math.Clamp( self.Speed / 100, 1, 5 )

	util.ScreenShake(self.HitPos, 1 * fac, 5, 0.3 * (fac/2.5), 60 * fac)
end

function ENT:CallbackOnDrop( entity )
	if not self.Impacted then return end
	self.Impacted = false
end

function ENT:Initialize( ... )
	BaseClass.Initialize( self, ... )

	self:SetMaterial( "models/weapons/tfa_bo3/gersch/lambert1" )
end

function ENT:OnRemove()
	local entity = self:GetParent()
	if SERVER and IsValid( entity ) and self.KillSelfString then
		entity:RemoveCallOnRemove( self.KillSelfString )
	end
end
