
AddCSLuaFile()

ENT.Base = "tfa_ww_base"
ENT.PrintName = "Ragnarok DG4"

// Settings

ENT.ConsumptionRate = 1

ENT.TakenAmmo = 0

ENT.VortexStartSound = "TFA_BO3_DG4.Vortex.Start"
ENT.VortexLoopSound = "TFA_BO3_DG4.Vortex.Loop"
ENT.VortexEndSound = "TFA_BO3_DG4.Vortex.End"

// Default Settings

ENT.Delay = 60
ENT.Range = 160

ENT.InfiniteDamage = true

ENT.NoDrawNoShadow = true

ENT.FindSolidOnly = true

ENT.HullMaxs = Vector(1, 1, 1)
ENT.HullMins = ENT.HullMaxs:GetNegated()

ENT.TrailEffect = "bo3_dg4_placed"
ENT.TrailAttachType = PATTACH_ABSORIGIN_FOLLOW
ENT.TrailAttachPoint = 1
ENT.TrailEffectActiveLooping = true

ENT.BubbleTrail = false

// nZombies

ENT.NZThrowIcon = Material("vgui/icon/hud_talonspikes.png", "unlitgeneric smooth")
ENT.NZHudIcon = Material("vgui/icon/hud_talonspikes.png", "smooth unlitgeneric")

DEFINE_BASECLASS(ENT.Base)

local nzombies = engine.ActiveGamemode() == "nzombies"
local dlight_cvar = GetConVar("cl_tfa_fx_wonderweapon_dlights")
local damage_cvar = GetConVar("sv_tfa_bo3ww_environmental_damage")

local CurTime = CurTime
local IsValid = IsValid

local bit_AND = bit.band

local util_TraceLine = util.TraceLine
local util_PointContents = util.PointContents
local util_ScreenShake = util.ScreenShake

local MASK_SHOT = MASK_SHOT
local MAT_GLASS = MAT_GLASS
local CONTENTS_SLIME = CONTENTS_SLIME
local CONTENTS_LIQUID = bit.bor( CONTENTS_WATER, CONTENTS_SLIME )
local MASK_RADIUS_DAMAGE = bit.band( MASK_SHOT, bit.bnot( CONTENTS_HITBOX ) )
local COLLISION_GROUP_BREAKABLE_GLASS = COLLISION_GROUP_BREAKABLE_GLASS

local SF_BUTTON_SPARK_IF_OFF = 4096

local vector_down = Vector(0, 0, -32)
local vector_down_ragdoll = Vector(0, 0, -64)

local BodyTarget = TFA.WonderWeapon.BodyTarget
local GiveStatus = TFA.WonderWeapon.GiveStatus
local DoDeathEffect = TFA.WonderWeapon.DoDeathEffect

local CLIENT_RAGDOLLS = {
	["class C_ClientRagdoll"] = true,
	["class C_HL2MPRagdoll"] = true,
}

local PHYS_PROPS = {
	["prop_physics"] = true,
	["prop_physics_multiplayer"] = true,
	["func_physbox"] = true,
	["func_physbox_multiplayer"] = true,
}

local STATIC_PROPS = {
	["prop_dynamic"] = true,
	["prop_dynamic_override"] = true,
	["prop_door_rotating"] = true,
	["func_door_rotating"] = true,
	["func_door"] = true,
}

function ENT:SetupDataTables()
	BaseClass.SetupDataTables(self)

	self:NetworkVarTFA("Bool", "Activated")
	self:NetworkVarTFA("Int", "AmmoCount")
	self:NetworkVarTFA("Float", "NextAmmo")
	self:NetworkVarTFA("Entity", "Weapon")
end

if CLIENT then
	function ENT:GetNZTargetText()
		local ply = self:GetOwner()
		if not IsValid(ply) then return end

		return ply:Nick().."'s - Ragnarok DG4s"
	end

	function ENT:GetNZTargetText2()
		if not self:GetActivated() then
			return
		end

		local prc = math.Clamp(self:GetAmmoCount() / 100, 0, 1)*100
		return prc.."%"
	end
end

if SERVER then
	function ENT:GravGunPickupAllowed()
		return false
	end
end

function ENT:GravGunPunt()
	return false
end

function ENT:Initialize(...)
	BaseClass.Initialize(self, ...)

	self:SetMoveType( MOVETYPE_NONE )

	self:EmitSound(self.VortexStartSound)
	self:EmitSound(self.VortexLoopSound)

	self:PhysicsStop()

	self:SetActivated(true)

	if CLIENT then return end

	self:SetNextAmmo(CurTime() + engine.TickInterval())

	self.BlockCollisionTrace = true

	self:CreatePlacedModel()
