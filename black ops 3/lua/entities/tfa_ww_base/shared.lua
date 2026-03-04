// Info
ENT.Type = "anim"
ENT.PrintName = "Wonder Weapon Projectile"
ENT.Author = "FlamingFox"
ENT.Contact = ""
ENT.Purpose = ""
ENT.Instructions = ""
ENT.DoNotDuplicate = true
ENT.DisableDuplicator = true

local nzombies = engine.ActiveGamemode() == "nzombies"

local developer = GetConVar("developer")

local SinglePlayer = game.SinglePlayer()

// Credits

// TFA Base Devs (Code)
// DBot (Code)
// Hidden (Code, Inspiration)
// ValsdalV (Code, converted SDK-2013 C++ functions to LUA)

//----------------------------------------------------------------------------------------------------
// please remember to call BaseClass when modifying existing functions, especially ENT:SetupDataTables !!!
//----------------------------------------------------------------------------------------------------

// Generic Settings

ENT.Delay = 10 // how long the projectile exists until it is removed

ENT.Range = 100 // range of explosion (and screenshake if not set separately)

ENT.Damage = 100 // damage of explosion, or things that you code to use it

ENT.InfiniteDamage = false // will cause wonder weapon to do infinite damage in nzombies (or if convar is on) when using ENTITY:GetTrueDamage( otherEnt )

ENT.HullMaxs = Vector(2, 2, 2) // THIS IS USED FOR BOTH TRACE BASED COLLISIONS AND THE VPHYS OBJECT (always a sphere by default) (x + y + z) / 3
ENT.HullMins = ENT.HullMaxs:GetNegated() // unless set to specifically use the models collision mesh
ENT.SizeOverride = nil // use to override VPhys sphere size if not using collision mesh

ENT.RemoveOnKilltimeEnd = true // remove the entity when self.killtime returns < CurTime(), this should almost always be true

ENT.ShouldUseCollisionModel = false // if projectile should use the models collision mesh instead of generic sphere

ENT.ShouldDestroyWindows = true // destroy breakable windows *before* the projectile would impact it allowing it to pass through
ENT.ShatterGlass = false // instantly destroy the entire window instead of only destroying where the projectile passed through

ENT.RemoveInWater = false // remove projectile if created inside water, or the frame before we enter water (self.IsUnderWater is still set to true before self:Remove() is called)

// Sound Settings

ENT.FluxSound = nil // sound attached to the entity on initialize
ENT.FluxSoundPaP = nil

ENT.StartSound = nil // sound emitted at spawn position on initialize
ENT.StartSoundPaP = nil

// Trail Settings

ENT.TrailSound = nil // called on initialized, usefull for looping sounds as StopSound is called OnRemove
ENT.TrailSoundPaP = nil

ENT.TrailEffect = nil // particle effect attached to entity on initialize
ENT.TrailEffectPaP = nil

ENT.TrailAttachType = PATTACH_ABSORIGIN_FOLLOW
ENT.TrailAttachPoint = 1

ENT.TrailOffset = Vector() //if you need to offset the position of the trail on the projectile
ENT.TrailOffsetPaP = Vector()

// Effect Settings

ENT.NoDrawNoShadow = false // for energy projectiles that dont have a model or shadow

ENT.BubbleTrail = true // emit bubbles when underwater (requires phys object and is based on velocity)

ENT.ImpactDecal = nil // place down a decal when self:DoImpactEffect() is called

ENT.BigImpactEffect = false // calls 'ImpactJeep' effect instead of 'Impact' (2x bigger impact effects)
ENT.BiggerImpactEffect = false // calls 'ImpactGunship' effect instead of 'Impact' (3x bigger impact effects)

ENT.ImpactBubbles = true // create small bubble explosion when projectile impacts underwater
ENT.ImpactBubblesSize = nil // the radius that the bubbles will burst outwards (in hammer units). Will be autocalculated if left blank (not super consistent)
ENT.ImpactBubblesMagnitude = nil // amount to scale bubble emission count by (1 is 16, 2 is 32, 3 is 48, 4 is 64, etc). Will be autocalculated if left blank (not super consistent)

// Explosion Settings

ENT.ExplodeOnRemove = false // call ENT:Explode from within an OnRemove callback function
ENT.ExplodeOnKilltimeEnd = false // call ENT:Explode when CurTime() elapses self.killtime and the projectile is going to be removed (requires self.RemoveOnKilltimeEnd to be true)

ENT.ExplosionDamageType = nzombies and DMG_BLAST or bit.bor( DMG_BLAST, DMG_AIRBOAT ) // damage type

ENT.ExplosionUseWeaponAsInflictor = nzombies and true or false // Legacy, see https://wiki.facepunch.com/gmod/CTakeDamageInfo:SetInflictor // inflictor for explosion will be set to the weapon that created the projectile instead of the projectile it self ( for addons made before CTakeDamageInfo:SetWeapon() )

