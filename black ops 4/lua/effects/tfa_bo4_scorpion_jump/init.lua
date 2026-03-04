local CONTENTS_LIQUID = bit.bor( CONTENTS_WATER, CONTENTS_SLIME )

function EFFECT:Init(data)
	self.StartPos = data:GetStart()
	self.EndPos = data:GetOrigin()
	self.Entity = data:GetEntity()

	if not IsValid( self.Entity ) then return end
	if self.Entity:Health() <= 0 then return end

	local effect = "bo4_scorpion_jump"
	if bit.band(util.PointContents(self.StartPos), CONTENTS_LIQUID) ~= 0 and bit.band(util.PointContents(self.EndPos), CONTENTS_LIQUID) ~= 0 then
		effect = "bo4_scorpion_jump_uwater"
	end

	local beamAtt = self.Entity:LookupAttachment( "beam_damage" )
	self.ChestAttachment = ( beamAtt > 0 ) and beamAtt or TFA.WonderWeapon.GetChestAttachment( self.Entity )

	if self.ChestAttachment then
		local attData = self.Entity:GetAttachment( self.ChestAttachment )
		if attData.Pos then
			self.EndPos = attData.Pos
		end
	end

	self.CNewParticle = CreateParticleSystem(self.Entity, tostring(effect), PATTACH_CUSTOMORIGIN, 1)
	if self.CNewParticle and IsValid(self.CNewParticle) then
		self.CNewParticle:SetControlPoint(0, self.StartPos)
		self.CNewParticle:SetControlPoint(1, self.EndPos)
	end
end

function EFFECT:Think()
	if not IsValid( self.Entity ) then
		return false
	end

	if self.Entity:Health() <= 0 or !TFA.WonderWeapon.HasStatus( self.Entity, "BO4_Orion_Shock" ) then
		if self.CNewParticle and IsValid( self.CNewParticle ) then
			self.CNewParticle:StopEmission()
		end
		return false
	end

	return true
end

function EFFECT:Render()
	if IsValid( self.Entity ) and self.CNewParticle and IsValid( self.CNewParticle ) then
		self.EndPos = self.Entity:WorldSpaceCenter()

		if self.ChestAttachment then
			local attData = self.Entity:GetAttachment( self.ChestAttachment )
			if attData.Pos then
				self.EndPos = attData.Pos
			end
		end

		self.CNewParticle:SetControlPoint(1, self.EndPos)
	end
end