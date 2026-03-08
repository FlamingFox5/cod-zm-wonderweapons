
AddCSLuaFile()

ENT.Base = "tfa_ww_tacnade_base"
ENT.PrintName = "Black Hole"

// Custom Settings

ENT.BlackHoleStart = "TFA_BO3_GERSCH.BHStart"

ENT.BlackHoleLoopFar = Sound("TFA_BO3_GERSCH.BHLoopFar")
ENT.BlackHoleLoopClose = Sound("TFA_BO3_GERSCH.BHLoopClose")

ENT.BlackHoleEnding = "TFA_BO3_GERSCH.BHPrePop"
ENT.BlackHoleCollapse = "TFA_BO3_GERSCH.BHPop"

ENT.Kills = 0

// Default Settings

ENT.ForcedKillTime = 30

ENT.Delay = 8
ENT.DelayPaP = 16

ENT.HullMaxs = Vector(1, 1, 1)
ENT.HullMins = ENT.HullMaxs:GetNegated()

ENT.BounceSound = "TFA_BO3_GERSCH.Bounce"
ENT.BounceActivationSpeed = 100
ENT.BounceVelocityRatio = 0.4

ENT.ImpactBubbles = true
ENT.ImpactBubblesSize = 32
ENT.ImpactBubblesMagnitude = 0.5

// DLight Settings

ENT.Color = Color(185, 70, 255)
ENT.ColorPaP = Color(255, 40, 10)

ENT.DLightBrightness = 2
ENT.DLightDecay = 1000
ENT.DLightSize = 500

ENT.DLightOnActivated = true

ENT.DLightFlashOnRemove = true

ENT.DLightFlashSize = 500
ENT.DLightFlashDecay = 2000
ENT.DLightFlashBrightness = 2

DEFINE_BASECLASS(ENT.Base)

local DoDeathEffect = TFA.WonderWeapon.DoDeathEffect
local HasDeathEffect = TFA.WonderWeapon.HasDeathEffect

local CLIENT_RAGDOLLS = {
	["class C_ClientRagdoll"] = true,
	["class C_HL2MPRagdoll"] = true,
}

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end

function ENT:SetupDataTables()
	BaseClass.SetupDataTables(self)

	self:NetworkVarTFA("Bool", "Dying")

	self:NetworkVarTFA("Vector", "TelePos")
end

function ENT:ActivateCustom( phys )
	if CLIENT then return end

	self:SetActivated(true)

	timer.Simple(0, function()
		if not IsValid(self) then return end

		self:SetMoveType(MOVETYPE_NONE)
	end)

	util.ScreenShake(self:GetPos(), 10, 255, 1, 512)

	self:CreateCore()

	self:CreateExitCore()

	local magnet = self:GetRagdollMagnet( Vector( 0, 0, 64 ), 800, 400 )
	if IsValid( magnet ) then
		magnet:Fire("Enable")
	end

	self.killtime = CurTime() + self.Delay

	/*if game.GetMap() == "nz_moon" then //i dont know how to do this, and why it wont work
		local plate = ents.FindByName("plates_urt_trigger")[1]
		local filter = ents.FindByName('gersh_filter')[1]
		if IsValid(plate) and IsValid(filter) then
			plate:Fire("OnTrigger", "", 2.5, filter, filter)
		end
	end*/
end

function ENT:CreateCore()
	local core = ents.Create("prop_dynamic")
	core:SetModel("models/dav0r/hoverball.mdl")
	core:SetModelScale(0.4, 0)
	core:SetPos(self:GetPos() + Vector(0,0,64))
	core:SetAngles(angle_zero)
	core:SetParent(self)
	core:SetMoveType(MOVETYPE_NONE)

	core:Spawn()

	self:DeleteOnRemove(core)

	timer.Simple(0, function()
		core:SetCollisionGroup(COLLISION_GROUP_NONE)
		core:SetSolid(SOLID_NONE)
	end)
	core:SetMaterial("models/weapons/tfa_bo3/gersch/lambert1")

	self.CoreMDL = core

	self.CoreMDL:EmitSound(self.BlackHoleStart)
	self.CoreMDL:EmitSound(self.BlackHoleLoopFar)
	self.CoreMDL:EmitSound(self.BlackHoleLoopClose)

	ParticleEffectAttach(self:GetUpgraded() and "bo3_gersch_loop_pap" or "bo3_gersch_loop", PATTACH_ABSORIGIN_FOLLOW, self.CoreMDL, 0)
