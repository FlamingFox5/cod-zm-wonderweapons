function EFFECT:Init(data)
	self.WeaponEnt = data:GetEntity()
	self.Attachment = data:GetAttachment()
	if not IsValid(self.WeaponEnt) then return end

	ParticleEffectAttach("bo3_waffe_3p_smoke", PATTACH_POINT_FOLLOW, self.WeaponEnt, self.Attachment)
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end