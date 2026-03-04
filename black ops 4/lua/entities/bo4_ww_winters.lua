
AddCSLuaFile()

ENT.Base = "tfa_ww_base"
ENT.PrintName = "WHATS COOLER THAN BEIN' COOL?"

// Default Settings

ENT.Delay = 0.24

ENT.NoDrawNoShadow = true

ENT.HullMaxs = Vector(1, 1, 1)
ENT.HullMins = ENT.HullMaxs:GetNegated()

ENT.TrailEffect = "bo4_freezegun_trail"
ENT.TrailAttachType = PATTACH_ABSORIGIN_FOLLOW
ENT.TrailAttachPoint = 1

ENT.StartSound = Sound("TFA_BO4_WINTERS.Wind")

ENT.BubbleTrail = false

// DLight Setings

ENT.Color = Color(245, 255, 255)

ENT.DLightBrightness = 1
ENT.DLightDecay = 5000
ENT.DLightSize = 400

DEFINE_BASECLASS(ENT.Base)

local nzombies = engine.ActiveGamemode() == "nzombies"

function ENT:Initialize(...)
	BaseClass.Initialize(self)

	self:SetNotSolid(true)
	self:SetSolid(SOLID_NONE)
	self:SetCollisionGroup(COLLISION_GROUP_WORLD)
end

function ENT:Think(...)
	if SERVER then
		local vecVel = self:GetVelocity()

		if !util.IsInWorld( self:GetPos() + vecVel:GetNormalized() * ( vecVel:Length() * engine.TickInterval()*2 ) ) then
			self:Remove()
			return false
		end
	end

	return BaseClass.Think(self, ...)
end
