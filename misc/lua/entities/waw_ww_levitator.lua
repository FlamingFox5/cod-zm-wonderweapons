AddCSLuaFile()

ENT.Base = "tfa_ww_base"
ENT.PrintName = "Panther Projectile"

// Custom Settings

ENT.Impacted = false

ENT.MaxKills = 12
ENT.Kills = 0

// Default Settings

ENT.Delay = 10
ENT.Range = 200
ENT.InfiniteDamage = true

ENT.NoDrawNoShadow = true

ENT.HullMaxs = Vector(2, 2, 2)
ENT.HullMins = ENT.HullMaxs:GetNegated()

ENT.FluxSound = "TFA_WAW_LEVITATOR.Orb.Start"

ENT.TrailSound = "TFA_WAW_LEVITATOR.Orb.Loop"
ENT.TrailEffect = "waw_levitator_trail"
ENT.TrailEffectPaP = "waw_levitator_trail_2"
ENT.TrailAttachType = PATTACH_ABSORIGIN_FOLLOW
ENT.TrailAttachPoint = 1

ENT.ImpactDecal = "FadingScorch"

ENT.ImpactBubbles = false // we explode on impact which has bubbles

ENT.FindCharacterOnly = true

// Explosion Settings

ENT.ExplosionBubbles = true
ENT.ExplosionBubblesSize = 256
ENT.ExplosionBubblesMagnitude = 4

ENT.MaxExplosionBlockingMass = 350
ENT.ExplosionDamageType = nzombies and DMG_DISSOLVE or bit.bor( DMG_BLAST, DMG_DISSOLVE )
ENT.ExplosionHeadShotScale = 1
ENT.ExplosionHitsOwner = true
ENT.ExplosionOwnerDamage = 50
ENT.ExplosionScreenShake = true

ENT.WaterBlockExplosions = true

ENT.ScreenShakeAmplitude = 5
ENT.ScreenShakeFrequency = 255
ENT.ScreenShakeDuration = 0.8
ENT.ScreenShakeRange = 240

ENT.ExplosionEffectAngleCorrection = Angle(-90,0,0)
ENT.ExplosionEffect = "waw_levitator_impact"
ENT.ExplosionEffectPaP = "waw_levitator_impact_2"

ENT.ExplosionSound1 = "TFA_WAW_LEVITATOR.Orb.End"

// DLight Settings

ENT.ColorPaP = Color(50, 245, 30, 255)
ENT.Color = Color(100, 240, 255, 255)

ENT.DLightBrightness = 1
ENT.DLightDecay = 2000
ENT.DLightSize = 200

ENT.DLightFlashOnRemove = true

ENT.DLightFlashSize = 400
ENT.DLightFlashDecay = 1000
ENT.DLightFlashBrightness = 1

DEFINE_BASECLASS(ENT.Base)

local nzombies = engine.ActiveGamemode() == "nzombies"
local dlight_cvar = GetConVar("cl_tfa_fx_wonderweapon_dlights")
local SinglePlayer = game.SinglePlayer()

function ENT:PhysicsCollide(data, phys)
	if self.Impacted then return end
	self.Impacted = true

	local hitEntity = data.HitEntity
	local trace = self:CollisionDataToTrace(data)
	local direction = data.OurOldVelocity:GetNormalized()

	if trace.Hit and IsValid(hitEntity) and not (hitEntity:IsNPC() or hitEntity:IsNextBot() or hitEntity:IsPlayer()) then
		local hitDamage = DamageInfo()
		hitDamage:SetDamage(10)
		hitDamage:SetAttacker(IsValid(self:GetOwner()) and self:GetOwner() or self)
		hitDamage:SetInflictor(IsValid(self.Inflictor) and self.Inflictor or self)
		hitDamage:SetDamageType(DMG_BULLET)
		hitDamage:SetDamageForce(direction*2000)
		hitDamage:SetDamagePosition(trace.HitPos)
		hitDamage:SetReportedPosition(trace.StartPos)

		hitEntity:DispatchTraceAttack(hitDamage, trace, direction)
	end

	self:SetHitPos(data.HitPos)

	self:DoImpactEffect(trace)

	self:Explode(data.HitPos)

	util.Decal("Scorch", data.HitPos - data.HitNormal, data.HitPos + data.HitNormal)

	phys:SetVelocity(vector_origin)
	phys:EnableMotion(false)
	phys:Sleep()

	self:Remove()
