local nzombies = engine.ActiveGamemode() == "nzombies"
local pvp_cvar = GetConVar("sbox_playershurtplayers")

local sv_damage_world = GetConVar("sv_tfa_bo3ww_environmental_damage")
local sv_true_damage = GetConVar("sv_tfa_bo3ww_cod_damage")
local sv_door_destruction = GetConVar("sv_tfa_bullet_doordestruction")

local old_radius_damage = GetConVar("old_radiusdamage")
local sv_robust_explosions = GetConVar("sv_robust_explosions")
local phys_pushscale = GetConVar("phys_pushscale")

// DONT TOUCH
ENT.ExplodedEntities = {}

local bit_AND = bit.band

local util_TraceLine = util.TraceLine
local util_TraceHull = util.TraceHull
local util_PointContents = util.PointContents

local string_find = string.find

local DispatchEffect = util.Effect

local MAT_GLASS = MAT_GLASS
local MASK_SHOT = MASK_SHOT
local MASK_RADIUS_DAMAGE = bit.band( MASK_SHOT, bit.bnot( CONTENTS_HITBOX ) )

local CONTENTS_SLIME = CONTENTS_SLIME
local CONTENTS_LIQUID = bit.bor( CONTENTS_WATER, CONTENTS_SLIME )

local COLLISION_GROUP_BREAKABLE_GLASS = COLLISION_GROUP_BREAKABLE_GLASS

local SHATTERSURFACE_TILE = 1

local IsExplosionTraceBlocked
local CalculateExplosiveDamageForce
local ShouldUseRobustRadiusDamage // https://www.youtube.com/watch?v=XNPaXNLyYbk

local BodyTarget = TFA.WonderWeapon.BodyTarget
local RobustableEntity = TFA.WonderWeapon.RobustableEntity
local DoorClasses = TFA.WonderWeapon.DoorClasses

TFA.WonderWeapon.DoorData = TFA.WonderWeapon.DoorData or {}
local DoorData = TFA.WonderWeapon.DoorData

local MASS_ABSORB_ALL_DAMAGE = 350
local ROBUST_RADIUS_PROBE_DIST = 16

local DIRECTION_PROBE_DIST_MIN = 24
local DIRECTION_PROBE_DIST_MAX = 80

local MAX_WATER_SURFACE_DISTANCE = 512

local vector_down = Vector( 0, 0, -1 )

