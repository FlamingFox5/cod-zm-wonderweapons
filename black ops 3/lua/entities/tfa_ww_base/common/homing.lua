
//ENT.CustomNetworkVar["Entity"] = "Target"

ENT.ProjectileHoming = false
ENT.SearchRange = 512
ENT.SearchCenterMass = true // TODO: add bone option to target
ENT.SearchStartDelay = 0.2

ENT.TargetCurveStrength = 1 // ~1.5 seconds to fully angle towards target

// DONT TOUCH
ENT.CurveRatio = 0

function ENT:HomingThink()
	local pTarget = self:GetTarget()

	if IsValid( pTarget ) then
		local vecToTarget = ( pTarget:GetPos() - self:GetPos() ) + ( self.SearchCenterMass and pTarget:OBBCenter() or vector_origin )
		self.CurveRatio = math.Clamp( self.CurveRatio + ( ( ( self.TargetCurveStrength or 1 ) / 100 ) * self.DefaultTickRateScale ), 0, 1 )

		self:SetAngles( LerpAngle( self.CurveRatio, self:GetAngles(), vecToTarget:Angle() ) )
	else
		self.CurveRatio = math.Clamp( self.CurveRatio - ( ( ( self.TargetCurveStrength or 1 ) / 100 ) * self.DefaultTickRateScale ), 0, 1 )
	end

	if self:GetUpgraded() and ( ( !IsValid( pTarget ) and ( self:GetCreationTime() + self.SearchStartDelay ) < CurTime() ) or ( IsValid( pTarget ) and ( pTarget:Health() <= 0 or !pTarget:Alive() ) ) ) then
		if nzombies then
			self:SetTarget( self:FindNearestZombie( self:GetPos() ) )
		else
			self:SetTarget( self:FindNearestEntity( self:GetPos(), self.SearchRange ) )
		end
	end
end
