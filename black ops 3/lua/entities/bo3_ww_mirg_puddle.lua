
AddCSLuaFile()

ENT.Base = "tfa_ww_base"
ENT.PrintName = "Infectious Puddle"

// Custom Settings

ENT.AtkDelay = 0.2
ENT.AtkDelayPaP = 0.2

// Default Settings

ENT.Delay = 3
ENT.DelayPaP = 5

ENT.InfiniteDamage = true
ENT.NoDrawNoShadow = true
ENT.RemoveInWater = true

ENT.TrailSound = "TFA_BO3_MIRG.Slime"
ENT.TrailEffect = "bo3_mirg2k_puddle"
ENT.TrailEffectPaP = "bo3_mirg2k_puddle_2"
ENT.TrailAttachType = PATTACH_ABSORIGIN_FOLLOW
ENT.TrailAttachPoint = 1

ENT.HullMaxs = Vector(28, 28, 8)
ENT.HullMins = Vector(-28, -28, 0)

// DLight Settigns

ENT.Color = Color(65, 235, 20)
ENT.ColorPaP = Color(0, 255, 235)

ENT.DLightBrightness = 0
ENT.DLightDecay = 2000
ENT.DLightSize = 128

DEFINE_BASECLASS(ENT.Base)

local nzombies = engine.ActiveGamemode() == "nzombies"
local dlight_cvar = GetConVar("cl_tfa_fx_wonderweapon_dlights")

local HasStatus = TFA.WonderWeapon.HasStatus
local GiveStatus = TFA.WonderWeapon.GiveStatus
local NotifyAchievement = TFA.WonderWeapon.NotifyAchievement
local ShouldDamage = TFA.WonderWeapon.ShouldDamage

function ENT:SetupDataTables()
	BaseClass.SetupDataTables(self)

	self:NetworkVarTFA("Bool", "Upgraded")
	self:NetworkVarTFA("Int", "Charge")
end

if SERVER then
	function ENT:GravGunPickupAllowed()
		return false
	end
end

function ENT:GravGunPunt()
	return false
end

function ENT:PhysicsCollide(data, phys)
end

function ENT:Initialize(...)
	BaseClass.Initialize(self, ...)

	self:SetMoveType( MOVETYPE_NONE )
	self:SetCollisionGroup( COLLISION_GROUP_IN_VEHICLE )

	self:PhysicsStop()

	self.CoolDown = CurTime()

	if self:GetUpgraded() then
		self.Delay = self.DelayPaP or self.Delay
		self.AtkDelay = self.AtkDelayPaP or self.AtkDelay
	end

	self.killtime = CurTime() + (self.Delay * self:GetCharge())

	local tr1 = util.TraceLine({
		start = self:WorldSpaceCenter(),
		endpos = self:WorldSpaceCenter() - Vector(0, 0, 1024),
		filter = self,
		mask = MASK_SOLID_BRUSHONLY,
	})

	self:SetPos(tr1.HitPos + vector_up)
	self:SetAngles(tr1.HitNormal:Angle() + Angle(90,0,0))

	if CLIENT then
		self.DLightSize = ( math.random(100) > 60 ) and 128 or 0
	end
end

function ENT:Think()
	if SERVER then
		local ply = self:GetOwner()
		if not IsValid(ply) then
			self:Remove()
			return false
		end
	end

	return BaseClass.Think(self)
end

function ENT:EntityCollide(trace)
	if self.CoolDown and self.CoolDown > CurTime() then return end

	local ply = self:GetOwner()
	local hitEntity = trace.Entity
	if not HasStatus(hitEntity, "BO3_KT4_Infection") and ( hitEntity:IsNPC() or hitEntity:IsNextBot() or hitEntity:IsPlayer() ) then
		if nzombies and (hitEntity.NZBossType or hitEntity.IsMooBossZombie or hitEntity.IsMooMiniBoss) then return end
		if !ShouldDamage(hitEntity, ply, self) then return end

		GiveStatus(hitEntity, "BO3_KT4_Infection", ( nzombies and nzPowerUps:IsPowerupActive("insta") ) and 0.5 or math.Rand( 1, 2 ), self:GetOwner(), self.Inflictor, self:GetTrueDamage( hitEntity ), self:GetUpgraded())

		if IsValid( ply ) and ply:IsPlayer() then
			NotifyAchievement( "BO3_KT4_Infection", ply, hitEntity )
		end

		self.CoolDown = CurTime() + self.AtkDelay + math.Rand(-0.1,0.1)
	end
end
