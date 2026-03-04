
AddCSLuaFile()

ENT.Base = "tfa_ww_base"
ENT.PrintName = "Yellow Lightning Ball"

ENT.MaxChain = 3
ENT.MaxChainPaP = 4

ENT.ZapRange = 120
ENT.ZapRangePaP = 140

ENT.ArcDelay = 0.25

ENT.Decay = 10

ENT.TargetsToIgnore = {} // Legacy

ENT.BounceSound = "TFA_BO3_WAFFE.Bounce"
ENT.SizzleSound = "TFA_BO3_WAFFE.Sizzle"
ENT.ZapEntitySound = "TFA_BO3_WAFFE.Zap"

// Effects
ENT.ImpactEffect = "bo4_dg1_impact"
ENT.ImpactEffectPaP = "bo4_dg1_impact_2"

ENT.ElectrocuteEffect = "bo4_dg1_electrocute"
ENT.ElectrocuteEffectPaP = "bo4_dg1_electrocute_2"

ENT.GroundEffect = "bo4_dg1_ground"
ENT.GroundEffectPaP = "bo4_dg1_ground_2"

// Default Settings

ENT.Delay = 10
ENT.Range = 128

ENT.NoDrawNoShadow = true

ENT.FindCharacterOnly = true

ENT.RemoveInWater = true

ENT.HullMaxs = Vector(0.5, 0.5, 0.5)
ENT.HullMins = ENT.HullMaxs:GetNegated()

ENT.BubbleTrail = false

// DLight Settings

ENT.Color = Color(255, 255, 0, 255)
ENT.ColorPaP = Color(255, 0, 255, 255)

ENT.DLightBrightness = 2
ENT.DLightDecay = 2000
ENT.DLightSize = 250

DEFINE_BASECLASS(ENT.Base)

local nzombies = engine.ActiveGamemode() == "nzombies"
local dlight_cvar = GetConVar("cl_tfa_fx_wonderweapon_dlights")

local BodyTarget = TFA.WonderWeapon.BodyTarget

function ENT:SetupDataTables()
	BaseClass.SetupDataTables(self)

	self:NetworkVarTFA("Bool", "HeadShot")
	self:NetworkVarTFA("Bool", "Activated")

	self:NetworkVarTFA("Entity", "Target")
	self:NetworkVarTFA("Entity", "Attacker")
	self:NetworkVarTFA("Entity", "Inflictor")

	self:NetworkVarTFA("Int", "Kills")
end

function ENT:Initialize()
	self:AddEFlags( EFL_NO_PHYSCANNON_INTERACTION )

	BaseClass.Initialize(self)

	self:SetNotSolid( true )
	self:SetSolid( SOLID_NONE )
	self:SetMoveType( MOVETYPE_NONE )

	local phys = self:GetPhysicsObject()
	if IsValid( phys ) then
		phys:AddGameFlag( FVPHYSICS_NO_PLAYER_PICKUP )
		phys:AddGameFlag( FVPHYSICS_CONSTRAINT_STATIC )

		phys:EnableMotion( false )
		phys:Sleep()
	end

	if self:GetUpgraded() then
		self.MaxChain = self.MaxChainPaP
		self.ZapRange = self.ZapRangePaP
	end

	if self:GetHeadShot() then
		self.MaxChain = self.MaxChain * 3
		self.ZapRange = self.ZapRange * 3 
	end

	if CLIENT then return end
	self:OnCollide()
end

function ENT:OnCollide()
	if not IsValid(self:GetTarget()) then
		self:Remove()
		return
	end

	self.BlockCollisionTrace = true

	self:SetKills(0)

	timer.Simple(0, function()
		if not IsValid(self) then return end

		local pEntity = self:GetTarget()
		if not IsValid(pEntity) or pEntity:Health() <= 0 then return end

		self:Zap(pEntity)
		self:SetKills(self:GetKills() + 1)
	end)

	local timername = self:EntIndex().."dg1shartsnfartz"
	timer.Create(timername, self.ArcDelay, self.MaxChain - 1, function()
		if not IsValid(self) then
			timer.Stop(timername)
			timer.Remove(timername)
			return
		end

		self:SetTarget(self:FindNearestEntity(self:GetPos(), self.ZapRange, self.TargetsToIgnore, true))

		if not IsValid(self:GetTarget()) then
			timer.Stop(timername)
			timer.Remove(timername)
			self:Remove()
			return
		end

		local tr = util.TraceLine({
			start = self:WorldSpaceCenter(),
			endpos = self:GetTarget():EyePos(),
			filter = {self, self:GetTarget(), self:GetOwner()},
			mask = MASK_SOLID_BRUSHONLY,
		}) //instead of removing if we hit a wall, just increase the decay penalty.

		self.ZapRange = self.ZapRange - (self.Decay * (tr.HitWorld and 3 or 1))
		self:Zap(self:GetTarget())
		self:SetKills(self:GetKills() + 1)

		if self:GetKills() >= self.MaxChain then
			timer.Stop(timername)
			timer.Remove(timername)

			self:Remove()
			return
		end
	end)
