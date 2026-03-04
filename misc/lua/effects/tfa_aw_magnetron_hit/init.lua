local CONTENTS_LIQUID = bit.bor( CONTENTS_WATER, CONTENTS_SLIME )

function EFFECT:Init(data)
	self.WeaponEnt = data:GetEntity()
	self.Attachment = data:GetAttachment()
	self.Position = data:GetStart()
	self.EndPos = data:GetOrigin()
	self.HitNormal = data:GetNormal()
	self.Upgraded = (data:GetFlags() or 0) > 0

	if IsValid(self.WeaponEnt) and self.WeaponEnt.GetMuzzleAttachment then
		self.Attachment = self.WeaponEnt:GetMuzzleAttachment()
	end

	self.StartPos = self:GetTracerShootPos(self.Position, self.WeaponEnt, self.Attachment)
	self.EndPos = data:GetOrigin()

	self.Life = 0
	self.MaxLife = 0.4
	self:SetRenderBoundsWS(self.StartPos, self.EndPos, Vector(1000,1000,1000))

	local effect = self.Upgraded and "aw_magnetron_hit_2" or "aw_magnetron_hit"
	/*if bit.band(util.PointContents(self.StartPos), CONTENTS_LIQUID) ~= 0 and bit.band(util.PointContents(self.EndPos), CONTENTS_LIQUID) ~= 0 then
		effect = self.Upgraded and "bo3_waffe_jump_uwater_2" or "bo3_waffe_jump_uwater"
	end*/

	if IsValid(self.WeaponEnt:GetOwner()) and self.WeaponEnt:IsCarriedByLocalPlayer() and not self.WeaponEnt:GetOwner():ShouldDrawLocalPlayer() then
		self.WeaponEnt = self.WeaponEnt.OwnerViewModel
		self.IsViewModel = true
	end

	self.CNewParticle = CreateParticleSystem(self.WeaponEnt, effect, PATTACH_POINT_FOLLOW, self.Attachment)
	if self.CNewParticle and IsValid(self.CNewParticle) then
		self.CNewParticle:SetControlPoint(0, self.StartPos)
		self.CNewParticle:SetControlPoint(1, self.EndPos)
	end

	CreateParticleSystemNoEntity("aw_magnetron_hit_zap", self.EndPos, self.HitNormal:Angle())
end

//Think
function EFFECT:Think()
	self.Life = self.Life + FrameTime() * (1 / self.MaxLife)
	if self.Life >= 1 and self.CNewParticle and self.CNewParticle:IsValid() then
		self.CNewParticle:StopEmission()
	end

	return self.Life < 1
end

function EFFECT:Render()
end