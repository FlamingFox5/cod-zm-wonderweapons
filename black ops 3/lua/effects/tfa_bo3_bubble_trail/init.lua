function EFFECT:Init(data)
	self.Entity = data:GetEntity()
	if not IsValid( self.Entity ) then return end

	self.Radius = data:GetRadius() or 4 // radius to emit bubbles ( in hammer units )
	self.Magnitude = data:GetMagnitude() or 1 // scale amount of bubbles to emit
	self.Scale = data:GetScale() or 1 // scale of actual bubble sprites

	self.CNewParticleSystem = CreateParticleSystem( self.Entity, "bo3_uwater_trail", PATTACH_ABSORIGIN_FOLLOW, 1 )

	self.CNewParticleSystem:SetControlPoint( 1, Vector( 0, self.Radius, self.Radius ) )
	self.CNewParticleSystem:SetControlPoint( 2, Vector( self.Magnitude, self.Magnitude, self.Magnitude ) )
	self.CNewParticleSystem:SetControlPoint( 4, Vector( self.Scale, self.Scale, self.Scale ) )

	local trace = util.TraceLine( {
		start = self.Entity:GetPos(),
		endpos = self.Entity:GetPos() + vector_up * 32768,
		mask = bit.bor( CONTENTS_WATER, CONTENTS_SLIME ),
	} )

	self.CNewParticleSystem:SetControlPoint( 6, trace.HitPos )

	self.WasUnderwater = self.IsUnderwater or self.Entity:WaterLevel() > 2

	self.IsUnderwater = self.Entity:WaterLevel() > 2

	self:SetPos( self.Entity:GetPos() )
end

function EFFECT:Think()
	if not IsValid( self.Entity ) then
		if self.CNewParticleSystem and IsValid( self.CNewParticleSystem ) then
			self.CNewParticleSystem:StopEmission()
		end

		return false
	end

	self:SetPos( self.Entity:GetPos() )

	self.IsUnderwater = self.Entity:WaterLevel() > 2

	if self.IsUnderwater ~= self.WasUnderwater then
		if self.CNewParticleSystem and IsValid( self.CNewParticleSystem ) then
			self.CNewParticleSystem:StopEmission()
		end

		return false
	end

	self.WasUnderwater = self.IsUnderwater

	self:SetPos( self.Entity:GetPos() )

	return true
end

function EFFECT:Render()
end