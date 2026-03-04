
local sv_true_damage = GetConVar("sv_tfa_bo3ww_cod_damage")

local util_TraceLine = util.TraceLine
local util_ScreenShake = util.ScreenShake

local BodyTarget = TFA.WonderWeapon.BodyTarget
local ShouldDamage = TFA.WonderWeapon.ShouldDamage
local ShouldCollide = TFA.WonderWeapon.ShouldCollide
local DoorClasses = TFA.WonderWeapon.DoorClasses

function ENT:GetTrueDamage( entity )
	self.Damage = self.mydamage or self.Damage

	if ( nzombies or ( sv_true_damage and sv_true_damage:GetBool() ) ) then
		if self.InfiniteDamage and IsValid( entity ) then
			return entity:Health() + 666
		else
			return self.Damage or 100
		end
	else
		return self.Damage or 100
	end
end

function ENT:PhysicsStop( phys )
	if phys == nil or not IsValid( phys ) then
		phys = self:GetPhysicsObject()
	end

	if IsValid( phys ) then
		phys:AddGameFlag( FVPHYSICS_NO_PLAYER_PICKUP )
		phys:AddGameFlag( FVPHYSICS_CONSTRAINT_STATIC )

		phys:SetVelocity( vector_origin )
		phys:EnableMotion( false )
		phys:Sleep()
	end
end

function ENT:GetUniqueID( pEntity )
	if not IsValid( pEntity ) then return nil end
	return pEntity:CreatedByMap() and pEntity:MapCreationID() or pEntity:GetCreationID()
end

function ENT:CollisionDataToTrace(data)
	local entity = data.HitEntity

	local trace = util.TraceLine({
		start = self:GetPos(),
		endpos = data.HitPos + data.HitNormal,
		mask = MASK_SHOT,
		filter = data.HitEntity,
		whitelist = true,
	})

	local trace2 = {}

	if IsValid( entity ) and trace.Entity ~= entity then
		if ( entity:IsPlayer() or entity:IsNPC() or entity:IsNextBot() or entity:IsVehicle() or entity:IsRagdoll() or entity:IsWeapon() or entity:Alive() ) and TFA.WonderWeapon.FindHullIntersection( entity, trace, trace2, MASK_SHOT ) then
			trace = trace2
		end
		trace.Entity = entity
	end


	trace.IsPhysicsCollide = true

	//debugoverlay.Axis(trace.HitPos, trace.HitNormal:Angle(), 10, 5, true)
	//Entity(1):ChatPrint('CollisionDataToTrace ['..tostring(trace.Entity)..'] at '..CurTime())

	self:StoreCollisionEventData( data, trace )

	return trace
end

function ENT:StoreCollisionEventData(data, trace)
	if not trace then
		self:CollisionDataToTrace(data)
		return
	end

	self.LastCollisionTrace = trace
	self.HitPos = data.HitPos
	self.HitNormal = trace.HitNormal
	self.HitEntity = data.HitEntity
	self.HitWorld = trace.HitWorld
	self.OldVelocity = data.OurOldVelocity

	if self.GetHitPos then
		self:SetHitPos(self.HitPos)
	end
end

function ENT:ShouldTraceCollide( entity )
	local playerEntity = self:GetOwner()

	if IsValid( playerEntity ) and entity == playerEntity and not self.CollideWithOwner then
		return false
	end

	if !ShouldCollide( entity, playerEntity, self )  then
		return false
	end

	if entity:IsWeapon() then
		return false
	end

	local index = self:GetUniqueID( entity )

	if self.IgnoreCollisionEntities and self.IgnoreCollisionEntities[ index ] then
		return false
	end

	if self.CurrentCollisions and self.CurrentCollisions[ entity ] then
		return false
	end

	return true
end

function ENT:IsAttractiveTarget( entity )
	local playerEntity = self:GetOwner()

	if IsValid( playerEntity ) and entity == playerEntity then
		return false
	end

	if !ShouldDamage( entity, playerEntity, self )  then
		return false
	end

	if entity:IsWeapon() then
		return false
	end

	local index = self:GetUniqueID( entity )

	if self.IgnoreCollisionEntities and self.IgnoreCollisionEntities[ index ] then
		return false
	end

	if self.CurrentCollisions and self.CurrentCollisions[ entity ] then
		return false
	end

	return true
end