end

function ENT:CreateExitCore()
	local core2 = ents.Create("prop_dynamic")
	core2:SetModel("models/dav0r/hoverball.mdl")
	core2:SetModelScale(0.4, 0)
	core2:SetPos(self:GetTelePos() + Vector(0,0,64))
	core2:SetAngles(angle_zero)
	core2:SetParent(self)
	core2:SetMoveType(MOVETYPE_NONE)

	core2:Spawn()

	self:DeleteOnRemove(core2)

	timer.Simple(0, function()
		core2:SetCollisionGroup( COLLISION_GROUP_NONE )
		core2:SetSolid( SOLID_NONE )
	end)

	core2:SetMaterial("models/weapons/tfa_bo3/gersch/lambert1")

	self.CoreMDL2 = core2

	self.CoreMDL2:EmitSound(self.BlackHoleLoopClose)

	ParticleEffectAttach(self:GetUpgraded() and "bo3_gersch_loop_2_pap" or "bo3_gersch_loop_2", PATTACH_ABSORIGIN_FOLLOW, self.CoreMDL2, 0)
end

function ENT:Initialize(...)
	BaseClass.Initialize(self, ...)

	if CLIENT then return end

	self:ConstructTeleportPos()
end

function ENT:Think()
	if CLIENT then
		if self:GetActivated() then
			for _, ent in ipairs( ents.FindInSphere( self:GetPos() + ( vector_up * 64 ), 42 ) ) do
				if CLIENT_RAGDOLLS[ ent:GetClass() ] or ent:IsRagdoll() and not HasDeathEffect( ent, "BO3_Gersh_Soul" ) then
					DoDeathEffect( ent, "BO3_Gersh_Soul" )
				end
			end
		end
	end

	if SERVER then
		local core = self.CoreMDL
		if self:GetActivated() and IsValid(core) then
			local ply = self:GetOwner()
			local pos = self:GetPos()

			for k, v in pairs(ents.FindInSphere(core:GetPos(), 1024)) do
				if v == ply then continue end

				if v:IsNPC() then
					v:SetGroundEntity(nil)

					v:SetVelocity( ( pos - v:GetPos() ):GetNormalized() * 10 )
				end

				if v:IsNextBot() then
					v:SetGroundEntity( nil )

					v.loco:SetVelocity( ( pos - v:GetPos() ):GetNormalized() * 200 )
				end
			end

			if self:GetActivated() then
				self:MonkeyBombNXB()
				self:MonkeyBomb()

				util.ScreenShake(core:GetPos(), 2, 255, 0.4, 120)
			end

			local killtrigger = ents.FindInSphere(core:GetPos(), 42)
			for k, v in pairs(killtrigger) do
				if ( v:IsNPC() or v:IsNextBot() ) and TFA.WonderWeapon.ShouldDamage( v, self:GetOwner(), self ) then
					self:InflictDamage(v)
				end

				if v:IsPlayer() and not v:IsOnGround() and math.abs(v:GetVelocity()[3]) > 0 then //fix for... something
					local vel = v:GetVelocity()
					v:SetPos(self:GetTelePos() + Vector(0,0,4))
					v:SetGroundEntity(nil)
					v:SetLocalVelocity(vel)

					sound.Play("TFA_BO3_GERSCH.Teleport", core:GetPos())
					v:EmitSound("TFA_BO3_GERSCH.TeleOut")

					ParticleEffectAttach("bo3_gersch_player_insanity", PATTACH_ABSORIGIN_FOLLOW, v, 1)
				end
			end
		end

		if self:GetDying() and self.CoreMDL and IsValid(self.CoreMDL) then
			self:SetPos(self:GetPos() + vector_up*0.7)
		end

		if self:GetActivated() and ( self.killtime - 1.4 ) < CurTime() and !self:GetDying() then
			self:EmitSound(self.BlackHoleEnding)

			if self.CoreMDL and IsValid(self.CoreMDL) then
				self.CoreMDL:StopSound(self.BlackHoleLoopFar)
				self.CoreMDL:StopSound(self.BlackHoleLoopClose)
				self.CoreMDL:StopParticles()
				self.CoreMDL:SetParent(nil)
			end

			if self.CoreMDL2 and IsValid(self.CoreMDL2) then
				self.CoreMDL2:SetParent(nil)
			end

			ParticleEffectAttach(self:GetUpgraded() and "bo3_gersch_end_pap" or "bo3_gersch_end", PATTACH_ABSORIGIN_FOLLOW, self.CoreMDL, 0)

			SafeRemoveEntityDelayed(self, 1.4)
			self:SetModelScale(0.1, 1.4)

			self:SetDying(true)
		end
	end

	return BaseClass.Think(self)
