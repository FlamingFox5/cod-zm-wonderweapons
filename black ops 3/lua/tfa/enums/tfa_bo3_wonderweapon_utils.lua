--[[ SOURCE 1 SDK LICENSE

Copyright(c) Valve Corporation. All rights reserved

THESE LICENSE TERMS ARE AN AGREEMENT BETWEEN YOU AND VALVE CORPORATION ("VALVE") FOR THE SOURCE 1 SDK (“SDK”). 
PLEASE READ THEM BEFORE DOWNLOADING OR USING THE SDK.  BY USING THE SDK, YOU ACKNOWLEDGE THAT YOU HAVE READ AND AGREE 
TO BE BOUND BY THESE LICENSE TERMS. IF YOU DO NOT AGREE TO THESE TERMS, YOU MAY NOT USE THE SDK.

You may, free of charge, use, copy, and modify the SDK to develop a modified Valve game running on Valve's Source 1 engine, 
which game can be distributed in source and object code form if it is free and meets the terms of use for Valve games in the 
Steam Subscriber Agreement located here: http://store.steampowered.com/subscriber_agreement/. You may also distribute the SDK 
(or any substantial portions of the SDK) and any modifications you make to the SDK in both source code and object code form, 
provided you meet the following conditions: distributions of the SDK must (1) be free of charge; (2) include this LICENSE file 
and thirdpartylegalnotices.txt; and (3) include the above copyright notice and the additional legal provisions below.  

DISCLAIMER OF WARRANTIES.  THE SDK AND  ANY OTHER MATERIAL YOU DOWNLOAD IS PROVIDED BY VALVE "AS IS" AND “AS AVAILABLE” WITHOUT 
WARRANTY OF ANY KIND.  VALVE EXPRESSLY DISCLAIMS ALL WARRANTIES AND CONDITIONS OF ANY KIND WHETHER EXPRESS OR IMPLIED, 
INCLUDING, BUT NOT LIMITED TO, IMPLIED WARRANTIES OF MERCHANTABILITY, NON-INFRINGEMENT, TITLE AND FITNESS FOR A PARTICULAR PURPOSE.

LIMITATION OF LIABILITY.  VALVE AND ITS LICENSORS SHALL NOT BE LIABLE TO YOU UNDER ANY THEORY OF LIABILITY FOR ANY DIRECT, INDIRECT, SPECIAL, INCIDENTAL, 
OR CONSEQUENTIAL DAMAGES WHATSOEVER THAT MAY BE INCURRED BY YOU EVEN IF VALVE HAS BEEN ADVISED OF OR SHOULD HAVE BEEN AWARE OF THE POSSIBILITY OF SUCH DAMAGES.  ]]

local nzombies = engine.ActiveGamemode() == "nzombies"
local sbox_pvp = GetConVar("sbox_playershurtplayers")
local SinglePlayer = game.SinglePlayer()

local CLIENT_RAGDOLLS = {
	["class C_ClientRagdoll"] = true,
	["class C_HL2MPRagdoll"] = true,
}

if BASECHOPPER_WASH_ALTITUDE == nil then
	BASECHOPPER_WASH_ALTITUDE = 1024
end

//-------------------------------------------------------------
// Global Table
//-------------------------------------------------------------

TFA.WonderWeapon = TFA.WonderWeapon or {}

local WonderWeapons = TFA.WonderWeapon

WonderWeapons.BLOOD_RED = "Human"
WonderWeapons.BLOOD_ZOMBIE = "Zombie"
WonderWeapons.BLOOD_ALIEN = "Yellow"
WonderWeapons.BLOOD_CYBORG = "Robot"
WonderWeapons.BLOOD_SYNTH = "Synth"
WonderWeapons.BLOOD_ACID = "Acid"
WonderWeapons.BLOOD_MECH = "Mech"
WonderWeapons.DONT_BLEED = "None"

//-------------------------------------------------------------
// Convars
//-------------------------------------------------------------

// Client Convars

if GetConVar("cl_tfa_bo3ww_crosshair") == nil then
	CreateClientConVar("cl_tfa_bo3ww_crosshair", 1, true, false, "Enable or disable the original crosshairs for their respective wonder weapons. \n(0 false, 1 true), Default is 1.")
end

if GetConVar("cl_tfa_bo3ww_achievements") == nil then
	CreateClientConVar("cl_tfa_bo3ww_achievements", 1, true, false, "Enable or disable achievements clientside. Server convar takes priority if disabled. \n(0 false, 1 true), Default is 1.")
end

if GetConVar("cl_tfa_bo3ww_screen_visuals") == nil then
	CreateClientConVar("cl_tfa_bo3ww_screen_visuals", 1, true, false, "Enable or disable full screen visual effects from proximity to certain entities. \n(0 false, 1 true, 2 overlay only, 3 visionset only, 4 visionset and statuseffect), Default is 1.", 0, 4)
end

if GetConVar("cl_tfa_bo3ww_pes_playercolor") == nil then
	CreateClientConVar("cl_tfa_bo3ww_pes_playercolor", 0, true, true, "Enable or disable the P.E.S. helmet visior texture using PlayerColor. \n(0 false, 1 true), Default is 0.", 0, 1)
end

if GetConVar("cl_tfa_bo3ww_pes_msaa_translucent") == nil then
	CreateClientConVar("cl_tfa_bo3ww_pes_msaa_translucent", 0, true, true, "Enable or disable the P.E.S. helmet visior texture being translucent, looks bad with MSAA disabled, recommend 2x or 4x. \n(0 false, 1 true), Default is 0.", 0, 1)
end

if GetConVar("cl_tfa_bo3ww_pes_hide_model") == nil then
	CreateClientConVar("cl_tfa_bo3ww_pes_hide_model", 0, true, true, "Enable to prevent P.E.S. helmets from drawing. \n(0 false, 1 true), Default is 0.", 0, 1)
end

// Visuals Convars

if GetConVar("cl_tfa_fx_wonderweapon_dlights") == nil then
	CreateClientConVar("cl_tfa_fx_wonderweapon_dlights", 1, true, false, "Enable or disable dynamic lights on Wonder Weapon entites. \n(0 false, 1 true, 2 minimal), Default is 1.", 0, 2)
end

if GetConVar("cl_tfa_fx_wonderweapon_muzzleflash_dlights") == nil then
	CreateClientConVar("cl_tfa_fx_wonderweapon_muzzleflash_dlights", 1, true, false, "Enable or disable dynamic lights on Wonder Weapon muzzleflashes. \n(0 false, 1 true), Default is 1.", 0, 1)
end

if GetConVar("cl_tfa_fx_wonderweapon_3p") == nil then
	CreateClientConVar("cl_tfa_fx_wonderweapon_3p", 1, true, false, "Enable or disable third person particles on wonder weapons that have them. \n(0 false, 1 true), Default is 1.", 0, 1)
end

if GetConVar("cl_tfa_fx_wonderweapon_gibs_max") == nil then
	CreateClientConVar("cl_tfa_fx_wonderweapon_gibs_max", 5, true, false, "Maximum amount of gibs that can spawn from a ragdoll caused by certain death effects. \nDefault is 5.", 0, 128)
end

if GetConVar("cl_tfa_fx_wonderweapon_gibs_multiplier") == nil then
	CreateClientConVar("cl_tfa_fx_wonderweapon_gibs_multiplier", 1, true, false, "Multiplies how many gibs spawn from certain ragdoll death effects. \nDefault is 1.", 0, 64)
end

local function CreateReplConVar( cvarname, cvarvalue, description, ... )
	return CreateConVar( cvarname, cvarvalue, CLIENT and {FCVAR_REPLICATED} or {FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY}, description, ... )
end -- replicated only on clients, archive/notify on server

// Server Convars

if GetConVar("sv_tfa_bo3ww_achievements") == nil then
	CreateReplConVar("sv_tfa_bo3ww_achievements", "1", "Enable or disable achievements system globally. \n(0 false, 1 true), Default is 1.", 0, 1)
end

if GetConVar("sv_tfa_bo3ww_inf_specialist") == nil then
	CreateReplConVar("sv_tfa_bo3ww_inf_specialist", "0", "Enable or disable infinite ammo on zombie specific specialist weapons. \nREQURIES MAP RESTART (0 false, 1 true), Default is 0.", 0, 1)
end

if GetConVar("sv_tfa_bo3ww_friendly_fire") == nil then
	CreateReplConVar("sv_tfa_bo3ww_friendly_fire", "1", "Enable or disable being able to damage / afflict allied NPCs. \n(0 false, 1 true), Default is 1.", 0, 1)
end

if GetConVar("sv_tfa_bo3ww_npc_friendly_fire") == nil then
	CreateReplConVar("sv_tfa_bo3ww_npc_friendly_fire", "0", "Enable or disable NPCs being able to damage / afflict other NPCs allied to them. \n(0 false, 1 true), Default is 0.", 0, 1)
end

if GetConVar("sv_tfa_bo3ww_vehicle_damage") == nil then
	CreateReplConVar("sv_tfa_bo3ww_vehicle_damage", "1", "Enable or disable Wonder Weapons being able to damage Vehicles. \n(0 false, 1 true), Default is 1.", 0, 2)
end

if GetConVar("sv_tfa_bo3ww_environmental_damage") == nil then
	CreateReplConVar("sv_tfa_bo3ww_environmental_damage", "1", "Enable or disable Wonder Weapons being able to damage entities other than Players, NPCs, Bots, and Vehicles. \n(0 false, 1 true), Default is 1.", 0, 1)
end