function ENT:FindNearestEntities(vecSrc, radius, ignoreentities, ignoreworld)
	if not vecSrc or not isvector( vecSrc ) or vecSrc:IsZero() then
		vecSrc = self:GetPos()
	end

	if not radius or not isnumber( radius ) or radius < 0 then
		radius = self.Range
	end

	if ignoreworld == nil then
		ignoreworld = false
	end

	local nearbyEnts = {}

	local ply = self:GetOwner()
	for k, v in ipairs( ents.FindInSphere( vecSrc, radius ) ) do
		if v == ply then continue end
		if !ShouldDamage( v, ply, self ) then continue end
		if v:GetNoDraw() and not ( v:IsNPC() or v:IsPlayer() or v:IsVehicle() or v:IsRagdoll() ) then continue end

		if self.ShouldIncludeNearbyEntity and isfunction(self.ShouldIncludeNearbyEntity) then
			local retVal = self:ShouldIncludeNearbyEntity(v, vecSrc, radius, ignoreentities, ignoreworld)
			if retVal ~= nil and not retVal then
				continue
			end
		end

		if self.FindSolidOnly and ( !v:IsSolid() and !v:IsRagdoll() and !DoorClasses[ v:GetClass() ] ) then continue end
		if self.FindCharacterOnly and not ( v:IsNPC() or v:IsPlayer() or v:IsNextBot() ) then continue end

		if ( ignoreentities == nil and !self.IgnoreEntities[ self:GetUniqueID( v ) ] ) or ( ignoreentities ~= nil and !ignoreentities[v] ) then
			table.insert(nearbyEnts, v)
		end
	end

	if #nearbyEnts > 1 then
		table.sort(nearbyEnts, function(a, b) return a:GetPos():DistToSqr( vecSrc ) < b:GetPos():DistToSqr( vecSrc ) end )
	end

	if not ignoreworld then	
		local tr = {
			start = vecSrc,
			filter = {self, self.Inflictor, ply},
			mask = MASK_SOLID_BRUSHONLY,
			collisiongroup = COLLISION_GROUP_NONE,
		}

		local trace = {}

		for k, v in pairs( nearbyEnts ) do
			tr.endpos = BodyTarget( v, vecSrc )
			tr.output = trace

			util_TraceLine( tr )

			table.insert( tr.filter, v )

			if trace.HitWorld then
				table.remove( nearbyEnts, k )
			end
		end
	end

	return nearbyEnts
end

function ENT:FindNearestEntity(vecSrc, radius, ignoreentities, ignoreworld)
	return self:FindNearestEntities(vecSrc, radius, ignoreentities, ignoreworld)[1]
end

function ENT:SendHitMarker(entity, damageinfo, trace)
	if not damageinfo then return end
	if not IsValid(entity) or not (entity:IsNPC() or entity:IsNextBot() or entity:IsPlayer() or entity:IsVehicle()) then return end

	local wep = self.Inflictor
	local ply = self:GetOwner()

	if IsValid(ply) and ply:IsPlayer() and IsValid(wep) and wep:IsWeapon() and wep.SendHitMarker then
		if not trace or not istable(trace) then
			local hitpos = damageinfo:GetDamagePosition()
			trace = {["Entity"] = entity, ["Hit"] = true, ["HitPos"] = !hitpos:IsZero() and hitpos or entity:WorldSpaceCenter()}
		end
		wep:SendHitMarker(ply, trace, damageinfo)
	end
end

function ENT:ScreenShake( position )
	if position == nil or not isvector(position) or position:IsZero() then
		position = ( self.GetHitPos and !self:GetHitPos():IsZero() ) and self:GetHitPos() or self:GetPos()
	end

	util_ScreenShake( position, self.ScreenShakeAmplitude or 5, self.ScreenShakeFrequency or 255, self.ScreenShakeDuration or 1, self.ScreenShakeRange or self.Range * 2.2 )
end

// Point Entities

function ENT:GetBullseye( offset, follow )
	if self.pBullseye and IsValid( self.pBullseye ) then
		return self.pBullseye
	end

	local target = ents.Create("npc_bullseye")
	if not IsValid( target ) then
		return NULL
	end

	if not offset or not isvector( offset ) then
		offset = Vector()
	end

	if follow == nil or not isbool( follow ) then
		follow = true
	end

	target:SetPos( self:GetPos() + offset )
	target:SetKeyValue( "health", "0" )
	target:SetKeyValue( "spawnflags", "256" ) // SF_NPC_LONG_RANGE
	target:SetKeyValue( "spawnflags", "131072" ) // SF_BULLSEYE_NODAMAGE 
	target:SetNoDraw(true)
	target:SetNotSolid(true)
	target:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
	target:Spawn()
	target:Activate()

	if follow then
		target:SetParent(self)
	end

	self.pBullseye = target

	return target
end

function ENT:GetRagdollMagnet( offset, radius, force )
	if self.pRagdollMagnet and IsValid( self.pRagdollMagnet ) then
		return self.pRagdollMagnet
	end

	local magnet = ents.Create("phys_ragdollmagnet")
	if not IsValid( magnet ) then
		return NULL
	end

	if not offset or not isvector( offset ) then
		offset = Vector()
	end

	if not radius or not isnumber( radius ) then
		radius = 800
	end

	if not force or not isnumber( force ) then
		force = 4000
	end

	magnet:SetPos( self:GetPos() + offset )
	magnet:SetAngles( self:GetAngles() )
	magnet:SetNoDraw( true )
	magnet:SetNotSolid( true )
	magnet:SetCollisionGroup( COLLISION_GROUP_IN_VEHICLE )

	magnet:SetKeyValue( "radius", tostring( radius ) )
	magnet:SetKeyValue( "force", tostring( force ) )

	magnet:Spawn()
	magnet:Activate()

	magnet:SetParent( self )

	magnet:Fire( "Disable" )

	self.pRagdollMagnet = magnet

	return magnet
end
