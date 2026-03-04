function EFFECT:Init(data)
	self.Position = data:GetOrigin()
	self.Normal = data:GetNormal()
	self.Magnitude = data:GetMagnitude() or 1 // scale amount of bubbles to emit
	self.Radius = data:GetRadius() or 100 // radius to emit bubbles ( in hammer units )

	self.CNewParticleSystem = CreateParticleSystemNoEntity("bo3_uwater_impact", self.Position, self.Normal:Angle())

	self.CNewParticleSystem:SetControlPoint(1, Vector(0, self.Radius, self.Radius))
	self.CNewParticleSystem:SetControlPoint(2, Vector(self.Magnitude, self.Magnitude, self.Magnitude))

	local trace = util.TraceLine({
		start = self.Position,
		endpos = self.Position + vector_up*32768,
		mask = bit.bor(CONTENTS_WATER, CONTENTS_SLIME),
	})

	self.CNewParticleSystem:SetControlPoint(6, trace.HitPos)
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end