if GetConVar("sv_tfa_bo3ww_shrinkray_shrink_players") == nil then
	CreateReplConVar("sv_tfa_bo3ww_shrinkray_shrink_players", "1", "Set to 0 to completely disable the 31-79 JGb215 from being able to shrink players, regardless of PVP or team based gamemode settings. \n(0 disabled, 1 allowed), Default is 1.", 0, 1)
end

if GetConVar("sv_tfa_bo3ww_shrinkray_damage_multiplier") == nil then
	CreateReplConVar("sv_tfa_bo3ww_shrinkray_damage_multiplier", "0.2", "Multiplier for damage done by shrunk entities inflicted with the 31-79 JGb215's shrink effect. \nDefault is 0.2", 0, 1)
end

if GetConVar("sv_tfa_bo3ww_shrinkray_shrink_all") == nil then
	CreateReplConVar("sv_tfa_bo3ww_shrinkray_shrink_all", "0", "Set to 1 to force the 31-79 JGb215 to shrink all NPCs regardless of hull / collision size. By default the JGb will instantly crush entities too small, or do surface blast damage to entities too large. \n(0 disabled, 1 enabled), Default is 0.", 0, 1)
end

if nzombies then
	if GetConVar("nz_difficulty_bo3_tacticalkills") == nil then
		CreateReplConVar("nz_difficulty_bo3_tacticalkills", "50", "Amount of kills required to upgrade Monkeybombs in nZombies. \nDefault is 50.")
	end
else
	if GetConVar("sv_tfa_bo3ww_monkeybomb_use_los") == nil then
		CreateReplConVar("sv_tfa_bo3ww_monkeybomb_use_los", "0", "Enable or disable Tactical Grenades from requiring line of sight to attract enemies. \n(0 false, 1 true), Default is 0.", 0, 1)
	end

	if GetConVar("sv_tfa_bo3ww_cod_damage") == nil then
		CreateReplConVar("sv_tfa_bo3ww_cod_damage", "0", "Enable or disable Wonder Weapons doing their true ingame damage from Call of Duty, instead of being balanced around Half-Life 2 / Deathmatch. \n(0 false, 1 true), Default is 0.", 0, 1)
	end
end

//-------------------------------------------------------------
// Helper Functions
//-------------------------------------------------------------

// dear rubat, consider the following

if ( util ) and util.CoinFlip == nil then
	function util.CoinFlip( tries )
		if tries and isnumber( tries ) and tries > 0 then
			for i = 1, tries do
				if ( math.random( 2 ) == 1 ) then
					return true
				end
			end

			return false
		else
			return ( math.random( 2 ) == 1 )
		end
	end
end

// Sick and tired of having to copy paste the same code block for something that should be a single function in the base game

function TFA.WonderWeapon.SafeRemoveRagdoll( ragdoll, delay )
	if delay and isnumber( delay ) and delay > 0 then
		if ragdoll.GetRagdollOwner then
			local owner = ragdoll:GetRagdollOwner()
			if IsValid( owner ) and owner:IsPlayer() then
				if SERVER then
					SafeRemoveEntityDelayed( ragdoll, delay )
				else
					if owner:GetNW2Bool( "RagdollRemoveRequested", false ) then return end

					if delay > 0 then
						timer.Create( "WonderWeapon.SafeRemoveRagdoll", delay, 1, function()
							if not IsValid( owner ) then return end
							if not IsValid( ragdoll ) then return end

							net.Start( "TFA.BO3.REMOVERAG" )
								net.WriteEntity( owner )
							net.SendToServer()
						end )
					else
						net.Start( "TFA.BO3.REMOVERAG" )
							net.WriteEntity( owner )
						net.SendToServer()
					end
				end
			else
				SafeRemoveEntityDelayed( ragdoll, delay )
			end
		else
			SafeRemoveEntityDelayed( ragdoll, delay )
		end
	else
		if ragdoll.GetRagdollOwner then
			local owner = ragdoll:GetRagdollOwner()
			if IsValid( owner ) and owner:IsPlayer() then
				if SERVER then
					SafeRemoveEntity( ragdoll )
				else
					if owner:GetNW2Bool( "RagdollRemoveRequested", false ) then return end

					net.Start( "TFA.BO3.REMOVERAG" )
						net.WriteEntity( ragdoll:GetRagdollOwner() )
					net.SendToServer()
				end
			else
				SafeRemoveEntity( ragdoll )
			end
		else
			SafeRemoveEntity( ragdoll )
		end
	end
end

if SERVER then
	// Player ragdolls use a serverside point entity (hl2mp_ragdoll) to spawn the clientside ragdolls.
	//  The ragdolls them selves cannot be removed, you must instead call remove on the point entity from the server.

	util.AddNetworkString("TFA.BO3WW.FOX.RagdollRemove")

	net.Receive( "TFA.BO3WW.FOX.RagdollRemove", function( length, ply )
		local ply = net.ReadEntity()
		if not IsValid( ply ) or ply:Alive() then return end

		ply:SetNW2Bool( "RagdollRemoveRequested", true )

		SafeRemoveEntity( ply:GetRagdollEntity() )

		local removeTimer = "WonderWeapons.RagdollRequest."..ply:EntIndex()
		if timer.Exists( removeTimer ) then
			timer.Remove( removeTimer )
		end

		timer.Create( removeTimer, engine.TickInterval()*2, 1, function()
			ply:SetNW2Bool("RagdollRemoveRequested", false)
		end )
	end)
end

// Shared alternative that attempts to mimic the general functionality of ENTITY:BodyTarget
//  if noise is enable, client and server will return different results due to math.random not being synced

function TFA.WonderWeapon.BodyTarget( entity, start, noisy, headshot )
	if not IsValid( entity ) then
		return vector_origin
	end
	if start == nil or not isvector( start ) or start:IsZero() then
		start = entity:GetPos()
	end
	if noisy == nil or not isbool( noisy ) then
		noisy = false
	end
	if headshot == nil or not isbool( headshot ) then
		headshot = false
	end

	local hitCharacter = ( entity:IsPlayer() or entity:IsNPC() or entity:IsNextBot() )
	local finalPos = headshot and entity:EyePos() or entity:WorldSpaceCenter()
	local hitboxid
	local boneid

	local hitgroups = {
		[1] = HITGROUP_HEAD,
		[2] = HITGROUP_CHEST,
		[3] = HITGROUP_STOMACH,
		[4] = HITGROUP_GENERIC,
		[5] = HITGROUP_GEAR,
	}

	local hitboxcount = entity:GetHitBoxCount( 0 )
	local boxfound = false

	for i = 1, #hitgroups do
		if i == 1 and !headshot then
			continue
		end
		if boxfound then
			break
		end

		for i2 = 0, hitboxcount do
			local hitgroup = entity:GetHitBoxHitGroup( i2, 0 )

			if hitgroup ~= nil and hitgroup == hitgroups[i] then
				hitboxid = i2
				boneid = entity:GetHitBoxBone( i2, 0 )
				boxfound = true
				break
			end
		end
	end

	if boneid and hitCharacter then
		finalPos = entity:GetBonePosition( boneid )
	elseif entity.GetPhysicsObject then
		local physCount = entity:GetPhysicsObjectCount() - 1

		// if phys count is greater than 1 (like a ragdoll), get the objects average phys center based on all phys objects centers
		//  and calculates which phys object is closest to the total center, use that phys objects center as the target pos

		if physCount > 0 then
			local bStartIsVisible = entity:VisibleVec( start )
			local physCenters = {}

			for i = 0, physCount do
				local phys = entity:GetPhysicsObjectNum( i )
				if IsValid( phys ) then
					local vecCenter = phys:LocalToWorld( phys:GetMassCenter() )

					if bStartIsVisible then
						local trace = util.TraceLine({
							start = start,
							endpos = vecCenter,
							mask = MASK_SHOT,
							collisiongroup = COLLISION_GROUP_NONE,
							whitelist = true,
							filter = phys,
						})

						if trace.Hit and trace.Entity == ent and trace.Fraction > 0.94 then
							physCenters[ i ] = vecCenter
						end
					else
						physCenters[ i ] = vecCenter
					end
				end
			end

			local vecSum = Vector()
			for _, v3 in pairs( physCenters ) do
				vecSum:Add( v3 )
			end

			local vecFinalCenter = ( vecSum / table.Count(physCenters) )
			local flClosest = math.huge
			local nTargetPhys = 0

			for i, vecCenter in pairs( physCenters ) do
				local flDistance = vecCenter:Distance( vecFinalCenter )
				if flDistance < flClosest then
					flClosest = flDistance
					nTargetPhys = i
				end
			end

			if nTargetPhys > 0 then
				local phys = entity:GetPhysicsObjectNum( nTargetPhys )
				finalPos = phys:GetPos()

				if noisy then
					local vecOffset = Vector()
					local vecMin, vecMax = phys:GetAABB()

					if not vecMax or not isvector( vecMax ) or vecMax == vector_origin then
						vecMin, vecMax = entity:GetCollisionBounds()
						vecMin:Mul( 1 / physCount )
						vecMax:Mul( 1 / physCount )
					end

					vecMin:Mul(0.5)
					vecMax:Mul(0.5)

					local qPhysAng = phys:GetAngles()
					vecMin:Rotate( qPhysAng )
					vecMax:Rotate( qPhysAng )

					vecOffset:SetUnpacked( math.random(vecMin[1], vecMax[1]), math.random(vecMin[2], vecMax[2]), math.random(vecMin[3], vecMax[3]) )

					debugoverlay.Text( finalPos, tostring( phys ), 5, false )
					debugoverlay.Box( finalPos, vecMin, vecMax, 3, Color( 255, 255, 0, 4 ) )

					finalPos = finalPos + vecOffset
					return finalPos
				end
			end
		else
			local phys = entity:GetPhysicsObject()
			if IsValid( phys ) then
				finalPos = phys:LocalToWorld(phys:GetMassCenter())

				if noisy then
					finalPos = entity:GetPos()

					local vecOffset = Vector()
					local vecMin, vecMax = phys:GetAABB()

					if not vecMax or not isvector( vecMax ) or vecMax == vector_origin then
						vecMin, vecMax = entity:GetCollisionBounds()
					end

					if string.find( entity:GetClass(), "_door_rotating" ) then
						// both of you go to hell and die forever
						// i will never understand how the missile knows where it is
						vecMin:Mul(0.75)
						vecMax:Mul(0.75)
					else
						vecMin:Mul(0.5)
						vecMax:Mul(0.5)
					end

					local qPhysAng = phys:GetAngles()
					vecMin:Rotate( qPhysAng )
					vecMax:Rotate( qPhysAng )

					vecOffset:SetUnpacked( math.random(vecMin[1], vecMax[1]), math.random(vecMin[2], vecMax[2]), math.random(vecMin[3], vecMax[3]) )

					debugoverlay.Box( finalPos, vecMin, vecMax, 3, Color( 255, 255, 0, 4 ) )

					finalPos = finalPos + vecOffset
					return finalPos
				end
			end
		end
	end

	if hitboxid and noisy then
		local vecOffset = Vector()
		local vecMin, vecMax = entity:GetHitBoxBounds( hitboxid, 0 )

		vecMin:Mul(0.5)
		vecMax:Mul(0.5)

		local vecBonePos, qBoneAng = entity:GetBonePosition( boneid )
		debugoverlay.BoxAngles( finalPos, vecMin, vecMax, qBoneAng, 3, Color( 255, 255, 0, 4 ) )

		vecMin:Rotate( qBoneAng )
		vecMax:Rotate( qBoneAng )

		vecOffset:SetUnpacked( math.random(vecMin[1], vecMax[1]), math.random(vecMin[2], vecMax[2]), math.random(vecMin[3], vecMax[3]) )

		finalPos = finalPos + vecOffset
	end

	return finalPos
