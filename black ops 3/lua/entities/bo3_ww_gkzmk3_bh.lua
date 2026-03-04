
AddCSLuaFile()

--[Info]--
ENT.Base = "tfa_ww_base"
ENT.PrintName = "Vortex"

// Custom Settings

ENT.ExplodeRange = 200

ENT.PulseInterval = 0.5

// Default Settings

ENT.Delay = 3.5
ENT.Range = 150

ENT.NoDrawNoShadow = true

ENT.HullMaxs = Vector(4, 4, 4)
ENT.HullMins = ENT.HullMaxs:GetNegated()

ENT.TrailSound = "TFA_BO3_GKZMK3.Orb.Loop2"

ENT.TrailEffect = "bo3_gkz_bh_loop"
ENT.TrailAttachType = PATTACH_ABSORIGIN_FOLLOW
ENT.TrailAttachPoint = 1
ENT.TrailEffectActiveLooping = true

ENT.ExplodeOnKilltimeEnd = true

ENT.BubbleTrail = false

// Explosion Settings

ENT.ExplosionBubblesSize = 120
ENT.ExplosionBubblesMagnitude = 2

ENT.ExplosionDamageType = DMG_DISSOLVE

ENT.ScreenShakeAmplitude = 5
ENT.ScreenShakeFrequency = 255
ENT.ScreenShakeDuration = 1
ENT.ScreenShakeRange = 400

// DLight Settings

ENT.Color = Color(185, 70, 255, 255)

ENT.DLightBrightness = 2
ENT.DLightDecay = 2000
ENT.DLightSize = 256

ENT.DLightFlashOnRemove = true

ENT.DLightFlashSize = 512
ENT.DLightFlashDecay = 1200
ENT.DLightFlashBrightness = 2

DEFINE_BASECLASS( ENT.Base )

local nzombies = engine.ActiveGamemode() == "nzombies"
local sv_true_damage = GetConVar("sv_tfa_bo3ww_cod_damage")

local vector_down_64 = Vector(0, 0, -64)

function ENT:SetupDataTables()
	BaseClass.SetupDataTables(self)

	self:NetworkVarTFA("Bool", "Upgraded")
	self:NetworkVarTFA("Bool", "Activated")
end

if SERVER then
	function ENT:GravGunPickupAllowed()
		return false
	end
end

function ENT:GravGunPunt()
	return false
end

function ENT:PhysicsCollide(data, phys)
	self:PhysicsStop( phys )
end

function ENT:EntityCollide(trace)
	local hitEntity = trace.Entity
	if self:GetActivated() then
		self:DoImpactEffect(trace)

		local hitBoss = nzombies and (hitEntity.NZBossType or hitEntity.IsMooBossZombie or hitEntity.IsMooMiniBoss)
		local hitCharacter = ( hitEntity:IsNPC() or hitEntity:IsNextBot() or hitEntity:IsPlayer() )

		local bOldDamage = self.InfiniteDamage
		self.InfiniteDamage = true

		local hitDamage = DamageInfo()
		hitDamage:SetDamage(hitBoss and self.Damage or self:GetTrueDamage(hitEntity))
		hitDamage:SetAttacker(IsValid(self:GetOwner()) and self:GetOwner() or self)
		hitDamage:SetInflictor(IsValid(self.Inflictor) and self.Inflictor or self)
		hitDamage:SetDamageType(nzombies and DMG_DISSOLVE or bit.bor(DMG_PREVENT_PHYSICS_FORCE, DMG_DISSOLVE))
		hitDamage:SetDamageForce(hitCharacter and ( trace.Normal * math.random(4000,6000) ) or VectorRand():GetNormalized()*2000)
		hitDamage:SetDamagePosition(trace.HitPos)
		hitDamage:SetReportedPosition(trace.StartPos)

		hitEntity:DispatchTraceAttack(hitDamage, trace, trace.Normal)

		self.InfiniteDamage = bOldDamage

		self:SendHitMarker(hitEntity, hitDamage, trace)

		sound.Play("TFA_BO3_GKZMK3.Orb.Damage", trace.HitPos)
	end
