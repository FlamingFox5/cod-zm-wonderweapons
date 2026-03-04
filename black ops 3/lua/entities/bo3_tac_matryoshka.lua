
AddCSLuaFile()

ENT.Base = "tfa_ww_tacnade_base"
ENT.PrintName = "Матрёшка"
ENT.AutomaticFrameAdvance = true

// Custom Settings

ENT.ClonesMax = 4
ENT.ClonesCount = 1

// Default Settings

ENT.ForcedKillTime = 20

ENT.Delay = 1
ENT.Range = 200

ENT.SizeOverride = 1

ENT.HullMaxs = Vector(2, 2, 4)
ENT.HullMins = Vector(-2, -2, 0)

ENT.BounceSound = "TFA_BO3_DOLL.Bounce"
ENT.BounceActivationSpeed = 100
ENT.BounceVelocityRatio = 0.4

ENT.DefaultModel = "models/weapons/tfa_bo3/matryoshka/matryoshka_prop.mdl"

ENT.StartSound = "TFA_BO3_DOLL.Pop"

ENT.RemoveOnKilltimeEnd = false

// Explosion Settings

ENT.ExplosionBubbles = true
ENT.ExplosionBubblesSize = 240
ENT.ExplosionBubblesMagnitude = 4

ENT.ExplosionMaxBlockingMass = 350
ENT.ExplosionDamageType = nzombies and DMG_BLAST or bit.bor(DMG_BLAST, DMG_AIRBOAT)
ENT.ExplosionHeadShotScale = 3
ENT.ExplosionHitsOwner = true
ENT.ExplosionOwnerDamage = 150
ENT.ExplosionOwnerRange = 150

ENT.WaterBlockExplosions = true

ENT.ScreenShakeAmplitude = 5
ENT.ScreenShakeFrequency = 255
ENT.ScreenShakeDuration = 1
ENT.ScreenShakeRange = 300

ENT.ExplosionSound1 = "TFA_BO3_GRENADE.Dist"
ENT.ExplosionSound2 = "TFA_BO3_GRENADE.Exp"
ENT.ExplosionSound3 = "TFA_BO3_GRENADE.ExpClose"
ENT.ExplosionSound4 = "TFA_BO3_GRENADE.Flux"

// DLight Settings

ENT.DLightBrightness = 1
ENT.DLightDecay = 2000
ENT.DLightSize = 128

DEFINE_BASECLASS(ENT.Base)

local dlight_cvar = GetConVar("cl_tfa_fx_wonderweapon_dlights")

function ENT:SetupDataTables()
	BaseClass.SetupDataTables(self)

	self:NetworkVarTFA("Int", "Character")
end

function ENT:ActivateCustom(phys)
	timer.Simple(0, function()
		if not IsValid( self ) then return end
		self:SetMoveType( MOVETYPE_NONE )
		self:SetCollisionGroup(COLLISION_GROUP_WORLD)
	end)

	self:SetActivated(true)

	if SERVER then
		sound.EmitHint(SOUND_DANGER, self:GetPos(), 300, 0.5, IsValid(self:GetOwner()) and self:GetOwner() or self)
	end
end

function ENT:Initialize()
	BaseClass.Initialize(self)

	if self:GetCharacter() == 1 then
		self.Color = Color(0,0,255,255)
		self:SetSkin(1)
	elseif self:GetCharacter() == 2 then
		self.Color = Color(255,0,0,255)
		self:SetSkin(2)
	elseif self:GetCharacter() == 3 then
		self.Color = Color(0,255,0,255)
		self:SetSkin(3)
	elseif self:GetCharacter() == 4 then
		self.Color = Color(255,255,0,255)
		self:SetSkin(4)
	end

	if CLIENT then return end

	util.SpriteTrail(self, 1, self.Color, true, 8, 1, 0.335, 0.1, "effects/laser_citadel1.vmt")
end

function ENT:Think()
	if SERVER then
		if self:GetActivated() and self.killtime < CurTime() then
			if self.ClonesCount > self.ClonesMax then
				if self.ExplosionScreenShake then
					self:ScreenShake()
				end

				self:Explode(self:GetPos())
				self:Remove()
				return false
			end

			if self.ClonesCount <= self.ClonesMax and self.ClonesCount ~= self:GetCharacter() then
				self:SpawnClones(self.ClonesCount)
			end

			self.ClonesCount = self.ClonesCount + 1
			self.killtime = CurTime() + math.Rand(0.15,0.2)
		end
	end

	return BaseClass.Think(self)
end

function ENT:SpawnClones(val)
	local doll = ents.Create("bo3_tac_matryoshka_mini")
	doll:SetModel("models/weapons/tfa_bo3/matryoshka/matryoshka_prop.mdl")
	doll:SetPos(self:GetPos() + Vector(0,0,2))
	doll:SetAngles(Angle(0, math.random(-180,180), 0))
	doll:SetOwner(IsValid(self:GetOwner()) and self:GetOwner() or self)

	doll.Damage = self.Damage
	doll.mydamage = self.Damage
	doll:SetCharacter(val)
	doll:SetSkin(val)

	doll:Spawn()

	local vel = Vector(math.random(-250,250), math.random(-250,250), math.random(200,400))

	doll:SetVelocity(vel)
	local phys = doll:GetPhysicsObject()
	if IsValid(phys) then
		phys:SetVelocity(vel)
	end

	doll:SetOwner(IsValid(self:GetOwner()) and self:GetOwner() or self)
	doll.Inflictor = IsValid(self.Inflictor) and self.Inflictor or self
end