ENT.ExplosionSortedEntities = true // should the list of nearby entities used in ENTITY:Explode() be sorted by distance to explosion source

ENT.ExplosionInterposingReduceDamage = nzombies and false or true // if an entity stands between the explosion source and the victim reduce damage by ( objectMass / maxBlockingMass ), ( 75 (average humanoid mass) / 350 ) would be ~21% damage reduction
ENT.ExplosionInterposingBlockDamage = false // if an entity stands between the explosion source and the victim, block all damage instead
ENT.ExplosionMaxBlockingMass = 350 // maximum mass for the interposing object to completely reduce the damage to 0 (ex: player is hid behind a dumpster prop)

ENT.ExplosionHeadShotScale = 3 // how much damage to scale explosion headshots by
ENT.ExplosionHitsOwner = false // should explosion damage the owner player
ENT.ExplosionOwnerDamage = 150 // maximum damage to do to owner entity

ENT.WaterBlockExplosions = false // explosions outside of water wont damage entities in water, explosions in water wont damage entities outside of water ( default source behavior )

--[[ // credit to user 'lurker' on Spring Engine forums
				 edgeEffectiveness
				 0     0.2    0.4    0.6    0.8    0.9    0.95
Distance -------------------------------------------------
   10%   |   0.9   0.92   0.94   0.96   0.98   0.99   0.99
   20%   |   0.8   0.83   0.87   0.91   0.95   0.98   0.99
   30%   |   0.7   0.74   0.8    0.85   0.92   0.96   0.98
   40%   |   0.6   0.65   0.71   0.79   0.88   0.94   0.97
   50%   |   0.5   0.56   0.63   0.71   0.83   0.91   0.95
   60%   |   0.4   0.45   0.53   0.63   0.77   0.87   0.93
   70%   |   0.3   0.35   0.42   0.52   0.68   0.81   0.9
   80%   |   0.2   0.24   0.29   0.38   0.56   0.71   0.83
   90%   |   0.1   0.12   0.16   0.22   0.36   0.53   0.69
   100%  |   0     0      0      0      0      0      0
			----Falloff Factor
]]

// Explosion Damage Calculation ( final damage will never be less than half the starting damage )
// Falloff = 1 - ( ( Radius - DistanceTo ) / ( Radius - DistanceTo * edgeEffectiveness ) )
// AdjustedDamage = ( Damage * Falloff ) / 2
// FinalDamage = Damage - AdjustedDamage

ENT.ExplosionDamageFalloff = nzombies and false or true // do damage falloff
ENT.ExplosionEdgeEffectiveness = nzombies and 0.89 or 0.5 // ( 0 - 1 ) see chart above to get a basic idea of how this works
ENT.ExplosionInnerRadiusScale = 0.25 // ( 0 - 1 ) what percentage of the explosion's radius will be instant and do max damage
ENT.ExplosionEdgeSpillRadiusScale = 0.5 // ( 0 - 1 ) what percentage of the explosion's radius will it attempt to 'spill' around corners to damage entities that are slightly out of LOS

// Projectile Lodging (sticky)

ENT.ShouldLodgeProjectile = false // if projectile should get parented/stick to entities hit on collision
ENT.ShouldDropProjectile = true // if projectile should be dropped when the parent entity is dead or dying (if applicable)
ENT.ParentOffset = 2 // how far, in the opposite direction the projectile was traveling, to offset from point of impact when sticking
ENT.ParentAlign = false // align with hitnormal when parenting

// Explosion Effect Settings

ENT.ExplosionBubbles = true // emit bubbles when Explode() is called underwater
ENT.ExplosionBubblesSize = nil // the radius that the bubbles will burst outwards (in hammer units). Will be autocalculated if left blank (not super consistent)
ENT.ExplosionBubblesMagnitude = nil // amount to scale bubble emission count by (1 is 16, 2 is 32, 3 is 48, 4 is 64, etc). Will be autocalculated if left blank (not super consistent)

ENT.ExplosionScreenShake = true // call util.ScreenShake when exploding ONLY when CurTime() elapses self.killtime and ENT.ExplodeOnKilltimeEnd equals true! (you must still call screenshake manually when calling ENTITY:Explode() yourself)
ENT.ExplosionShakeRopes = true // call "ShakeRopes" util.effect within DoExplosionEffect
ENT.ExplosionTracerSound = true // can either be a bool or a string for a custom Whizby sound to be played after each DispatchTraceAttack call in self:Explode()
ENT.ExplosionTracers = true // call "Tracer" util.effect when the explosion trace hits its target

ENT.ExplosionEmitHint = true // use sound.EmitHint to better help NPCs react to the explosion
ENT.WaterSurfaceExplosion = true // testing
ENT.ExplosionTraceDecal = false // place decal on non character entities hit by explosion traces
ENT.ExplosionImpactDecal = "Scorch" // decal that gets placed on non character entities hit by explosion traces (effect disabled by default via ENT.ExplosionTraceDecal variable)
ENT.ExplosionTraceWaterSplash = true // call "watersplash" util.effect if the explosion hit target is outside of water while we are submerged ( or vice versa )

