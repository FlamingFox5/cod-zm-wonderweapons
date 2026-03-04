AddCSLuaFile()

ENT.Base = "tfa_ww_base"
ENT.PrintName = "Stake Bolt"

// Default Settings

ENT.Delay = 10

//ENT.DesiredSpeed = 6000

ENT.HullMaxs = Vector(1, 1, 1)
ENT.HullMins = ENT.HullMaxs:GetNegated()

ENT.ParentOffset = 0

ENT.SpawnGravityEnabled = true

ENT.SpriteTrailMaterial = "trails/smoke"
ENT.SpriteTrailResolution = 0.1
ENT.SpriteTrailLifetime = 0.5
ENT.SpriteTrailStartWidth = 1.5
ENT.SpriteTrailEndWidth = 0
ENT.SpriteTrailAdditive = true
ENT.SpriteTrailColor = Color(120, 120, 120, 200)
ENT.SpriteTrailAttachment = 1

ENT.ShouldLodgeProjectile = false
ENT.ShouldDropProjectile = true

ENT.ImpactBubbles = true
ENT.ImpactBubblesSize = 64
ENT.ImpactBubblesMagnitude = 1

DEFINE_BASECLASS(ENT.Base)

local nzombies = engine.ActiveGamemode() == "nzombies"

local sv_true_damage = GetConVar("sv_tfa_bo3ww_cod_damage")
local ShouldDamage = TFA.WonderWeapon.ShouldDamage

function ENT:PhysicsCollide(data, phys)
	if self.Impacted then return end
	self.Impacted = true

	local trace = self:CollisionDataToTrace(data)
	local direction = data.OurOldVelocity:GetNormalized()
	local hitEntity = trace.Entity

	self:StoreCollisionEventData(data, trace)

	self:DoImpactEffect(trace)

	self:LodgeProjectile(trace)

	if trace.Hit and IsValid(hitEntity) and ShouldDamage(hitEntity, self:GetOwner(), self) then
		local hitDamage = DamageInfo()
		hitDamage:SetDamage(self.Damage)
		hitDamage:SetAttacker(IsValid(self:GetOwner()) and self:GetOwner() or self)
		hitDamage:SetInflictor(IsValid(self.Inflictor) and self.Inflictor or self)
		hitDamage:SetDamageType(nzombies and DMG_BULLET or bit.bor(DMG_BULLET, DMG_AIRBOAT))
		hitDamage:SetDamageForce(direction*2000)
		hitDamage:SetDamagePosition(trace.HitPos)
		hitDamage:SetReportedPosition(trace.StartPos)

		if trace.HitGroup == HITGROUP_HEAD then
			if nzombies and (hitEntity.NZBossType or hitEntity.IsMooBossZombie or hitEntity.IsMooMiniBoss) then
				hitDamage:ScaleDamage(7)
			else
				if ( sv_true_damage ~= nil and sv_true_damage:GetBool() ) or nzombies then
					hitDamage:SetDamage(hitEntity:Health() + 666)
				else
					hitDamage:ScaleDamage(7)
				end
			end
		end

		hitEntity:DispatchTraceAttack(hitDamage, trace, direction)

		self:SendHitMarker(hitEntity, hitDamage, trace)
	end
end

function ENT:EntityCollide(trace)
	if self.Impacted then return end

	self:DoImpactEffect(trace)

	self.Damage = self.mydamage or self.Damage

	local hitEntity = trace.Entity
	local direction = trace.Normal

	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		direction = phys:GetVelocity():GetNormalized()
	end

	local flHitForce = 2000
	local flMass = 0

	for i=0, hitEntity:GetPhysicsObjectCount() - 1 do
		local theirPhys = hitEntity:GetPhysicsObjectNum(i)
		if IsValid( theirPhys ) then
			flMass = theirPhys:GetMass() + flMass
		end
	end

	if flMass > 5 then
		flHitForce = math.Clamp( flMass * 400, 1000, 30000 )
	end

	local hitDamage = DamageInfo()
	hitDamage:SetDamage(self.Damage)
	hitDamage:SetAttacker(IsValid(self:GetOwner()) and self:GetOwner() or self)
	hitDamage:SetInflictor(IsValid(self.Inflictor) and self.Inflictor or self)
	hitDamage:SetDamageType(nzombies and DMG_BULLET or bit.bor(DMG_BULLET, DMG_AIRBOAT))
	hitDamage:SetDamageForce( direction * flHitForce )
	hitDamage:SetDamagePosition(trace.HitPos)
	hitDamage:SetReportedPosition(trace.StartPos)

	if trace.HitGroup == HITGROUP_HEAD then
		if nzombies and (hitEntity.NZBossType or hitEntity.IsMooBossZombie or hitEntity.IsMooMiniBoss) then
			hitDamage:ScaleDamage(7)
		else
			if ( sv_true_damage ~= nil and sv_true_damage:GetBool() ) or nzombies then
				hitDamage:SetDamage(hitEntity:Health() + 666)
			else
				hitDamage:ScaleDamage(7)
			end
		end
	end

	hitEntity:DispatchTraceAttack(hitDamage, trace, trace.Normal)

	self:SendHitMarker(hitEntity, hitDamage, trace)
end

function ENT:Think()
	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		local vel = phys:GetVelocity()
		phys:SetAngles(vel:Angle())
		phys:SetVelocity(vel)
	end

	return BaseClass.Think(self)
end
