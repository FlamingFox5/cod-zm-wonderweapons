local nzombies = engine.ActiveGamemode() == "nzombies"
local LIFE_ALIVE = 0

//-------------------------------------------------------------
// Globals
//-------------------------------------------------------------

local WonderWeapons = TFA.WonderWeapon

WonderWeapons.StatusEffects = WonderWeapons.StatusEffects or {}

local StatusEffects = WonderWeapons.StatusEffects

// Table of Entities with each Key being the entity and its Value being a table of its active Status Effects

StatusEffects.Entities = StatusEffects.Entities or {}

local ActiveStatusEffects = StatusEffects.Entities

// Table used to keep track of and give all Status Effects a unique index

StatusEffects.IndexCount = StatusEffects.IndexCount or 0

local CurrentIndex = StatusEffects.IndexCount

// Table of Status Effect Objects by their Index isntead of being tied to the parent Entity

StatusEffects.Index = StatusEffects.Index or {}

local StatusEffectIndex = StatusEffects.Index

// Status Effect State Enumerations (int)

StatusEffects.States = StatusEffects.States or {}

local StatusState = StatusEffects.States

StatusState.ACTIVE = 0
StatusState.INITIALIZING = 1
StatusState.ENDED = 2
StatusState.REMOVE = 3

// Main Table Thingy
local StatusEffect = {}

// Use this to access the main table and make your own GLOBAL StatusEffect:MyCustomFunction()
RegisterMetaTable("WWStatusEffect", StatusEffect)

//-------------------------------------------------------------
// Main Functions
//-------------------------------------------------------------

function WonderWeapons.AddStatusEffect(id, data)
	StatusEffects[id] = data
end

function WonderWeapons.StatusEffectData(id)
	return StatusEffects[id] or nil
end

