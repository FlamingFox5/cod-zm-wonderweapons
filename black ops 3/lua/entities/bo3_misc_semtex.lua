
AddCSLuaFile()

ENT.Base = "tfa_ww_base"
ENT.PrintName = "Widows Wine Semtex"
ENT.Purpose = "Spawns a live Widows Wine semtex from black ops 3."
ENT.Spawnable = true
ENT.AdminOnly = false
ENT.Category = "TFA Other"

// Default Settings

ENT.Delay = 1
ENT.Range = 250
ENT.Damage = 25
ENT.SpawnGravityEnabled = true

ENT.DefaultModel = "models/weapons/tfa_bo3/semtex/w_semtex.mdl"

ENT.HullMaxs = Vector(2, 2, 2)
ENT.HullMins = ENT.HullMaxs:GetNegated()

ENT.StartSound = "TFA_BO3_GRENADE.Pin"

ENT.ShouldLodgeProjectile = true
ENT.ShouldDropProjectile = true

ENT.ParentOffset = -1.2
ENT.BuoyancyRatio = 0.2

ENT.ImpactBubbles = true
ENT.ImpactBubblesSize = 64 
ENT.ImpactBubblesMagnitude = 0.5

ENT.SpriteTrailMaterial = "trails/smoke"
ENT.SpriteTrailResolution = 0.1
ENT.SpriteTrailLifetime = 0.5
ENT.SpriteTrailStartWidth = 4
ENT.SpriteTrailEndWidth = 1
ENT.SpriteTrailAdditive = true
ENT.SpriteTrailColor = Color(200, 200, 200, 200)
ENT.SpriteTrailAttachment = 1

// Explosion Settings

ENT.ExplodeOnKilltimeEnd = true

ENT.ExplosionBubbles = true
ENT.ExplosionBubblesSize = 240
ENT.ExplosionBubblesMagnitude = 2

ENT.ExplosionMaxBlockingMass = 350
ENT.ExplosionDamageType = nzombies and DMG_BLAST or bit.bor(DMG_BLAST, DMG_AIRBOAT)
ENT.ExplosionHeadShotScale = 3
ENT.ExplosionHitsOwner = false
ENT.ExplosionOwnerDamage = 150

ENT.WaterBlockExplosions = false

ENT.ScreenShakeAmplitude = 5
ENT.ScreenShakeFrequency = 255
ENT.ScreenShakeDuration = 1
ENT.ScreenShakeRange = 300

ENT.ExplosionEffect = "bo3_spider_impact"

ENT.ExplosionSound1 = "TFA_BO3_SPIDERNADE.Explode"

// DLight Settings

ENT.Color = Color( 255, 255, 255 )

ENT.DLightBrightness = 0
ENT.DLightSize = 0

ENT.DLightFlashOnRemove = true

ENT.DLightFlashSize = 200
ENT.DLightFlashDecay = 2000
ENT.DLightFlashBrightness = 0

// nZombies

ENT.NZThrowIcon = Material("vgui/icon/hud_icon_sticky_grenade.png", "unlitgeneric smooth")

DEFINE_BASECLASS(ENT.Base)

local nzombies = engine.ActiveGamemode() == "nzombies"

function ENT:SetupDataTables()
	BaseClass.SetupDataTables(self)

	self:NetworkVarTFA("Bool", "Activated")
end

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

	local aimangle = ply:GetAimVector():Angle()

	local ent = ents.Create( ClassName )
	ent:SetPos(SpawnPos)
	ent:SetAngles(Angle( 0, aimangle[2], 0 ) )
	ent:SetOwner(ply)

	ent.Delay = 3
	ent.Range = 144

	ent.Inflictor = ent

	ent.SpawnMenuCreated = true

	ent:Spawn()
	ent:Activate()

	local phys = ent:GetPhysicsObject()
	if IsValid(phys) then
		phys:SetMass( 5 )
		phys:SetBuoyancyRatio( 0 )

		local angvel = Vector( 0, math.random( -200, 200 ), math.random( -200, -600 ) )
		angvel:Rotate( -1 * ply:EyeAngles() )
		angvel:Rotate( Angle( 0, ply:EyeAngles().y, 0 ) )

		phys:AddAngleVelocity( angvel )

		local fuck1 = math.random(2) == 2 and 10 or -10
		local fuck2 = math.random(2) == 1 and -10 or 10
		phys:SetVelocity( Vector( 0, 0, math.random( 200, 400 ) ) + Vector( math.random( 0, 4 ) * fuck1, math.random( 0, 4 ) * fuck2, 0 ) )
	end

	return ent
end

if SERVER then
	function ENT:GravGunPickupAllowed()
		return not self:GetActivated()
	end
end

function ENT:GravGunPunt(ply)
	if self:GetActivated() then
		return false
	end

	local owner = self:GetOwner()
	if not IsValid(owner) or owner:IsNPC() then
		self:SetOwner(ply)
	end

	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:EnableMotion( true )

		local angvel = Vector( 0, math.random( -2000, 2000 ), math.random( -2000, -8000 ) )
		angvel:Rotate( -1 * ply:EyeAngles() )
		angvel:Rotate( Angle( 0, ply:EyeAngles().y, 0 ) )

		phys:AddAngleVelocity( angvel )
	end

	return true
end

function ENT:PhysicsCollide(data, phys)
	if self:GetActivated() then return end

	local trace = self:CollisionDataToTrace(data)

	self:LodgeProjectile(trace)

	if data.OurOldVelocity:Length() > 400 then
		self:DoImpactEffect(trace)
	end

	self:ActivateCustom(trace)
end

function ENT:EntityCollide(trace)
	if self:GetActivated() then return end

	self:DoImpactEffect(trace)

	self:ActivateCustom(trace)
end

function ENT:ActivateCustom(trace)
	self:SetActivated(true)

	sound.Play("TFA_BO3_SEMTEX.Stick", trace.HitPos)
	
	if trace.Hit and IsValid(hitEntity) then
		local hitDamage = DamageInfo()
		hitDamage:SetDamage(25)
		hitDamage:SetAttacker(IsValid(self:GetOwner()) and self:GetOwner() or self)
		hitDamage:SetInflictor(IsValid(self.Inflictor) and self.Inflictor or self)
		hitDamage:SetDamageType(DMG_BULLET)
		hitDamage:SetDamageForce(trace.Normal*200)
		hitDamage:SetDamagePosition(trace.HitPos)
		hitDamage:SetReportedPosition(trace.StartPos)

		hitEntity:DispatchTraceAttack(hitDamage, trace, trace.Normal)
	end
end

function ENT:PreExplosionDamage( hitEntity, explosionTrace, damageinfo )
	if nzombies and (hitEntity.NZBossType or hitEntity.IsMooBossZombie or hitEntity.IsMooMiniBoss) then return end

	if ( hitEntity:IsPlayer() or hitEntity:IsNextBot() or hitEntity:IsNPC() ) then
		TFA.WonderWeapon.GiveStatus(hitEntity, "BO3_WidowsWine_Web", math.Remap(10*explosionTrace.Fraction, 0, 10, 6, 10), self:GetOwner())
	end

	return true //block doing damage
end

function ENT:CallbackOnDrop()
	if not self:GetActivated() then return end
	self:SetActivated(false)
end