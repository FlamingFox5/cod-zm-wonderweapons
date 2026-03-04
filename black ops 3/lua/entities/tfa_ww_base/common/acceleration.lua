
ENT.ProjectileCurve = false // curve projectile randomly about
ENT.CurveSineRate = 30 // how many times the projectile curve oscillates from a positive to negative value per second
ENT.CurveStrengthMin = 0 // minimum curving strength
ENT.CurveStrengthMax = 1 // maximum curving strength

ENT.UnderWaterSpeedRatio = 0.785 // speed reduction ratio when in water ( only with projectile acceleration enabled )

ENT.BaseSpeed = nil // starting speed in hammer units
ENT.MaxSpeed = nil // maximum movement speed in hammer units

ENT.ProjectileAccelerate = false // projectile will slowly accelerate from the given basespeed to maxspeed over the given duration, this overrides default behavior and speed assigned by the SWEP inflictor
ENT.AccelerationTime = 1 // time it takes to reach full speed

// DONT TOUCH
ENT.AccelProgress = 0

function ENT:AccelerationThink()
	local phys = self:GetPhysicsObject()

	if self.AccelerationTime > 0 and self.AccelProgress < 1 then
		self.LastAccelThink = self.LastAccelThink or CurTime()
		self.AccelProgress = Lerp( ( CurTime() - self.LastAccelThink ) / self.AccelerationTime, self.AccelProgress, 1 )
	end

	if IsValid( phys ) and phys:IsMotionEnabled() then
		if self.BaseSpeed == nil then
			self.BaseSpeed = phys:GetVelocity()
		end

		self.Speed = Lerp( self.AccelProgress, self.BaseSpeed, self.MaxSpeed )
		if not self.IsUnderwater then
			phys:SetVelocity( self:GetForward() * self.Speed )
		else
			phys:SetVelocity( self:GetForward() * ( self.Speed * ( self.UnderWaterSpeedRatio or 0.5 ) ) )
		end

		if self.ProjectileCurve then
			phys:AddAngleVelocity( VectorRand() * ( math.sin( CurTime() * self.CurveSineRate ) ) * math.random( self.CurveStrengthMin, self.CurveStrengthMax ) )
			self:SetAngles( phys:GetVelocity():Angle() )
		end
	end
end