end

function ENT:Zap(ent)
	self.HeadShot = math.random(10) < 4
	self.HitPos = BodyTarget(ent, self:GetPos(), true, self.HeadShot)

	local ply = IsValid(self:GetOwner()) and self:GetOwner() or self

	local fx = EffectData()
	fx:SetStart(self:GetPos())
	fx:SetOrigin(self.HitPos)
	fx:SetFlags(self:GetUpgraded() and 1 or 0)

	util.Effect("tfa_bo4_dg1_jump", fx)

	if ( ent:IsNPC() or ent:IsNextBot() or ent:IsPlayer() ) then
		TFA.WonderWeapon.DoDeathEffect(ent, "BO4_Sniperwaffe", math.Rand( 4, 6 ), self:GetUpgraded(), self.HeadShot)
	else
		ParticleEffectAttach(self.ElectrocuteEffect, PATTACH_POINT_FOLLOW, ent, 1)
		if ent:OnGround() then
			ParticleEffectAttach(self.GroundEffect, PATTACH_ABSORIGIN_FOLLOW, ent, 1)
		end
	end

	local ply = IsValid(self:GetOwner()) and self:GetOwner() or self
	local upg = self:GetUpgraded()

	self:EmitSound(self.BounceSound)

	ent:EmitSound(self.SizzleSound)

	sound.Play(self.ZapEntitySound, self.HitPos)

	if self.HeadShot then
		if ent.GetBloodColor then
			local BloodParticle = TFA.WonderWeapon.ParticleByBloodColor[ent:GetBloodColor()]
			if BloodParticle then
				ParticleEffect(BloodParticle, self.HitPos, ent:EyeAngles())
			end
		end

		sound.Play("TFA_BO3_WAFFE.Pop", self.HitPos)
		sound.Play("TFA_BO3_GENERIC.Gore", self.HitPos)
	end

	local finalPos = self.HitPos
	timer.Simple(0, function()
		if not IsValid(self) then return end
		self:SetPos(finalPos)
	end)

	self:InflictDamage(ent)

	self:IgnoreEntity(ent, 1.5)
end

function ENT:InflictDamage(ent)
	if CLIENT then return end

	local flHitForce = 6000
	local flMass = 0

	for i=0, ent:GetPhysicsObjectCount() - 1 do
		local theirPhys = ent:GetPhysicsObjectNum(i)
		if IsValid( theirPhys ) then
			flMass = theirPhys:GetMass() + flMass
		end
	end

	if flMass > 5 then
		flHitForce = math.Clamp( flMass * 400, 1000, 30000 )
	end

	local damage = DamageInfo()
	damage:SetDamage(self:GetTrueDamage(ent))
	damage:SetAttacker(IsValid(self:GetAttacker()) and self:GetAttacker() or self)
	damage:SetInflictor(IsValid(self:GetInflictor()) and self:GetInflictor() or self)
	damage:SetDamageType(DMG_SHOCK)
	damage:SetDamageForce(ent:GetUp()*1000 + (ent:GetPos() - self:GetPos()):GetNormalized()*flHitForce)
	damage:SetDamagePosition(self.HitPos or ent:WorldSpaceCenter())
	damage:SetReportedPosition(self:GetPos())

	if nzombies and (ent.NZBossType or ent.IsMooBossZombie or ent.IsMooMiniBoss) then
		damage:SetDamage(math.max(1000, ent:GetMaxHealth() / 22))
	end

	if ent:IsNPC() and ent:HasCondition(COND.NPC_FREEZE) then
		ent:SetCondition(COND.NPC_UNFREEZE)
	end

	ent:TakeDamageInfo(damage)

	self:SendHitMarker(ent, damage)
end