ENT.ExplosionEffectAngleCorrection = nil --Angle(0,0,0) // if the explosion effect is oriented on an axist other than X, use this to correct it (some insurgency effects use the Z axis)
ENT.ExplosionEffect = nil // as on tin
ENT.ExplosionEffectPaP = nil

ENT.ExplosionSound = nil // as on tin
ENT.ExplosionSound1 = nil
ENT.ExplosionSound2 = nil
ENT.ExplosionSound3 = nil
ENT.ExplosionSound4 = nil

// Optimizations

ENT.DoTransmitWithParent = false // set to true if we can parent to another entity without worrying about our parent dying or being removed (very few cases)
ENT.StopTransmitToParent = false // set to true if we dont need to worry about drawing ourselves to the entity we are parented to (like a player)

// Entity Search Settings

ENT.FindSolidOnly = false // require entities returned by self:FindNearestEntities() to be solid (seems to filter out ragdolls aswell)
ENT.FindCharacterOnly = false // require entities returned by self:FindNearestEntities() to be either an NPC, Player, or NextBot

// DLight Settings

ENT.ColorPaP = nil
ENT.Color = nil // DLight color

ENT.DLightAttachment = nil // use attachment for dlight position
ENT.DLightBrightness = 1 // dlight brightness for trail dlight
ENT.DLightDecay = 2000 // dlight decay rate for trail dlight
ENT.DLightSize = 200 // dlight size for trail dlight
ENT.DLightOffset = Vector() // offset for dlight (each vector component is relative to the objects Forward, Side, and Up facing directions)

ENT.DLightFlashOnRemove = false // flash a bright light using self.Color and the variables below when entity is removed
ENT.DLightOnActivated = false // if the entity has the network variable 'Activated' require the bool to return true for the dlight to show
ENT.DLightFlashSize = 250 // dlight size for flash
ENT.DLightFlashDecay = 2000 // dlight decay rate for flash
ENT.DLightFlashBrightness = 2 // dlight brightness for flash

// Other

ENT.CustomNetworkVar = {}

function ENT:NetworkVarTFA(typeIn, nameIn)
	if not self.TrackedDTTypes then
		self.TrackedDTTypes = {
			Angle = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31},
			Bool = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31},
			Entity = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31},
			Float = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31},
			Int = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31},
			String = {0, 1, 2, 3},
			Vector = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31},
		}

		if istable(self.dt) then
			local meta = getmetatable(self.dt)

			if istable(meta) and isfunction(meta.__index) then
				local name, value = debug.getupvalue(meta.__index, 1)

				if name == "datatable" and istable(value) then
					for variableName, variableData in SortedPairs(value) do
						if istable(variableData) and isstring(variableData.typename) and isnumber(variableData.index) then
							local trackedData = self.TrackedDTTypes[variableData.typename]

							if trackedData then
								table.RemoveByValue(trackedData, variableData.index)
							end
						end
					end
				end
			end
		end
	end

	if not self.TrackedDTTypes[typeIn] then
		error("Variable type " .. typeIn .. " is invalid")
	end

	local gatherindex = table.remove(self.TrackedDTTypes[typeIn], 1)

	if gatherindex then
		(self["NetworkVar_TFA"] or self["NetworkVar"])(self, typeIn, gatherindex, nameIn)
		return
	end

	local get = self["GetNW2" .. typeIn]
	local set = self["SetNW2" .. typeIn]

	self["Set" .. nameIn] = function(_self, value)
		set(_self, nameIn, value)
	end

	self["Get" .. nameIn] = function(_self, def)
		return get(_self, nameIn, def)
	end

	if developer:GetBool() then
		print("[TFA Base] developer 1: Variable " .. nameIn .. " can not use DTVars due to " .. typeIn .. " index exhaust")
	end
end

function ENT:SetupDataTables()
	self.TrackedDTTypes = nil
	self.NetworkVar_TFA = self.NetworkVar

	self:NetworkVarTFA("Bool", "Upgraded")
	self:NetworkVarTFA("Vector", "HitPos")

	if self.ProjectileHoming then
		self:NetworkVarTFA("Entity", "Target")
	end

	if self.CustomNetworkVar and istable( self.CustomNetworkVar ) and next( self.CustomNetworkVar ) ~= nil then
		for vartype, name in pairs( self.CustomNetworkVar ) do
			if self.TrackedDTTypes[ vartype ] then
				self:NetworkVarTFA( vartype, name )
			end
		end
	end
end

// use this if a certain entitiy should or should not be included in tables returned by self:FindNearestEntities()
function ENT:ShouldIncludeNearbyEntity( possibleTarget, position, radius, ignoreentities, ignoreworld )
	--return false // to block including given entity
end
