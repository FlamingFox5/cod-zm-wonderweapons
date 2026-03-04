
AddCSLuaFile()

ENT.Base = "tfa_ww_base"
ENT.PrintName = "WHATS COOLER THAN BEIN' COOL?"

// Default Settings

ENT.Delay = engine.TickInterval()

ENT.NoDrawNoShadow = true

ENT.HullMaxs = Vector(1, 1, 1)

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

	if !SinglePlayer or ( SERVER and SinglePlayer ) then
		local fx = EffectData()
		fx:SetOrigin(self:GetPos())
		fx:SetAngles(self:GetAngles())
		fx:SetEntity(self)
		fx:SetAttachment(1)

		util.Effect( "tfa_bo4_freezegun_blast", fx )
		//ParticleEffect("bo4_freezegun_blast", self:GetPos(), self:GetAngles())
	end
end