end

function ENT:Initialize()
	BaseClass.Initialize(self)

	self:SetMoveType(MOVETYPE_NONE)
	self:SetNotSolid(true)
	self:DrawShadow(false)

	self:PhysicsStop()

	self:SetActivated(true)

	local trace = util.TraceLine({
		start = self:GetPos(),
		endpos = self:GetPos() + vector_down_64,
		mask = MASK_SHOT,
		filter = self,
	})

	if trace.Hit then
		util.Decal("Scorch", trace.HitPos, trace.HitPos - vector_up*4)
	end
end

function ENT:Think()
	if SERVER and self:GetActivated() then
		for k, v in pairs(ents.FindInSphere(self:GetPos(), self.Range)) do
			if v:IsNPC() then
				//self:SmokeyHead(v)

				if not v.Old_Speed then
					v.Old_Speed = v:GetMoveVelocity()
				end

				v:SetMoveVelocity( v.Old_Speed / 2 )
			end

			if v:IsNextBot() then
				//self:SmokeyHead(v)

				local seq = v:GetSequence()
				if seq and seq > -1 then
					local speed = v:GetSequenceGroundSpeed(seq)
					if speed ~= nil and speed > 0 then
						v.loco:SetVelocity( v:GetForward() * (v.loco:GetDesiredSpeed() / 2) )
					end
				end
			end
		end

		if !self.NextDamagePulse or self.NextDamagePulse < CurTime() then
			self.NextDamagePulse = CurTime() + self.PulseInterval

			local oldBool = self.FindCharacterOnly
			self.FindCharacterOnly = true

			self:Explode( self:GetPos(), self.Range, VectorRand():Normalize() )

			self.FindCharacterOnly = oldBool

			self.HasExploded = false
		end

		if self.killtime < CurTime() and self.Range ~= self.ExplodeRange then
			self.Range = self.ExplodeRange
		end
	end

	return BaseClass.Think(self)
end

function ENT:PreExplosionDamage( hitEntity, explosionTrace, damageinfo )
	ParticleEffect("bo3_gkz_bh_zomb", damageinfo:GetDamagePosition(), (-explosionTrace.Normal):Angle())
	hitEntity:EmitSound("TFA_BO3_GKZMK3.Orb.Damage")

	local hitBoss = nzombies and (hitEntity.NZBossType or hitEntity.IsMooBossZombie or hitEntity.IsMooMiniBoss)
	if nzombies and hitBoss then
		damageinfo:SetDamage(math.max(800, hitEntity:GetMaxHealth() / 12))
	end

	if !hitEntity.GKZPulseCount then hitEntity.GKZPulseCount = 0 end
	hitEntity.GKZPulseCount = 1 + hitEntity.GKZPulseCount

	if hitEntity.GKZPulseCount > 3 then
		hitEntity.GKZPulseCount = 0

		if ( !sv_true_damage or sv_true_damage:GetBool() ) or nzombies then
			if hitBoss then
				damageinfo:ScaleDamage( 3 )
			else
				damageinfo:SetDamage(hitEntity:Health() + 666)
			end
		elseif !nzombies then
			damageinfo:ScaleDamage( 3 )
		end
	end
end

function ENT:DoExplosionEffect( position, radius, direction, bSubmerged )
	// the pulse damage is just an explosion
	//  so dont do the effect untill were actually dead

	if self.killtime > CurTime() then
		return
	end

	self:StopSound("TFA_BO3_GKZMK3.Orb.Loop2")
	self:EmitSound("TFA_BO3_GKZMK3.Orb.End")

	ParticleEffect("bo3_gkz_bh_explode", position, Angle(0,0,0))

	if self.ExplosionBubbles and bit.band( util.PointContents(self:GetPos() + vector_up*24), bit.bor( CONTENTS_WATER, CONTENTS_SLIME ) ) ~= 0 then
		self:DoExplosionBubblesEffect( self:GetPos(), vector_up, self.ExplosionBubblesMagnitude, self.ExplosionBubblesSize )
	end
end
