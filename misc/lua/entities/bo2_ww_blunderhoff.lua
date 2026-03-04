AddCSLuaFile()

--[Info]--
ENT.Base = "tfa_exp_base"
ENT.PrintName = "Party Flechette"

--[Parameters]--
ENT.Delay = 10
ENT.Life = 2
ENT.LifeRandMax = 0.8
ENT.Range = 160

ENT.HullMaxs = Vector( 2, 2, 2 )
ENT.HullMins = ENT.HullMaxs:GetNegated()
ENT.ParentOffset = 2

DEFINE_BASECLASS(ENT.Base)

local nzombies = engine.ActiveGamemode() == "nzombies"
local pvp_cvar = GetConVar("sbox_playershurtplayers")
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
local DoImpactEffect

function ENT:SetupDataTables()
	self:NetworkVar("Bool", 0, "Upgraded")
	self:NetworkVar("Bool", 1, "Activated")
end

function ENT:PhysicsCollide(data, phys)
	if self:GetActivated() then return end

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

	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:Wake()
		phys:EnableMotion(true)

		phys:EnableGravity(false)
		phys:EnableDrag(false)

		phys:SetBuoyancyRatio(0)
		phys:AddGameFlag(FVPHYSICS_NO_NPC_IMPACT_DMG)
	end

	self.RangeSqr = self.Range * self.Range
	self.killtime = CurTime() + self.Delay

	self:EmitSound("TFA_BO2_ACIDGAT.Proj.Fuse")

	self:NextThink( CurTime() )

	if CLIENT then return end

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

function ENT:Think()
	local pos = self:GetPos()
	if CLIENT and dlight_cvar:GetBool() and DynamicLight then
		self.DLight = self.DLight or DynamicLight(self:EntIndex(), false)
		if self.DLight then
			self.DLight.pos = pos
			self.DLight.r = 240
			self.DLight.g = 15
			self.DLight.b = 255
			self.DLight.brightness = 0.5
			self.DLight.Decay = 2000
			self.DLight.Size = 64
			self.DLight.dietime = CurTime() + 0.5
		end
	end

	if SERVER then
		if self.killtime <= CurTime() then
			self:Explode()
			self:Remove()
			return false
		end

		local phys = self:GetPhysicsObject()
		if not IsValid(phys) then
			self:Remove()
			return false
		end

		if not self:GetActivated() then
			if not self:TraceForCollisions() then
				self:NextThink(CurTime())
				return false
			end
		end

		local p = self:GetParent()
		if IsValid(p) and p:GetMaxHealth() > 0 and (p:GetInternalVariable( "m_lifeState" ) ~= LIFE_ALIVE or (nzombies and p:IsValidZombie() and !p:IsAlive())) then
			self:DropFromParent()
			self:SetActivated(false)
		end
	end

	self:NextThink(CurTime())
	return true
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
			if TFA.WonderWeapon.FindHullIntersection(hitEntity, trace, trace2) then
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
			hitDamage:SetDamageType(DMG_BULLET)
			hitDamage:SetDamageForce(direction*2000)
			hitDamage:SetDamagePosition(trace.HitPos)

			hitEntity:DispatchTraceAttack(hitDamage, trace, direction)
		end
	end

	return true
end

function ENT:ActivateCustom(trace)
	self:SetActivated(true)

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
				self:SetAngles( trace.Normal:Angle() )
				self:SetMoveType( MOVETYPE_NONE )
			end)
		else
			self:SetMoveType( MOVETYPE_NONE )
			self:SetPos( trace.HitPos - trace.HitNormal*self.ParentOffset )
			self:SetAngles( trace.Normal:Angle() )
		end
	end

	self.HitNormal = -trace.HitNormal

	DoImpactEffect(trace)

	self:StopParticles()

	ParticleEffect("bo2_blunderhoff_impact", trace.HitPos, -trace.HitNormal:Angle())

	self.fuckangle = -trace.HitNormal:Angle()
	self.hitwall = trace.HitNormal:Dot(Vector(0,0,-1)) < 0.9

	if !self.HasIgnited then
		self.HasIgnited = true

		self.killtime = CurTime() + (self.Life - math.Rand(0,self.LifeRandMax))
	end
end

function ENT:DropFromParent()
	if not self:GetActivated() then return end

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
				self:SetActivated(false)
			end
		end)
	end

	//self:SetTransmitWithParent( true )

	return true
end