function ENT:Explode(vecSrc, radius, direction, edgeEffectiveness, damageinfo, ignoreentities, ignoreclass)
	if self.HasExploded then return end
	self.HasExploded = true

	self.Damage = self.mydamage or self.Damage

	local phys = self:GetPhysicsObject()

	if not vecSrc or not isvector( vecSrc ) or vecSrc:IsZero() then
		vecSrc = self.HitPos or self:GetPos()
	end

	if not edgeEffectiveness or not isnumber( edgeEffectiveness ) or edgeEffectiveness < 0 then
		edgeEffectiveness = self.ExplosionEdgeEffectiveness or 0.5
	end

	if not radius or not isnumber( radius ) or radius < 0 then
		radius = self.Range
	end

	if not direction or not isvector( direction ) or direction:IsZero() then
		if self.HitNormal and ( self:IsOnGround() or self:GetVelocity():Length() < 1 ) then
			direction = self.HitNormal
		else
			direction = vector_up

			if IsValid( phys ) and phys:GetVelocity():Length() > 1 then
				direction = self:FindExplosionDirection( vecSrc, radius, phys:GetVelocity(), { self, self.Inflictor } )
			else
				direction = self:FindExplosionDirection( vecSrc, radius, self.Direction or self:GetForward(), { self, self.Inflictor } )
			end
		end
	end

	local pOwner = self:GetOwner()

	if damageinfo == nil or not damageinfo:IsValid() then
		local pPlayer = ( IsValid(pOwner) and pOwner or self )
		local pWeapon = ( IsValid(self.Inflictor) and self.Inflictor or self )
		local pInflictor = self.ExplosionUseWeaponAsInflictor and ( pWeapon ) or self

		damageinfo = DamageInfo()
		damageinfo:SetDamage( self.Damage )
		damageinfo:SetDamageType( self.ExplosionDamageType )
		damageinfo:SetAttacker( pPlayer )
		damageinfo:SetInflictor( nzombies and pWeapon or pInflictor )
		damageinfo:SetReportedPosition( vecSrc )
		damageinfo:SetDamageForce( vector_origin )

		if IsValid( self.Inflictor ) then
			damageinfo:SetWeapon( self.Inflictor ) // i hope this doesnt break anything, but its a new feature so i guess well use it
		end
	end

	// ~Justin Case
	if util.IsInWorld( vecSrc + direction ) then
		vecSrc = vecSrc + direction
	end

	local traceFilter = { self, self.Inflictor }
	table.Empty( self.ExplodedEntities )

	local flStartDamage = damageinfo:GetDamage()
	local nStartDamageType = damageinfo:GetDamageType()
	local bInWater = self.IsUnderwater
	local bSubmerged = bit_AND( util_PointContents( vecSrc + ( vector_up * 24 ) ), CONTENTS_LIQUID ) ~= 0

	local flInnerRadius = ( radius * ( self.ExplosionInnerRadiusScale or 0.25 ) )
	local flInnerFalloff = radius - flInnerRadius
	local flSpillRadius = ( radius * ( self.ExplosionEdgeSpillRadiusScale or 0.25 ) )

	debugoverlay.Sphere( vecSrc, radius, 5, Color( 255, 0, 0, 0 ), true )

	debugoverlay.Axis( vecSrc, direction:Angle(), 10, 5, true )

	debugoverlay.Text( vecSrc, "Inner: " .. flInnerRadius .. "hu", 5, false )
	debugoverlay.Text( vecSrc + ( vector_up * 4 ), "Radius: " .. radius .. "hu", 5, false )
	debugoverlay.Text( vecSrc + ( vector_up * 8 ), "Damage: " .. damageinfo:GetDamage(), 5, false )

	if self.ExplosionEmitHint then
		sound.EmitHint( bit.bor( SOUND_COMBAT, SOUND_CONTEXT_EXPLOSION ), vecSrc, self.ExplosionHintVolume or math.max( 128.0, radius * 1.5 ), 0.25, self.Inflictor )
	end

	self:DoExplosionEffect( vecSrc, radius, direction, bSubmerged )

	if self.ExplosionBubbles and bSubmerged then
		self:DoExplosionBubblesEffect( vecSrc, direction, self.ExplosionBubblesMagnitude, self.ExplosionBubblesSize )
	end

	// HACKY
	local oldSolid = self.FindSolidOnly
	self.FindSolidOnly = true

	local nearbyEnts = self:FindNearestEntities( vecSrc, radius, ignoreentities, ( self.ExplosionIgnoreWorld ~= nil and self.ExplosionIgnoreWorld ) or true )

	self.FindSolidOnly = oldSolid

	if tobool( self.ExplosionHitsOwner ) and IsValid( pOwner ) and vecSrc:DistToSqr( pOwner:GetPos() ) < ( self.ExplosionOwnerRange or self.Range )^2 then
		table.insert( nearbyEnts, pOwner )
	end

	for k, pEntity in pairs( nearbyEnts ) do
		if not IsValid( pEntity ) then continue end

		if pEntity:GetClass() == ignoreclass then
			continue
		end

		if pEntity:IsWeapon() then
			continue
		end

		local hitCharacter = ( pEntity:IsNPC() or pEntity:IsPlayer() or pEntity:IsNextBot() )
		local hitDoor = ( DoorClasses[ pEntity:GetClass() ] )

		if !sv_damage_world:GetBool() and !hitCharacter then
			continue
		end

		if self.WaterBlockExplosions then
			if self.IsUnderwater and pEntity:WaterLevel() == 0 then
				// they out we in
				continue
			end

			if !self.IsUnderwater and pEntity:WaterLevel() == 3 then
				// we out they in
				continue
			end
		end

		local flAdjustedDamage
		local flBlockedDamagePercent = 0
		local flDistanceRatio = 0
		local falloff = 0

		local vecSpot = BodyTarget( pEntity, vecSrc, true )
		vecSpot = vecSpot + ( vecSpot - vecSrc ):GetNormalized()

		// level out the z component for damage falloff calculation
		local diff = vecSpot[3] - vecSrc[3]
		local vecStart = Vector(vecSrc[1], vecSrc[2], vecSrc[3] + ( diff * 0.5 ) )
		local flDistance = math.min( ( vecStart - vecSpot ):Length(), ( vecSrc - pEntity:GetPos() ):Length() )

		local flToSpot = ( vecSrc - vecSpot ):Length()
		local flToOrigin = ( vecSrc - pEntity:GetPos() ):Length()
		local flDistanceToEntity = math.min( flToSpot, flToOrigin )

		local trace = util_TraceLine( {
			start = vecSrc,
			endpos = vecSpot,
			filter = traceFilter,
			mask = MASK_RADIUS_DAMAGE,
			collisiongroup = COLLISION_GROUP_NONE,
		} )
 
		debugoverlay.Text( vecSpot, "BodyTarget", 5, false )
		debugoverlay.Text( vecSpot - ( vector_up * 4 ), tostring( trace.Entity ), 5, false )

		debugoverlay.Axis( vecSpot, trace.Normal:Angle(), 10, 5, true )

		debugoverlay.Line( vecSrc, vecSpot, 5, Color( 0, 0, 255, 255 ), true )

		local vecHit = trace.HitPos

		if old_radius_damage:GetBool() then
			if trace.Fraction ~= 1 and trace.Entity ~= pEntity then
				continue
			end
		else
			if trace.Fraction ~= 1 then
				if IsExplosionTraceBlocked( trace, pEntity ) then
					// special case for hitting a dynamic_prop linked to a func_door
					local pBlockingEntity = trace.Entity
					if IsValid( pBlockingEntity ) and IsValid( pBlockingEntity:GetMoveParent() ) and ( sv_door_destruction == nil or sv_door_destruction:GetBool() ) and DoorClasses[ pBlockingEntity:GetMoveParent():GetClass() ] then
						table.insert( traceFilter, pBlockingEntity )

						util_TraceLine( {
							start = trace.StartPos,
							endpos = vecSpot,
							filter = traceFilter,
							mask = MASK_RADIUS_DAMAGE,
							collisiongroup = COLLISION_GROUP_NONE,
							output = trace,
						} )

						vecHit = trace.HitPos

						self:ExplosionHandleDoor( pBlockingEntity:GetMoveParent(), trace, radius, flInnerRadius )
						debugoverlay.Text( vecSpot - ( vector_up * 8 ), tostring( pBlockingEntity:GetMoveParent() ) .. " |Move Parent|", 5, false )
					elseif ShouldUseRobustRadiusDamage( pEntity ) then
						// attempt to blast open rotating doors that block the path to our target entity ( the damage will still potentially be blocked )
						local pBlockingEntity = trace.Entity
						if IsValid( pBlockingEntity ) and ( sv_door_destruction == nil or sv_door_destruction:GetBool() ) and DoorClasses[ pBlockingEntity:GetClass() ] then
							self:ExplosionHandleDoor( pBlockingEntity, trace, radius, flInnerRadius )
						end

						debugoverlay.Sphere( vecSrc, radius / 2, 5, Color( 0, 0, 255, 0 ), true )

						if flDistanceToEntity > flSpillRadius then
							// only use robust within half the explosion radius
							debugoverlay.Text( vecHit, "Out of Range: " .. math.Round(flDistanceToEntity, 2) .. "hu", 5, false )
							continue
						end

						local vecLastPos = trace.HitPos
						local vecLastHit = trace.HitNormal
						local flStartFrac = trace.Fraction

						debugoverlay.Axis( vecLastPos, vecLastHit:Angle(), 5, 5, true )

						// deflect blast along surface
						local vecToTarget = ( vecSrc - vecSpot ):GetNormalized()
						local vecUp = vecToTarget:Cross( trace.HitNormal )
						local vecDeflect = trace.Normal:Cross( vecUp )
						vecDeflect:Normalize()

						// trace along intercepting surface
						util_TraceLine( {
							start = vecLastPos,
							endpos = vecLastPos + ( vecDeflect * ROBUST_RADIUS_PROBE_DIST ),
							filter = traceFilter,
							mask = MASK_RADIUS_DAMAGE,
							collisiongroup = COLLISION_GROUP_NONE,
							output = trace,
						} )

						debugoverlay.Line( vecLastPos, trace.HitPos, 5, Color( 255, 0, 0, 255 ), true )

						debugoverlay.Text( vecLastPos - ( vector_up * 4 ), "Deflection Angle: " .. math.Round(math.deg(math.acos(vecLastHit:Dot(vecDeflect))), 2) .. "°", 5, false )

						vecLastPos = trace.HitPos

						// check for spill over
						util_TraceLine( {
							start = vecLastPos,
							endpos = vecSpot,
							filter = traceFilter,
							mask = MASK_RADIUS_DAMAGE,
							collisiongroup = COLLISION_GROUP_NONE,
							output = trace,
						} )

						local flSpill = ( vecLastPos - ( trace.Entity == pEntity and trace.HitPos or vecSpot ) ):Length()

						local difference = ( flSpill + ROBUST_RADIUS_PROBE_DIST ) - ( flDistance * ( 1 - flStartFrac ) )

						debugoverlay.Line( vecLastPos, trace.HitPos, 5, Color( 255, 0, 0, 255 ), true )
						debugoverlay.Axis( trace.HitPos, trace.HitNormal:Angle(), 10, 5, true )

						if trace.Fraction ~= 1 and trace.HitWorld then
							// crawl failed
							continue
						end

						debugoverlay.Text( vecLastPos, "Spill Length: " .. math.Round(flSpill, 2) .. "hu", 5, false )
						debugoverlay.Text( vecLastPos + ( vector_up * 4 ), "Length Difference: " .. math.Round(difference, 2) .. "hu", 5, false )

						// increase the distance penalty by spillover amount and deflection distance
						flDistance = math.min( flDistanceToEntity, flDistance ) + flSpill + difference

						// increase block factor by the initial trace fraction result and proximity to origin
						local penalty = math.Clamp( flDistanceToEntity / flSpillRadius, 0, 1 )

						flBlockedDamagePercent = 0.15 - ( 0.15 * flStartFrac ) + ( 0.15 * penalty )
						vecHit = vecLastPos
					else
						// non robustable entity
						continue
					end
				end

				if IsValid( trace.Entity ) and trace.Entity ~= pEntity and ( !IsValid( trace.Entity:GetOwner() ) or trace.Entity:GetOwner() ~= pEntity ) and self.ExplosionInterposingReduceDamage then
					if self.ExplosionInterposingBlockDamage then
						debugoverlay.Text( trace.HitPos + ( vector_up * 4 ), "Interposing Entity [" .. tostring( trace.Entity ) .. "] Blocked Trace!", 5, false )
						continue
					end

					local pBlockingEntity = trace.Entity

					// scale damage based on mass of interposing entity
					if IsValid( pBlockingEntity:GetPhysicsObject() ) then
						local flMass = pBlockingEntity:GetPhysicsObject():GetMass()
						local scale = math.Clamp( flMass / self.ExplosionMaxBlockingMass, 0, 1 )

						if scale >= 1 then
							debugoverlay.Text( trace.HitPos, "Too Heavy", 5, false )
							debugoverlay.Text( trace.HitPos + ( vector_up * 4 ), "Mass: " .. flMass .. "kg", 5, false )
							// interposing object is too heavy
							continue
						end

						flBlockedDamagePercent = flBlockedDamagePercent + scale

						debugoverlay.Text( trace.HitPos + ( vector_up * 4 ), "Interposing Mass: " .. flMass .. "kg", 5, false )
					else
						flBlockedDamagePercent = flBlockedDamagePercent + 0.25
					end

					flBlockedDamagePercent = math.min( flBlockedDamagePercent, 1 )
				end
			end
		end

		// out of range !
		if flDistance > radius then
			debugoverlay.Text( pEntity:EyePos() - ( vector_up * 4 ), "Out of Range! " .. math.Round(flDistance, 2), 5, false )
			continue
		end

		// reset starting damage and falloff variables
		local flDamage = damageinfo:GetDamage()
		flDistanceRatio = math.Clamp( ( flDistance - radius + flInnerFalloff ) / flInnerFalloff, 0, 1 ) // linear falloff
		falloff = math.Clamp( 1 - ( radius - flDistance ) / ( radius - flDistance * edgeEffectiveness ), 0, 1 ) // quadratic falloff

		if hitCharacter then
			debugoverlay.Text( pEntity:GetPos() + ( vector_up * 8 ), "Distance Penalty: " .. math.Round(flDistance, 2) .. "hu", 5, false )
			debugoverlay.Text( pEntity:GetPos() + ( vector_up * 4 ), "Real Distance: " .. math.Round(( vecSrc - vecSpot ):Length(), 2) .. "hu", 5, false )
		end

		// damaging owner is a special case
		if pEntity == self:GetOwner() and self.ExplosionHitsOwner then
			if self.ExplosionOwnerRange then
				if vecSpot:DistToSqr( vecSrc ) > self.ExplosionOwnerRange^2 then
					continue
				end

				falloff = math.Clamp( flDistance / self.ExplosionOwnerRange, 0, 1 )
			end

			flDamage = math.min( self.Damage, tonumber( self.ExplosionOwnerDamage ) )
		end

		if self.ExplosionDamageFalloff then
			// special case for doors, take less damage if they are open away from us
			// ( idea taken from the codebase of 'sandstorm station 13' server )

			if hitDoor and pEntity.GetPhysicsObject then
				local pPhys = pEntity:GetPhysicsObject()
				if IsValid( pPhys ) then
					local vecDir2D = ( Vector(vecSpot.x, vecSpot.y, 0) - Vector(vecSrc.x, vecSrc.y, 0) ):GetNormalized()
					local vecDoorDir = ( trace.Entity == pEntity and trace.HitNormal or pPhys:GetAngles():Forward() )
					local difference = math.abs(  vecDoorDir:Dot( vecDir2D ) )

					// dot product falloff becomes less effective the closer we are to initial blast origin
					local penalty = math.Remap( flDistanceRatio, 0, 1, 0.5, 1 )

					falloff = math.Clamp( falloff + ( ( 1 - difference ) * penalty ), 0, 1 )

					local printpos = pPhys:LocalToWorld( pPhys:GetMassCenter() )
					debugoverlay.Axis( printpos, vecDoorDir:Angle(), 5, 5, true )

					debugoverlay.Text( printpos, "Door Facing Difference: " .. math.Round(math.deg(math.acos(difference)), 2) .. "°", 5, false )
					debugoverlay.Text( printpos + ( vector_up * 4 ), "Additional Falloff: " .. math.Round(( 1 - difference ) * penalty, 2), 5, false )
				end

				if trace.Hit and (sv_door_destruction == nil or sv_door_destruction:GetBool()) then
					self:ExplosionHandleDoor( pEntity, trace, radius, flInnerRadius )
				end
			end

			flAdjustedDamage = ( flDistanceToEntity <= flInnerRadius ) and 0 or ( flDamage * falloff ) / 2

			if hitCharacter then
				local flFalloffRatio = ( 1 - math.Clamp( ( flDamage - flAdjustedDamage ) / flStartDamage, 0, 1 ) )
				debugoverlay.Text( pEntity:GetPos() + ( vector_up * 16 ), "Damage Falloff: " .. math.Round(flAdjustedDamage, 2) .. " ( " .. math.Round( 100 * flFalloffRatio, 2) .. "% )", 5, false )
				debugoverlay.Text( pEntity:GetPos() + ( vector_up * 12 ), "Falloff Factor: " .. math.Round(falloff, 2), 5, false )
			end

			flAdjustedDamage = flDamage - flAdjustedDamage
		else
			flAdjustedDamage = flDamage
		end

		if flAdjustedDamage <= 0 then
			continue
		end

		if hitCharacter and flBlockedDamagePercent > 0 then
			debugoverlay.Text( vecHit + ( vector_up * 8 ), "Blocked Damage: " .. math.Round(( flAdjustedDamage * flBlockedDamagePercent ), 2) .. " ( " .. math.Round( 100 * flBlockedDamagePercent, 2) .. "% )", 5, false )
		end

		if trace.StartSolid then
			trace.HitPos = vecSrc
			trace.Fraction = 0
		end

		debugoverlay.Text( trace.HitPos, "HitPos", 5, false )
		debugoverlay.Axis( trace.HitPos, trace.HitNormal:Angle(), 10, 5, true )

		local data = {
			entity = pEntity,
			trace = table.Copy( trace ),
			origin = vecSrc,
			position = vecSpot,
			damage = flAdjustedDamage,
			blocked = flBlockedDamagePercent,
			falloff = falloff,
			distance = flDistance,
		}

		table.insert( self.ExplodedEntities, data )

		// ignore character entity in future traces ( ents table is sorted by nearest to furthest )
		if pEntity:IsNPC() or pEntity:IsPlayer() or pEntity:IsNextBot() then
			table.insert( traceFilter, pEntity )
		end
	end

	if !self.ExplosionSortedEntities then
		table.Shuffle( self.ExplodedEntities )
	end

	for index, data in pairs( self.ExplodedEntities ) do
		local pEntity = data.entity

		if not IsValid( pEntity ) then
			continue
		end

		local trace = data.trace

		local falloff = data.falloff
		local flAdjustedDamage = data.damage
		local flBlockedDamagePercent = data.blocked

		local vecSrc = data.origin
		local vecSpot = data.position
		local vecDir = ( vecSpot - vecSrc ):GetNormalized()
		local flDistance = data.distnace

		local ExplosionTable = {
			["Entity"] = pEntity,
			["ExplosionTrace"] = trace,
			["ExplosionOrigin"] = vecSrc,
			["DamagePosition"] = vecSpot,
			["DamageAmount"] = flAdjustedDamage,
			["BlockedPercent"] = flBlockedDamagePercent,
			["FalloffPercent"] = falloff,
			["Distance"] = flDistance,
		}

		debugoverlay.Text( pEntity:EyePos(), index, 5, false )

		local hitCharacter = ( pEntity:IsNPC() or pEntity:IsPlayer() or pEntity:IsNextBot() )

		if bit_AND( damageinfo:GetDamageType(), DMG_PREVENT_PHYSICS_FORCE ) == 0 then
			damageinfo:SetDamageForce( CalculateExplosiveDamageForce( damageinfo:GetDamage(), vecDir, pEntity ) )
		end

		if pEntity:GetCollisionGroup() == COLLISION_GROUP_BREAKABLE_GLASS and self.ShouldDestroyWindows and ( pEntity:GetInternalVariable("surfacetype") or 0 ) == SHATTERSURFACE_TILE then
			// sonic & blast damage cause tile windows to blowout in a circular pattern
			damageinfo:SetDamageType( DMG_SONIC )
		end

		damageinfo:SetDamagePosition( trace.Entity == pEntity and trace.HitPos or vecSpot )
		damageinfo:SetDamageForce( damageinfo:GetDamageForce() * ( 1 - falloff ) )
		damageinfo:SetDamage( flAdjustedDamage - ( flAdjustedDamage * flBlockedDamagePercent ) )

		if ( nzombies or ( sv_true_damage and sv_true_damage:GetBool() ) ) and self.InfiniteDamage then
			damageinfo:SetDamage( pEntity:Health() + 666 )
		end

		local bBlockDamage = self:PreExplosionDamage( pEntity, trace, damageinfo, index, ExplosionTable )
		if bBlockDamage ~= nil and bBlockDamage == true then
			debugoverlay.Text( pEntity:GetPos() + ( vector_up * 16 ), "DAMAGE BLOCKED BY FUNC", 4, false )
			continue
		end

		//if hitCharacter then
			debugoverlay.Text( pEntity:GetPos() + ( vector_up * 20 ), "Final Damage: " .. math.Round(damageinfo:GetDamage(), 2), 5, false )
		//end

		// hack to fix NPCs not dying when taking fatal damage and frozen
		if pEntity:IsNPC() and pEntity:Alive() and damageinfo:GetDamage() >= pEntity:Health() then
			pEntity:SetCondition( COND.NPC_UNFREEZE )
		end

		local vecHitSpot = ( trace.Entity == pEntity ) and trace.HitPos or vecSpot
		local bHitInWater = bit_AND( util_PointContents( vecHitSpot ), CONTENTS_LIQUID ) ~= 0

		// if victim is outside of water while were inside water (or vice versa) do water splash at surface level along path to target
		if self.ExplosionTraceWaterSplash then
			if ( ( bHitInWater and !bSubmerged ) or ( bSubmerged and !bHitInWater ) ) then
				local trace2 = {}

				util_TraceLine({
					start = vecSrc,
					endpos = vecHitSpot,
					mask = CONTENTS_LIQUID,
					output = trace2,
				})

				local fx = EffectData()
				fx:SetOrigin( trace2.HitPos )
				fx:SetNormal( trace2.HitNormal )
				fx:SetScale( math.random( 2, 8 ) )
				fx:SetFlags( bit_AND( trace2.Contents, CONTENTS_SLIME ) != 0 && 1 || 0 )

				DispatchEffect( "watersplash", fx, false, true )

				debugoverlay.Axis( trace2.HitPos, trace2.HitNormal:Angle(), 5, 5, true )

				if bSubmerged then
					local flBubbleRatio = math.Clamp( ( flDistance * trace2.Fraction ) / radius, 0, 1 )

					effects.BubbleTrail( vecSrc, trace2.HitPos, ( 24 * flBubbleRatio ) * ( radius / 100 ), 16, 8, 0 )
				else
					local flBubbleRatio = math.Clamp( ( flDistance * ( 1 - trace2.Fraction ) ) / radius, 0, 1 )

					effects.BubbleTrail( trace2.HitPos, vecHitSpot, ( 24 * flBubbleRatio ) * ( radius / 100 ), 16, 8, 0 )
				end
			elseif bHitInWater and bSubmerged then
				effects.BubbleTrail( trace2.HitPos, vecHitSpot, 24 * ( radius / 100 ), 16, 8, 0 )
			end
		end

		if trace.Entity == pEntity then
			// stop damage scaling by forcing HitGroup to use melee hitgroup unless a headshot (sorry ragdoll mods)
			trace.HitGroup = trace.HitGroup == HITGROUP_HEAD and HITGROUP_HEAD or HITGROUP_GENERIC

			if trace.HitGroup == HITGROUP_HEAD then
				damageinfo:ScaleDamage( self.ExplosionHeadShotScale )
			end

			if !self.ExplosionEffect and self.ExplosionTracers and ( math.random(2) == 1 ) then
				local fx = EffectData()
				fx:SetEntity( self )
				fx:SetOrigin( trace.HitPos + trace.Normal*256 )
				fx:SetStart( trace.StartPos )
				//fx:SetScale( math.Rand( 0.2, 0.5 ) )
				//fx:SetFlags( 1 )

				DispatchEffect( "Tracer", fx, false, true )
			end

			self:DoImpactEffect( trace, true )

			pEntity:DispatchTraceAttack( damageinfo, trace, vecDir )
		else
			pEntity:TakeDamageInfo( damageinfo )
		end

		if self.ExplosionTracerSound and !pEntity:IsPlayer() then
			/*net.Start("TFA.BO3WW.FOX.Explode.TracerSound")
				net.WriteVector( vecSpot )
				net.WriteVector( vecSrc )
				net.WriteUInt( ( bHitInWater and bSubmerged ) and 8 or 1 , 4)
				net.WriteString( isstring( self.ExplosionTracerSound ) and self.ExplosionTracerSound or "" )
			net.SendPVS( vecSrc )*/

			/*local fx = EffectData()
			fx:SetOrigin( vecSpot ) // endpos
			fx:SetStart( vecSrc )
			fx:SetFlags( ( bHitInWater and bSubmerged ) and 8 or 1 )

			DispatchEffect( "TracerSound", fx, false, true )*/
		end

		damageinfo:SetDamage( flStartDamage )
		damageinfo:SetDamageType( nStartDamageType )

		self:PostExplosionDamage( pEntity, trace, damageinfo, index, ExplosionTable )

		self:SendHitMarker( pEntity, damageinfo, trace )

		self:TraceAttackToTriggers( damageinfo, vecSrc, vecSpot, vecDir )
	end
