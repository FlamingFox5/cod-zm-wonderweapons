
AddCSLuaFile()

ENT.Base = "tfa_ww_base"
ENT.PrintName = "Infectious Goo"

// Custom Settings

ENT.MaxKills = 3
ENT.MaxKillsPaP = 6

ENT.Kills = 0

ENT.Impacted = false

ENT.ImpactSound = "TFA_BO3_MIRG.Impact"

// Default Settings

ENT.Delay = 10
ENT.Range = 80
ENT.RangePaP = 90

ENT.InfiniteDamage = true
ENT.SpawnGravityEnabled = true
ENT.NoDrawNoShadow = true
ENT.RemoveInWater = true

ENT.HullMaxs = Vector(2, 2, 2)
ENT.HullMins = ENT.HullMaxs:GetNegated()

ENT.TrailEffect = "bo3_mirg2k_trail"
ENT.TrailEffectPaP = "bo3_mirg2k_trail_2"
ENT.TrailAttachType = PATTACH_ABSORIGIN_FOLLOW
ENT.TrailAttachPoint = 1

ENT.ExplosionEffectAngleCorrection = Angle(-90,0,0)
ENT.ExplosionEffect = "bo3_mirg2k_impact"
ENT.ExplosionEffectPaP = "bo3_mirg2k_impact_2"

ENT.SurfacePropOverride = "Gmod_Bouncy"

// Explosion Settings

ENT.ExplosionSound1 = "TFA_BO3_MIRG.Impact"
ENT.ExplosionSound2 = "TFA_BO3_MIRG.ImpactSwt"

// DLight Settings

ENT.Color = Color(65, 235, 20)
ENT.ColorPaP = Color(0, 255, 235)

ENT.DLightBrightness = 2
ENT.DLightDecay = 2000
ENT.DLightSize = 200

ENT.DLightFlashOnRemove = true

ENT.DLightFlashSize = 240
ENT.DLightFlashDecay = 2000
ENT.DLightFlashBrightness = 2

DEFINE_BASECLASS(ENT.Base)

local nzombies = engine.ActiveGamemode() == "nzombies"
local dlight_cvar = GetConVar("cl_tfa_fx_wonderweapon_dlights")

local HasStatus = TFA.WonderWeapon.HasStatus
local GiveStatus = TFA.WonderWeapon.GiveStatus
local GetStatus = TFA.WonderWeapon.GetStatus
local ShouldDamage = TFA.WonderWeapon.ShouldDamage

function ENT:SetupDataTables()
	BaseClass.SetupDataTables(self)

	self:NetworkVarTFA("Bool", "Upgraded")
	self:NetworkVarTFA("Int", "Charge")
	self:NetworkVarTFA("Vector", "HitPos")
end

function ENT:PhysicsCollide(data, phys)
	if self.Impacted then return end

	local trace = self:CollisionDataToTrace(data)

	if self:GetCharge() > 1 then
		if data.HitNormal:Dot(vector_up*-1)>0.9 then
			self.HitFloor = true

			local pos = data.HitPos
			timer.Simple(0, function()
				if not IsValid(self) then return end
				self:CreateSlipPlate(pos, angle_zero)
			end)

			self:ActivateCustom( trace )
		elseif data.Speed > 60 then
			local LastSpeed = math.max( data.OurOldVelocity:Length(), data.Speed )
			local NewVelocity = phys:GetVelocity()
			NewVelocity:Normalize()

			LastSpeed = math.max( NewVelocity:Length(), LastSpeed )
			local TargetVelocity = NewVelocity * LastSpeed * 0.1
			phys:SetVelocity( TargetVelocity )
		end
	else
		self:ActivateCustom( trace )
	end
end

function ENT:EntityCollide(trace)
	if self.Impacted then return end

	local hitEntity = trace.Entity

	local mStatus = GetStatus(hitEntity, "BO3_KT4_Infection")
	if mStatus then
		mStatus.ChainReact = true
		mStatus:SetEndTime(0)
	end

	self:ActivateCustom(trace)

	if IsValid(hitEntity) and ShouldDamage(hitEntity, self:GetOwner(), self) then
		local hitDamage = DamageInfo()
		hitDamage:SetDamage(10)
		hitDamage:SetAttacker(IsValid(self:GetOwner()) and self:GetOwner() or self)
		hitDamage:SetInflictor(IsValid(self.Inflictor) and self.Inflictor or self)
		hitDamage:SetDamageType(nzombies and DMG_RADIATION or bit.bor(DMG_BULLET, DMG_AIRBOAT))
		hitDamage:SetDamageForce(trace.Normal*math.random(8000,12000))
		hitDamage:SetDamagePosition(trace.HitPos)
		hitDamage:SetReportedPosition(trace.StartPos)

		hitEntity:DispatchTraceAttack(hitDamage, trace, trace.Normal)

		self:SendHitMarker(hitEntity, hitDamage, trace)
	end
