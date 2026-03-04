
AddCSLuaFile()

ENT.Base = "tfa_ww_base"
ENT.PrintName = "ICE COLD"

// Custom Settings

ENT.InnerRange = 100

ENT.Kills = 0
ENT.MaxKills = 24

// Defaul Settings

ENT.Delay = 0.3
ENT.Range = 300

ENT.HullMaxs = Vector(1, 1, 1)
ENT.HullMins = ENT.HullMaxs:GetNegated()

ENT.TrailEffect = "bo4_tundragun_trail"
ENT.TrailAttachType = PATTACH_ABSORIGIN_FOLLOW
ENT.TrailAttachPoint = 1

ENT.ImpactDecal = "snow_grenade"

ENT.ImpactBubbles = false // we explode on impact which has bubbles

ENT.WaterSplashSize = 24

// Explosion Settings

ENT.ExplosionBubbles = true
ENT.ExplosionBubblesSize = 256
ENT.ExplosionBubblesMagnitude = 4

ENT.ExplodeOnKilltimeEnd = true
ENT.MaxExplosionBlockingMass = 350
ENT.ExplosionDamageType = nZSTORM and DMG_VEHICLE or DMG_REMOVENORAGDOLL
ENT.ExplosionHeadShotScale = 7
ENT.ExplosionHitsOwner = true
ENT.ExplosionOwnerDamage = 45
ENT.ExplosionScreenShake = true

ENT.WaterBlockExplosions = false

ENT.ScreenShakeAmplitude = 5
ENT.ScreenShakeFrequency = 255
ENT.ScreenShakeDuration = 0.8
ENT.ScreenShakeRange = 240

ENT.ExplosionEffectAngleCorrection = Angle(-90,0,0)
ENT.ExplosionEffect = "bo4_tundragun_impact"

ENT.ExplosionSound1 = "TFA_BO4_TUNDRAGUN.Impact"
ENT.ExplosionSound2 = "TFA_BO3_GRENADE.ExpClose"
ENT.ExplosionSound3 = "TFA_BO3_GRENADE.Flux"

// DLight Settings

ENT.Color = Color(120, 240, 255)

ENT.DLightBrightness = 0
ENT.DLightSize = 0

ENT.DLightFlashOnRemove = true

ENT.DLightFlashSize = 250
ENT.DLightFlashDecay = 1500
ENT.DLightFlashBrightness = 2

DEFINE_BASECLASS(ENT.Base)

local nzombies = engine.ActiveGamemode() == "nzombies"

local GiveStatus = TFA.WonderWeapon.GiveStatus
local HasStatus = TFA.WonderWeapon.HasStatus

function ENT:PhysicsCollide(data, phys)
	if self.Impacted then return end
	self.Impacted = true

	local trace = self:CollisionDataToTrace(data)
	local direction = data.OurOldVelocity:GetNormalized()
	local hitEntity = trace.Entity

	self:StoreCollisionEventData(data, trace)

	self:DoImpactEffect(trace)

	if trace.Hit and IsValid(hitEntity) and TFA.WonderWeapon.ShouldDamage(hitEntity, self:GetOwner(), self) then
		local hitDamage = DamageInfo()
		hitDamage:SetDamage(10)
		hitDamage:SetAttacker(IsValid(self:GetOwner()) and self:GetOwner() or self)
		hitDamage:SetInflictor(IsValid(self.Inflictor) and self.Inflictor or self)
		hitDamage:SetDamageType(DMG_BULLET)
		hitDamage:SetDamageForce(direction*2000)
		hitDamage:SetDamagePosition(trace.HitPos)
		hitDamage:SetReportedPosition(trace.StartPos)

		hitEntity:DispatchTraceAttack(hitDamage, trace, direction)

		self:SendHitMarker(hitEntity, hitDamage, trace)
	end

	self:Explode(data.HitPos)

	self:PhysicsStop(phys) // always call last

	self:Remove()
end

