
AddCSLuaFile()

ENT.Base = "tfa_ww_base"
ENT.PrintName = "40mm Grenade"
ENT.Spawnable = true
ENT.AdminOnly = false
ENT.Category = "TFA Other"

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
ENT.SpriteTrailStartWidth = 4
ENT.SpriteTrailEndWidth = 1
ENT.SpriteTrailAdditive = true
ENT.SpriteTrailColor = Color(200, 200, 200, 200)
ENT.SpriteTrailAttachment = 1

// Explosion Settings

ENT.ExplosionBubbles = true
ENT.ExplosionBubblesSize = 240
ENT.ExplosionBubblesMagnitude = 4

ENT.ExplosionMaxBlockingMass = 350
ENT.ExplosionDamageType = nzombies and DMG_BLAST or bit.bor(DMG_BLAST, DMG_AIRBOAT)
ENT.ExplosionHeadShotScale = 3 
ENT.ExplosionHitsOwner = true
ENT.ExplosionOwnerDamage = 50
ENT.ExplosionOwnerRange = 150

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

function ENT:SpawnFunction( ply, tr, ClassName )
	if ( !tr.Hit ) then return end

	local size = 2
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

	local aimangle = tr.Normal:Angle()

	local ent = ents.Create( ClassName )
	ent:SetPos(SpawnPos)
	ent:SetAngles(Angle( 0, aimangle[2], 0 ) )
	ent:SetOwner(ply)

	ent.Delay = math.huge
	ent.Range = 144
	ent.Damage = 100
	ent.mydamage = 100

	ent.Inflictor = ent

	ent.SpawnMenuCreated = true

	ent:Spawn()
	ent:Activate()

	local phys = ent:GetPhysicsObject()
	if IsValid(phys) then
		phys:SetMass(10)
		phys:SetBuoyancyRatio(0)
		phys:EnableMotion(true)
		phys:Wake()
	end

	return ent
end

function ENT:GravGunPunt(ply)
	local owner = self:GetOwner()
	if not IsValid(owner) or owner:IsNPC() then
		self:SetOwner(ply)
	end

	if self.SpawnMenuCreated and !self.SpriteTrail then
		self:CreateSpriteTrail()
	end

	self.SpawnMenuCreated = false

	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:EnableMotion(true)

		local angvel = Vector( 0, math.random( -2000, 2000 ), math.random( -2000, -8000 ) )
		angvel:Rotate( -1 * ply:EyeAngles() )
		angvel:Rotate( Angle( 0, ply:EyeAngles().y, 0 ) )

		phys:AddAngleVelocity( angvel )
	end
	return true
end

function ENT:PhysicsCollide(data, phys)
	if self.SpawnMenuCreated and data.OurOldVelocity:Length() < 200 then return end

	if self.Impacted then return end
	self.Impacted = true

	local trace = self:CollisionDataToTrace(data)
	local direction = data.OurOldVelocity:GetNormalized()
	local hitEntity = trace.Entity

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

	self:Explode(data.HitPos, self.Range, trace.HitNormal)

	self:PhysicsStop(phys) // always call last

	self:Remove()
end

function ENT:EntityCollide(trace)
	if self.Impacted then return end
	self.Impacted = true

	local hitEntity = trace.Entity

	self:SetHitPos(trace.HitPos)

	self:DoImpactEffect(trace)

	local myDamage = self:GetTrueDamage(hitEntity)

	local hitDamage = DamageInfo()
	hitDamage:SetDamage(myDamage)
	hitDamage:SetAttacker(IsValid(self:GetOwner()) and self:GetOwner() or self)
	hitDamage:SetInflictor(IsValid(self.Inflictor) and self.Inflictor or self)
	hitDamage:SetDamageType(nzombies and DMG_BLAST or bit.bor(DMG_BLAST, DMG_ALWAYSGIB))
	hitDamage:SetDamageForce(trace.Normal*math.random(9000,14000))
	hitDamage:SetDamagePosition(trace.HitPos)
	hitDamage:SetReportedPosition(trace.StartPos)

	if trace.HitGroup == HITGROUP_HEAD then
		hitDamage:SetDamage(myDamage*5)
	end

	hitEntity:DispatchTraceAttack(hitDamage, trace, trace.Normal)

	self:SendHitMarker(hitEntity, hitDamage, trace)

	self:Explode(trace.HitPos, self.Range, trace.HitNormal)

	self:PhysicsStop() // always call last

	self:Remove()
	return false
end
