AddCSLuaFile()

--[Info]--
ENT.Base = "tfa_ww_base"
ENT.PrintName = "Biolum-Pod"

--[Parameters]--
ENT.Delay = 2
ENT.Range = 200

ENT.Impacted = false

ENT.HullMaxs = Vector(3, 3, 3)
ENT.HullMins = ENT.HullMaxs:GetNegated()

ENT.ExplosionDamageType = bit.bor(DMG_BLAST, DMG_RADIATION)

ENT.ShouldExplodeOnRemove = true
ENT.ShouldLodgeProjectile = true
ENT.ShouldDropProjectile = true

ENT.DLightBrightness = 0
ENT.DLightDecay = 2000
ENT.DLightSize = 128

ENT.ParentOffset = 0

DEFINE_BASECLASS(ENT.Base)

local nzombies = engine.ActiveGamemode() == "nzombies"
local dlight_cvar = GetConVar("cl_tfa_fx_wonderweapon_dlights")

function ENT:SetupDataTables()
	self:NetworkVar("Bool", 0, "Upgraded")
	self:NetworkVar("Bool", 1, "Activated")
end

function ENT:PhysicsCollide(data, phys)
	if self:GetActivated() then return end
	self:SetActivated(true)

	local trace = self:CollisionDataToTrace(data)
	local direction = data.OurOldVelocity:GetNormalized()
	local hitEntity = trace.Entity

	self:ActivateCustom(trace)

	if trace.Hit and IsValid(hitEntity) and TFA.WonderWeapon.ShouldDamage(hitEntity, self:GetOwner(), self) then
		local hitDamage = DamageInfo()
		hitDamage:SetDamage(10)
		hitDamage:SetAttacker(IsValid(self:GetOwner()) and self:GetOwner() or self)
		hitDamage:SetInflictor(IsValid(self.Inflictor) and self.Inflictor or self)
		hitDamage:SetDamageType(nzombies and DMG_BULLET or bit.bor(DMG_BULLET, DMG_AIRBOAT))
		hitDamage:SetDamageForce(direction*2000)
		hitDamage:SetDamagePosition(trace.HitPos)
		hitDamage:SetReportedPosition(trace.StartPos)

		hitEntity:DispatchTraceAttack(hitDamage, trace, direction)

		self:SendHitMarker(hitEntity, hitDamage, trace)
	end

	local ent = data.HitEntity
	local ang = self:GetAngles()

	timer.Simple(0, function()
		if not self:IsValid() then return end
		self:SetAngles(ang)
		self:SetSolid(SOLID_NONE)
		self:SetMoveType(MOVETYPE_NONE)
	end)

	phys:EnableMotion(false)
	phys:Sleep()

	sound.EmitHint(SOUND_DANGER, data.HitPos, 200, 0.2, IsValid(self:GetOwner()) and self:GetOwner() or self)
end

function ENT:StartTouch(ent)
	if ent == self:GetOwner() then return end
	if not ent:IsSolid() then return end
	if nzombies and ent:IsPlayer() then return end
	if self:GetActivated() then return end

	self:SetParent(ent)

	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)

	sound.EmitHint(SOUND_DANGER, self:GetPos(), 200, 0.2, IsValid(self:GetOwner()) and self:GetOwner() or self)
end

function ENT:ActivateCustom(trace)
	self:SetActivated(true)

	self.BlockCollisionTrace = true

	local hitEntity = trace.Entity
	if not trace.HitWorld and IsValid(hitEntity) and hitEntity:GetInternalVariable( "m_lifeState" ) == 0 then
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
	self.HitPos = trace.HitPos

	self:DoImpactEffect(trace)

	ParticleEffect("bo4_acidgat_impact", trace.HitPos, self.HitNormal:Angle())

	if !self.HasIgnited then
		if nzombies and self:GetUpgraded() then
			self:SetTargetPriority(TARGET_PRIORITY_SPECIAL)
		end

		self.HasIgnited = true

		self.killtime = CurTime() + (self:GetUpgraded() and math.Rand(3,4) or math.Rand(2,3))
		self:EmitSound("TFA_BO4_BLUNDER.Acid.Fuse")

		local sprite = self:CreateGlowSprite(math.Clamp(self.killtime - CurTime(), 0, 4), self.Color, 255, 0.25)
		if sprite then
			sprite:SetParent(self)
			sprite:SetLocalPos(Vector(0,0,0))
		end
	end

	timer.Simple(0.4, function()
		if not IsValid(self) then return end
		if self.SmokeTrail and IsValid(self.SmokeTrail) then
			self.SmokeTrail:Remove()
		end
	end)
end

function ENT:Initialize()
	BaseClass.Initialize(self)

	self:SetNoDraw(true)
	self:DrawShadow(false)

	self:SetRenderMode(RENDERMODE_GLOW)

	if self:GetUpgraded() then
		ParticleEffectAttach("iw7_venomx_trail_2", PATTACH_ABSORIGIN_FOLLOW, self, 0)
		self.Color = Color(200, 150, 50, 255)
	else
		ParticleEffectAttach("iw7_venomx_trail", PATTACH_ABSORIGIN_FOLLOW, self, 0)
		self.Color = Color(200, 255, 0, 255)
	end
end

function ENT:DoExplosionEffect()
	self:EmitSound("TFA_IW7_VENOMX.Explode")
	ParticleEffect(self:GetUpgraded() and "iw7_venomx_explode_2" or "iw7_venomx_explode", self:GetPos(), Angle(0,0,0))
end

function ENT:Explode(...)
	self:SpawnGasCloud()

	BaseClass.Explode(self, ...)
end

function ENT:SpawnGasCloud()
	self.Damage = self.mydamage or self.Damage

	local gas = ents.Create("iw7_ww_venomx_gas")
	gas:SetModel("models/hunter/misc/sphere025x025.mdl")
	gas:SetPos(self:GetPos())
	gas:SetAngles(Angle(0,0,0))

	gas.Damage = nzombies and (self.Damage / 10) or self.Damage
	gas:SetOwner(IsValid(self:GetOwner()) and self:GetOwner() or self)
	gas.Inflictor = IsValid(self.Inflictor) and self.Inflictor or self
	gas:SetUpgraded(self:GetUpgraded())

	gas:Spawn()
end

function ENT:OnRemove()
	if CLIENT and dlight_cvar:GetBool() and DynamicLight then
		local dlight = DynamicLight(self:EntIndex())
		if dlight then
			dlight.pos = self:GetPos()
			dlight.r = self.Color.r
			dlight.g = self.Color.g
			dlight.b = self.Color.b
			dlight.brightness = 2
			dlight.Decay = 2000
			dlight.Size = 400
			dlight.DieTime = CurTime() + 0.5
		end
	end
end