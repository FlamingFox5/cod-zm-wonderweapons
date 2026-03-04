
AddCSLuaFile()

ENT.Base = "tfa_exp_base"
ENT.PrintName = "Матрёшка (nZombies)"

// Custom Settings

ENT.ClonesMax = 8
ENT.ClonesCount = 0

// Default Settings

ENT.ForcedKillTime = 20

ENT.Delay = 1.5
ENT.Range = 200

ENT.SizeOverride = 1

ENT.HullMaxs = Vector(2, 2, 4)
ENT.HullMins = Vector(-2, -2, 0)

ENT.BounceSound = "TFA_BO3_DOLL.Bounce"
ENT.BounceActivationSpeed = 100
ENT.BounceVelocityRatio = 0.4

ENT.DefaultModel = "models/weapons/tfa_bo4/matryoshka/w_matryoshka.mdl"

ENT.StartSound = "TFA_BO3_DOLL.Pop"

ENT.RemoveOnKilltimeEnd = false

// Explosion Settings

ENT.ExplosionBubbles = true
ENT.ExplosionBubblesSize = 240
ENT.ExplosionBubblesMagnitude = 4

ENT.MaxExplosionBlockingMass = 350
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

ENT.ExplosionSound1 = "TFA_BO4_FRAG.Explode"
ENT.ExplosionSound2 = "TFA_BO4_FRAG.Explode.Lfe"
ENT.ExplosionSound3 = "TFA_BO4_FRAG.Explode.Sw"

// DLight Settings

ENT.Color = Color(255, 240, 200, 255)

ENT.DLightBrightness = 1
ENT.DLightDecay = 2000
ENT.DLightSize = 128

// nZombies Settings

ENT.NZHudIcon = Material("vgui/icon/t7_zm_hud_doll.png", "unlitgeneric smooth")

DEFINE_BASECLASS(ENT.Base)


function ENT:SetupDataTables()
	BaseClass.SetupDataTables(self)

	self:NetworkVarTFA("Int", "Character")
end

function ENT:ActivateCustom(phys)
	timer.Simple(0, function()
		if not IsValid(self) then return end
		self:SetMoveType(MOVETYPE_NONE)
		self:SetCollisionGroup(COLLISION_GROUP_WORLD)
	end)

	self:SetActivated(true)

	if SERVER then
		sound.EmitHint(SOUND_DANGER, self:GetPos(), 300, 1, IsValid(self:GetOwner()) and self:GetOwner() or self)
	end
end

function ENT:Initialize(...)
	BaseClass.Initialize(self, ...)

	if CLIENT then return end

	util.SpriteTrail(self, 1, color_white, false, 8, 1, 0.35, 2, "effects/laser_citadel1.vmt")
end

function ENT:Think()
	if SERVER then
		if self:GetActivated() and self.killtime < CurTime() then
			if self.ClonesCount > self.ClonesMax then
				self:Explode()
				self:Remove()
				return false
			end

			self:SpawnClones(self.ClonesCount)
			self.ClonesCount = self.ClonesCount + 1
			self.killtime = CurTime() + 1/3
		end
	end

	self:NextThink(CurTime())
	return true
end

function ENT:SpawnClones(val)
	local doll = ents.Create("nz_bo3_tac_matryoshka_mini")
	doll:SetModel("models/weapons/tfa_bo3/matryoshka/matryoshka_prop.mdl")
	doll:SetPos(self:GetPos() + Vector(0,0,2))
	doll:SetAngles(Angle(0, math.random(-180,180), 0))
	doll:SetOwner(IsValid(self:GetOwner()) and self:GetOwner() or self)

	doll.Damage = self.Damage
	doll.mydamage = self.Damage
	doll:SetCharacter(self.ClonesCount%4 + 1)
	doll:SetSkin(self.ClonesCount%4 + 1)

	doll.ExplosionSound1 = "TFA_BO4_FRAG.Explode"
	doll.ExplosionSound2 = "TFA_BO4_FRAG.Explode.Lfe"
	doll.ExplosionSound3 = "TFA_BO4_FRAG.Explode.Sw"

	doll:Spawn()

	local vel = Vector(math.random(-300,300), math.random(-300,300), math.random(200,300))

	doll:SetVelocity(vel)
	local phys = doll:GetPhysicsObject()
	if IsValid(phys) then
		phys:SetVelocity(vel)
	end

	doll:SetOwner(IsValid(self:GetOwner()) and self:GetOwner() or self)
	doll.Inflictor = IsValid(self.Inflictor) and self.Inflictor or self
end
