AddCSLuaFile()

ENT.Base = "tfa_ww_base"
ENT.PrintName = "Rocket-Propelled Pumpkin"

// Custom Settings

ENT.Impacted = false

// Default Settings

ENT.Delay = 10
ENT.Range = 250

ENT.HullMaxs = Vector(2, 2, 2)
ENT.HullMins = ENT.HullMaxs:GetNegated()

ENT.FluxSound = "TFA_WAW_PUMPKINGUN.Shot"

ENT.SearchRange = 400

ENT.TrailEffect = "waw_pumpkingun_trail"
ENT.TrailEffectPaP = "waw_pumpkingun_trail_2"
ENT.TrailAttachType = PATTACH_POINT_FOLLOW
ENT.TrailAttachPoint = 1

ENT.ImpactDecal = "Scorch"

ENT.ImpactBubbles = false // we explode on impact which has bubbles

// Acceleration Settings

ENT.CurveStrengthMin = 1
ENT.CurveStrengthMax = 1

ENT.BaseSpeed = 200
ENT.MaxSpeed = 1000
ENT.AccelerationTime = 1

// Explosion Settings

ENT.ExplosionBubbles = true
ENT.ExplosionBubblesSize = 200
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
ENT.ScreenShakeDuration = 0.9
ENT.ScreenShakeRange = 300

ENT.ExplosionSound1 = "TFA_WAW_PUMPKINGUN.Explode"

// DLight Settings

ENT.ColorPaP = Color(0, 200, 255, 255)
ENT.Color = Color(255, 150, 0, 255)

ENT.DLightBrightness = 1
ENT.DLightDecay = 2000
ENT.DLightSize = 250

ENT.DLightFlashOnRemove = true

ENT.DLightFlashSize = 300
ENT.DLightFlashDecay = 2000
ENT.DLightFlashBrightness = 2

DEFINE_BASECLASS(ENT.Base)

local nzombies = engine.ActiveGamemode() == "nzombies"

local SinglePlayer = game.SinglePlayer()

function ENT:PhysicsCollide(data, phys)
	if self.Impacted then return end
	self.Impacted = true

	local trace = self:CollisionDataToTrace(data)
	local direction = data.OurOldVelocity:GetNormalized()
	local hitEntity = trace.Entity

	self:StoreCollisionEventData(data, trace)

	self:DoImpactEffect(trace)

	if trace.Hit and IsValid( hitEntity ) and not ( hitEntity:IsNPC() or hitEntity:IsNextBot() or hitEntity:IsPlayer() ) and TFA.WonderWeapon.ShouldDamage( hitEntity, self:GetOwner(), self ) then
		local hitDamage = DamageInfo()
		hitDamage:SetDamage(10)
		hitDamage:SetAttacker(IsValid(self:GetOwner()) and self:GetOwner() or self)
		hitDamage:SetInflictor(IsValid(self.Inflictor) and self.Inflictor or self)
		hitDamage:SetDamageType(DMG_BLAST_SURFACE)
		hitDamage:SetDamageForce(direction*2000)
		hitDamage:SetDamagePosition(trace.HitPos)
		hitDamage:SetReportedPosition(trace.StartPos)

		hitEntity:DispatchTraceAttack( hitDamage, trace, direction )
	end

	self:DoImpactEffect( trace )

	self:Explode( trace.HitPos - direction, self.Range, trace.HitNormal )

	self:PhysicsStop( phys )

	self:Remove()
end

function ENT:EntityCollide(trace)
	if self.Impacted then return end
	self.Impacted = true

	local hitEntity = trace.Entity
	local direction = trace.Normal

	local phys = self:GetPhysicsObject()
	if IsValid( phys ) then
		direction = phys:GetVelocity():GetNormalized()
	end

	self:DoImpactEffect( trace )


	if hitEntity:IsNPC() or hitEntity:IsNextBot() then
		hitEntity:WAWPumpkin( math.Rand(2,3.2), self:GetOwner(), self.Inflictor, self:GetUpgraded() )
	end

	local hitDamage = DamageInfo()
	hitDamage:SetDamage(10)
	hitDamage:SetAttacker(IsValid(self:GetOwner()) and self:GetOwner() or self)
	hitDamage:SetInflictor(IsValid(self.Inflictor) and self.Inflictor or self)
	hitDamage:SetDamageType(DMG_BLAST_SURFACE)
	hitDamage:SetDamageForce(direction*2000)
	hitDamage:SetDamagePosition(trace.HitPos)
	hitDamage:SetReportedPosition(trace.StartPos)

	local nLastHealth = hitEntity:Health()

	hitEntity:DispatchTraceAttack(hitDamage, trace, trace.Normal)

	if hitEntity:Health() < nLastHealth then
		self:SendHitMarker(hitEntity, hitDamage, trace)
	end

	self:Explode( trace.HitPos )

	self:PhysicsStop( phys )

	self:Remove()

	return false
