AddCSLuaFile()

--[Info]--
ENT.Base = "tfa_exp_base"
ENT.PrintName = "Fire Flechette"

--[Parameters]--
ENT.Delay = 10

ENT.Life = 4.5
ENT.LifeUpgraded = 6
ENT.LifeRandom = 0.5

ENT.Range = 120
ENT.BlastRange = 140

ENT.Burn = false
ENT.AttackDelay = 0.75
ENT.HealthFraction = 20

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

function ENT:Draw()
	self:DrawModel()

	if self:GetActivated() then
		if !self.pvs_fx or not IsValid(self.pvs_fx) then
			self.pvs_fx = CreateParticleSystem(self, "bo2_hellgat_loop", PATTACH_POINT_FOLLOW, 1)
		end
	end
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
		ParticleEffectAttach("bo2_hellgat_trail", PATTACH_POINT_FOLLOW, self, 1)
	end

	self:EmitSound("TFA_BO2_HELLGAT.Proj")
	self:EmitSound("TFA_BO2_HELLGAT.Proj.Charge")

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
	
	if self:GetUpgraded() then
		self.Life = self.LifeUpgraded
	end

	local ply = self:GetOwner()
	if nzombies and IsValid(ply) and ply:IsPlayer() and ply:HasPerk("time") then
		self.Life = self.Life * 1.5
	end

	self.Life = self.Life + math.Rand(-self.LifeRandom,self.LifeRandom)

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
			hitDamage:SetDamageType(DMG_BURN)
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
		self.dlight = self.dlight or DynamicLight(self:EntIndex(), false)
		if self.dlight then
			self.dlight.pos = pos
			self.dlight.r = 255
			self.dlight.g = 60
			self.dlight.b = 0
			self.dlight.brightness = self:GetActivated() and 2 or 1
			self.dlight.Decay = 2000
			self.dlight.Size = self:GetActivated() and 380 or 128
			self.dlight.dietime = CurTime() + 0.5
		end
	end

	if SERVER then
		if self.Impacted and not self:GetActivated() and (self.killtime - self.Life) + 1 < CurTime() then
			self:CustomActivate()
		end

		if self.killtime < CurTime() then
			self:Remove()
			return false
		end

		if not self.Impacted then
			if not self:TraceForCollisions() then
				self:NextThink(CurTime())
				return false
			end
		end

		if self:GetActivated() then
			self:FireAttackThink()
		end

		local p = self:GetParent()
		if IsValid(p) and p:GetMaxHealth() > 0 and (p:GetInternalVariable( "m_lifeState" ) ~= LIFE_ALIVE or (nzombies and p:IsValidZombie() and !p:IsAlive())) then
			self:DropFromParent()
			self.Impacted = false
		end
	end

	self:NextThink(CurTime())
	return true
end

function ENT:FireAttackThink()
	if nzombies then
		local round = nzRound:GetNumber() > 0 and nzRound:GetNumber() or 1
		local health = tonumber(nzCurves.GenerateHealthCurve(round))
		local mydamage = health / self.HealthFraction

		for k, v in pairs(ents.FindInSphere(self:GetPos(), self.Range)) do
			if not v:IsValidZombie() then continue end
			if v.HellgatAttack and v.HellgatAttack[self:GetCreationID()] and v.HellgatAttack[self:GetCreationID()] > CurTime() then continue end

			local damage = DamageInfo()
			damage:SetDamage(mydamage)
			damage:SetAttacker(IsValid(ply) and ply or self)
			damage:SetInflictor(IsValid(self.Inflictor) and self.Inflictor or self)
			damage:SetDamageForce((v:GetPos() - self:GetPos()):GetNormalized())
			damage:SetDamagePosition(v:WorldSpaceCenter())
			damage:SetDamageType(DMG_BURN)

			if (v.NZBossType or v.IsMooBossZombie) then
				damage:SetDamage(math.max(600, v:GetMaxHealth() / 18))
			else
				v:BO1BurnSlow(2)
			end

			v:TakeDamageInfo(damage)

			if not (v.NZBossType or v.IsMooBossZombie) then
				v:Extinguish()
			end

			if not v.HellgatAttack then v.HellgatAttack = {} end
			v.HellgatAttack[self:GetCreationID()] = CurTime() + self.AttackDelay
		end
	else
		for k, v in pairs(ents.FindInSphere(self:GetPos(), self.Range)) do
			if v:IsNPC() or v:IsNextBot() or v:IsPlayer() or v:IsVehicle() then
				if v:IsOnFire() then continue end
				if v:Health() <= 0 then continue end

				v:Ignite(0.5)
			end
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

	self:StopParticles()

	self.fuckangle = (-trace.HitNormal):Angle()

	if !self.HasIgnited then
		self.HasIgnited = true

		self.killtime = CurTime() + self.Life
	end