end

function ENT:CreatePlacedModel()
	local ply = self:GetOwner()

	local model1 = ents.Create("prop_dynamic")
	model1:SetModel("models/weapons/tfa_bo3/dg4/dg4_prop.mdl")
	model1:SetAngles(self:GetAngles() - Angle(0,90,0))
	model1:SetSolid(SOLID_NONE)
	model1:SetMoveType(MOVETYPE_NONE)

	model1:SetOwner(IsValid(ply) and ply or self)

	model1.AutomaticFrameAdvance = true
	model1:SetSequence(model1:LookupSequence("idle_open"))

	model1:SetParent(self)
	model1:SetPos((self:GetPos() + self:GetRight()*-18))

	model1:Spawn()

	self.CloneModelA = model1

	local model2 = ents.Create("prop_dynamic")
	model2:SetModel("models/weapons/tfa_bo3/dg4/dg4_prop.mdl")
	model2:SetAngles(self:GetAngles() - Angle(0,90,0))
	model2:SetSolid(SOLID_NONE)
	model2:SetMoveType(MOVETYPE_NONE)

	model2:SetOwner(IsValid(ply) and ply or self)

	model2.AutomaticFrameAdvance = true
	model2:SetSequence(model2:LookupSequence("idle_open"))

	model2:SetParent(self)
	model2:SetPos((self:GetPos() + self:GetRight()*18))

	model2:Spawn()

	self.CloneModelB = model2
end

local flLastGravityTick = 0

function ENT:Think()
	if CLIENT and dlight_cvar:GetInt() == 1 and DynamicLight then
		local dlight = dlight or DynamicLight(self:EntIndex(), false)
		if dlight then
			dlight.pos = self:GetPos()
			dlight.dir = self:GetUp()
			dlight.r = 45
			dlight.g = 165
			dlight.b = 255
			dlight.brightness = self:GetActivated() and 4 or 1
			dlight.Decay = 2000
			dlight.Size = self:GetActivated() and 256 or 128
			dlight.dietime = CurTime() + 0.5
		end
	end

	if ( damage_cvar and damage_cvar:GetBool() ) and self:GetAmmoCount() > 0 and self:GetActivated() and flLastGravityTick ~= CurTime() and self:GetCreationTime() + 0.25 < CurTime() then
		flLastGravityTick = CurTime()
		self:AntiGravityWell()
	end

	if SERVER then
		local wep = self:GetWeapon()

		if not IsValid(self:GetOwner()) then
			self:StopSound(self.VortexLoopSound)
			self:Remove()
			return false
		end

		if (self:GetAmmoCount() <= 0 or self.TakenAmmo >= 100 or (IsValid(wep) and (nzombies and wep:Clip1() or wep:Ammo1()) <= 0)) and self:GetActivated() then
			self:DisableVortex()
		end

		if self:GetAmmoCount() > 0 and self:GetActivated() then
			if nzombies and nzRound then
				self:RevivePlayers()
			end

			self:DoRadiusDamage()

			if self:GetNextAmmo() < CurTime() then
				self:SetAmmoCount(math.max(self:GetAmmoCount() - 5, 0))

				if IsValid(wep) then
					if nzombies then
						wep:SetClip1( math.max( wep:Clip1() - 5, 0 ) )
					else
						local ply = wep:GetOwner()
						if IsValid( ply ) then
							ply:SetAmmo( math.max( wep:Ammo1() - 5, 0 ), wep:GetPrimaryAmmoType() )
						end
					end
				end

				self.TakenAmmo = self.TakenAmmo + 5
				self:SetNextAmmo(CurTime() + self.ConsumptionRate)
			end
		end
	end

	return BaseClass.Think(self)
end

local liftclasses = {
	["nz_zombie_boss_fireman"] = true,
	["nz_zombie_boss_krasny"] = true,
	["nz_zombie_boss_panzer"] = true,
	["nz_zombie_boss_panzer_bo3"] = true,
}

function ENT:DisableVortex()
	self:SetActivated(false)

	//self:StopParticles()

	ParticleEffect("bo3_dg4_finish", self:GetPos(), angle_zero)

	self:StopSound(self.VortexLoopSound)
	self:EmitSound(self.VortexEndSound)

	if self.CloneModelA and IsValid(self.CloneModelA) then
		ParticleEffectAttach("bo3_dg4_dead", PATTACH_ABSORIGIN_FOLLOW, self.CloneModelA, 1)
	end

	if self.CloneModelB and IsValid(self.CloneModelB) then
		ParticleEffectAttach("bo3_dg4_dead", PATTACH_ABSORIGIN_FOLLOW, self.CloneModelB, 1)
	end

	util_ScreenShake(self:GetPos(), 10, 255, 1.5, 512)

	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:SetCollisionGroup(COLLISION_GROUP_WORLD)

	SafeRemoveEntityDelayed(self, 30)