if SERVER then
	//-------------------------------------------------------------
	// Serverside Functions
	//-------------------------------------------------------------

	function WonderWeapons.GetStatuses( entity )
		if not IsValid( entity ) then return end
		if not ActiveStatusEffects[ entity:EntIndex() ] then
			ActiveStatusEffects[ entity:EntIndex() ] = {}
		end

		return ActiveStatusEffects[ entity:EntIndex() ]
	end

	function WonderWeapons.GetStatus( entity, effect )
		if not IsValid( entity ) then return end

		local currentStatuses = WonderWeapons.GetStatuses( entity )
		return currentStatuses[ effect ] or nil
	end

	function WonderWeapons.HasStatus( entity, effect )
		if not IsValid( entity ) then return end

		local currentStatuses = WonderWeapons.GetStatuses( entity )
		return tobool( currentStatuses[ effect ] )
	end

	function WonderWeapons.GetStatusByIndex( index )
		if not index or not isnumber( index ) or index < 1 then
			return
		end

		return StatusEffectIndex[ index ] or nil
	end

	function WonderWeapons.RemoveStatus( entity, effect, bNoSync )
		if not IsValid( entity ) then return end

		local mStatus = WonderWeapons.GetStatuses( entity )[ effect ]

		if not mStatus then return end
		
		hook.Run( "TFA_WonderWeapon_PreStatusEffectRemoved", entity, mStatus, bNoSync )

		if not bNoSync then
			mStatus:SyncRemove()
		end

		if mStatus.ZombieSlowed then
			mStatus:ResetZombieSlow()
		end

		if mStatus.EntityNoTarget then
			mStatus:ResetNoTarget()
		end

		if mStatus.BlockAttack then
			mStatus:ResetBlockAttack()
		end

		if mStatus.SpeedChanged then
			mStatus:ResetMoveSpeed()
		end

		if mStatus.CollisionGroupChanged then
			mStatus:ResetCollisionGroup()
		end

		if mStatus.ModelScaleChanged then
			mStatus:ResetModelScale()
		end

		if mStatus.ShouldFreeze then
			mStatus:UnfreezeEntity()
		end

		local index = mStatus:GetIndex()

		mStatus:OnRemove( entity )

		hook.Run( "TFA_WonderWeapon_PostStatusEffectRemoved", entity, mStatus, bNoSync )

		ActiveStatusEffects[ entity:EntIndex() ][ effect ] = nil
		StatusEffectIndex[ index ] = nil

		if next( ActiveStatusEffects[ entity:EntIndex() ] ) == nil then
			ActiveStatusEffects[ entity:EntIndex() ] = nil
		end
	end

	function WonderWeapons.GiveStatus( entity, effect, duration, ... )
		if not IsValid( entity ) then return end

		// Return true to block effect from being given
		//  please know what you are doing

		local hookOverride = hook.Run( "TFA_WonderWeapon_GiveStatusEffect", entity, effect, duration, ... )
		if hookOverride ~= nil and tobool( hookOverride ) then
			return
		end

		if nzombies and entity:IsValidZombie() and ( entity.IsAATTurned and entity:IsAATTurned() or entity.Turned ) then
			return
		end

		local effectData = WonderWeapons.StatusEffectData( effect )
		if not effectData then return end

		local varargs = table.Pack( ... )

		// Update if entity already has given status effect
		local currentStatuses = WonderWeapons.GetStatuses( entity )
		if currentStatuses[ effect ] then
			local mStatus = currentStatuses[ effect ]

			hook.Run( "TFA_WonderWeapon_PreUpdateStatusEffect", entity, mStatus, duration, ... )

			mStatus:SetDuration( duration )
			mStatus:SetEndTime( CurTime() + duration )

			mStatus:Update( entity, duration, unpack( varargs ) )

			hook.Run( "TFA_WonderWeapon_PostUpdateStatusEffect", entity, mStatus, duration, ... )

			mStatus:Sync( entity, duration, varargs )

			return mStatus
		end

		local nMaxMinusOne = ( 2^31 - 1 ) - 1
		local nNextIndex = 1 + CurrentIndex

		if ( nNextIndex >= nMaxMinusOne ) then
			nNextIndex = 1 // Justin Case
		end

		CurrentIndex = nNextIndex

		// Creating status effect table
		local data = table.Copy( effectData )
		data.StatusEffect = effect
		data.StatusEffectData = effectData
		data.State = StatusState.INITIALIZING
		data.Index = CurrentIndex

		setmetatable( data, StatusEffect )

		currentStatuses[ effect ] = data

		// New status effect object
		local mStatus = currentStatuses[ effect ]
		mStatus:SetEntity( entity )
		mStatus:SetIndex( CurrentIndex )
		mStatus:SetDuration( duration )
		mStatus:SetStartTime( CurTime() )
		mStatus:SetEndTime( CurTime() + duration )

		hook.Run( "TFA_WonderWeapon_StatusEffectCreated", entity, mStatus, duration, ... )

		mStatus:Sync( entity, duration, varargs )

		// Clear all status effects when removed ( mimicked by client so no networking needed )
		entity:CallOnRemove( "WonderWeapon.StatusEffects.Removed."..effect.."."..entity:EntIndex(), function( removed )
			if mStatus == nil then return end
			if mStatus:GetEntity() ~= removed then return end // dont ever do this or i will find you, and i will kill myself my self

			WonderWeapons.RemoveStatus( removed, effect, true )
		end )

		// Initialization
		mStatus.HasInitialized = true

		local hullMins, hullMaxs = entity:GetCollisionBounds()
		if not mStatus.HullMaxs then
			if mStatus.HullPadding then
				hullMaxs:Add( mStatus.HullPadding )
			end

			mStatus.HullMaxs = hullMaxs
		end
		if not mStatus.HullMins then
			if mStatus.HullPadding then
				hullMins:Sub( mStatus.HullPadding )
			end

			mStatus.HullMins = hullMins
		end

		mStatus.ChestAttachment = WonderWeapons.GetChestAttachment( entity )
		mStatus.HeadAttachment = WonderWeapons.GetHeadAttachment( entity )
		mStatus.EyesAttachment = WonderWeapons.GetEyeAttachment( entity )
		mStatus.MouthAttachment = WonderWeapons.GetMouthAttachment( entity )

		local eyeR, eyeL = WonderWeapons.GetEyesAttachment( entity )
		mStatus.RightEyeAttachment = eyeR
		mStatus.LeftEyeAttachment = eyeL

		local handR, handL = WonderWeapons.GetHandsAttachment( entity )
		mStatus.RightHandAttachment = handR
		mStatus.LeftHandAttachment = handL

		mStatus:Initialize( entity, duration, unpack(varargs) )

		local mStatus = WonderWeapons.GetStatuses( entity )[ effect ]

		hook.Run( "TFA_WonderWeapon_PostStatusEffectInitialized", entity, mStatus, duration, varargs )

		if mStatus.ZombieSlowWalk and nzombies and entity:IsValidZombie() then
			mStatus:SlowZombie()
		end

		if mStatus.PlayerNoTarget and entity:IsPlayer() then
			mStatus:NoTargetPlayer()
		end

		if mStatus.BlockAttack then
			mStatus:EntityBlockAttack()
		end

		if mStatus.CollisionGroupOverride and not entity:IsPlayer() then
			mStatus:ModifyCollisionGroup()
		end

		if mStatus.ShouldFreeze then
			mStatus:FreezeEntity()
		end

		if mStatus.ModelScale then
			mStatus:ModifyModelScale()
		end

		local flStartInit = SysTime()
		local hookName = "WonderWeapon.StatusEffect.PostInitialize."..effect
		hook.Add( "Think", hookName, function()
			hook.Remove( "Think", hookName )

			if not IsValid( entity ) then return end

			local mStatus = WonderWeapons.GetStatuses( entity )[ effect ]

			if not mStatus then return end

			print( SysTime() )
			if mStatus.HasInitialized and mStatus:GetState() == StatusState.INITIALIZING then
				local shitter = tostring(entity)
				print( shitter.." Status ["..effect.."] activated by Think Hook" )
				mStatus:SetState( StatusState.ACTIVE )
			end

			local flSubTickDifference = flStartInit - SysTime()

			mStatus:PostInitialize( entity, flSubTickDifference )

			hook.Run( "TFA_WonderWeapon_StatusEffectPostInitialized", entity, mStatus, flSubTickDifference )

			if mStatus.DoAlertSound then
				if entity.AlertSound then
					entity:AlertSound()
				elseif entity.TauntSounds and entity.PlaySound then
					entity:PlaySound( entity.TauntSounds[ math.random( #entity.TauntSounds ) ], 100, math.random( entity.MinSoundPitch or 97, entity.MaxSoundPitch or 103 ), 1, 2 )
					entity.NextSound = CurTime() + ( entity.SoundDelayMax or 6 )
				end
			end

			if mStatus.DoFearSound then
				if entity.FearSound then
					entity:FearSound()
				elseif entity.FireDeathSounds and entity.PlaySound then
					entity:PlaySound( entity.FireDeathSounds[ math.random( #entity.FireDeathSounds ) ], 90, math.random( entity.MinSoundPitch or 95, entity.MaxSoundPitch or 105 ), 1, 2 )
				end
			end

			if mStatus.DoDeathSound then
				if entity.StartEngineSchedule and entity.SetSchedule then
					entity:SetSchedule( SCHED_DIE_RAGDOLL )
				elseif entity.DeathSounds and entity.PlaySound then
					entity:PlaySound( entity.DeathSounds[ math.random( #entity.DeathSounds ) ], 90, math.random( entity.MinSoundPitch or 97, entity.MaxSoundPitch or 103 ), 1, 2 )
				end
			end

			if mStatus.DropWeapon and entity.DropWeapon then
				if entity:IsNPC() then
					entity:SetKeyValue( "spawnflags", bit.band( entity:GetSpawnFlags(), bit.bnot( SF_NPC_NO_WEAPON_DROP ) ) )
				end
				entity:DropWeapon( nil, entity:GetPos() + entity:GetAimVector(), entity.WeaponDropVelocity or 240 )
			end
		end )

		StatusEffectIndex[ CurrentIndex ] = mStatus

		return mStatus
	end

	// Serverside Hooks

	hook.Add( "Tick", "TFA.BO3WW.FOX.StatusEffect.Think", function()
		for eid, effectTable in pairs( ActiveStatusEffects ) do
			local entity = Entity( eid )
			if not IsValid( entity ) then continue end

			for effect, mStatus in pairs( effectTable ) do
				if not mStatus then continue end

				if !mStatus.HasPrintedDebugStart then
					print( SysTime() )
					mStatus.HasPrintedDebugStart = true
				end

				if mStatus.HasInitialized and mStatus:GetState() == StatusState.INITIALIZING then
					local shitter = tostring(entity)
					print( shitter.." Status ["..effect.."] activated by Tick Hook" )
					mStatus:SetState( StatusState.ACTIVE )
				end

				// Collisions
				if mStatus.ShouldCollide then
					local position = entity:GetPos()
					local trace = {}

					util.TraceHull({
						start = position,
						endpos = position,
						filter = ( mStatus.CollisionFilter ~= nil and IsTableOfEntitiesValid(mStatus.CollisionFilter) ) and mStatus.CollisionFilter or entity,
						mask = mStatus.CollisionMask,
						collisiongroup = mStatus.CollisionGroup,
						ignoreworld = mStatus.CollisionIgnoreWorld,
						maxs = mStatus.HullMaxs,
						mins = mStatus.HullMins,
						output = trace,
					})

					mStatus.PreIntersectionCollisionTrace = trace

					local hitEntity = trace.Entity
					if trace.Hit then
						local trace2 = {}
						if IsValid( hitEntity ) and WonderWeapons.FindHullIntersection( hitEntity, trace, trace2 ) then
							trace.HitPos:Set( trace2.HitPos )
							trace.HitBox = trace2.HitBox
							trace.PhysicsBone = trace2.PhysicsBone
							trace.HitGroup = ( trace2.HitGroup == HITGROUP_HEAD ) and HITGROUP_HEAD or HITGROUP_GENERIC
						end

						mStatus.CollisionTrace = trace

						hook.Run( "TFA_WonderWeapon_StatusEffectCollision", entity, mStatus, mStatus.CollisionTrace, mStatus.PreIntersectionCollisionTrace )

						mStatus:EntityCollide( entity, trace )
					end
				end

				// NPC Movement
				if mStatus.DesiredSpeed then
					local rate = 1 - math.Clamp( ( ( mStatus:GetStartTime() + mStatus.SpeedChangeDelta ) - CurTime() ) / mStatus.SpeedChangeDelta, 0, 1 )

					if entity:IsNPC() and entity.pStoredIdealSpeed then
						entity:SetMoveVelocity( entity:GetMoveVelocity():GetNormalized() * Lerp(rate, entity.pStoredIdealSpeed, mStatus.DesiredSpeed ) )
					end

					if entity:IsNextBot() and entity.pStoredAcceleration and mStatus.DesiredAcceleration then
						entity.loco:SetAcceleration( Lerp(rate, entity.pStoredAcceleration, mStatus.DesiredAcceleration ) )
						entity.loco:SetDesiredSpeed( Lerp(rate, entity.pStoredDesiredSpeed, mStatus.DesiredSpeed ) )
					end
				end

				// Thinking
				mStatus:Think( entity )

				// Removal
				if ( mStatus:GetEndTime() < CurTime() ) or ( entity:IsPlayer() and not entity:Alive() ) then
					if !mStatus.HasEndTimeElapsed then
						mStatus.HasEndTimeElapsed = true
						mStatus:SetState( StatusState.ENDED )

						mStatus:OnStatusEnd( entity )

						mStatus:SyncEnd()
					end

					if mStatus:ShouldRemove( entity ) then
						mStatus:SetState( StatusState.REMOVE )

						mStatus:Remove()
					end
				end
			end
		end
	end )

	hook.Add( "EntityTakeDamage", "TFA.BO3WW.FOX.StatusEffect.TakeDamage", function( entity, damageinfo )
		if ActiveStatusEffects[ entity:EntIndex() ] then
			if entity.StatusEffectDamage then return end

			for effect, mStatus in pairs( ActiveStatusEffects[ entity:EntIndex() ] ) do
				local nLifeState = entity:GetInternalVariable( "m_lifeState" )

				if entity:Health() > 0 and ( nLifeState == nil or nLifeState == LIFE_ALIVE ) then
					// return 'true' to block entity taking damage
					local bBlockHook = mStatus:EntityTakeDamage( entity, damageinfo )
					if tobool( bBlockHook ) then
						damageinfo:SetDamage( 0 )
						damageinfo:SetMaxDamage( 0 )
						damageinfo:SetDamageBonus( 0 )
						damageinfo:ScaleDamage( 0 )
						return true
					end
				end

				local hookName = "WonderWeapon.StatusEffect.PostTakeDamage." .. entity:EntIndex()
				hook.Add( "PostEntityTakeDamage", hookName, function( postEntity, postDamageinfo, bTook )
					if not IsValid( entity ) then
						hook.Remove( "PostEntityTakeDamage", hookName )
						return
					end

					if ( postEntity == entity ) then
						hook.Remove( "PostEntityTakeDamage", hookName )

						local bIsLivingBeing = ( postEntity:IsPlayer() or postEntity:IsNextBot() or postEntity:IsNPC() or postEntity:IsVehicle() )

						if ( bTook ) and ( postEntity:Health() <= 0 or ( not bIsLivingBeing and postDamageinfo:GetDamage() >= entity:Health() ) ) then
							mStatus:OnEntityKilled( entity, postDamageinfo )
						end
					end
				end )
			end
		end
	end )

	hook.Add( "CreateEntityRagdoll", "TFA.BO3WW.FOX.StatusEffect.EntityRagdoll", function( entity, ragdoll )
		if ActiveStatusEffects[ entity:EntIndex() ] then
			if entity.StatusEffectDamage then return end

			for effect, mStatus in pairs( ActiveStatusEffects[ entity:EntIndex() ] ) do
				mStatus:OnEntityRagdoll( entity, ragdoll )
			end
		end
	end )

	hook.Add( "PlayerSpawn", "TFA.BO3WW.FOX.StatusEffect.PlayerSpawn", function( ply, bTransition )
		if ( bTransition ) then return end

		if ActiveStatusEffects[ ply:EntIndex() ] then
			for effect, mStatus in pairs( ActiveStatusEffects[ ply:EntIndex() ] ) do
				WonderWeapons.RemoveStatus( ply, effect )
			end
		end
	end )

	/*local lockedPlayers = {}
	local updateStatuses = {}

	hook.Add("StartCommand", "TFA.BO3WW.FOX.StatusEffect.DeSyncFix", function( ply, cusercmd )
		if SERVER then
			// CUserCommand:IsForced() means the player stopped sending usercommand data to the server and their last inputs are being looped
			//  assuming this only happens during packet loss, we should be able to use this for fixing desync possibly

			if cusercmd:IsForced() then
				if !lockedPlayers[ ply ] then
					lockedPlayers[ ply ] = CurTime()
				end
			elseif lockedPlayers[ ply ] then
				local missedUpdates = updateStatuses[ ply ]

				for index, data in pairs( missedUpdates ) do
					// i give up
				end

				lockedPlayers[ ply ] = nil
			end
		end
	end)

	hook.Add("PlayerPostThink", "TFA.BO3WW.FOX.StatusEffect.DeSyncFix", function( ply )
		if SERVER then
			local updates = CurrentUpdates
			for index, data in pairs( updates ) do
				if StatusEffectIndex[ index ] and lockedPlayers[ ply ] and lockedPlayers[ ply ] + 0.2 < CurTime() then
					if not updateStatuses[ ply ] then
						updateStatuses[ ply ] = {}
					end

					updateStatuses[ ply ][ index ] = data
				end

				CurrentUpdates[ index ] = nil

				continue
			end
		end
	end)

	gameevent.Listen( "OnRequestFullUpdate" )
	hook.Add( "OnRequestFullUpdate", "TFA.BO3WW.FOX.StatusEffect.DeSyncFix", function( data )
		local ply = Player( data.userid )
		if not IsValid( ply ) then return end
	end )*/
end

// Shared Hooks

hook.Add( "SetupMove", "TFA.BO3WW.FOX.StatusEffect.SetupMove", function( ply, cmovedata, cusercmd )
	local currentStatuses = WonderWeapons.GetStatuses( ply )

	for effect, mStatus in pairs( currentStatuses ) do
		mStatus:SetupMove( ply, cmovedata, cusercmd )

		if mStatus.BlockPlayerAttack and cusercmd:GetImpulse() == TFA.BASH_IMPULSE then
			cusercmd:SetImpulse( 0 )
		end

		if mStatus.SpeedChangeRatio then
			local rate = 1 - math.Clamp( ( ( mStatus:GetStartTime() + mStatus.SpeedChangeDelta ) - CurTime() ) / mStatus.SpeedChangeDelta, 0, 1 )

			cmovedata:SetMaxClientSpeed( cmovedata:GetMaxClientSpeed() * Lerp( rate, 1, mStatus.SpeedChangeRatio ) )

			cusercmd:SetForwardMove( cusercmd:GetForwardMove() * Lerp( rate, 1, mStatus.SpeedChangeRatio ) )
			cusercmd:SetSideMove( cusercmd:GetSideMove() * Lerp( rate, 1, mStatus.SpeedChangeRatio ) )
		elseif mStatus.DesiredSpeed then
			cmovedata:SetMaxClientSpeed( mStatus.DesiredSpeed )

			cusercmd:SetForwardMove( math.Clamp( cusercmd:GetForwardMove(), 0, mStatus.DesiredSpeed ) )
			cusercmd:SetSideMove( math.Clamp( cusercmd:GetSideMove(), 0, mStatus.DesiredSpeed ) )
		end
	end
end )


G_StatusEffectsMoveFinished = false
G_StatusEffectsLastMoveFinish = 0

hook.Add( "StartCommand", "TFA.BO3WW.FOX.StatusEffect.StartCommand", function( ply, cusercmd )
	if G_StatusEffectsLastMoveFinish ~= CurTime() then
		G_StatusEffectsLastMoveFinish = CurTime()
		G_StatusEffectsMoveFinished = false
	end

	local currentStatuses = WonderWeapons.GetStatuses( ply )

	for effect, mStatus in pairs( currentStatuses ) do
		mStatus:StartCommand( ply, cusercmd )
	end
end )

hook.Add( "FinishMove", "TFA.BO3WW.FOX.StatusEffect.FinishMove", function( ply, cmovedata )
	for eid, statusTable in pairs( ActiveStatusEffects ) do
		local entity = Entity( eid )
		if IsValid( entity ) then
			if !entity:IsPlayer() and ( ( CLIENT and !entity:GetPredictable() or SERVER ) or G_StatusEffectsMoveFinished ) then
				if entity.LastStatusEffectMoveFrame and entity.LastStatusEffectMoveFrame == CurTime() then
					continue
				end

				entity.LastStatusEffectMoveFrame = CurTime()
			end

			for effect, mStatus in pairs( statusTable ) do
				if entity == ply then
					mStatus:FinishMove( entity, cmovedata )
				else
					mStatus:FinishMove( entity )
				end
			end
		end
	end

	G_StatusEffectsMoveFinished = true
end )

//-------------------------------------------------------------
// Default Shared Functions
//-------------------------------------------------------------

StatusEffect.StartTime = 0
StatusEffect.EndTime = 0
StatusEffect.Duration = 0
StatusEffect.Upgraded = false
StatusEffect.CollisionGroup = COLLISION_GROUP_NONE
StatusEffect.CollisionMask = bit.band( MASK_SHOT, bit.bnot( CONTENTS_HITBOX ) )
StatusEffect.Index = 0
StatusEffect.Damage = 0

// Dont modify these ( ever )

function StatusEffect:SetEntity( entity )
	self.Parent = entity
end

function StatusEffect:GetEntity()
	return self.Parent
end

function StatusEffect:SetIndex( int )
	self.Index = tonumber( int )
end

function StatusEffect:GetIndex()
	return self.Index or 0
end

// Dont modify how these work, but do make use of them

function StatusEffect:SetEndTime( time )
	self.EndTime = tonumber(time)
end

function StatusEffect:GetEndTime()
	return self.EndTime
end

function StatusEffect:SetStartTime( time )
	self.StartTime = tonumber(time)
end

function StatusEffect:GetStartTime()
	return self.StartTime
end

function StatusEffect:SetDuration( time )
	self.Duration = tonumber(time)
end

function StatusEffect:GetDuration()
	return self.Duration
end

function StatusEffect:SetAttacker( entity )
	if self.Attacker == nil and self.FirstAttacker == nil then
		self:SetOriginalAttacker( enity )
	end

	self.Attacker = entity
end

function StatusEffect:GetAttacker()
	return self.Attacker
end

function StatusEffect:SetInflictor( entity )
	self.Inflictor = entity
end

function StatusEffect:GetInflictor()
	return self.Inflictor
end

function StatusEffect:SetWeapon( entity )
	self.Weapon = entity
end

function StatusEffect:GetWeapon()
	return self.Weapon
end

function StatusEffect:SetDamage( number )
	self.Damage = tonumber(number)
end

function StatusEffect:GetDamage()
	return self.Damage
end

function StatusEffect:SetUpgraded( bool )
	self.Upgraded = tobool(bool)
end

function StatusEffect:GetUpgraded()
	return self.Upgraded
end

function StatusEffect:SetOriginalAttacker( entity )
	self.FirstAttacker = entity
end

function StatusEffect:GetOriginalAttacker()
	return self.FirstAttacker
end

// Do modify these

function StatusEffect:Initialize( entity, duration, ... )
	// called once when entity is afflicted with status effect
end

function StatusEffect:Update( entity, duration, ... )
	// called when GiveStatus is run on an entity that is already afflicted with the given status
end

function StatusEffect:Think( entity )
	// called every frame on client and every tick on server while the statuseffect exists
end

function StatusEffect:Tick( entity, subtick )
	// called every tick
	// IMPORTANT: on the client this will cease to call after statusend has elapsed curtime, regardless of if the netmessage for calling statusend has reached the client yet
end

function StatusEffect:OnStatusEnd( entity )
	// called when self:GetEndTime() returns less than CurTime()
end

function StatusEffect:OnRemove( entity )
	// called when the status effect is removed after the effects duration expires
	//  ONLY when the entity is not a dead NPC or NextBot
end

function StatusEffect:StartCommand( entity, cusercmd )
	// This function only exists for players afflicted with a status effect
end

function StatusEffect:SetupMove( entity, cmovedata, cusercmd )
	// This function only exists for players afflicted with a status effect
end

function StatusEffect:FinishMove( entity, cmovedata )
	// This function exists for all entities but CMoveData will only be supplied if the entity is actually a player
end

function StatusEffect:PostInitialize( entity, delta )
	// called the tick after initialization and when the status effect starts thinking, delta is the sub-tick precise time since initialization
end

if CLIENT then
	//-------------------------------------------------------------
	// Default Clientside Functions
	//-------------------------------------------------------------

	// Do modify these

	function StatusEffect:Draw( entity, visibility )
		// called every frame while the entity is within our PVS using PostDrawOpaqueRenderables hook.
		//  Visibility is a float between 0 and 1 of how visible the entity is onscreen from its center mass
	end

	function StatusEffect:CalcView( ply, origin, angles, fov, znear, zfar )
		// functions like the hook version, return to override
	end

	function StatusEffect:RenderScreenspaceEffects( entity )
		// as on tin
	end

	function StatusEffect:OnClientsideRagdoll( entity, ragdoll )
		// only called if the entity dies while afflicted with a status effect
	end

	function StatusEffect:InputMouseApply( entity, cusercmd )
		// This function only exists for players afflicted with a status effect
		//  functions like the hook version, return to override
	end
end

if SERVER then
	//-------------------------------------------------------------
	// Default Serverside Functions
	//-------------------------------------------------------------

	// Do modify these ( as needed )

	StatusEffect.DoAlertSound = false
	StatusEffect.DoFearSound = false
	StatusEffect.DoDeathSound = false
	StatusEffect.DropWeapon = false
	StatusEffect.CollisionIgnoreWorld = true //entity will usually always be touching the world (what else would it be standing on duh)

	function StatusEffect:EntityTakeDamage( entity, damageinfo )
		// return true to block the original EntityTakeDamage hook call ( will also set damage to 0 )
	end

	function StatusEffect:OnEntityKilled( entity, damageinfo )
		// called the same frame the entity takes damage but only after it has already took the damage and been killed
	end

	function StatusEffect:EntityCollide( entity, trace )
		// called anytime another entity enters the afflicted entities collision bounds
	end

	function StatusEffect:OnEntityRagdoll( entity, ragdoll )
		// only called if the entity dies while afflicted with a status effect
	end

	// Modify this if you really need to and know what you are doing
	//  By default the behavior of status effects it to call 'OnStatusEnd' when time is up, and usually they would remove the same frame.
	//  If the status effect happens to kill the entity on end, then for both ragdoll hooks to be called the entity must stay afflicted untill it is removed.
	//  This is why 'OnStatusEnd' and 'OnRemove' are seperate.

	function StatusEffect:ShouldRemove( entity )
		local nLifeState = entity:GetInternalVariable( "m_lifeState" )
		return ( nLifeState == nil or nLifeState == LIFE_ALIVE or entity:IsMarkedForDeletion() ) and !entity:IsFlagSet(FL_TRANSRAGDOLL)
	end

	// dont modify these

	function StatusEffect:SetState( int )
		self.State = tonumber( int )
	end

	function StatusEffect:GetState()
		return self.State or StatusState.ACTIVE
	end

	// Dont modify these, but do make use of them

	StatusEffect.CollisionTrace = {}

	function StatusEffect:Remove( bNoSync )
		WonderWeapons.RemoveStatus( self:GetEntity(), self.StatusEffect, bNoSync )
	end

	function StatusEffect:GetCollisionTrace()
		return self.CollisionTrace
	end

	function StatusEffect:GetPreHullIntersectionCollisionTrace()
		return self.PreIntersectionCollisionTrace or nil
	end

	function StatusEffect:SendHitMarker( attacker, inflictor, entity, damageinfo, trace )
		if not IsValid( entity ) then return end

		if damageinfo == nil and trace == nil then
			return
		end

		if not IsValid( attacker ) or not attacker:IsPlayer() then
			return
		end

		if not IsValid( inflictor ) then
			return
		end

		local owner = inflictor:GetOwner()

		if not IsValid( owner ) or owner ~= attacker then
			if owner.GetActiveWeapon then
				inflictor = owner:GetActiveWeapon()
			else
				return
			end
		end

		if not inflictor.SendHitMarker then
			return
		end

		if ( entity:IsNPC() or entity:IsNextBot() or entity:IsPlayer() ) then
			local hitpos = damageinfo:GetDamagePosition()

			if not trace or not istable( trace ) or table.IsEmpty(trace) then
				trace = { ["Entity"] = entity, ["Hit"] = true, ["HitPos"] = !hitpos:IsZero() and hitpos or entity:WorldSpaceCenter() }
			end

			inflictor:SendHitMarker( attacker, trace, damageinfo )
		end
	end

	//-------------------------------------------------------------
	// Movespeed Helper Functions
	//-------------------------------------------------------------

	local function UpdateSpeedChanges( self, entity )
		local bPassed = true
		
		local currentStatuses = WonderWeapons.GetStatuses( entity )
		
		for effect, status in pairs( currentStatuses ) do
			if not status.SpeedChanged then continue end
			if status == self then continue end

			if status:GetEndTime() > self:GetEndTime() and !self.DontResetSpeed then
				if status.DontResetSpeed then
					status.DontResetSpeed = nil
				end

				bPassed = false

				self.DontResetSpeed = true
			else
				status.DontResetSpeed = true
			end
		end

		if bPassed and self.DontResetSpeed then
			self.DontResetSpeed = nil
		end
	end

	function StatusEffect:SetMoveSpeed( speed )
		local entity = self:GetEntity()
		if not IsValid(entity) then return end

		if nzombies and entity:IsValidZombie() and self.ZombieSlowWalk and entity.SpeedChanged then
			return
		end

		self.SpeedChanged = true

		self.SpeedChangeDelta = 0

		self.DesiredSpeed = speed

		if entity:IsNPC() then
			if not entity.pStoredIdealSpeed then
				entity.pStoredIdealSpeed = entity:GetIdealMoveSpeed()
				entity.pStoredIdealAcceleration = entity:GetIdealMoveAcceleration()
			else
				UpdateSpeedChanges( self, entity )
			end
		end

		if entity:IsNextBot() then
			if not entity.pStoredAcceleration then
				entity.pStoredAcceleration = entity.loco:GetAcceleration()
				entity.pStoredDesiredSpeed = entity.loco:GetDesiredSpeed()
			else
				UpdateSpeedChanges( self, entity )
			end
		end
	end

	function StatusEffect:ModifyMoveSpeed( ratio, time )
		local entity = self:GetEntity()
		if not IsValid(entity) then return end

		if nzombies and entity:IsValidZombie() and self.ZombieSlowWalk and entity.SpeedChanged then
			return
		end

		self.SpeedChanged = true
		self.SpeedChangeRatio = ratio
		self.SpeedChangeDelta = time

		if entity:IsNPC() then
			if not entity.pStoredIdealSpeed then
				entity.pStoredIdealSpeed = entity:GetIdealMoveSpeed()
				entity.pStoredIdealAcceleration = entity:GetIdealMoveAcceleration()
			else
				UpdateSpeedChanges( self, entity )
			end

			self.DesiredSpeed = entity.pStoredIdealSpeed * self.SpeedChangeRatio
		end

		if entity:IsNextBot() then
			if not entity.pStoredAcceleration then
				entity.pStoredAcceleration = entity.loco:GetAcceleration()
				entity.pStoredDesiredSpeed = entity.loco:GetDesiredSpeed()
			else
				UpdateSpeedChanges( self, entity )
			end

			self.DesiredAcceleration = entity.pStoredAcceleration * self.SpeedChangeRatio
			self.DesiredSpeed = entity.pStoredDesiredSpeed * self.SpeedChangeRatio
		end
	end

	function StatusEffect:ResetMoveSpeed()
		local entity = self:GetEntity()
		if not IsValid(entity) then return end

		self.SpeedChanged = nil
		self.SpeedChangeRatio = nil
		self.SpeedChangeDelta = nil

		self.DesiredSpeed = nil
		self.DesiredAcceleration = nil

		if entity.pStoredPlaybackRate and !self.DontResetPlaybackRate then
			entity:SetPlaybackRate( entity.pStoredPlaybackRate )

			entity.pStoredPlaybackRate = nil
		end

		if self.DontResetSpeed then return end

		if entity:IsNPC() and entity.pStoredIdealSpeed then
			entity:SetMoveVelocity( entity:GetMoveVelocity() * entity.pStoredIdealSpeed )

			entity.pStoredIdealSpeed = nil
		end

		if entity:IsNextBot() and entity.pStoredAcceleration then
			entity.loco:SetAcceleration( entity.pStoredAcceleration )
			entity.loco:SetDesiredSpeed( entity.pStoredDesiredSpeed )

			entity.pStoredAcceleration = nil
			entity.pStoredDesiredSpeed = nil
		end
	end

	//-------------------------------------------------------------
	// CollisionGroup Helper Functions
	//-------------------------------------------------------------

	local function UpdateCollisionChanges( self, entity )
		local bPassed = true
		
		local currentStatuses = WonderWeapons.GetStatuses( entity )
		
		for effect, status in RandomPairs(currentStatuses) do
			if not status.CollisionGroupChanged then continue end
			if status == self then continue end

			if status:GetEndTime() > self:GetEndTime() and ( !self.DontResetCollisionGroup or !self.StoredCollisionGroup ) then
				if status.DontResetCollisionGroup then
					status.DontResetCollisionGroup = nil
				end

				bPassed = false

				if status.CollisionGroupOverride ~= self.CollisionGroupOverride then
					self.StoredCollisionGroup = status.CollisionGroupOverride
				else
					self.DontResetCollisionGroup = true
				end
			else
				status.DontResetCollisionGroup = true
			end
		end

		if bPassed and self.DontResetCollisionGroup then
			self.DontResetCollisionGroup = nil
		end
	end

	function StatusEffect:ModifyCollisionGroup()
		local entity = self:GetEntity()
		if not IsValid(entity) then return end

		self.CollisionGroupChanged = true

		if not entity.pStoredCollisionGroup then
			entity.pStoredCollisionGroup = entity:GetCollisionGroup()
		else
			UpdateCollisionChanges( self, entity )
		end

		entity:SetCollisionGroup( self.CollisionGroupOverride )
	end

	function StatusEffect:ResetCollisionGroup()
		local entity = self:GetEntity()
		if not IsValid(entity) then return end

		if not entity.pStoredCollisionGroup then return end

		self.CollisionGroupChanged = nil

		if self.DontResetCollisionGroup then return end

		entity:SetCollisionGroup( entity.pStoredCollisionGroup )
		entity.pStoredCollisionGroup = nil
	end

	//-------------------------------------------------------------
	// ModelScale Helper Functions
	//-------------------------------------------------------------

	local function UpdateModelScaleChanges( self, entity )
		local bPassed = true

		local currentStatuses = WonderWeapons.GetStatuses( entity )

		for effect, status in RandomPairs(currentStatuses) do
			if not status.ModelScaleChanged then continue end
			if status == self then continue end

			if status:GetEndTime() > self:GetEndTime() and ( !self.DontResetModelScale or !self.StoredModelScale ) then
				if status.DontResetModelScale then
					status.DontResetModelScale = nil
				end

				bPassed = false

				if status.ModelScale ~= self.ModelScale then
					self.StoredModelScale = status.ModelScale
				else
					self.DontResetModelScale = true
				end
			else
				status.DontResetModelScale = true
			end
		end

		if bPassed and self.DontResetModelScale then
			self.DontResetModelScale = nil
		end
	end

	function StatusEffect:ModifyModelScale()
		local entity = self:GetEntity()
		if not IsValid(entity) then return end

		self.ModelScaleChanged = true

		if not entity.pStoredModelScale then
			entity.pStoredModelScale = entity:GetModelScale()
			entity.pStoredModelScaleDelta = self.ModelScaleDeltaTime or 0
		else
			UpdateModelScaleChanges( self, entity )
		end

		entity:SetModelScale( self.ModelScale, self.ModelScaleDeltaTime or 0 )
	end

	function StatusEffect:ResetModelScale()
		local entity = self:GetEntity()
		if not IsValid(entity) then return end

		if not entity.pStoredModelScale then return end

		self.ModelScaleChanged = nil

		if self.DontResetModelScale then return end

		entity:SetModelScale( entity.pStoredModelScale, entity.pStoredModelScaleDelta or 0 )
		entity.pStoredModelScale = nil
		entity.pStoredModelScaleDelta = nil
	end

	//-------------------------------------------------------------
	// ViewOffset Helper Functions
	//-------------------------------------------------------------

	local function UpdateViewHeightChanges( self, entity )
		local bPassed = true

		local currentStatuses = WonderWeapons.GetStatuses( entity )
		
		for effect, status in RandomPairs(currentStatuses) do
			if not status.DealWithTheDevil then continue end
			if status == self then continue end

			if status:GetEndTime() > self:GetEndTime() and !self.DontResetViewHeight then
				if status.DontResetViewHeight then
					status.DontResetViewHeight = nil
				end

				bPassed = false

				self.DontResetViewHeight = true
			else
				status.DontResetViewHeight = true
			end
		end

		if bPassed and self.DontResetViewHeight then
			self.DontResetViewHeight = nil
		end
	end

	function StatusEffect:ModifyViewHeight()
		local entity = self:GetEntity()
		if not IsValid(entity) then return end

		self.DealWithTheDevil = true

		if not entity.pStoredViewHeight then
			entity.pStoredViewHeight = entity:GetViewOffset()
		else
			UpdateViewHeightChanges( self, entity )
		end

		entity:SetViewOffset( entity:GetViewOffsetDucked() )
	end

	function StatusEffect:ResetViewHeight()
		local entity = self:GetEntity()
		if not IsValid(entity) then return end

		if not entity.pStoredViewHeight then return end

		self.DealWithTheDevil = nil

		if self.DontResetViewHeight then return end

		local vecView = entity.pStoredViewHeight
		entity:SetViewOffset( vecView )

		local NoHope = "LocalPlayer():SetViewOffset(Vector("..vecView[1]..", "..vecView[2]..", "..vecView[3].."))"
		entity:SendLua(NoHope)

		entity.pStoredViewHeight = nil
	end

	//-------------------------------------------------------------
	// PlaybackRate Helper Functions
	//-------------------------------------------------------------

	local function UpdatePlaybackChanges( self, entity )
		local bPassed = true

		local currentStatuses = WonderWeapons.GetStatuses( entity )

		for effect, status in pairs(currentStatuses) do
			if not status.PlaybackRateModified then continue end
			if status == self then continue end

			if status:GetEndTime() > self:GetEndTime() then
				if status.DontResetPlaybackRate then
					status.DontResetPlaybackRate = nil
				end

				bPassed = false

				self.DontResetPlaybackRate = true
			else
				status.DontResetPlaybackRate = true
			end
		end

		if bPassed and self.DontResetPlaybackRate then
			self.DontResetPlaybackRate = nil
		end
	end

	function StatusEffect:ModifyPlaybackRate()
		local entity = self:GetEntity()
		if not IsValid(entity) then return end

		if not self.DesiredPlaybackRate then return end

		if not entity.pStoredPlaybackRate then
			entity.pStoredPlaybackRate = entity:GetPlaybackRate()
		else
			UpdatePlaybackChanges( self, entity )
		end

		entity:SetPlaybackRate( self.DesiredPlaybackRate )

		entity.StatusEffectPlaybackRateModified = true
	end

	function StatusEffect:ResetPlaybackRate()
		local entity = self:GetEntity()
		if not IsValid(entity) then return end

		if self.DontResetPlaybackRate then return end

		self.PlaybackRateModified = nil

		entity.StatusEffectPlaybackRateModified = nil

		if entity.pStoredPlaybackRate and !self.DontResetPlaybackRate then
			entity:SetPlaybackRate( entity.pStoredPlaybackRate )

			entity.pStoredPlaybackRate = nil
		end
	end

	//-------------------------------------------------------------
	// Entity Freeze Helper Functions
	//-------------------------------------------------------------

	function StatusEffect:FreezeEntity()
		local entity = self:GetEntity()
		if not IsValid( entity ) then return end

		self.SpeedChanged = true
		entity.StatusEffectFrozen = true

		if entity:IsNPC() then
			if not entity.pStoredIdealSpeed then
				entity.pStoredIdealSpeed = entity:GetIdealMoveSpeed()
				entity.pStoredIdealAcceleration = entity:GetIdealMoveAcceleration()
			else
				UpdateSpeedChanges( self, entity )
			end

			entity:StopMoving()

			entity:SetVelocity(vector_origin)
			entity:SetMoveVelocity(vector_origin)

			entity:SetCondition(COND.NPC_FREEZE)

			entity:ClearEnemyMemory(entity:GetEnemy())

			if self.DoFirePanic then
				entity:Ignite(0)
				//entity:AddFlags( FL_ONFIRE )
				entity:Fire( "HitByBugbait", math.Rand( 0, 2 ) )

				timer.Simple( engine.TickInterval(), function()
					if not IsValid(entity) then return end

					entity:RemoveFlags( FL_ONFIRE )
				end )
			end
		end

		if entity:IsNextBot() then
			if not entity.pStoredAcceleration then
				entity.pStoredAcceleration = entity.loco:GetAcceleration()
				entity.pStoredDesiredSpeed = entity.loco:GetDesiredSpeed()
			else
				UpdateSpeedChanges( self, entity )
			end

			entity.loco:SetVelocity(vector_origin)
			entity.loco:SetAcceleration(0)
			entity.loco:SetDesiredSpeed(0)
		end

		if entity:IsPlayer() then
			entity:Freeze( true )
		end
	end

	function StatusEffect:UnfreezeEntity()
		local entity = self:GetEntity()
		if not IsValid( entity ) then return end

		entity.StatusEffectFrozen = nil

		if entity:IsNextBot() and entity.pStoredBehaveThread then
			entity.BehaveThread = entity.pStoredBehaveThread

			entity.pStoredBehaveThread = nil
		end

		if self.DoFirePanic then
			entity:Extinguish()
		end

		if entity:IsNPC() then
			entity:SetCondition(COND.NPC_UNFREEZE)
		end

		if entity:IsPlayer() then
			entity:Freeze(false)
		end

		self:ResetMoveSpeed()
	end

	//-------------------------------------------------------------
	// Block Attacking Functions
	//-------------------------------------------------------------

	local function UpdateBlockAttackChanges( self, entity )
		local bPassed = true
		
		local currentStatuses = WonderWeapons.GetStatuses( entity )
		
		for effect, status in pairs(currentStatuses) do
			if not status.BlockAttack then continue end
			if status == self then continue end

			if status:GetEndTime() > self:GetEndTime() and !self.DontResetBlockAttack then
				if status.DontResetBlockAttack then
					status.DontResetBlockAttack = nil
				end

				bPassed = false

				self.DontResetBlockAttack = true
			else
				status.DontResetBlockAttack = true
			end
		end

		if bPassed and self.DontResetBlockAttack then
			self.DontResetBlockAttack = nil
		end
	end

	function StatusEffect:EntityBlockAttack()
		local entity = self:GetEntity()
		if not IsValid( entity ) then return end

		if not self.BlockAttack then return end

		if entity:IsNPC() then
			if not entity.StatusEffectBlockAttack then
				entity.StatusEffectBlockAttack = true
			else
				UpdateBlockAttackChanges( self, entity )
			end

			local bitCapabilties = entity:CapabilitiesGet()

			if bit.band( bitCapabilties, CAP_USE_WEAPONS ) then
				self.EntityUseWeapons = true

				entity:CapabilitiesRemove( CAP_USE_WEAPONS )
			end

			if bit.band( bitCapabilties, CAP_WEAPON_RANGE_ATTACK2 ) then
				self.EntityUseGrenades = true

				entity:CapabilitiesRemove( CAP_WEAPON_RANGE_ATTACK2 )
			end

			entity:SetCondition( COND.WEAPON_BLOCKED_BY_FRIEND )
		end

		entity.StatusEffectBlockAttack = true

		if entity:IsNextBot() then
			if nzombies then
				if entity:IsValidZombie() then
					entity:SetBlockAttack( true )
				end
			else
				/*if not entity.pStoredBehaveThread then
					entity.pStoredBehaveThread = entity.BehaveThread
				else
					UpdateBlockAttackChanges( self, entity )
				end

				local flDuration = self:GetDuration()
				local strStatus = self.StatusEffect

				entity.BehaveThread = coroutine.create( function()
					coroutine.wait( flDuration )

					local mStatus = WonderWeapons.GetStatus( entity, strStatus )
					if mStatus and mStatus.DontResetBlockAttack then
						return
					end

					entity.BehaveThread = entity.pStoredBehaveThread
				end )*/
			end
		end

		// Player handled separately
	end

	function StatusEffect:ResetBlockAttack()
		if not nzombies then return end

		local entity = self:GetEntity()
		if not IsValid(entity) then return end

		if self.DontResetBlockAttack then return end

		if entity:IsNPC() and entity.StatusEffectBlockAttack then
			if self.EntityUseWeapons then
				entity:CapabilitiesAdd( CAP_USE_WEAPONS )
			end

			if self.EntityUseGrenades then
				entity:CapabilitiesAdd( CAP_WEAPON_RANGE_ATTACK2 )
			end

			entity:ClearCondition( COND.WEAPON_BLOCKED_BY_FRIEND )
		end

		if entity:IsNextBot() and entity.pStoredBehaveThread then
			entity.BehaveThread = entity.pStoredBehaveThread
		end

		entity.StatusEffectBlockAttack = nil
	end

	//-------------------------------------------------------------
	// Player NoTarget Helper Functions
	//-------------------------------------------------------------

	local function UpdateNoTargetChanges( self, entity )
		local bPassed = true
		
		local currentStatuses = WonderWeapons.GetStatuses( entity )
		
		for effect, status in pairs(currentStatuses) do
			if not status.EntityNoTarget then continue end
			if status == self then continue end

			if status:GetEndTime() > self:GetEndTime() and !self.DontResetNoTarget then
				if status.DontResetNoTarget then
					status.DontResetNoTarget = nil
				end

				bPassed = false

				self.DontResetNoTarget = true
			else
				status.DontResetNoTarget = true
			end
		end

		if bPassed and self.DontResetNoTarget then
			self.DontResetNoTarget = nil
		end
	end

	function StatusEffect:NoTargetPlayer( self )
		if not nzombies then return end

		local entity = self:GetEntity()
		if not IsValid(entity) then return end

		if not WonderWeapons.CanNoTargetPlayer( entity ) then
			local status = self.StatusEffect

			local repeatTimer = "WonderWeapon.StatusEffect.NoTarget." .. status .. "." .. entity:EntIndex()

			if timer.Exists( repeatTimer ) then
				timer.Remove( repeatTimer )
			end

			timer.Create( repeatTimer, 0, 0, function()
				if not IsValid( entity ) or not entity:Alive() then
					timer.Remove( repeatTimer )
					return
				end

				if not WonderWeapons.HasStatus( entity, status ) then
					timer.Remove( repeatTimer )
					return
				end


				if WonderWeapons.CanNoTargetPlayer( entity ) then
					self:NoTargetPlayer()

					timer.Remove( repeatTimer )
				end
			end )

			return
		end

		self.EntityNoTarget = true

		if not entity.StatusEffectNoTarget then
			entity.StatusEffectNoTarget = true

			if entity.SetTargetPriority then
				entity:SetTargetPriority( TARGET_PRIORITY_NONE )
			end

			entity:SetNoTarget( true )
		else
			UpdateNoTargetChanges( self, entity )
		end
	end

	function StatusEffect:ResetNoTarget()
		local entity = self:GetEntity()
		if not IsValid(entity) then return end

		if self.DontResetNoTarget then return end

		self.EntityNoTarget = nil

		if entity.StatusEffectNoTarget then
			if entity.SetTargetPriority then
				entity:SetTargetPriority( TARGET_PRIORITY_PLAYER )
			end

			entity:SetNoTarget( false )
		end
	end

	//-------------------------------------------------------------
	// Zombie Helper Functions
	//-------------------------------------------------------------

	local function UpdateSlowChanges( self, entity )
		local bPassed = true
		
		local currentStatuses = WonderWeapons.GetStatuses( entity )
		
		for effect, status in pairs(currentStatuses) do
			if not status.ZombieSlowed then continue end
			if status == self then continue end

			if status:GetEndTime() > self:GetEndTime() and !self.DontResetSlow then
				if status.DontResetSlow then
					status.DontResetSlow = nil
				end

				bPassed = false

				self.DontResetSlow = true
			else
				status.DontResetSlow = true
			end
		end

		if bPassed and self.DontResetSlow then
			self.DontResetSlow = nil
		end
	end

	function StatusEffect:SlowZombie( self )
		if not nzombies then return end

		local entity = self:GetEntity()
		if not IsValid(entity) then return end

		entity.StatusEffectSlowed = true

		self.ZombieSlowed = true

		if entity:IsValidZombie() and entity.SpeedChanged and entity.DesiredSpeed then
			if not entity.pStoredSlow then
				entity.pStoredSlow = true
			else
				UpdateSlowChanges( self, entity )
			end

			entity:SetRunSpeed( 10 )
			entity:SpeedChanged()
		end
	end

	function StatusEffect:ResetZombieSlow()
		if not nzombies then return end

		local entity = self:GetEntity()
		if not IsValid(entity) then return end

		if self.DontResetSlow then return end

		entity.StatusEffectSlowed = nil

		if entity.pStoredSlow and entity.DesiredSpeed then
			entity:SetRunSpeed( entity.DesiredSpeed )
			entity:SpeedChanged()

			entity.pStoredSlow = nil
		end
	end

	//-------------------------------------------------------------
	// Networking Functions
	//-------------------------------------------------------------

	util.AddNetworkString( "TFA.BO3WW.FOX.StatusEffect.Sync" )
	util.AddNetworkString( "TFA.BO3WW.FOX.StatusEffect.SyncFix" )
	util.AddNetworkString( "TFA.BO3WW.FOX.StatusEffect.SyncRemove" )
	util.AddNetworkString( "TFA.BO3WW.FOX.StatusEffect.SyncEnd" )

	local status_queue = {}

	function StatusEffect:Sync( entity, duration, varargs )
		if not IsValid( entity ) then return end
		if not self.StatusEffect or not isstring( self.StatusEffect ) then return end

		net.Start( "TFA.BO3WW.FOX.StatusEffect.Sync" )
			net.WriteInt( entity:EntIndex(), MAX_EDICT_BITS )
			net.WriteUInt( self.Index, 32 ) // Status Effect Index
			net.WriteString( self.StatusEffect ) // Status Effect Classname
			net.WriteFloat( CurTime() ) // StartTime / Updated EndTime
			net.WriteFloat( duration ) // Duration
			net.WriteTable( varargs, true ) // Custom variables as sequential table
		net.Broadcast()

		status_queue[ entity ] = true

		//CurrentUpdates[ self:GetIndex() ] = { time = CurTime(), duration = duration, varargs = varargs }
	end

	function StatusEffect:SyncRemove()
		if not self.StatusEffect or not isstring( self.StatusEffect ) then return end

		net.Start( "TFA.BO3WW.FOX.StatusEffect.SyncRemove" )
			net.WriteUInt( self.Index, 32 )
		net.Broadcast()
	end

	function StatusEffect:SyncEnd()
		net.Start( "TFA.BO3WW.FOX.StatusEffect.SyncEnd" )
			net.WriteUInt( self.Index, 32 )
		net.Broadcast()
	end

	hook.Add( "EntityRemoved", "TFA.BO3WW.FOX.StatusEffect.EntityRemoved", function( entity )
		if status_queue[ entity ] then
			net.Start("TFA.BO3WW.FOX.StatusEffect.SyncFix")
				net.WriteInt( entity:EntIndex(), MAX_EDICT_BITS )
			net.Broadcast()

			status_queue[ entity ] = nil
		end
	end )
end

StatusEffect.__index = StatusEffect

if CLIENT then
	local cl_screenvisuals = GetConVar("cl_tfa_bo3ww_screen_visuals")

	local PixVis = {}

	//-------------------------------------------------------------
	// Clientside Functions
	//-------------------------------------------------------------

	function WonderWeapons.GetStatuses( entity )
		if not IsValid( entity ) then return end
		if not ActiveStatusEffects[ entity:EntIndex() ] then
			ActiveStatusEffects[ entity:EntIndex() ] = {}
		end

		return ActiveStatusEffects[ entity:EntIndex() ]
	end

	function WonderWeapons.GetStatus( entity, effect )
		if not IsValid( entity ) then return end

		local currentStatuses = WonderWeapons.GetStatuses( entity )
		return currentStatuses[ effect ] or nil
	end

	function WonderWeapons.HasStatus( entity, effect )
		if not IsValid( entity ) then return end

		local currentStatuses = WonderWeapons.GetStatuses( entity )
		return tobool( currentStatuses[ effect ] )
	end

	function WonderWeapons.GetStatusByIndex( index )
		if not index or not isnumber( index ) or index < 1 then
			return
		end

		return StatusEffectIndex[ index ] or nil
	end

	//-------------------------------------------------------------
	// Main Functions
	//-------------------------------------------------------------

	local function RemoveStatus( entity, effect )
		if not IsValid( entity ) then return end

		local mStatus = WonderWeapons.GetStatuses( entity )[ effect ]
		if mStatus then
			local index = mStatus:GetIndex()

			mStatus:OnRemove( entity )

			StatusEffectIndex[ index ] = nil
		end

		WonderWeapons.StopDrawParticle( entity, tostring(effect..entity:EntIndex()), false )

		PixVis[ entity ] = nil
		ActiveStatusEffects[ entity:EntIndex() ][ effect ] = nil

		if next( ActiveStatusEffects[ entity:EntIndex() ] ) == nil then
			ActiveStatusEffects[ entity:EntIndex() ] = nil
		end
	end

	local function GiveStatus( entity, index, effect, start, duration, ... )
		if not IsValid( entity ) then return end

		if not index or not isnumber( index ) then
			return
		end

		local effectData = WonderWeapons.StatusEffectData( effect )
		if not effectData then return end

		local varargs = table.Pack( ... )

		local currentStatuses = WonderWeapons.GetStatuses( entity )
		if currentStatuses[ effect ] then
			local mStatus = currentStatuses[ effect ]

			mStatus:SetDuration( duration )
			mStatus:SetEndTime( start + duration )

			mStatus:Update( entity, duration, unpack(varargs) )

			return mStatus
		end

		local data = table.Copy( effectData )
		data.Index = index
		data.StatusEffect = effect
		data.StatusEffectData = effectData

		setmetatable( data, StatusEffect )

		currentStatuses[ effect ] = data

		local nMaxMinusOne = ( 2^31 - 1 ) - 1
		local nNextIndex = 1 + CurrentIndex

		if ( nNextIndex >= nMaxMinusOne ) then
			nNextIndex = 1 // Justin Case
		end

		CurrentIndex = nNextIndex //this is unused but ill keep it for now for debugging

		local mStatus = currentStatuses[ effect ]
		mStatus:SetIndex( index )
		mStatus:SetEntity( entity )
		mStatus:SetDuration( duration )
		mStatus:SetStartTime( start )
		mStatus:SetEndTime( start + duration )

		entity:CallOnRemove( "WonderWeapon.StatusEffects.Removed."..effect.."."..entity:EntIndex(), function( removed )
			local currentStatuses = WonderWeapons.GetStatuses( removed )

			for effect, status in pairs( currentStatuses ) do
				RemoveStatus( removed, effect )
			end
		end )

		PixVis[ entity ] = util.GetPixelVisibleHandle()

		mStatus.PixelVisHandle = PixVis[ entity ]

		mStatus.ChestAttachment = WonderWeapons.GetChestAttachment( entity )
		mStatus.HeadAttachment = WonderWeapons.GetHeadAttachment( entity )
		mStatus.EyesAttachment = WonderWeapons.GetEyeAttachment( entity )
		mStatus.MouthAttachment = WonderWeapons.GetMouthAttachment( entity )

		local eyeR, eyeL = WonderWeapons.GetEyesAttachment( entity )
		mStatus.RightEyeAttachment = eyeR
		mStatus.LeftEyeAttachment = eyeL

		local handR, handL = WonderWeapons.GetHandsAttachment( entity )
		mStatus.RightHandAttachment = handR
		mStatus.LeftHandAttachment = handL

		mStatus.HasInitialized = true
		mStatus:Initialize( entity, duration, unpack(varargs) )

		StatusEffectIndex[ index ] = mStatus

		return mStatus
	end

	// Clientside Hooks

	hook.Add( "CreateMove", "TFA.BO3WW.FOX.StatusEffect.Input", function( cusercmd )
		local ply = LocalPlayer()
		if not IsValid( ply ) then return end

		if ActiveStatusEffects[ ply:EntIndex() ] then
			for effect, mStatus in pairs( ActiveStatusEffects[ ply:EntIndex() ] ) do
				if not mStatus or not mStatus.BlockPlayerAttack then continue end

				cusercmd:SetButtons( bit.band( cusercmd:GetButtons(), bit.bnot( bit.bor( IN_ATTACK, IN_ATTACK2 ) ) ) )

				if cusercmd:GetImpulse() == TFA.BASH_IMPULSE then
					cusercmd:SetImpulse( 0 )
				end
			end
		end
	end )

	hook.Add( "CalcView", "TFA.BO3WW.FOX.StatusEffect.CalcView", function( ply, origin, angles, fov, znear, zfar )
		if ActiveStatusEffects[ ply:EntIndex() ] then
			for effect, mStatus in pairs( ActiveStatusEffects[ ply:EntIndex() ] ) do
				local hookCalcView = mStatus:CalcView( ply, origin, angles, fov, znear, zfar )
				if hookCalcView ~= nil and istable( hookCalcView ) then
					return hookCalcView
				end
			end
		end
	end )

	hook.Add( "InputMouseApply", "TFA.BO3WW.FOX.StatusEffect.InputMouseApply", function( cusercmd, x, y, angle )
		local ply = LocalPlayer()
		if not IsValid( ply ) then return end

		local currentStatuses = WonderWeapons.GetStatuses( ply )

		for effect, mStatus in pairs( currentStatuses ) do
			local bBlockHook = mStatus:InputMouseApply( ply, cusercmd, x, y, angle )
			if tobool( bBlockHook ) then
				return true
			end
		end
	end )

	hook.Add( "Think", "TFA.BO3WW.FOX.StatusEffect.Think", function()
		for eid, effectTable in pairs( ActiveStatusEffects ) do
			local entity = Entity( eid )
			if not IsValid( entity ) or entity:IsDormant() then continue end

			for effect, mStatus in pairs( effectTable ) do
				if not mStatus then continue end

				//if ( mStatus:GetEndTime() > CurTime() ) then
					mStatus:Think( entity )
				//end
			end
		end
	end )

	hook.Add( "Tick", "TFA.BO3WW.FOX.StatusEffect.Tick", function()
		for eid, effectTable in pairs( ActiveStatusEffects ) do
			local entity = Entity( eid )
			if not IsValid( entity ) or entity:IsDormant() then continue end

			for effect, mStatus in pairs( effectTable ) do
				if not mStatus then continue end

				if ( mStatus:GetEndTime() > CurTime() ) then
					mStatus:Tick( entity, SysTime() )
				end
			end
		end
	end )

	hook.Add( "PreDrawEffects", "TFA.BO3WW.FOX.StatusEffect.Draw", function()
		for eid, effectTable in pairs( ActiveStatusEffects ) do
			local entity = Entity( eid )
			if not IsValid( entity ) then continue end

			for effect, mStatus in pairs( effectTable ) do
				if not mStatus or mStatus.NoDraw then continue end

				local flWidth = 16
				if mStatus.HullMaxs then
					flWidth = math.max( mStatus.HullMaxs[1] + mStatus.HullMaxs[2], flWidth )
				end

				// Calculate visibility of entity and pass that along (0 = not visible, 1 = fully visible)

				local bIsCharacter = ( entity:IsNPC() or entity:IsPlayer() or entity:IsNextBot() ) and entity.EyePos

				local flVisibility = util.PixelVisible( bIsCharacter and entity:EyePos() or ( entity:GetPos() + entity:OBBCenter() ), flWidth, PixVis[ entity ] )

				mStatus:Draw( entity, flVisibility )
			end
		end
	end )

	hook.Add( "RenderScreenspaceEffects", "TFA.BO3WW.FOX.StatusEffect.Visuals",function()
		local ply = LocalPlayer()
		if not IsValid( ply ) then return end

		if cl_screenvisuals ~= nil and (cl_screenvisuals:GetInt() ~= 1 and cl_screenvisuals:GetInt() ~= 4) then
			return
		end

		if ActiveStatusEffects[ ply:EntIndex() ] then
			for effect, mStatus in pairs( ActiveStatusEffects[ ply:EntIndex() ] ) do
				if not mStatus then continue end

				mStatus:RenderScreenspaceEffects( ply )

				local particleName = mStatus.ScreenSpaceEffect
				if particleName and isstring( particleName ) then
					ply:AddDrawCallParticle( particleName, PATTACH_POINT_FOLLOW, 1, ply:Alive(), tostring( effect..ply:EntIndex() ) )
				end

				local materialName = mStatus.ScreenSpaceMaterial
				if materialName and isstring( materialName ) then
					DrawMaterialOverlay( materialName, mStatus.ScreenSpaceMaterialRefractAmount or -0.1 )
				end
			end
		end
	end )

	hook.Add( "CreateClientsideRagdoll", "TFA.BO3WW.FOX.StatusEffect.ClientRagdoll", function( entity, ragdoll )
		if ActiveStatusEffects[ entity:EntIndex() ] then
			if entity.StatusEffectDamage then return end

			for effect, mStatus in pairs( ActiveStatusEffects[ entity:EntIndex() ] ) do
				mStatus:OnClientsideRagdoll( entity, ragdoll )
			end
		end
	end )

	// Example sync system from gmod wiki

	local status_queue_cl = {}

	// insert status effect into queue
	local function ReceiveSync( length )
		local ply = LocalPlayer()
		if not IsValid( ply ) then return end

		local entity = net.ReadInt( MAX_EDICT_BITS )
		local index = net.ReadUInt( 32 )
		local effect = net.ReadString()
		local start = net.ReadFloat()
		local duration = net.ReadFloat()
		local varargs = net.ReadTable( true )

		if !status_queue_cl[ ply ] then
			status_queue_cl[ ply ] = {}
		end

		table.insert( status_queue_cl[ ply ], { entity = entity, effect = effect, start = start, duration = duration, varargs = varargs, index = index } )
	end

	// remove status effect from queue if entity is removed before entering our pvs
	local function ReceiveSyncFix(length)
		local ply = LocalPlayer()
		if not IsValid( ply ) then return end

		local index = net.ReadInt( MAX_EDICT_BITS )

		if !status_queue_cl[ ply ] then return end

		for k, data in pairs( status_queue_cl[ ply ] ) do
			if data.entity and data.entity == index then
				status_queue_cl[ ply ][ k ] = nil
				if table.IsEmpty( status_queue_cl[ ply ] ) then
					status_queue_cl[ ply ] = nil
				end

				break
			end
		end
	end

	// status effect removed sync
	local function ReceiveSyncRemove( length )
		local index = net.ReadUInt( 32 )

		local mStatus = StatusEffectIndex[ index ]
		if mStatus then
			RemoveStatus( mStatus.Parent, mStatus.StatusEffect )
		end
	end

	// status effect duration elapsed sync
	local function ReceiveSyncEnd( length )
		local index = net.ReadUInt( 32 )

		local mStatus = StatusEffectIndex[ index ]
		if mStatus then
			mStatus:OnStatusEnd( mStatus.Parent )
		end
	end

	hook.Add( "Think", "TFA.BO3WW.FOX.StatusEffect.Sync", function()
		local ply = LocalPlayer()
		if not IsValid( ply ) then return end

		if status_queue_cl[ ply ] then
			for k, data in pairs(status_queue_cl[ ply ]) do
				local entindex = data.entity
				local index = data.index
				local effect = data.effect
				local start = data.start
				local duration = data.duration
				local varargs = data.varargs

				local entity = Entity( entindex )
				if IsValid( entity ) then
					GiveStatus( entity, index, effect, start, duration, unpack(varargs) )

					status_queue_cl[ ply ][ k ] = nil

					if table.IsEmpty( status_queue_cl[ ply ] ) then
						status_queue_cl[ ply ] = nil
					end

					break
				end
			end
		end
	end )

	net.Receive( "TFA.BO3WW.FOX.StatusEffect.Sync", ReceiveSync )
	net.Receive( "TFA.BO3WW.FOX.StatusEffect.SyncFix", ReceiveSyncFix )
	net.Receive( "TFA.BO3WW.FOX.StatusEffect.SyncEnd", ReceiveSyncEnd )
	net.Receive( "TFA.BO3WW.FOX.StatusEffect.SyncRemove", ReceiveSyncRemove )
end
