
AddCSLuaFile()

ENT.Base = "tfa_ww_base"
ENT.PrintName = "Frag Grenade"
ENT.Purpose = "Spawns a live frag grenade from black ops 3."
ENT.Spawnable = true
ENT.AdminOnly = false
ENT.Category = "TFA Other"

// Default Settings

ENT.Delay = 3
ENT.Range = 200
ENT.Damage = 200
ENT.SpawnGravityEnabled = true

ENT.DefaultModel = "models/weapons/tfa_bo3/grenade/grenade_prop.mdl"

ENT.HullMaxs = Vector(2, 2, 2)
ENT.HullMins = ENT.HullMaxs:GetNegated()

ENT.StartSound = "TFA_BO3_GRENADE.Pin"

ENT.ImpactBubbles = true
ENT.ImpactBubblesSize = 32
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
ENT.ExplosionBubblesMagnitude = 4

ENT.ExplosionMaxBlockingMass = 350
ENT.ExplosionDamageType = nzombies and DMG_BLAST or bit.bor(DMG_BLAST, DMG_AIRBOAT)
ENT.ExplosionHeadShotScale = 3
ENT.ExplosionHitsOwner = true
ENT.ExplosionOwnerDamage = 150

ENT.WaterBlockExplosions = false

ENT.ScreenShakeAmplitude = 5
ENT.ScreenShakeFrequency = 255
ENT.ScreenShakeDuration = 1
ENT.ScreenShakeRange = 300

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

// nZombies

ENT.NZNadeRethrow = true
ENT.NZHudIcon = Material("vgui/hud/hud_grenadethrowback_glow.png", "smooth unlitgeneric")
ENT.NZHudIcon_t7 = Material("vgui/hud/hud_grenadethrowback.png", "smooth unlitgeneric")

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

	local aimangle = ply:GetAimVector():Angle()

	local ent = ents.Create( ClassName )
	ent:SetPos(SpawnPos)
	ent:SetAngles(Angle( 0, aimangle[2], 0 ) )
	ent:SetOwner(ply)
	
	ent.Delay = 3
	ent.Range = 144
	ent.Damage = 100
	ent.mydamage = 100

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

function ENT:GravGunPunt(ply)
	local owner = self:GetOwner()
	if not IsValid(owner) or owner:IsNPC() then
		self:SetOwner(ply)
	end

	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:EnableMotion( true )
	end
	return true
end

function ENT:PhysicsCollide(data, phys)
	if data.Speed > 60 then
		sound.Play("TFA_BO3_GRENADE.Bounce", data.HitPos)

		if data.OurOldVelocity:Length() > 700 then
			local trace = self:CollisionDataToTrace(data)
			local direction = data.OurOldVelocity:GetNormalized()
			local hitEntity = trace.Entity

			self:DoImpactEffect(trace)

			if trace.Hit and IsValid(hitEntity) then
				local hitDamage = DamageInfo()
				hitDamage:SetDamage(25)
				hitDamage:SetAttacker(IsValid(self:GetOwner()) and self:GetOwner() or self)
				hitDamage:SetInflictor(IsValid(self.Inflictor) and self.Inflictor or self)
				hitDamage:SetDamageType(DMG_BULLET)
				hitDamage:SetDamageForce(direction*200)
				hitDamage:SetDamagePosition(trace.HitPos)
				hitDamage:SetReportedPosition(trace.StartPos)

				if trace.HitGroup == HITGROUP_HEAD then
					hitDamage:SetDamage(self:GetTrueDamage(hitEntity)*3)
				end

				hitEntity:DispatchTraceAttack(hitDamage, trace, direction)

				self:SendHitMarker(hitEntity, hitDamage, trace)
			end
		end

		local impulse = (data.OurOldVelocity - 2 * data.OurOldVelocity:Dot(data.HitNormal) * data.HitNormal) * 0.25
		phys:ApplyForceCenter(impulse)
	end
end

function ENT:EntityCollide(trace)
	if self.Impacted then return end

	self:DoImpactEffect(trace)

	local hitEntity = trace.Entity

	local hitDamage = DamageInfo()
	hitDamage:SetDamage(25)
	hitDamage:SetAttacker(IsValid(self:GetOwner()) and self:GetOwner() or self)
	hitDamage:SetInflictor(IsValid(self.Inflictor) and self.Inflictor or self)
	hitDamage:SetDamageType(DMG_BULLET)
	hitDamage:SetDamageForce(trace.Normal*200)
	hitDamage:SetDamagePosition(trace.HitPos)
	hitDamage:SetReportedPosition(trace.StartPos)

	if trace.HitGroup == HITGROUP_HEAD then
		hitDamage:SetDamage(self:GetTrueDamage(hitEntity)*3)
	end

	hitEntity:DispatchTraceAttack(hitDamage, trace, trace.Normal)

	self:SendHitMarker(hitEntity, hitDamage, trace)
end
