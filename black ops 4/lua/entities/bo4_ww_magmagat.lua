
AddCSLuaFile()

ENT.Base = "tfa_ww_base"
ENT.PrintName = "Magma Blob"

// Custom Settings

ENT.Life = 7
ENT.LifeImpact = 1

ENT.EndSound = "TFA_BO4_BLUNDER.Magma.End"

ENT.BlastRange = 180

// Default Settings

ENT.Delay = 10
ENT.Range = 100

ENT.SpawnGravityEnabled = true
ENT.ShouldLodgeProjectile = true
ENT.ShouldDropProjectile = true

ENT.HullMaxs = Vector(2, 2, 2)
ENT.HullMins = ENT.HullMaxs:GetNegated()

ENT.TrailSound = "TFA_BO4_BLUNDER.Magma.Loop"
ENT.TrailEffect = "bo4_magmagat_trail"
ENT.TrailAttachType = PATTACH_ABSORIGIN_FOLLOW
ENT.TrailAttachPoint = 1

ENT.ImpactDecal = "FadingScorch"

ENT.ImpactBubbles = false

ENT.ParentOffset = -1
ENT.ParentAlign = true
ENT.ParentAlignOffset = Angle(-90,0,0)

// Explosion Settings

ENT.ExplosionBubbles = false
ENT.ExplosionBubblesSize = 128
ENT.ExplosionBubblesMagnitude = 4

ENT.MaxExplosionBlockingMass = 350
ENT.ExplosionDamageType = nzombies and DMG_BLAST or bit.bor(DMG_BLAST, DMG_AIRBOAT)
ENT.ExplosionHeadShotScale = 7
ENT.ExplosionHitsOwner = true
ENT.ExplosionOwnerDamage = 50
ENT.ExplosionScreenShake = true

ENT.WaterBlockExplosions = false

ENT.ScreenShakeAmplitude = 5
ENT.ScreenShakeFrequency = 255
ENT.ScreenShakeDuration = 0.8
ENT.ScreenShakeRange = 240

ENT.ExplosionEffectAngleCorrection = Angle(-90,0,0)
ENT.ExplosionEffect = "bo4_magmagat_explode"

ENT.ExplosionSound1 = "TFA_BO4_BLUNDER.Magma.Explode"
ENT.ExplosionSound2 = "TFA_BO4_BLUNDER.Magma.Explode.Swt"
ENT.ExplosionSound3 = "TFA_BO4_GRENADE.Close"

// DLight Settings

ENT.Color = Color(255, 45, 0, 255)

DEFINE_BASECLASS(ENT.Base)

local nzombies = engine.ActiveGamemode() == "nzombies"

local GiveStatus = TFA.WonderWeapon.GiveStatus
local HasStatus = TFA.WonderWeapon.HasStatus
local ShouldDamage = TFA.WonderWeapon.ShouldDamage

function ENT:SetupDataTables()
	BaseClass.SetupDataTables(self)

	self:NetworkVarTFA("Bool", "Activated")
end

function ENT:Draw(...)
	BaseClass.Draw( self, ... )

	self:AddDrawCallParticle( self.TrailEffect , self.TrailAttachType or PATTACH_ABSORIGIN_FOLLOW, self.TrailAttachPoint or 1, self:GetActivated() and IsValid( self:GetParent() ), "magma_fake_trail" )

	self:AddDrawCallParticle( ( self:GetUp():GetNegated() ):Dot( Vector(0, 0, 1) ) < 0.9 and "bo4_magmagat_puddle_billboard" or "bo4_magmagat_puddle" , PATTACH_ABSORIGIN_FOLLOW, 1, self:GetActivated() and not IsValid( self:GetParent() ), "magma_puddle" )
end