end

function ENT:InflictDamage(ent)
	local ply = self:GetOwner()
	local damage = DamageInfo()
	damage:SetDamage(ent:Health() + 666)
	damage:SetInflictor(IsValid(self.Inflictor) and self.Inflictor or self)
	damage:SetAttacker(IsValid(self:GetOwner()) and self:GetOwner() or self)
	damage:SetDamageType(DMG_REMOVENORAGDOLL)
	damage:SetDamagePosition(TFA.WonderWeapon.BodyTarget(ent, self:GetPos(), true))
	damage:SetDamageForce(vector_up)

	if IsValid( self.CoreMDL ) then
		damage:SetReportedPosition(self.CoreMDL:GetPos())
	else
		damage:SetReportedPosition(self:GetPos())
	end

	ParticleEffect("bo3_gersch_kill", ent:WorldSpaceCenter(), angle_zero)

	ent:EmitSound("TFA_BO3_GERSCH.Suck")

	ent:SetHealth(1)

	ent:TakeDamageInfo(damage)

	self:SendHitMarker(ent, damage)

	if IsValid( ply ) and ply:IsPlayer() then
		TFA.WonderWeapon.NotifyAchievement( "BO3_Gersh_Kills", ply, ent, self )
	end

	local startVec = self.CoreMDL2:GetPos()
	local vecVelocity = Vector( math.random( -200, 200 ), math.random( -200, 200 ), math.random( 100, 200 ) )
	local vecAngleVelocity = Vector( 0, math.random( 1000, 2000 ), 0 )
	local randomFacingAngle = Angle(0, math.random( -180, 180 ), 0)

	TFA.WonderWeapon.CreateHorrorGib( startVec, randomFacingAngle, vecVelocity, vecAngleVelocity, math.Rand( 3, 4 ), ent.GetBloodColor and ent:GetBloodColor() or TFA.WonderWeapon.GetBloodName( ent ) or DONT_BLEED )
end

function ENT:ConstructTeleportPos()
	self:SetTelePos(self:GetRandomSpawnPoint())
end

function ENT:OnRemove()
	if SERVER then
		self:CleanupMonkeyBomb()

		if IsValid(self.CoreMDL) and IsValid(self.CoreMDL2) then
			ParticleEffect(self:GetUpgraded() and "bo3_gersch_explode_pap" or "bo3_gersch_explode", self.CoreMDL:GetPos(), angle_zero)

			util.ScreenShake(self:GetPos(), 10, 255, 1, 512)

			self.CoreMDL:StopSound(self.BlackHoleLoopFar)
			self.CoreMDL:StopSound(self.BlackHoleLoopClose)
			self.CoreMDL:EmitSound(self.BlackHoleCollapse)

			self.CoreMDL2:StopSound(self.BlackHoleLoopFar)
			self.CoreMDL2:StopSound(self.BlackHoleLoopClose)
			self.CoreMDL2:EmitSound(self.BlackHoleCollapse)

			SafeRemoveEntity(self.CoreMDL)
			SafeRemoveEntity(self.CoreMDL2)
		end
	end
end