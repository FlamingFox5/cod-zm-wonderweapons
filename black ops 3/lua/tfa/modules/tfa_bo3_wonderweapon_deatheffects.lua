local nzombies = engine.ActiveGamemode() == "nzombies"

//-------------------------------------------------------------
// Globals
//-------------------------------------------------------------

local WonderWeapons = TFA.WonderWeapon

WonderWeapons.DeathEffects = WonderWeapons.DeathEffects or {}

local DeathEffects = WonderWeapons.DeathEffects

// Table of Entities with each Key being the entity and its Value being a table of its active Death Effects

DeathEffects.Entities = DeathEffects.Entities or {}

local ActiveDeathEffects = DeathEffects.Entities

// Table used to keep track of and give all Status Effects a unique index

DeathEffects.IndexCount = DeathEffects.IndexCount or 0

local CurrentIndex = DeathEffects.IndexCount

// Table of Death Effect Objects by its Index isntead of being tied to the parent Entity

DeathEffects.Index = DeathEffects.Index or {}

local DeathEffectIndex = DeathEffects.Index

// Death Effect Type Enumerations (bit)

DeathEffects.Types = {}

local EffectType = DeathEffects.Types

EffectType.ON_DEATH = 1
EffectType.ON_RAGDOLL = 2

// Main Table Thingy
local DeathEffect = {}

// Use this to access the main table and make your own DeathEffect:MyCustomFunction()
RegisterMetaTable("WWDeathEffect", DeathEffect)

DeathEffect.StartTime = 0
DeathEffect.EndTime = 0
DeathEffect.Duration = 0
DeathEffect.Index = 0
DeathEffect.VarArgs = {}

// Dont modify these ( ever )

function DeathEffect:SetEntity( entity )
	self.Parent = entity
end

function DeathEffect:GetEntity()
	return self.Parent
end

function DeathEffect:SetIndex( int )
	self.Index = tonumber( int )
end

function DeathEffect:GetIndex()
	return self.Index or 0
end

function DeathEffect:SetInputData( varargs )
	self.VarArgs = varargs
end

function DeathEffect:GetInputData()
	return self.VarArgs
end

// Dont modify how these work, but do make use of them

function DeathEffect:SetEndTime( time )
	self.EndTime = tonumber(time)
end

function DeathEffect:GetEndTime()
	return self.EndTime
end

function DeathEffect:SetStartTime( time )
	self.StartTime = tonumber(time)
end

function DeathEffect:GetStartTime()
	return self.StartTime
end

function DeathEffect:SetDuration( time )
	self.Duration = tonumber(time)
end

function DeathEffect:GetDuration()
	return self.Duration
end

function DeathEffect:Remove()
	WonderWeapons.RemoveDeathEffect( self:GetEntity(), self.DeathEffect )
end

DeathEffect.__index = DeathEffect

//-------------------------------------------------------------
// Functions
//-------------------------------------------------------------

function WonderWeapons.AddDeathEffect(id, data)
	DeathEffects[id] = data
end

function WonderWeapons.DeathEffectData(id)
	return DeathEffects[id] or nil
end

