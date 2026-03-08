include("shared.lua")

include("common/effects.lua")
include("common/utility.lua")

local nzombies = engine.ActiveGamemode() == "nzombies"

local dlight_cvar = GetConVar("cl_tfa_fx_wonderweapon_dlights")

local developer = GetConVar("developer")

local SinglePlayer = game.SinglePlayer()

net.Receive( "TFA.BO3WW.FOX.Explode.TracerSound", function( length )
	local vecStop = net.ReadVector()
	local vecStart = net.ReadVector()
	local nType = net.ReadUInt( 4 )
	local soundOverride = net.ReadString()

	if soundOverride == "" or not file.Exists("sound/"..soundOverride, "GAME") then
		soundOverride = nil
	end

	effects.TracerSound( vecStart, vecStop, nType, soundOverride )
end )

function ENT:Draw( nFlags )
	if !self.NoDrawNoShadow then
		self:DrawModel()
	end

	if self.TrailEffect ~= nil and isstring( self.TrailEffect ) then
		if ( !self.TrailCNewParticle ) or ( !IsValid( self.TrailCNewParticle ) ) then
			self.TrailCNewParticle = CreateParticleSystem( self, self.TrailEffect, self.TrailAttachType or PATTACH_ABSORIGIN_FOLLOW, self.TrailAttachPoint or 1, self.TrailOffset or Vector())

		elseif ( IsValid( self.TrailCNewParticle ) ) and ( self.TrailCNewParticle:GetEffectName() ~= tostring( self.TrailEffect ) ) then
			self.TrailCNewParticle:StopEmissionAndDestroyImmediately()

			self.TrailCNewParticle = CreateParticleSystem( self, self.TrailEffect, self.TrailAttachType or PATTACH_ABSORIGIN_FOLLOW, self.TrailAttachPoint or 1, self.TrailOffset or Vector())
		end
	end

	if ( ( self.GetActivated and ( self:GetActivated() and !self.TrailEffectActiveLooping ) ) or ( self.GetImpacted and self:GetImpacted() ) ) and self.TrailCNewParticle and IsValid( self.TrailCNewParticle ) then
		self.TrailCNewParticle:StopEmission()
	elseif ( self.GetActivated and ( !self:GetActivated() and self.TrailEffectActiveLooping ) ) and self.TrailCNewParticle and IsValid( self.TrailCNewParticle ) then
		self.TrailCNewParticle:StopEmission()
	end
end