end

WonderWeapons.WeaponList = WonderWeapons.WeaponList or {}

local WeaponsList = WonderWeapons.WeaponList

hook.Add( "InitPostEntity", "TFA.BO3WW.FOX.WeaponList", function()
	hook.Add( "OnEntityCreated", "TFA.BO3WW.FOX.WeaponList", function( wep )
		if not IsValid( wep ) or not wep:IsWeapon() then return end

		table.insert( WeaponsList, wep )
	end )

	hook.Add( "EntityRemoved", "TFA.BO3WW.FOX.WeaponList", function( wep, fullUpdate )
		if ( fullUpdate ) then return end

		for i = 1, #WeaponsList do
			if WeaponsList[ i ] == wep then
				table.remove(WeaponsList, i)
				break
			end
		end
	end )
end )

// Returns a random key from a table, where each key's value is its weight (a number)

function TFA.WonderWeapon.WeightedRandom( pool )
	local poolsize = 0
	for id, weight in pairs( pool ) do
		poolsize = poolsize + weight
	end

	local selection = math.random( 1, poolsize )

	for id, weight in pairs( pool ) do
		selection = selection - weight

		if ( selection <= 0 ) then
			return id
		end
	end
end

// Alternative to CalcClosestPointOnLineSegment() <mathlib_base.cpp#L3138> --Credit roblox devforum user Jaycbee

function TFA.WonderWeapon.PointOnSegmentNearestToPoint( start, endpos, position )
	local direction = endpos - start
	local facing = position - start

	local t = facing:Dot( direction ) / ( direction.x^2 + direction.y^2 + direction.z^2 )
		t = math.Clamp(t, 0, 1)
	return start + t * direction
end

// Alternative to enginetrace->ClipRayToEntity() --Credit to ValsdalV for converting this to LUA!!!
//  Returns true or false depending on if the trace successfully clipped the entity.
//  The second trace table input is meant to be an empty table that will contain the new trace data after the function is called.

--[[EXAMPLE:
	local trace = util.TraceHull({ tracedata })

	if trace.Hit and not trace.HitWorld then
		local testEntity = trace.Entity
		local trace2 = {}

		if TFA.WonderWeapon.FindHullIntersection( testEntity, trace, trace2 ) then
			trace.HitPos:Set( trace2.HitPos )
			trace.HitBox = trace2.HitBox
			trace.PhysicsBone = trace2.PhysicsBone
			trace.HitGroup = ( trace2.HitGroup == HITGROUP_HEAD ) and HITGROUP_HEAD or HITGROUP_GENERIC // use this to overwrite built in damage scaling, at the cost of ragdoll force mods hating you
		else
			trace.UnreliableHitPos = true
		end
	end
]]--

function TFA.WonderWeapon.FindHullIntersection( entity, trace, trace2, contentsMask )
	local debugstring = tostring(trace.HitPos)
	debugoverlay.Axis( trace.HitPos, trace.Normal:Angle(), 5, 5, true)
	debugoverlay.Text( trace.HitPos + ( vector_up * 4 ), "FindHullIntersection ["..debugstring.."]", 5, false )

	local ray = {
		start = trace.HitPos,
		endpos = 48 * trace.Normal + trace.HitPos,
		mask = contentsMask or MASK_SHOT,
		ignoreworld = true,
		output = trace2,
		whitelist = true,
		filter = entity,
	}

	util.TraceLine( ray )

	debugoverlay.Axis( trace2.HitPos, trace2.HitNormal:Angle(), 5, 5, true)
	debugoverlay.Line( ray.start, trace2.HitPos, 5, Color( 255, 0, 0 ), true )

	if trace2.Hit then
		return true
	end

	local endPos = ray.endpos
	endPos:Set( entity:GetPos() )
	endPos[ 3 ] = trace.HitPos[ 3 ]

	util.TraceLine( ray )

	debugoverlay.Axis( trace2.HitPos, trace2.HitNormal:Angle(), 5, 5, true)
	debugoverlay.Line( ray.start, trace2.HitPos, 5, Color( 0, 255, 0 ), true )

	if trace2.Hit then
		return true
	end

	endPos:Set( entity:WorldSpaceCenter() )
	endPos[ 3 ] = 0.5 * ( endPos[ 3 ] + trace.HitPos[ 3 ] )

	util.TraceLine( ray )

	debugoverlay.Axis( trace2.HitPos, trace2.HitNormal:Angle(), 5, 5, true)
	debugoverlay.Line( ray.start, trace2.HitPos, 5, Color( 0, 0, 255 ), true )

	return trace2.Hit
end

// Given a table of positions and a starting point, return a new table of the positions that have a clear line of sight to the starting point

function TFA.WonderWeapon.GetClearPaths( entity, position, tiles )
	local clearPaths = {}
	local filter = table.Copy(player.GetAll())
	table.Add( filter, entity )
	table.Add( filter, ents.FindByClass( "prop_physics" ) )
	table.Add( filter, ents.FindByClass( "prop_physics_multiplayer" ) )
	table.Add( filter, ents.FindByClass( "ph_prop" ) )

	for _, tile in pairs( tiles ) do
		local tr = util.TraceLine({
			start = position,
			endpos = tile,
			filter = filter,
			mask = MASK_PLAYERSOLID
		})
		
		if not tr.Hit and util.IsInWorld(tile) then
			table.insert( clearPaths, tile )
		end
	end

	return clearPaths
end

// Generate table of positions in all directions by the width of the entities collision bounds or an input distance

function TFA.WonderWeapon.GetSurroundingTiles( entity, position, distance )
	if distance == nil or not isnumber(distance) then
		distance = 1
	end

	local tiles = {}
	local x, y, z

	local maxBound = Vector()
	local minBound

	if IsValid( entity ) then
		if entity.GetHull then
			minBound, maxBound = entity:GetHull()
		else
			minBound, maxBound = entity:GetCollisionBounds()
		end
	end

	local checkRange = math.max(distance, maxBound.x, maxBound.y)

	for z = -1, 1, 1 do
		for y = -1, 1, 1 do
			for x = -1, 1, 1 do
				local testTile = Vector( x, y, z )
				testTile:Mul( checkRange )

				table.insert( tiles, position + testTile )
			end
		end
	end

	return tiles
end

// Check if an area around the input position is clear of obstructions for the given bounds

function TFA.WonderWeapon.IsCollisionBoxClear( position, mFilter, minBound, maxBound, robust )
	local tr = util.TraceHull({
		start = position,
		endpos = position + vector_up*maxBound[3],
		maxs = maxBound,
		mins = minBound,
		filter = mFilter,
		mask = MASK_PLAYERSOLID
	})

	if SERVER and robust then
		local corner1 = position + Vector(minBound[1], minBound[2], 0)
		//debugoverlay.Axis(corner1, angle_zero, 5, 4, true)
		if !util.IsInWorld(corner1) then
			return false
		end

		local corner2 = position + Vector(minBound[1], maxBound[2], 0)
		//debugoverlay.Axis(corner2, angle_zero, 5, 4, true)
		if !util.IsInWorld(corner2) then
			return false
		end

		local corner3 = position + Vector(maxBound[1], maxBound[2], 0)
		//debugoverlay.Axis(corner3, angle_zero, 5, 4, true)
		if !util.IsInWorld(corner3) then
			return false
		end

		local corner4 = position + Vector(maxBound[1], minBound[2], 0)
		//debugoverlay.Axis(corner4, angle_zero, 5, 4, true)
		if !util.IsInWorld(corner4) then
			return false
		end

		local corner5 = position + Vector(minBound[1], minBound[2], maxBound[3])
		//debugoverlay.Axis(corner5, angle_zero, 5, 4, true)
		if !util.IsInWorld(corner5) then
			return false
		end

		local corner6 = position + Vector(minBound[1], maxBound[2], maxBound[3])
		//debugoverlay.Axis(corner6, angle_zero, 5, 4, true)
		if !util.IsInWorld(corner6) then
			return false
		end

		local corner7 = position + Vector(maxBound[1], maxBound[2], maxBound[3])
		//debugoverlay.Axis(corner7, angle_zero, 5, 4, true)
		if !util.IsInWorld(corner7) then
			return false
		end

		local corner8 = position + Vector(maxBound[1], minBound[2], maxBound[3])
		//debugoverlay.Axis(corner8, angle_zero, 5, 4, true)
		if !util.IsInWorld(corner8) then
			return false
		end
	end

	return !tr.StartSolid