end

function ENT:RevivePlayers()
	local ply = self:GetOwner()
	local position = self:GetPos()

	for _, v in pairs(nzRound:InState(ROUND_CREATE) and player.GetAll() or player.GetAllPlaying()) do
		if v:IsPlayer() and v:Alive() and !v:GetNotDowned() and !v.DownedWithSoloRevive and v:GetPos():DistToSqr(position) < 25600 and v:IsLineOfSightClear(position + vector_up) then
			v.DownedWithSoloRevive = true
			v:StartRevive(v)

			timer.Simple(2, function()
				if not IsValid(v) or v:GetNotDowned() then return end

				v:RevivePlayer(v)

				if v.OldPerks then
					for _, perk in pairs(v.OldPerks) do
						v:GivePerk(perk)
					end
				end

				if v.DownPoints then
					v:GivePoints(tonumber(v.DownPoints))
				end
			end)
		end
	end
end

function ENT:AntiGravityWell()
	local ply = self:GetOwner()

	for _, ent in ipairs(ents.FindInSphere(self:GetPos(), self.Range)) do

		// lift ragdolls into the air by a constant force and arc up to 3 random phys segments, applying a random angular velocity

		if ( CLIENT and CLIENT_RAGDOLLS[ent:GetClass()] ) or ( SERVER and ent:IsRagdoll() ) then
			local phys = ent:GetPhysicsObject()

			local groundTrace = util.TraceLine({
				start = ent:GetPos(),
				endpos = ent:GetPos() + vector_down_ragdoll,
				mask = MASK_SOLID_BRUSHONLY,
				filter = { ent, self },
			})

			local nPhysCount = math.max( ent:GetPhysicsObjectCount() , 1 )

			local nJolts = 0
			local nJoltChance = math.Clamp( math.ceil( nPhysCount / 3 ), 1, 3 )
			local nLastJoltPhys = 0

			if IsValid( phys ) and phys:GetMass() < 102 and groundTrace.HitWorld then
				ent:SetGroundEntity(nil)

				phys:EnableMotion(true)
				phys:Wake()

				for i=0, nPhysCount - 1 do
					local phys_i = ent:GetPhysicsObjectNum( i )
					if IsValid( phys_i ) then
						local bShouldJolt = ( math.random( nJoltChance ) == 1 or ( nLastJoltPhys + nJoltChance <= i ) )

						if ( !ent.NextRagnarokJolt or ent.NextRagnarokJolt < CurTime() ) and bShouldJolt and nJolts < 3 then
							nLastJoltPhys = i
							nJolts = 1 + nJolts

							phys_i:AddAngleVelocity( VectorRand():GetNormalized() * 2000 )

							if IsValid( phys_i ) then
								local fx = EffectData()
								fx:SetStart( self:GetPos() )
								fx:SetOrigin( phys_i:LocalToWorld( phys_i:GetMassCenter() ) )

								util.Effect( "tfa_bo3_dg4_jump", fx )
							end
						end

						phys_i:EnableMotion(true)
						phys_i:Wake()

						local flMass = phys_i:GetMass()
						local up = 100*(1 - groundTrace.Fraction)

						local force = ( flMass * physenv.GetGravity():GetNegated() ) + vector_up * ( ( 1 * up ) * flMass )
						local delta = engine.TickInterval()

						phys_i:ApplyForceCenter( force * delta )
					end
				end

				if ( !ent.NextRagnarokJolt or ent.NextRagnarokJolt < CurTime() ) then
					ent.NextRagnarokJolt = CurTime() + math.Rand(0.4, 1)
				end
			end

			continue
		end

		if CLIENT then continue end

		// cause buttons to spark

		if ent:GetClass() == 'func_button' and ent:GetInternalVariable( 'm_bLocked' ) == true and !ent:HasSpawnFlags( SF_BUTTON_SPARK_IF_OFF ) and ( !ent.NextRagnarokJolt or ent.NextRagnarokJolt < CurTime() ) then
			ent.NextRagnarokJolt = CurTime() + math.Rand( 0, 1.5 )

			local fx = EffectData()
			fx:SetOrigin(ent:WorldSpaceCenter())
			fx:SetRadius(1)
			fx:SetMagnitude(2)
			fx:SetScale(1)
			fx:SetNormal(ent:GetUp())
			fx:SetEntity(ent)

			util.Effect( "ElectricSpark", fx )

			ent:EmitSound( "DoSpark" )

			continue
		end

		// lift physics objects into the air and apply a random angular velocity when arcing to the the prop

		if PHYS_PROPS[ent:GetClass()] then
			local phys = ent:GetPhysicsObject()

			local groundTrace = util.TraceLine({
				start = ent:GetPos(),
				endpos = ent:GetPos() + vector_down,
				mask = MASK_SOLID_BRUSHONLY,
				filter = { ent, self },
			})

			if IsValid( phys ) and phys:IsMotionEnabled() and phys:IsMotionEnabled() and phys:GetMass() < 202 and groundTrace.HitWorld then
				ent:SetGroundEntity(nil)
				if phys:IsAsleep() then
					phys:Wake()
				end

				if !ent.NextRagnarokJolt or ent.NextRagnarokJolt < CurTime() then
					phys:AddAngleVelocity(VectorRand():GetNormalized()*400)
					ent.NextRagnarokJolt = CurTime() + math.Rand(0.4, 1)

					if SERVER and IsValid( phys ) then
						local vecMin, vecMax = phys:GetAABB()
						vecMin:Mul(0.2)
						vecMax:Mul(0.2)

						local fx = EffectData()
						fx:SetStart(self:GetPos())
						fx:SetOrigin(phys:LocalToWorld(phys:GetMassCenter()) + ( Vector( math.Rand(vecMin[1], vecMax[1]), math.Rand(vecMin[2], vecMax[2]), math.Rand(vecMin[3], vecMax[3]) ) ))

						util.Effect("tfa_bo3_dg4_jump", fx)
					end
				end

				local flMass = 0

				for i=0, ent:GetPhysicsObjectCount() - 1 do
					local phys_i = ent:GetPhysicsObjectNum(i)
					if IsValid( phys_i ) then
						flMass = phys_i:GetMass() + flMass
					end
				end

				local up = 20*(1 - groundTrace.Fraction)

				local force = ( flMass * physenv.GetGravity():GetNegated() ) + vector_up * ( ( math.abs(math.sin((CurTime()) + ent:EntIndex()*8)) * up ) * flMass )
				local delta = engine.TickInterval()

				phys:ApplyForceCenter( force * delta )
			end

			continue
		end

		// arc to static props

		if STATIC_PROPS[ent:GetClass()] then
			local trace = util.TraceLine({
				start = self:GetPos(),
				endpos = ent:WorldSpaceCenter(),
				mask = MASK_RADIUS_DAMAGE,
				filter = { self, self.CloneModelA, self.CloneModelB },
			})

			if trace.Entity == ent and ( !ent.NextRagnarokJolt or ent.NextRagnarokJolt < CurTime() ) then
				ent.NextRagnarokJolt = CurTime() + math.Rand(0.1, 1.5)

				if ent.GetPhysicsObject then
					local phys = ent:GetPhysicsObject()
					if IsValid( phys ) then
						local vecMin, vecMax = phys:GetAABB()
						vecMin:Mul(0.5)
						vecMax:Mul(0.5)

						local fx = EffectData()
						fx:SetStart(self:GetPos())
						fx:SetOrigin(phys:LocalToWorld(phys:GetMassCenter()) + ( Vector( math.Rand(vecMin[1], vecMax[1]), math.Rand(vecMin[2], vecMax[2]), math.Rand(vecMin[3], vecMax[3]) ) ))

						util.Effect("tfa_bo3_dg4_jump", fx)
					end
				else
					local vecMin, vecMax = ent:GetCollisionBounds()
					vecMin:Mul(0.5)
					vecMax:Mul(0.5)

					local fx = EffectData()
					fx:SetStart(self:GetPos())
					fx:SetOrigin(ent:WorldSpaceCenter() + ( Vector( math.Rand(vecMin[1], vecMax[1]), math.Rand(vecMin[2], vecMax[2]), math.Rand(vecMin[3], vecMax[3]) ) ))

					util.Effect("tfa_bo3_dg4_jump", fx)
				end
			end
		end
	end