function ENT:Initialize()
	/*local mdl = self:GetModel()
	if (not mdl or mdl == "" or mdl == "models/error.mdl") and self.DefaultModel then
		self:SetModel(self.DefaultModel)
	end

	self.Size = ( self.HullMaxs[1] + self.HullMaxs[2] + self.HullMaxs[3] ) / 3

	if not self.ShouldUseCollisionModel then
		self:PhysicsInitSphere( self.SizeOverride or self.Size, self.SurfacePropOverride or "default" )
	else
		self:PhysicsInit( SOLID_VPHYSICS )
	end

	self:SetSolid( SOLID_VPHYSICS )

	self:SetCollisionGroup( nzombies and COLLISION_GROUP_DEBRIS or COLLISION_GROUP_PROJECTILE )

	self:SetMoveType( MOVETYPE_VPHYSICS )

	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)*/

	// TESTING

	self:SetFriction( 1 )
	self:DrawShadow( true )

	/*local phys = self:GetPhysicsObject()
	if IsValid( phys ) then
		phys:Wake()

		if !self.SpawnGravityEnabled then
			phys:EnableGravity( false )
			phys:EnableDrag( false )
		end

		phys:SetBuoyancyRatio( self.BuoyancyRatio or 0 )
		phys:AddGameFlag( FVPHYSICS_NO_IMPACT_DMG )
		phys:AddGameFlag( FVPHYSICS_NO_NPC_IMPACT_DMG )
	end*/

	if self.GetUpgraded and self:GetUpgraded() then
		self.TrailEffect = self.TrailEffectPaP or self.TrailEffect
		self.TrailSound = self.TrailSoundPaP or self.TrailSound
		self.TrailOffset = self.TrailOffsetPaP or self.TrailOffset

		self.Delay = self.DelayPaP or self.Delay
		self.Range = self.RangePaP or self.Delay
		self.Color = self.ColorPaP or self.Color

		self.StartSound = self.StartSoundPaP or self.StartSound
		self.FluxSound = self.FluxSoundPaP or self.FluxSound
		self.LoopSound = self.LoopSoundPaP or self.LoopSound

		self.ExplosionEffect = self.ExplosionEffectPaP or self.ExplosionEffect
		self.ExplosionSound = self.ExplosionSoundPaP or self.ExplosionSound

		self.DeflectionRange = self.DeflectionRangePaP or self.DeflectionRange
		self.DeflectionSearchRadius = self.DeflectionSearchRadiusPaP or self.DeflectionSearchRadius
		self.DeflectionDotAngle = self.DeflectionDotAnglePaP or self.DeflectionDotAngle
		self.DeflectionGuideFactor = self.DeflectionGuideFactorPaP or self.DeflectionGuideFactor

		self.GlowSpriteTrailColor = self.GlowSpriteTrailColorPaP or self.GlowSpriteTrailColor
	end

	self.killtime = CurTime() + self.Delay

	self.DefaultTickRateScale = ( 66 / ( 1 / engine.TickInterval() ) )

	self:NextThink( CurTime() )

	if self.TrailSound then
		self:EmitSound(self.TrailSound)
	end

	if self.LoopSound then
		self:EmitSound(self.LoopSound)
	end

	if self.FluxSound then
		self:EmitSound(self.FluxSound)
	end

	if self.StartSound and ( !SinglePlayer or ( SinglePlayer and SERVER) ) then
		sound.Play(self.StartSound, self:GetPos())
	end

	if self.NoDrawNoShadow then
		//self:SetNoDraw( true )
		self:DrawShadow( false )
		self:AddEffects( bit.bor( EF_NORECEIVESHADOW, EF_NOSHADOW ) )
	end

	self.FrameTime = engine.TickInterval()

	if self.MaxHealth then
		self:SetHealth(self.MaxHealth)
	end

	self:CallOnRemove( "onremove_hack"..self:EntIndex(), function( removed )
		if CLIENT then
			if istable( self.CNewParticlesTable ) then
				for _, CNewParticleSystem in pairs( self.CNewParticlesTable ) do
					if IsValid( CNewParticleSystem ) then
						CNewParticleSystem:StopEmission()
					end
				end
			end

			if self.TrailCNewParticle and IsValid( self.TrailCNewParticle ) then
				self.TrailCNewParticle:StopEmission()
			end

			if self.DLightFlashOnRemove and self.DoDynamicLightFlash then
				self:DoDynamicLightFlash()
			end
		end

		if self.LoopSound then
			self:StopSound(self.LoopSound)
		end

		if self.TrailSound then
			self:StopSound(self.TrailSound)
		end
	end )
end

function ENT:Think()
	if self.Color and dlight_cvar:GetInt() == 1 and DynamicLight and ( self.DLightSize == nil or self.DLightSize > 0 ) then
		self.DLight = self.DLight or DynamicLight( self:EntIndex() )
		if ( self.DLight ) and ( !self.DLightOnActivated or ( self.GetActivated == nil or self:GetActivated() ) ) then
			local DLightPos = self:GetPos()

			if self.DLightAttachment then
				local attData = self:GetAttachment(self.DLightAttachment)
				if attData and attData.Pos and not attData.Pos:IsZero() then
					DLightPos = attData.Pos
				end
			end

			if self.DLightOffset and not self.DLightOffset:IsZero() then
				DLightPos:Add( self:GetUp() * self.DLightOffset[3] )
				DLightPos:Add( self:GetRight() * self.DLightOffset[2] )
				DLightPos:Add( self:GetForward() * self.DLightOffset[1] )
			end

			self.DLight.pos = DLightPos
			self.DLight.r = self.Color.r
			self.DLight.g = self.Color.g
			self.DLight.b = self.Color.b
			self.DLight.brightness = self.DLightBrightness or 1
			self.DLight.decay = self.DLightDecay or 2000
			self.DLight.size = self.DLightSize or 200
			self.DLight.dietime = CurTime() + ( 1000 / ( self.DLightDecay or 2000 ) )
		end
	end

	self:SetNextClientThink( CurTime() )
	return true
end
