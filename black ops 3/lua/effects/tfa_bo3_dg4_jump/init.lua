local CONTENTS_LIQUID = bit.bor( CONTENTS_WATER, CONTENTS_SLIME )

function EFFECT:Init(data)
	self.StartPos = data:GetStart()
	self.EndPos = data:GetOrigin()

	local effect = "bo3_dg4_jump"
	if bit.band(util.PointContents(self.StartPos), CONTENTS_LIQUID) ~= 0 and bit.band(util.PointContents(self.EndPos), CONTENTS_LIQUID) ~= 0 then
		effect = "bo3_dg4_jump_uwater"
	end

	self.CNewParticle = CreateParticleSystemNoEntity(tostring(effect), self.StartPos, angle_zero)
	if self.CNewParticle and IsValid(self.CNewParticle) then
		self.CNewParticle:SetControlPoint(0, self.StartPos)
		self.CNewParticle:SetControlPoint(1, self.EndPos)
	end
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end