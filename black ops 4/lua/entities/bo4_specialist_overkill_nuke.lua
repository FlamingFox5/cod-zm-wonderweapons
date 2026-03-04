
AddCSLuaFile()

ENT.Base = "tfa_ww_base"
ENT.PrintName = "Nuke"

// Default Settings

ENT.Delay = 2.5

ENT.ShouldUseCollisionModel = true

ENT.SpawnGravityEnabled = true
ENT.HullMaxs = Vector(1, 1, 1)
ENT.HullMins = ENT.HullMaxs:GetNegated()

ENT.TrailSound = "TFA_BO4_OVERKILL.Cook"
ENT.TrailEffect = "bo4_overkill_charge"
ENT.TrailAttachType = PATTACH_POINT_FOLLOW
ENT.TrailAttachPoint = 2

ENT.ImpactBubbles = true
ENT.ImpactBubblesSize = 64
ENT.ImpactBubblesMagnitude = 1

ENT.BubbleTrail = false

ENT.ExplodeOnKilltimeEnd = true

ENT.ExplosionEffectAngleCorrection = Angle(-90,0,0)
ENT.ExplosionEffect = "bo3_panzer_explosion"

ENT.ExplosionSound1 = "TFA_BO4_OVERKILL.NukeFlash"
ENT.ExplosionSound2 = "TFA_BO4_OVERKILL.NukeEcho"
ENT.ExplosionSound3 = "TFA_BO4_GRENADE.Flux"

ENT.Color = Color(255, 160, 0, 255)

ENT.DLightBrightness = 1
ENT.DLightDecay = 2000
ENT.DLightSize = 200

DEFINE_BASECLASS(ENT.Base)

local nzombies = engine.ActiveGamemode() == "nzombies"
local SinglePlayer = game.SinglePlayer()

function ENT:PhysicsCollide(data, phys)
	if data.Speed > 60 then
		local impulse = (data.OurOldVelocity - 2 * data.OurOldVelocity:Dot(data.HitNormal) * data.HitNormal) * 0.25
		phys:ApplyForceCenter(impulse)
	end

	/*if data.Speed < 200 and data.HitNormal[2] < 0.7 then
		local hitEntity = data.HitEntity
		if ( hitEntity:GetMoveType() == MOVETYPE_PUSH or hitEntity:IsVehicle() ) then
			self:SetParent( hitEntity )
		end

		self:AddEFlags( EFL_NO_PHYSCANNON_INTERACTION )
		self:PhysicsStop( phys )
	end*/
end

function ENT:Initialize(...)
	BaseClass.Initialize(self, ...)

	self:SetCollisionGroup( COLLISION_GROUP_WEAPON )
end

function ENT:NukeEffectEnemy(ent)
	local fx = EffectData()
	fx:SetOrigin(ent:GetPos())
	fx:SetNormal(ent:GetUp())

	util.Effect("HelicopterMegaBomb", fx)

	ent:EmitSound("TFA_BO4_OVERKILL.NukeSoul")
end

function ENT:Explode()
	if nzombies then
		nzPowerUps:Nuke(self:GetPos())

		util.ScreenShake(self:GetPos(), 20, 255, 2.5, 2048)
		self:DoExplosionEffect()
		self:Remove()
		return
	end

	local ply = self:GetOwner()

	local DMG_BLAST_NO_PHYSFORCE = bit.bor(DMG_BLAST, DMG_PREVENT_PHYSICS_FORCE)

	local damage = DamageInfo()
	damage:SetAttacker(IsValid(ply) and ply or self)
	damage:SetInflictor(IsValid(self.Inflictor) and self.Inflictor or self)
	damage:SetReportedPosition(self:GetPos())

	for k, v in pairs(ents.GetAll()) do
		if v:IsPlayer() then
			v:ScreenFade(SCREENFADE.IN, Color(220,220,220,100), 1, 0.1)
		end

		if v:IsNPC() or v:IsNextBot() then
			if !TFA.WonderWeapon.ShouldDamage(v, ply, self) then continue end

			damage:SetDamageType(DMG_BLAST_NO_PHYSFORCE)
			damage:SetDamage(math.huge)

			if string.find(v:GetClass(), "boss") then
				damage:SetDamage(math.max(10000, v:GetMaxHealth() / 2))
			end

			damage:SetDamageForce(v:GetUp()*5000 + v:GetRight()*math.random(-1000,1000))
			if v.EyePos then
				damage:SetDamagePosition(v:EyePos())
			end

			self:NukeEffectEnemy(v)

			v:Ignite(4)
			v:TakeDamageInfo(damage)
		end
	end

	util.ScreenShake(self:GetPos(), 255, 255, 2.5, 2048)

	self:DoExplosionEffect()
	self:Remove()
end