end

function ENT:DoRadiusDamage()
	local position = self:GetPos()

	local ply = self:GetOwner()

	local nearbyEnts = self:FindNearestEntities( self:GetPos(), self.Range )

	local tr = {
		start = position,
		filter = { self, self.Inflictor },
		mask = MASK_SHOT,
		collsiongroup = COLLISION_GROUP_NONE,
	}

	local pPlayer = ( IsValid(self:GetOwner()) and self:GetOwner() or self )
	local pWeapon = ( IsValid(self.Inflictor) and self.Inflictor or self )
	local pInflictor = self

	local bSubmerged = bit_AND( util_PointContents( position + vector_up*24 ), CONTENTS_LIQUID ) ~= 0

	for k, ent in ipairs(nearbyEnts) do
		if liftclasses[ent:GetClass()] or ent.CanPanzerLift then
			GiveStatus(ent, "BO3_Ragnarok_Lift_Boss", 0.5)
			continue
		end

		if ent:IsWeapon() then
			continue
		end

		if STATIC_PROPS[ent:GetClass()] or PHYS_PROPS[ent:GetClass()] or ent:IsRagdoll() then
			continue
		end

		local hitCharacter = ent:IsPlayer() or ent:IsNPC() or ent:IsNextBot()
		//if not hitCharacter then continue end

		local vecSpot = BodyTarget(ent, position, true)

		local dir = ( vecSpot - position ):GetNormalized()

		tr.endpos = vecSpot

		local trace = util_TraceLine(tr)

		local damageinfo = DamageInfo()
		damageinfo:SetDamage( self:GetTrueDamage(ent) )
		damageinfo:SetDamageType( DMG_ENERGYBEAM )
		damageinfo:SetAttacker( pPlayer )
		damageinfo:SetInflictor( nzombies and pWeapon or pInflictor )
		damageinfo:SetDamageForce( ent:GetUp() * math.random(12000,16000) + dir * math.random(6000,8000) )
		damageinfo:SetDamagePosition( trace.Entity == ent and trace.HitPos or vecSpot )
		damageinfo:SetReportedPosition( position )

		if IsValid(self.Inflictor) then
			damageinfo:SetWeapon( self.Inflictor )
		end

		if ent:IsNPC() and ent:Alive() and damageinfo:GetDamage() >= ent:Health() then
			ent:SetCondition(COND.NPC_UNFREEZE)
		end

		if hitCharacter then
			DoDeathEffect( ent, "BO3_Ragnarok", math.Rand( 2.5, 4 ) )
		end

		if SERVER then
			local fx = EffectData()
			fx:SetStart(self:GetPos())
			fx:SetOrigin(vecSpot)

			util.Effect("tfa_bo3_dg4_jump", fx)
		end

		if trace.Entity == ent then
			trace.HitGroup = trace.HitGroup == HITGROUP_HEAD and HITGROUP_HEAD or HITGROUP_GENERIC

			local hitInWater = bit_AND( util_PointContents( trace.HitPos ), CONTENTS_LIQUID ) ~= 0
			if ( hitInWater and !bSubmerged ) or ( bSubmerged and !hitInWater ) then
				local trace2 = {}

				util_TraceLine({
					start = trace.StartPos,
					endpos = trace.HitPos,
					mask = CONTENTS_LIQUID,
					output = trace2,
				})

				local data = EffectData()
				data:SetOrigin( trace2.HitPos )
				data:SetNormal( trace2.HitNormal )
				data:SetScale( math.random(2,4) )
				data:SetFlags( bit_AND( trace2.Contents, CONTENTS_SLIME ) != 0 && 1 || 0 )

				DispatchEffect( "watersplash", data, false, true )
			end

			if ent:GetCollisionGroup() == COLLISION_GROUP_BREAKABLE_GLASS or ent:Health() > 0 then
				self:DoImpactEffect( trace, true )

				ent:DispatchTraceAttack( damageinfo, trace, dir )
			else
				ent:TakeDamageInfo( damageinfo )
			end
		else
			ent:TakeDamageInfo( damageinfo )
		end

		self:IgnoreEntity( ent, 1/3 )

		table.insert( tr.filter, ent )

		self:SendHitMarker( ent, damageinfo, trace )
	end

	util_ScreenShake(position, 4, 255, 0.1, self.Range*1.5)
end

function ENT:OnRemove()
	self:StopParticles()

	self:StopSound(self.VortexLoopSound)

	self:ReturnToOwner()
end

function ENT:ReturnToOwner()
	local ply = self:GetOwner()
	if SERVER and IsValid(ply) then
		ply:EmitSound("weapon_bo3_cloth.med")
		self:EmitSound("weapon_bo3_gear.rattle")

		if not nzombies then
			ply:Give("tfa_bo3_dg4", true)

			local wep = ply:GetWeapon("tfa_bo3_dg4")
			if IsValid(wep) then
				wep.IsFirstDeploy = true
			end
		end
	end
end

function ENT:Use(act, cal)
	if CLIENT then return end
	if self:GetActivated() then return end

	if IsValid(act) and act == self:GetOwner() then
		self:Remove()
	end
end
