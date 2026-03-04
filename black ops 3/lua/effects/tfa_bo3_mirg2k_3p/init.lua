function EFFECT:Init(data)
	self.WeaponEnt = data:GetEntity()
	if not IsValid(self.WeaponEnt) then return end

	local upgrade = data:GetFlags() or 0
	self.Upgraded = upgrade > 0
	ParticleEffectAttach(self.Upgraded and "bo3_mirg2k_3p_smoke_2" or "bo3_mirg2k_3p_smoke", PATTACH_POINT_FOLLOW, self.WeaponEnt, 8)
	ParticleEffectAttach(self.Upgraded and "bo3_mirg2k_3p_smoke_2" or "bo3_mirg2k_3p_smoke", PATTACH_POINT_FOLLOW, self.WeaponEnt, 9)
	ParticleEffectAttach(self.Upgraded and "bo3_mirg2k_3p_smoke_2" or "bo3_mirg2k_3p_smoke", PATTACH_POINT_FOLLOW, self.WeaponEnt, 10)
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end