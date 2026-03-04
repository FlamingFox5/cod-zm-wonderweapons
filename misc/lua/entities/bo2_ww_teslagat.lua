AddCSLuaFile()

--[Info]--
ENT.Base = "tfa_exp_base"
ENT.PrintName = "Tesla Flechette"

--[Parameters]--
ENT.Delay = 10
ENT.Life = 6

ENT.Range = 80
ENT.BlastRange = 120

ENT.HullMaxs = Vector( 2, 2, 2 )
ENT.HullMins = ENT.HullMaxs:GetNegated()
ENT.ParentOffset = 2

DEFINE_BASECLASS(ENT.Base)

local nzombies = engine.ActiveGamemode() == "nzombies"
local dlight_cvar = GetConVar("cl_tfa_fx_wonderweapon_dlights")

local CurTime = CurTime
local IsValid = IsValid

local bit_AND = bit.band
local ents_FindInBox = ents.FindInBox
local game_GetWorld = game.GetWorld

local util_TraceLine = util.TraceLine
local util_TraceHull = util.TraceHull
local util_PointContents = util.PointContents
local util_ScreenShake = util.ScreenShake

local MASK_SHOT = MASK_SHOT
local MAT_GLASS = MAT_GLASS
local CONTENTS_SLIME = CONTENTS_SLIME
local CONTENTS_LIQUID = bit.bor( CONTENTS_WATER, CONTENTS_SLIME )
local COLLISION_GROUP_BREAKABLE_GLASS = COLLISION_GROUP_BREAKABLE_GLASS

local WorldToLocal = WorldToLocal
local EffectData = EffectData
local DispatchEffect = util.Effect
local SinglePlayer = game.SinglePlayer()

local LIFE_ALIVE = 0 // alive

local DoWaterSplashEffect
local FindHullIntersection
local DoImpactEffect

function ENT:SetupDataTables()
	self:NetworkVar("Bool", 0, "Upgraded")
	self:NetworkVar("Bool", 1, "Activated")
end

function ENT:PhysicsCollide(data, phys)
	if self.Impacted then return end

	local ent = data.HitEntity
	if IsValid(ent) and not self:IsAttractiveTarget(ent) then
		return
	end

	local trace = util_TraceLine({
		start = self:GetPos(),
		endpos = data.HitPos + data.HitNormal,
		mask = MASK_SHOT,
		filter = data.HitEntity,
		whitelist = true,
	})

	trace.IsPhysicsCollide = true

	self:ActivateCustom(trace)
end

function ENT:Initialize(...)
	local mdl = self:GetModel()
	if not mdl or mdl == "" or mdl == "models/error.mdl" then
		self:SetModel(self.DefaultModel)
	end

	self:SetSolid(SOLID_OBB)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	self:PhysicsInitSphere(1, "default")

	if !SinglePlayer or (SinglePlayer and SERVER) then
		ParticleEffectAttach("bo2_teslagat_trail", PATTACH_ABSORIGIN_FOLLOW, self, 1)
	end

	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:Wake()
		phys:EnableMotion(true)

		phys:EnableGravity(true)
		phys:EnableDrag(true)

		phys:SetBuoyancyRatio(0)
		phys:AddGameFlag(FVPHYSICS_NO_NPC_IMPACT_DMG)
	end

	self.killtime = CurTime() + self.Delay

	local ply = self:GetOwner()
	if nzombies and IsValid(ply) and ply:IsPlayer() and ply:HasPerk("time") then
		self.Life = self.Life * 1.2
	end

	self:NextThink( CurTime() )

	if CLIENT then return end
	util.SpriteTrail(self, 3, Color(90, 0, 255), true, 24, 0, 0.3, 0.1, "effects/laser_citadel1")

	local ply = self:GetOwner()
	if not self.Inflictor and ply:IsValid() and ply.GetActiveWeapon and ply:GetActiveWeapon():IsValid() then
		self.Inflictor = ply:GetActiveWeapon()
	end

	self.Damage = self.mydamage or self.Damage

	// Entity water level
	if bit_AND(util_PointContents(self:GetPos()), CONTENTS_LIQUID) != 0 then
		self.IsUnderwater = true
	else
		self.IsUnderwater = false
	end

	self.FrameTime = engine.TickInterval()