end

function ENT:TraceAttackToTriggers( damageinfo, vecStart, vecEnd, dir )
	local triggerEnts = {}

	for _, pEntity in ipairs( ents.FindAlongRay( vecStart, vecEnd ) ) do
		if not pEntity.GetBrushSurfaces then continue end
		if pEntity:GetClass() == self:GetClass() then continue end

		local surf = pEntity:GetBrushSurfaces()
		if surf == nil then
			continue
		end

		triggerEnts[ #triggerEnts + 1 ] = pEntity
	end

	table.sort( triggerEnts, function(a, b) return a:GetPos():DistToSqr( vecStart ) < b:GetPos():DistToSqr( vecStart ) end )

	for _, pEnt in ipairs( triggerEnts ) do
		local tr = util_TraceLine({
			start = vecStart,
			endpos = vecEnd,
			mask = MASK_SHOT,
		})

		if tr.Fraction < 1 and tr.Entity == pEnt then
			pEnt:DispatchTraceAttack( damageinfo, tr, dir )
		end
	end
end

local downtiles = {
	[1] = Vector( 1, 1, -1 ), // forwards right down
	[2] = Vector( 1, -1, -1 ), // forwards left down
	[3] = Vector( -1, 1, -1 ), // back right down
	[4] = Vector( -1, -1, -1 ), // back left down
	[5] = vector_down, // down...
	[6] = vector_up, // up...
}

function ENT:FindExplosionDirection( position, radius, velocity, filter )
	local trace = {}
	local vecSpots = {}

	local flSpeed = velocity:Length()

	local vecBlastDir = velocity:GetNormalized()
	local vecDir = velocity:GetNormalized()
	local qAngleVel = velocity:Angle()

	local vecUp = qAngleVel:Up()
	local vecRight = qAngleVel:Right()

	local tiles = {
		// trace the four corners in the direction were traveling using our local orientation
		[1] = ( vecDir + vecUp + vecRight ), // forwards up right
		[2] = ( vecDir + vecUp - vecRight ), // forwards up left
		[3] = ( vecDir - vecUp + vecRight ), // forwards down right
		[4] = ( vecDir - vecUp - vecRight ), // forwards down left
		[5] = vecDir, // our forward
		[6] = -vecDir, // our backwards
	}

	if flSpeed <= 1 then
		// if were stationary, or close to it, trace the four corners directly beneath us using axis aligned orientation
		tiles = downtiles
	end

	// trace in the direction were traveling
	util_TraceLine({
		start = position,
		endpos = position + tiles[5] * math.min( radius, DIRECTION_PROBE_DIST_MAX ),
		filter = filter,
		mask = MASK_SOLID_BRUSHONLY,
		collisiongroup = COLLISION_GROUP_NONE,
		output = trace,
	})

	debugoverlay.Axis( trace.HitPos, ( trace.Hit and trace.HitNormal or trace.Normal ):Angle(), 5, 5, true )
	debugoverlay.Line( position, trace.HitPos, 5, Color( 0, 255, 0, 255 ), true )

	// see if were already close to geometry
	local flDistance = ( position - trace.HitPos ):Length()

	for index, tile in ipairs( tiles ) do
		util_TraceLine({
			start = position,
			endpos = position + tile * math.max( flDistance, DIRECTION_PROBE_DIST_MIN ),
			filter = filter,
			mask = MASK_SOLID_BRUSHONLY,
			collisiongroup = COLLISION_GROUP_NONE,
			output = trace
		})

		//if index != 5 then
			debugoverlay.Axis( trace.HitPos, ( trace.Hit and trace.HitNormal or trace.Normal ):Angle(), 5, 5, true )
			debugoverlay.Line( position, trace.HitPos, 5, Color( 0, 255, 0, 255 ), true )
		//end

		if trace.Hit then
			table.insert( vecSpots, { [ 'direction' ] = trace.Normal, [ 'position' ] = trace.HitPos, [ 'normal' ] = trace.HitNormal, [ 'fraction' ] = trace.Fraction } )
		end
	end

	local flBestDot = -1
	local flBestFrac = 1
	local vecHit = Vector()
	vecHit:Add( position )

	// find the best spot by comparing dot products
	for _, data in pairs( vecSpots ) do
		local dir = data.direction
		local testdir = vecDir

		// probably stationary, test against whats below us
		if flSpeed <= 1 then
			testdir = vector_down
		end

		// test against direction of travel
		local flDot = testdir:Dot( dir )
		local flFrac = data.fraction

		if flFrac < flBestFrac then
			flBestFrac = flFrac
		end

		// make sure the failsafe doesnt override the other directions
		if flDot > flBestDot and ( flDot ~= 1 or flFrac == flBestFrac ) then
			flBestDot = flDot

			vecBlastDir:Set( data.normal )
			vecHit:Set( data.position )

			debugoverlay.Axis( data.position, ( data.direction ):Angle(), 5, 5, true )
			debugoverlay.Line( position, vecHit, 5, Color( 255, 0, 255, 255 ), true )
		end
	end

	debugoverlay.Text( position - vector_up*3, "Direction: [ " .. math.Round(vecBlastDir[1], 2) .. ", " .. math.Round(vecBlastDir[2], 2) .. ", " .. math.Round(vecBlastDir[3], 2) .. " ]", 5, false )

	return vecBlastDir
end

function ENT:DoExplosionEffect( position, radius, direction, underwater )
	if self.BlockExplosionEffect then return end

	if not position or not isvector(position) or position:IsZero() then
		position = self.HitPos or self:GetPos()
	end
	if not direction or not isvector(direction) or direction:IsZero() then
		direction = self.HitNormal or self:GetUp()
	end
	if not radius or not isnumber(radius) or radius < 0 then
		radius = self.Range
	end

	if underwater and self.WaterSurfaceExplosion then
		self:DoWaterSurfaceExplosion( position, radius, direction )
	end

	if self.ExplosionShakeRopes then
		local shakeforce = ( math.pow( self.Damage / 60, 0.2 ) * self.Range )

		local fx = EffectData()
		fx:SetOrigin( position )
		fx:SetRadius( radius )
		fx:SetMagnitude( shakeforce )

		DispatchEffect( "ShakeRopes", fx )
	end

	if self.ExplosionEffect then
		if self.ShouldLodgeProjectile and self.HitNormal then
			direction = self.HitNormal
		end

		ParticleEffect(self.ExplosionEffect, position, direction:Angle() - ( self.ExplosionEffectAngleCorrection or angle_zero ))
	else
		local effectdata = EffectData()
		effectdata:SetOrigin( position )
		effectdata:SetNormal( direction )

		util.Effect("HelicopterMegaBomb", effectdata)
		if not underwater then
			util.Effect("Explosion", effectdata)
		end
	end

	if self.ExplosionSound then
		sound.Play(self.ExplosionSound, position)
	end
	if self.ExplosionSound1 then
		sound.Play(self.ExplosionSound1, position)
	end
	if self.ExplosionSound2 then
		sound.Play(self.ExplosionSound2, position)
	end
	if self.ExplosionSound3 then
		sound.Play(self.ExplosionSound3, position)
	end
	if self.ExplosionSound4 then
		sound.Play(self.ExplosionSound4, position)
	end
end

function ENT:DoExplosionBubblesEffect( position, direction, magnitude, radius )
	if self.BlockExplosionBubbles then return end

	if magnitude == nil or not isnumber(magnitude) or magnitude < 0 then
		magnitude = math.Clamp( ( math.pow( self.Damage / 100, 0.5 ) * ( self.Range / 100 ) ), 1, 12 )
	end
	if radius == nil or not isnumber(radius) or radius < 0 then
		radius = math.Clamp( ( math.pow( self.Damage / 10, 0.2 ) * ( self.Range / 2 ) ) / 1.25, 32, 512 )
	end

	local data = EffectData()
	data:SetOrigin( position or self.HitPos or self:GetPos() )
	data:SetNormal( direction or self.HitNormal or self:GetUp() )
	data:SetMagnitude( magnitude )
	data:SetRadius( radius )

	//debugoverlay.Line(position, position + direction*32, 10, Color(255,0,0,255), true)

	DispatchEffect( "tfa_bo3_bubble_explosion", data )
end

function ENT:DoWaterSurfaceExplosion( position, radius, direction, damage )
	if self.BlockWaterSurfaceExplosion then return end

	// Fake surface explosion because we already have an explosion effect
	if self.ExplosionEffect then
		local vecWaterSurface
		local flDepth = math.max( radius * 2, MAX_WATER_SURFACE_DISTANCE )

		// Find our water surface by tracing up till we're out of the water
		local trace = {}
		local vecTrace = Vector( 0, 0, flDepth )

		util_TraceLine({
			start = position,
			endpos = position + vecTrace,
			mask = CONTENTS_LIQUID,
			collisiongroup = COLLISION_GROUP_NONE,
			output = trace,
		})

		// If we didn't start in water, we're above it
		if not trace.StartSolid then
			// Look downward to find the surface
			vecTrace:SetUnpacked( 0, 0, -flDepth )
			util_TraceLine({
				start = position,
				endpos = position + vecTrace,
				mask = CONTENTS_LIQUID,
				collisiongroup = COLLISION_GROUP_NONE,
				output = trace,
			})

			// If we hit it, setup the explosion
			if tr.Fraction < 1 then
				vecWaterSurface = tr.EndPos
				flDepth = 0
			else
				vecWaterSurface = position
				flDepth = 0
			end
		elseif trace.FractionLeftSolid > 0 then
			// Otherwise we came out of the water at this point
			vecWaterSurface = position + (vecTrace * trace.FractionLeftSolid)
			flDepth = flDepth * tr.FractionLeftSolid
		else
			// Use default values, we're really deep
			vecWaterSurface = position
			flDepth = MAX_WATER_SURFACE_DISTANCE
		end

		local data = EffectData()
		data:SetOrigin( vecWaterSurface )
		data:SetNormal( trace.HitNormal )
		data:SetScale( math.Clamp( radius / 4, 8, 128 ) )
		data:SetFlags( bit_AND( trace.Contents, CONTENTS_SLIME ) != 0 && 1 || 0 ) // FX_WATER_IN_SLIME = 1

		DispatchEffect( "gunshotsplash", data, false, true )

		// Must be in deep enough water
		if flDepth >= 128 then
			data:SetScale( radius )

			DispatchEffect( "waterripple", data, false, true )
		end
	else
		local data = EffectData()
		data:SetOrigin( position )
		data:SetMagnitude( math.Clamp( damage, 25, 150 ) )
		data:SetScale( radius )
		data:SetFlags( bit.bor( 8, 32, 1024 ) ) // SF_ENVEXPLOSION_NOSMOKE, SF_ENVEXPLOSION_NOSPARKS, SF_ENVEXPLOSION_NODLIGHTS

		DispatchEffect( "WaterSurfaceExplosion", data, false, true )
	end
end

// DoorState_t Enums
local DOOR_STATE_CLOSED = 0
local DOOR_STATE_OPENING = 1
local DOOR_STATE_OPEN = 2
local DOOR_STATE_CLOSING = 3
local DOOR_STATE_AJAR = 4

// TOGGLE_STATE Enums
local TS_AT_TOP = 0
local TS_AT_BOTTOM = 1
local TS_GOING_UP = 2
local TS_GOING_DOWN = 3

// Door SpawnFlags
local SF_DOOR_ROTATE_BACKWARDS = 2
local SF_DOOR_PASSABLE = 8
local SF_DOOR_ONEWAY = 16
local SF_DOOR_PUSE = 256
local SF_DOOR_PTOUCH = 1024
local SF_DOOR_SILENT = 4096
local SF_DOOR_IGNORE_USE = 32768

// PropDoorRotatingOpenDirection_e Enums
local DOOR_ROTATING_OPEN_BOTH_WAYS  = 0
local DOOR_ROTATING_OPEN_FORWARD = 1
local DOOR_ROTATING_OPEN_BACKWARD = 2

function ENT:ExplosionHandleDoor( entity, trace, radius, inner )
	if not trace or not istable( trace ) then
		return
	end

	if not IsValid( entity ) or not entity.GetPhysicsObject or not IsValid( entity:GetPhysicsObject() ) then
		return
	end

	if entity.MFKickedDown then
		return
	end

	// only rotating doors can be blasted open, normal doors will just take damage
	// if you have some sort of door destruction addon that will handle the rest

	local class = entity:GetClass()
	if !string_find( class, "_door_rotating" ) then
		return
	end

	local bFuncDoor = string_find( class, "func" )
	local bPropDoor = string_find( class, "prop" )

	// ignore doors that are disabled / unusable
	if ( bPropDoor and entity:HasSpawnFlags( SF_DOOR_IGNORE_USE + SF_DOOR_PASSABLE ) ) or ( bFuncDoor and ( entity:HasSpawnFlags(SF_DOOR_PASSABLE) or !entity:HasSpawnFlags( SF_DOOR_PUSE + SF_DOOR_PTOUCH ) ) ) then
		return
	end

	local flSpeed = entity:GetInternalVariable( "m_flSpeed" ) or 100 // door movespeed
	local flDistance = bFuncDoor and ( entity:GetInternalVariable( "m_flMoveDistance" ) or 90 ) or ( entity:GetInternalVariable( "m_flDistance" ) or 90 ) // how many degrees the door opens by
	local nToggleState = entity:GetInternalVariable( "m_toggle_state" ) or 0 // open or close
	local nDoorState = entity:GetInternalVariable( "m_eDoorState" ) or 0 // open or close (or other)
	local flDamage = entity:GetInternalVariable( "dmg" ) // damage done to entities blocking the doors path
	local nFlags = entity:GetSpawnFlags() // backup spawnflags

	// ignore doors that are already open
	if bFuncDoor and nToggleState == TS_AT_TOP then
		return
	end
	if bPropDoor and nDoorState == DOOR_STATE_OPEN then
		return
	end

	local pPhys = entity:GetPhysicsObject()
	local vecSrc = trace.StartPos
	local vecDoorSpot = pPhys:LocalToWorld( pPhys:GetMassCenter() )
	local vecDoorStart = entity:GetPos()
	local vecDoorDir = pPhys:GetAngles():Forward()

	local vecMins, vecMaxs = pPhys:GetAABB()
	local flWidth = ( vecMins - vecMaxs ):Length2D()

	local flToSpot = ( vecSrc - trace.HitPos ):Length()
	local flToOrigin = ( vecSrc - vecDoorSpot ):Length()
	local flDistanceToEntity = math.min( flToSpot, flToOrigin )

	local flSpillRadius = ( radius * ( self.ExplosionEdgeSpillRadiusScale or 0.25 ) )
	local flDoorEdge = 0.6

	local flDoorFalloff = ( radius - inner ) / 2
	local falloff = math.Clamp( 1 - ( flDoorFalloff - flDistance ) / ( flDoorFalloff - flDistance * flDoorEdge ), 0, 1 )
	if falloff <= 0 then
		return
	end

	local bIsHatch = false

	// find the position of where the door would be when open
	if bFuncDoor then
		if entity:HasSpawnFlags( SF_DOOR_ONEWAY + SF_DOOR_ROTATE_BACKWARDS ) then
			local vecMoveAng = entity:GetInternalVariable( "m_vecMoveDir" ):Angle()
			vecDoorDir = vecMoveAng:Up()

			bIsHatch = true
		else
			vecDoorDir = trace.HitNormal:GetNegated()
		end

		vecDoorStart = entity:GetInternalVariable("m_vecPosition1") // hinge pos
		vecDoorSpot = ( vecDoorStart + vecDoorDir * flWidth )

		flDistance = ( vecDoorStart - vecDoorSpot ):Length()
		flDistanceToEntity = math.min( flDistanceToEntity, ( vecSrc - vecDoorStart ):Length() )

		debugoverlay.Axis( vecDoorStart, entity:GetAngles(), 5, 5, true )
		debugoverlay.Text( vecDoorStart, "Door Start", 5, false )
	elseif bPropDoor then
		vecDoorDir = trace.HitNormal:GetNegated()
		vecDoorSpot:SetUnpacked( vecDoorStart.x, vecDoorStart.y, vecDoorSpot.z ) // hinge pos

		local vecMoveAng = entity:GetInternalVariable("m_angRotationOpenForward")
		local vecMoveDir = ( Angle( vecMoveAng.x, vecMoveAng.y, vecMoveAng.z ):Forward() ):GetNegated() // i wanna say no no words

		vecDoorStart = vecDoorSpot + vecMoveDir * flWidth
		vecDoorSpot = vecDoorSpot + vecDoorDir * flWidth

		flDistance = ( vecDoorStart - vecDoorSpot ):Length()
		flDistanceToEntity = math.min( flDistanceToEntity, ( vecSrc - vecDoorStart ):Length() )

		debugoverlay.Axis( vecDoorStart, ( vecDoorSpot - vecDoorStart ):Angle(), 5, 5, true )
		debugoverlay.Text( vecDoorStart, "Door Start", 5, false )
	end

	if bIsHatch then
		debugoverlay.Text( vecDoorSpot - ( vector_up * 4 ), "SF_DOOR_ONEWAY + SF_DOOR_ROTATE_BACKWARDS", 5, false )
	end

	debugoverlay.Axis( vecDoorSpot, vecDoorDir:Angle(), 5, 5, true )

	// test if the open position of the door is inside the world
	if util.IsInWorld( vecDoorSpot ) then
		debugoverlay.Text( vecDoorSpot, "Door Stop: " .. flDistance .. "hu", 5, false )

		// make sure the open position of the door is opposite us
		if trace.Normal:Dot( ( trace.HitPos - vecDoorSpot ):GetNormalized() ) > 0 then
			return
		end

		// if the door is close enough and locked, unlock it
		if flDistanceToEntity <= inner and entity:GetInternalVariable( "m_bLocked" ) then
			entity:SetSaveValue( "m_bLocked", false )
		end
	else
		debugoverlay.Text( vecDoorSpot, "Door Stop: Out of Bounds", 5, false )
		return
	end

	// if a door is still locked at this point, ignore it
	if entity:GetInternalVariable( "m_bLocked" ) then
		return
	end

	local nOpenDir = entity:GetInternalVariable( "opendir" ) or DOOR_ROTATING_OPEN_BOTH_WAYS

	sound.Play( "ambient/materials/door_hit1.wav", ( trace.Entity and trace.Entity == entity ) and trace.HitPos or entity:WorldSpaceCenter(), SNDLVL_TALKING, math.random( 90, 110 ), 1 )

	local strName = "TFABash" .. self:EntIndex()
	self.PreBashName = self:GetName()
	self:SetName( strName )

	entity:Fire( "SetSpeed", tostring( flSpeed * 5 * math.max( falloff, 0.4 ) ), 0, self, self )

	if tobool( entity:GetInternalVariable( "m_isChaining" ) ) then
		entity:Input( "close", self, self )
	else
		entity:Fire( "close", nil, 0, self, self )
	end

	entity:SetKeyValue( "dmg", ( flSpeed * falloff ) )
	entity:SetKeyValue( "spawnflags", nFlags + SF_DOOR_SILENT )

	// opening door
	if bFuncDoor then
		// source-sdk-2013/src/game/server/doors.cpp#L994
		local hOldActivator = entity:GetInternalVariable( "m_hActivator" )

		local flWait = entity:GetInternalVariable( "m_flWait" )
		if flWait ~= nil and isnumber( flWait ) and flWait > 0 then
			local index = self:GetUniqueID( entity )
			DoorData[ index ] = {}
			DoorData[ index ][ "m_flWait" ] = { ["old"] = flWait, ["new"] = -1 }
		end

		entity:SetSaveValue( "m_flWait", -1 ) // force our way open ( setting the 'forceclosed' keyvalue achieves the same affect )

		entity:SetSaveValue( "m_isChaining", true ) // stop partner doors from opening, the explosion will handle this
		entity:SetSaveValue( "m_hActivator", self ) // open away from us

		entity:Fire( "open", strName, 0, self, self )

		entity:SetKeyValue( "forceclosed", true )
		entity:SetSaveValue( "m_isChaining", false )
		entity:SetSaveValue( "m_hActivator", hOldActivator )
	else
		local flBlastDir = ( trace.Hit and trace.HitNormal:GetNegated() or Vector( trace.Normal[ 1 ], trace.Normal[ 2 ], 0 ) )
		if flBlastDir:Dot( entity:GetForward() ) <= 0 then
			entity:SetKeyValue( "opendir", DOOR_ROTATING_OPEN_BACKWARD )
		else
			entity:SetKeyValue( "opendir", DOOR_ROTATING_OPEN_FORWARD )
		end

		local flWait = entity:GetInternalVariable( "returndelay" )
		if flWait ~= nil and isnumber( flWait ) and flWait > 0 then
			local index = self:GetUniqueID( entity )
			DoorData[ index ] = {}
			DoorData[ index ][ "returndelay" ] = { ["old"] = flWait, ["new"] = -1 }
		end

		entity:SetSaveValue( "returndelay", -1 )

		// stop partner doors from opening, the explosion will handle this
		local strOldName = entity:GetInternalVariable( "m_iName" )
		entity:SetSaveValue( "m_iName", nil )

		entity:Fire( "openawayfrom", strName, 0, self, self )

		entity:SetSaveValue( "m_iName", strOldName )
	end

	// mightyfootengaged
	entity.MFKickedDown = true

	// find our partner
	/*local hDoorMaster = entity:GetInternalVariable( "m_hMaster" )
	if IsValid( hDoorMaster ) then
		if !self.DoubleDoorMasterToSlave then
			print( "DOOR MASTER IS " .. tostring( hDoorMaster ) )
			self.DoubleDoorSlaveToMaster = true
			self:ExplosionHandleDoor( hDoorMaster, trace, radius, inner )
			self.DoubleDoorSlaveToMaster = nil
		end
	elseif !self.DoubleDoorSlaveToMaster then
		local iszSearchName = entity:GetName()
		local pSlaveName = entity:GetInternalVariable( "m_SlaveName" ) or entity:GetInternalVariable( "m_ChainTarget" )
		if pSlaveName and #pSlaveName > 0 then
			iszSearchName = pSlaveName
		end

		self.DoubleDoorMasterToSlave = true
		for _, pTarget in pairs( ents.FindByName( iszSearchName ) ) do
			if IsValid( pTarget ) and pTarget ~= entity then
				local pDoor = pTarget:GetInternalVariable( "m_hMaster" )
				if IsValid( pDoor ) and pDoor:GetInternalVariable( "m_hMaster" ) == entity then
					print( "DOOR SLAVE IS " .. tostring( pTarget ) )
					self:ExplosionHandleDoor( pTarget, trace, radius, inner )
				end
			end
		end
		self.DoubleDoorMasterToSlave = nil
	end*/

	// cleanup
	local hPlayer = self:GetOwner()
	timer.Simple( ( flDistance / flSpeed ) + engine.TickInterval(), function()
		if !IsValid( entity ) then
			return
		end

		entity:SetKeyValue( "spawnflags", nFlags )
		entity:SetKeyValue( "opendir", nOpenDir )
		entity:SetKeyValue( "dmg", flDamage or 0 )

		entity:Fire( "SetSpeed", flSpeed, 0, hPlayer, hPlayer )

		if timer.Exists( "MFDoorTimer" .. entity:EntIndex() ) then
			return
		end

		entity.MFKickedDown = false
	end )

	self:SetName( self.PreBashName )
end

local t_WatchedInputs = {
	["Open"] = true,
	["Close"] = true
}

hook.Add( "AcceptInput", "TFA.BO3WW.FOX.DoorBust.Input", function( entity, event, activator, caller, value )
	if DoorClasses[ entity:GetClass() ] and t_WatchedInputs[ event ] then
		local index = entity:CreatedByMap() and entity:MapCreationID() or entity:EntIndex()
		if DoorData[ index ] then
			for name, data in pairs( DoorData[ index ] ) do
				if entity:GetInternalVariable( name ) == data.new then
					entity:SetSaveValue( name, data.old )
				end
			end

			DoorData[ index ] = nil
		end
	end
end )

// helper functions from sdk-2013

function IsExplosionTraceBlocked( trace, entity )
	if trace.HitWorld then
		return true
	end

	local target = trace.Entity
	if not IsValid( target ) then
		return false
	end

	if target:GetMoveType() == MOVETYPE_PUSH and DoorClasses[ IsValid( target:GetMoveParent() ) and target:GetMoveParent():GetClass() or target:GetClass() ] and target ~= entity then
		// not all push are doors, but all doors are push
		return true
	end

	if trace.Entity:IsVehicle() and not entity:InVehicle() then
		// vehicles larger than max mass
		local bodyPhys = trace.Entity:GetPhysicsObject()
		if IsValid( bodyPhys ) and bodyPhys:GetMass() >= self.ExplosionMaxBlockingMass then
			return true
		end
	end

	return false
end

function ShouldUseRobustRadiusDamage( entity )
	if not sv_robust_explosions:GetBool() then
		return false
	end

	if !( RobustableEntity[ entity:GetClass() ] or entity:IsNPC() or entity:IsNextBot() or entity:IsPlayer() ) then
		return false
	end

	// will automatically catch entities holding weapons
	if entity.CapabilitiesGet and bit_AND( entity:CapabilitiesGet(), CAP_SIMPLE_RADIUS_DAMAGE ) ~= 0 then
		return false
	end

	// specifically for weapons that block blast radius damage ( could this be used for a riotshield? )
	if entity.GetActiveWeapon and IsValid( entity:GetActiveWeapon() ) and entity:GetActiveWeapon().GetCapabilities and bit_AND( entity:GetActiveWeapon():GetCapabilities(), CAP_SIMPLE_RADIUS_DAMAGE ) ~= 0 then
		return false
	end

	return true
end

function CalculateExplosiveDamageForce( damage, vecDir, entity )
	local flClampForce = 75 * 400 //75kg is average character ragdoll mass
	local flForceScale = damage * ( 75 * 4 )

	if flForceScale > flClampForce then
		flForceScale = flClampForce
	end

	flForceScale = flForceScale * math.Rand( 0.85, 1.15 )

	local vecForce = Vector()
	vecForce:Set( vecDir )
	vecForce:Mul( flForceScale )
	vecForce:Mul( phys_pushscale:GetFloat() )

	return vecForce
end
