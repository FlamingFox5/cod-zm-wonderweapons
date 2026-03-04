local nzombies = engine.ActiveGamemode() == "nzombies"
local pvp_cvar = GetConVar("sbox_playershurtplayers")
local SinglePlayer = game.SinglePlayer()

//-------------------------------------------------------------
// Material Proxies
//-------------------------------------------------------------

if not matproxy then return end

matproxy.Add({
	name = "TFA_GetGlowLevel1",
	init = function(self, mat, values)
		self.ResultTo = values.resultvar
	end,
	bind = function(self, mat, ent)
		if not IsValid(ent) then return end

		local parent = ent:GetParent()
		local owner = (IsValid(parent) and parent.GetActiveWeapon) and parent or ent:GetOwner()
		local weapon = ent

		if not (IsValid(weapon) and weapon:IsWeapon()) and IsValid(owner) and owner.GetActiveWeapon then
			weapon = owner:GetActiveWeapon()
		end
		if not (IsValid(weapon) and weapon:IsWeapon()) and owner:IsWeapon() then
			weapon = owner
		end

		if not (IsValid(weapon) and weapon:IsWeapon()) or not weapon.GetGlowLevel then return end

		local int = (weapon:GetGlowLevel() > 0) and 1 or 0
		mat:SetInt(self.ResultTo, int)
	end
})

matproxy.Add({
	name = "TFA_GetGlowLevel2",
	init = function(self, mat, values)
		self.ResultTo = values.resultvar
	end,
	bind = function(self, mat, ent)
		if not IsValid(ent) then return end

		local parent = ent:GetParent()
		local owner = (IsValid(parent) and parent.GetActiveWeapon) and parent or ent:GetOwner()
		local weapon = ent

		if not (IsValid(weapon) and weapon:IsWeapon()) and IsValid(owner) and owner.GetActiveWeapon then
			weapon = owner:GetActiveWeapon()
		end
		if not (IsValid(weapon) and weapon:IsWeapon()) and owner:IsWeapon() then
			weapon = owner
		end

		if not (IsValid(weapon) and weapon:IsWeapon()) or not weapon.GetGlowLevel then return end

		local int = (weapon:GetGlowLevel() > 1) and 1 or 0
		mat:SetInt(self.ResultTo, int)
	end
})

matproxy.Add({
	name = "TFA_GetGlowLevel3",
	init = function(self, mat, values)
		self.ResultTo = values.resultvar
	end,
	bind = function(self, mat, ent)
		if not IsValid(ent) then return end

		local parent = ent:GetParent()
		local owner = (IsValid(parent) and parent.GetActiveWeapon) and parent or ent:GetOwner()
		local weapon = ent

		if not (IsValid(weapon) and weapon:IsWeapon()) and IsValid(owner) and owner.GetActiveWeapon then
			weapon = owner:GetActiveWeapon()
		end
		if not (IsValid(weapon) and weapon:IsWeapon()) and owner:IsWeapon() then
			weapon = owner
		end

		if not (IsValid(weapon) and weapon:IsWeapon()) or not weapon.GetGlowLevel then return end

		local int = (weapon:GetGlowLevel() > 2) and 1 or 0
		mat:SetInt(self.ResultTo, int)
	end
})

matproxy.Add({
	name = "TFA_GetGlowLevel4",
	init = function(self, mat, values)
		self.ResultTo = values.resultvar
	end,
	bind = function(self, mat, ent)
		if not IsValid(ent) then return end

		local parent = ent:GetParent()
		local owner = (IsValid(parent) and parent.GetActiveWeapon) and parent or ent:GetOwner()
		local weapon = ent

		if not (IsValid(weapon) and weapon:IsWeapon()) and IsValid(owner) and owner.GetActiveWeapon then
			weapon = owner:GetActiveWeapon()
		end
		if not (IsValid(weapon) and weapon:IsWeapon()) and owner:IsWeapon() then
			weapon = owner
		end

		if not (IsValid(weapon) and weapon:IsWeapon()) or not weapon.GetGlowLevel then return end

		local int = (weapon:GetGlowLevel() > 3) and 1 or 0
		mat:SetInt(self.ResultTo, int)
	end
})

matproxy.Add({
	name = "TFA_GetMainGlow",
	init = function(self, mat, values)
		self.ResultTo = values.resultvar
	end,
	bind = function(self, mat, ent)
		if not IsValid(ent) then return end

		local parent = ent:GetParent()
		local owner = (IsValid(parent) and parent.GetActiveWeapon) and parent or ent:GetOwner()
		local weapon = ent

		if not (IsValid(weapon) and weapon:IsWeapon()) and IsValid(owner) and owner.GetActiveWeapon then
			weapon = owner:GetActiveWeapon()
		end
		if not (IsValid(weapon) and weapon:IsWeapon()) and owner:IsWeapon() then
			weapon = owner
		end

		if not (IsValid(weapon) and weapon:IsWeapon()) or not weapon.GetMainGlow then return end

		local int = weapon:GetMainGlow() and 1 or 0
		mat:SetInt(self.ResultTo, int)
	end
})

matproxy.Add({
	name = "TFA_GetGlowRatio",
	init = function(self, mat, values)
		self.ResultTo = values.resultvar
	end,
	bind = function(self, mat, ent)
		if not IsValid(ent) then return end

		local parent = ent:GetParent()
		local owner = (IsValid(parent) and parent.GetActiveWeapon) and parent or ent:GetOwner()
		local weapon = ent

		if not (IsValid(weapon) and weapon:IsWeapon()) and IsValid(owner) and owner.GetActiveWeapon then
			weapon = owner:GetActiveWeapon()
		end

		if not (IsValid(weapon) and weapon:IsWeapon()) or not weapon.GetGlowRatio then return end

		mat:SetFloat(self.ResultTo, weapon:GetGlowRatio())
	end
})
