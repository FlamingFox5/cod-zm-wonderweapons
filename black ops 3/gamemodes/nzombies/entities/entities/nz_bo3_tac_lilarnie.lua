
AddCSLuaFile()

ENT.Base = "tfa_exp_base"
ENT.PrintName = "Lil' Squidy (nZombies)"

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

ENT.Color = Color(185, 70, 255)
ENT.ColorPaP = Color(255, 40, 10)

ENT.DLightBrightness = 1
ENT.DLightDecay = 1000
ENT.DLightSize = 150

ENT.DLightFlashOnRemove = true

ENT.DLightFlashSize = 250
ENT.DLightFlashDecay = 2000
ENT.DLightFlashBrightness = 2

// nZombies Settings

ENT.NZThrowIcon = Material("vgui/icon/uie_t7_zm_hud_inv_icntact.png", "unlitgeneric smooth")

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

	if self:GetActivated() then
		self:CreateSquid()
	end
end