end

function ENT:CustomActivate()
	local p = self:GetParent()
	if !IsValid(p) and self.fuckangle then
		self:SetAngles(self.fuckangle)
	end

	self:SetActivated(true)

	self:StopSound("TFA_BO2_HELLGAT.Proj.Charge")
	self:EmitSound("TFA_BO2_HELLGAT.Explo")
	self:EmitSound("TFA_BO2_HELLGAT.Proj.Explo")

	ParticleEffect("bo2_hellgat_explode", self:GetPos(), self.fuckangle and (self.fuckangle - Angle(90,0,0)) or angle_zero)

	self:Explode()

	if IsValid(p) and (p:IsNPC() or p:IsPlayer() or p:IsNextBot()) or !self.Burn then
		self:Remove()
	else
		self:EmitSound("TFA_BO2_HELLGAT.Proj.Loop")
	end
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

	if nzombies and hitEntity:IsValidZombie() and hitEntity:Health() <= 0 then
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

function ENT:Explode()
	self.Damage = self.mydamage or self.Damage

	local ply = self:GetOwner()
	local p = self:GetParent() or self

	local tr = {
		start = self:GetPos(),
		filter = {self, p, ply},
		mask = MASK_SHOT
	}

	for k, v in pairs(ents.FindInSphere(self:GetPos(), self.BlastRange)) do
		if v:IsSolid() and not v:IsWorld() then
			if !TFA.WonderWeapon.ShouldDamage(v, ply, self) then continue end

			tr.endpos = v:WorldSpaceCenter()
			local tr1 = util.TraceLine(tr)
			if tr1.HitWorld then continue end

			local damage = DamageInfo()
			damage:SetDamage(self.Damage)
			damage:SetAttacker(IsValid(self:GetOwner()) and self:GetOwner() or self)
			damage:SetInflictor(IsValid(self.Inflictor) and self.Inflictor or self)
			damage:SetDamageForce(v:GetUp()*math.random(8000,9000) + tr1.Normal*math.random(9000,12000))
			damage:SetDamagePosition(tr1.Entity == v and tr1.HitPos or tr.endpos)
			damage:SetDamageType(nzombies and DMG_BURN or DMG_SLOWBURN)

			if nzombies and v:IsValidZombie() then
				if (v.NZBossType or v.IsMooBossZombie) then
					damage:SetDamage(math.max(self.Damage, v:GetMaxHealth() / 12))
				else
					v:BO1BurnSlow(4)
				end

				if not v.HellgatAttack then v.HellgatAttack = {} end
				v.HellgatAttack[self:GetCreationID()] = CurTime() + self.AttackDelay
			end

			if v == ply then
				local dist = self:GetPos():Distance(v:GetPos())
				dist = 1 - math.Clamp(dist/self.Range, 0, 1)
				damage:SetDamage(50 * dist)
			end

			if v:IsNPC() and v:HasCondition(COND.NPC_FREEZE) then
				v:SetCondition(COND.NPC_UNFREEZE)
			end

			v:TakeDamageInfo(damage)

			if nzombies and v:IsValidZombie() then
				v:Extinguish()
			end

			if v:IsNPC() or v:IsNextBot() or v:IsPlayer() then
				table.insert(tr.filter, v)
			end
		end
	end

	util_ScreenShake(self:GetPos(), 4, 255, 1, self.BlastRange*2)
end

function ENT:OnRemove()
	self:StopParticles()

	self:StopSound("TFA_BO2_HELLGAT.Proj.Loop")
	self:StopSound("TFA_BO2_HELLGAT.Proj.Charge")
	self:EmitSound("TFA_BO2_HELLGAT.Proj.End")
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