/* EXAMPLE FUNCTION

// When calling TFA.WonderWeapon.DoDeathEffect( Entity 'entity', String 'effect', Float 'duration', Any '...' ),
//  you can supply up to 64 variables of any var type (that has a net.Write function and isnt a table) after the 'duration' input.
//  They will be passed to the 'OnEntity', 'OnClientRagdoll', 'OnServerRagdoll', and 'OnServerRagdoll_Client' functions

WonderWeapons.AddDeathEffect("Unique_Name", {
	// Type is a bit value
	Type = bit.bor(EffectType.ON_DEATH, EffectType.ON_RAGDOLL),

	// TFA.WonderWeapon.HasDeathEffect will always return true while the death effects ( startTime + duration ) is greater than CurTime()
	//  TFA.WonderWeapon.DeathEffectIsValid( entity, effect ) will return whatever based on the conditions you give it

	IsValid = function( self, entity )
		return timer.Exists( "SomethingIsHappening" .. self:GetIndex() )
	end,

	// Called on the entity that was inflicted with the death effect.
	//  If the entity ragdolls while still inflicted with the death effect,
	//  this function will then be called on its ragdoll (only if the other
	//  ragdoll specific functions do not exists)

	OnEntity = function( self, entity, duration, anyVarArgs ) // CLIENT REALM ONLY
	end,
	
	// Called when the ragdoll of an entity inflicted with the death effect is created with server ragdolls enabled.
	//  This will be called instead of OnClientRagdoll for serverside ragdolls.

	OnServerRagdoll = function( self, ragdoll, entity, duration, anyVarArgs ) // SERVER REALM ONLY
	end,

	// Called when the ragdoll of an entity inflicted with the death effect is created with server ragdolls enabled.
	//  This function is not needed as OnServerRagdoll will still be called regardless of if this exists.
	//  But is still usefull if you need to change how you code the visuals for Serverside ragdolls in the client realm.

	OnServerRagdoll_Client = function( self, ragdoll, entity, duration, anyVarArgs ) // CLIENT REALM ONLY
	end,

	// Called when the ragdoll of an entity inflicted with the death effect is created.
	//  This will be called instead of OnEntity for the entities ragdoll.
	//  Use this if the effect is 'EffectType.ON_RAGDOLL' only, as OnEntity will not be called

	OnClientRagdoll = function( self, ragdoll, entity, duration, anyVarArgs ) // CLIENT REALM ONLY
	end,

	// Called when the status effect start time + duration returns less than CurTime(),
	//  or when the entity / ragdoll gets removed. Destroy will return true when the entity is actually removed.
	//  Use this to cleanup any particle effects that could loop forever or to stop sounds, etc.

	OnRemove = function( self, entity, destroy ) // SHARED
	end,
})
*/

