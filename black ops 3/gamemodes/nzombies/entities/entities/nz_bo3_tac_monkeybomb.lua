
AddCSLuaFile()

ENT.Base = "nz_ww_tacnade_base"
ENT.PrintName = "Monkey Bomb"
ENT.AutomaticFrameAdvance = true

// Custom Settings

ENT.MonkeySong = "TFA_BO3_MNKEY.Song"
ENT.MonkeySongPaP = "TFA_BO3_MNKEY.Upg.Song"

ENT.Burning = false

ENT.SongDelay = 6
ENT.SongDelayPaP = 7

// Default Settings

ENT.ForcedKillTime = 30

ENT.Delay = 7.5
ENT.DelayPAP = 8.5
ENT.Range = 200

ENT.SizeOverride = 1

ENT.HullMaxs = Vector(2, 2, 2)
ENT.HullMins = ENT.HullMaxs:GetNegated()

ENT.BounceSound = "TFA_BO3_MNKEY.VOX.Bounce"
ENT.BounceActivationSpeed = 100
ENT.BounceVelocityRatio = 0.4

ENT.ThrowSound = "TFA_BO3_MNKEY.VOX.Throw"
ENT.ThrowSoundPaP = "TFA_BO3_MNKEY.VOX.Upg.Throw"

ENT.FindSolidOnly = true

ENT.RemoveOnKilltimeEnd = false

// Explosion Settings

ENT.ExplosionBubbles = true
ENT.ExplosionBubblesSize = 200
ENT.ExplosionBubblesMagnitude = 4

ENT.ExplosionMaxBlockingMass = 350
ENT.ExplosionDamageType = bit.bor(DMG_BLAST, DMG_AIRBOAT)
ENT.ExplosionHeadShotScale = 3
ENT.ExplosionHitsOwner = false
ENT.ExplosionOwnerDamage = 50

ENT.WaterBlockExplosions = false

ENT.ScreenShakeAmplitude = 10
ENT.ScreenShakeFrequency = 255
ENT.ScreenShakeDuration = 1.25
ENT.ScreenShakeRange = 400

ENT.ExplosionSound1 = "TFA_BO3_GRENADE.Dist"
ENT.ExplosionSound2 = "TFA_BO3_GRENADE.Exp"
ENT.ExplosionSound3 = "TFA_BO3_GRENADE.ExpClose"
ENT.ExplosionSound4 = "TFA_BO3_GRENADE.Flux"

// DLight Settings

ENT.Color = Color(245, 245, 255)

ENT.DLightAttachment = 1
ENT.DLightBrightness = 1
ENT.DLightDecay = 2000
ENT.DLightSize = 128

ENT.DLightFlashOnRemove = true

ENT.DLightFlashSize = 200
ENT.DLightFlashDecay = 2000
ENT.DLightFlashBrightness = 2

// nZombies Settings

ENT.NZThrowIcon = Material("vgui/icon/hud_cymbal_monkey_bo2.png", "unlitgeneric smooth")
ENT.NZTacticalPaP = true

DEFINE_BASECLASS(ENT.Base)

local CurTime = CurTime
local IsValid = IsValid

local bit_AND = bit.band

local util_TraceLine = util.TraceLine
local util_PointContents = util.PointContents
local util_ScreenShake = util.ScreenShake

local MASK_SHOT = MASK_SHOT
local CONTENTS_SLIME = CONTENTS_SLIME
local CONTENTS_LIQUID = bit.bor( CONTENTS_WATER, CONTENTS_SLIME )

