
// DONT FUCKING TOUCH I SWEAR TO GOD PLEEEEEAAAAASSSEEEEEEEEEEE
ENT.IgnoreCollisionEntities = {} // USE self:IgnoreEntityCollisions( entity, duration ) if duration is nil or < 0 projectile will ignore the entity forever
ENT.IgnoreEntities = {} // USE self:IgnoreEntity( entity, duration ) if duration is nil or < 0 projectile will ignore the entity forever
ENT.CollidedEntities = {}
ENT.CurrentCollisions = {}

local CurTime = CurTime
local IsValid = IsValid

local bit_AND = bit.band

local util_TraceLine = util.TraceLine
local util_TraceHull = util.TraceHull
local util_PointContents = util.PointContents

local MAT_GLASS = MAT_GLASS
local MASK_SHOT = MASK_SHOT
local MASK_RADIUS_DAMAGE = bit.band( MASK_SHOT, bit.bnot( CONTENTS_HITBOX ) )

local CONTENTS_SLIME = CONTENTS_SLIME
local CONTENTS_LIQUID = bit.bor( CONTENTS_WATER, CONTENTS_SLIME )

local COLLISION_GROUP_BREAKABLE_GLASS = COLLISION_GROUP_BREAKABLE_GLASS

local SHATTERSURFACE_TILE = 1

local FindHullIntersection = TFA.WonderWeapon.FindHullIntersection

function ENT:GetLastCollisionTrace()
	return self.LastCollisionTrace
end

// Will not collide with this entity for input duration
function ENT:IgnoreEntityCollisions( pEntity, flDuration )
	self.IgnoreCollisionEntities[ self:GetUniqueID(pEntity) ] = (flDuration == nil or !isnumber(flDuration) or flDuration < 0) and -1 or CurTime() + flDuration
end

// Will not return this entity within FindNearestEntities function for input duration
function ENT:IgnoreEntity( pEntity, flDuration )
	self.IgnoreEntities[ self:GetUniqueID(pEntity) ] = (flDuration == nil or !isnumber(flDuration) or flDuration < 0) and -1 or CurTime() + flDuration
end

function ENT:CollisionTraceThink()
	// reset IgnoreEntities before collision checks
	for index, time in pairs(self.IgnoreEntities) do
		if time < 0 then continue end

		if time < CurTime() then
			self.IgnoreEntities[ index ] = nil
		end
	end

	for index, time in pairs( self.IgnoreCollisionEntities ) do
		if time < 0 then continue end

		if time < CurTime() then
			self.IgnoreCollisionEntities[ index ] = nil
		end
	end

	if IsValid(phys) and not self.BlockCollisionTrace then
		if not self:TraceForCollisions() then
			return false
		end
	end

	// check for current collisions
	if not table.IsEmpty( self.CurrentCollisions ) then
		local insideEnts = ents.FindInBox( self:LocalToWorld( self.HullMins ), self:LocalToWorld( self.HullMaxs ) )
		local stillInside = {}

		for i = 1, table.Count( self.CurrentCollisions ) do
			for _, pEntity in ipairs( insideEnts ) do
				if self.CurrentCollisions[ pEntity ] then
					stillInside[ pEntity ] = true
					break
				end
			end
		end

		for pEnt, _ in pairs( self.CurrentCollisions ) do
			if self.CollidedEntities[ pEnt ] < CurTime() and not stillInside[ pEnt ] then
				if self.OnCollisionEnd then
					self:OnCollisionEnd( pEnt )
				end
				self.CurrentCollisions[ pEnt ] = nil
			end
		end
	end
end

