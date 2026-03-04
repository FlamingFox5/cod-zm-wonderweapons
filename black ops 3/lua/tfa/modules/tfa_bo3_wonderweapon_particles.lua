local nzombies = engine.ActiveGamemode() == "nzombies"
local pvp_cvar = GetConVar("sbox_playershurtplayers")
local SinglePlayer = game.SinglePlayer()

//-------------------------------------------------------------
// Draw Call Particles System
//-------------------------------------------------------------

local WonderWeapons = TFA.WonderWeapon

if SERVER then
	util.AddNetworkString("TFA.BO3WW.FOX.DrawParticles.Sync")
	util.AddNetworkString("TFA.BO3WW.FOX.DrawParticles.SyncFix")
	util.AddNetworkString("TFA.BO3WW.FOX.DrawParticles.Stop")

	WonderWeapons.ParticleEntities = WonderWeapons.ParticleEntities or {}

	local ParticleEntityTable = WonderWeapons.ParticleEntities

	function WonderWeapons.GetDrawParticles( entity )
		if not IsValid( entity ) then return end

		if not ParticleEntityTable[ entity:EntIndex() ] then
			ParticleEntityTable[ entity:EntIndex() ] = {}
		end

		return ParticleEntityTable[ entity:EntIndex() ]
	end

	// This system is used to create permanent looping particles on any entity until it is removed.
	//  TFA.WonderWeapon.CreateDrawParticle( entity Entity, string Effect, enum PAttachType, int Attachment, string UniqueNameYouWillRemember, table CPointTable )
	//  If no name is supplied, the name will be set to ( 'Effect'..'.'..'Attachment' ), meaning only 1 of that effect per that attachment.
	//  If the particle effect object gets deleted for any reason other than being removed through code, it will be recreate the next frame.
	//  Uses the clientside CNewParticleSystem entity to allow for modifying controlpoint values through a table.
	//  Each key should be the control point id to modify, and the value should be the Vector() that the cpoint gets set to.

	function WonderWeapons.CreateDrawParticle( entity, name, effect, attachtype, attachment, cpointTable )
		if not IsValid( entity ) then
			return
		end

		if not effect or not isstring( effect ) or effect == "" then
			return
		end

		if not attachtype or not isnumber( attachtype ) or attachtype < 0 then
			attachtype = PATTACH_ABSORIGIN_FOLLOW
		end

		if not attachment or not isnumber( attachment ) or attachment < 1 then
			attachment = 1
		end

		if not name or not isstring( name ) or name == "" then
			name = effect.."."..attachment
		end

		if not cpointTable or not istable( cpointTable ) then
			cpointTable = {}
		end

		local hookOverride = hook.Run( "TFA_WonderWeapon_CreateDrawCallParticle", entity, name, effect, attachtype, attachment, cpointTable )
		if hookOverride ~= nil and tobool( hookOverride ) then
			return
		end

		WonderWeapons.GetDrawParticles( entity )[ name ] = { effect = effect, type = attachtype, attachment = attachment, cpoints = cpointTable or nil }

		net.Start( "TFA.BO3WW.FOX.DrawParticles.Sync" )
			net.WriteInt( entity:EntIndex(), MAX_EDICT_BITS )
			net.WriteString( name )
			net.WriteString( effect )
			net.WriteUInt( attachtype, 8 )
			net.WriteUInt( attachment, 8 )
			net.WriteTable( cpointTable )
		net.Broadcast()
	end

	hook.Add("EntityRemoved", "TFA.BO3WW.FOX.DrawParticles.Removed", function( entity )
		if ParticleEntityTable[ entity:EntIndex() ] then
			net.Start("TFA.BO3WW.FOX.DrawParticles.SyncFix")
				net.WriteInt( entity:EntIndex(), MAX_EDICT_BITS )
			net.Broadcast()

			ParticleEntityTable[ entity:EntIndex() ] = nil
		end
	end)

	// Supports argument overload for name being the particle effect name instead, and will remove all instances of that effect on the entity

	function WonderWeapons.StopDrawParticle( entity, name, destroy )
		if not IsValid( entity ) then
			return
		end

		if not name or not isstring( name ) or name == "" then
			return
		end

		if not destroy or not isbool( destroy ) then
			destroy = false
		end

		local currentEffects = WonderWeapons.GetDrawParticles( entity )

		local hookOverride = hook.Run( "TFA_WonderWeapon_StopDrawCallParticle", entity, name, destroy, currentEffects )
		if hookOverride ~= nil and tobool( hookOverride ) then
			return
		end

		for effectName, effectsTable in pairs( currentEffects ) do
			if string.find( effectName, name ) then
				net.Start( "TFA.BO3WW.FOX.DrawParticles.Stop" )
					net.WriteInt( entity:EntIndex(), MAX_EDICT_BITS )
					net.WriteString( tostring( name ) )
					net.WriteBool( tobool( destroy ) )
				net.Broadcast()
			end
		end
	end