end

function ENT:TraceForCollisions()
	local phys = self:GetPhysicsObject()
	local ply = self:GetOwner()

	local position = self:GetPos()
	local speed = phys:GetVelocity():Length()
	local direction = phys:GetVelocity():GetNormalized()
	local distance = speed * self.FrameTime

	local trace = {}

	util_TraceHull({
		start = position,
		endpos = distance * direction + position,
		filter = function(ent)
			return self:IsAttractiveTarget(ent)
		end,
		mask = MASK_SHOT,
		maxs = self.HullMaxs,
		mins = self.HullMins,
		output = trace,
	})

	self:WaterLevelThink(trace)

	if trace.Hit then
		local hitEntity = trace.Entity
		if hitEntity:GetCollisionGroup() == COLLISION_GROUP_BREAKABLE_GLASS then
			hitEntity:Input( "Break" )
		end

		if !nzombies and trace.HitSky then
			self:Remove()
			return false
		end

		local trace2 = {}
		local hitEntity = trace.Entity

		if hitEntity then
			if FindHullIntersection(hitEntity, trace, trace2) then
				trace.HitPos:Set(trace2.HitPos)
				trace.HitBox = trace2.HitBox
				trace.PhysicsBone = trace2.PhysicsBone
				trace.HitGroup = trace2.HitGroup
			end

			self:ActivateCustom(trace)

			local hitDamage = DamageInfo()
			hitDamage:SetDamage(10)
			hitDamage:SetAttacker(IsValid(self:GetOwner()) and self:GetOwner() or self)
			hitDamage:SetInflictor(self)
			hitDamage:SetDamageType(DMG_SHOCK)
			hitDamage:SetDamageForce(direction*2000)
			hitDamage:SetDamagePosition(trace.HitPos)

			hitEntity:DispatchTraceAttack(hitDamage, trace, direction)
		end
	end

	return true
end

function ENT:Think()
	local pos = self:GetPos()
	if CLIENT and dlight_cvar:GetBool() and DynamicLight then
		local dlight = dlight or DynamicLight(self:EntIndex(), false)
		if dlight then
			dlight.pos = pos
			dlight.r = 5*(math.random(6))
			dlight.g = 15
			dlight.b = 255
			dlight.brightness = self:GetActivated() and 2 or 1
			dlight.Decay = 2000
			dlight.Size = self:GetActivated() and 256 or 128
			dlight.dietime = CurTime() + 0.5
		end
	end

	if SERVER then
		if self.Impacted and not self:GetActivated() and (self.killtime - self.Life) + 1 < CurTime() then
			self:CustomActivate()
		end

		if self.killtime < CurTime() then
			self:Explode()
			self:Remove()
			return false
		end

		if not self.Impacted then
			if not self:TraceForCollisions() then
				self:NextThink(CurTime())
				return false
			end
		end

		local p = self:GetParent()

		if self:GetActivated() then
			if IsValid(p) and p:GetMaxHealth() > 0 and (p:GetInternalVariable( "m_lifeState" ) ~= LIFE_ALIVE or (nzombies and p:IsValidZombie() and !p:IsAlive())) then
				self:Explode()
				self:Remove()
				return false
			end

			self:SparkyAttackThink()
		else
			if IsValid(p) and p:GetMaxHealth() > 0 and (p:GetInternalVariable( "m_lifeState" ) ~= LIFE_ALIVE or (nzombies and p:IsValidZombie() and !p:IsAlive())) then
				self:DropFromParent()
				self.Impacted = false
			end
		end
	end

	self:NextThink(CurTime())
	return true
end

