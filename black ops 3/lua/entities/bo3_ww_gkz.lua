
AddCSLuaFile()

ENT.Base = "tfa_ww_base"
ENT.PrintName = "Slow Vortex"

// Custom Settings

ENT.Life = 3.5

ENT.PulseInterval = 0.5

// Default Settings

ENT.Delay = 10
ENT.Range = 110

ENT.NoDrawNoShadow = true
ENT.SpawnGravityEnabled = true

ENT.HullMaxs = Vector(2, 2, 2)
ENT.HullMins = ENT.HullMaxs:GetNegated()

ENT.TrailEffect = "bo3_gkz_trail"
ENT.TrailAttachType = PATTACH_ABSORIGIN_FOLLOW
ENT.TrailAttachPoint = 1

ENT.ExplodeOnKilltimeEnd = true

// Explosion Settings

ENT.ExplosionBubblesSize = 120
ENT.ExplosionBubblesMagnitude = 2

ENT.ExplosionDamageType = DMG_DISSOLVE

ENT.ScreenShakeAmplitude = 5
ENT.ScreenShakeFrequency = 255
ENT.ScreenShakeDuration = 1
ENT.ScreenShakeRange = 350

// DLight Settings

ENT.Color = Color(255, 250, 50, 255)

ENT.DLightBrightness = 2
ENT.DLightDecay = 2000
ENT.DLightSize = 200

ENT.DLightFlashOnRemove = true

ENT.DLightFlashSize = 400
ENT.DLightFlashDecay = 2500
ENT.DLightFlashBrightness = 2

DEFINE_BASECLASS(ENT.Base)

local nzombies = engine.ActiveGamemode() == "nzombies"

local ShouldDamage = TFA.WonderWeapon.ShouldDamage

function ENT:SetupDataTables()
	BaseClass.SetupDataTables(self)

	self:NetworkVarTFA("Bool", "Activated")
end

if SERVER then
	function ENT:GravGunPickupAllowed()
		return not self:GetActivated()
	end
end

function ENT:GravGunPunt()
	return not self:GetActivated()
end

function ENT:Draw( ... )
	BaseClass.Draw( self, ... )

	self:AddDrawCallParticle("bo3_gkz_loop", PATTACH_ABSORIGIN_FOLLOW, 1, self:GetActivated(), "GKZ_Loop")
end

function ENT:PhysicsCollide(data, phys)
	if self:GetActivated() then return end
	self:SetActivated(true)

	self.BlockCollisionTrace = true

	local trace = self:CollisionDataToTrace(data)
	local direction = data.OurOldVelocity:GetNormalized()
	local hitEntity = trace.Entity

	if trace.Hit and IsValid(hitEntity) and ShouldDamage(hitEntity, self:GetOwner(), self) then
		local hitDamage = DamageInfo()
		hitDamage:SetDamage(10)
		hitDamage:SetAttacker(IsValid(self:GetOwner()) and self:GetOwner() or self)
		hitDamage:SetInflictor(IsValid(self.Inflictor) and self.Inflictor or self)
		hitDamage:SetDamageType(DMG_ENERGYBEAM)
		hitDamage:SetDamageForce(direction*800)
		hitDamage:SetDamagePosition(trace.HitPos)
		hitDamage:SetReportedPosition(trace.StartPos)

		hitEntity:DispatchTraceAttack(hitDamage, trace, direction)

		self:SendHitMarker(hitEntity, hitDamage, trace)
	end

	self:StopParticles()

	self:EmitSound( "TFA_BO3_GKZMK3.Orb.Start" )
	self:EmitSound( "TFA_BO3_GKZMK3.Orb.Loop" )

	util.Decal( "FadingScorch", data.HitPos, data.HitPos + direction * 4 )

	util.ScreenShake( data.HitPos, 6, 255, 0.6, 250 )

	self.killtime = CurTime() + self.Life

	self:PhysicsStop( phys ) // always call last

	timer.Simple(0, function()
		if not IsValid(self) then return end

		self:SetMoveType(MOVETYPE_NONE)
		self:SetAngles(angle_zero)
		if data.HitNormal[2] < 0.7 then
			self:SetPos( data.HitPos + vector_up*48 )
		end
	end)
end

function ENT:EntityCollide(trace)
	local hitEntity = trace.Entity
	if not self:GetActivated() and ( hitEntity:IsNPC() or hitEntity:IsNextBot() or hitEntity:IsPlayer() ) then
		self:DoImpactEffect(trace)

		local hitDamage = DamageInfo()
		hitDamage:SetDamage(self.Damage)
		hitDamage:SetAttacker(IsValid(self:GetOwner()) and self:GetOwner() or self)
		hitDamage:SetInflictor(IsValid(self.Inflictor) and self.Inflictor or self)
		hitDamage:SetDamageType(nzombies and DMG_DISSOLVE or bit.bor(DMG_PREVENT_PHYSICS_FORCE, DMG_DISSOLVE))
		hitDamage:SetDamageForce(trace.Normal*math.random(6000,12000))
		hitDamage:SetDamagePosition(trace.HitPos)
		hitDamage:SetReportedPosition(trace.StartPos)

		hitEntity:DispatchTraceAttack(hitDamage, trace, trace.Normal)

		self:SendHitMarker(hitEntity, hitDamage, trace)

		ParticleEffect("bo3_gkz_zomb", trace.HitPos, angle_zero)
	end