local dlight_cvar = GetConVar("cl_tfa_fx_wonderweapon_dlights")
function ENT:ActivateCustom(phys)
	self:SetActivated(true)

	timer.Simple(0, function()
		if not IsValid( self ) then return end
		self:SetMoveType( MOVETYPE_NONE )
		self:SetCollisionGroup( COLLISION_GROUP_WORLD )
	end)

	self:ResetSequence("play")
	self.NextScream = CurTime() + 0.35

	self:SetTargetPriority(TARGET_PRIORITY_SPECIAL)
	UpdateAllZombieTargets(self)

	local mins, maxs = self:GetModelBounds()
	mins, maxs = self:LocalToWorld(mins), self:LocalToWorld(maxs)

	for _, trigger in pairs(ents.FindInBox(mins, maxs)) do
		if ( trigger:GetClass() == "trigger_hurt" and bit.band(trigger:GetInternalVariable('damagetype'), DMG_BURN) ~= 0 ) then
			self.Burning = true
			self:Ignite(self.Delay)
			break
		end
	end

	if !self.Burning then
		for _, fire in pairs(ents.FindInSphere(self:GetPos(), 24)) do
			if ( fire:GetClass() == "env_fire" and tobool( fire:GetInternalVariable('m_bEnabled') ) and self:VisibleVec( fire:GetPos() ) ) then
				self.Burning = true
				self:Ignite(self.Delay)
				break
			end

			// because TF2 doesnt have a working 'env_fire' i have to kill my self out of shame
			if ( fire:GetClass() == "info_particle_system" and self:VisibleVec( fire:GetPos() ) ) then
				local particleName = tostring( fire:GetInternalVariable('effect_name') )
				if particleName and isstring( particleName ) then
					local namelength = #particleName

					// ends with 'flame'
					local _, i = string.find( particleName, "flame" )
					if i and i == namelength then
						self.Burning = true
						self:Ignite(self.Delay)
						break
					end

					// ends with 'fire'
					local _, fucking = string.find( particleName, "fire" )
					if fucking and fucking == namelength then
						self.Burning = true
						self:Ignite(self.Delay)
						break
					end

					// starts with 'burning_'
					local hate, _ = string.find( particleName, "burning_" )
					if hate and hate == 1 then
						self.Burning = true
						self:Ignite(self.Delay)
						break
					end

					// starts with 'candle'
					local patterns, _ = string.find( particleName, "candle_" )
					if patterns and patterns == 1 then
						self.Burning = true
						self:Ignite(self.Delay)
						break
					end
				end
			end 
		end
	end

	self:EmitSound(self.Burning and "TFA_BO3_MNKEY.VOX.Scream" or self.MonkeySong)

	self.killtime = CurTime() + self.Delay
	self.soundtime = CurTime() + self.SongDelay

	ParticleEffectAttach("bo3_monkeybomb_glow", PATTACH_POINT_FOLLOW, self, 1)
	ParticleEffectAttach("bo3_monkeybomb_blink", PATTACH_POINT_FOLLOW, self, 2)
end

function ENT:Initialize(...)
	BaseClass.Initialize(self, ...)

	self:SetSkin(self:GetUpgraded() and 1 or 0)

	if self:GetUpgraded() then
		self.SongDelay = self.SongDelayPaP or self.SongDelay
		self.MonkeySong = self.MonkeySongPaP or self.MonkeySong
	end
end

function ENT:Initialize(...)
	BaseClass.Initialize(self, ...)

	self:SetSkin(self:GetUpgraded() and 1 or 0)

	if self:GetUpgraded() then
		self.SongDelay = self.SongDelayPaP or self.SongDelay
		self.MonkeySong = self.MonkeySongPaP or self.MonkeySong
	end
end

function ENT:OnTakeDamage(damageinfo)
	local attacker = damageinfo:GetAttacker()
	if self.killtime and bit.band(damageinfo:GetDamageType(), DMG_BURN) ~= 0 and !self.Burning then
		self.Burning = true
		self:Ignite(self.killtime - CurTime())

		self:StopSound(self.MonkeySong)
		self:EmitSound("TFA_BO3_MNKEY.VOX.Scream")
	end
end

function ENT:Think()
	if SERVER then
		local ply = self:GetOwner()
		if self.NextScream and self.NextScream < CurTime() and not self.HasEmitSound and self:GetUpgraded() then
			self:DoRadiusDamage()

			ParticleEffect("bo3_monkeybomb_pap", self:WorldSpaceCenter(), Angle(0,0,0))
			self.NextScream = CurTime() + 1/2
		end

		if self:GetActivated() and self.soundtime < CurTime() and not self.HasEmitSound and not self.Burning then
			self.HasEmitSound = true
			//self:ResetSequence("death")

			self:EmitSound(self:GetUpgraded() and "TFA_BO3_MNKEY.VOX.Upg.Explode" or "TFA_BO3_MNKEY.VOX.Explode")
		end

		if self:GetActivated() and self.killtime < CurTime() then
			self:StopSound("TFA_BO3_MNKEY.VOX.Scream")

			if self.ExplosionScreenShake then
				self:ScreenShake()
			end

			self:Explode()

			self:Remove()
			return false
		end
	end

	return BaseClass.Think(self)
