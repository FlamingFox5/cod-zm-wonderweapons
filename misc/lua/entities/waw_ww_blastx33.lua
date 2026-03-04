AddCSLuaFile()

--[Info]--
ENT.Base = "tfa_ww_base"
ENT.PrintName = "Green Lightning"

--[Parameters]--
ENT.Delay = 10

ENT.ArcDelay = 1/3
ENT.ArcDelayPaP = 1/3
ENT.MaxChain = 9
ENT.MaxChainPaP = 12
ENT.ZapRange = 600
ENT.ZapRangePaP = 800

ENT.Decay = 35
ENT.Kills = 0

ENT.HullMaxs = Vector(1, 1, 1)
ENT.HullMins = ENT.HullMaxs:GetNegated()

ENT.FindCharacterOnly = true

DEFINE_BASECLASS(ENT.Base)

local pvp_cvar = GetConVar("sbox_playershurtplayers")
local nzombies = engine.ActiveGamemode() == "nzombies"

function ENT:SetupDataTables()
	self:NetworkVar("Bool", 0, "Upgraded")

	self:NetworkVar("Entity", 0, "Target")
	self:NetworkVar("Entity", 1, "Attacker")
	self:NetworkVar("Entity", 2, "Inflictor")

	self:NetworkVar("Vector", 0, "HitPos")
end

function ENT:PhysicsCollide(data, phys)
end

function ENT:Initialize(...)
	BaseClass.Initialize(self, ...)

	self:SetNotSolid(true)
	self:SetNoDraw(true)
	self:DrawShadow(false)

	self:SetSolid(SOLID_NONE)
	self:SetMoveType(MOVETYPE_NONE)

	self.TargetsToIgnore = {}

	if self:GetUpgraded() then
		self.ArcDelay = self.ArcDelayPaP
		self.MaxChain = self.MaxChainPaP
		self.ZapRange = self.ZapRangePaP
	end

	if SERVER then
		self:OnCollide()
	end
end

function ENT:OnCollide()
	if not IsValid(self:GetTarget()) then
		SafeRemoveEntity(self)
		return
	end

	self:Zap(self:GetTarget())
	self.Kills = 0

	local timername = self:EntIndex().."wawgreenkush"
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
			SafeRemoveEntity(self)
			return
		end

		local tr = util.TraceLine({
			start = self:GetPos(),
			endpos = self:GetTarget():EyePos(),
			filter = {self, self:GetTarget(), self:GetOwner()},
			mask = MASK_SOLID_BRUSHONLY,
		}) //instead of removing if we hit a wall, just increase the decay penalty.

		self.ZapRange = self.ZapRange - (self.Decay * (tr.HitWorld and 2 or 1))
		self:Zap(self:GetTarget())
		self.Kills = self.Kills + 1

		if self.Kills >= self.MaxChain then
			timer.Stop(timername)
			timer.Remove(timername)
			self:Remove()
			return
		end
	end)
end

function ENT:Zap(ent)
	local att = ent:GetAttachment(2) and ent:GetAttachment(2).Pos or ent:EyePos()

	util.ParticleTracerEx(self:GetUpgraded() and "waw_lightrifle_jump_2" or "waw_lightrifle_jump", self:GetPos(), att, false, self:GetOwner():EntIndex(), 0)

	local hitboxid
	local bone = ent:LookupBone("j_spineupper") or ent:LookupBone("ValveBiped.Bip01_Spine2") or ent:LookupBone("ValveBiped.Bip01_Spine")
	if !bone then
		for i = 0, ent:GetHitBoxCount(0) do
			local hitgroup = ent:GetHitBoxHitGroup(i,0)
			if (hitgroup == HITGROUP_HEAD) then
				hitboxid = i
				bone = ent:GetHitBoxBone(i, 0)
				break
			end
		end

		if !bone then
			for i = 0, ent:GetHitBoxCount(0) do
				local hitgroup = ent:GetHitBoxHitGroup(i,0)
				if (hitgroup == HITGROUP_GENERIC) then
					hitboxid = i
					bone = ent:GetHitBoxBone(i, 0)
					break
				end
			end
		end
	else
		for i = 0, ent:GetHitBoxCount(0) do
			if ent:GetHitBoxBone(i,0) == bone then
				hitboxid = i
				break
			end
		end
	end

	local finalPos = ent:EyePos()
	if bone then
		finalPos = ent:GetBonePosition(bone)
	end

	local offset = vector_origin
	if hitboxid then
		local mins, maxs = ent:GetHitBoxBounds(hitboxid, 0)
		offset:Set(Vector(math.random(mins[1], maxs[1]), math.random(mins[2], maxs[2]), math.random(mins[3], maxs[3])))

		finalPos = finalPos + offset
	end

	self.HitPos = finalPos

	local fx = EffectData()
	fx:SetStart(self:GetPos())
	fx:SetOrigin(finalPos)
	fx:SetFlags(self:GetUpgraded() and 1 or 0)

	util.Effect("tfa_bo3_waffe_jump", fx)

	self:EmitSound("TFA_BO3_WAFFE.Jump")
	ent:EmitSound("weapons/tfa_bo3/wunderwaffe/projectile/wpn_tesla_jump.wav", SNDLVL_NORM, math.random(95,105), 1, CHAN_STATIC)

	timer.Simple(0, function()
		if not IsValid(self) then return end
		self:SetPos(finalPos)
	end)

	ent:WAWBlastXInfect(math.Rand(2,4), self:GetAttacker(), self:GetInflictor(), self:GetUpgraded())

	self.TargetsToIgnore[ent] = true
end

function ENT:DoIncludeNearbyEntity(pEntity, ...)
	if pEntity:WAWIsBlastXInfected() then
		return true // block including infected entities
	end
end
