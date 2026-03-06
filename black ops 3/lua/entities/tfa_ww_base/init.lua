// SERVER
include("shared.lua")

include("common/acceleration.lua")
include("common/augerdeath.lua")
include("common/collision.lua")
include("common/deflection.lua")
include("common/effects.lua")
include("common/explode.lua")
include("common/homing.lua")
include("common/monkeybomb.lua")
include("common/rotorwash.lua")
include("common/sticking.lua")
include("common/utility.lua")
include("common/whizby.lua")

// CLIENT
AddCSLuaFile("common/effects.lua")
AddCSLuaFile("common/utility.lua")

AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

util.AddNetworkString("TFA.BO3WW.FOX.Explode.TracerSound")

local nzombies = engine.ActiveGamemode() == "nzombies"

local SinglePlayer = game.SinglePlayer()

local CurTime = CurTime
local IsValid = IsValid

local bit_AND = bit.band

local util_PointContents = util.PointContents

local CONTENTS_SLIME = CONTENTS_SLIME
local CONTENTS_LIQUID = bit.bor( CONTENTS_WATER, CONTENTS_SLIME )

local CreateRotorWash = TFA.WonderWeapon.CreateRotorWash

function ENT:PhysicsCollide( data, phys )
	local trace = self:CollisionDataToTrace( data )

	if self.ProjectileDeflection then
		self:Deflect( data, trace )
	end

	return trace
end

function ENT:Initialize()
	local mdl = self:GetModel()
	if (not mdl or mdl == "" or mdl == "models/error.mdl") and self.DefaultModel then
		self:SetModel(self.DefaultModel)
	end

	self.Size = ( self.HullMaxs[1] + self.HullMaxs[2] + self.HullMaxs[3] ) / 3

	self:SetMoveType( self.MoveTypeOverride or MOVETYPE_VPHYSICS )

	if self.SizeOverride then
		self:PhysicsInitSphere( self.SizeOverride or self.Size, self.SurfacePropOverride or "default" )
	else
		self:PhysicsInit( SOLID_VPHYSICS )
	end

	self:SetSolid( SOLID_VPHYSICS )

	// TESTING
	self:SetCollisionGroup( nzombies and COLLISION_GROUP_DEBRIS or COLLISION_GROUP_PROJECTILE )

	//self:PhysicsInit( SOLID_VPHYSICS )
	//self:SetMoveType( MOVETYPE_VPHYSICS )
	//self:SetSolid( SOLID_VPHYSICS )

	//self:SetFriction( 1 )
	self:DrawShadow( true )

	if self.BuoyancyRatio and self.BuoyancyRatio == 0 then
		self:AddEFlags( EFL_NO_WATER_VELOCITY_CHANGE )
	end

	local phys = self:GetPhysicsObject()
	if IsValid( phys ) then
		phys:Wake()

		if !self.SpawnGravityEnabled then
			phys:EnableGravity( false )
			phys:EnableDrag( false )
		end

		phys:SetBuoyancyRatio( self.BuoyancyRatio or 0 )
		phys:AddGameFlag( FVPHYSICS_NO_IMPACT_DMG )
		phys:AddGameFlag( FVPHYSICS_NO_NPC_IMPACT_DMG )

		local vecMin, vecMax = phys:GetAABB()
		if not vecMax or not isvector( vecMax ) or vecMax == vector_origin then
			vecMin, vecMax = self:GetCollisionBounds()
		end

		local padding = Vector(0.1, 0.1, 0.1)
		vecMin:Add(padding)
		vecMax:Add(padding)

		self.HullMins = vecMin
		self.HullMaxs = vecMax
	end

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

	self:CallOnRemove( "onremove_hack"..self:EntIndex(), function( removed )
		if self.ExplodeOnRemove then
			if self.ExplosionScreenShake then
				self:ScreenShake()
			end
			self:Explode()
		end

		if self.SpriteTrail and IsValid( self.SpriteTrail ) then
			SafeRemoveEntityDelayed( self.SpriteTrail, self.SpriteTrailLifetime )
		end

		if self.pGlowSprite and IsValid( self.pGlowSprite ) then
			SafeRemoveEntity( self.pGlowSprite )
		end

		if self.pBullseye and IsValid( self.pBullseye ) then
			SafeRemoveEntity( self.pBullseye )
		end

		if self.pRotorWashEmitter and IsValid( self.pRotorWashEmitter ) then
			SafeRemoveEntity( self.pRotorWashEmitter )
		end

		if self.pRotorBlast then
			self.pRotorBlast:Stop()
		end

		if self.LoopSound then
			self:StopSound(self.LoopSound)
		end

		if self.TrailSound then
			self:StopSound(self.TrailSound)
		end
	end )

	if self.MaxHealth then
		self:SetHealth(self.MaxHealth)
	end

	if self.MaxHealth then
		self:SetMaxHealth(self.MaxHealth)
	end

	if self.ShouldDoRotorWash and !self.RotorWashWaterSurfaceOnly then
		if !self.pRotorWashEmitter or !IsValid( self.pRotorWashEmitter ) then
			self.pRotorWashEmitter = CreateRotorWash( self:GetPos(), self:GetAngles(), self, self.RotorWashAltitude or BASECHOPPER_WASH_ALTITUDE )
		end
	end

	if self.RotorBlastSound then
		// Start the blast sound and then immediately drop it to 0 (starting it at 0 wouldn't start it)
		self.pRotorBlast = CreateSound( self, self.RotorBlastSound )
		self.pRotorBlast:PlayEx( 1, 100 )
		self.pRotorBlast:SetSoundLevel( self.RotorBlastSoundLevel or SNDLVL_TALKING )
		self.pRotorBlast:ChangeVolume( 0, 0 )
	end

	if self.GlowSpriteTrail then
		self:CreateGlowSprite(self.GlowSpriteTrailLife or self.Delay, self.GlowSpriteTrailColor or self.Color, self.GlowSpriteTrailAlpha or 255, self.GlowSpriteTrailSize or 0.15)

		if self.pGlowSprite and IsValid( self.pGlowSprite ) then
			self.pGlowSprite:SetPos( self:GetPos() )
			self.pGlowSprite:SetParent( self )
			self.pGlowSprite:SetLocalPos( self.GlowSpriteOffset or Vector() )
		end
	end

	local ply = self:GetOwner()
	if not self.Inflictor and ply:IsValid() and ply.GetActiveWeapon and ply:GetActiveWeapon():IsValid() then
		self.Inflictor = ply:GetActiveWeapon()
	end

	self.Damage = self.mydamage or self.Damage

	if bit_AND( util_PointContents( self:GetPos() ), CONTENTS_LIQUID ) != 0 then
		self.IsUnderwater = true

		if self.RemoveInWater then
			self:SetHitPos(self:GetPos())
			self:Remove()
			return
		elseif self.BubbleTrail then
			self:CreateBubbleTrail()
		end
	else
		self.IsUnderwater = false
	end

	if IsValid( self.Inflictor ) and self.Inflictor.IsTFAWeapon then
		self.MaxSpeed = self.Inflictor:GetStatL("Primary.ProjectileVelocity", 4000)
		self.Speed = self.MaxSpeed

		self:TraceForCollisions( self:GetPos(), self:GetAngles():Forward(), self.Inflictor:GetStatL("Primary.ProjectileVelocity", 4000) )
	end

	if self.SpriteTrailMaterial and not self.SpawnMenuCreated then
		self:CreateSpriteTrail()
	end
