
// Currently deflection requires the use of the acceleration module

ENT.ProjectileDeflection = false
ENT.ProjectileTargeting = false
ENT.DeflectionDelay = 0.2 // how often the projectile can deflect towards an enemy when Entity:DeflectTowardEnemy( trace, direction ) is called
ENT.DeflectionSeekKill = false // should the projectile seek out enemies within 360 degrees from point of impact
ENT.DeflectionRange = 2048 // radius to check for entities when deflecting towards them
ENT.DeflectionSearchRadius = 1024 // radius to check for entities when deflecting towards them
ENT.DeflectionDotAngle = 15 // angle in degrees to try and find enemies to redirect towards from point of impact
ENT.DeflectionGuideFactor = 0.5 // amount to multiply the search angle by for every bounce

// DONT TOUCH
ENT.DeflectionCount = 0

local MAX_COORD_FLOAT = 16384.0

function ENT:Deflect( data, trace, speed )
	if not data then return end

	local impulse = ( data.OurOldVelocity - 2 * data.OurOldVelocity:Dot( data.HitNormal ) * data.HitNormal ) * 0.25

	local direction = data.OurNewVelocity:GetNormalized()

	if speed == nil or not isnumber( speed ) then
		speed = impulse:Length()
	end

	phys:SetVelocity( direction * ( speed or self.MaxSpeed ) )

	if self.ProjectileTargeting then
		self:DeflectTowardEnemy( trace, direction )
	end
end

function ENT:DeflectTowardEnemy( trace, direction )
	if self.fl_LastDeflect and self.fl_LastDeflect + ( self.DeflectionDelay or 0.2 ) > CurTime() then
		self.fl_LastDeflect = 0
		return
	end

	local bestTarget
	local vecStartPoint = trace.HitPos
	local flBestDist = MAX_COORD_FLOAT
	local vecDelta

	if self.DeflectionSeekKill then
		local oldSearch = self.FindCharacterOnly
		self.FindCharacterOnly = true

		local entList = self:FindNearestEntities( trace.HitPos, self.DeflectionSearchRadius or 1024 )

		self.FindCharacterOnly = oldSearch

		for i=1, #entList do
			local ent = entList[i]
			if not IsValid(ent) then continue end

			local vecDelta = ent:WorldSpaceCenter()
			vecDelta:Sub(trace.HitPos)

			local flDistance = vecDelta:GetNormalized():Length()
			if flDistance < flBestDist then
				if vecDelta:Dot(direction) > 0.0 then
					bestTarget = ent
					flBestDist = flDistance
				end
			end
		end
	else
		local flMaxDot = self.DeflectionDotAngle or 20
		local flGuideFactor = self.DeflectionGuideFactor or 0.5

		for i=1, self.DeflectionCount do
			flMaxDot = flMaxDot * flGuideFactor
		end

		flMaxDot = math.Clamp( math.cos( flMaxDot * math.pi / 180 ), 0, 1 )

		local extents = Vector(256, 256, 256)
		local entList = ents.FindAlongRay( trace.HitPos, trace.HitPos + ( direction * ( self.DeflectionRange or 2048 ) ), extents:GetNegated(), extents )

		for i=1, #entList do
			local ent = entList[i]
			if not IsValid(ent) then continue end
			if not ( ent:IsNPC() or ent:IsNextBot() or ent:IsPlayer() ) then continue end
			if not self:IsAttractiveTarget( ent ) then continue end

			local vecDelta = ent:WorldSpaceCenter()
			vecDelta:Sub( trace.HitPos )
			vecDelta:Normalize()

			local flDistance = vecDelta:GetNormalized():Length()
			flDot = vecDelta:Dot( direction )

			if flDot > flMaxDot then
				if flDistance < flBestDist then
					bestTarget = ent
					flBestDist = flDistance
				end
			end
		end
	end

	if IsValid( bestTarget ) then
		self.DeflectionCount = 1 + self.DeflectionCount

		local vecDelta = bestTarget:WorldSpaceCenter()
		vecDelta:Sub(vecStartPoint)
		vecDelta:Normalize()

		self.fl_LastDeflect = CurTime()

		local phys = self:GetPhysicsObject()
		if IsValid( phys ) then
			if !self.Speed then
				self.Speed = phys:GetVelocity()
			end

			self:SetAngles( vecDelta:Angle() )

			phys:SetVelocity( vecDelta * self.Speed )
		end

		return vecDelta
	end
end
