
AddCSLuaFile()

ENT.Base = "tfa_exp_base"
ENT.PrintName = "Arnie (nZombies)"
ENT.AutomaticFrameAdvance = true

// Default Settings

ENT.ForcedKillTime = 30

ENT.DefaultModel = "models/weapons/tfa_bo3/octobomb/octobomb_arnie.mdl"

ENT.Delay = 12
ENT.DelayPAP = 18

ENT.InfiniteDamage = true

ENT.ShouldUseCollisionModel = true

ENT.HullMaxs = Vector(12, 12, 24)
ENT.HullMins = Vector(-12, -12, 0)

ENT.LoopSound = "TFA_BO3_ARNIE.OctoFlail"

ENT.TrailSound = "TFA_BO3_ARNIE.Loop"

ENT.FluxSound = "TFA_BO3_ARNIE.AcidSizzle"

ENT.StartSound = "TFA_BO3_ARNIE.OctoExpl"

ENT.DontUseRollAngle = true
ENT.ExplodeOnRemove = true
ENT.RemoveOnKilltimeEnd = false

// Explosion Settings

ENT.ExplosionBubbles = true
ENT.ExplosionBubblesSize = 240
ENT.ExplosionBubblesMagnitude = 4

ENT.ExplosionMaxBlockingMass = 700
ENT.ExplosionDamageType = DMG_RADIATION
ENT.ExplosionHeadShotScale = 3
ENT.ExplosionHitsOwner = false
ENT.ExplosionOwnerDamage = 25

ENT.WaterBlockExplosions = true

ENT.ScreenShakeAmplitude = 5
ENT.ScreenShakeFrequency = 255
ENT.ScreenShakeDuration = 1
ENT.ScreenShakeRange = 300

ENT.ExplosionEffect = "bo3_lilarnie_start"
ENT.ExplosionEffectPaP = "bo3_lilarnie_start_2"

ENT.ExplosionSound1 = "TFA_BO3_ARNIE.OctoEnd"
ENT.ExplosionSound2 = "TFA_BO3_ARNIE.AcidSizzle"

// DLight Settings

ENT.ColorPaP = Color(100, 10, 170)
ENT.Color = Color(140, 255, 100)

ENT.DLightBrightness = 1
ENT.DLightDecay = 2000
ENT.DLightSize = 250

ENT.DLightOffset = Vector(0,0,4)

// nZombies Settings

ENT.NZThrowIcon = Material("vgui/icon/hud_squidbomb.png", "unlitgeneric smooth")
ENT.NZTacticalPaP = true

DEFINE_BASECLASS(ENT.Base)

function ENT:SetupDataTables()
	BaseClass.SetupDataTables(self)

	self:NetworkVarTFA("Bool", "Dying")
end

function ENT:EntityCollide(trace)
	self:DoImpactEffect(trace)

	local hitEntity = trace.Entity

	hitEntity:EmitSound("TFA_BO3_ARNIE.ZombieDie")

	local hitDamage = DamageInfo()
	hitDamage:SetDamage(self:GetTrueDamage(hitEntity))
	hitDamage:SetAttacker(IsValid(self:GetOwner()) and self:GetOwner() or self)
	hitDamage:SetInflictor(IsValid(self.Inflictor) and self.Inflictor or self)
	hitDamage:SetDamageType(DMG_RADIATION)
	hitDamage:SetDamageForce(hitEntity:GetUp() * math.random(12000,18000) + trace.Normal * math.random(12000,16000))
	hitDamage:SetDamagePosition(trace.HitPos)
	hitDamage:SetReportedPosition(trace.StartPos)

	if nzombies and (hitEntity.NZBossType or hitEntity.IsMooBossZombie or hitEntity.IsMooMiniBoss) then
		damageinfo:SetDamage( math.max( self.Damage, hitEntity:GetMaxHealth() / 9 ) )
	else
		hitEntity:SetHealth( 1 )
	end

	TFA.WonderWeapon.DoDeathEffect(hitEntity, self:GetUpgraded() and "BO3_Octobomb_Upgraded" or "BO3_Octobomb", math.Rand(2, 3))

	hitEntity:DispatchTraceAttack(hitDamage, trace, trace.Normal)

	self:SendHitMarker(hitEntity, hitDamage, trace)
end

function ENT:Initialize()
	BaseClass.Initialize(self)

	self:SetSolidFlags( bit.bor( FSOLID_NOT_STANDABLE, FSOLID_NOT_SOLID, FSOLID_TRIGGER, FSOLID_TRIGGER_TOUCH_DEBRIS ) )
	self:AddEFlags( EFL_NO_PHYSCANNON_INTERACTION )

	self:SetMoveType( MOVETYPE_NONE )
	self:PhysicsInitStatic( SOLID_VPHYSICS )
	self:SetSolid( SOLID_NONE )

	self:SetCollisionGroup( COLLISION_GROUP_WORLD )

	self:ResetSequence( "start" )
	timer.Simple( self:SequenceDuration( "start" ), function() 
		if not IsValid(self) then return end

		ParticleEffectAttach( self:GetUpgraded() and "bo3_lilarnie_loop_2" or "bo3_lilarnie_loop", PATTACH_ABSORIGIN_FOLLOW, self, 1 )
		ParticleEffectAttach( self:GetUpgraded() and "bo3_lilarnie_puddle_2" or "bo3_lilarnie_puddle", PATTACH_ABSORIGIN_FOLLOW, self, 1 )

		self:ResetSequence( "loop" )
	end )

	if SERVER then
		self.NextScream = CurTime() + math.Rand( 2, 3.5 )
		self:DropToFloor()

		self:SetTargetPriority(TARGET_PRIORITY_SPECIAL)
		UpdateAllZombieTargets(self)
	end

	self:PhysicsStop()
end

function ENT:Think()
	if SERVER then
		if ( not self.NextScream or self.NextScream < CurTime() ) and not self:GetDying() then
			self:EmitSound("TFA_BO3_ARNIE.AttackVox")
			self:SetNextScream(CurTime() + math.Rand(3, 5))
		end

		if self.killtime < CurTime() and not self:GetDying() then
			self:SetDying(true)

			self:StopSound(self.TrailSound)
			self:StopSound(self.LoopSound)

			self:StopSound("TFA_BO3_ARNIE.AttackVox")

			self:EmitSound("TFA_BO3_ARNIE.DeathThroes")
			self:EmitSound("TFA_BO3_ARNIE.DeathVox")

			self:ResetSequence("end")
			SafeRemoveEntityDelayed(self, self:SequenceDuration("end") - 0.5)
		end
	end

	return BaseClass.Think(self)
end

function ENT:PreExplosionDamage( hitEntity, explosionTrace, damageinfo )
	if nzombies and (hitEntity.NZBossType or hitEntity.IsMooBossZombie or hitEntity.IsMooMiniBoss) then
		damageinfo:SetDamage( math.max( self.Damage, hitEntity:GetMaxHealth() / 9 ) )
	else
		hitEntity:SetHealth( 1 )
		damageinfo:SetDamage( self:GetTrueDamage( hitEntity ) )
	end

	damageinfo:SetDamageForce( damageinfo:GetDamageForce() * math.Rand(4,6) )

	TFA.WonderWeapon.DoDeathEffect(hitEntity, "BO3_Octobomb", math.Rand(2, 3), self:GetUpgraded())
end

function ENT:OnRemove()
	BaseClass.OnRemove(self)

	self:StopParticles()

	self:StopSound(self.TrailSound)
	self:StopSound(self.LoopSound)

	if SERVER then
		self:CleanupMonkeyBomb()
	end
end