function ENT:PhysicsCollide(data, phys)
	if self:GetActivated() then return end

	local trace = self:CollisionDataToTrace(data)
	local direction = data.OurOldVelocity:GetNormalized()
	local hitEntity = trace.Entity

	self:StoreCollisionEventData(data, trace)

	self:LodgeProjectile(trace)

	self:ActivateCustom(trace)

	if trace.Hit and IsValid(hitEntity) and ShouldDamage(hitEntity, self:GetOwner(), self) then
		local hitDamage = DamageInfo()
		hitDamage:SetDamage(10)
		hitDamage:SetAttacker(IsValid(owner) and owner or self)
		hitDamage:SetInflictor(self)
		hitDamage:SetDamageType(DMG_BULLET)
		hitDamage:SetDamageForce(direction*2000)
		hitDamage:SetDamagePosition(trace.HitPos)

		hitEntity:DispatchTraceAttack(hitDamage, trace, direction)

		self:SendHitMarker(hitEntity, hitDamage, trace)
	end
end

function ENT:EntityCollide(trace)
	if self:GetActivated() then return end

	self:ActivateCustom(trace)

	local hitEntity = trace.Entity
	local direction = trace.Normal

	local hitDamage = DamageInfo()
	hitDamage:SetDamage(10)
	hitDamage:SetAttacker(IsValid(owner) and owner or self)
	hitDamage:SetInflictor(self)
	hitDamage:SetDamageType(DMG_BURN)
	hitDamage:SetDamageForce(direction*2000)
	hitDamage:SetDamagePosition(trace.HitPos)

	hitEntity:DispatchTraceAttack(hitDamage, trace, direction)

	self:SendHitMarker(hitEntity, hitDamage, trace)
end

function ENT:Initialize()
	BaseClass.Initialize(self)

	if CLIENT then return end

	local sprite = self:CreateGlowSprite(self.Life, self.Color, 255, 0.4)
	if sprite then
		sprite:SetParent(self)
		sprite:SetLocalPos(self:GetUp()*2)
	end

	self.DeathFalter = math.Rand(0.5,1)
end

function ENT:ActivateCustom(trace)
	self:SetActivated(true)

	local hitEntity = trace.Entity
	if not trace.HitWorld and IsValid(hitEntity) and hitEntity:GetInternalVariable( "m_lifeState" ) == 0 then
		self.Impacted = true

		hitEntity:Ignite(self.LifeImpact)
		if hitEntity:IsNPC() or hitEntity:IsNextBot() then
			hitEntity:SetNW2Bool("OnAcid", true)

			if nzombies and hitEntity:IsValidZombie() and not (hitEntity.NZBossType or hitEntity.IsMooBossZombie or hitEntity.IsMooMiniBoss) then
				hitEntity:Freeze(3)
			end
		end
	end

	self:DoImpactEffect(trace)

	self.BubbleTrail = false

	if self.HasIgnited then return end
	self.HasIgnited = true

	if not self.Impacted then
		self:StopParticles()

		if nzombies then
			self:MonkeyBombNZ()
		else
			self:MonkeyBomb()
		end

		self.killtime = CurTime() + self.Life

		local sprite = self:CreateGlowSprite(self.Life, self.Color, 255, 1.2)
		if sprite then
			sprite:SetParent(self)
			sprite:SetLocalPos(self:GetUp()*2)
		end

		/*if trace.HitNormal:Dot(Vector(0,0,1))<0.9 then
			ParticleEffectAttach("bo4_magmagat_puddle_billboard", PATTACH_ABSORIGIN_FOLLOW, self, 1)
		else
			ParticleEffectAttach("bo4_magmagat_puddle", PATTACH_ABSORIGIN_FOLLOW, self, 1)
		end*/
	else
		self.killtime = CurTime() + self.LifeImpact

		if nzombies and self:GetUpgraded() then
			self:SetTargetPriority( TARGET_PRIORITY_SPECIAL )
		end

		self:SetAngles( (-trace.Normal):Angle() )
	end
end

function ENT:Think()
	if SERVER then
		local ply = self:GetOwner()

		if self.killtime < CurTime() then
			self:StopSound(self.TrailSound)
			self:StopParticles()

			if IsValid(self:GetParent()) then
				self:Explode()
			end

			self:EmitSound(self.EndSound)

			self:Remove()
			return false
		end

		local p = self:GetParent()
		local pValid = tobool( IsValid( p ) )

		if not nzombies and self:GetActivated() and !pValid then
			self:MonkeyBomb()
			self:MonkeyBombNXB()
		end

		if self:GetActivated() and !pValid then
			self:MagmaAttackThink()
		end
	end

	return BaseClass.Think(self)
