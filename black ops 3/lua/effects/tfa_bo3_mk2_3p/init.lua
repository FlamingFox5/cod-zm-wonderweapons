function EFFECT:Init(data)
	self.WeaponEnt = data:GetEntity()
	if not IsValid(self.WeaponEnt) then return end

	if self.WeaponEnt:IsCarriedByLocalPlayer() and self.WeaponEnt:IsFirstPerson() then
		return
	end

	local flags = data:GetFlags() or 0
	self.Upgraded = tobool(flags > 0)

	if self.Upgraded then
		ParticleEffectAttach("bo3_mk2_arc_3p_2", PATTACH_POINT_FOLLOW, self.WeaponEnt, 4)
		ParticleEffectAttach("bo3_mk2_arcb_3p_2", PATTACH_POINT_FOLLOW, self.WeaponEnt, 5)
	else
		ParticleEffectAttach("bo3_mk2_arc_3p", PATTACH_POINT_FOLLOW, self.WeaponEnt, 4)
		ParticleEffectAttach("bo3_mk2_arcb_3p", PATTACH_POINT_FOLLOW, self.WeaponEnt, 5)
	end
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end