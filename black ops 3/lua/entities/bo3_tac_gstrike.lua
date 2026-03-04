
AddCSLuaFile()

ENT.Base = "tfa_ww_tacnade_base"
ENT.PrintName = "G-Strike"
ENT.AutomaticFrameAdvance = true

// Custom Settings

ENT.MaxMissiles = 15
ENT.NumMissiles = 0

ENT.MortarWait = 4
ENT.MortarDelay = 0.25

// Default Settings

ENT.ForcedKillTime = 20

ENT.Delay = 25

ENT.SizeOverride = 8

ENT.HullMaxs = Vector(2, 2, 2)
ENT.HullMins = ENT.HullMaxs:GetNegated()

ENT.BounceSound = "TFA_BO3_GSTRIKE.Bounce"
ENT.BounceActivationSpeed = 100
ENT.BounceVelocityRatio = 0.4

ENT.DisablePhysicsOnActivate = true

ENT.ParentToMoveableEntities = true

ENT.ImpactBubbles = true
ENT.ImpactBubblesSize = 32
ENT.ImpactBubblesMagnitude = 0.5

// DLight Settings

ENT.Color = Color(185, 70, 255)

ENT.DLightBrightness = 1
ENT.DLightDecay = 2000
ENT.DLightSize = 250

ENT.DLightOnActivated = true

DEFINE_BASECLASS(ENT.Base)

function ENT:ActivateCustom(phys)
	timer.Simple( 0, function()
		if not IsValid( self ) then return end
		self:SetMoveType( MOVETYPE_NONE )
	end )

	self.NextScream = CurTime()

	self:EmitSound( "TFA_BO3_GSTRIKE.Alarm" )

	self:ResetSequence("deploy")
	timer.Simple( self:SequenceDuration( "deploy" ), function() 
		if IsValid( self ) then
			self:ResetSequence( "play" )
		end
	end )

	self.LandingSpots = {}
	self.StartingSpots = {}

	self.NextMortar = CurTime() + self.MortarWait
	self.NextGlow = CurTime() + 0.5

	self:SetActivated(true)
end

function ENT:Think()
	if SERVER then
		if self:GetActivated() and (!self.NextScream or self.NextScream < CurTime()) and self.NumMissiles < self.MaxMissiles then
			sound.Play("TFA_BO3_GSTRIKE.Beep", self:GetPos() + vector_up * 4)

			ParticleEffectAttach( "bo3_gstrike", PATTACH_POINT_FOLLOW, self, 1 )

			self.NextScream = CurTime() + 1.5
		end

		if self:GetActivated() then
			self:MonkeyBombNXB()
			self:MonkeyBomb()
		end

		if self:GetActivated() and ( self.NextMortar == nil or self.NextMortar < CurTime() ) and self.NumMissiles < self.MaxMissiles then
			self:Mortar()

			self.NextMortar = CurTime() + self.MortarDelay

			if self.NumMissiles%5 == 0 then
				self.NextMortar = CurTime() + 1
			end
		end

		if self.NumMissiles >= self.MaxMissiles then
			SafeRemoveEntityDelayed(self, 1)
			return false
		end
	end

	self:NextThink(CurTime())
	return true
end

function ENT:Mortar()
	local i = self.NumMissiles%5
	local a_v_land_offsets = self:BuildLandingOffset()
	local a_v_start_offsets = self:BuildStartingOffset()

	self.StartingSpots[i] = self:GetPos() + a_v_start_offsets[i]
	self.LandingSpots[i] = self:GetPos() + a_v_land_offsets[i]

	local v_start_trace = self.StartingSpots[i] - Vector(0, 0, 2000)

	uptrace = util.QuickTrace(self:GetPos(), Vector(0,0,8000), self)

	local trace = util.TraceLine({
		start = v_start_trace,
		endpos = self.LandingSpots[i],
		filter = self,
		mask = MASK_SOLID,
		ignoreworld = (uptrace.HitWorld or uptrace.HitSky),
	})

	if not util.IsInWorld(trace.HitPos) then
		trace = util.TraceLine({
			start = trace.HitPos - trace.HitNormal,
			endpos = self.LandingSpots[i],
			filter = self,
			mask = MASK_SOLID,
			ignoreworld = (uptrace.HitWorld or uptrace.HitSky),
		})
	end

	self.LandingSpots[i] = trace.HitPos

	if SERVER then
		local dist = self.StartingSpots[i]:Distance(self.LandingSpots[i])

		local mortar = ents.Create("bo3_tac_gstrike_mortar")
		mortar:SetModel("models/weapons/tfa_bo3/qed/w_maxgl_proj.mdl")
		mortar:SetPos(self.StartingSpots[i])
		mortar:SetAngles(Angle(90,0,0))
		mortar:SetOwner(IsValid(self:GetOwner()) and self:GetOwner() or self)

		mortar.Damage = self.mydamage
		mortar.mydamage = self.mydamage
		mortar.Delay = 12
		mortar:SetLandingSpot(self.LandingSpots[i])

		mortar:Spawn()

		local dir = (self.LandingSpots[i] - self.StartingSpots[i]):GetNormalized()*dist

		mortar:SetVelocity(dir)
		local phys = mortar:GetPhysicsObject()
		if IsValid(phys) then
			phys:SetVelocity(dir)
		end

		mortar:SetOwner(IsValid(self:GetOwner()) and self:GetOwner() or self)
		mortar.Inflictor = IsValid(self.Inflictor) and self.Inflictor or self
	end

	self.NumMissiles = self.NumMissiles + 1
end

function ENT:BuildLandingOffset()
	local a_offsets = {}
	a_offsets[0] = Vector(0, 0, 1)
	a_offsets[1] = Vector(-1, 1, 0) * math.random(60,180)
	a_offsets[2] = Vector(1, 1, 0) * math.random(60,180)
	a_offsets[3] = Vector(1, -1, 0) * math.random(60,180)
	a_offsets[4] = Vector(-1, -1, 0) * math.random(60,180)

	return a_offsets
end

function ENT:BuildStartingOffset()
	local a_offsets = {}
	a_offsets[0] = Vector( 0, 0, 6000)
	a_offsets[1] = Vector(-1500, 1500, 6000)
	a_offsets[2] = Vector(1500, 1500, 6000)
	a_offsets[3] = Vector(1500, -1500, 6000)
	a_offsets[4] = Vector(-1500, -1500, 6000)

	return a_offsets
end