end

local playerBurnDistSqr = 32^2

function ENT:MagmaAttackThink()
	local ply = self:GetOwner()
	for k, v in pairs( ents.FindInSphere( self:GetPos(), self.Range ) ) do
		if v:IsNPC() or v:IsNextBot() or v:IsPlayer() then
			if HasStatus(v, "BO4_MagmaGat_Burn") then continue end

			if v == ply then
				if ply:GetPos():DistToSqr( v:GetPos() ) < playerBurnDistSqr then
					ply:Ignite( engine.TickInterval() )
				end
				continue
			end

			if not ShouldDamage(v, ply, self) then continue end

			GiveStatus(v, "BO4_MagmaGat_Burn", math.Rand( 1, 2 ), self:GetOwner(), self.Inflictor, self.mydamage)
		end
	end
end

function ENT:CallbackOnDrop()
	if not self:GetActivated() then return end
	self:SetActivated(false)

	self.BubbleTrail = true
end

function ENT:MonkeyBombNZ()
	if CLIENT then return end
	self:SetTargetPriority(TARGET_PRIORITY_PLAYER)
	//UpdateAllZombieTargets(self)
end

function ENT:PreExplosionDamage( hitEntity, explosionTrace, damageinfo )
	if nzombies and (hitEntity.NZBossType or hitEntity.IsMooBossZombie or hitEntity.IsMooMiniBoss) then
		damageinfo:SetDamage(math.max(self.Damage, hitEntity:GetMaxHealth() / 9))
		damageinfo:SetDamageType( bit.bor( DMG_BURN, DMG_RADIATION ) )
	else
		if not HasStatus(hitEntity, "BO4_MagmaGat_Burn") then
			GiveStatus(hitEntity, "BO4_MagmaGat_Burn", math.Rand(1.5,3), self:GetOwner(), self.Inflictor, self.Damage)
		end

		//return true //block doing damage
	end
end

function ENT:Explode( ... )
	local ent = self:GetParent()

	if IsValid( ent ) and ShouldDamage( ent, self:GetOwner(), self ) then
		local damage = DamageInfo()
		damage:SetInflictor(IsValid(self.Inflictor) and self.Inflictor or self)
		damage:SetAttacker(IsValid(self:GetOwner()) and self:GetOwner() or self)
		damage:SetDamage(ent:Health() + 666)
		damage:SetDamageType(bit.bor(DMG_BLAST_SURFACE, DMG_BURN))
		damage:SetDamagePosition(TFA.WonderWeapon.BodyTarget( ent, self:GetPos(), true ))
		damage:SetReportedPosition(self:GetPos())
		damage:SetDamageForce(vector_up)

		TFA.WonderWeapon.DoDeathEffect(ent, "BO3_Wavegun_Pop")

		if nzombies and ( ent.NZBossType or ent.IsMooBossZombie or ent.IsMooMiniBoss ) then
			damage:SetDamage(math.max(self.Damage, ent:GetMaxHealth() / 12))
		elseif ( ent:IsNPC() or ent:IsNextBot() or ent:IsPlayer() ) then
			ent:SetHealth(1)
		end

		ent:TakeDamageInfo(damage)

		self:SendHitMarker(ent, damage)
	end
 
	BaseClass.Explode( self, ... )
end

function ENT:OnRemove()
	BaseClass.OnRemove( self )

	self:StopSound( self.TrailSound )

	local pEnt = self:GetParent()
	if IsValid( pEnt ) then
		local bPassed = true
		for _, child in ipairs(pEnt:GetChildren()) do
			if child ~= self and child:GetClass() == self:GetClass() then
				bPassed = false
				break
			end
		end

		if bPassed and pEnt:GetNW2Bool("OnAcid") then
			pEnt:SetNW2Bool("OnAcid", false)
		end
	end
end