end

if CLIENT then
	WonderWeapons.ParticleEntities = WonderWeapons.ParticleEntities or {}

	local ParticleEntityTable = WonderWeapons.ParticleEntities

	function WonderWeapons.GetDrawParticles( entity )
		if not IsValid( entity ) then return end

		if not ParticleEntityTable[ entity:EntIndex() ] then
			ParticleEntityTable[ entity:EntIndex() ] = {}
		end

		return ParticleEntityTable[ entity:EntIndex() ]
	end

	function WonderWeapons.CreateDrawParticle( entity, name, effect, attachtype, attachment, cpointTable )
		if not IsValid( entity ) then
			return
		end

		if not effect or not isstring( effect ) or effect == "" then
			return
		end

		if not attachtype or not isnumber( attachtype ) then
			attachtype = PATTACH_ABSORIGIN_FOLLOW
		end

		if not attachment or not isnumber( attachment ) or attachment < 1 then
			attachment = 1
		end

		if not name or not isstring( name ) or name == "" then
			name = effect.."."..attachment
		end

		if not name or not isstring( name ) or name == "" then
			return
		end

		if cpointTable and istable( cpointTable ) and table.IsEmpty( cpointTable ) then
			cpointTable = nil
		end

		local hookOverride = hook.Run( "TFA_WonderWeapon_CreateDrawCallParticle", entity, name, effect, attachtype, attachment, cpointTable )
		if hookOverride ~= nil and tobool( hookOverride ) then
			return
		end

		if WonderWeapons.GetDrawParticles( entity )[ name ] then
			WonderWeapons.StopDrawParticle( entity, name )
		end

		WonderWeapons.GetDrawParticles( entity )[ name ] = { effect = effect, type = attachtype, attachment = attachment, cpoints = cpointTable or nil }

		entity:AddDrawCallParticle( effect, attachtype, attachment, true, name, cpointTable )
	end

	// Stops all instances of an effect with supplied name on all entities.

	function WonderWeapons.StopAllDrawParticleInstaces( name, destroy )
		if not name or not isstring( name ) or name == "" then
			return
		end

		for index, effectsTable in pairs( ParticleEntityTable ) do
			local entity = Entity( index )
			if IsValid( entity ) and effectsTable[ name ] then
				WonderWeapons.StopDrawParticle( entity, name, destroy )
			end
		end
	end

	// If no effect name is given, but a valid entity is, the first effect tied to that entity will be removed.

	function WonderWeapons.StopDrawParticle( entity, name, destroy )
		if not IsValid( entity ) then
			return
		end

		if entity.CNewParticlesTable and ( !name or !isstring( name ) or name == "" ) then
			name = next( entity.CNewParticlesTable )
		end

		if not name or not isstring( name ) or name == "" then
			return
		end

		local currentEffects = WonderWeapons.GetDrawParticles( entity )

		local hookOverride = hook.Run( "TFA_WonderWeapon_StopDrawCallParticle", entity, name, destroy, currentEffects )
		if hookOverride ~= nil and tobool( hookOverride ) then
			return
		end

		if entity.CNewParticlesTable and entity.CNewParticlesTable[ name ] and IsValid( entity.CNewParticlesTable[ name ] ) then
			if tobool( destroy ) then
				entity.CNewParticlesTable[ name ]:StopEmissionAndDestroyImmediately()
				entity.CNewParticlesTable[ name ] = nil
			else
				entity.CNewParticlesTable[ name ]:StopEmission()
			end

			WonderWeapons.GetDrawParticles( entity )[ name ] = nil
		end
	end

	local function ReceiveStopParticle( length )
		local index = net.ReadInt( MAX_EDICT_BITS )
		local name = net.ReadString()
		local destroy = net.ReadBool()

		WonderWeapons.StopDrawParticle( Entity( index ), tostring( name ), destroy )
	end

	net.Receive( "TFA.BO3WW.FOX.DrawParticles.Stop", ReceiveStopParticle )

	function WonderWeapons.ClearDrawParticles( entity, destroy )
		if destroy == nil or not isbool( destroy ) then
			destroy = false
		end

		if entity.CNewParticlesTable then
			for name, CNewParticleSystem in pairs( entity.CNewParticlesTable ) do
				if IsValid( CNewParticleSystem ) then
					local owner = CNewParticleSystem:GetOwner()
					if IsValid( owner) and owner ~= entity then
						// Why the fuck is this happening?
						//  How the fuck is this happening???
						continue
					end

					if tobool( destroy ) then
						CNewParticleSystem:StopEmissionAndDestroyImmediately()
					else
						CNewParticleSystem:StopEmission()
					end
				end
			end

			entity.CNewParticlesTable = {}
			ParticleEntityTable[ entity:EntIndex() ] = nil
		end
	end

	hook.Add( "EntityRemoved", "TFA.BO3WW.FOX.DrawParticles.Removed", function( entity, fullUpdate )
		if ( fullUpdate ) then return end

		if ParticleEntityTable and ParticleEntityTable[ entity:EntIndex() ] then
			WonderWeapons.ClearDrawParticles( entity )

			ParticleEntityTable[ entity:EntIndex() ] = nil
		end
	end )

	// Example sync system from gmod wiki
	//  executes given code the frame that the entity becomes valid on our client
	//  and will wait until it does, unless the entity is removed before it enters our PVS

	local status_queue_cl = {}

	local function ReceiveSync( length )
		local ply = LocalPlayer()
		if not IsValid(ply) then return end

		local index = net.ReadInt( MAX_EDICT_BITS )
		local name = net.ReadString()
		local effect = net.ReadString()
		local attachtype = net.ReadUInt( 8 )
		local attachment = net.ReadUInt( 8 )
		local cpointTable = net.ReadTable()

		if !status_queue_cl[ ply ] then
			status_queue_cl[ ply ] = {}
		end

		table.insert( status_queue_cl[ply], { entity = index, name = name, effect = effect, attachtype = attachtype, attachment = attachment, cpoints = cpointTable } )
	end

	// Entity was removed before it could enter our PVS, remove from table

	local function ReceiveSyncFix( length )
		local ply = LocalPlayer()
		if not IsValid(ply) then return end

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

	// Wait until the entity exists on our client to run the code, called every ingame tick

	hook.Add( "Tick", "TFA.BO3WW.FOX.DrawParticles.Sync", function()
		local ply = LocalPlayer()
		if not IsValid(ply) then return end

		if status_queue_cl[ ply ] then
			for k, data in pairs(status_queue_cl[ ply ]) do
				local entity = Entity( data.entity )
				if IsValid( entity ) then
					WonderWeapons.CreateDrawParticle( entity, data.name, data.effect, data.attachtype, data.attachment, data.cpoints )

					status_queue_cl[ ply ][ k ] = nil

					if table.IsEmpty( status_queue_cl[ ply ] ) then
						status_queue_cl[ ply ] = nil
					end

					break
				end
			end
		end
	end )

	net.Receive( "TFA.BO3WW.FOX.DrawParticles.Sync", ReceiveSync )
	net.Receive( "TFA.BO3WW.FOX.DrawParticles.SyncFix", ReceiveSyncFix )

	// Make sure effect is alive and persists every frame, this is totally overkill
	//  but fuck me if source doesnt *LOVE* removing clientside particles anytime you leave its PVS for too long

	hook.Add( "PostDrawEffects", "TFA.BO3WW.FOX.DrawParticles", function()
		for index, effectsTable in pairs( ParticleEntityTable ) do
			local entity = Entity( index )

			if not IsValid( entity ) or entity:IsDormant() then
				continue
			end

			if ( ( entity:IsNPC() or entity:IsPlayer() or entity:IsNextBot() ) and entity:GetInternalVariable("m_lifeState") == 2 ) then
				WonderWeapons.ClearDrawParticles( entity, false )
				continue
			end

			for name, data in pairs( effectsTable ) do
				entity:AddDrawCallParticle( data.effect, data.type or PATTACH_ABSORIGIN_FOLLOW, data.attachment or 1, true, name, data.cpoints )
			end
		end
	end )

	local ENTITY = FindMetaTable("Entity")

	if ENTITY then
		// meant to be called from within the ENTITY:Draw() function, but can be used to create a CNewParticleSystem with custom control point data if only called once

		local oldStopParticleEmission = ENTITY.StopParticleEmission
		function ENTITY:StopParticleEmission( ... )
			WonderWeapons.ClearDrawParticles( self, false )

			oldStopParticleEmission( self, ... )
		end

		function ENTITY:AddDrawCallParticle( effect, attachtype, attachment, active, name, cpoints )
			if not effect or not isstring( effect ) or effect == "" then
				return
			end

			if not name or not isstring( name ) or name == "" then
				name = effect.."."..attachment
			end

			if not attachtype or not isnumber( attachtype ) or ( attachtype > 5 or attachtype < 0 ) then
				attachtype = 1
			end

			if not self.CNewParticlesTable or not istable( self.CNewParticlesTable ) then
				self.CNewParticlesTable = {}
			end

			// conditional for if the particle should exist for this specific ENTITY:Draw() call
			if tobool( active ) then
				local CNPSystem = self.CNewParticlesTable[ name ]

				// particle effect name does not match existing ones name, destroy and recreate
				if IsValid( CNPSystem ) and CNPSystem:GetEffectName() ~= effect then
					self.CNewParticlesTable[ name ]:StopEmissionAndDestroyImmediately()
					self.CNewParticlesTable[ name ] = nil

					CNPSystem = nil
				end

				// particle does not exist anymore or is done emitting
				if not CNPSystem or not CNPSystem:IsValid() then
					self.CNewParticlesTable[ name ] = CreateParticleSystem( self, effect, attachtype or PATTACH_ABSORIGIN_FOLLOW, attachment or 1 )
					if cpoints and istable( cpoints ) and not table.IsEmpty( cpoints ) then
						for cpoint, vector in pairs( cpoints ) do
							if not vector or not isvector( vector ) then
								continue
							end

							self.CNewParticlesTable[ name ]:SetControlPoint( tonumber( cpoint ), vector )
						end
					end

					local removeHook = "WonderWeapon.DrawParticleClean." .. name

					hook.Add("Think", removeHook, function()
						if not IsValid( self ) then
							hook.Remove("Think", removeHook)
							return
						end
						//print(self.CNewParticlesTable[ name ])
					end)

					self:RemoveCallOnRemove( removeHook )

					// always remember to destroy our self when parent entity dies
					self:CallOnRemove( removeHook, function( removed, fullUpdate )
						//if fullUpdate ~= nil and tobool( fullUpdate ) then return end
						print(self.CNewParticlesTable[ name ])
						WonderWeapons.ClearDrawParticles( removed, false )
						if self.CNewParticlesTable and istable( self.CNewParticlesTable ) and IsValid( self.CNewParticlesTable[ name ] ) then
							self.CNewParticlesTable[ name ]:StopEmission()
						end
					end )

					hook.Run( "TFA_WonderWeapon_DrawCallParticleCreated", self, self.CNewParticlesTable[ name ], effect, attachtype, attachment, active, name, cpoints )
				end

				return self.CNewParticlesTable[ name ]
			elseif self.CNewParticlesTable[ name ] and IsValid( self.CNewParticlesTable[ name ] ) and active ~= nil then
				// if we shouldnt exist anymore, destroy

				self.CNewParticlesTable[ name ]:StopEmissionAndDestroyImmediately()
			end
		end

		// Supports argument overload of name being the particle effects name instead, and will return first instance of that effect attached to the entity
		function ENTITY:GetDrawCallParticle( self, name )
			if not self.CNewParticlesTable then
				return
			end

			if not name or not isstring( name ) or name == "" then
				return
			end

			if self.CNewParticlesTable[ name ] then
				return self.CNewParticlesTable[ name ]
			else
				for effectName, CNP in pairs( self.CNewParticlesTable ) do
					if string.find( effectName, name ) then
						return self.CNewParticlesTable[ effectName ]
					end
				end
			end
		end
	end
end