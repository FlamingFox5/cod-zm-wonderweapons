
AddCSLuaFile()

ENT.Base = "bo3_ww_thundergun"
ENT.PrintName = "More Wind"

ENT.TrailEffect = "bo4_thundergun_trail"
ENT.TrailEffectPaP = nil

DEFINE_BASECLASS(ENT.Base)

function ENT:OnRemove()
	self:StopParticles()

	local ply = self:GetOwner()
	local wep = self.Inflictor
	if SERVER and IsValid(ply) and IsValid(wep) and wep:GetClass() == "tfa_bo4_thundergun" and math.random(8) == 1 and (not wep.NextChatterDelay or wep.NextChatterDelay < CurTime()) then
		wep.NextChatterDelay = CurTime() + 18
		wep:EmitSound("TFA_BO3_THUNDERGUN.Chatter")
	end
end