end

function ENT:Think()
	if SERVER and self:GetActivated() then
		for k, v in pairs(ents.FindInSphere(self:GetPos(), self.Range)) do
			if v:GetClass() == "bo3_ww_mk3" and self:GetPos():Distance(v:GetPos()) < 42 then
				self:StopSound("TFA_BO3_GKZMK3.Orb.Loop")
				self:StopParticles()

				self:CreateBlackHole()
				self:Remove()
				return false
			end

			if v:IsNPC() then
				self:SmokeyHead(v)

				if not v.Old_Speed then
					v.Old_Speed = v:GetMoveVelocity()
				end

				v:SetMoveVelocity( v.Old_Speed * 0.7 )
			end

			if v:IsNextBot() then
				self:SmokeyHead(v)

				local seq = v:GetSequence()
				if seq and seq > -1 then
					local speed = v:GetSequenceGroundSpeed(seq)
					if speed ~= nil and speed > 0 then
						v.loco:SetVelocity( v:GetForward() * (v.loco:GetDesiredSpeed() * 0.7) )
					end
				end
			end
		end

		if !self.NextDamagePulse or self.NextDamagePulse < CurTime() then
			self.NextDamagePulse = CurTime() + self.PulseInterval

			local oldBool = self.FindCharacterOnly
			self.FindCharacterOnly = true

			self:Explode(self:GetPos(), self.Range, VectorRand():GetNormalized())

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
	ParticleEffect( "bo3_gkz_zomb", damageinfo:GetDamagePosition(), ( -explosionTrace.Normal ):Angle() )
	hitEntity:EmitSound( "TFA_BO3_GKZMK3.Orb.Damage" )

	local hitBoss = ( hitEntity.NZBossType or hitEntity.IsMooBossZombie or hitEntity.IsMooMiniBoss )
	if nzombies and hitBoss then
		damageinfo:SetDamage( math.max( 60, hitEntity:GetMaxHealth() / 20 ) )
	else
		damageinfo:SetDamage( self.Damage / 20 )
	end
end

function ENT:DoExplosionEffect( position, radius, direction, bSubmerged )
	// the pulse damage is just an explosion
	//  so dont do the effect untill were actually dead

	if self.killtime > CurTime() then
		return
	end

	self:StopSound("TFA_BO3_GKZMK3.Orb.Loop")
	self:EmitSound("TFA_BO3_GKZMK3.Orb.End")

	ParticleEffect("bo3_gkz_explode", position or self:GetPos(), Angle(0,0,0))
end

function ENT:SmokeyHead(ent)
	if not IsValid(ent) or ent:Health() <= 0 then return end
	local att = TFA.WonderWeapon.BodyTarget(ent, self:GetPos(), true)

	ParticleEffect("bo3_gkz_zomb", att, Angle(0,0,0))
end

function ENT:CreateBlackHole()
	self.Damage = self.mydamage or self.Damage

	local bhole = ents.Create("bo3_ww_gkzmk3_bh")
	bhole:SetModel("models/hunter/misc/sphere025x025.mdl")
	bhole:SetOwner(IsValid(self:GetOwner()) and self:GetOwner() or self)
	bhole:SetPos(self:GetPos())
	bhole:SetAngles(Angle(0,0,0))
	bhole:SetUpgraded(self:GetUpgraded())
	bhole.Damage = self.Damage
	bhole.mydamage = self.Damage

	bhole:Spawn()

	bhole:SetOwner(IsValid(self:GetOwner()) and self:GetOwner() or self)
	bhole.Inflictor = IsValid(self.Inflictor) and self.Inflictor or self

	self:ScreenShake(bhole:GetPos())
end

function ENT:Explode(...)

	if self.killtime > CurTime() then
		return BaseClass.Explode(self, ...)
	end

	self:StopSound("TFA_BO3_GKZMK3.Orb.Loop")
	self:EmitSound("TFA_BO3_GKZMK3.Orb.End")

	self:ScreenShake()

	self:DoExplosionEffect()

	if not self:IsMarkedForDeletion() then
		self:Remove()
	end
end

function ENT:OnRemove()
	BaseClass.OnRemove(self)

	self:StopSound("TFA_BO3_GKZMK3.Orb.Loop")
end