end

function ENT:Explode(...)
	self:StopSound("TFA_BO3_MNKEY.Scream")

	BaseClass.Explode(self, ...)
end

function ENT:DoRadiusDamage()
	local vecSrc = self:GetPos()

	local ply = self:GetOwner()

	local nearbyEnts = self:FindNearestEntities( self:GetPos(), 64 )

	local tr = {
		start = vecSrc,
		filter = { self, self.Inflictor },
		mask = MASK_SHOT,
		collsiongroup = COLLISION_GROUP_NONE,
	}

	local pPlayer = ( IsValid(self:GetOwner()) and self:GetOwner() or self )
	local pWeapon = ( IsValid(self.Inflictor) and self.Inflictor or self )
	local pInflictor = self

	for k, ent in ipairs(nearbyEnts) do
		if ent:IsWeapon() then
			continue
		end

		local vecSpot = BodyTarget(ent, vecSrc, true)

		local dir = ( vecSpot - vecSrc ):GetNormalized()

		tr.endpos = vecSpot

		local trace = util_TraceLine(tr)

		local damageinfo = DamageInfo()
		damageinfo:SetDamage( self.Damage )
		damageinfo:SetDamageType( nzombies and DMG_BLAST or DMG_SONIC )
		damageinfo:SetAttacker( pPlayer )
		damageinfo:SetInflictor( nzombies and pWeapon or pInflictor )
		damageinfo:SetDamageForce( ent:GetUp() * math.random(12000,18000) + dir * math.random(18000,24000) )
		damageinfo:SetDamagePosition( trace.Entity == ent and trace.HitPos or vecSpot )
		damageinfo:SetReportedPosition( vecSrc )

		if IsValid(self.Inflictor) then
			damageinfo:SetWeapon( self.Inflictor )
		end

		if ent:IsNPC() and ent:Alive() and damageinfo:GetDamage() >= ent:Health() then
			ent:SetCondition(COND.NPC_UNFREEZE)
		end

		if trace.Entity == ent then
			trace.HitGroup = trace.HitGroup == HITGROUP_HEAD and HITGROUP_HEAD or HITGROUP_GENERIC

			self:DoImpactEffect( trace, true )

			local hitInWater = bit_AND( util_PointContents( trace.HitPos ), CONTENTS_LIQUID ) ~= 0
			if ( hitInWater and !bSubmerged ) or ( bSubmerged and !hitInWater ) then
				local trace2 = {}

				util_TraceLine({
					start = trace.StartPos,
					endpos = trace.HitPos,
					mask = CONTENTS_LIQUID,
					output = trace2,
				})

				local data = EffectData()
				data:SetOrigin( trace2.HitPos )
				data:SetNormal( trace2.HitNormal )
				data:SetScale( math.random(2,4) )
				data:SetFlags( bit_AND( trace2.Contents, CONTENTS_SLIME ) != 0 && 1 || 0 )

				DispatchEffect( "watersplash", data, false, true )
			end

			ent:DispatchTraceAttack( damageinfo, trace, dir )
		else
			ent:TakeDamageInfo( damageinfo )
		end

		table.insert( tr.filter, ent )

		self:SendHitMarker( ent, damageinfo, trace )
	end

	util_ScreenShake(vecSrc, 4, 255, 0.1, self.Range*1.5)
end

function ENT:OnRemove()
	self:StopSound("TFA_BO3_MNKEY.Scream")
	if SERVER then
		self:CleanupMonkeyBomb()
	end
end

function ENT:Explode()
	self:StopSound("TFA_BO3_MNKEY.Scream")

	local tr = {
		start = self:GetPos(),
		filter = {self, self:GetOwner()},
		mask = MASK_SOLID_BRUSHONLY
	}

	for k, v in pairs(ents.FindInSphere(self:GetPos(), 200)) do
		if not v:IsWorld() and v:IsSolid() then
			if !TFA.WonderWeapon.ShouldDamage(v, self:GetOwner(), self) then continue end

			tr.endpos = v:WorldSpaceCenter()
			local tr1 = util.TraceLine(tr)
			if tr1.HitWorld then continue end

			self:InflictDamage(v)
		end
	end

	self:DoExplosionEffect()
	self:Remove()
end