end

// Check if an entity should take damage / become afflicted
//  TFA.WonderWeapon.ShouldDamage(entity Target, entity Attacker, entity Inflictor) Inflictor should be the projectile entity, not the weapon the projectile came from

function TFA.WonderWeapon.ShouldTarget( target, attacker, inflictor )
end

function TFA.WonderWeapon.ShouldDamage( target, attacker, inflictor )
	if not IsValid(target) then
		return false
	end

	local isCharacter = ( target:IsNPC() or target:IsPlayer() or target:IsNextBot() )

	// if you need to override targetting / damaging behavior
	local override = hook.Run("TFA_WonderWeapon_ShouldDamage", target, attacker, inflictor)
	if override ~= nil then
		return override
	end

	// dont hit our self
	if IsValid(inflictor) and target == inflictor then
		return false
	end

	// dont hit players if pvp is off
	if IsValid(attacker) and attacker:IsPlayer() and target:IsPlayer() and !sbox_pvp:GetBool() then
		return false
	end

	// dont hit players in nzombies
	if target:IsPlayer() and nzombies and target ~= attacker then
		return false
	end

	// ignore dead/dying enemies
	if nzombies and target:IsValidZombie() and ( target.IsAlive and !target:IsAlive() or target.MarkedForDeath ) then
		return false
	end

	if isCharacter and target:GetInternalVariable("m_lifeState") ~= 0 then
		return false
	end

	// entity cant take damage (most likely a dynamic prop or physics object)
	if target:GetInternalVariable("m_takedamage") == 0 and !WonderWeapons.DoorClasses[ target:GetClass() ] then
		return false
	end

	// because why not
	if target:IsPlayer() and IsValid(attacker) and !hook.Run("PlayerShouldTakeDamage", target, attacker) then
		return false
	end

	// we dont hit npcs
	if !GetConVar("sv_tfa_bo3ww_friendly_fire"):GetBool() and IsValid(attacker) and target:IsNPC() and target:Disposition(attacker) == D_LI then
		return false
	end

	// npcs dont hit us (as an npc)
	if !GetConVar("sv_tfa_bo3ww_npc_friendly_fire"):GetBool() and IsValid(attacker) and attacker:IsNPC() and attacker:Disposition(target) == D_LI then
		return false
	end

	local owner = target:GetOwner()
	if IsValid( attacker ) and IsValid( owner ) then
		// dont hit stuff we own
		if ( owner == attacker ) then
			return false
		end

		// dont hit stuff others own if pvp is off or in nzombies
		if ( ( nzombies or !sbox_pvp:GetBool() ) and ( owner:IsPlayer() and attacker:IsPlayer() ) ) then
			return false
		end

		// dont hit stuff owned by friendly NPCs
		if ( owner:IsNPC() and owner.Disposition and owner:Disposition( attacker ) == D_LI ) then
			return false
		end
	end

	local parent = target:GetParent()
	if IsValid( parent ) and IsValid( attacker ) then
		// dont hit stuff we own
		if ( parent == attacker ) then
			return false
		end

		// dont hit stuff others own if pvp is off or in nzombies
		if ( ( nzombies or !sbox_pvp:GetBool() ) and ( parent:IsPlayer() and attacker:IsPlayer() ) ) then
			return false
		end

		// dont hit stuff owned by friendly NPCs
		if ( parent:IsNPC() and parent.Disposition and parent:Disposition( attacker ) == D_LI ) then
			return false
		end
	end

	// dont hit non characters except vehicles or missiles
	if !GetConVar("sv_tfa_bo3ww_environmental_damage"):GetBool() and !( isCharacter or ( GetConVar("sv_tfa_bo3ww_vehicle_damage"):GetBool() and target:IsVehicle() ) ) and ( ( target.Classify == nil or !isfunction( target.Classify ) ) or target:Classify() ~= CLASS_MISSILE ) then
		return false
	end

	// for campaign purposes
	if target.Classify and isfunction( target.Classify ) and WonderWeapons.ClassifyDamageIgnore[ target:Classify() ] then
		return false
	end

	return true
end

//  TFA.WonderWeapon.ShouldDamage(entity Target, entity Attacker, entity Inflictor) Inflictor should be the projectile entity, not the weapon the projectile came from

function TFA.WonderWeapon.ShouldCollide( target, attacker, inflictor )
	if not IsValid(target) then
		return false
	end

	local isCharacter = ( target:IsNPC() or target:IsPlayer() or target:IsNextBot() )

	// if you need to override projectile collision behavior
	local override = hook.Run("TFA_WonderWeapon_ShouldCollide", target, attacker, inflictor)
	if override ~= nil then
		return override
	end

	// dont hit our self
	if IsValid(inflictor) and target == inflictor then
		return false
	end

	// dont hit players if pvp is off
	if IsValid(attacker) and attacker:IsPlayer() and target:IsPlayer() and !sbox_pvp:GetBool() then
		return false
	end

	// dont hit owner for a bit
	if IsValid( inflictor ) and IsValid( attacker ) and target == attacker and inflictor:GetCreationTime() + 0.2 > CurTime() then
		return false
	end

	// ignore teammates
	if IsValid( attacker ) and GAMEMODE.TeamBased and target.Team and attacker.Team and isfunction( target.Team ) and isfunction( attacker.Team ) and target:Team() == attacker:Team() then
		return false
	end

	// dont hit players in nzombies
	if nzombies and target:IsPlayer() then
		return false
	end

	// ignore dead zombies
	if nzombies and target:IsValidZombie() and ( target.IsAlive and !target:IsAlive() or target.MarkedForDeath ) then
		return false
	end

	// ignore dead but not dying enemies (if they voluntarily have collisions enabled)
	if isCharacter and target:GetInternalVariable("m_lifeState") > 1 then
		return false
	end

	// entity cant take damage (most likely a dynamic prop or physics object)
	if target:GetInternalVariable("m_takedamage") == 0 then
		return false
	end

	// we dont hit npcs (in nzombies)
	if nzombies and IsValid(attacker) and target:IsNPC() and target:Disposition(attacker) == D_LI then
		return false
	end

	// npcs dont hit us (as an npc)
	if !GetConVar("sv_tfa_bo3ww_npc_friendly_fire"):GetBool() and IsValid(attacker) and attacker:IsNPC() and attacker:Disposition(target) == D_LI then
		return false
	end

	if nzombies then
		local owner = target:GetOwner()
		if IsValid( attacker ) and IsValid( owner ) then
			// dont hit stuff we own
			if ( owner == attacker ) then
				return false
			end

			// dont hit stuff others own
			if owner:IsPlayer() and attacker:IsPlayer() then
				return false
			end

			// dont hit stuff owned by friendly NPCs
			if ( owner:IsNPC() and owner.Disposition and owner:Disposition( attacker ) == D_LI ) then
				return false
			end
		end

		local parent = target:GetParent()
		if IsValid( parent ) and target:IsEffectActive( EF_BONEMERGE ) then
			return false
		end
	end

	// dont hit vehicles were in
	if IsValid( attacker ) and attacker:InVehicle() and target == attacker:GetVehicle() then
		return false
	end

	// for campaign purposes
	if target.Classify and WonderWeapons.ClassifyDamageIgnore[ target:Classify() ] then
		return false
	end

	return true
end

// yeah im getting lazy with this one

function TFA.WonderWeapon.DoBloodyFleshImpact( BloodColor, position, direction, hitsound )
	if hitsound and isstring( hitsound ) and file.Exists("sound/" .. hitsound, "GAME") then
		sound.Play( hitsound, position, SNDLVL_IDLE, math.random( 97, 103 ), 1 )
	end

	if BloodColor then
		if WonderWeapons.ParticleByBloodColor[ BloodColor ] then
			ParticleEffect( WonderWeapons.ParticleByBloodColor[ BloodColor ], position - direction, ( -direction ):Angle() )

			util.Decal( WonderWeapons.DecalByBloodColor[ BloodColor ], position, position + direction*24 )
		end
	else
		ParticleEffect( "blood_impact_red_01", position - direction, (-direction):Angle() )

		util.Decal( "Blood", position, position + direction*24 )
	end

	local debugstring = tostring(position)
	debugoverlay.Axis( position, -direction:Angle(), 5, 5, true )
	debugoverlay.Text( position + ( vector_up * 4 ), "DoBloodyFleshImpact ["..debugstring.."]", 5, false )
end

// Generic giblets model that has a blood trail effect and creates the correct blood impact effects / decals based on given blood color enum.
//  Works on both server and client, allowing for cheap clientside only gibs for visual flair.
//  Returns the gib prop that gets created.