end

function ENT:EntityCollide(trace)
	if self.Impacted then return end

	local hitEntity = trace.Entity
	local direction = trace.Normal

	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		direction = ply:GetVelocity():GetNormalized()
	end

	self:DoImpactEffect(trace)

	local hitDamage = DamageInfo()
	hitDamage:SetDamage(self.Damage)
	hitDamage:SetAttacker(IsValid(self:GetOwner()) and self:GetOwner() or self)
	hitDamage:SetInflictor(IsValid(self.Inflictor) and self.Inflictor or self)
	hitDamage:SetDamageType(DMG_DISSOLVE)
	hitDamage:SetDamageForce(direction*math.random(8000,12000))
	hitDamage:SetDamagePosition(trace.HitPos)
	hitDamage:SetReportedPosition(trace.StartPos)

	if trace.HitGroup == HITGROUP_HEAD then
		hitDamage:SetDamage(self.Damage*7)
	end

	local nLastHealth = hitEntity:Health()

	hitEntity:DispatchTraceAttack(hitDamage, trace, trace.Normal)

	if hitEntity:Health() < nLastHealth then
		self:SendHitMarker(hitEntity, hitDamage, trace)
	end

	if not (hitEntity:IsNPC() or hitEntity:IsPlayer() or hitEntity:IsNextBot()) then
		self.Impacted = true

		self:SetHitPos(trace.HitPos)

		self:Explode(trace.HitPos)

		util.Decal("Scorch", trace.HitPos, trace.HitPos + trace.Normal*4)

		if IsValid(phys) then
			phys:SetVelocity(vector_origin)
			phys:EnableMotion(false)
			phys:Sleep()
		end

		self:Remove()
		return false
	end
end

function ENT:PreExplosionDamage( hitEntity, explosionTrace, damageinfo )
	local bTooSmall = false
	local bTooBig = false

	if nzombies and hitEntity:IsValidZombie() and hitEntity.IsMooSpecial then
		local _, colMaxs = hitEntity:GetCollisionBounds()
		if ( colMaxs[1] < 10 or colMaxs[2] < 10 or colMaxs[3] < 32 )  then
			bTooSmall = true
		end

		local _, boundsMaxs = hitEntity:GetSurroundingBounds()
		if !bTooSmall and ( boundsMaxs[1] < 21 or boundsMaxs[2] < 21 or boundsMaxs[3] < 32 ) then
			bTooSmall = true
		end
	end

	if hitEntity.GetHullType and hitEntity:GetHullType() ~= HULL_HUMAN and ( sv_shrink_all == nil or !sv_shrink_all:GetBool() ) then
		bTooSmall = true
	end

	if hitEntity.GetHullType and hull_too_big[hitEntity:GetHullType()] and ( sv_shrink_all == nil or !sv_shrink_all:GetBool() ) then
		bTooBig = true
	end

	local bBossZombie = false
	if nzombies and (hitEntity.NZBossType or hitEntity.IsMooBossZombie or hitEntity.IsMooMiniBoss) then
		bBossZombie = true
	end

	if nzombies and bBossZombie then
		damageinfo:SetDamage( math.max( self:GetUpgraded() and 2000 or 1200, hitEntity:GetMaxHealth() / 6 ) )
	elseif bTooSmall then
		damageinfo:ScaleDamage( 7 )
	elseif !bTooBig then
		if not HasStatus(hitEntity, "WAW_Panther_Levitate") then
			self.Kills = self.Kills + 1
			if self.Kills > self.MaxKills then
				return true
			end

			GiveStatus(hitEntity, "WAW_Panther_Levitate", math.Rand( 2.5, 5 ), self:GetOwner(), self.Inflictor, self:GetUpgraded() )
		end

		return true //block doing damage
	end
end
