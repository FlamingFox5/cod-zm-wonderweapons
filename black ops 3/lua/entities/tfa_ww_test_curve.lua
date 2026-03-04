
AddCSLuaFile()

ENT.Base = "tfa_ww_base"
ENT.PrintName = "Random Deviation"
ENT.Purpose = "Test projectile base 'Acceleration' (Curve) module."
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.Category = "Testing"

// Default Settings

ENT.Delay = 10
ENT.Range = 10
ENT.Damage = 21

ENT.DefaultModel = "models/dav0r/hoverball.mdl"

ENT.HullMaxs = Vector(2, 2, 2)
ENT.HullMins = ENT.HullMaxs:GetNegated()

ENT.ImpactBubbles = true
ENT.ImpactBubblesSize = 128
ENT.ImpactBubblesMagnitude = 1

// Acceleration Settings

ENT.ProjectileCurve = true
ENT.CurveSineRate = 30
ENT.CurveStrengthMin = 0
ENT.CurveStrengthMax = 1

ENT.ProjectileAccelerate = true
ENT.AccelerationTime = 0.5
ENT.UnderWaterSpeedRatio = 0.6
ENT.BaseSpeed = 2000
ENT.MaxSpeed = 2400

DEFINE_BASECLASS(ENT.Base)

local nzombies = engine.ActiveGamemode() == "nzombies"

function ENT:SpawnFunction( ply, tr, ClassName )
	if ( !tr.Hit ) then return end

	local size = 32
	local direction = ply:GetAimVector()
	local SpawnPos = ply:GetShootPos() + ply:GetAimVector()*16

	local ent = ents.Create( ClassName )
	ent:SetPos( SpawnPos )
	ent:SetAngles( direction:Angle() )
	ent:SetOwner( ply )
	ent.CurveStrengthMin = math.random( 2 ) == 1 and 0 or 1
	ent.CurveStrengthMax = math.random( 2, 24 )

	ent.Inflictor = ent

	ent.SpawnMenuCreated = true

	ent:Spawn()
	ent:Activate()

	local phys = ent:GetPhysicsObject()
	if IsValid( phys ) then
		phys:SetMass( 1 )
		phys:SetBuoyancyRatio( 0.5 )
		phys:Wake()
		phys:SetVelocity(direction)
	end

	return ent
end

function ENT:GravGunPunt( ply )
	local phys = self:GetPhysicsObject()
	if IsValid( phys ) then
		phys:EnableDrag( true )
		phys:EnableGravity( true )
	end
	return true
end

function ENT:PhysicsCollide( data, phys )
	if self.Impacted then return end
	self.Impacted = true

	local trace = self:CollisionDataToTrace(data)
	local direction = data.OurOldVelocity:GetNormalized()
	local hitEntity = trace.Entity

	if data.Speed > 60 then
		self:DoImpactEffect( trace )

		local fac = math.Clamp( data.Speed / 100, 1, 5 )

		if data.Speed >= 100 then
			if trace.Hit and IsValid( hitEntity ) and TFA.WonderWeapon.ShouldDamage( hitEntity, self:GetOwner(), self ) and !hitEntity:IsPlayer() then
				local hitCharacter = ( hitEntity:IsNPC() or hitEntity:IsPlayer() or hitEntity:IsNextBot() )

				local hitDamage = DamageInfo()
				hitDamage:SetDamage(self.Damage * fac)
				hitDamage:SetAttacker(IsValid(self:GetOwner()) and self:GetOwner() or self)
				hitDamage:SetInflictor(IsValid(self.Inflictor) and self.Inflictor or self)
				hitDamage:SetDamageType(DMG_SONIC)
				hitDamage:SetDamageForce(hitCharacter and direction*math.random(12000,16000) or direction*2000)
				hitDamage:SetDamagePosition(trace.HitPos)
				hitDamage:SetReportedPosition(trace.StartPos)

				local nLastHealth = hitEntity:Health()

				hitEntity:DispatchTraceAttack( hitDamage, trace, direction )

				if hitEntity:Health() < nLastHealth then
					self:SendHitMarker( hitEntity, hitDamage, trace )
				end
			end
		end

		util.ScreenShake( data.HitPos, 1 * fac, 5, 0.4 * (fac/2), 60 * fac )

		if data.Speed >= 300 then
			local surfdata = util.GetSurfaceData( data.TheirSurfaceProps )
			if IsValid( hitEntity ) and ( ( hitEntity:GetCollisionGroup() == COLLISION_GROUP_BREAKABLE_GLASS ) or ( surfdata and surfdata.material == MAT_GLASS ) or ( surfdata and surfdata.breakSound and surfdata.breakSound ~= "" and file.Exists( "sound/" .. surfdata.breakSound, "GAME" ) ) ) then
				hitEntity:Input( "break" )
				phys:SetVelocityInstantaneous( direction * data.OurOldVelocity:Length() )
			end
		end
	end

	self:PhysicsStop( phys )

	self:Remove()
end

function ENT:EntityCollide( trace )
	if self.Impacted then return end
	self.Impacted = true

	if self.Speed > 60 then
		self:DoImpactEffect( trace )

		local fac = math.Clamp( data.Speed / 100, 1, 5 )

		if data.Speed >= 100 then
			if trace.Hit and IsValid( hitEntity ) and TFA.WonderWeapon.ShouldDamage( hitEntity, self:GetOwner(), self ) and !hitEntity:IsPlayer() then
				local hitCharacter = ( hitEntity:IsNPC() or hitEntity:IsPlayer() or hitEntity:IsNextBot() )

				local hitDamage = DamageInfo()
				hitDamage:SetDamage(self.Damage * fac)
				hitDamage:SetAttacker(IsValid(self:GetOwner()) and self:GetOwner() or self)
				hitDamage:SetInflictor(IsValid(self.Inflictor) and self.Inflictor or self)
				hitDamage:SetDamageType(DMG_SONIC)
				hitDamage:SetDamageForce(hitCharacter and direction*math.random(12000,16000) or direction*2000)
				hitDamage:SetDamagePosition(trace.HitPos)
				hitDamage:SetReportedPosition(trace.StartPos)

				local nLastHealth = hitEntity:Health()

				hitEntity:DispatchTraceAttack( hitDamage, trace, direction )

				if hitEntity:Health() < nLastHealth then
					self:SendHitMarker( hitEntity, hitDamage, trace )
				end
			end
		end

		util.ScreenShake( data.HitPos, 1 * fac, 5, 0.3 * (fac/2.5), 60 * fac )
	end

	self:PhysicsStop()

	self:Remove()
	return true
end

function ENT:Initialize( ... )
	BaseClass.Initialize( self, ... )

	self:SetMaterial( "models/weapons/tfa_bo3/gersch/lambert1" )
end
