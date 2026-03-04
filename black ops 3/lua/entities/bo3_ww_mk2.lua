
AddCSLuaFile()

ENT.Base = "tfa_ww_base"
ENT.PrintName = "Raygun Mk2"

// Custom Settings

ENT.Impacted = false

ENT.ImpactSound = "TFA_BO3_MK2.Impact"

// Default Settings

ENT.Delay = 10

ENT.NoDrawNoShadow = true

ENT.HullMaxs = Vector(1, 1, 1)
ENT.HullMins = ENT.HullMaxs:GetNegated()

ENT.TrailEffect = "bo3_mk2_trail"
ENT.TrailEffectPaP = "bo3_mk2_trail_2"
ENT.TrailAttachType = PATTACH_ABSORIGIN_FOLLOW
ENT.TrailAttachPoint = 1

ENT.ImpactDecal = "FadingScorch"

ENT.ImpactBubbles = true
ENT.ImpactBubblesSize = 64
ENT.ImpactBubblesMagnitude = 1

// DLight Settings

ENT.Color = Color(90, 255, 10)
ENT.ColorPaP = Color(255, 40, 10)

ENT.DLightBrightness = 1
ENT.DLightDecay = 2000
ENT.DLightSize = 200

ENT.DLightFlashOnRemove = true

ENT.DLightFlashSize = 200
ENT.DLightFlashDecay = 2000
ENT.DLightFlashBrightness = 2

// 'env_sprite' Follower

ENT.GlowSpriteTrail = true
ENT.GlowSpriteTrailSize = 0.15
ENT.GlowSpriteTrailLife = ENT.Delay
ENT.GlowSpriteTrailColor = ENT.Color
ENT.GlowSpriteTrailColorPaP = ENT.ColorPaP
ENT.GlowSpriteTrailAlpha = 255
ENT.GlowSpriteOffset = Vector()

DEFINE_BASECLASS(ENT.Base)

local nzombies = engine.ActiveGamemode() == "nzombies"

local ShouldDamage = TFA.WonderWeapon.ShouldDamage

function ENT:PhysicsCollide(data, phys)
	if self.Impacted then return end
	self.Impacted = true

	sound.Play(self.ImpactSound, data.HitPos)

	local trace = self:CollisionDataToTrace(data)
	local direction = data.OurOldVelocity:GetNormalized()
	local hitEntity = trace.Entity

	self:DoImpactEffect(trace)

	if trace.Hit and IsValid(hitEntity) and ShouldDamage(hitEntity, self:GetOwner(), self) then
		local hitCharacter = (hitEntity:IsNPC() or hitEntity:IsPlayer() or hitEntity:IsNextBot())

		local hitDamage = DamageInfo()
		hitDamage:SetDamage(self.Damage)
		hitDamage:SetAttacker(IsValid(self:GetOwner()) and self:GetOwner() or self)
		hitDamage:SetInflictor(IsValid(self.Inflictor) and self.Inflictor or self)
		hitDamage:SetDamageType(nzombies and DMG_BULLET or DMG_ENERGYBEAM)
		hitDamage:SetDamageForce(hitCharacter and direction*math.random(12000,16000) or direction*2000)
		hitDamage:SetDamagePosition(trace.HitPos)
		hitDamage:SetReportedPosition(trace.StartPos)

		local nLastHealth = hitEntity:Health()

		hitEntity:DispatchTraceAttack(hitDamage, trace, direction)

		if hitEntity:Health() < nLastHealth then
			self:SendHitMarker(hitEntity, hitDamage, trace)
		end
	end

	util.ScreenShake( data.HitPos, 5, 255, 0.6, 96 )

	if data.TheirNewVelocity:Length() < 20 then
		ParticleEffect(self:GetUpgraded() and "bo3_mk2_impact_2" or "bo3_mk2_impact", data.HitPos, data.HitNormal:Angle() - Angle(90,0,0))
	end

	self:PhysicsStop(phys)

	self:Remove()
end

function ENT:EntityCollide(trace)
	if self.Impacted then return end

	sound.Play(self.ImpactSound, trace.HitPos)

	ParticleEffect(self:GetUpgraded() and "bo3_mk2_hitzomb_2" or "bo3_mk2_hitzomb", trace.HitPos, trace.HitNormal:Angle())

	self:DoImpactEffect(trace)

	local hitEntity = trace.Entity
	local direction = trace.Normal

	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		direction = phys:GetVelocity():GetNormalized()
	end

	local hitDamage = DamageInfo()
	hitDamage:SetDamage(self.Damage)
	hitDamage:SetAttacker(IsValid(self:GetOwner()) and self:GetOwner() or self)
	hitDamage:SetInflictor(IsValid(self.Inflictor) and self.Inflictor or self)
	hitDamage:SetDamageType(nzombies and DMG_BULLET or DMG_ENERGYBEAM)
	hitDamage:SetDamageForce(direction*math.random(8000,12000))
	hitDamage:SetDamagePosition(trace.HitPos)
	hitDamage:SetReportedPosition(trace.StartPos)

	local bBossZombie = nzombies and (hitEntity.NZBossType or hitEntity.IsMooBossZombie or hitEntity.IsMooMiniBoss)
	if trace.HitGroup == HITGROUP_HEAD then
		hitDamage:SetDamage(self.Damage*(bBossZombie and 7 or 22))
	end

	local nLastHealth = hitEntity:Health()

	hitEntity:DispatchTraceAttack(hitDamage, trace, trace.Normal)

	if hitEntity:Health() < nLastHealth then
		self:SendHitMarker(hitEntity, hitDamage, trace)
	end

	util.ScreenShake( trace.HitPos, 5, 255, 0.6, 64 )
end