if SERVER then
	// WARNING: This will get turned into a redirect for the clientside version later, thus it will not return an entity
	function TFA.WonderWeapon.CreateHorrorGib( position, angle, velocity, angleVelocity, lifetime, bloodcolor )
		if not position or not isvector( position ) or position:IsZero() then
			return
		end

		if not angle or not isangle( angle ) then
			angle = Angle( 0, math.random( -180, 180 ), 0 )
		end

		if not lifetime or not isnumber( lifetime ) or lifetime < 0 then
			lifetime = engine.TickInterval()
		end

		if not velocity or not isvector( velocity ) or velocity:IsZero() then
			velocity = Vector( math.random( -200, 200 ), math.random( -200, 200 ), math.random( 100, 250 ) )
		end

		if not angleVelocity or not isvector( angleVelocity ) then
			angleVelocity = Vector( 0, math.random( -1200, 1200 ), math.random( -200, 200 ) )
		end

		local serverGib = ents.Create( "prop_physics" )
		serverGib:SetPos( position )
		serverGib:SetAngles( angle )
		serverGib:SetModel( "models/zmb/gibs/p7_gib_chunk.mdl" )
		serverGib:SetBodygroup( 0, math.random( 0, 10 ) )

		serverGib:SetModelScale( math.Rand( 1, 1.5 ) )

		serverGib:PhysicsInit( SOLID_VPHYSICS )
		serverGib:SetMoveType( MOVETYPE_VPHYSICS )
		serverGib:SetSolid( SOLID_VPHYSICS )

		serverGib:SetCollisionGroup( COLLISION_GROUP_DEBRIS )

		serverGib.BloodColor = bloodcolor or DONT_BLEED

		serverGib:Spawn()

		timer.Simple(0, function()
			if not IsValid( serverGib ) then return end

			ParticleEffectAttach( "horror_bloodgibs", PATTACH_ABSORIGIN_FOLLOW, serverGib, 1 )
		end)

		local phys = serverGib:GetPhysicsObject()
		if IsValid( phys ) then
			phys:EnableMotion( true )
			phys:EnableDrag( true )

			phys:AddGameFlag( FVPHYSICS_NO_IMPACT_DMG )
			phys:SetBuoyancyRatio( 0.65 )
			phys:SetMass( 5 )

			phys:Wake()

			phys:AddAngleVelocity( angleVelocity )
			phys:SetVelocity( velocity )
		end

		SafeRemoveEntityDelayed( serverGib, lifetime )

		serverGib:AddCallback( "PhysicsCollide", function( _, data )
			if data.Speed < 60 then return end

			WonderWeapons.DoBloodyFleshImpact( serverGib.BloodColor, data.HitPos, data.HitNormal )
		end )


		return serverGib
	end
else
	function TFA.WonderWeapon.CreateHorrorGib( position, angle, velocity, angleVelocity, lifetime, bloodcolor )
		if not position or not isvector( position ) or position:IsZero() then
			return
		end

		if not angle or not isangle( angle ) then
			angle = Angle( 0, math.random( -180, 180 ), 0 )
		end

		if not lifetime or not isnumber( lifetime ) or lifetime < 0 then
			lifetime = engine.TickInterval()
		end

		if not velocity or not isvector( velocity ) or velocity:IsZero() then
			velocity = Vector( math.random( -200, 200 ), math.random( -200, 200 ), math.random( 100, 250 ) )
		end

		if not angleVelocity or not isvector( angleVelocity ) then
			angleVelocity = Vector( 0, math.random( -1200, 1200 ), math.random( -200, 200 ) )
		end

		local debugstring = tostring(position)
		debugoverlay.Axis( position, angle, 5, 5, true )
		debugoverlay.Text( position + ( vector_up * 4 ), "CreateHorrorGib ["..debugstring.."]", 5, false )

		local clientGib = ents.CreateClientProp( "models/zmb/gibs/p7_gib_chunk.mdl" )
		clientGib:SetPos( position )
		clientGib:SetAngles( angle )
		clientGib:SetModel( "models/zmb/gibs/p7_gib_chunk.mdl" )
		clientGib:SetBodygroup( 0, math.random(0, 10) )

		clientGib:SetModelScale( math.Rand(1, 1.5) )

		clientGib:PhysicsInit( SOLID_VPHYSICS )
		clientGib:SetMoveType( MOVETYPE_VPHYSICS )
		clientGib:SetSolid( SOLID_VPHYSICS )

		clientGib:SetCollisionGroup( COLLISION_GROUP_DEBRIS )

		clientGib.BloodColor = bloodcolor or DONT_BLEED

		clientGib:Spawn()

		local phys = clientGib:GetPhysicsObject()
		if IsValid( phys ) then
			phys:EnableMotion( true )
			phys:EnableDrag( true )

			phys:AddGameFlag( FVPHYSICS_NO_IMPACT_DMG )
			phys:SetBuoyancyRatio( 0.65 )
			phys:SetMass( 5 )

			phys:Wake()

			phys:AddAngleVelocity( angleVelocity )
			phys:SetVelocity( velocity )
		end

		ParticleEffectAttach( "horror_bloodgibs", PATTACH_ABSORIGIN_FOLLOW, clientGib, 1 )

		SafeRemoveEntityDelayed( clientGib, lifetime )

		clientGib:AddCallback( "PhysicsCollide", function( _, data )
			if data.Speed < 60 then return end

			WonderWeapons.DoBloodyFleshImpact( clientGib.BloodColor, data.HitPos, data.HitNormal )
		end )

		return clientGib
	end
end

// Specialist deploy radius damage and effect

function TFA.WonderWeapon.SpecialistDeploy( wep, ply, range )
	if CLIENT then return end
	if not IsValid(wep) or not IsValid(ply) then
		return
	end

	hook.Run("TFA_WonderWeapon_OnSpecialistDeployed", ply, wep, range)

	range = range or 100

	local damage = DamageInfo()
	damage:SetAttacker(ply)
	damage:SetInflictor(wep)
	damage:SetDamageType(nzombies and DMG_MISSILEDEFENSE or bit.bor(DMG_NEVERGIB, DMG_PREVENT_PHYSICS_FORCE))

	local tr = {
		start = ply:GetShootPos(),
		mask = MASK_SHOT,
	}

	for k, v in pairs(ents.FindInSphere(ply:GetShootPos(), range)) do
		if v:IsNPC() or v:IsNextBot() or v:IsPlayer() then
			if v == ply then continue end
			if !WonderWeapons.ShouldDamage(v, ply, wep) then continue end

			tr.endpos = v:WorldSpaceCenter()
			tr.filter = v
			tr.whitelist = true

			local tr1 = util.TraceLine(tr)
			if tr1.HitWorld then continue end

			if v:IsPlayer() then
				v:SetGroundEntity(nil)
				v:SetLocalVelocity(v:GetVelocity() + vector_up*80 + (v:GetPos() - wep:GetPos()):GetNormalized()*40)
				continue
			end

			local hitpos = tr1.Entity == v and tr1.HitPos or tr.endpos

			damage:SetDamage(nzombies and 75 or 125)
			damage:SetDamageForce(v:GetUp()*10000 + (v:GetPos() - wep:GetPos()):GetNormalized() * 15000)
			damage:SetDamagePosition(hitpos)

			local bBossZombie = (v.NZBossType or v.IsMooBossZombie or v.IsMooMiniBoss)
			local dist = v:GetPos():DistToSqr(ply:GetPos())

			if !bBossZombie and dist < 1600 then //40^2
				damage:SetDamage(v:Health() + 666)
			end

			if v:IsNPC() and v:Alive() and damage:GetDamage() >= v:Health() then
				v:SetCondition(COND.NPC_UNFREEZE)
			end

			v.SpecialistDeployHurt = true

			v:TakeDamageInfo(damage)

			v.SpecialistDeployHurt = nil
		end
	end
end

// When an NPC / NextBot dies, refill specialist ammo by amount set per the swep

function TFA.WonderWeapon.SpecialistAmmoRefil( npc, ply, inflictor )
	if not IsValid(npc) or not IsValid(ply) or not IsValid(inflictor) or not ply:IsPlayer() then return end

	for _, weapon in pairs(ply:GetWeapons()) do
		if weapon.IsTFAWeapon and weapon.NZSpecialCategory == "specialist" and inflictor:GetClass() ~= weapon:GetClass() then
			if weapon:Clip1() < weapon:GetStatL("Primary.ClipSize") then
				local clipsize = weapon:GetStatL("Primary.ClipSize")

				if weapon:Clip1() == clipsize then return end
				local amount = weapon.AmmoRegen or 1
				if nzombies and ply:HasPerk("time") then
					amount = math.Round(amount * 2)
				end

				weapon:SetClip1(math.Min(weapon:Clip1() + amount, clipsize))

				if weapon:Clip1() >= clipsize then
					if weapon.OnSpecialistRecharged then
						weapon:OnSpecialistRecharged()
						if SERVER then
							weapon:CallOnClient("OnSpecialistRecharged")
						end
					end

					hook.Run("TFA_WonderWeapon_OnSpecialistRecharged", ply, weapon, inflictor, npc)

					if ply:GetActiveWeapon() ~= weapon and weapon.IsTFAWeapon then
						weapon:ResetFirstDeploy()
						if SERVER and SinglePlayer then
							weapon:CallOnClient("ResetFirstDeploy")
						end
					end

					if SERVER then
						net.Start("TFA.BO3.QED_SND", true)
							net.WriteString("Specialist")
						net.Send(ply)
					end
				end
			end
		end
	end
end

// Returns a float of how much force is needed to accelerate the entity to the given speed. (hammer units per second)

function TFA.WonderWeapon.CalculateImpulseForce( entity, speed )
	if not IsValid(entity) then return end
	if not entity.GetPhysicsObject then return end

	if not speed or not isnumber( speed ) or speed < 0 then
		speed = 20
	end

	local simulation = physenv.GetPerformanceSettings()

	speed = math.min( speed, simulation and simulation.MaxVelocity or 4000 )

	local flHitForce = 5 * speed
	local flMass = 0

	for i=0, entity:GetPhysicsObjectCount() - 1 do
		local phys = entity:GetPhysicsObjectNum(i)
		if IsValid( phys ) then
			flMass = phys:GetMass() + flMass
		end
	end

	flHitForce = math.Clamp( flMass * speed, flHitForce, 60000 ) // maximum push force

	return flHitForce
