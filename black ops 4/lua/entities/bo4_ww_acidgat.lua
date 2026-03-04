AddCSLuaFile()

ENT.Base = "tfa_ww_base"
ENT.PrintName = "Acid Flechette"

// Custom Settings

ENT.Life = 3

// Default Settings

ENT.Delay = 10
ENT.Range = 140

ENT.DefaultModel = Model("models/weapons/tfa_bo4/acidgat/acidgat_projectile.mdl")

ENT.HullMaxs = Vector(1, 1, 1)
ENT.HullMins = ENT.HullMaxs:GetNegated()

ENT.ExplodeOnKilltimeEnd = true
ENT.ShouldLodgeProjectile = true
ENT.ShouldDropProjectile = true
ENT.ProjectileSpinOnDrop = true

ENT.DLightBrightness = 0
ENT.DLightDecay = 2000
ENT.DLightSize = 64

ENT.ParentOffset = 0

// Explosion Settings

ENT.ExplosionBubbles = true
ENT.ExplosionBubblesSize = 150
ENT.ExplosionBubblesMagnitude = 4

ENT.MaxExplosionBlockingMass = 350
ENT.ExplosionDamageType = DMG_RADIATION
ENT.ExplosionHeadShotScale = 7
ENT.ExplosionHitsOwner = true
ENT.ExplosionOwnerDamage = 45
ENT.ExplosionScreenShake = true

ENT.WaterBlockExplosions = false

ENT.ScreenShakeAmplitude = 5
ENT.ScreenShakeFrequency = 255
ENT.ScreenShakeDuration = 0.8
ENT.ScreenShakeRange = 240

ENT.ExplosionEffectAngleCorrection = Angle(-90,0,0)
ENT.ExplosionEffect = "bo4_acidgat_explode"

ENT.ExplosionSound = "TFA_BO4_BLUNDER.Acid.Explode"

// DLight Settings

ENT.Color = Color(50, 255, 50, 255)

ENT.DLightBrightness = 1
ENT.DLightDecay = 2000
ENT.DLightSize = 32

ENT.DLightFlashOnRemove = false

DEFINE_BASECLASS(ENT.Base)

local nzombies = engine.ActiveGamemode() == "nzombies"
local dlight_cvar = GetConVar("cl_tfa_fx_wonderweapon_dlights")

local SPRITE_OFFSET = Vector(0, 0, 0)

local ShouldDamage = TFA.WonderWeapon.ShouldDamage
local Impulse = TFA.WonderWeapon.CalculateImpulseForce

function ENT:SetupDataTables()
	BaseClass.SetupDataTables( self )

	self:NetworkVarTFA("Bool", "Activated")
end

function ENT:PhysicsCollide(data, phys)
	if self:GetActivated() then return end

	local trace = self:CollisionDataToTrace(data)
	local direction = data.OurOldVelocity:GetNormalized()
	local hitEntity = trace.Entity

	self:StoreCollisionEventData(data, trace)

	self:ActivateCustom(trace)

	self:LodgeProjectile(trace)

	if trace.Hit and IsValid(hitEntity) and ShouldDamage(hitEntity, self:GetOwner(), self) then
		local hitDamage = DamageInfo()
		hitDamage:SetDamage(10)
		hitDamage:SetAttacker(IsValid(self:GetOwner()) and self:GetOwner() or self)
		hitDamage:SetInflictor(IsValid(self.Inflictor) and self.Inflictor or self)
		hitDamage:SetDamageType(nzombies and DMG_BULLET or bit.bor(DMG_BULLET, DMG_AIRBOAT))
		hitDamage:SetDamageForce(direction*Impulse(hitEntity, 200))
		hitDamage:SetDamagePosition(trace.HitPos)
		hitDamage:SetReportedPosition(trace.StartPos)

		hitEntity:DispatchTraceAttack(hitDamage, trace, direction)

		self:SendHitMarker(hitEntity, hitDamage, trace)
	end
end

function ENT:EntityCollide(trace)
	if self:GetActivated() then return end

	self:ActivateCustom(trace)

	local hitEntity = trace.Entity
	local direction = trace.Normal

	local hitDamage = DamageInfo()
	hitDamage:SetDamage(10)
	hitDamage:SetAttacker(IsValid(self:GetOwner()) and self:GetOwner() or self)
	hitDamage:SetInflictor(IsValid(self.Inflictor) and self.Inflictor or self)
	hitDamage:SetDamageType(nzombies and DMG_BULLET or bit.bor(DMG_BULLET, DMG_AIRBOAT))
	hitDamage:SetDamageForce(direction*Impulse(hitEntity, 200))
	hitDamage:SetDamagePosition(trace.HitPos)
	hitDamage:SetReportedPosition(trace.StartPos)

	hitEntity:DispatchTraceAttack(hitDamage, trace, direction)

	self:SendHitMarker(hitEntity, hitDamage, trace)
