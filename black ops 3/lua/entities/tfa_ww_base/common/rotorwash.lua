
local nzombies = engine.ActiveGamemode() == "nzombies"

local phys_pushscale = GetConVar("phys_pushscale")

local SinglePlayer = game.SinglePlayer()

ENT.ShouldDoRotorWash = false // do hl2 hunterchopper rotor wash effect when above the ground and water
ENT.ShouldRotorWashPushVPhysics = true // should rotor wash effect push physics objects
ENT.RotorWashWaterSurfaceOnly = false // should the rotor wash effect only show when on the water surface
ENT.RotorWashPushMaxObjects = 6 // max amount of objects that can be pushed at a time by rotor wash effect
ENT.RotorWashPushRadius = 256 // range of rotor wash physics pushing
ENT.RotorWashAltitude = 300 // range that rotor wash effect will trace downwards
ENT.RotorWashPushDamageType = DMG_BLAST // damagetype used by the Entity:TakePhysicsDamage( CTakeDamageInfo )
//ENT.RotorBlastSound = "NPC_AttackHelicopter.RotorBlast" // rotor wash blast sound effect (the big wooshing sound when stood beneath the helicopter)
ENT.RotorBlastSoundLevel = SNDLVL_TALKING // sound level for rotor wash blast sound

// DONT TOUCH
ENT.EntitiesPushedByWash = {}

local CurTime = CurTime
local IsValid = IsValid

local M_PI = math.pi

local util_TraceLine = util.TraceLine

local CONTENTS_SLIME = CONTENTS_SLIME
local CONTENTS_LIQUID = bit.bor( CONTENTS_WATER, CONTENTS_SLIME )

local ROTORWASH_THINK_INTERVAL = 0.01
local ROTORWASH_PUSH_ORIGIN_OFFSET = Vector(0, 0, 64)

local BASECHOPPER_WASH_MAX_OBJECTS = 6
local BASECHOPPER_WASH_RADIUS = 256
local BASECHOPPER_WASH_MAX_MASS = 300
local BASECHOPPER_WASH_RAMP_TIME = 1.0
local BASECHOPPER_WASH_PUSH_MIN = 30
local BASECHOPPER_WASH_PUSH_MAX = 40

local MatrixBuildRotationAboutAxis
local SimpleSplineRemapVal
local SimpleSpline

local BodyTarget = TFA.WonderWeapon.BodyTarget
local CreateRotorWash = TFA.WonderWeapon.CreateRotorWash

local DispatchEffect = util.Effect

function ENT:RotorWashThink()
	if ( self.NextRotorWashThink ) and ( self.NextRotorWashThink > CurTime() ) then
		return
	end

	local tr = {}

	util_TraceLine({
		start = self:GetPos(),
		endpos = self:GetPos() - vector_up * ( self.RotorWashAltitude or BASECHOPPER_WASH_ALTITUDE ),
		mask = self.RotorWashWaterSurfaceOnly and CONTENTS_LIQUID or MASK_SHOT,
		output = tr,
	})

	if tr.Hit then
		if !self.pRotorWashEmitter then
			self.pRotorWashEmitter = CreateRotorWash( self:GetPos(), self:GetAngles(), self, ( self.RotorWashAltitude or BASECHOPPER_WASH_ALTITUDE ) + 64 )
		end
	elseif self.pRotorWashEmitter and IsValid( self.pRotorWashEmitter ) then
		self.pRotorWashEmitter:Remove()
		self.pRotorWashEmitter = nil
	end

	self:DrawRotorWash( self.RotorWashAltitude or BASECHOPPER_WASH_ALTITUDE, self:GetPos() )

	self.NextRotorWashThink = CurTime() + ( self.RotorWashThinkDelay or ROTORWASH_THINK_INTERVAL )
end

function ENT:DrawRotorWash( altitude, position )
	// Shake any ropes nearby
	if math.random( 0, 2 ) == 0 then
		local data = EffectData()
		data:SetOrigin( position )
		data:SetRadius( altitude )
		data:SetMagnitude( 128 )

		DispatchEffect( "ShakeRopes", data, false, true )
	end

	if self:GetInternalVariable( "spawnflags", "32" ) then
		return
	end

	if ( !self.ShouldRotorWashPushVPhysics ) then
		return
	end

	self:DoRotorPhysicsPush( position, altitude )

	if ( self.RotorWashEntitySearchTime > CurTime() ) then
		return
	end

	// Only push every half second
	self.RotorWashEntitySearchTime = CurTime() + 0.5
