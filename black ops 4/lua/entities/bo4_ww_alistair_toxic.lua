
AddCSLuaFile()

ENT.Base = "tfa_ww_base"
ENT.PrintName = "Golden Shower"

// Custom Settings

ENT.ActivateLoopSound = "TFA_BO4_ALISTAIR.Charged.Toxic"
ENT.Life = 8

// Default Settings

ENT.Delay = 10
ENT.Range = 100

ENT.NoDrawNoShadow = true

ENT.HullMaxs = Vector(1, 1, 1)
ENT.HullMins = ENT.HullMaxs:GetNegated()

ENT.TrailEffect = "bo4_alistairs_trail_toxic"
ENT.TrailAttachType = PATTACH_ABSORIGIN_FOLLOW
ENT.TrailAttachPoint = 1

ENT.ImpactDecal = "Dark"

ENT.ImpactBubbles = true
ENT.ImpactBubblesSize = 256
ENT.ImpactBubblesMagnitude = 2

// DLight Settings

ENT.Color = Color(255, 200, 10, 255)

ENT.DLightSize = 200
ENT.DLightBrightness = 2
ENT.DLightDecay = 1000

DEFINE_BASECLASS(ENT.Base)

local nzombies = engine.ActiveGamemode() == "nzombies"

local GiveStatus = TFA.WonderWeapon.GiveStatus
local HasStatus = TFA.WonderWeapon.HasStatus
local ShouldDamage = TFA.WonderWeapon.ShouldDamage

function ENT:SetupDataTables()
	BaseClass.SetupDataTables(self)

	self:NetworkVarTFA("Bool", "Activated")
end

function ENT:Draw(...)
	BaseClass.Draw( self, ... )

	self:AddDrawCallParticle("bo4_alistairs_toxic", PATTACH_ABSORIGIN_FOLLOW, 1, self:GetActivated())
end

function ENT:PhysicsCollide(data, phys)
	if self:GetActivated() then return end
	self:SetActivated(true)

	self:StopParticles()

	local trace = self:CollisionDataToTrace(data)
	local direction = data.OurOldVelocity:GetNormalized()
	local hitEntity = trace.Entity

	self:StoreCollisionEventData(data, trace)

	self:EmitSound(self.ActivateLoopSound)
	self:SetAngles(data.HitNormal:Angle())

	ParticleEffect("bo4_alistairs_impact_toxic", data.HitPos, data.HitNormal:Angle() - Angle(90,0,0))

	if trace.Hit and IsValid( hitEntity ) then
		timer.Simple( 0, function()
			if not IsValid( self ) then return end

			self:SetPos( data.HitPos )
		end )
	end

	self:DoImpactEffect(trace)

	self.killtime = CurTime() + self.Life

	self:PhysicsStop( phys )
end

function ENT:Initialize()
	BaseClass.Initialize(self)

	self:DrawShadow(false)
end

function ENT:Think()
	if SERVER then
		local ply = self:GetOwner()
		if self:GetActivated() then
			for k, v in pairs(ents.FindInSphere(self:GetPos(), self.Range)) do
				if not (v:IsNPC() or v:IsNextBot()) then continue end

				if v == ply then continue end
				if HasStatus(v, "BO4_Alistair_Toxic") then continue end
				if nzombies and (v.NZBossType or v.IsMooBossZombie or v.IsMooMiniBoss) then continue end
				if ShouldDamage(v, ply, self) then continue end

				GiveStatus(v, "BO4_Alistair_Toxic", math.Rand(2, 4), self:GetOwner(), self.Inflictor)
			end
		end
	end

	return BaseClass.Think(self)
end

function ENT:OnRemove()
	self:StopParticles()
end
