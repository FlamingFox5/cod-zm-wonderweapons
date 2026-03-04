AddCSLuaFile()

ENT.Base = "tfa_ww_base"
ENT.PrintName = "Wonder Weapon Projectile"

ENT.DesiredSpeed = 7000
ENT.DesiredGravity = nil // default uses sv_gravity convar

local CurTime = CurTime
local IsValid = IsValid

local bit_AND = bit.band

local util_TraceLine = util.TraceLine
local util_TraceHull = util.TraceHull
local util_PointContents = util.PointContents
local util_ScreenShake = util.ScreenShake

local MASK_SHOT = MASK_SHOT
local MAT_GLASS = MAT_GLASS
local CONTENTS_SLIME = CONTENTS_SLIME
local CONTENTS_LIQUID = bit.bor( CONTENTS_WATER, CONTENTS_SLIME )
local MASK_RADIUS_DAMAGE = bit.band( MASK_SHOT, bit.bnot( CONTENTS_HITBOX ) )
local COLLISION_GROUP_BREAKABLE_GLASS = COLLISION_GROUP_BREAKABLE_GLASS

local LIFE_ALIVE = 0
local BOLT_SPRITE_OFFSET = Vector( 0, 0, 0 )

local sv_friendly_fire = GetConVar("sv_tfa_bo3ww_friendly_fire")
local sv_npc_friendly_fire = GetConVar("sv_tfa_bo3ww_npc_friendly_fire")
local sv_npc_require_los = GetConVar("sv_tfa_bo3ww_monkeybomb_use_los")

local mImpactMaterials = TFA.WonderWeapon.BoltImpactSoundSurfaceMats

DEFINE_BASECLASS( ENT.Base )

function ENT:Initialize()
	BaseClass.Initialize(self)

	self:AddEFlags( EFL_NO_PHYSCANNON_INTERACTION )

	self:SetMoveType( MOVETYPE_NONE )
	self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE )
	self:SetSolid( SOLID_NONE )
	self:SetNotSolid( true )

	self.FrameTime = engine.TickInterval()
	self.FrameTimeRate = ( 1 / engine.TickInterval() )
	self.Speed = self.DesiredSpeed
	self.Gravity = self.DesiredGravity or ( GetConVar( "sv_gravity" ):GetInt() / self.FrameTimeRate ) * 0.25
	self.Direction = self:GetAngles():Forward()
end

function ENT:Think()
	if SERVER then
		local speed = self.Speed
		local gravity = self.Gravity
		local direction = self:GetAngles():Forward()
		local isUnderwater = self.IsUnderwater

		direction:Mul( speed )
		direction[ 3 ] = direction[ 3 ] - gravity
		speed = direction:Length()
		direction:Normalize()

		local position = self:GetPos()
		local owner = self:GetOwner()
		local distance = speed * self.FrameTime

		local trace = {} 
		local trace2 = {}
		local hitEntity
		local hitCharacter = false
		local hitRagdoll = false
		local hitDot = 0
		local hitsPerFrame = 0

		if !self.BlockCollisionTrace and !self:IsPlayerHolding() then
			if self.ProjectileCurve then
				local vecCurve = VectorRand() * ( math.sin( CurTime() * 30 ) ) * math.random( self.CurveStrengthMin, self.CurveStrengthMax )
				vecCurve:Normalize()

				direction:Add( vecCurve )
				direction:Normalize()
			end

			repeat
				util_TraceHull( {
					start = position,
					endpos = distance * direction + position,
					filter = function( ent )
						return self:ShouldTraceCollide( ent )
					end,
					mask = MASK_PLAYERSOLID,
					collisiongroup = COLLISION_GROUP_NONE,
					maxs = self.HullMaxs,
					mins = self.HullMins,
					output = trace,
				} )

				self:WaterLevelThink(trace)

				if trace.Hit then
					if trace.Fraction == 0 then
						trace.Normal:Set( direction )
					end

					if !nzombies and trace.HitSky then
						self.BlockCollisionTrace = true

						position:Set( trace.HitPos )
						speed = 0

						self:Remove()
						return
					end

					hitEntity = trace.Entity

					hitDot = trace.HitNormal:Dot( -direction )
					hitRagdoll = hitEntity:GetClass() == "prop_ragdoll"
					hitCharacter = hitEntity:IsNPC() || hitEntity:IsPlayer() || hitEntity:IsNextBot()

					if hitEntity:GetCollisionGroup() == COLLISION_GROUP_BREAKABLE_GLASS then
						position:Set( trace.HitPos )
						hitEntity:Input( "Break" )
						break
					end

					if trace.MatType == MAT_GLASS && hitEntity:GetInternalVariable( "m_lifeState" ) ~= LIFE_ALIVE then
						position:Set( trace.HitPos )
						break
					end

					if hitCharacter then
						if TFA.WonderWeapon.FindHullIntersection( hitEntity, trace, trace2 ) then
							trace.HitPos:Set( trace2.HitPos )
							trace.HitBox = trace2.HitBox
							trace.PhysicsBone = trace2.PhysicsBone
							trace.HitGroup = trace2.HitGroup
						else
							trace.UnreliableHitPos = true
						end
					end

					self.LastCollisionTrace = trace
					self.HitPos = trace.HitPos
					self.HitNormal = -trace.HitNormal
					self.HitEntity = hitEntity
					self.OldVelocity = direction * speed
					self.HitWorld = trace.HitWorld

					if not trace.HitWorld then
						self.CollidedEntities[ hitEntity ] = CurTime()
						self.CurrentCollisions[ hitEntity ] = true

						if self.EntityCollide then
							local bReturnHalt = self:EntityCollide( trace )
							if tobool( bReturnHalt ) then
								self.BlockCollisionTrace = true

								position:Set( trace.HitPos )
								speed = 0

								if self.ShouldLodgeProjectile then
									self:LodgeProjectile( trace )
								end

								if self.GetHitPos then
									self:SetHitPos( self.HitPos )
								end

								break
							end
						end
					else
						if self.WorldCollide then
							local bReturnHalt = self:WorldCollide( trace )
							if tobool( bReturnHalt ) then
								self.BlockCollisionTrace = true

								position:Set( trace.HitPos )
								speed = 0

								if self.ShouldLodgeProjectile then
									self:LodgeProjectile( trace )
								end	

								if self.GetHitPos then
									self:SetHitPos( self.HitPos )
								end

								break
							end
						else
							self.BlockCollisionTrace = true

							position:Set( trace.HitPos )
							speed = 0

							if self.ShouldLodgeProjectile then
								self:LodgeProjectile( trace )
							end	

							if self.GetHitPos then
								self:SetHitPos( self.HitPos )
							end

							break
						end
					end
				end

				position:Set( trace.HitPos )
				distance = distance * ( 1 - trace.Fraction )

				hitsPerFrame = 1 + hitsPerFrame
			until ( distance <= 0 || hitsPerFrame > 3 ) // Stop tracing

			if !self.BlockCollisionTrace then
				self:SetPos( position )
				self:SetAngles( direction:Angle() )
			end

			self.Speed = speed
			self.Gravity = gravity
			self.Direction = direction
		end
	end

	return BaseClass.Think(self)
end