end

function ENT:DoRotorPhysicsPush( position, altitude )
	local pEntity = NULL
	local tr = {}
	local trace_t = {
		start = position,
		endpos = position + Vector( 0, 0, -altitude ),
		mask = bit.bor( MASK_SOLID_BRUSHONLY, CONTENTS_LIQUID ),
		collisiongroup = COLLISION_GROUP_NONE,
		output = tr,
	}

	// First, trace down and find out where the was is hitting the ground
	util_TraceLine( trace_t )

	// Always raise the physics origin a bit
	local vecPhysicsOrigin = tr.HitPos + ( self.RotorWashPushOffset or ROTORWASH_PUSH_ORIGIN_OFFSET )

	// Debug
	debugoverlay.Axis( vecPhysicsOrigin, angle_zero, 16, 1, true)

	// Push entities that we've pushed before, and are still within range
	// Walk backwards because they may be removed if they're now out of range
	local iCount = #self.EntitiesPushedByWash
	local bWasPushingObjects = (iCount > 0);

	for i = 0, iCount - 1, 1 do
		local n = iCount - i
		if !self:DoWashPush( self.EntitiesPushedByWash[ n ], vecPhysicsOrigin ) then
			table.remove( self.EntitiesPushedByWash, n )
		end
	end

	if ( self.RotorWashEntitySearchTime > CurTime() ) then
		return
	end

	// Any spare slots?
	iCount = #self.EntitiesPushedByWash
	if ( iCount >= self.RotorWashPushMaxObjects ) then
		return
	end

	// Find the lightest physics entity below us and add it to our list to push around
	local pLightestEntity = NULL
	local flLightestMass = 9999

	/*for _, pEntity in pairs( self:FindNearestEntities( vecPhysicsOrigin, BASECHOPPER_WASH_RADIUS, { self }, true ) ) do
	end*/

	local entList = self:FindNearestEntities( vecPhysicsOrigin, self.RotorWashPushRadius, { self }, true )
	local k = 1
	while entList[ k ] and IsValid( entList[ k ] ) do
		pEntity = entList[ k ]
		k = k + 1

		if pEntity:IsEFlagSet( EFL_NO_ROTORWASH_PUSH ) then
			continue
		end

		if not pEntity.GetPhysicsObject then
			continue
		end

		local pPhysObject = pEntity:GetPhysicsObject()

		if pEntity:GetMoveType() == MOVETYPE_VPHYSICS and IsValid( pPhysObject ) and !pEntity:IsPlayer() then
			// Make sure it's not already in our wash
			local bAlreadyPushing = false;

			for i = 0, iCount - 1, 1 do
				local n = iCount - i
				if self.EntitiesPushedByWash[ iCount ].hEntity == pEntity then
					bAlreadyPushing = true
					break
				end
			end

			if ( bAlreadyPushing ) then
				continue
			end

			local flMass = math.huge
			if ( pShooter ) then
				flMass = 1.0
			else
				// Don't try to push anything too big
				flMass = pPhysObject:GetMass()
				if ( flMass > BASECHOPPER_WASH_MAX_MASS ) then
					continue
				end
			end

			// Ignore anything bigger than the one we've already found
			if ( flMass > flLightestMass ) then
				continue
			end

			local vecSpot = BodyTarget( pEntity, vecPhysicsOrigin )

			// Don't push things too far below our starting point (helps reduce through-roof cases w/o doing a trace)
			if ( math.abs( vecSpot.z - vecPhysicsOrigin.z ) > 96 ) then
				continue
			end

			local vecToSpot = ( vecSpot - vecPhysicsOrigin )
			vecToSpot.z = 0

			local flDist = vecToSpot:Length()
			if ( flDist > self.RotorWashPushRadius ) then
				continue
			end

			// Try to cast to the helicopter; if we can't, then we can't be hit.
			if ( pEntity:GetInternalVariable("m_pServerVehicle") ) then
				local trace_t = {
					start = vecSpot,
					endpos = vecPhysicsOrigin,
					mask = MASK_SOLID_BRUSHONLY,
					collisiongroup = COLLISION_GROUP_NONE,
					filter = pEntity,
					output = tr,
				}

				util_TraceLine( trace_t )

				if ( tr.Fraction ~= 1.0 ) then
					continue
				end
			end

			flLightestMass = flMass;
			pLightestEntity = pEntity;

			local Wash = {}
			Wash.hEntity = pLightestEntity;
			Wash.flWashStartTime = CurTime();

			table.insert(self.EntitiesPushedByWash, Wash)

			// Can we fit more after adding this one? No? Then we are done.
			iCount = #self.EntitiesPushedByWash
			if ( iCount >= self.RotorWashPushMaxObjects ) then
				break
			end
		end
	end
	
	// Handle sound.
	// If we just started pushing objects, ramp the blast sound up.
	if ( !bWasPushingObjects and #self.EntitiesPushedByWash > 0 ) then
		if ( self.pRotorBlast ) then
			self.pRotorBlast:ChangeVolume( 1, 1 )
		end
	elseif ( bWasPushingObjects and #self.EntitiesPushedByWash == 0 ) then
		// We just stopped pushing objects, so fade the blast sound out.
		if ( self.pRotorBlast ) then
			self.pRotorBlast:ChangeVolume( 0, 1 )
		end
	end
end

local MAX_AIRBOAT_ROLL_ANGLE = 20.0
local MAX_AIRBOAT_ROLL_COSANGLE = 0.866
local MAX_AIRBOAT_ROLL_COSANGLE_X2 = 0.5

function ENT:DoWashPushOnAirboat( pAirboat, vecWashToAirboat, flWashAmount )
	local vecUp = pAirboat:GetWorldTransformMatrix():GetUp()
	if vecUp.z < MAX_AIRBOAT_ROLL_COSANGLE then
		return
	end

	local vecRollNormal = vecWashToAirboat:Cross( Vector( 0, 0, 1 ) )

	vecUp = vecUp + vecRollNormal * ( -vecUp:Dot( vecRollNormal ) )
	vecUp:Normalize()

	local rot = MatrixBuildRotationAboutAxis( vecRollNormal, MAX_AIRBOAT_ROLL_ANGLE )
	local vecExtremeUp = rot:GetUp()

	local flCosDelta = vecExtremeUp:Dot( vecUp )
	local flDelta = math.acos( flCosDelta ) * 180.0 / M_PI()
	flDelta = math.Clamp( flDelta, 0, MAX_AIRBOAT_ROLL_ANGLE )
	flDelta = SimpleSplineRemapVal( flDelta, 0, MAX_AIRBOAT_ROLL_ANGLE, 0, 1 )

	local flForce = 12.0 * flWashAmount * flDelta

	local vecForce = Vector( 0, 0, -1 ) * flForce
	local vecWashOrigin = pAirboat:GetPos() + ( vecWashToAirboat * -200 )

	debugoverlay.Axis( vecWashOrigin, angle_zero, 4, 0.1, true )
	debugoverlay.Line( vecWashOrigin, pAirboat:GetPos() + vecForce, 0.1, color_white, true )

	local damage = DamageInfo()
	damage:SetAttacker( self )
	damage:SetInflictor( self )
	damage:SetDamagePosition( vecWashOrigin )
	damage:SetDamageForce( vecForce )
	damage:SetDamage( flWashAmount )
	damage:SetDamageType( self.RotorWashPushDamageType or DMG_BLAST )

	pAirboat:TakePhysicsDamage( damage )
end

function ENT:DoWashPush( pWash, vecWashOrigin )
	if ( !pWash or !pWash.hEntity ) then
		return false
	end

	// Make sure the entity is still within our wash's radius
	local pEntity = pWash.hEntity

	// This can happen because we can dynamically turn this flag on and off
	if ( pEntity:IsEFlagSet( EFL_NO_ROTORWASH_PUSH )) then
		return false
	end

	local vecSpot = BodyTarget( pEntity, vecWashOrigin )
	local vecToSpot = ( vecSpot - vecWashOrigin )
	vecToSpot.z = 0;

	local flDist = vecToSpot:Length()
	if ( flDist > self.RotorWashPushRadius ) then
		return false
	end

	local pPhysObject

	local flPushTime = ( CurTime() - pWash.flWashStartTime )
	flPushTime = math.Clamp( flPushTime, 0, BASECHOPPER_WASH_RAMP_TIME )

	local flWashAmount = math.Remap( flPushTime, 0, BASECHOPPER_WASH_RAMP_TIME, BASECHOPPER_WASH_PUSH_MIN, BASECHOPPER_WASH_PUSH_MAX )

	// Airboat gets special treatment
	if ( pEntity:GetClass() == "prop_vehicle_airboat" ) then
		self:DoWashPushOnAirboat( pEntity, vecToSpot, flWashAmount )
		return true
	end

	pPhysObject = pEntity:GetPhysicsObject()
	if ( !IsValid( pPhysObject ) ) then
		return false
	end

	// Push it away from the center of the wash
	local flMass = pPhysObject:GetMass()

	// This used to be mass independent, which is a bad idea because it blows 200kg engine blocks
	// as much as it blows cardboard and soda cans. Make this force mass-independent, but clamp at
	// 30kg. 
	flMass = math.min( flMass, 30.0 )

	local vecForce = (0.015 / 0.1) * flWashAmount * flMass * vecToSpot * phys_pushscale:GetFloat()

	local damage = DamageInfo()
	damage:SetAttacker( self )
	damage:SetInflictor( self )
	damage:SetDamagePosition( vecWashOrigin )
	damage:SetDamageForce( vecForce )
	damage:SetDamage( flWashAmount )
	damage:SetDamageType( self.RotorWashPushDamageType or DMG_BLAST )

	pEntity:TakePhysicsDamage( damage )

	// Debug
	debugoverlay.Axis( vecSpot, angle_zero, 4, 0.1, true )
	debugoverlay.Line( vecSpot, pEntity:GetPos() + vecForce, 0.1, color_white, true )

	print("Pushed %s (index %d) (mass %f) with force %f (min %.2f max %.2f) at time %.2f\n", 
		pEntity:GetClass(), pEntity:EntIndex(), pPhysObject:GetMass(), flWashAmount, 
		BASECHOPPER_WASH_PUSH_MIN * flMass, BASECHOPPER_WASH_PUSH_MAX * flMass, CurTime() )

	// If we've pushed this thing for some time, remove it to give us a chance to find lighter things nearby
	if ( flPushTime > 2.0 ) then
		return false
	end

	return true
end

function MatrixBuildRotationAboutAxis( vAxisOfRot, angleDegrees )
	local matrix
	local radians = angleDegrees * ( M_PI() / 180.0 )
	local fSin = math.sin( radians )
	local fCos = math.cos( radians )

	local axisXSquared = vAxisOfRot[1] * vAxisOfRot[1]
	local axisYSquared = vAxisOfRot[2] * vAxisOfRot[2]
	local axisZSquared = vAxisOfRot[3] * vAxisOfRot[3]

	local dst = {}
	dst[1][1] = axisXSquared + (1 - axisXSquared) * fCos;
	dst[2][1] = vAxisOfRot[1] * vAxisOfRot[2] * (1 - fCos) + vAxisOfRot[3] * fSin;
	dst[3][1] = vAxisOfRot[3] * vAxisOfRot[1] * (1 - fCos) - vAxisOfRot[2] * fSin;

	dst[1][2] = vAxisOfRot[1] * vAxisOfRot[2] * (1 - fCos) - vAxisOfRot[3] * fSin;
	dst[2][2] = axisYSquared + (1 - axisYSquared) * fCos;
	dst[3][2] = vAxisOfRot[2] * vAxisOfRot[3] * (1 - fCos) + vAxisOfRot[1] * fSin;

	dst[1][3] = vAxisOfRot[3] * vAxisOfRot[1] * (1 - fCos) + vAxisOfRot[2] * fSin;
	dst[2][3] = vAxisOfRot[2] * vAxisOfRot[3] * (1 - fCos) - vAxisOfRot[1] * fSin;
	dst[3][3] = axisZSquared + (1 - axisZSquared) * fCos;

	dst[1][4] = 0;
	dst[2][4] = 0;
	dst[3][4] = 0;

	matrix = Matrix( dst )

	return matrix
end

local function SimpleSpline( value )
	local valueSquared = value * value

	return (3 * valueSquared - 2 * valueSquared * value)
end

function SimpleSplineRemapVal( val, a, b, c, d )
	if a == b then
		return val >= B and d or c
	end

	local cVal = (val - a) / (b - a)
	return c + (d - c) * SimpleSpline( cVal )
end
