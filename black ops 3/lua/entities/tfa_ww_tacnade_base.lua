AddCSLuaFile()

ENT.Base = "tfa_ww_base"
ENT.PrintName = "Thrown Wonder Weapon Projectile"

ENT.ThrowSound = nil // sound emits with entity on init
ENT.ThrowSoundPaP = nil

ENT.HideModel = false
ENT.DontUseRollAngle = false

ENT.HintSoundOnBounce = false
ENT.HintSoundType = SOUND_DANGER
ENT.HintSoundRadius = 500
ENT.HintSoundDuration = 0.2

ENT.NPCAttractRange = 1024
ENT.NPCAttractTauntRange = 40
ENT.NPCAttractRequireLOS = false

ENT.NextBotAttractRange = 1024

ENT.SpawnGravityEnabled = true

ENT.SurfacePropOverride = "metal_bouncy" // default bouncy for grenades

ENT.DisablePhysicsOnActivate = true // sets velocity to 0 and calls Phys:EnableMotion(false) and Phys:Sleep()
ENT.ParentToMoveableEntities = true // if the projectiles ground entity is MOVETYPE_PUSH or a vehicle the projectile will be parented to said entity

ENT.BounceVelocityRatio = 0.4 // percentage of velocity to retain after each bounce (40% of velocity from before the bounce)

ENT.BounceActivationSpeed = 100

ENT.BounceSound = nil //
ENT.BounceSoundMaterials = nil // table of sounds by MAT_ enum type, see QED for example

local CurTime = CurTime
local IsValid = IsValid

local bit_AND = bit.band

local util_TraceLine = util.TraceLine
local util_TraceHull = util.TraceHull
local util_PointContents = util.PointContents
local util_ScreenShake = util.ScreenShake

local DispatchEffect = util.Effect

local MASK_SHOT = MASK_SHOT
local MAT_GLASS = MAT_GLASS
local CONTENTS_SLIME = CONTENTS_SLIME
local CONTENTS_LIQUID = bit.bor( CONTENTS_WATER, CONTENTS_SLIME )
local MASK_RADIUS_DAMAGE = bit.band( MASK_SHOT, bit.bnot( CONTENTS_HITBOX ) )
local COLLISION_GROUP_BREAKABLE_GLASS = COLLISION_GROUP_BREAKABLE_GLASS

local sv_friendly_fire = GetConVar("sv_tfa_bo3ww_friendly_fire")
local sv_npc_friendly_fire = GetConVar("sv_tfa_bo3ww_npc_friendly_fire")
local sv_npc_require_los = GetConVar("sv_tfa_bo3ww_monkeybomb_use_los")

DEFINE_BASECLASS(ENT.Base)

if SERVER then
	function ENT:GravGunPickupAllowed()
		return not self:GetActivated()
	end
end

function ENT:GravGunPunt()
	return not self:GetActivated()
end

function ENT:Draw()
	if not self.DontUseRollAngle then
		self:SetRenderAngles(self:GetRoll())
	end

	if not self.HideModel then
		self:DrawModel()
	end
end

function ENT:SetupDataTables()
	BaseClass.SetupDataTables(self)

	self:NetworkVarTFA("Bool", "Activated")
	self:NetworkVarTFA("Angle", "Roll")
end

function ENT:PhysicsCollide(data, phys)
	if self:GetActivated() then return end

	self:StoreCollisionEventData(data)

	if data.Speed > ( self.BounceActivationSpeed or 100 ) then
		if self.BounceSoundMaterials then
			local finalsound = self.BounceSoundMaterials[0]

			local surfaceData = util.GetSurfaceData(data.TheirSurfaceProps)
			if surfaceData and surfaceData.material then
				finalsound = self.BounceSoundMaterials[surfaceData.material] or finalsound
			end

			self:EmitSound(finalsound)
		elseif self.BounceSound then
			self:EmitSound(self.BounceSound)
		end

		if self.HintSoundOnBounce then
			sound.EmitHint( self.HintSoundType or SOUND_DANGER, data.HitPos, ( self.HintSoundRadius or 500 ), ( self.HintSoundDuration or 0.2), IsValid(self:GetOwner()) and self:GetOwner() or self )
		end

		if self.ImpactBubbles and bit_AND( util_PointContents( data.HitPos ), CONTENTS_LIQUID ) ~= 0 and data.OurOldVelocity:Length() > 170 then
			local fx = EffectData()
			fx:SetOrigin( data.HitPos )
			fx:SetNormal( data.HitNormal )
			fx:SetMagnitude( self.ImpactBubblesMagnitude or math.Clamp( ( self.Damage / 100 ) + ( self.Range / 100 ), 1, 12 ) )
			fx:SetRadius( self.ImpactBubblesSize or math.Clamp( ( math.pow( self.Damage / 100, 0.2 ) * self.Range ) / 2, 16, 64 ) )

			DispatchEffect( "tfa_bo3_bubble_explosion", fx )
		end
	end

	if data.Speed < ( self.BounceActivationSpeed or 100 ) and data.HitNormal[2] < 0.7 then
		local hitEntity = data.HitEntity
		if self.ParentToMoveableEntities and ( hitEntity:GetMoveType() == MOVETYPE_PUSH or hitEntity:IsVehicle() ) then
			self:SetParent( hitEntity )
		end

		self:ActivateCustom( phys )

		if self.DisablePhysicsOnActivate then
			self:SetSolidFlags( bit.bor( FSOLID_NOT_STANDABLE, FSOLID_NOT_SOLID, FSOLID_TRIGGER, FSOLID_TRIGGER_TOUCH_DEBRIS ) )
			self:AddEFlags( EFL_NO_PHYSCANNON_INTERACTION )

			self:PhysicsStop( phys )

			timer.Simple( 0, function()
				if not IsValid( self ) then return end

				self:PhysicsInitStatic( SOLID_VPHYSICS )
				self:PhysicsStop()
			end )
		end
	else
		local LastSpeed = math.max( data.OurOldVelocity:Length(), data.Speed )

		local NewVelocity = phys:GetVelocity()
		NewVelocity:Normalize()

		LastSpeed = math.max( NewVelocity:Length(), LastSpeed )
		local TargetVelocity = NewVelocity * LastSpeed * self.BounceVelocityRatio

		phys:SetVelocity( TargetVelocity )
	end