end

if SERVER then
	util.AddNetworkString( "TFA.BO3WW.FOX.RagdollShock" )
	util.AddNetworkString( "TFA.BO3WW.FOX.RagdollPop" )
	util.AddNetworkString( "TFA.BO3WW.FOX.RagdollGib" )

	function TFA.WonderWeapon.GibRagdoll( entity, gibcount )
		if not IsValid( entity ) or not entity:IsRagdoll() then
			return
		end

		if not gibcount or not isnumber( gibcount ) or gibcount < 1 then
			local nPhysCount = math.max( entity:GetPhysicsObjectCount() , 1 )

			gibcount = math.Round( math.Clamp( ( nPhysCount / 3 ), 1, 5 ) )
		end

		gibcount = math.min( gibcount, 255 )

		net.Start( "TFA.BO3WW.FOX.RagdollGib", true )
			net.WriteEntity( entity )
			net.WriteUInt( gibcount, 8 )
		net.SendPVS( entity:GetPos() )
	end

	function TFA.WonderWeapon.ShockClientRagdolls( position, radius, upgraded )
		if not position or not isvector( position ) then return end

		if not radius or not isnumber( radius ) or radius <= 0 then
			radius = 8
		end

		if not upgraded or not isbool( upgraded ) then
			upgraded = false
		end

		radius = math.Clamp( math.abs(radius), 1, 0xFFFF )

		net.Start( "TFA.BO3WW.FOX.RagdollShock", true )
			net.WriteDouble( position[1] )
			net.WriteDouble( position[2] )
			net.WriteDouble( position[3] )
			net.WriteUInt( math.Round( radius ), 16 )
			net.WriteBool( upgraded )
		net.SendPVS( position )
	end

	function TFA.WonderWeapon.WavegunPopClientRagdolls( position, radius, gibcount )
		if not position or not isvector( position ) then return end

		if not radius or not isnumber( radius ) or radius <= 0 then
			radius = 8
		end

		if not upgraded or not isbool( upgraded ) then
			upgraded = false
		end

		radius = math.Clamp( math.abs(radius), 1, 0xFFFF )

		gibcount = math.Clamp( gibcount, 0, 0xFF )

		net.Start( "TFA.BO3WW.FOX.RagdollPop", true )
			net.WriteDouble( position[1] )
			net.WriteDouble( position[2] )
			net.WriteDouble( position[3] )
			net.WriteUInt( math.Round( radius ), 16 ) // 65536 - 1
			net.WriteUInt( math.Round( gibcount ), 8 ) // 256 - 1
		net.SendPVS( position )
	end

	function TFA.WonderWeapon.CreateRotorWash( position, angles, owner, flAltitude )
		if not IsValid( owner ) then
			return
		end

		if not position or not isvector( position ) or position:IsZero() then
			return
		end

		if not angles or not isangle( angles ) then
			angles = angle_zero
		end

		if not flAltitude or not isnumber( flAltitude ) then
			flAltitude = BASECHOPPER_WASH_ALTITUDE
		end

		local CRotorWashEmitter = ents.Create( "env_rotorwash_emitter" )

		if CRotorWashEmitter == NULL then
			return NULL
		end

		CRotorWashEmitter:SetPos( position )
		CRotorWashEmitter:SetAngles( angles )
		CRotorWashEmitter:SetParent( owner )

		CRotorWashEmitter:SetKeyValue( "m_flAltitude", tostring( flAltitude ) )
		CRotorWashEmitter:SetKeyValue( "m_bEmit", "false" )

		return CRotorWashEmitter
	end
end

local bMapPostCleanup = false
hook.Add("PostCleanupMap", "TFA.BO3WW.FOX.CleanupFixes", function()
	bMapPostCleanup = true
end)

function TFA.WonderWeapon.DoRadialBloodImpact( position, radius, count, bloodcolor, mask, collisiongroup, filter )
	if position == nil or !isvector( position ) or position:IsZero() then
		return
	end

	if bloodcolor == nil or ( !isstring(bloodcolor) or !isnumber(bloodcolor) ) then
		return
	end

	if radius == nil or not isnumber( radius ) or radius < 0 then
		radius = 144
	end

	if count == nil or not isnumber( count ) or count < 0 then
		count = 16
	end

	if mask == nil or not isnumber( mask ) then
		mask = bit.bor( MASK_SHOT, bit.bnot( CONTENTS_HITBOX ) )
	end

	if collisiongroup == nil or not isnumber( collisiongroup ) then
		collisiongroup = COLLISION_GROUP_NONE
	end

	if filter == nil or ( ( !istable( filter ) or !IsTableOfEntitiesValid(filter) ) or !IsValid( filter ) ) then
		filter = {}
	end

	if bMapPostCleanup then
		bMapPostCleanup = false
	end

	local ImpactEffect = WonderWeapons.ParticleByBloodColor[ bloodcolor ]
	local DecalEffect = WonderWeapons.DecalByBloodColor[ bloodcolor ]

	if (ImpactEffect == nil) and bloodcolor and bloodcolor == DONT_BLEED then return end

	for i = 1, count do
		local trace = {}
		local direction = VectorRand():GetNormalized()

		util.TraceLine( {
			start = position,
			endpos = radius * direction + position,
			mask = mask,
			filter = filter,
			output = trace
		} )

		local debugstring = tostring(trace.HitPos)
		debugoverlay.Text( position + ( vector_up * 4 ), "DoRadialBloodImpact ["..debugstring.."]", 5, false )

		if trace.Hit then
			timer.Create( "WonderWeapon.DoRadialBloodImpact", ( radius / 800 ) * trace.Fraction, 1, function()
				// Stop if map was cleaned up before impact
				if bMapPostCleanup then
					bMapPostCleanup = false
					return
				end

				debugoverlay.Axis( trace.HitPos, -direction:Angle(), 5, 5, true )

				if ImpactEffect then
					ParticleEffect(ImpactEffect or "blood_impact_red_01", trace.HitPos + trace.HitNormal*6, trace.HitNormal:Angle())
				end

				if DecalEffect then
					util.Decal(DecalEffect or "Blood", trace.HitPos, trace.HitPos + trace.Normal*32)
				end
			end )
		end
	end
end

