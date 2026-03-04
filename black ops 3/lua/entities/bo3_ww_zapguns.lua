
AddCSLuaFile()

ENT.Base = "tfa_ww_base"
ENT.PrintName = "Zapgun"

// Default Settings

ENT.Range = 20
ENT.Delay = 6

ENT.InfiniteDamage = true

ENT.NoDrawNoShadow = true

ENT.HullMaxs = Vector(2, 2, 2)
ENT.HullMins = ENT.HullMaxs:GetNegated()

ENT.ImpactDecal = "FadingScorch"

ENT.ImpactBubbles = true
ENT.ImpactBubblesSize = 128
ENT.ImpactBubblesMagnitude = 2

// Explosion Settings

ENT.ScreenShakeAmplitude = 5
ENT.ScreenShakeFrequency = 255
ENT.ScreenShakeDuration = 0.5
ENT.ScreenShakeRange = 180

// DLight Settings

ENT.DLightBrightness = 1
ENT.DLightDecay = 5000
ENT.DLightSize = 200

ENT.DLightFlashOnRemove = true

ENT.DLightFlashSize = 250
ENT.DLightFlashDecay = 2000
ENT.DLightFlashBrightness = 2

DEFINE_BASECLASS(ENT.Base)

local nzombies = engine.ActiveGamemode() == "nzombies"
local dlight_cvar = GetConVar("cl_tfa_fx_wonderweapon_dlights")
local damage_cvar = GetConVar("sv_tfa_bo3ww_environmental_damage")
local SinglePlayer = game.SinglePlayer()

function ENT:SetupDataTables()
	BaseClass.SetupDataTables(self)

	self:NetworkVarTFA("Int", "AttackType")
end

function ENT:PhysicsCollide(data, phys)
	if self.Impacted then return end
	self.Impacted = true

	sound.Play("TFA_BO3_ZAPGUN.Flux", data.HitPos)

	local trace = self:CollisionDataToTrace(data)
	local direction = data.HitNormal
	local hitEntity = trace.Entity

	self:DoImpactEffect(trace)

	if IsValid(hitEntity) and TFA.WonderWeapon.ShouldDamage(hitEntity, self:GetOwner(), self) then
		local hitCharacter = (hitEntity:IsNPC() or hitEntity:IsNextBot() or hitEntity:IsPlayer())

		local hitDamage = DamageInfo()
		hitDamage:SetDamage(self:GetTrueDamage(hitEntity))
		hitDamage:SetAttacker(IsValid(self:GetOwner()) and self:GetOwner() or self)
		hitDamage:SetInflictor(IsValid(self.Inflictor) and self.Inflictor or self)
		hitDamage:SetDamageType(nzombies and DMG_SHOCK or bit.bor( DMG_SHOCK, DMG_NEVERGIB ))
		hitDamage:SetDamageForce(direction*2000)
		hitDamage:SetDamagePosition(trace.HitPos)
		hitDamage:SetReportedPosition(trace.StartPos)

		if nzombies and (hitEntity.NZBossType or hitEntity.IsMooBossZombie or hitEntity.IsMooMiniBoss) then
			hitDamage:SetDamage(math.max(400, ent:GetMaxHealth() / 24))
		end

		if trace.HitGroup == HITGROUP_HEAD then
			if hitCharacter then
				sound.Play("TFA_BO3_WAFFE.Pop", trace.HitPos)
				hitEntity:EmitSound("TFA_BO3_GENERIC.Gore")
			end
		else
			trace.HitGroup = HITGROUP_GENERIC
		end

		if ( hitCharacter ) then
			TFA.WonderWeapon.DoDeathEffect(hitEntity, "BO3_Wunderwaffe", math.Rand(4, 6), self:GetUpgraded(), trace.HitGroup == HITGROUP_HEAD)
		elseif ( damage_cvar == nil or damage_cvar:GetBool() ) then
			TFA.WonderWeapon.DoDeathEffect(hitEntity, "BO3_Wunderwaffe", math.Rand( 3, 4 ), self:GetUpgraded())
		end

		hitEntity:DispatchTraceAttack(hitDamage, trace, direction)

		self:SendHitMarker(hitEntity, hitDamage, trace)
	end

	if self:GetUpgraded() then
		ParticleEffect("bo3_zapgun_impact_pap", data.HitPos, data.HitNormal:Angle() - Angle(90,0,0))
	elseif self:GetAttackType() == 0 then
		ParticleEffect("bo3_zapgun_impact_left", data.HitPos, data.HitNormal:Angle() - Angle(90,0,0))
	else
		ParticleEffect("bo3_zapgun_impact_right", data.HitPos, data.HitNormal:Angle() - Angle(90,0,0))
	end

	TFA.WonderWeapon.ShockClientRagdolls( data.HitPos, 16, self:GetUpgraded() )

	self:ScreenShake(data.HitPos)

	self:PhysicsStop(phys)

	self:Remove()
