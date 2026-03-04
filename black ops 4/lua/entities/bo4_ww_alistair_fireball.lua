
AddCSLuaFile()

ENT.Base = "tfa_ww_base"
ENT.PrintName = "Incenerator"

// Custom Settings

ENT.Impacted = false

ENT.Life = 8

ENT.ActivateLoopSound = "TFA_BO4_ALISTAIR.Charged.FireLoop"
ENT.ActivateSound = "TFA_BO4_ALISTAIR.Charged.FireStart"
ENT.ActivateEndSound = "TFA_BO4_ALISTAIR.Charged.FireEnd"

// Default Settings

ENT.Delay = 10
ENT.Range = 140

ENT.NoDrawNoShadow = true

ENT.HullMaxs = Vector(1, 1, 1)
ENT.HullMins = ENT.HullMaxs:GetNegated()

ENT.TrailEffect = "bo4_alistairs_trail_fire"
ENT.TrailAttachType = PATTACH_ABSORIGIN_FOLLOW
ENT.TrailAttachPoint = 1

ENT.ImpactDecal = "Dark"

ENT.ImpactBubbles = true
ENT.ImpactBubblesSize = 64
ENT.ImpactBubblesMagnitude = 1

// DLight Settings

ENT.Color = Color(255, 60, 10, 255)

ENT.DLightSize = 250
ENT.DLightBrightness = 1
ENT.DLightDecay = 1000

ENT.DLightFlashOnRemove = true

ENT.DLightFlashSize = 300
ENT.DLightFlashDecay = 2000
ENT.DLightFlashBrightness = 2

DEFINE_BASECLASS(ENT.Base)

local nzombies = engine.ActiveGamemode() == "nzombies"
local SinglePlayer = game.SinglePlayer()

function ENT:SetupDataTables()
	BaseClass.SetupDataTables(self)

	self:NetworkVarTFA("Bool", "Activated")
end

function ENT:Draw(...)
	BaseClass.Draw( self, ... )

	self:AddDrawCallParticle("bo4_alistairs_fireball", PATTACH_ABSORIGIN_FOLLOW, 1, self:GetActivated())
end

function ENT:PhysicsCollide(data, phys)
	if self:GetActivated() then return end
	self:SetActivated(true)

	self:StopParticles()

	local trace = self:CollisionDataToTrace(data)
	local direction = data.OurOldVelocity:GetNormalized()
	local hitEntity = trace.Entity

	self:StoreCollisionEventData(data, trace)

	self:DoImpactEffect(trace)

	self:EmitSound( self.ActivateSound )

	self:EmitSound( self.ActivateLoopSound )

	ParticleEffect( "bo4_alistairs_impact_fireball", data.HitPos, ( -data.HitNormal ):Angle() )

	if trace.Hit and IsValid( hitEntity ) then
		timer.Simple( 0, function()
			if not IsValid( self ) then return end
			self:SetPos( data.HitPos - data.HitNormal )
		end )
	end

	self.killtime = CurTime() + self.Life
	self.DesiredPos = data.HitPos - data.HitNormal*50

	self:PhysicsStop( phys )
end

function ENT:Initialize( ... )
	BaseClass.Initialize( self, ... )

	self:DrawShadow( false )
end

function ENT:Think()
	if SERVER then
		if self:GetActivated() then
			if self:GetPos() ~= self.DesiredPos then
				self:SetPos(LerpVector(0.05, self:GetPos(), self.DesiredPos))
			end

			local ply = self:GetOwner()
			for k, v in pairs(ents.FindInSphere(self:GetPos(), self.Range)) do
				if v:IsNPC() or v:IsNextBot() or v:IsPlayer() then
					if v == ply then continue end
					if TFA.WonderWeapon.HasStatus(v, "BO4_Alistair_Fireball") then continue end
					if !TFA.WonderWeapon.ShouldDamage(v, ply, self) then continue end

					TFA.WonderWeapon.GiveStatus(v, "BO4_Alistair_Fireball", math.random(3,6)*0.5, self:GetOwner(), self.Inflictor)
				end
			end
		end
	end

	return BaseClass.Think(self)
end

function ENT:OnRemove()
	BaseClass.OnRemove(self)

	self:StopSound( self.ActivateLoopSound )

	if SERVER and self.killtime < CurTime() then
		self:EmitSound( self.ActivateEndSound )

		ParticleEffect( "bo4_alistairs_explode_fireball", self:GetPos(), angle_zero )
	end
end