end

function ENT:Initialize(...)
	BaseClass.Initialize(self, ...)

	self:SetModelScale(0.65, 0)

	if SERVER then
		if math.random(100) <= 20 then
			self.Talker = true
		end

		if self.Talker then
			self:EmitSound("TFA_WAW_PUMPKINGUN.Chatter")
		end
	end
end

function ENT:Think()
	if CLIENT then
		if !self:GetRenderAngles() then self:SetRenderAngles(self:GetAngles()) end
		self:SetRenderAngles(self:GetVelocity():Angle() + Angle(90,0,0))
	end

	return BaseClass.Think( self )
end

function ENT:ShouldIncludeNearbyEntity(pEntity, ...)
	if pEntity:WAWIsPumpkin() then
		return false
	end
end

function ENT:FindNearestZombie(pos)
	if not nzombies then return end
	if not pos then
		pos = self:GetPos()
	end

	local nearestent
	local ply = IsValid(self:GetOwner()) and self:GetOwner() or self
	local tr = {
		start = pos,
		filter = {self, ply},
		mask = MASK_SHOT
	}

	if nzLevel then
		for k, v in nzLevel.GetZombieArray() do
			if v == ply then continue end
			if !TFA.WonderWeapon.ShouldDamage(v, ply, self) then continue end
			if v:WAWIsPumpkin() then continue end

			tr.endpos = v:WorldSpaceCenter()
			local tr1 = util.TraceLine(tr)
			if tr1.Entity ~= v then continue end

			nearestent = v
			break
		end
	else
		for k, v in pairs(ents.FindInPVS(ply)) do
			if not v:IsValidZombie() then continue end
			if v == ply then continue end
			if !TFA.WonderWeapon.ShouldDamage(v, ply, self) then continue end
			if v:WAWIsPumpkin() then continue end

			tr.endpos = v:WorldSpaceCenter()
			local tr1 = util.TraceLine(tr)
			if tr1.Entity ~= v then continue end

			nearestent = v
			break
		end
	end

	return nearestent
end

function ENT:DoExplosionEffect( ... )
	BaseClass.DoExplosionEffect( self, ... )

	if self.Talker then
		self:StopSound("TFA_WAW_PUMPKINGUN.Chatter")
		self:EmitSound("TFA_WAW_PUMPKINGUN.Kaboom")
	end
end

function ENT:PreExplosionDamage( hitEntity, explosionTrace, damageinfo, index, ExplosionTable )
	if ( hitEntity.NZBossType or hitEntity.IsMooBossZombie or hitEntity.IsMooMiniBoss ) then
		damageinfo:SetDamage(math.max(1800, v:GetMaxHealth() / 7))
	elseif ( hitEntity:IsNPC() or hitEntity:IsNextBot() ) and ( ( hitEntity:Health() - damageinfo:GetDamage() ) <= 0 or ( hitEntity.PumpkinMark and hitEntity.PumpkinMark >= 3 ) ) then
		if hitEntity.PumpkinMark then 
			hitEntity.PumpkinMark = 0
		end

		hitEntity:WAWPumpkin( math.Rand( 2, 3.2 ), damageinfo:GetAttacker(), damageinfo:GetInflictor(), self:GetUpgraded() )
		return true // block damage
	end

	local distfac = ExplosionTable["FalloffPercent"]

	if not hitEntity.PumpkinMark then hitEntity.PumpkinMark = 0 end
	hitEntity.PumpkinMark = hitEntity.PumpkinMark + ( ( distfac > 0.64 and 3 ) or ( distfac > 0.28 and 2 ) or 1 ) //90hu //180hu

	/*local pktimer = "pumpkin_decay"..v:EntIndex()
	if timer.Exists(pktimer) then
		timer.Remove(pktimer)
	end
	timer.Create(pktimer, 6, 0, function()
		if not IsValid(v) then timer.Remove(pktimer) return end
		if v:Health() <= 0 then timer.Remove(pktimer) return end
		if not v.PumpkinMark then v.PumpkinMark = 0 end
		v.PumpkinMark = math.max(v.PumpkinMark - 1, 0)
		if v.PumpkinMark == 0 then timer.Remove(pktimer) return end
	end)*/
end