end

function ENT:Initialize()
	BaseClass.Initialize(self)

	if CLIENT then return end

	self.DeathFalter = math.Rand(0.5,1)
end

function ENT:ActivateCustom(trace)
	self:SetActivated(true)

	local hitEntity = trace.Entity
	if IsValid(hitEntity) and ( hitEntity:IsNPC() or hitEntity:IsNextBot() ) then
		hitEntity:SetNW2Bool("OnAcid", true)

		if nzombies and hitEntity:IsValidZombie() and not ( hitEntity.NZBossType or hitEntity.IsMooBossZombie or hitEntity.IsMooMiniBoss ) then
			hitEntity:Freeze(3)
		end
	end

	self:DoImpactEffect(trace)

	ParticleEffect("bo4_acidgat_impact", trace.HitPos, (-self.HitNormal):Angle())

	if !self.HasIgnited then
		if nzombies and self:GetUpgraded() then
			self:SetTargetPriority( TARGET_PRIORITY_SPECIAL )
		end

		self.HasIgnited = true

		self.killtime = CurTime() + ( self:GetUpgraded() and math.Rand( 3, 4 ) or math.Rand( 2, 3 ) )
		self:EmitSound("TFA_BO4_BLUNDER.Acid.Fuse")

		local sprite = self:CreateGlowSprite( math.Clamp( self.killtime - CurTime(), 0, 4 ), self.Color, 255, 0.25 )
		if sprite then
			sprite:SetParent(self)
			sprite:SetLocalPos(SPRITE_OFFSET)
		end
	end
end

function ENT:Think()
	if SERVER then
		if not nzombies and self:GetActivated() and self:GetUpgraded() then
			self:MonkeyBomb()
			self:MonkeyBombNXB()
		end

		local p = self:GetParent()
		if IsValid(p) and (p:IsNPC() or p:IsNextBot()) and (!nzombies or (nzombies and !p.IsMooBossZombie and !p.NZBossType and !p.IsMooMiniBoss and !p.IsMooSpecialZombie)) and p:Health() > 0 and self.killtime - self.DeathFalter < CurTime() then
			local damage = DamageInfo()
			damage:SetDamage(p:Health() + 666)
			damage:SetAttacker(IsValid(ply) and ply or self)
			damage:SetInflictor(IsValid(self.Inflictor) and self.Inflictor or self)
			damage:SetDamageForce(p:GetUp()*10000)
			damage:SetDamagePosition(p:WorldSpaceCenter())
			damage:SetReportedPosition(self:GetPos())
			damage:SetDamageType(nzombies and DMG_MISSILEDEFENSE or DMG_NEVERGIB)

			p:SetHealth(1)

			TFA.WonderWeapon.DoDeathEffect(p, "BO3_Wavegun_Pop")

			p:TakeDamageInfo(damage)

			self:SendHitMarker(p, damage)

			if ( nzombies and ( p.IsAlive and p:IsAlive() or p:Alive() ) or p:Alive() ) then
				self:DropFromParent()
			end
		end
	end

	return BaseClass.Think(self)
end

function ENT:CallbackOnParent(trace)
	local hitEntity = trace.Entity

	if IsValid( hitEntity ) and hitEntity:IsNPC() then
		hitEntity:Ignite(0)
		if hitEntity:IsNPC() then
			hitEntity:SetCondition(COND.NPC_FREEZE)
		end
	end
end

function ENT:CallbackOnDrop(entity)
	if not self:GetActivated() then return end
	self:SetActivated(false)

	if IsValid( entity ) and entity:IsOnFire() then
		entity:Extinguish()
	end
end

function ENT:OnRemove()
	self:StopSound("TFA_BO4_BLUNDER.Acid.Fuse")

	local pEnt = self:GetParent()
	if IsValid(pEnt) and SERVER then
		if pEnt:IsNPC() then
			pEnt:SetCondition(COND.NPC_UNFREEZE)
		end

		if self.KillSelfString then
			pEnt:RemoveCallOnRemove(self.KillSelfString)
		end

		local bPassed = true
		for _, child in ipairs(pEnt:GetChildren()) do
			if child ~= self and child:GetClass() == self:GetClass() then
				bPassed = false
				break
			end
		end

		if bPassed and pEnt:GetNW2Bool("OnAcid") then
			pEnt:SetNW2Bool("OnAcid", false)
		end
	end
end