function ENT:EntityCollide(trace)
	if self.Impacted then return end
	self.Impacted = true

	self:SetHitPos(trace.HitPos)

	self:DoImpactEffect(trace)

	local hitEntity = trace.Entity
	local direction = trace.HitNormal
	local hitCharacter = (hitEntity:IsNPC() or hitEntity:IsNextBot() or hitEntity:IsPlayer())

	local hitDamage = DamageInfo()
	hitDamage:SetDamage(10)
	hitDamage:SetAttacker(IsValid(self:GetOwner()) and self:GetOwner() or self)
	hitDamage:SetInflictor(IsValid(self.Inflictor) and self.Inflictor or self)
	hitDamage:SetDamageType(DMG_BULLET)
	hitDamage:SetDamageForce(direction*2000)
	hitDamage:SetDamagePosition(trace.HitPos)
	hitDamage:SetReportedPosition(trace.StartPos)

	local nLastHealth = hitEntity:Health()

	hitEntity:DispatchTraceAttack(hitDamage, trace, direction)

	if hitEntity:Health() < nLastHealth then
		self:SendHitMarker(hitEntity, hitDamage, trace)
	end

	if !hitCharacter then
		local phys = self:GetPhysicsObject()
		if IsValid(phys) then
			direction = phys:GetVelocity():GetNormalized()
		end

		util.Decal("snow_grenade", trace.HitPos, trace.HitPos + direction*4)
	end

	self:Explode(trace.HitPos)

	self:PhysicsStop() // always call last

	self:Remove()
end

local function enemy_percent_damaged_by_freezegun(d, e)
	if not IsValid(e) then return 0 end
	return math.Clamp(1 - (d / e:Health()), .33, 1)
end

function ENT:PreExplosionDamage( hitEntity, explosionTrace, damageinfo )
	ParticleEffect( "bo4_tundragun_zomb", hitEntity:WorldSpaceCenter(), angle_zero )

	if not (hitEntity:IsPlayer() or hitEntity:IsNPC() or hitEntity:IsNextBot()) then
		return
	end

	if nzombies and ( hitEntity.NZBossType or hitEntity.IsMooBossZombie or hitEntity.IsMooMiniBoss ) then
		damageinfo:SetDamage( math.max( self.Damage, 1200, hitEntity:GetMaxHealth() / 8 ) )
		damageinfo:SetDamageType( nZSTORM and DMG_VEHICLE or DMG_GENERIC )

		GiveStatus( hitEntity, "BO4_Winters_Slow", 10, enemy_percent_damaged_by_freezegun( damageinfo:GetDamage(), hitEntity ) )
	else
		local inner_range = self.InnerRange
		local outer_range = self.Range
		local inner_range_squared = inner_range * inner_range
		local outer_range_squared = outer_range * outer_range

		local mydamage = self.mydamage or self.Damage
		if nzombies and hitEntity:IsValidZombie() and nzRound and nzRound.GetZombieHealth then
			mydamage = nzRound:GetZombieHealth() + 6
		end

		local test_origin = explosionTrace.Entity == hitEntity and explosionTrace.HitPos or hitEntity:WorldSpaceCenter()
		local test_range_squared = explosionTrace.StartPos:DistToSqr(test_origin)
		local dist_ratio = ( outer_range_squared - test_range_squared ) / ( outer_range_squared - inner_range_squared ) 
		local damagefinal = math.Clamp( Lerp( dist_ratio, mydamage / 2, mydamage ), 0, hitEntity:Health() - 1 )

		damageinfo:SetDamage( damagefinal )

		if hitEntity:Health() - damageinfo:GetDamage() < 2 then
			if not HasStatus(hitEntity, "BO4_Winters_Freeze") then
				self.Kills = self.Kills + 1
				if self.Kills > self.MaxKills then
					return true
				end

				GiveStatus( hitEntity, "BO4_Winters_Freeze", math.Rand(2,4), self:GetOwner(), self.Inflictor, self.Damage, self:GetUpgraded() )
			end

			return true //block doing damage
		else
			GiveStatus( hitEntity, "BO4_Winters_Slow", 10, enemy_percent_damaged_by_freezegun( damageinfo:GetDamage(), hitEntity ) )
		end
	end
end
