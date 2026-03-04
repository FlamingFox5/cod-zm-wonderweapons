
AddCSLuaFile()

ENT.Base = "tfa_ww_base"
ENT.PrintName = "Wind"

// Default Settings

ENT.Delay = 0.45
ENT.WaterSplashSize = 24

ENT.TrailEffect = "bo3_thundergun_trail"
ENT.TrailEffectPaP = "bo3_thundergun_trail_2"

ENT.HullMaxs = Vector(2, 2, 2)

ENT.NoDrawNoShadow = true

ENT.BubbleTrail = false

ENT.ShouldDoRotorWash = true
ENT.RotorWashWaterSurfaceOnly = true
ENT.ShouldRotorWashPushVPhysics = false

DEFINE_BASECLASS(ENT.Base)

local nzombies = engine.ActiveGamemode() == "nzombies"
local cv_doordestruction = GetConVar("sv_tfa_melee_doordestruction")

local bit_AND = bit.band

local util_TraceLine = util.TraceLine
local util_PointContents = util.PointContents

local CONTENTS_LIQUID = bit.bor( CONTENTS_WATER, CONTENTS_SLIME )

local doorClasses = {
	["prop_door_rotating"] = true,
	["func_door_rotating"] = true,
}

local traceWater = {}
local vecToSurface = Vector(0, 0, 600)

function ENT:Draw( ... )
	BaseClass.Draw( self, ... )

	self:AddDrawCallParticle("bo3_thundergun_trail_bubbles", PATTACH_ABSORIGIN_FOLLOW, 1, self:WaterLevel() > 2, "BO3_Thundergun_Bubbles")

	if self.CNewParticlesTable then
		local CNPBubbleTrail = self.CNewParticlesTable["BO3_Thundergun_Bubbles"]

		if IsValid( CNPBubbleTrail ) then
			local trace = util.TraceLine({
				start = self:GetPos(),
				endpos = self:GetPos() + vecToSurface,
				filter = self,
				mask = bit.bor( CONTENTS_WATER, CONTENTS_SLIME ),
			})

			if trace.Hit then
				CNPBubbleTrail:SetControlPoint(6, trace.HitPos)
			end
		end
	end
end

function ENT:HandleDoor( slashtrace )
	if CLIENT or not IsValid(slashtrace.Entity) then return end

	if not cv_doordestruction:GetBool() then return end

	if slashtrace.Entity:GetClass() == "func_door_rotating" or slashtrace.Entity:GetClass() == "prop_door_rotating" then
		slashtrace.Entity:EmitSound("ambient/materials/door_hit1.wav", 100, math.random(80, 120))

		local newname = "TFABash" .. self:EntIndex()
		self.PreBashName = self:GetName()
		self:SetName(newname)

		slashtrace.Entity:SetKeyValue("Speed", "500")
		slashtrace.Entity:SetKeyValue("Open Direction", "Both directions")
		slashtrace.Entity:SetKeyValue("opendir", "0")
		slashtrace.Entity:Fire("unlock", "", .01)
		slashtrace.Entity:Fire("openawayfrom", newname, .01)

		timer.Simple(0.02, function()
			if not IsValid(self) or self:GetName() ~= newname then return end

			self:SetName(self.PreBashName)
		end)

		timer.Simple(0.3, function()
			if IsValid(slashtrace.Entity) then
				slashtrace.Entity:SetKeyValue("Speed", "100")
			end
		end)
	end
end

function ENT:PhysicsCollide(data, phys)
	if self.Impacted then return end
	self.Impacted = true

	ParticleEffect("bo3_thundergun_hit", data.HitPos, data.HitNormal:Angle() - Angle(180,0,0))

	local trace = self:CollisionDataToTrace(data)
	local hitEntity = trace.Entity
	if IsValid(hitEntity) and hitEntity.GetMoveType and hitEntity:GetMoveType() == MOVETYPE_PUSH and doorClasses[hitEntity:GetClass()] and IsValid(self.Inflictor) then
		self:HandleDoor(trace)
	end

	self:Remove()
end

function ENT:EntityCollide(trace)
	if self.Impacted then return end
	local hitEntity = trace.Entity
	if IsValid(hitEntity) and hitEntity.GetMoveType and hitEntity:GetMoveType() == MOVETYPE_PUSH and doorClasses[hitEntity:GetClass()] and IsValid(self.Inflictor) then
		self.Impacted = true

		ParticleEffect("bo3_thundergun_hit", trace.HitPos, trace.HitNormal:Angle() - Angle(180,0,0))

		self:HandleDoor(trace)

		self:Remove()
		return false
	end
end

function ENT:Initialize(...)
	BaseClass.Initialize(self, ...)

	self:DrawShadow(false)

	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
end

function ENT:OnRemove()
	self:StopParticles()

	local ply = self:GetOwner()
	local wep = self.Inflictor
	if SERVER then
		if IsValid(ply) and IsValid(wep) and wep:GetClass() == "tfa_bo3_thundergun" and math.random(8) == 1 and (!wep.NextChatterDelay or wep.NextChatterDelay < CurTime()) then
			wep.NextChatterDelay = CurTime() + 20
			wep:EmitSound("TFA_BO3_THUNDERGUN.Chatter")
		end
	end
end