function ENT:DoExplosionEffect()
	self:EmitSound("TFA_BO2_BLUNDERHOFF.Explo")

	if self.hitwall then
		if self.HitNormal then
			ParticleEffect("bo2_blunderhoff_explode", self:GetPos(), self.HitNormal:Angle() - Angle(90,0,0))
		else
			ParticleEffect("bo2_blunderhoff_explode", self:GetPos(), self:GetAngles() - Angle(90,0,0))
		end
	else
		ParticleEffect("bo2_blunderhoff_explode_floor", self:GetPos(), Angle(0,0,0))
	end
end

function ENT:Explode()
	if self.Exploded then return end
	self.Exploded = true

	self.Damage = self.mydamage or self.Damage

	local ply = self:GetOwner()
	local p = self:GetParent() or self

	local tr = {
		start = self:GetPos(),
		filter = self,
		mask = MASK_SHOT_HULL
	}

	for k, v in pairs(ents.FindInSphere(self:GetPos(), self.Range)) do
		if v:IsNPC() or v:IsNextBot() or (not nzombies and v:IsPlayer()) then
			if v == ply then continue end
			if !TFA.WonderWeapon.ShouldDamage(v, ply, self) then continue end

			if v:BO2IsHoffDancing() then continue end

			tr.endpos = v:WorldSpaceCenter()
			local tr1 = util.TraceLine(tr)
			if tr1.HitWorld then continue end
			local hitpos = tr1.Entity == v and tr1.HitPos or v:EyePos()

			self:InflictDamage(v, hitpos)
		end
	end

	util.ScreenShake(self:GetPos(), 4, 4, 0.8, self.Range*2)
	self:DoExplosionEffect()
end

function ENT:InflictDamage(ent, hitpos)
	local ply = IsValid(self:GetOwner()) and self:GetOwner() or self
	local wep = IsValid(self.Inflictor) and self.Inflictor or self

	local dist = self:GetPos():DistToSqr(hitpos or ent:WorldSpaceCenter())
	local distfac = 1 - math.Clamp(dist/self.RangeSqr, 0, 0.5)

	local damage = DamageInfo()
	damage:SetDamage(self.Damage*distfac)
	damage:SetAttacker(ply)
	damage:SetInflictor(wep)
	damage:SetDamageForce((ent:GetPos() - self:GetPos()):GetNormalized())
	damage:SetDamagePosition(hitpos or ent:EyePos())
	damage:SetDamageType(DMG_BLAST_SURFACE)

	if nzombies and (ent.NZBossType or ent.IsMooZombieBoss or string.find(ent:GetClass(), "zombie_boss")) then
		damage:SetDamage(math.max(400, ent:GetMaxHealth() / 18))
	end

	if (damage:GetDamage() > ent:Health()) or (nzombies and nzPowerUps:IsPowerupActive("insta")) then
		if nzombies and ent:IsValidZombie() and (!ent.IsMooSpecial or (ent.IsMooSpecial and !ent.MooSpecialZombie)) and !ent.NZBossType and !ent.IsMooZombieBoss and !string.find(ent:GetClass(), "zombie_boss") then
			ent:SetNW2Bool("NZNoRagdoll", true)
			ent:SetHealth(1)

			ent:BO2HoffDance(1, ply, wep)
			return
		end

		if ent:IsNPC() then
			damage:SetDamageType(DMG_REMOVENORAGDOLL)
			damage:SetDamagePosition(ent:EyePos())
			if ent:IsNPC() and ent:HasCondition(COND.NPC_FREEZE) then
				ent:SetCondition(COND.NPC_UNFREEZE)
			end
			ent:SetHealth(1)
		end

		ent:EmitSound("TFA_BO2_ACIDGAT.Proj.Explo")
		ParticleEffect("bo2_blunderhoff_infect", ent:GetPos(), Angle(0,0,0))
	end

	ent:TakeDamageInfo(damage)
end

function ENT:OnRemove()
	if CLIENT and dlight_cvar:GetBool() and DynamicLight and self:GetActivated() then
		self.DLight = self.DLight or DynamicLight(self:EntIndex(), false)
		if self.DLight then
			self.DLight.pos = self:GetPos()
			self.DLight.r = 240
			self.DLight.g = 15
			self.DLight.b = 255
			self.DLight.brightness = 2
			self.DLight.Decay = 1000
			self.DLight.Size = 256
			self.DLight.dietime = CurTime() + 1
		end
	end

	self:StopSound("TFA_BO2_ACIDGAT.Proj.Fuse")
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