end

function ENT:ActivateCustom( trace )
	self.Impacted = true

	self:EmitSound(self.ImpactSound)

	if !trace.IsPhysicsCollide then
		self:DoImpactEffect(trace)
	end

	local hitEntity = trace.Entity
	if !self.HitFloor and self:GetCharge() > 1 and IsValid(hitEntity) then
		local finalPos = Vector(trace.HitPos[1], trace.HitPos[2], hitEntity:GetPos()[3]) + trace.HitNormal
		local floorTrace = util.QuickTrace(finalPos, vector_up*-72, self)

		if floorTrace.Hit then
			//debugoverlay.Axis(floorTrace.HitPos, floorTrace.HitNormal:Angle(), 10, 5, true)
			timer.Simple(0, function()
				if not IsValid(self) then return end
				self:CreateSlipPlate(floorTrace.HitPos, angle_zero)
			end)
		end
	end

	self:Explode(trace.HitPos, self.Range, trace.HitNormal)

	self:PhysicsStop()

	self:Remove()
end

function ENT:Initialize()
	BaseClass.Initialize(self)

	if self:GetUpgraded() then
		self.MaxKills = self.MaxKillsPaP
	end
end

function ENT:OnWaterEnter(waterTrace, collisionTrace)
	self.Impacted = true

	sound.Play(self.ExplosionSound2, waterTrace.HitPos)

	self.HitPos = waterTrace.HitPos
	self.HitNormal = waterTrace.HitNormal
	self.HitEntity = waterTrace.Entity
	self:SetHitPos(waterTrace.HitPos)

	self:DoExplosionEffect()

	self:SetPos( self.HitPos )

	self:Remove()
end

function ENT:PreExplosionDamage( hitEntity, explosionTrace, damageinfo )
	if nzombies and (hitEntity.NZBossType or hitEntity.IsMooBossZombie or hitEntity.IsMooMiniBoss) then
		damageinfo:SetDamage(math.max(self.Damage, hitEntity:GetMaxHealth() / 9))
		damageinfo:SetDamageType( DMG_RADIATION )
	else
		if not HasStatus(hitEntity, "BO3_KT4_Infection") then
			self.Kills = self.Kills + 1
			if self.Kills > self.MaxKills then
				return true
			end

			GiveStatus(hitEntity, "BO3_KT4_Infection", math.Rand(1,1.5), self:GetOwner(), self.Inflictor, self:GetTrueDamage( hitEntity ), self:GetUpgraded())
		end

		return true //block doing damage
	end
end

function ENT:CreateSlipPlate(pos, ang)
	if self.HasCreatedPlate then return end
	self.HasCreatedPlate = true

	local qty = 10 --number of puddles you want
    local randomintensity = 0.8 --how intense the randomness should be
    local radv = 50 --size of circle
    local pi = math.pi / (qty/2)

    pos = pos + vector_up*2

	local tr = {
		start = pos,
		filter = {self},
		mask = MASK_SOLID_BRUSHONLY,
	}

	self.Damage = self.mydamage or self.Damage

	for i = 1, qty do
		local posx, posy = radv * math.sin(pi * i), radv * math.cos(pi * i)
        local offset = Vector(posx + (math.Rand(-radv, radv) * randomintensity), posy + (math.Rand(-radv, radv) * randomintensity), 0)
		tr.endpos = pos + offset
		local traceres = util.TraceLine(tr)
		local pos = pos + traceres.Normal * math.Clamp(traceres.Fraction,0,1) * offset:Length()

		local tr1 = util.TraceLine({
			start = pos,
			endpos = pos - (vector_up*32),
			filter = self,
			mask = MASK_SOLID,
		})

		if tr1.AllSolid or tr1.StartSolid or tr1.Fraction == 1 then
			continue
		end

		local goo = ents.Create("bo3_ww_mirg_puddle")
		goo:SetModel("models/hunter/plates/plate075x075.mdl")
		goo:SetPos(pos)
		goo:SetOwner(self:GetOwner())
		goo:SetAngles(ang)

		goo:SetUpgraded(self:GetUpgraded())
		goo:SetCharge(self:GetCharge())

		goo.Damage = self.Damage
		goo.mydamage = self.Damage
				
		goo:Spawn()

		goo:SetOwner(self:GetOwner())
		goo.Inflictor = self.Inflictor

		table.insert(tr.filter, goo)
	end
end
