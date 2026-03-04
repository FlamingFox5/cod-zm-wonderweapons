EFFECT.Life = 0
EFFECT.MaxLife = 1

local ang_correct = Angle(90,0,0)
function EFFECT:Init(data)
	self.Position = data:GetOrigin()
	self.Angles = data:GetAngles()
	self.Projectile = data:GetEntity()
	self.Attachment = data:GetAttachment()

	if not IsValid( self.Projectile ) then return end

	local owner = self.Projectile:GetOwner()
	if IsValid( owner ) and owner.GetActiveWeapon and IsValid( owner:GetActiveWeapon() ) then
		self.StartPos = self:GetTracerShootPos(self.Position, owner:GetActiveWeapon(), self.Attachment)
	end

	self.Life = 0
	self.MaxLife = 1
	self:SetRenderBoundsWS(self.StartPos, self.StartPos, Vector(1000,1000,1000))

	ParticleEffect("bo4_freezegun_blast", self.StartPos, self.Angles)
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end