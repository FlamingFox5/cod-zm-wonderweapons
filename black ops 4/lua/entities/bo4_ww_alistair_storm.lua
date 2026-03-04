
AddCSLuaFile()

ENT.Base = "tfa_ww_base"
ENT.PrintName = "Wind Storm"

// Custom Settings

ENT.ActivateLoopSound = "TFA_BO4_ALISTAIR.Charged.WindLoop"
ENT.ActivateEndSound = "TFA_BO4_ALISTAIR.Charged.WindEnd"

ENT.Life = 10

ENT.TornadoEnts = {}

// Default Settings

ENT.Delay = 10
ENT.Range = 150

ENT.HullMaxs = Vector(1, 1, 1)
ENT.HullMins = ENT.HullMaxs:GetNegated()

ENT.NoDrawNoShadow = true

ENT.TrailEffect = "bo4_alistairs_trail_storm"
ENT.TrailAttachType = PATTACH_ABSORIGIN_FOLLOW
ENT.TrailAttachPoint = 1

ENT.ImpactDecal = "Dark"

ENT.ImpactBubbles = true
ENT.ImpactBubblesSize = 256
ENT.ImpactBubblesMagnitude = 2

// DLight Settings

ENT.Color = Color(159, 215, 255, 255)

ENT.DLightSize = 200
ENT.DLightBrightness = 2
ENT.DLightDecay = 1000

DEFINE_BASECLASS(ENT.Base)

local nzombies = engine.ActiveGamemode() == "nzombies"
local SinglePlayer = game.SinglePlayer()
local sv_true_damage = GetConVar("sv_tfa_bo3ww_cod_damage")

local GiveStatus = TFA.WonderWeapon.GiveStatus
local HasStatus = TFA.WonderWeapon.HasStatus
local GetStatus = TFA.WonderWeapon.GetStatus
local ShouldDamage = TFA.WonderWeapon.ShouldDamage
local Impulse = TFA.WonderWeapon.CalculateImpulseForce

function ENT:SetupDataTables()
	BaseClass.SetupDataTables(self)

	self:NetworkVarTFA("Bool", "Activated")
end

function ENT:Draw(...)
	BaseClass.Draw( self, ... )

	self:AddDrawCallParticle("bo4_alistairs_storm", PATTACH_ABSORIGIN_FOLLOW, 1, self:GetActivated())
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
	self:SetAngles(angle_zero)

	ParticleEffect("bo4_alistairs_impact_storm", data.HitPos, data.HitNormal:Angle() - Angle(90,0,0))

	if trace.Hit and IsValid( hitEntity ) then
		timer.Simple( 0, function()
			if not IsValid( self ) then return end

			local tr = util.QuickTrace( data.HitPos, vector_up * -200, self )

			if tr.Hit and tr.HitWorld then
				self:SetPos( tr.HitPos )
			else
				self:SetPos( data.HitPos )
			end
		end )
	end

	self.killtime = CurTime() + self.Life

	self:PhysicsStop(phys)
end

function ENT:Think()
	if SERVER then
		if self:GetActivated() then
			local pos = self:GetPos()
			local ply = self:GetOwner()

			for k, v in pairs(ents.FindInSphere(pos, self.Range)) do
				if v:IsNPC() or v:IsNextBot() then
					if v == ply then continue end
					if HasStatus("BO4_Alistair_Tornado", v) then continue end
					if !ShouldDamage(v, ply, self) then continue end

					local vpos = v:GetPos()

					if v:IsNPC() then
						v:SetGroundEntity(NULL)

						local pushDir = (vpos - pos):GetNormalized()
						local magnitude = -15
						local vecPush = magnitude * pushDir
						if bit.band(v:GetFlags(), FL_BASEVELOCITY) != 0 then
							vecPush = vecPush + v:GetBaseVelocity()
						end

						v:SetVelocity(vecPush)
					end

					if v:IsNextBot() then
						if not nzombies then
							v.loco:FaceTowards(pos)
							v.loco:SetVelocity((pos - vpos):GetNormalized() * 250)
						end
						v.loco:Approach(pos, 99)
					end

					if nzombies and (v.NZBossType or v.IsMooBossZombie or v.IsMooMiniBoss) then continue end

					if vpos:DistToSqr(pos) < 3600 then
						if nzombies then
							GiveStatus( v, "BO4_Alistair_Tornado", math.Rand(4.5,5.5), self:GetOwner(), self.Inflictor )
							table.insert(self.TornadoEnts, v)
						else
							self:InflictDamage(v)
						end
					end
				end
			end
		end
	end

	return BaseClass.Think(self)
end

function ENT:InflictDamage(ent)
	local damage = DamageInfo()
	damage:SetDamage( ( sv_true_damage and sv_true_damage:GetBool() or nzombies ) and entity:Health() + 666 or self.Damage )
	damage:SetAttacker( IsValid(self:GetOwner()) and self:GetOwner() or self )
	damage:SetInflictor( IsValid(self.Inflictor) and self.Inflictor or self )
	damage:SetDamageType( DMG_ALWAYSGIB )
	damage:SetDamagePosition( ent:WorldSpaceCenter() )
	damage:SetDamageForce( ( self:GetPos() - ent:GetPos() ):GetNormalized() * Impulse(ent, 10) + vector_up*math.random(20000,32000) )
	damage:SetReportedPosition( self:GetPos() )

	if damage:GetDamage() >= ent:Health() and ent:IsNPC() then
		ent:SetCondition( COND.NPC_UNFREEZE )
	end

	ent:TakeDamageInfo( damage )

	self:SendHitMarker( ent, damage )
end

function ENT:OnRemove()
	self:StopSound(self.ActivateLoopSound)
	self:EmitSound(self.ActivateEndSound)

	if SERVER and nzombies then
		for k, v in pairs(self.TornadoEnts) do
			if IsValid(v) and v:IsValidZombie() and v:Health() > 0 then
				local mStatus = GetStatus(v, "BO4_Alistair_Tornado")
				if mStatus and mStatus:GetEndTime() > CurTime() then
					mStatus:SetEndTime(CurTime())
				end
			end
		end
	end
end