
AddCSLuaFile()

ENT.Base = "tfa_ww_base"
ENT.PrintName = "Ragnarok DG5"

// Custom Settings

ENT.ConsumptionRate = 1

ENT.TakenAmmo = 0

ENT.VortexStartSound = "TFA_BO4_DG5.Vortex.Start"
ENT.VortexLoopSound = "TFA_BO4_DG5.Vortex.Loop"
ENT.VortexEndSound = "TFA_BO4_DG5.Vortex.End"

// Default Settings

ENT.Range = 160

ENT.InfiniteDamage = true

ENT.NoDrawNoShadow = true

ENT.HullMaxs = Vector(1, 1, 1)
ENT.HullMins = ENT.HullMaxs:GetNegated()

ENT.TrailEffect = "bo3_dg4_placed"
ENT.TrailAttachType = PATTACH_ABSORIGIN_FOLLOW
ENT.TrailAttachPoint = 1

ENT.BubbleTrail = false

// nZombies Settings

ENT.NZThrowIcon = Material("vgui/icon/ui_icon_equipment_zm_gravityspikes_lv3_dark.png", "unlitgeneric smooth")
ENT.NZHudIcon = Material("vgui/icon/ui_icon_equipment_zm_gravityspikes_lv3_dark.png", "smooth unlitgeneric")

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

local vector_down_64 = Vector(0, 0, -64)

local BodyTarget = TFA.WonderWeapon.BodyTarget
local GiveStatus = TFA.WonderWeapon.GiveStatus
local DoDeathEffect = TFA.WonderWeapon.DoDeathEffect

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

		return ply:Nick().."'s - Ragnarok DG5s"
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

	self:SetMoveType(MOVETYPE_NONE)

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
	if CLIENT then return end
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

	if SERVER then
		local wep = self:GetWeapon()

		if not IsValid(self:GetOwner()) then
			self:StopSound(self.VortexLoopSound)
			self:Remove()
			return false
		end

		if (self:GetAmmoCount() <= 0 or self.TakenAmmo >= 100 or (IsValid(wep) and (nzombies and wep:Clip1() or wep:Ammo1()) <= 0)) and self:GetActivated() then
			self:DisableVortex()
			return false
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

	self:NextThink(CurTime())
	return true
end

local liftclasses = {
	["nz_zombie_boss_fireman"] = true,
	["nz_zombie_boss_krasny"] = true,
	["nz_zombie_boss_panzer"] = true,
	["nz_zombie_boss_panzer_bo3"] = true,
}

function ENT:DisableVortex()
	self:SetActivated(false)

	self:StopParticles()

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

	self:Remove()
end

function ENT:RevivePlayers()
	local ply = self:GetOwner()
	local vecSrc = self:GetPos()

	for _, v in pairs(nzRound:InState(ROUND_CREATE) and player.GetAll() or player.GetAllPlaying()) do
		if v:IsPlayer() and v:Alive() and !v:GetNotDowned() and !v.DownedWithSoloRevive and v:GetPos():DistToSqr(vecSrc) < 25600 and v:IsLineOfSightClear(vecSrc + vector_up) then
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

function ENT:DoRadiusDamage()
	local vecSrc = self:GetPos()

	local ply = self:GetOwner()

	local nearbyEnts = self:FindNearestEntities( self:GetPos(), self.Range )

	local tr = {
		start = vecSrc,
		filter = { self, self.Inflictor },
		mask = MASK_SHOT,
		collsiongroup = COLLISION_GROUP_NONE,
	}

	local pPlayer = ( IsValid(self:GetOwner()) and self:GetOwner() or self )
	local pWeapon = ( IsValid(self.Inflictor) and self.Inflictor or self )
	local pInflictor = self

	local bSubmerged = bit_AND( util_PointContents( vecSrc + vector_up*24 ), CONTENTS_LIQUID ) ~= 0

	for k, ent in ipairs(nearbyEnts) do
		if liftclasses[ent:GetClass()] or ent.CanPanzerLift then
			GiveStatus(ent, "BO3_Ragnarok_Lift_Boss", 0.5)
			continue
		end

		if ent:IsWeapon() then
			continue
		end

		local hitCharacter = ent:IsPlayer() or ent:IsNPC() or ent:IsNextBot()
		if not hitCharacter and damage_cvar and damage_cvar:GetBool() then
			local phys = ent:GetPhysicsObject()
			local groundTrace = util.TraceLine({
				start = ent:GetPos(),
				endpos = ent:GetPos() + vector_down_64,
				mask = MASK_SOLID_BRUSHONLY,
				filter = { ent, self },
			})

			if IsValid( phys ) and phys:IsMotionEnabled() and phys:GetMass() < 202 and groundTrace.HitWorld then
				if phys:IsAsleep() then
					phys:Wake()
				end

				local force = ( phys:GetMass() * physenv.GetGravity():GetNegated() ) + vector_up * math.sin( CurTime() * 30 ) * math.random( 0, 30 )
				local dt = engine.TickInterval()

				phys:ApplyForceCenter( force * dt )
			end

			continue
		end

		local vecSpot = BodyTarget(ent, vecSrc, true)

		local dir = ( vecSpot - vecSrc ):GetNormalized()

		tr.endpos = vecSpot

		local trace = util_TraceLine(tr)

		local damageinfo = DamageInfo()
		damageinfo:SetDamage( self:GetTrueDamage(ent) )
		damageinfo:SetDamageType( DMG_ENERGYBEAM )
		damageinfo:SetAttacker( pPlayer )
		damageinfo:SetInflictor( nzombies and pWeapon or pInflictor )
		damageinfo:SetDamageForce( ent:GetUp() * math.random(18000,24000) + dir * math.random(12000,16000) )
		damageinfo:SetDamagePosition( trace.Entity == ent and trace.HitPos or vecSpot )
		damageinfo:SetReportedPosition( vecSrc )

		if IsValid(self.Inflictor) then
			damageinfo:SetWeapon( self.Inflictor )
		end

		if ent:IsNPC() and ent:Alive() and damageinfo:GetDamage() >= ent:Health() then
			ent:SetCondition(COND.NPC_UNFREEZE)
		end

		DoDeathEffect( ent, "BO3_Ragnarok", math.Rand( 2.5, 4 ) )

		if trace.Entity == ent then
			trace.HitGroup = trace.HitGroup == HITGROUP_HEAD and HITGROUP_HEAD or HITGROUP_GENERIC

			self:DoImpactEffect( trace, true )

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

			ent:DispatchTraceAttack( damageinfo, trace, dir )
		else
			ent:TakeDamageInfo( damageinfo )
		end

		self:IgnoreEntity( ent, 1/3 )

		table.insert( tr.filter, ent )

		self:SendHitMarker( ent, damageinfo, trace )
	end

	util_ScreenShake(vecSrc, 4, 255, 0.1, self.Range*1.5)
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
			ply:Give("tfa_bo4_dg5", true)

			local wep = ply:GetWeapon("tfa_bo4_dg5")
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