function ENT:SparkyAttackThink()
	for k, v in pairs(ents.FindInSphere(self:GetPos(), self.Range)) do
		if v:IsNPC() or v:IsNextBot() then
			if v:BO2IsSparky() then continue end
			if v:Health() <= 0 then continue end
			if v.NZBossType or v.IsMooBossZombie then continue end

			v:BO2Sparky((self.killtime - CurTime()) + 0.15)
		end
	end
end

function ENT:ActivateCustom(trace)
	self.Impacted = true

	local hitEntity = trace.Entity
	if not trace.HitWorld and IsValid(hitEntity) and hitEntity:GetInternalVariable( "m_lifeState" ) == LIFE_ALIVE then
		self:SetParentFromTrace( trace )
	else
		local phys = self:GetPhysicsObject()
		if IsValid(phys) then
			phys:EnableMotion(false)
			phys:Sleep()
		end

		if trace.IsPhysicsCollide then
			timer.Simple(0, function()
				if not IsValid(self) then return end
				self:SetPos( trace.HitPos - trace.HitNormal*self.ParentOffset )
				self:SetAngles( self:GetActivated() and -trace.HitNormal:Angle() or trace.Normal:Angle() )
				self:SetMoveType( MOVETYPE_NONE )
			end)
		else
			self:SetMoveType( MOVETYPE_NONE )
			self:SetPos( trace.HitPos - trace.HitNormal*self.ParentOffset )
			self:SetAngles( self:GetActivated() and -trace.HitNormal:Angle() or trace.Normal:Angle() )
		end
	end

	self.HitNormal = -trace.HitNormal

	DoImpactEffect(trace)

	self.fuckangle = -trace.HitNormal:Angle()
	self.hitwall = trace.HitNormal:Dot(Vector(0,0,1)) < 0.9

	if !self.HasIgnited then
		self.HasIgnited = true

		self.killtime = CurTime() + self.Life
		self:EmitSound("TFA_BO2_TESLAGAT.Proj.Charge")
		self:StopParticles()
	end
end

function ENT:CustomActivate()
	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:EnableMotion(false)
		phys:Sleep(true)
	end

	if self.fuckangle and not IsValid(self:GetParent()) then
		self:SetAngles(self.fuckangle)
	end

	self:SetActivated(true)

	self:EmitSound("TFA_BO2_TESLAGAT.Proj.Loop")
	self:EmitSound("TFA_BO2_TESLAGAT.Proj.Loop2")

	ParticleEffect("bo2_teslagat_impact", self:GetPos(), -self:GetAngles())
	ParticleEffectAttach(self.hitwall and "bo2_teslagat_wall" or "bo2_teslagat_ground", PATTACH_ABSORIGIN_FOLLOW, self, 1)
end

function ENT:DropFromParent()
	if not self.Impacted then return end

	self.LastParent = self:GetParent()
	if IsValid(self.LastParent) then
		if self.KillSelfString then
			self.LastParent:RemoveCallOnRemove(self.KillSelfString)
		end
		if self.LastParent:IsPlayer() then
			self:SetPreventTransmit(self.LastParent, false)
		end
	end

	local pos = self:GetPos()
	local ang = self:GetAngles()

	self:SetParent(nil)
	self:SetMoveType(MOVETYPE_VPHYSICS)

	self:SetPos(pos)
	self:SetAngles(ang)

	local phys = self:GetPhysicsObject()
	if not IsValid(phys) then
		self:Remove()
		return
	end

	phys:EnableGravity(true)
	phys:EnableDrag(true)

	phys:EnableMotion(true)
	phys:Wake()

	phys:AddAngleVelocity(Vector(0,math.random(-600,-600),math.random(-600,600)))
	phys:SetVelocity(vector_up)
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

			DoWaterSplashEffect(trace2)
		end
	 elseif self.IsUnderwater then
		self.IsUnderwater = false

		util_TraceLine({
			start = trace.HitPos,
			endpos = trace.StartPos,
			mask = CONTENTS_LIQUID,
			output = trace2,
		})

		DoWaterSplashEffect(trace2)
	end