function ENT:TraceForCollisions(position, direction, speed)
	local phys = self:GetPhysicsObject()

	if not IsValid( phys ) and ( position == nil or direction == nil or speed == nil ) then
		return
	end

	local ply = self:GetOwner()

	position = position or self:GetPos()
	speed = speed or phys:GetVelocity():Length()
	direction = direction or phys:GetVelocity():GetNormalized()
	local distance = speed * self.FrameTime

	self.Speed = speed

	local trace = {}

	util_TraceHull({
		start = position,
		endpos = position + ( direction * distance ),
		filter = function(ent)
			return self:ShouldTraceCollide( ent )
		end,
		mask = bit.bor( MASK_PLAYERSOLID, CONTENTS_GRATE ),
		maxs = self.HullMaxs,
		mins = self.HullMins,
		output = trace,
	})

	self:WaterLevelThink( trace )

	if self.WhizbySound then
		self:WhizSoundThink( position, (speed * (self.FrameTime * 2)) * direction + position, direction )
	end

	if trace.Hit then
		local hitEntity = trace.Entity
		if hitEntity:GetCollisionGroup() == COLLISION_GROUP_BREAKABLE_GLASS and self.ShouldDestroyWindows then
			if self.ShatterGlass then
				hitEntity:Input( "Break" )
			else
				// sonic & blast damage cause tile windows to blowout in a circular pattern
				local m_nSurfaceType = hitEntity:GetInternalVariable("surfacetype") or 0

				local hitDamage = DamageInfo()
				hitDamage:SetDamage(1)
				hitDamage:SetAttacker(IsValid(self:GetOwner()) and self:GetOwner() or self)
				hitDamage:SetInflictor(IsValid(self.Inflictor) and self.Inflictor or self)
				hitDamage:SetDamageType(m_nSurfaceType == SHATTERSURFACE_TILE and DMG_SONIC or DMG_BULLET)
				hitDamage:SetDamageForce(direction)
				hitDamage:SetDamagePosition(trace.HitPos)
				hitDamage:SetReportedPosition(trace.StartPos)

				hitEntity:DispatchTraceAttack(hitDamage, trace, direction)
			end

			return false
		end

		if trace.HitSky and !trace.StartSolid then
			Entity( 1 ):ChatPrint( tostring(self) .. " was slain" )
			self:Remove()
			return false
		end

		local trace2 = {}

		if IsValid( hitEntity ) and not trace.HitWorld then
			if FindHullIntersection( hitEntity, trace, trace2 ) then
				trace.HitPos:Set( trace2.HitPos )
				trace.HitBox = trace2.HitBox
				trace.PhysicsBone = trace2.PhysicsBone
				trace.HitGroup = ( trace2.HitGroup == HITGROUP_HEAD ) and HITGROUP_HEAD or HITGROUP_GENERIC // ignore scaling (sorry)
			end

			self.CollidedEntities[ hitEntity ] = CurTime()
			self.CurrentCollisions[ hitEntity ] = true

			self.LastCollisionTrace = trace
			self.HitPos = trace.HitPos
			self.HitNormal = -trace.HitNormal
			self.HitEntity = hitEntity
			self.OldVelocity = direction * speed
			self.HitWorld = false

			if self.ShouldLodgeProjectile then
				self:LodgeProjectile( trace )
			end

			if self.GetHitPos then
				self:SetHitPos(self.HitPos)
			end

			if self.EntityCollide then
				//Entity(1):ChatPrint('EntityCollide ['..tostring(trace.Entity)..'] at '..CurTime())
				local bReturnHalt = self:EntityCollide( trace )
				if bReturnHalt ~= nil then
					return bReturnHalt
				end
			end

			if IsValid( phys ) then
				local impulse = ( self.OldVelocity - 2 * self.OldVelocity:Dot( trace.HitNormal ) * trace.HitNormal ) * 0.25
				phys:SetVelocityInstantaneous( impulse )
			end
		end
	end

	return true
end

function ENT:WaterLevelThink(trace)
	local trace2 = {}

	if bit_AND(util_PointContents(trace.HitPos), CONTENTS_LIQUID) != 0 then
		if not self.IsUnderwater then
			self.IsUnderwater = true

			util_TraceLine({
				start = trace.StartPos,
				endpos = trace.HitPos,
				mask = CONTENTS_LIQUID,
				output = trace2,
			})

			self:SetNW2Vector( "WaterSurface", trace2.HitPos )

			self:DoWaterSplashEffect( trace2 )

			if self.BubbleTrail then
				self:CreateBubbleTrail()
			end

			if self.OnWaterEnter then // overwrite this
				self:OnWaterEnter( trace2, trace )
			end

			if self.RemoveInWater then
				self:Remove()
			end
		end
	 elseif self.IsUnderwater then
		self.IsUnderwater = false

		util_TraceLine({
			start = trace.HitPos,
			endpos = trace.StartPos,
			mask = CONTENTS_LIQUID,
			output = trace2,
		})

		self:DoWaterSplashEffect( trace )

		if self.OnWaterExit then // overwrite this
			self:OnWaterExit( trace2, trace )
		end
	end
end
