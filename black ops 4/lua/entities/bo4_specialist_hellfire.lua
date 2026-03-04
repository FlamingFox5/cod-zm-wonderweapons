
AddCSLuaFile()

ENT.Base = "tfa_ww_base"
ENT.PrintName = "Hellfire Tornado"

// Default Settings

ENT.Delay = 20
ENT.Range = 60

ENT.NoDrawNoShadow = true

ENT.SizeOverride = 2

ENT.HullMaxs = Vector(32, 32, 64)
ENT.HullMins = Vector(-32, -32, 0)

ENT.StartSound = "TFA_BO4_HELLFIRE.Tornado.Start"

ENT.TrailSound = "TFA_BO4_HELLFIRE.Tornado.Loop"
ENT.TrailEffect = "bo4_hellfire_tornado"
ENT.TrailAttachType = PATTACH_ABSORIGIN_FOLLOW
ENT.TrailAttachPoint = 1

ENT.BubbleTrail = false

// DLight Settings

ENT.DLightBrightness = 0
ENT.DLightDecay = 2000
ENT.DLightSize = 250

ENT.Color = Color(255, 90, 0, 255)

DEFINE_BASECLASS( ENT.Base )

local nzombies = engine.ActiveGamemode() == "nzombies"

local Impulse = TFA.WonderWeapon.CalculateImpulseForce

function ENT:UpdateTransmitState()
	return self:GetActivated() and TRANSMIT_ALWAYS or TRANSMIT_PVS
end

function ENT:SetupDataTables()
	self:NetworkVar("Bool", 0, "Activated")
end

function ENT:EntityCollide(trace)
	local ply = self:GetOwner()

	local direction = trace.Normal
	local hitEntity = trace.Entity

	hitEntity:Ignite(4)

	if not (hitEntity:IsNPC() or hitEntity:IsPlayer() or hitEntity:IsNextBot() or hitEntity:IsRagdoll()) then
		util.Decal("Scorch", trace.HitPos, trace.HitPos + direction*4)
	end

	if hitEntity:IsPlayer() or hitEntity:IsNextBot() or hitEntity:IsNPC() then
		self:DoImpactEffect(trace)

		ParticleEffectAttach("bo4_alistairs_fireball_kill", PATTACH_POINT_FOLLOW, hitEntity, 0)

		sound.Play("TFA_BO4_ALISTAIR.Charged.FireExpl", trace.HitPos)
		hitEntity:EmitSound("TFA_BO4_HELLFIRE.Sizzle")

		local hitDamage = DamageInfo()
		hitDamage:SetDamage(hitEntity:Health() + 666)
		hitDamage:SetAttacker(IsValid(ply) and ply or self)
		hitDamage:SetInflictor(IsValid(self.Inflictor) and self.Inflictor or self)
		hitDamage:SetDamageType(nzombies and DMG_BURN or DMG_SLOWBURN)
		hitDamage:SetDamageForce(direction*Impulse(20))
		hitDamage:SetDamagePosition(trace.HitPos)
		hitDamage:SetReportedPosition(trace.StartPos)

		if trace.HitGroup == HITGROUP_HEAD then
			hitDamage:SetDamage(self.Damage*5)
		end

		if nzombies and (hitEntity.NZBossType or hitEntity.IsMooBossZombie or hitEntity.IsMooMiniBoss) then
			damage:SetDamage(math.max(1400, hitEntity:GetMaxHealth() / 12))
		end

		hitEntity:DispatchTraceAttack(hitDamage, trace, direction)
	end
end

function ENT:Initialize()
	BaseClass.Initialize(self)

	self:SetActivated(true)

	self:SetSolid(SOLID_VPHYSICS)
	self:SetMoveType(bit.bor(MOVETYPE_FLYGRAVITY, MOVECOLLIDE_FLY_BOUNCE))
	self:SetLocalVelocity(self:GetForward() * 100)

	self.LastStuckPos = self:GetPos()
	self.NextStuckThink = CurTime()
	self.StuckStrength = 0

	if CLIENT then return end

	self:DropToFloor()
end

function ENT:IsStuck()
	if CLIENT then return end

	if self.NextStuckThink < CurTime() then
		self.NextStuckThink = CurTime() + 0.1

		if self.LastStuckPos:Distance(self:GetPos()) < 10 then
			local strength = math.Clamp(self:GetPos():DistToSqr(self:GetOwner():GetEyeTrace().HitPos), 0, 200) / 50

			self.StuckStrength = self.StuckStrength + math.Clamp(strength, 1, 4)
		else
			self.StuckStrength = 0
		end

		self.LastStuckPos = self:GetPos()

		if self.StuckStrength >= 5 then
			return true
		elseif self.StuckStrength == 0 then
			local dt = util.QuickTrace(self:GetPos(), self:GetUp()*-10, self)
			if not dt.Hit then
				self:DropToFloor()
			end
		end
	end

	return false
end

function ENT:Think()
	if SERVER then
		local ply = self:GetOwner()
		if IsValid(ply) and self:GetActivated() then
			local tr = ply:GetEyeTrace()
			local norm = (tr.HitPos - self:GetPos()):GetNormalized()
			local fwd = Vector(norm.x,norm.y,0)

			if self:IsStuck() then
				self:SetPos(self:GetPos() + Vector(0,0,12))
			end

			self:SetLocalVelocity(fwd * 150)
		end

		util.ScreenShake(self:GetPos(), 4, 255, 0.1, 200)
	end

	return BaseClass.Think(self)
end

function ENT:OnRemove(...)
	BaseClass.OnRemove(self, ...)

	self:EmitSound("TFA_BO4_HELLFIRE.Tornado.End")
end