end

function ENT:Think()
	if self.killtime < CurTime() and tobool( self.RemoveOnKilltimeEnd ) then
		if self.ExplodeOnKilltimeEnd then
			if self.ExplosionScreenShake then
				self:ScreenShake()
			end
			self:Explode()
		end

		self:Remove()
		return false
	end

	// acceleration think
	if self.ProjectileAccelerate then
		self:AccelerationThink()
	end

	// targetting think
	if self.ProjectileHoming then
		self:HomingThink()
	end

	// auger think
	if self.HasShotDown then
		self:AugerThink()
	end

	// rotor wash think
	if self.ShouldDoRotorWash then
		self:RotorWashThink()
	end

	local bCollisionPassed = self:CollisionTraceThink()
	if bCollisionPassed ~= nil and not bCollisionPassed then
		// stop thinking for a frame
		self:NextThink( CurTime() )
		return false
	end

	local p = self:GetParent()
	if IsValid( p ) and p:GetMaxHealth() > 0 and ( p:GetInternalVariable( "m_lifeState" ) ~= 0 or ( nzombies and p:IsValidZombie() and p.IsAlive and !p:IsAlive() ) ) then
		self:DropFromParent()
	end

	self:NextThink( CurTime() )
	return true
end

// REPLACE ME!!
function ENT:EntityCollide( collisionTrace ) // alternative to StartTouch because source hates me
end

// REPLACE ME!!
function ENT:CallbackOnParent( collisionTrace ) // called after self:SetParent(trace.Entity)
end

// REPLACE ME!!
function ENT:CallbackOnDrop( parentEntity ) // use this to do something like reset collision / activation variables that prohibit movement
end

// REPLACE ME!!
function ENT:PreExplosionDamage( hitEntity, explosionTrace, damageinfo, index, ExplosionTable ) // use this to set variables, call events, or modify/block damage to an entity before damage is applied
end

// REPLACE ME!!
function ENT:PostExplosionDamage( hitEntity, explosionTrace, damageinfo, index, ExplosionTable ) // use this to set variables, call events, or reset damageinfo variables after damage is applied
end

// ExplosionTable Data Structure
/*
ExplosionTable = {
	["Entity"] = The entity hit by the trace, will not always be the explosions target ( an interposing entity ).
	["ExplosionTrace"] = The trace that hit the entity.
	["ExplosionOrigin"] = The origin of the explosion, or point of impact.
	["DamagePosition"] = The position on the entity to attempt to trace to.
	["DamageAmount"] = The amount of damage the explosion will do.
	["BlockedPercent"] = Damage blocked percentage by interposing object's mass.
	["FalloffPercent"] = Damage falloff percentage by distance.
	["Distance"] = Distance from damage position to explosion origin.
}
*/

// REPLACE ME!!
function ENT:OnWaterEnter( waterTrace, collisionTrace )
end

// REPLACE ME!!
function ENT:OnWaterExit( waterTrace, collisionTrace )
end

// REPLACE ME!!
function ENT:OnCollisionEnd( hitEntity ) // not equivalent to EndTouch, called when X entity that we hit (with EntityCollide) is no longer within the projectiles hull mins / maxs. depending on how far we move in 1 frame this could be called from rather far away
end
