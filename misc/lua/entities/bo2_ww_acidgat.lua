AddCSLuaFile()

--[Info]--
ENT.Base = "tfa_exp_base"
ENT.PrintName = "Acid Flechette"

--[Parameters]--
ENT.Delay = 10
ENT.Life = 3
ENT.Range = 140
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

	self:EmitSound("TFA_BO2_ACIDGAT.Proj.Fweep")

	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:Wake()
		phys:EnableMotion(true)

		phys:EnableGravity(false)
		phys:EnableDrag(false)

		phys:SetBuoyancyRatio(0)
		phys:AddGameFlag(FVPHYSICS_NO_NPC_IMPACT_DMG)
	end

	self.killtime = CurTime() + self.Delay

	self:NextThink( CurTime() )

	if CLIENT then return end

	local ply = self:GetOwner()
	if not self.Inflictor and ply:IsValid() and ply.GetActiveWeapon and ply:GetActiveWeapon():IsValid() then
		self.Inflictor = ply:GetActiveWeapon()
	end

	self.Damage = self.mydamage or self.Damage

	if bit_AND(util_PointContents(self:GetPos()), CONTENTS_LIQUID) != 0 then
		self.IsUnderwater = true
	else
		self.IsUnderwater = false
	end

	self.FrameTime = engine.TickInterval()

	local num = math.random(180,200)
	self.SmokeTrail = util.SpriteTrail(self, 1, Color(num,num,num, 60), true, 6, 1, 0.4, 0.1, "trails/smoke")
end

function ENT:Think()
	if CLIENT and dlight_cvar:GetBool() and DynamicLight then
		self.DLight = self.DLight or DynamicLight(self:EntIndex(), false)
		if self.DLight and self:GetActivated() then
			self.DLight.pos = self:GetAttachment(1).Pos
			self.DLight.r = 50
			self.DLight.g = 255
			self.DLight.b = 50
			self.DLight.brightness = 1
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

		if not nzombies and self:GetActivated() and self:GetUpgraded() then
			self:MonkeyBomb()
			self:MonkeyBombNXB()
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
		end
	end

	self:NextThink( CurTime() )
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

	if IsValid(hitEntity) then
		if hitEntity:IsNPC() or hitEntity:IsNextBot() then
			hitEntity:SetNW2Bool("OnAcid", true)

			if nzombies and hitEntity:IsValidZombie() and not (hitEntity.NZBossType or hitEntity.IsMooBossZombie or hitEntity.IsMooMiniBoss) then
				hitEntity:Freeze(3)
			end
		end
	end

	self.HitNormal = -trace.HitNormal

	DoImpactEffect(trace)

	ParticleEffect("bo4_acidgat_impact", trace.HitPos, self.HitNormal:Angle())

	if !self.HasIgnited then
		if nzombies and self:GetUpgraded() then
			self:SetTargetPriority(TARGET_PRIORITY_SPECIAL)
		end

		self.HasIgnited = true

		self.killtime = CurTime() + (self:GetUpgraded() and math.Rand(3,4) or math.Rand(2,3))
		self:EmitSound("TFA_BO2_ACIDGAT.Proj.Fuse")
	end

	timer.Simple(0.4, function()
		if not IsValid(self) then return end
		if self.SmokeTrail and IsValid(self.SmokeTrail) then
			self.SmokeTrail:Remove()
		end
	end)
end

function ENT:DropFromParent()
	if not self:GetActivated() then return end
	self:SetActivated(false)

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
			end
		end)
	end

	//self:SetTransmitWithParent( true )

	return true
end

function ENT:MonkeyBomb()
	if CLIENT then return end

	for k, v in pairs(ents.FindInSphere(self:GetPos(), 1024)) do
		if v == self:GetOwner() then continue end
		if IsValid(v) and v:IsNPC() then
			if v:GetEnemy() ~= self then
				v:ClearSchedule()
				v:ClearEnemyMemory(v:GetEnemy())

				v:SetEnemy(self)
			end

			v:UpdateEnemyMemory(self, self:GetPos())
			v:SetSaveValue("m_vecLastPosition", self:GetPos())
			v:SetSchedule(SCHED_FORCED_GO_RUN)
		end
	end
