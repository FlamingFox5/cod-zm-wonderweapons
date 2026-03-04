function EFFECT:Init(data)
	self.WeaponEnt = data:GetEntity()
	if not IsValid(self.WeaponEnt) then return end

	ParticleEffectAttach( "bo3_jgb_attack_3p", PATTACH_POINT_FOLLOW, self.WeaponEnt, 3 )
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end