if SERVER then
	util.AddNetworkString("TFA.BO3WW.FOX.DeathEffects.Start")
	util.AddNetworkString("TFA.BO3WW.FOX.DeathEffects.Ragdoll")
	util.AddNetworkString("TFA.BO3WW.FOX.DeathEffects.Cache")
	util.AddNetworkString("TFA.BO3WW.FOX.DeathEffects.Stop")
	util.AddNetworkString("TFA.BO3WW.FOX.DeathEffects.DoRadius")

	function WonderWeapons.GetDeathEffects( entity )
		if not IsValid( entity ) then return end
		if not ActiveDeathEffects[ entity ] then
			ActiveDeathEffects[ entity ] = {}
		end

		return ActiveDeathEffects[ entity ]
	end

	function WonderWeapons.GetDeathEffect( entity, effect )
		if not IsValid( entity ) then return end

		local currentStatuses = WonderWeapons.GetDeathEffects( entity )
		return currentStatuses[ effect ] or nil
	end

	function WonderWeapons.HasDeathEffect( entity, effect )
		if not IsValid( entity ) then return end

		local currentStatuses = WonderWeapons.GetDeathEffects( entity )
		return tobool( currentStatuses[ effect ] )
	end

	function WonderWeapons.RemoveDeathEffect( entity, effect, destroy )
		local currentEffects = WonderWeapons.GetDeathEffects( entity )

		// If no effect is supplied, use first available effect
		if not effect or not isstring( effect) or effect == "" then
			effect = next( currentEffects )
		end

		if not effect or not isstring( effect ) or effect == "" then
			return
		end

		local mDeathFX = currentEffects[ effect ]
		if not mDeathFX then return end

		mDeathFX:OnRemove( entity, destroy )

		net.Start( "TFA.BO3WW.FOX.DeathEffects.Stop" )
			net.WriteEntity( entity )
			net.WriteString( effect )
			net.WriteBool( false )
		net.Broadcast()

		currentEffects[ effect ] = nil

		// active effects table is empty, remove it
		if next( currentEffects ) == nil then
			ActiveDeathEffects[ entity ] = nil
		end
	end

	function WonderWeapons.ClearDeathEffects( entity )
		local currentEffects = WonderWeapons.GetDeathEffects( entity )
		for effect, mDeathFX in pairs(currentEffects) do
			mDeathFX:OnRemove( entity, false )

			net.Start( "TFA.BO3WW.FOX.DeathEffects.Stop" )
				net.WriteEntity(entity)
				net.WriteString(effect)
				net.WriteBool(false)
			net.Broadcast()

			currentEffects[ effect ] = nil
		end

		ActiveDeathEffects[ entity ] = nil
	end

	// MUST BE CALLED BEFORE DOING DAMAGE!!!

	function WonderWeapons.DoDeathEffect( entity, effect, duration, ... )
		if not IsValid( entity ) then return end
		if effect == nil or not isstring( effect ) then return end

		if duration == nil then
			duration = 0
		end

		local effectData = WonderWeapons.DeathEffectData( effect )
		if not effectData then return end

		local currentEffects = WonderWeapons.GetDeathEffects( entity )
		if currentEffects[ effect ] then
			//return
		end

		local varArgs = table.Pack( ... )

		local bDoRagdoll = bit.band( effectData.Type, EffectType.ON_RAGDOLL ) ~= 0
		local bDoDeath = bit.band( effectData.Type, EffectType.ON_DEATH ) ~= 0

		if entity:GetClass() == "prop_ragdoll" and bDoRagdoll and entity.GetRagdollOwner then
			local nMaxMinusOne = ( 2^31 - 1 ) - 1
			local nNextIndex = 1 + CurrentIndex

			if ( nNextIndex >= nMaxMinusOne ) then
				nNextIndex = 1 // Justin Case
			end

			CurrentIndex = nNextIndex

			// Creating status effect table
			local data = table.Copy( effectData )
			data.DeathEffect = effect
			data.DeathEffectData = effectData
			data.Index = CurrentIndex
			data.VarArgs = varArgs

			setmetatable( data, DeathEffect )

			ActiveDeathEffects[ entity ][ effect ] = data

			local mDeathFX = ActiveDeathEffects[ entity ][ effect ]
			mDeathFX:SetEntity( entity )
			mDeathFX:SetIndex( CurrentIndex )
			mDeathFX:SetInputData( varArgs )
			mDeathFX:SetDuration( duration )
			mDeathFX:SetStartTime( CurTime() )
			mDeathFX:SetEndTime( CurTime() + duration )

			DeathEffectIndex[CurrentIndex] = mDeathFX

			local owner = entity:GetRagdollOwner()
			if not IsValid( owner ) then
				owner = entity
			end

			if mDeathFX.OnServerRagdoll then
				mDeathFX:OnServerRagdoll( entity, owner, duration, unpack( varArgs ) )
			end

			if mDeathFX.OnServerRagdoll_Client then
				net.Start( "TFA.BO3WW.FOX.DeathEffects.Ragdoll" )
					net.WriteEntity( entity )
					net.WriteString( effect )
					net.WriteFloat( duration )
					net.WriteTable( varArgs, true )
					net.WriteEntity( owner )
				net.Broadcast()
			end
		else
			local hookName = "WonderWeapon.DeathEffect."..effect.."."..entity:EntIndex()
			hook.Add( "PostEntityTakeDamage", hookName, function( postEntity, postDamageinfo, bTook )
				if not IsValid( entity ) then
					hook.Remove( "PostEntityTakeDamage", hookName )
					return
				end

				if ( postEntity == entity ) then
					hook.Remove( "PostEntityTakeDamage", hookName )

					local bIsLivingBeing = ( postEntity:IsPlayer() or postEntity:IsNextBot() or postEntity:IsNPC() or postEntity:IsVehicle() )

					if ( bTook or entity:GetClass() == "prop_ragdoll" ) and ( postEntity:Health() <= 0 or not bIsLivingBeing ) then
						local nMaxMinusOne = ( 2^31 - 1 ) - 1
						local nNextIndex = 1 + CurrentIndex

						if ( nNextIndex >= nMaxMinusOne ) then
							nNextIndex = 1 // Justin Case
						end

						CurrentIndex = nNextIndex

						// Creating status effect table
						local data = table.Copy( effectData )
						data.DeathEffect = effect
						data.DeathEffectData = effectData
						data.Index = CurrentIndex
						data.VarArgs = varArgs

						setmetatable( data, DeathEffect )

						ActiveDeathEffects[ entity ][ effect ] = data

						local mDeathFX = ActiveDeathEffects[ entity ][ effect ]
						mDeathFX:SetEntity( entity )
						mDeathFX:SetIndex( CurrentIndex )
						mDeathFX:SetInputData( varArgs )
						mDeathFX:SetDuration( duration )
						mDeathFX:SetStartTime( CurTime() )
						mDeathFX:SetEndTime( CurTime() + duration )

						DeathEffectIndex[CurrentIndex] = mDeathFX

						if ( entity:GetClass() == "prop_ragdoll" ) then
							if bDoRagdoll and entity.GetRagdollOwner then
								local owner = entity:GetRagdollOwner()
								if not IsValid( owner ) then
									owner = entity
								end

								if mDeathFX.OnServerRagdoll then
									mDeathFX:OnServerRagdoll( entity, owner, duration, unpack( varArgs ) )
								end

								if mDeathFX.OnServerRagdoll_Client then
									net.Start( "TFA.BO3WW.FOX.DeathEffects.Ragdoll" )
										net.WriteEntity( entity )
										net.WriteString( effect )
										net.WriteFloat( duration )
										net.WriteTable( varArgs, true )
										net.WriteEntity( owner )
									net.Broadcast()
								end
							end
						elseif not bDoDeath then
							net.Start( "TFA.BO3WW.FOX.DeathEffects.Cache" )
								net.WriteEntity( entity )
								net.WriteString( effect )
								net.WriteFloat( duration )
								net.WriteTable( varArgs, true )
							net.Broadcast()
						else
							net.Start( "TFA.BO3WW.FOX.DeathEffects.Start" )
								net.WriteEntity( entity )
								net.WriteString( effect )
								net.WriteFloat( duration )
								net.WriteTable( varArgs, true )
							net.Broadcast()
						end
					end
				end
			end)

			local resetTimer = "WonderWeapon.EffectDamageReset."..effect.."."..entity:EntIndex()
			timer.Create( resetTimer, 0, 1, function()
				hook.Remove( "PostEntityTakeDamage", hookName )
			end )
		end
	end

	function WonderWeapons.DeathEffectClientRagdolls( position, radius, effect, doimpact, requireLOS )
		if not position or not isvector( position ) then return end

		if not radius or not isnumber( radius ) or radius <= 0 then
			radius = 8
		end

		if not doimpact or not isbool( doimpact ) then
			doimpact = false
		end

		if not requireLOS or not isbool( requireLOS ) then
			requireLOS = true
		end

		radius = math.Clamp( math.abs(radius), 1, 0xFFFF )

		net.Start( "TFA.BO3WW.FOX.DeathEffects.DoRadius", true )
			net.WriteDouble( position[1] )
			net.WriteDouble( position[2] )
			net.WriteDouble( position[3] )
			net.WriteUInt( math.Round( radius ), 16 )
			net.WriteBool( upgraded )
		net.SendPVS( position )
	end

	hook.Add("CreateEntityRagdoll", "TFA.BO3WW.FOX.DeathEffects.CreateEntityRagdoll", function( entity, ragdoll )
		if ragdoll.BloodColor == nil then
			ragdoll.BloodColor = WonderWeapons.GetBloodName( entity )
		end

		//timer.Simple( engine.TickInterval(), function()
			if not entity then return end

			if not IsValid( ragdoll ) then return end

			local currentEffects = ActiveDeathEffects[ entity ]

			if not currentEffects then return end

			if not IsValid( entity ) then
				entity = ragdoll
			end

			// Entity that was doing death effect ragdolled
			//  remove effects from entity and apply to ragdoll

			for effect, mDeathFX in pairs( currentEffects ) do
				if not mDeathFX then continue end
				if mDeathFX.Type and bit.band( mDeathFX.Type, EffectType.ON_RAGDOLL ) == 0 then
					continue 
				end

				local duration = mDeathFX:GetDuration()
				local arguments = mDeathFX:GetInputData()

				WonderWeapons.RemoveDeathEffect( entity, effect )

				if mDeathFX.OnServerRagdoll then
					mDeathFX:OnServerRagdoll( ragdoll, entity, duration, unpack( arguments ) )
				end

				if mDeathFX.OnServerRagdoll_Client then
					net.Start( "TFA.BO3WW.FOX.DeathEffects.Ragdoll" )
						net.WriteEntity( ragdoll )
						net.WriteString( effect )
						net.WriteFloat( duration )
						net.WriteTable( arguments, true )
						net.WriteEntity( entity )
					net.Broadcast()
				end
			end
		//end )
	end )

	// Cleanup

	hook.Add( "Think", "TFA.BO3WW.FOX.DeathEffects.Think", function()
		for entity, effectTable in pairs( ActiveDeathEffects ) do
			if not IsValid( entity ) then continue end

			for effect, mDeathFX in pairs( effectTable ) do
				if not mDeathFX or mDeathFX:GetDuration() <= 0 then continue end

				if ( mDeathFX:GetEndTime() < CurTime() ) and !mDeathFX.HasStatusEnded then
					mDeathFX.HasStatusEnded = true

					mDeathFX:Remove()
				end
			end
		end
	end )