if CLIENT then
	local RAGDOLL_FILTER = {
		"class C_ClientRagdoll",
		"class C_HL2MPRagdoll",
	}

	function TFA.WonderWeapon.GibRagdoll( entity, gibcount, velocity, angularvelocity, angle )
		if not IsValid( entity ) or not entity:IsRagdoll() then
			return
		end
		if not entity.GetPhysicsObject then
			return
		end

		local nPhysCount = math.max( entity:GetPhysicsObjectCount() , 1 )

		local nGibMult = GetConVar("cl_tfa_fx_wonderweapon_gibs_multiplier"):GetFloat()
		local nMaxGibs = GetConVar("cl_tfa_fx_wonderweapon_gibs_max"):GetInt()

		if not gibcount or not isnumber( gibcount ) or gibcount < 0 then
			gibcount = math.Round( math.Clamp( ( nPhysCount / 3 ), 1, nMaxGibs ) )
		end

		local owner = entity:GetRagdollOwner()

		local BloodColor = entity.BloodColor

		if IsValid( owner ) then
			if owner.GetBloodColor then
				BloodColor = owner:GetBloodColor()
			elseif owner.BloodColor then
				BloodColor = owner.BloodColor
			end
		end

		local nGibs = math.Clamp( gibcount * nGibMult, 1, nMaxGibs )
		local nGibCount = 0

		for i = 1, math.ceil( nGibMult ) do
			if nGibCount >= ( nGibs ) then
				break
			end

			local PhysTable = {}

			for i = 0, nPhysCount - 1 do
				if i + 1 > nGibs then
					break
				end

				local phys = entity:GetPhysicsObjectNum( i )
				if IsValid( phys ) then
					PhysTable[ 1 + #PhysTable ] = phys
				end
			end

			for i, phys in RandomPairs( PhysTable ) do
				nGibCount = 1 + nGibCount

				if nGibCount > ( nGibs ) then
					break
				end

				local vecMin, vecMax = phys:GetAABB()
				vecMin:Mul(0.5)
				vecMax:Mul(0.5)

				local startVec = phys:LocalToWorld( phys:GetMassCenter() ) + Vector( math.Rand(vecMin[1], vecMax[1]), math.Rand(vecMin[2], vecMax[2]), math.Rand(vecMin[3], vecMax[3]) )
				local vecVelocity = velocity or Vector( math.random( -20, 20 ), math.random( -20, 20 ), math.random( 0, 60 ) )
				local vecAngleVelocity = angularvelocity or Vector( 0, math.random( 400, 1200 ), 0 )
				local angFacing = angle or Angle(0, math.random( -180, 180 ), 0)

				WonderWeapons.CreateHorrorGib( startVec, angFacing, vecVelocity * math.Rand( 1, i ), vecAngleVelocity, math.Rand( 3, 4 ), BloodColor )
			end
		end
	end 

	// specifically for the waffe, but possibly usefull for other things later down the line

	function TFA.WonderWeapon.ShockClientRagdolls( position, radius, upgraded )
		if not position or not isvector( position ) then return end

		if not radius or not isnumber( radius ) or radius <= 0 then
			radius = 8
		end

		position.z = position.z + 1

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

						if trace.Hit and trace.Entity == ragdoll then
							local BloodColor = ragdoll.GetBloodColor and ragdoll:GetBloodColor() or ragdoll.BloodColor
							if WonderWeapons.ParticleByBloodColor[ BloodColor ] then
								ParticleEffect( WonderWeapons.ParticleByBloodColor[ BloodColor ], trace.HitPos, ( -trace.Normal ):Angle() )
							end

							WonderWeapons.DoDeathEffect( ragdoll, "BO3_Wunderwaffe", math.Rand( 4, 6 ), tobool( upgraded ), trace.HitGroup == HITGROUP_HEAD )
							break
						end
					end
				end
			end
		end
	end

	function TFA.WonderWeapon.WavegunPopClientRagdolls( position, radius, gibcount )
		if not position or not isvector( position ) then return end

		if not radius or not isnumber( radius ) or radius <= 0 then
			radius = 8
		end

		if not gibcount or not isnumber( gibcount ) or gibcount < 0 then
			gibcount = 3
		end

		position.z = position.z + 1

		for _, ragdoll in RandomPairs( ents.FindInSphere( position, radius ) ) do
			if CLIENT_RAGDOLLS[ ragdoll:GetClass() ] then
				for i = 0, ragdoll:GetPhysicsObjectCount() - 1 do
					local phys = ragdoll:GetPhysicsObjectNum( i )

					if IsValid( phys ) then
						local masscenter = phys:LocalToWorld(phys:GetMassCenter())

						local trace = util.TraceLine({
							start = position,
							endpos = masscenter,
							mask = MASK_SHOT,
							ignoreworld = false,
							hitclientonly = true,
						})

						if trace.Hit and trace.Entity == ragdoll then
							if gibcount > 0 then
								WonderWeapons.GibRagdoll( ragdoll, gibcount )
							end

							WonderWeapons.DoDeathEffect( ragdoll, "BO3_Wavegun_Pop" )
							break
						end
					end
				end
			end
		end
	end

	net.Receive( "TFA.BO3WW.FOX.RagdollGib", function( length, ply )
		local ragdoll = net.ReadEntity()
		if not IsValid( ragdoll ) then return end
		local gibcount = net.ReadUInt(8)

		WonderWeapons.GibRagdoll( ragdoll, gibcount )
	end)

	net.Receive( "TFA.BO3WW.FOX.RagdollShock", function( length, ply )
		local x = net.ReadDouble()
		local y = net.ReadDouble()
		local z = net.ReadDouble()
		local radius = net.ReadUInt( 16 )
		local upgraded = net.ReadBool()

		WonderWeapons.ShockClientRagdolls( Vector( x, y, z ), radius, upgraded )
	end)

	net.Receive( "TFA.BO3WW.FOX.RagdollPop", function( length, ply )
		local x = net.ReadDouble()
		local y = net.ReadDouble()
		local z = net.ReadDouble()
		local radius = net.ReadUInt( 16 )
		local mingibs = net.ReadUInt( 8 )
		local maxgibs = net.ReadUInt( 8 )

		WonderWeapons.WavegunPopClientRagdolls( Vector( x, y, z ), radius, mingibs, maxgibs )
	end)
end

// lots of custom blood effects

local alienEnums = {
	[BLOOD_COLOR_YELLOW] = true,
	[BLOOD_COLOR_ANTLION] = true,
}

local zombieEnums = {
	[BLOOD_COLOR_GREEN] = true,
	[BLOOD_COLOR_ZOMBIE] = true,
}

local zombieBloods = {
	["Green"] = true,
	["Zombie"] = true,
}

local alienBloods = {
	["Yellow"] = true,
	["Antlion"] = true,
}

local cyborgBloods = {
	["Robot"] = true,
	["Cyborg"] = true,
}

local synthBloods = {
	["Synth"] = true,
	["Hunter"] = true,
}

local acidBloods = {
	["AnlionWorker"] = true,
	["Anlion Worker"] = true,
	["Acid"] = true,
	["Toxic"] = true,
	["Glowing"] = true,
}

local mechBloods = {
	["Oil"] = true,
	["Mech"] = true,
	["Mechanical"] = true,
}

function TFA.WonderWeapon.GetBloodName( entity )
	if not IsValid( entity ) then
		return
	end

	local bloodenum = entity.GetBloodColor and entity:GetBloodColor()

	local bloodcolor = entity.BloodColor or entity.BloodType

	if CLIENT_RAGDOLLS[entity:GetClass()] then
		bloodenum = math.huge
	end

	if ( bloodcolor and isstring( bloodcolor ) ) or ( bloodenum ) then
		if ( bloodcolor and cyborgBloods[ bloodcolor ] ) or entity:GetClass() == "nz_zombie_walker_cyborg" then
			return WonderWeapons.BLOOD_CYBORG
		elseif ( bloodcolor and zombieBloods[ bloodcolor ] ) or ( bloodenum and zombieEnums[ bloodenum ] ) then
			return WonderWeapons.BLOOD_ZOMBIE
		elseif ( bloodcolor and alienBloods[ bloodcolor ] ) or ( bloodenum and alienEnums[ bloodenum ] ) then
			return WonderWeapons.BLOOD_ALIEN
		elseif ( bloodcolor and synthBloods[ bloodcolor ] ) or ( entity:GetClass() == "npc_hunter" or entity:GetModel() == "models/hunter.mdl" ) then
			return WonderWeapons.BLOOD_SYNTH
		elseif ( bloodcolor and acidBloods[ bloodcolor ] ) or ( bloodenum and bloodenum == BLOOD_COLOR_ANTLION_WORKER ) then
			return WonderWeapons.BLOOD_ACID
		elseif ( bloodcolor and mechBloods[ bloodcolor ] ) or ( bloodenum and bloodenum == BLOOD_COLOR_MECH ) then
			return WonderWeapons.BLOOD_MECH
		elseif ( bloodenum and bloodenum == DONT_BLEED ) then
			return WonderWeapons.DONT_BLEED
		else
			return WonderWeapons.BLOOD_RED
		end
	end

	if ( bloodcolor and isnumber( bloodcolor ) and bloodcolor > -1 ) then
		if zombieEnums[ bloodcolor ] then
			return WonderWeapons.BLOOD_ZOMBIE
		elseif alienEnums[ bloodcolor ] then
			return WonderWeapons.BLOOD_ALIEN
		elseif bloodcolor == BLOOD_COLOR_ANTLION_WORKER then
			return WonderWeapons.BLOOD_ACID
		elseif ( entity:GetClass() == "npc_hunter" or entity:GetModel() == "models/hunter.mdl" ) then
			return WonderWeapons.BLOOD_SYNTH
		elseif bloodcolor == BLOOD_COLOR_MECH then
			return WonderWeapons.BLOOD_MECH
		elseif bloodcolor == DONT_BLEED then
			return WonderWeapons.DONT_BLEED
		else
			return WonderWeapons.BLOOD_RED
		end
	end

	if bloodcolor ~= nil and ( ( isbool( bloodcolor ) and bloodcolor == false ) or ( isnumber(bloodcolor) and bloodcolor == -1 ) ) then
		return WonderWeapons.DONT_BLEED
	end

	return nil
end

// zombies dont take burn damage while on fire, fuck your self

WonderWeapons.BurnImmuneZombies = {
	["npc_zombie"] = true,
	["npc_zombie_torso"] = true,
	["npc_poisonzombie"] = true,
	["npc_fastzombie"] = true,
	["npc_fastzombie_torso"] = true,
	["npc_zombine"] = true,
}

function TFA.WonderWeapon.GetBurnDamage( entity )
	if ( entity.Classify and entity:Classify() == CLASS_ZOMBIE ) or WonderWeapons.BurnImmuneZombies[ entity:GetClass() ] then
		return bit.bor( DMG_BURN, DMG_DIRECT )
	else
		return DMG_BURN
	end
end

// just nZombies for now

function TFA.WonderWeapon.CanNoTargetPlayer( entity )
	if not IsValid( entity ) or not entity:IsPlayer() then
		return false
	end

	if nzombies then
		// Player has Zombie Blood Power-Up
		if nzPowerUps and nzPowerUps.IsPlayerPowerupActive and nzPowerUps:IsPlayerPowerupActive( entity, "zombieblood" ) then
			return false
		end

		// Player has In Plain Sight Gum
		if nzGum and nzGum.GetActiveGum then
			local activeGum = nzGum:GetActiveGum( entity )
			if activeGum and isstring( activeGum ) and activeGum == "in_plain_sight" and nzGum.IsWorking and nzGum:IsWorking( entity ) then
				return false
			end
		end

		// Player is stood in Vulture Aid Stink Mist
		if entity.HasVultureStink and entity:HasVultureStink() then
			return false
		end

		// Something else before this has already set the target priority of the player to none
		if entity.GetTargetPriority then
			local nTargetPriority = entity:GetTargetPriority()
			if nTargetPriority and isnumber( nTargetPriority ) and ( nTargetPriority == TARGET_PRIORITY_NONE ) then
				return false
			end
		end
	end

	return true
end

// because alot of effects will try to attach to generalized points on the body

WonderWeapons.HeadAttachmentName = WonderWeapons.HeadAttachmentName or {}
WonderWeapons.HeadAttachmentName["forward"] = 1 // HL1S / HL2 / DOD / CSS
WonderWeapons.HeadAttachmentName["head_fx_tag"] = 2 // nZombies
WonderWeapons.HeadAttachmentName["anim_attachment_head"] = 3
WonderWeapons.HeadAttachmentName["head_center"] = 4 // CSGO
WonderWeapons.HeadAttachmentName["head"] = 5
WonderWeapons.HeadAttachmentName["eyes"] = 6
WonderWeapons.HeadAttachmentName["eye"] = 7 // HL2 Robot Enemies
WonderWeapons.HeadAttachmentName["mouth"] = 8
WonderWeapons.HeadAttachmentName["attach_mouth"] = 9 // CS:GO

local HeadAttachments = WonderWeapons.HeadAttachmentName

function TFA.WonderWeapon.GetHeadAttachment( entity )
	if not IsValid( entity ) then return end

	local head = 0
	local lowest = math.huge

	for id, data in RandomPairs( entity:GetAttachments() ) do
		local priority = HeadAttachments[data.name]
		if priority and priority < lowest then
			lowest = priority
			head = data.id
		end
	end

	local attachmentData = WonderWeapons.ModelAttachmentPoints[ entity:GetModel() ]
	if attachmentData and attachmentData["head"] then
		head = attachmentData["head"]
	end

	return ( head and isnumber( head ) and head > 0 ) and head or nil
end

WonderWeapons.ChestAttachmentName = WonderWeapons.ChestAttachmentName or {}
WonderWeapons.ChestAttachmentName["chest"] = 1
WonderWeapons.ChestAttachmentName["spine_fx_tag"] = 2 // nZombies
WonderWeapons.ChestAttachmentName["chest_fx_tag"] = 3 // nZombies
WonderWeapons.ChestAttachmentName["back_lower"] = 4 // TF2
WonderWeapons.ChestAttachmentName["back_upper"] = 5 // TF2
WonderWeapons.ChestAttachmentName["beam_damage"] = 6 // HL2 Combine
WonderWeapons.ChestAttachmentName["upper_spine"] = 7 // L4D2
WonderWeapons.ChestAttachmentName["spine"] = 8 // HL2 / L4D2

local ChestAttachments = WonderWeapons.ChestAttachmentName

function TFA.WonderWeapon.GetChestAttachment( entity )
	local chest = 0
	local lowest = math.huge

	for id, data in RandomPairs( entity:GetAttachments() ) do
		local priority = ChestAttachments[data.name]
		if priority and priority < lowest then
			lowest = priority
			chest = data.id
		end
	end

	local attachmentData = WonderWeapons.ModelAttachmentPoints[ entity:GetModel() ]
	if attachmentData and attachmentData["chest"] then
		chest = attachmentData["chest"]
	end

	return ( chest and isnumber( chest ) and chest > 0 ) and chest or nil
end

WonderWeapons.RHandAttachmentName = WonderWeapons.RHandAttachmentName or {}
WonderWeapons.RHandAttachmentName["anim_attachment_RH"] = 1 // HL2
WonderWeapons.RHandAttachmentName["righthand"] = 2 // L4D2
WonderWeapons.RHandAttachmentName["weapon_bone"] = 3 //HL2 / TF2
WonderWeapons.RHandAttachmentName["hand_R"] = 4 // TF2
WonderWeapons.RHandAttachmentName["RHand"] = 5
WonderWeapons.RHandAttachmentName["effect_hand_R"] = 6 // TF2
WonderWeapons.RHandAttachmentName["rightclaw"] = 7 // HL1S Zombies
WonderWeapons.RHandAttachmentName["Blood_Right"] = 8 // HL2 Zombies
WonderWeapons.RHandAttachmentName["physgun_attachment"] = 9 // GMOD
WonderWeapons.RHandAttachmentName["weapon_hand_R"] = 10 // CS:GO

local RHandAttachments = WonderWeapons.RHandAttachmentName

WonderWeapons.LHandAttachmentName = WonderWeapons.LHandAttachmentName or {}
WonderWeapons.LHandAttachmentName["anim_attachment_LH"] = 1 // HL2
WonderWeapons.LHandAttachmentName["lefthand"] = 2 // L4D2
WonderWeapons.LHandAttachmentName["weapon_bone_L"] = 3 // HL2
WonderWeapons.LHandAttachmentName["hand_L"] = 4 // TF2
WonderWeapons.LHandAttachmentName["LHand"] = 5
WonderWeapons.LHandAttachmentName["effect_hand_L"] = 6 // TF2
WonderWeapons.LHandAttachmentName["leftclaw"] = 7 // HL1S Zombies
WonderWeapons.LHandAttachmentName["Blood_Left"] = 8 // HL2 Zombies
WonderWeapons.LHandAttachmentName["weapon_hand_L"] = 10 // CS:GO
WonderWeapons.LHandAttachmentName["L_weapon_bone"] = 11 // TF2

local LHandAttachments = WonderWeapons.LHandAttachmentName

function TFA.WonderWeapon.GetHandsAttachment( entity )
	local handR, handL = 0, 0

	local lowest = math.huge

	for id, data in RandomPairs( entity:GetAttachments() ) do
		local priority = RHandAttachments[data.name]
		if priority and priority < lowest then
			lowest = priority
			handR = data.id
		end
	end

	lowest = math.huge

	for id, data in RandomPairs( entity:GetAttachments() ) do
		local priority = LHandAttachments[data.name]
		if priority and priority < lowest then
			lowest = priority
			handL = data.id
		end
	end

	local attachmentData = WonderWeapons.ModelAttachmentPoints[ entity:GetModel() ]

	if attachmentData and attachmentData["rhand"] then
		handR = attachmentData["rhand"]
	end

	if attachmentData and attachmentData["lhand"] then
		handL = attachmentData["lhand"]
	end

	if ( handR and isnumber( handR ) and handR > 0 ) or ( handL and isnumber( handL ) and handL > 0 ) then
		return handR, handL
	end

	return nil
end

WonderWeapons.REyeAttachmentName = WonderWeapons.REyeAttachmentName or {}
WonderWeapons.REyeAttachmentName["righteye"] = 1
WonderWeapons.REyeAttachmentName["UNUSED_righteye"] = 2 // nZombies
WonderWeapons.REyeAttachmentName["eyeglow_R"] = 4 // TF2
WonderWeapons.REyeAttachmentName["eye_R"] = 5 // CS:GO
WonderWeapons.REyeAttachmentName["top_eye"] = 9 // EP2 Mini Strider

local REyeAttachment = WonderWeapons.REyeAttachmentName

WonderWeapons.LEyeAttachmentName = WonderWeapons.LEyeAttachmentName or {}
WonderWeapons.LEyeAttachmentName["lefteye"] = 1
WonderWeapons.LEyeAttachmentName["UNUSED_lefteye"] = 2 // nZombies
WonderWeapons.LEyeAttachmentName["eyeglow_L"] = 4 // TF2
WonderWeapons.LEyeAttachmentName["eye_L"] = 5 // CS:GO
WonderWeapons.LEyeAttachmentName["bottom_eye"] = 9 // EP2 Mini Strider

local LEyeAttachment = WonderWeapons.LEyeAttachmentName

function TFA.WonderWeapon.GetEyesAttachment( entity )
	local eyeR, eyeL = 0, 0

	local lowest = math.huge

	for id, data in RandomPairs( entity:GetAttachments() ) do
		local priority = REyeAttachment[data.name]
		if priority and priority < lowest then
			lowest = priority
			eyeR = data.id
		end
	end

	lowest = math.huge

	for id, data in RandomPairs( entity:GetAttachments() ) do
		local priority = LEyeAttachment[data.name]
		if priority and priority < lowest then
			lowest = priority
			eyeL = data.id
		end
	end

	local attachmentData = WonderWeapons.ModelAttachmentPoints[ entity:GetModel() ]
	if attachmentData and attachmentData["reye"] then
		eyeR = attachmentData["reye"]
	end

	if attachmentData and attachmentData["leye"] then
		eyeL = attachmentData["leye"]
	end

	if ( eyeR and isnumber( eyeR ) and eyeR > 0 ) or ( eyeL and isnumber( eyeL ) and eyeL > 0  ) then
		return eyeR, eyeL
	end

	return nil
end

WonderWeapons.FaceAttachmentName = WonderWeapons.FaceAttachmentName or {}
WonderWeapons.FaceAttachmentName["eyes"] = 1
WonderWeapons.FaceAttachmentName["facemask"] = 2 // CS:GO

local FaceAttachments = WonderWeapons.FaceAttachmentName

function TFA.WonderWeapon.GetEyeAttachment( entity )
	local eyes = 0
	local lowest = math.huge

	for id, data in RandomPairs( entity:GetAttachments() ) do
		local priority = FaceAttachments[data.name]
		if priority and priority < lowest then
			lowest = priority
			eyes = data.id
		end
	end

	local attachmentData = WonderWeapons.ModelAttachmentPoints[ entity:GetModel() ]
	if attachmentData and attachmentData["eyes"] then
		eyes = attachmentData["eyes"]
	end

	if ( eyes and isnumber( eyes ) and eyes > 0  ) then
		return eyes
	end

	return nil
end

WonderWeapons.MouthAttachmentName = WonderWeapons.MouthAttachmentName or {}
WonderWeapons.MouthAttachmentName["mouth"] = 1
WonderWeapons.MouthAttachmentName["attach_mouth"] = 2 // CS:GO

local MouthAttachments = WonderWeapons.MouthAttachmentName

function TFA.WonderWeapon.GetMouthAttachment( entity )
	if not IsValid( entity ) then return end

	local mouth = 0
	local lowest = math.huge

	for id, data in RandomPairs( entity:GetAttachments() ) do
		local priority = MouthAttachments[data.name]
		if priority and priority < lowest then
			lowest = priority
			mouth = data.id
		end
	end

	local attachmentData = WonderWeapons.ModelAttachmentPoints[ entity:GetModel() ]
	if attachmentData and attachmentData["mouth"] then
		mouth = attachmentData["mouth"]
	end

	return ( mouth and isnumber( mouth ) and mouth > 0  ) and mouth or nil
end
