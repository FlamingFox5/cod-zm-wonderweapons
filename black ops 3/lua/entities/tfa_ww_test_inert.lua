
AddCSLuaFile()

ENT.Base = "tfa_ww_base"
ENT.PrintName = "Intert"
ENT.Purpose = "Test the base projectile."
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.Category = "Testing"

// Default Settings

ENT.Delay = 10
ENT.Range = 10
ENT.Damage = 21

ENT.SpawnGravityEnabled = true

ENT.DefaultModel = "models/dav0r/hoverball.mdl"

ENT.HullMaxs = Vector(2, 2, 2)
ENT.HullMins = ENT.HullMaxs:GetNegated()

ENT.ImpactBubbles = true
ENT.ImpactBubblesSize = 128
ENT.ImpactBubblesMagnitude = 1

DEFINE_BASECLASS(ENT.Base)

local nzombies = engine.ActiveGamemode() == "nzombies"

function ENT:SpawnFunction( ply, tr, ClassName )
	if ( !tr.Hit ) then return end

	local size = 32
	local SpawnPos = tr.HitPos + tr.HitNormal * size

	local oobTr = util.TraceLine( {
		start = tr.HitPos,
		endpos = SpawnPos,
		mask = MASK_SOLID_BRUSHONLY
	} )

	if ( oobTr.Hit ) then
		SpawnPos = oobTr.HitPos + oobTr.HitNormal * ( tr.HitPos:Distance( oobTr.HitPos ) / 2 )
	end

	local flDist = (ply:GetShootPos() - tr.HitPos):Length()
	local direction = tr.HitNormal:Angle()
	local velocity = Vector()

	if flDist <= 2048 then
		SpawnPos = ply:GetShootPos() + ply:GetAimVector()

		local time = 1.4 * math.Clamp( flDist / 2048, 0, 1 )
		local diff = tr.HitPos - SpawnPos --subtract the vectors

		local velx = diff.x/time -- x velocity
		local vely = diff.y/time -- y velocity
		local velz = (diff.z - 0.5*(-GetConVarNumber( "sv_gravity"))*(time^2))/time --  x = x0 + vt + 0.5at^2 conversion

		velocity:SetUnpacked(velx, vely, velz)
		direction = velocity:GetNormalized()
	end

	local ent = ents.Create( ClassName )
	ent:SetPos( SpawnPos )
	ent:SetAngles( direction:Angle() )

	ent.Inflictor = ent

	ent.SpawnMenuCreated = true

	ent:Spawn()
	ent:Activate()

	local phys = ent:GetPhysicsObject()
	if IsValid( phys ) then
		phys:SetMass( 5 )
		phys:SetBuoyancyRatio( 0 )
		phys:Wake()

		phys:SetVelocity( velocity )
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

		util.ScreenShake( data.HitPos, 1 * fac, 5, 0.3 * (fac/2.5), 60 * fac )

		if data.Speed >= 300 then
			local surfdata = util.GetSurfaceData( data.TheirSurfaceProps )
			if IsValid( hitEntity ) and ( ( hitEntity:GetCollisionGroup() == COLLISION_GROUP_BREAKABLE_GLASS ) or ( surfdata and surfdata.material == MAT_GLASS ) or ( surfdata and surfdata.breakSound and surfdata.breakSound ~= "" and file.Exists( "sound/" .. surfdata.breakSound, "GAME" ) ) ) then
				hitEntity:Input( "break" )
				phys:SetVelocityInstantaneous( direction * data.OurOldVelocity:Length() )
			end
		end
	end
end

function ENT:EntityCollide( trace )
	if self.Speed > 60 then
		self:DoImpactEffect( trace )

		local fac = math.Clamp( self.Speed / 100, 1, 5 )
		util.ScreenShake( self.HitPos, 1 * fac, 5, 0.3 * (fac/2.5), 60 * fac )
	end
end

function ENT:Initialize( ... )
	BaseClass.Initialize( self, ... )

	self:SetMaterial( "models/weapons/tfa_bo3/gersch/lambert1" )
end