end

function ENT:Think()
	if SERVER then
		local phys = self:GetPhysicsObject()
		local groundEnt = self:GetGroundEntity()

		if not self:GetActivated() and self:IsOnGround() and IsValid(phys) and phys:GetVelocity():Length() < 10 and not (groundEnt:IsNPC() or groundEnt:IsPlayer() or groundEnt:IsNextBot()) then
			if self.ParentToMoveableEntities and ( groundEnt:GetMoveType() == MOVETYPE_PUSH or groundEnt:IsVehicle() ) then
				self:SetParent( groundEnt )
			end

			self:ActivateCustom( phys )

			if self.DisablePhysicsOnActivate then
				self:PhysicsInitStatic( SOLID_VPHYSICS )

				self:SetSolidFlags( bit.bor( FSOLID_NOT_STANDABLE, FSOLID_NOT_SOLID, FSOLID_TRIGGER, FSOLID_TRIGGER_TOUCH_DEBRIS ) )
				self:AddEFlags( EFL_NO_PHYSCANNON_INTERACTION )
				
				self:PhysicsStop()
			end
		end
	end

	return BaseClass.Think(self)
end

function ENT:Initialize()
	if self.ForcedKillTime and self.ForcedKillTime > 0 then
		SafeRemoveEntityDelayed( self, self.ForcedKillTime )
	end

	BaseClass.Initialize( self )

	self:SetCollisionGroup( COLLISION_GROUP_PROJECTILE )

	self:AddEFlags( EFL_DONTWALKON )
	self:AddEFlags( EFL_NO_DAMAGE_FORCES )

	if self:GetUpgraded() then
		self.ThrowSound = self.ThrowSoundPaP or self.ThrowSound
	end

	if self.ThrowSound then
		self:EmitSound(self.ThrowSound)
	end

	local ply = self:GetOwner()

	local phys = self:GetPhysicsObject()
	if IsValid( phys ) then
		phys:AddGameFlag( FVPHYSICS_NO_IMPACT_DMG )
	end

	self:SetRoll( self:GetAngles() )
end

function ENT:GetRandomSpawnPoint()
	//self:BuildSpawnPoints()

	local ply = self:GetOwner()

	local spawn = GAMEMODE:PlayerSelectSpawn( ply, false )
	if ( IsValid( spawn ) ) then
		self.LastSpawnPoint = spawn
		return spawn:GetPos()
	end

	/*if GAMEMODE.TeamBased then
		local spawn = GAMEMODE:PlayerSelectTeamSpawn( ply:Team(), ply )
		if ( IsValid( spawn ) ) then
			return spawn:GetPos()
		end
	end

	local count = table.Count(self.SpawnPoints)
	local spawn

	-- Try to work out the best, random spawnpoint
	for i = 1, count do
		spawn = table.Random(self.SpawnPoints)
		if IsValid(spawn) and spawn:IsInWorld() then
			if spawn == self.LastSpawnPoint and count > 1 then continue end
			if hook.Call("IsSpawnpointSuitable", GAMEMODE, ply, spawn, i == count) then
				self.LastSpawnPoint = spawn
				return spawn:GetPos()
			end
		end
	end*/
end

function ENT:BuildSpawnPoints()
	if !IsTableOfEntitiesValid(self.SpawnPoints) then
		self.LastSpawnPoint = 0
		self.SpawnPoints = ents.FindByClass( "info_player_start" )
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_deathmatch" ) )
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_combine" ) )
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_rebel" ) )

		-- Portal 2 Coop
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_coop_spawn" ) )

		-- CS Maps
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_counterterrorist" ) )
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_terrorist" ) )

		-- DOD Maps
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_axis" ) )
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_allies" ) )

		-- (Old) GMod Maps
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "gmod_player_start" ) )

		-- TF Maps
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_teamspawn" ) )

		-- INS Maps
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "ins_spawnpoint" ) )

		-- AOC Maps
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "aoc_spawnpoint" ) )

		-- Dystopia Maps
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "dys_spawn_point" ) )

		-- PVKII Maps
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_pirate" ) )
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_viking" ) )
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_knight" ) )

		-- DIPRIP Maps
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "diprip_start_team_blue" ) )
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "diprip_start_team_red" ) )

		-- OB Maps
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_red" ) )
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_blue" ) )

		-- SYN Maps
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_coop" ) )

		-- ZPS Maps
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_human" ) )
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_zombie" ) )

		-- ZM Maps
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_zombiemaster" ) )

		-- FOF Maps
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_fof" ) )
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_desperado" ) )
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_vigilante" ) )

		-- L4D Maps
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_survivor_rescue" ) )
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_survivor_position" ) )

		-- NEOTOKYO Maps
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_attacker" ) )
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_defender" ) )

		-- Fortress Forever Maps
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_ff_teamspawn" ) )
	end
end