end

function ENT:IsAttractiveTarget( hitEntity )
	local playerEntity = self:GetOwner()

	if IsValid(self.LastParent) and hitEntity == self.LastParent then
		return false
	end

	if nzombies and hitEntity:Health() <= 0 then
		return false
	end

	if hitEntity:GetClass() == self:GetClass() then
		return false
	end

	if IsValid( playerEntity ) and hitEntity == playerEntity then
		return false
	end

	if nzombies and hitEntity:IsPlayer() then
		return false
	end

	if hitEntity:IsWeapon() then
		return false
	end

	if hitEntity:IsPlayer() and not pvp_cvar:GetBool() then
		return false
	end

	if IsValid( playerEntity ) and hitEntity:IsPlayer() and playerEntity:IsPlayer() and !hook.Run( "PlayerShouldTakeDamage", ent, playerEntity ) then
		return false
	end

	return true
end

function ENT:SetParentFromTrace( trace )
	local origin = self.ParentOffset * trace.Normal // adjust the bolt position
	origin:Add( trace.HitPos )

	local hitEntity = trace.Entity
	local bone = hitEntity:TranslatePhysBoneToBone( trace.PhysicsBone )

	if bone && bone >= 0 then
		// A multi-bone skeleton (a ragdoll, player, NPC...)
		local boneMatrix = hitEntity:GetBoneMatrix( bone )

		if !boneMatrix then
			// Bone ID is out of bounds or the entity has no model (how did it manage to get hit?)
			self:Remove()
			return false
		end

		// Have to manually set local position/angle in this case
		local position, angles = WorldToLocal( origin, trace.Normal:Angle(), boneMatrix:GetTranslation(), boneMatrix:GetAngles() )

		self:FollowBone( hitEntity, bone )
		self:SetLocalPos( position )
		self:SetLocalAngles( angles )

		if hitEntity:IsPlayer() then
			// Save bandwidth, this player will not draw this bolt anyway
			self:SetPreventTransmit( hitEntity, true )
		end
	else
		// A zero- or mono-bone skeleton, most likely a prop
		self:SetPos( origin )
		self:SetAngles( trace.Normal:Angle() )

		self:SetParent( hitEntity )
	end

	if not trace.HitWorld then
		self.KillSelfString = "sticky_fixme"..self:EntIndex()
		hitEntity:CallOnRemove(self.KillSelfString, function(ent)
			if not IsValid(self) then return end
			local parent = self:GetParent()
			if IsValid(parent) and parent == ent then
				self:DropFromParent()
				self.Impacted = false
			end
		end)
	end

	//self:SetTransmitWithParent( true )

	return true
end

function ENT:DoExplosionEffect()
	ParticleEffect("bo2_teslagat_impact", self:GetPos(), angle_zero)

	self:EmitSound("TFA_BO2_TESLAGAT.Act")
end

