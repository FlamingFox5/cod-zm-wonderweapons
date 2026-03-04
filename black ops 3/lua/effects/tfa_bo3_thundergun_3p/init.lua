local CONTENTS_LIQUID = bit.bor( CONTENTS_WATER, CONTENTS_SLIME )

function EFFECT:Init(data)
	self.WeaponEnt = data:GetEntity()
	if not IsValid(self.WeaponEnt) then return end

	local flag = data:GetFlags() or 0
	self.MagSmoke = flag > 0

	local finalPos = IsValid(self.WeaponEnt:GetOwner()) and self.WeaponEnt:GetOwner():EyePos() or self.WeaponEnt:GetPos()
	
	local isUnderwater = bit.band(util.PointContents(finalPos), CONTENTS_LIQUID) ~= 0

	if self.MagSmoke then
		ParticleEffectAttach(isUnderwater and "bo3_thundergun_3p_uwater" or "bo3_thundergun_3p_smoke", PATTACH_POINT_FOLLOW, self.WeaponEnt, 1)
	else
		ParticleEffectAttach(isUnderwater and "bo3_thundergun_3p_leak_uwater" or "bo3_thundergun_3p_leak", PATTACH_POINT_FOLLOW, self.WeaponEnt, 3)
		ParticleEffectAttach(isUnderwater and "bo3_thundergun_3p_leak_uwater" or "bo3_thundergun_3p_leak", PATTACH_POINT_FOLLOW, self.WeaponEnt, 4)
		ParticleEffectAttach(isUnderwater and "bo3_thundergun_3p_leak_uwater" or "bo3_thundergun_3p_leak", PATTACH_POINT_FOLLOW, self.WeaponEnt, 5)
	end
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end