end

if CLIENT then
	local CreationIndex = 0

	local RagdollCache = {}

	local CLIENT_RAGDOLLS = {
		["class C_ClientRagdoll"] = true,
		["class C_HL2MPRagdoll"] = true,
	}

	function WonderWeapons.GetDeathEffects( entity )
		if not IsValid( entity ) then return end

		if not ActiveDeathEffects[ entity ] then
			ActiveDeathEffects[ entity ] = {}
		end

		return ActiveDeathEffects[ entity ]
	end

	function WonderWeapons.GetDeathEffect( entity, effect )
		if not IsValid( entity ) then return end

		local currentStatuses = WonderWeapons.GetDeathEffects( entity )
		return currentStatuses[ effect ] or nil
	end

	function WonderWeapons.HasDeathEffect( entity, effect )
		if not IsValid( entity ) then return end

		local currentStatuses = WonderWeapons.GetDeathEffects( entity )
		return tobool( currentStatuses[ effect ] )
	end

	function WonderWeapons.DeathEffectIsValid( entity, effect )
		local currentStatuses = WonderWeapons.GetDeathEffects( entity )

		local mDeathFX = currentStatuses[ effect ]
		if mDeathFX then
			if not mDeathFX.IsValid then
				return false
			end

			return mDeathFX:IsValid( entity )
		else
			return false
		end
	end

	function WonderWeapons.RemoveDeathEffect( entity, effect, destroy )
		local currentEffects = WonderWeapons.GetDeathEffects( entity )

		// If no effect is supplied, use first available effect
		if not effect or not isstring( effect) or effect == "" then
			effect = next( currentEffects )
		end

		if not effect or not isstring( effect ) or effect == "" then
			return
		end

		local mDeathFX = currentEffects[ effect ]
		if not mDeathFX then return end

		mDeathFX:OnRemove( entity, destroy )

		currentEffects[ effect ] = nil

		// active effects table is empty, remove it
		if next( currentEffects ) == nil then
			ActiveDeathEffects[ entity ] = nil
		end
	end

	function WonderWeapons.ClearDeathEffects( entity )
		local currentEffects = WonderWeapons.GetDeathEffects( entity )
		for effect, mDeathFX in pairs(currentEffects) do
			mDeathFX:OnRemove( entity, false )

			currentEffects[ effect ] = nil
		end

		ActiveDeathEffects[ entity ] = nil
	end

	local function AssignDeathEffect( entity, effect, duration, arguments )
		local effectData = WonderWeapons.DeathEffectData( effect )
		local currentEffects = WonderWeapons.GetDeathEffects( entity )

		local nMaxMinusOne = ( 2^31 - 1 ) - 1
		local nNextIndex = 1 + CurrentIndex

		if ( nNextIndex >= nMaxMinusOne ) then
			nNextIndex = 1 // Justin Case
		end

		CurrentIndex = nNextIndex

		// Creating death effect table
		local data = table.Copy( effectData )
		data.DeathEffect = effect
		data.DeathEffectData = effectData
		data.Index = CurrentIndex
		data.VarArgs = arguments

		setmetatable( data, DeathEffect )

		ActiveDeathEffects[ entity ][ effect ] = data

		local mDeathFX = ActiveDeathEffects[ entity ][ effect ]
		mDeathFX:SetEntity( entity )
		mDeathFX:SetIndex( CurrentIndex )
		mDeathFX:SetInputData( arguments )
		mDeathFX:SetDuration( duration )
		mDeathFX:SetStartTime( CurTime() )
		mDeathFX:SetEndTime( CurTime() + duration )

		DeathEffectIndex[CurrentIndex] = mDeathFX

		return mDeathFX
	end

	function WonderWeapons.DoDeathEffect( entity, effect, duration, ... )
		if not IsValid(entity) then return end
		if effect == nil or not isstring(effect) then return end

		if not duration or not isnumber( duration ) or duration < 0 then
			duration = 0
		end

		local effectData = WonderWeapons.DeathEffectData( effect )
		if not effectData then return end

		local currentEffects = WonderWeapons.GetDeathEffects( entity )
		if currentEffects[ effect ] then
			//WonderWeapons.RemoveDeathEffect( entity, effect, true )
		end

		local varArgs = table.Pack( ... )

		local mDeathFX = AssignDeathEffect( entity, effect, duration, varArgs )

		local ragdollowner = entity.DeathEffectParent
		if not IsValid( ragdollowner ) and entity:IsRagdoll() and entity.GetRagdollOwner then
			ragdollowner = entity:GetRagdollOwner()
		end

		if ( ragdollowner ~= nil and IsValid( ragdollowner ) or CLIENT_RAGDOLLS[ entity:GetClass() ] ) and ( mDeathFX.OnClientRagdoll or mDeathFX.OnServerRagdoll_Client ) then
			if CLIENT_RAGDOLLS[ entity:GetClass() ] and not IsValid( ragdollowner ) then
				ragdollowner = entity
			end

			if entity.m_bServerRagdoll and mDeathFX.OnServerRagdoll_Client then
				mDeathFX:OnServerRagdoll_Client( entity, ragdollowner, duration, ... )
			elseif mDeathFX.OnClientRagdoll then
				mDeathFX:OnClientRagdoll( entity, ragdollowner, duration, ... )
			end
		else
			mDeathFX:OnEntity( entity, duration, unpack(varArgs) )
		end

		local removeHook = "WonderWeapon.EffectReset."..effect.."."..entity:EntIndex()
		entity:CallOnRemove( removeHook, function( ent )
			if ActiveDeathEffects[ ent ] then
				WonderWeapons.ClearDeathEffects( ent )
			end
		end )
	end

	function WonderWeapons.DeathEffectClientRagdolls( position, radius, effect, bDoImpact, bRequireLOS, ... )
		if not position or not isvector( position ) then return end

		if not radius or not isnumber( radius ) or radius <= 0 then
			radius = 8
		end

		if not bDoImpact or not isbool( bDoImpact ) then
			bDoImpact = false
		end

		if not bRequireLOS or not isbool( bRequireLOS ) then
			bRequireLOS = true
		end

		radius = math.Clamp( math.abs(radius), 1, 0xFFFF )

		if not position or not isvector( position ) then return end

		if not radius or not isnumber( radius ) or radius <= 0 then
			radius = 8
		end

		for _, ragdoll in RandomPairs( ents.FindInSphere( position, radius ) ) do
			if CLIENT_RAGDOLLS[ ragdoll:GetClass() ] then
				for i = 0, ragdoll:GetPhysicsObjectCount() - 1 do
					local phys = ragdoll:GetPhysicsObjectNum( i )

					if IsValid( phys ) then
						local trace = util.TraceLine({
							start = position,
							endpos = phys:LocalToWorld(phys:GetMassCenter()),
							mask = MASK_SHOT,
							ignoreworld = false,
							hitclientonly = true,
						})

						if ( trace.Hit and trace.Entity == ragdoll ) or !bRequireLOS then
							if bDoImpact then
								local BloodColor = ragdoll.GetBloodColor and ragdoll:GetBloodColor() or ragdoll.BloodColor
								if WonderWeapons.ParticleByBloodColor[ BloodColor ] then
									ParticleEffect( WonderWeapons.ParticleByBloodColor[ BloodColor ], trace.HitPos, ( -trace.Normal ):Angle() )
								end
							end

							WonderWeapons.DoDeathEffect( ragdoll, "BO3_Wunderwaffe", math.Rand( 4, 6 ), tobool( upgraded ), trace.HitGroup == HITGROUP_HEAD )
							break
						end
					end
				end
			end
		end
	end

	// Entity that was inflicted is the desired target
	net.Receive("TFA.BO3WW.FOX.DeathEffects.Start", function(len, ply)
		local entity = net.ReadEntity()
		local effect = net.ReadString()
		local duration = net.ReadFloat()
		local varArgs = net.ReadTable(true)

		print('network received effect start')
		//print(entity)
		WonderWeapons.DoDeathEffect(entity, effect, duration, unpack(varArgs))
	end)

	// Entity's serverside ragdoll is the desired target
	net.Receive("TFA.BO3WW.FOX.DeathEffects.Ragdoll", function(len, ply)
		local entity = net.ReadEntity()
		local effect = net.ReadString()
		local duration = net.ReadFloat()
		local varArgs = net.ReadTable(true)
		local ragdollowner = net.ReadEntity()

		entity.m_bServerRagdoll = true
		entity.DeathEffectParent = ragdollowner

		print('network received effect ragdoll')
		//print(entity)
		WonderWeapons.DoDeathEffect(entity, effect, duration, unpack(varArgs))
	end)

	// Entity's clientside ragdoll is the only target
	net.Receive("TFA.BO3WW.FOX.DeathEffects.Cache", function(len, ply)
		local entity = net.ReadEntity()
		local effect = net.ReadString()
		local duration = net.ReadFloat()
		local varArgs = net.ReadTable(true)

		if not IsValid(entity) then return end

		if not duration or not isnumber( duration ) or duration < 0 then
			duration = 0
		end

		local effectData = WonderWeapons.DeathEffectData( effect )
		if not effectData then return end

		local currentEffects = WonderWeapons.GetDeathEffects( entity )
		if currentEffects[ effect ] then
			WonderWeapons.RemoveDeathEffect( entity, effect, true )
		end

		print('network received effect cache')
		//print(entity)

		//RagdollCache[entity] = { effect = effect, duration = duration, arguments = varArgs}
		AssignDeathEffect( entity, effect, duration, varArgs )
	end)

	net.Receive("TFA.BO3WW.FOX.DeathEffects.Stop", function(len, ply)
		local entity = net.ReadEntity()
		local effect = net.ReadString()
		local destroy = net.ReadBool()

		if IsValid(entity) and ActiveDeathEffects[ entity ] then
			print('network received effect stop')
			//print(entity)
			WonderWeapons.RemoveDeathEffect( entity, effect, destroy )
		end
	end)

	net.Receive( "TFA.BO3WW.FOX.DeathEffects.DoRadius", function( length, ply )
		local x = net.ReadDouble()
		local y = net.ReadDouble()
		local z = net.ReadDouble()
		local radius = net.ReadUInt( 16 )
		local upgraded = net.ReadBool()

		WonderWeapons.ShockClientRagdolls( Vector( x, y, z ), radius, upgraded )
	end)

	hook.Add("OnEntityCreated", "TFA.BO3WW.FOX.DeathEffects.RagdollCreated", function( ragdoll )
		if CLIENT_RAGDOLLS[ragdoll:GetClass()] then
			// Clientside entities dont have a unique identifier
			CreationIndex = 1 + CreationIndex

			local flStartTime = CurTime()

			local hookName = "TFA.BO3WW.FOX.DeathEffects.RagdollCreated" .. CreationIndex
			hook.Add("Think", hookName, function()
				if not IsValid(ragdoll) then
					hook.Remove("Think", hookName)
					return
				end

				if flStartTime + 0.5 < CurTime() then
					hook.Remove("Think", hookName)
					return
				end

				// Entity that was doing death effect ragdolled
				//  remove effects from entity and apply to ragdoll

				local entity = ragdoll.ClientRagdollOwner
				if not IsValid( entity ) and CLIENT_RAGDOLLS[ ragdoll:GetClass() ] and ragdoll.GetRagdollOwner then
					entity = ragdoll:GetRagdollOwner() // ~Justin Case
				end

				if not entity then
					hook.Remove("Think", hookName)
					return
				end

				local currentEffects = ActiveDeathEffects[ entity ]

				if not currentEffects then return end

				if not IsValid( entity ) then
					entity = ragdoll
				end

				if currentEffects then
					for effect, mDeathFX in pairs( currentEffects ) do
						if not mDeathFX then continue end

						if mDeathFX.Type and bit.band( mDeathFX.Type, EffectType.ON_RAGDOLL ) == 0 then
							continue 
						end

						local duration = mDeathFX:GetDuration() - ( mDeathFX:GetEndTime() - CurTime() )
						local arguments = mDeathFX:GetInputData()

						WonderWeapons.RemoveDeathEffect( entity, effect )

						if duration > 0 then
							ragdoll.DeathEffectParent = entity

							WonderWeapons.DoDeathEffect( ragdoll, effect, duration, unpack(arguments) )
						end
					end

					ActiveDeathEffects[ entity ] = nil
				end
			end)
		end
	end)

	// Clientside only ragdoll owner hack

	hook.Add("CreateClientsideRagdoll", "TFA.BO3WW.FOX.DeathEffects.CreateClientsideRagdoll", function( entity, ragdoll )
		if not IsValid(entity) or not IsValid(ragdoll) then return end

		ragdoll.ClientRagdollOwner = entity

		if ragdoll.BloodColor == nil then
			ragdoll.BloodColor = WonderWeapons.GetBloodName( entity )
		end
	end)

	// Cleanup

	/*hook.Add( "Tick", "TFA.BO3WW.FOX.DeathEffects.Think", function()
		for entity, currentEffects in pairs( ActiveDeathEffects ) do
			if not IsValid( entity ) or entity:IsDormant() then continue end

			for effect, mDeathFX in pairs( currentEffects ) do
				if not mDeathFX then continue end
				if mDeathFX:GetDuration() <= 0 then continue end

				if ( mDeathFX:GetEndTime() < CurTime() ) and !mDeathFX.HasStatusEnded then
					mDeathFX.HasStatusEnded = true

					mDeathFX:Remove()
				end
			end
		end
	end )*/
end