function ENT:Explode()
	self.Damage = self.mydamage or self.Damage

	local ply = self:GetOwner()
	local p = self:GetParent() or self

	local tr = {
		start = self:GetPos(),
		filter = {self, p, ply},
		mask = MASK_SHOT
	}

	local damage = DamageInfo()
	damage:SetAttacker(IsValid(self:GetOwner()) and self:GetOwner() or self)
	damage:SetInflictor(IsValid(self.Inflictor) and self.Inflictor or self)

	for k, v in pairs(ents.FindInSphere(self:GetPos(), self.BlastRange)) do
		if v:IsSolid() and not v:IsWorld() then
			if v == ply then continue end
			if !TFA.WonderWeapon.ShouldDamage(v, ply, self) then continue end

			tr.endpos = v:WorldSpaceCenter()
			local tr1 = util.TraceLine(tr)
			if tr1.HitWorld then continue end

			local hitpos = tr1.Entity == v and tr1.HitPos or tr.endpos

			damage:SetDamageForce(v:GetUp()*math.random(4000,8000) + (v:WorldSpaceCenter() - self:GetPos()):GetNormalized()*math.random(4000,8000))
			damage:SetDamagePosition(math.random(3) == 1 and v:EyePos() or hitpos)
			damage:SetDamageType(nzombies and DMG_ENERGYBEAM or DMG_SHOCK)
			damage:SetDamage(self.Damage)

			if nzombies and (v.NZBossType or v.IsMooBossZombie or string.find(v:GetClass(), "zombie_boss")) then
				damage:SetDamage(math.max(600, v:GetMaxHealth() / 18))
			end

			if v:IsNPC() then
				v:StopParticles()
				if damage:GetDamage() >= v:Health() and v:IsNPC() and v:HasCondition(COND.NPC_FREEZE) then
					v:SetCondition(COND.NPC_UNFREEZE)
				end
			end

			if (v:IsNPC() or v:IsNextBot() or v:IsPlayer() or v:IsRagdoll() or v:IsVehicle()) then
				ParticleEffectAttach("bo2_teslagat_shock", PATTACH_ABSORIGIN_FOLLOW, v, 1)
			end

			v:TakeDamageInfo(damage)
		end
	end

	util.ScreenShake(self:GetPos(), 4, 255, 1, self.BlastRange*2)
	self:DoExplosionEffect()
end

function ENT:OnRemove()
	if CLIENT and dlight_cvar:GetBool() and DynamicLight and self:GetActivated() then
		local dlight = dlight or DynamicLight(self:EntIndex(), false)
		if dlight then
			dlight.pos = self:GetPos()
			dlight.r = 5*(math.random(6))
			dlight.g = 15
			dlight.b = 255
			dlight.brightness = 4
			dlight.Decay = 1000
			dlight.Size = 256 + 64
			dlight.dietime = CurTime() + 1
		end
	end

	self:StopSound("TFA_BO2_TESLAGAT.Proj.Loop")
	self:StopSound("TFA_BO2_TESLAGAT.Proj.Loop2")
end

function FindHullIntersection( entity, trace, trace2 )
	// Equivalent to enginetrace->ClipRayToEntity()
	local ray = {
		start = trace.HitPos,
		endpos = 48 * trace.Normal + trace.HitPos,
		mask = MASK_SHOT,
		ignoreworld = true,
		output = trace2,
		whitelist = true,
		filter = entity,
	}

	util_TraceLine( ray )

	if trace2.Hit then
		// Best case scenario, the target entity was on the bolt's trajectory
		return true
	end

	// Find a possible hit location at the same height
	local endPos = ray.endpos
	endPos:Set( entity:GetPos() )
	endPos[ 3 ] = trace.HitPos[ 3 ]

	util_TraceLine( ray )

	if trace2.Hit then
		// Found a suitable point
		return true
	end

	// Last attempt, aim towards the center of mass
	endPos:Set( entity:WorldSpaceCenter() )
	endPos[ 3 ] = 0.5 * ( endPos[ 3 ] + trace.HitPos[ 3 ] ) // limit the vertical excursion

	util_TraceLine( ray )

	return trace2.Hit
end

function DoImpactEffect( trace )
	local data = EffectData()
	data:SetStart( trace.StartPos )
	data:SetOrigin( trace.HitPos )
	data:SetEntity( trace.Entity )
	data:SetSurfaceProp( trace.SurfaceProps )
	data:SetHitBox( trace.HitBox )

	DispatchEffect( "Impact", data, false, true )
end

function DoWaterSplashEffect(trace)
	local data = EffectData()
	data:SetOrigin( trace.HitPos )
	data:SetNormal( trace.Normal )
	data:SetScale( 6 )
	data:SetFlags( bit_AND( trace.Contents, CONTENTS_SLIME ) != 0 && 1 || 0 ) // FX_WATER_IN_SLIME = 1

	DispatchEffect( "gunshotsplash", data, false, true )
end