end

function ENT:MonkeyBombNXB()
	if CLIENT then return end

	for k, v in pairs(ents.FindInSphere(self:GetPos(), 1024)) do
		if v == self:GetOwner() then continue end
		if IsValid(v) and v:IsNextBot() then
			v.loco:FaceTowards(self:GetPos())
			v.loco:Approach(self:GetPos(), 99)
			if v.SetEnemy then
				v:SetEnemy(self)
			end
		end
	end
end

function ENT:DoExplosionEffect()
	self:EmitSound("TFA_BO2_ACIDGAT.Proj.Explo")
	self:EmitSound("TFA_BO2_ACIDGAT.Proj.Sweet")

	if self.HitNormal then
		ParticleEffect("bo4_acidgat_explode", self:GetPos(), self.HitNormal:Angle() - Angle(90,0,0))
	else
		ParticleEffect("bo4_acidgat_explode", self:GetPos(), Angle(0,0,0))
	end
end

function ENT:Explode()
	self.Damage = self.mydamage or self.Damage

	local ply = self:GetOwner()
	local tr = {
		start = self:GetPos(),
		filter = {self, ply},
		mask = MASK_SHOT
	}

	for k, v in pairs(ents.FindInSphere(self:GetPos(), self.Range)) do
		if not v:IsWorld() and v:IsSolid() then
			if !TFA.WonderWeapon.ShouldDamage(v, ply, self) then continue end

			tr.endpos = v:WorldSpaceCenter()
			local tr1 = util.TraceLine(tr)
			if tr1.HitWorld then continue end

			local damage = DamageInfo()
			damage:SetDamage(self.Damage)
			damage:SetAttacker(IsValid(ply) and ply or self)
			damage:SetInflictor(IsValid(self.Inflictor) and self.Inflictor or self)
			damage:SetDamageForce(v:GetUp()*10000 + (v:GetPos() - self:GetPos()):GetNormalized() * 8000)
			damage:SetDamagePosition(v:WorldSpaceCenter())
			damage:SetDamageType(DMG_RADIATION)

			if v:IsPlayer() then
				local dist = self:GetPos():Distance(v:GetPos())
				dist = 1 - math.Clamp(dist/self.Range, 0, 1)
				damage:SetDamage(50 * dist)
			end

			if nzombies and (v.NZBossType or v.IsMooBossZombie or v.IsMooMiniBoss) then
				damage:SetDamage(math.max(self.Damage, v:GetMaxHealth() / 16))
			end

			if v:IsNPC() and damage:GetDamage() >= v:Health() and v:HasCondition(COND.NPC_FREEZE) then
				v:SetCondition(COND.NPC_UNFREEZE)
			end

			v:TakeDamageInfo(damage)
		end
	end

	util_ScreenShake(self:GetPos(), 8, 255, 1, self.Range * 2.5)

	self.HasExploded = true

	self:DoExplosionEffect()
	self:Remove()
end

function ENT:OnRemove()
	if CLIENT and dlight_cvar:GetBool() and DynamicLight and self:GetActivated() then
		self.DLight = self.DLight or DynamicLight(self:EntIndex(), false)
		if self.DLight and self:GetActivated() then
			self.DLight.pos = self:GetAttachment(1).Pos
			self.DLight.r = 50
			self.DLight.g = 255
			self.DLight.b = 50
			self.DLight.brightness = 2
			self.DLight.Decay = 500
			self.DLight.Size = 256
			self.DLight.dietime = CurTime() + 1
		end
	end

	self:StopSound("TFA_BO2_ACIDGAT.Proj.Fweep")
	self:StopSound("TFA_BO2_ACIDGAT.Proj.Fuse")

	local p = self:GetParent()
	if IsValid(p) then
		if p:GetNW2Bool("OnAcid") then
			p:SetNW2Bool("OnAcid", false)
		end
	end
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