end

function ENT:EntityCollide(trace)
	if self.Impacted then return end
	self.Impacted = true

	sound.Play("TFA_BO3_ZAPGUN.Flux", trace.HitPos)

	self:DoImpactEffect(trace)

	local hitEntity = trace.Entity
	local direction = trace.Normal

	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		direction = phys:GetVelocity():GetNormalized()
	end

	local hitCharacter = (hitEntity:IsNPC() or hitEntity:IsNextBot() or hitEntity:IsPlayer())

	local hitDamage = DamageInfo()
	hitDamage:SetDamage(self:GetTrueDamage(hitEntity))
	hitDamage:SetAttacker(IsValid(self:GetOwner()) and self:GetOwner() or self)
	hitDamage:SetInflictor(IsValid(self.Inflictor) and self.Inflictor or self)
	hitDamage:SetDamageType(nzombies and DMG_SHOCK or bit.bor( DMG_SHOCK, DMG_NEVERGIB ))
	hitDamage:SetDamageForce(direction*2000)
	hitDamage:SetDamagePosition(trace.HitPos)
	hitDamage:SetReportedPosition(trace.StartPos)

	if nzombies and (hitEntity.NZBossType or hitEntity.IsMooBossZombie or hitEntity.IsMooMiniBoss) then
		hitDamage:SetDamage(math.max(400, ent:GetMaxHealth() / 24))
	end

	if trace.HitGroup == HITGROUP_HEAD then
		if hitCharacter then
			sound.Play("TFA_BO3_WAFFE.Pop", trace.HitPos)
			hitEntity:EmitSound("TFA_BO3_GENERIC.Gore")
		end
	else
		trace.HitGroup = HITGROUP_GENERIC
	end

	if ( hitCharacter ) then
		local validHulls = {
			[HULL_HUMAN] = true,
			[HULL_WIDE_HUMAN] = true,
		}

		if hitEntity.Classify and hitEntity:Classify() == CLASS_ZOMBIE and ( !hitEntity.GetHullType or validHulls[hitEntity:GetHullType()] ) then
			hitEntity:EmitSound("TFA_BO3_WAFFE.Death")
		end

		TFA.WonderWeapon.DoDeathEffect(hitEntity, "BO3_Wunderwaffe", math.Rand(4, 6), self:GetUpgraded(), trace.HitGroup == HITGROUP_HEAD)
		
		sound.Play("TFA_BO3_WAFFE.Zap", trace.HitPos)
	elseif ( damage_cvar == nil or damage_cvar:GetBool() ) then
		TFA.WonderWeapon.DoDeathEffect(hitEntity, "BO3_Wunderwaffe", math.Rand( 3, 4 ), self:GetUpgraded())
	end

	hitEntity:DispatchTraceAttack(hitDamage, trace, direction)

	self:SendHitMarker(hitEntity, hitDamage, trace)

	if self:GetUpgraded() then
		ParticleEffect("bo3_zapgun_impact_pap", trace.HitPos, trace.HitNormal:Angle() - Angle(90,0,0))
	elseif self:GetAttackType() == 0 then
		ParticleEffect("bo3_zapgun_impact_left", trace.HitPos, trace.HitNormal:Angle() - Angle(90,0,0))
	else
		ParticleEffect("bo3_zapgun_impact_right", trace.HitPos, trace.HitNormal:Angle() - Angle(90,0,0))
	end

	self:ScreenShake(trace.HitPos)

	self:PhysicsStop()

	self:Remove()
end

function ENT:Initialize()
	BaseClass.Initialize(self)

	if self:GetUpgraded() then
		if !SinglePlayer or (SinglePlayer and SERVER) then
			ParticleEffectAttach("bo3_zapgun_pap_beam", PATTACH_ABSORIGIN_FOLLOW, self, 1)
		end

		self.Color = Color(190, 125, 255)
	elseif self:GetAttackType() == 0 then
		if !SinglePlayer or (SinglePlayer and SERVER) then
			ParticleEffectAttach("bo3_zapgun_left_beam", PATTACH_ABSORIGIN_FOLLOW, self, 1)
		end

		self.Color = Color(90, 90, 255)
	else
		if !SinglePlayer or (SinglePlayer and SERVER) then
			ParticleEffectAttach("bo3_zapgun_right_beam", PATTACH_ABSORIGIN_FOLLOW, self, 1)
		end

		self.Color = Color(255, 90, 90)
	end
end
