
AddCSLuaFile()

ENT.Base = "tfa_ww_base"
ENT.PrintName = "Void"

// Custom Settings

ENT.Life = 7
ENT.NextAttack = 0

ENT.ActivateLoopSound = "TFA_BO4_ALISTAIR.Charged.ShrinkLoop"
ENT.ActivateEndSound = "TFA_BO4_ALISTAIR.Charged.ShrinkEnd"

// Default Settings

ENT.Delay = 10
ENT.Range = 100

ENT.NoDrawNoShadow = true

ENT.HullMaxs = Vector(1, 1, 1)
ENT.HullMins = ENT.HullMaxs:GetNegated()

ENT.TrailEffect = "bo4_alistairs_trail_shrink"
ENT.TrailAttachType = PATTACH_ABSORIGIN_FOLLOW
ENT.TrailAttachPoint = 1

ENT.ImpactDecal = "Dark"

ENT.ImpactBubbles = true
ENT.ImpactBubblesSize = 256
ENT.ImpactBubblesMagnitude = 2

// DLight Settings

ENT.Color = Color(20, 255, 5, 255)

ENT.DLightSize = 200
ENT.DLightBrightness = 1
ENT.DLightDecay = 1000

DEFINE_BASECLASS(ENT.Base)

local nzombies = engine.ActiveGamemode() == "nzombies"
local SinglePlayer = game.SinglePlayer()

function ENT:SetupDataTables()
	BaseClass.SetupDataTables(self)

	self:NetworkVarTFA("Bool", "Activated")
end

function ENT:Draw(...)
	BaseClass.Draw( self, ... )

	self:AddDrawCallParticle("bo4_alistairs_shrink", PATTACH_ABSORIGIN_FOLLOW, 1, self:GetActivated())
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

	self:EmitSound(self.ActivateLoopSound)
	self:SetAngles(data.HitNormal:Angle())

	ParticleEffect( "bo4_alistairs_impact_shrink", data.HitPos, trace.HitNormal:Angle() - Angle(90, 0, 0) )

	if trace.Hit and IsValid( hitEntity ) then
		timer.Simple( 0, function()
			if not IsValid( self ) then return end

			self:SetPos( data.HitPos )
		end )
	end

	self.killtime = CurTime() + self.Life

	self:PhysicsStop(phys)
end

function ENT:Initialize(...)
	BaseClass.Initialize(self, ...)

	self:DrawShadow( false )
end

function ENT:Think()
	if SERVER then
		if self:GetActivated() and self.NextAttack < CurTime() then
			local ply = self:GetOwner()

			local range = self.Range + ( math.sin( CurTime() * 2 ) * 20 )

			for k, v in pairs( ents.FindInSphere( self:GetPos(), range ) ) do
				if v:IsNPC() or v:IsNextBot() then
					if v == ply then continue end
					if TFA.WonderWeapon.HasStatus(v, "BO4_Alistair_Shrink") then continue end
					if !TFA.WonderWeapon.ShouldDamage(v, ply, self) then continue end

					if nzombies and (v.NZBossType or v.IsMooBossZombie or v.IsMooMiniBoss) then continue end

					TFA.WonderWeapon.GiveStatus(v, "BO4_Alistair_Shrink", 1, ply, self.Inflictor)

					self.NextAttack = CurTime() + 0.05

					if IsValid(ply) and ply:IsPlayer() then
						TFA.WonderWeapon.NotifyAchievement( "BO4_Alistair_Shrink_Kills", ply, v, self )
					end
				end
			end
		end
	end

	return BaseClass.Think(self)
end

function ENT:OnRemove()
	self:StopSound(self.ActivateLoopSound)
	self:EmitSound(self.ActivateEndSound)
end