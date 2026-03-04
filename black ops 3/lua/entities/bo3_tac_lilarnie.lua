
AddCSLuaFile()

ENT.Base = "tfa_ww_tacnade_base"
ENT.PrintName = "Lil' Squidy"

// Custom Settings

// Default Settings

ENT.ForcedKillTime = 20

ENT.Delay = 10

ENT.SizeOverride = 12

ENT.HullMaxs = Vector(4, 4, 4)
ENT.HullMins = ENT.HullMaxs:GetNegated()

ENT.BounceSound = "TFA_BO3_ARNIE.JarBounce"
ENT.BounceActivationSpeed = 100
ENT.BounceVelocityRatio = 0.4

ENT.DisablePhysicsOnActivate = true

ENT.ParentToMoveableEntities = true

ENT.ImpactBubbles = true
ENT.ImpactBubblesSize = 32
ENT.ImpactBubblesMagnitude = 0.5

// DLight Settings

ENT.Color = Color(140, 255, 100)
ENT.ColorPaP = Color(100, 10, 170)

ENT.DLightBrightness = 1
ENT.DLightDecay = 1000
ENT.DLightSize = 150

ENT.DLightFlashOnRemove = true

ENT.DLightFlashSize = 250
ENT.DLightFlashDecay = 2000
ENT.DLightFlashBrightness = 2

DEFINE_BASECLASS(ENT.Base)

function ENT:ActivateCustom(phys)
	timer.Simple( 0, function()
		if not IsValid( self ) then return end
		self:SetMoveType( MOVETYPE_NONE )
	end )

	self:SetActivated( true )
	self:Remove()
end

function ENT:CreateSquid()
	ParticleEffect("bo3_lilarnie_start", self:GetPos(), angle_zero)

	local arnie = ents.Create( "bo3_tac_lilarnie_squid" )
	arnie:SetModel( "models/weapons/tfa_bo3/octobomb/octobomb_arnie.mdl" )
	arnie:SetOwner( IsValid(self:GetOwner()) and self:GetOwner() or self )
	arnie:SetPos( self:GetPos() - Vector( 0, 0, 11 ) )
	arnie:SetAngles( self:GetRoll() - Angle( 0, 90, 0 ) )

	arnie:SetUpgraded( self:GetUpgraded() )
	arnie.Damage = self.mydamage
	arnie.mydamage = self.mydamage

	arnie:Spawn()
	arnie:DropToFloor()

	arnie:SetOwner( IsValid( self:GetOwner() ) and self:GetOwner() or self )
	arnie.Inflictor = IsValid( self.Inflictor ) and self.Inflictor or self

	if not self:IsMarkedForDeletion() then
		self:Remove()
	end
end

function ENT:OnRemove()
	BaseClass.OnRemove(self)

	if SERVER and self:GetActivated() then
		self:CreateSquid()
	end
end
