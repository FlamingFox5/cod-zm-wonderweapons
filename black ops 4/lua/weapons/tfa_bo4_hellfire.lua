local nzombies = engine.ActiveGamemode() == "nzombies"
local inf_cvar = GetConVar("sv_tfa_bo3ww_inf_specialist")
local dlight_cvar = GetConVar("cl_tfa_fx_wonderweapon_dlights")
local sv_true_damage = GetConVar("sv_tfa_bo3ww_cod_damage")
local sv_damage_world = GetConVar("sv_tfa_bo3ww_environmental_damage")

SWEP.Base = "tfa_gun_base"
SWEP.Category = "TFA Wonder Weapons"
SWEP.SubCategory = "Black Ops 4"
SWEP.Spawnable = TFA_BASE_VERSION and TFA_BASE_VERSION >= 4.76
SWEP.AdminSpawnable = true
SWEP.UseHands = true
SWEP.Type_Displayed = "#tfa.weapontype.specialist"
SWEP.Purpose = "Assembled with Russian know-how from the scraps of war and inter-dimensional combat, the Hellfire flamethrower has incinerated legions of filthy hell-pigs."
SWEP.Author = "FlamingFox"
SWEP.Slot = 0
SWEP.PrintName = nzombies and "Hellfire | BO4" or "Hellfire"
SWEP.DrawCrosshair = true
SWEP.DrawCrosshairIronSights = false
SWEP.WWCrosshairEnabled = true
SWEP.AutoSwitchTo = false

--[Model]--
SWEP.ViewModel			= "models/weapons/tfa_bo4/hellfire/c_hellfire.mdl"
SWEP.ViewModelFOV = 65
SWEP.WorldModel			= "models/weapons/tfa_bo4/hellfire/w_hellfire.mdl"
SWEP.HoldType = "ar2"
SWEP.CameraAttachmentOffsets = {}
SWEP.CameraAttachmentScale = 1
SWEP.MuzzleAttachment = "1"
SWEP.MuzzleAttachmentSilenced = "2"
SWEP.VMPos = Vector(0, 0, 0)
SWEP.VMAng = Vector(0, 0, 0)
SWEP.VMPos_Additive = true

SWEP.Offset = { --Procedural world model animation, defaulted for CS:S purposes.
        Pos = {
        Up = -1,
        Right = 1.2,
        Forward = 4,
        },
        Ang = {
		Up = -180,
        Right = 195,
        Forward = 0
        },
		Scale = 1
}

--[Gun Related]--
SWEP.Primary.Sound = "TFA_BO4_HELLFIRE.Start"
SWEP.Primary.LoopSound = "TFA_BO4_HELLFIRE.Loop"
SWEP.Primary.LoopSoundTail = "TFA_BO4_HELLFIRE.Stop"
SWEP.Primary.Ammo = nzombies and "none" or "AlyxGun"
SWEP.Primary.Automatic = true
SWEP.Primary.RPM = 1200
SWEP.Primary.RPM_Semi = nil
SWEP.Primary.RPM_Burst = nil
SWEP.Primary.Damage = nzombies and 115 or 24
SWEP.Primary.Knockback = 0
SWEP.Primary.NumShots = 1
SWEP.Primary.AmmoConsumption = inf_cvar:GetBool() and 0 or 1
SWEP.Primary.ClipSize = nzombies and 300 or -1
SWEP.Primary.DefaultClip = 300
SWEP.Primary.DryFireDelay = 0.35
SWEP.MuzzleFlashEffect	= ""
SWEP.MuzzleFlashEffectSilenced = "tfa_bo4_muzzleflash_hellfire_2"
SWEP.MuzzleFlashEnabled = false
SWEP.DisableChambering = true
SWEP.FiresUnderwater = true

--[Firemode]--
SWEP.Primary.BurstDelay = nil
SWEP.DisableBurstFire = true
SWEP.SelectiveFire = false
SWEP.OnlyBurstFire = false
SWEP.BurstFireCount = nil

--[LowAmmo]--
SWEP.FireSoundAffectedByClipSize = false
SWEP.LowAmmoSoundThreshold = 0 --0.33
SWEP.LowAmmoSound = ""
SWEP.LastAmmoSound = ""

--[Range]--
SWEP.Primary.Range = 450
SWEP.Primary.RangeFalloff = -1
SWEP.Primary.DisplayFalloff = false
SWEP.DisplayFalloff = false

--[Recoil]--
SWEP.ViewModelPunchPitchMultiplier = -0.2 --0.5
SWEP.ViewModelPunchPitchMultiplier_IronSights = 0.09 --.09

SWEP.ViewModelPunch_MaxVertialOffset				= 2.5 --3
SWEP.ViewModelPunch_MaxVertialOffset_IronSights		= 1.95 --1.95
SWEP.ViewModelPunch_VertialMultiplier				= 0.5 --1
SWEP.ViewModelPunch_VertialMultiplier_IronSights	= 0.25 --0.25

SWEP.ViewModelPunchYawMultiplier = 0.25 --0.6
SWEP.ViewModelPunchYawMultiplier_IronSights = 0.25 --0.25

SWEP.ChangeStateRecoilMultiplier = 1.3 --1.3
SWEP.CrouchRecoilMultiplier = 0.65 --0.65
SWEP.JumpRecoilMultiplier = 1.65 --1.3
SWEP.WallRecoilMultiplier = 1.1 --1.1

--[Spread Related]--
SWEP.Primary.Spread		  = .04
SWEP.Primary.IronAccuracy = .01
SWEP.IronRecoilMultiplier = 0.6
SWEP.CrouchAccuracyMultiplier = 0.85

SWEP.Primary.KickUp				= 0.1
SWEP.Primary.KickDown			= 0
SWEP.Primary.KickHorizontal		= 0.1
SWEP.Primary.StaticRecoilFactor	= 0.2

SWEP.Primary.SpreadMultiplierMax = 2
SWEP.Primary.SpreadIncrement = 0
SWEP.Primary.SpreadRecovery = 2

SWEP.ChangeStateAccuracyMultiplier = 1.5 --1.5
SWEP.CrouchAccuracyMultiplier = 1.0 --0.5
SWEP.JumpAccuracyMultiplier = 3.0 --2
SWEP.WalkAccuracyMultiplier = 1.35 --1.35

--[Projectile]--
SWEP.Secondary.Projectile		= "bo4_specialist_hellfire"
SWEP.Secondary.ProjectileModel	= "models/hunter/plates/plate.mdl"

--[Iron Sights]--
SWEP.data = {}
SWEP.data.ironsights = 0

--[Shells]--
SWEP.LuaShellEject = false
SWEP.LuaShellEffect = "ShellEject"
SWEP.LuaShellModel = "models/tfa/rifleshell.mdl"
SWEP.LuaShellScale = 0.5
SWEP.LuaShellEjectDelay = 0
SWEP.ShellAttachment = "0"
SWEP.EjectionSmokeEnabled = false

--[Misc]--
SWEP.InspectPos = Vector(11, -2, -3)
SWEP.InspectAng = Vector(24, 42, 16)
SWEP.MoveSpeed = 0.95
SWEP.IronSightsMoveSpeed = SWEP.MoveSpeed * 0.8
SWEP.SafetyPos = Vector(-1, -2, -0.5)
SWEP.SafetyAng = Vector(-15, 25, -20)
SWEP.ImpactDecal = "Dark"
SWEP.SmokeParticle = ""

--[NZombies]--
SWEP.NZWonderWeapon = false
SWEP.NZSpecialCategory = "specialist"
SWEP.NZSpecialWeaponData = {MaxAmmo = 0, AmmoType = "none"}

SWEP.NZSpecialistResistanceData = {
	Types = bit.bor(DMG_BURN, DMG_SLOWBURN, DMG_VEHICLE),
	Percent = 0.9, // 0 - 1, 1 being 100% reduction
	MinimumDamage = 5,
}

SWEP.NZHudIcon = Material("vgui/icon/ui_icon_equipment_zm_flamethrower_lvl3_dark.png", "unlitgeneric smooth")

SWEP.AmmoRegen = 3

function SWEP:NZSpecialHolster(wep)
	return true
end

function SWEP:OnSpecialistRecharged()
	if CLIENT then
		self.NZPickedUpTime = CurTime()
	end
	self:SetHasNuked(false)
end

--[Tables]--
SWEP.SequenceLengthOverride = {
}

SWEP.SprintAnimation = {
	["in"] = {
		["type"] = TFA.Enum.ANIMATION_SEQ, --Sequence or act
		["value"] = "sprint_in", --Number for act, String/Number for sequence
	},
	["loop"] = {
		["type"] = TFA.Enum.ANIMATION_SEQ, --Sequence or act
		["value"] = "sprint_loop", --Number for act, String/Number for sequence
		["is_idle"] = true
	},
	["out"] = {
		["type"] = TFA.Enum.ANIMATION_SEQ, --Sequence or act
		["value"] = "sprint_out", --Number for act, String/Number for sequence
	}
}

SWEP.EventTable = {
[ACT_VM_DRAW_DEPLOYED] = {
{ ["time"] = 0, ["type"] = "sound", ["value"] = Sound("TFA_BO4_OVERKILL.Deploy") },
{ ["time"] = 0, ["type"] = "sound", ["value"] = Sound("TFA_BO4_HELLFIRE.Raise") },
},
[ACT_VM_DRAW] = {
{ ["time"] = 0, ["type"] = "sound", ["value"] = Sound("TFA_BO4_HELLFIRE.Draw") },
},
[ACT_VM_HOLSTER] = {
{ ["time"] = 0, ["type"] = "sound", ["value"] = Sound("TFA_BO4_HELLFIRE.Holster") },
{ ["time"] = 5 / 30, ["type"] = "lua", value = function(self) self:StopFirstPersonParticles() end, client = true, server = false},
},
[ACT_VM_PULLBACK] = {
{ ["time"] = 0, ["type"] = "sound", ["value"] = Sound("TFA_BO4_HELLFIRE.Ult") },
},
[ACT_VM_SECONDARYATTACK] = {
{ ["time"] = 0, ["type"] = "sound", ["value"] = Sound("TFA_BO4_HELLFIRE.Charge") },
},
}

--[Shit]--
SWEP.AllowViewAttachment = true --Allow the view to sway based on weapon attachment while reloading or drawing, IF THE CLIENT HAS IT ENABLED IN THEIR CONVARS.
SWEP.Sprint_Mode = TFA.Enum.LOCOMOTION_HYBRID -- ANI = mdl, HYBRID = ani + lua, Lua = lua only
SWEP.Sights_Mode = TFA.Enum.LOCOMOTION_HYBRID -- ANI = mdl, HYBRID = lua but continue idle, Lua = stop mdl animation
SWEP.Idle_Mode = TFA.Enum.IDLE_BOTH --TFA.Enum.IDLE_DISABLED = no idle, TFA.Enum.IDLE_LUA = lua idle, TFA.Enum.IDLE_ANI = mdl idle, TFA.Enum.IDLE_BOTH = TFA.Enum.IDLE_ANI + TFA.Enum.IDLE_LUA
SWEP.Idle_Blend = 0.25 --Start an idle this far early into the end of a transition
SWEP.Idle_Smooth = 0.05 --Start an idle this far early into the end of another animation
SWEP.SprintBobMult = 0

SWEP.Secondary.RPM = 120
SWEP.Secondary.AmmoConsumption = inf_cvar:GetBool() and 0 or 20
SWEP.Secondary.Sound = "TFA_BO4_HELLFIRE.AirBlast"

SWEP.CylinderRadius = 100
SWEP.CylinderRange = 250
SWEP.CylinderKillRange = 150

SWEP.StatCache_Blacklist = {
	["MuzzleFlashEffect"] = true,
}

SWEP.ViewModelBoneMods = {
	["tag_dial_animate"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
}

SWEP.Glow = Material("models/weapons/tfa_bo4/hellfire/xmaterial_a290e21cf1a3fee.vmt")
SWEP.FlameSize = Vector(8,8,8)
SWEP.FlameSizeMin = SWEP.FlameSize:GetNegated()
SWEP.FlameDistance = 24

SWEP.WWFP_FX = "bo4_hellfire_vm"
SWEP.WWFP_FX_uw = "bo4_hellfire_vm_uwater"
SWEP.WWFP_ATT = 4

SWEP.WWFP_FXb = "bo4_hellfire_pilot"
SWEP.WWFP_ATTb = 2

SWEP.WW3P_FX = "bo4_hellfire_3p"
SWEP.WW3P_ATT = 4

--[Coding]--
DEFINE_BASECLASS( SWEP.Base )

local developer = GetConVar("developer")
local phys_pushscale = GetConVar("phys_pushscale")
local tpfx_cvar = GetConVar("cl_tfa_fx_wonderweapon_3p")

local l_CT = CurTime
local sp = game.SinglePlayer()

local CONTENTS_LIQUID = bit.bor( CONTENTS_WATER, CONTENTS_SLIME )
local doorClasses = {
	["prop_door_rotating"] = true,
	["func_door"] = true,
	["func_door_rotating"] = true,
}

local CLIENT_RAGDOLLS = {
	["class C_ClientRagdoll"] = true,
	["class C_HL2MPRagdoll"] = true,
}

local Impulse = TFA.WonderWeapon.CalculateImpulseForce

function SWEP:SetupDataTables(...)
	BaseClass.SetupDataTables(self,...)

	self:NetworkVarTFA("Float", "GlowRatio")

	self:NetworkVarTFA("Bool", "HasEmitSound")
	self:NetworkVarTFA("Bool", "HasNuked")
	self:NetworkVarTFA("Bool", "MainGlow")

	self:NetworkVarTFA("Entity", "FireTornado")

	self:SetMainGlow(true)
end

function SWEP:PreDrawViewModel(vm, ...)
	BaseClass.PreDrawViewModel(self, vm, ...)

	local owner = IsValid(self:GetOwner()) and self:GetOwner() or self
	local status = self:GetStatus()
	local bNotUnderwater = ( not IsValid(owner) or ( owner.WaterLevel and owner:WaterLevel() < 3 or ( not owner.WaterLevel ) ) )

	self:AddDrawCallViewModelParticle(bNotUnderwater and self.WWFP_FX or self.WWFP_FX_uw, PATTACH_POINT_FOLLOW, tonumber(self.WWFP_ATT), true, "BO4_Hellfire_Passive")
	self:AddDrawCallViewModelParticle(self.WWFP_FXb, PATTACH_POINT_FOLLOW, tonumber(self.WWFP_ATTb), bNotUnderwater, "BO4_Hellfire_Pilot")

	if dlight_cvar:GetBool() and DynamicLight and bNotUnderwater then
		self.DLight = self.DLight or DynamicLight(self.OwnerViewModel:EntIndex(), true)

		if self.DLight and !TFA.Enum.HolsterStatus[status] then
			local attpos = self.OwnerViewModel:GetAttachment(4)

			if (attpos and attpos.Pos) then
				self.DLight.pos = attpos.Pos
				self.DLight.dir = attpos.Ang:Forward()
				self.DLight.r = 255
				self.DLight.g = 60
				self.DLight.b = 0
				self.DLight.decay = 2000
				self.DLight.brightness = 0.5
				self.DLight.size = 64
				self.DLight.dietime = CurTime() + 0.5
			end
		end
	elseif self.DLight then
		self.DLight.dietime = -1
	end
end

function SWEP:DrawWorldModel(...)
	BaseClass.DrawWorldModel(self, ...)

	local owner = IsValid(self:GetOwner()) and self:GetOwner() or self
	local status = self:GetStatus()
	local bNotUnderwater = ( not IsValid(owner) or ( owner.WaterLevel and owner:WaterLevel() < 3 or ( not owner.WaterLevel ) ) )

	self:AddDrawCallWorldModelParticle(self.WW3P_FX, PATTACH_POINT_FOLLOW, tonumber(self.WW3P_ATT), tpfx_cvar:GetBool() and not TFA.Enum.HolsterStatus[status] and not bNotUnderwater)

	if dlight_cvar:GetBool() and DynamicLight and bNotUnderwater then
		self.DLight = self.DLight or DynamicLight(self:EntIndex())

		if self.DLight and !TFA.Enum.HolsterStatus[status] then
			local attpos = self:GetAttachment(4)

			if (attpos and attpos.Pos) then
				self.DLight.pos = attpos.Pos
				self.DLight.dir = attpos.Ang:Forward()
				self.DLight.r = 255
				self.DLight.g = 60
				self.DLight.b = 0
				self.DLight.decay = 2000
				self.DLight.brightness = 1
				self.DLight.size = 64
				self.DLight.dietime = CurTime() + 0.5
			end
		end
	elseif self.DLight then
		self.DLight.dietime = -1
	end
end

function SWEP:CanPrimaryAttack(...)
	return not TFA.Enum.ChargeStatus[self:GetStatus()] and BaseClass.CanPrimaryAttack(self, ...)
end

function SWEP:OnWaterLevelChanged(ply, old, new)
	if old < 3 and new > 2 then
		self:StopFirstPersonParticles()
	elseif old > 2 and new < 3 then
		self:StopFirstPersonParticles()
	end
end

function SWEP:StopFirstPersonParticles()
	if SERVER then return end
	if not self:VMIV() then return end

	self:AddDrawCallViewModelParticle(self.WWFP_FX, PATTACH_POINT_FOLLOW, tonumber(self.WWFP_ATT), false, "BO4_Hellfire_Passive")
	self:AddDrawCallViewModelParticle(self.WWFP_FXb, PATTACH_POINT_FOLLOW, tonumber(self.WWFP_ATTb), false, "BO4_Hellfire_Pilot")
end

function SWEP:Deploy(...)
	local bDeploy = BaseClass.Deploy(self, ...)

	if SERVER and self.IsFirstDeploy then
		TFA.WonderWeapon.SpecialistDeploy(self, self:GetOwner(), 128)
	end

	return bDeploy
end

function SWEP:GetSecondaryDelay()
	local rpm2 = self:GetStat("Secondary.RPM")
	if rpm2 and rpm2 > 0 then
		return 60 / rpm2
	end
end

function SWEP:Think2(...)
	local ply = self:GetOwner()
	local status = self:GetStatus()
	local statusend = CurTime() >= self:GetStatusEnd()

	if self:GetGlowRatio() > 0 and ( status ~= TFA.Enum.STATUS_SHOOTING or ply:WaterLevel() > 2 ) then
		self:SetGlowRatio(math.Approach(self:GetGlowRatio(), 0, FrameTime()))
	end

	if status == TFA.Enum.STATUS_CHARGE_UP and statusend then
		self:PreSecondaryAttack()

		self.Silenced = true
		self:SetSilenced(self.Silenced)
		self.DoMuzzleFlash = true

		self:ShootEffectsCustom()
		self.Silenced = false
		self:SetSilenced(self.Silenced)

		self:EmitGunfireSound(self:GetStatL("Secondary.Sound"))

		if hook.Run("TFA_SecondaryAttack", self) then return end
		self:Airblast()

		self:SetNextPrimaryFire(self:GetActivityLength())
		self:ScheduleStatus(TFA.Enum.STATUS_CHARGE_DOWN, self:GetSecondaryDelay())
	end

	if ply.WaterLevel then
		if ply:WaterLevel() > 2 and self:GetMainGlow() then
			self:SetMainGlow(false)
		elseif ply:WaterLevel() < 3 and not self:GetMainGlow() then
			self:SetMainGlow(true)
		end
	end

	if IsValid(ply) and ply:IsPlayer() and self:VMIV() then
		local maxClip = (nzombies and self:GetStat("Primary.ClipSize") or self:GetStat("Primary.DefaultClip"))
		local clip = (nzombies and self:Clip1() or self:Ammo1())
		local clipRatio = math.Clamp(clip - maxClip, -maxClip, 0)

		self.ViewModelBoneMods["tag_dial_animate"].angle = Angle(0,0,math.Truncate(clipRatio*0.77) - 130)
	end

	if nzombies and ply:IsPlayer() and ply:GetAmmoCount(self:GetPrimaryAmmoType()) > 0 then
		ply:SetAmmo(0, self:GetPrimaryAmmoType())
	end

	if self:GetHasEmitSound() and status ~= TFA.Enum.STATUS_SHOOTING then
		self:SetHasEmitSound(false)
		if IsFirstTimePredicted() then
			self:EmitSound("TFA_BO4_HELLFIRE.CoolDown")
		end
	end

	return BaseClass.Think2(self,...)
end

function SWEP:PrePrimaryAttack()
	local ply = self:GetOwner()
	if not IsValid(ply) then return end
	if !ply:IsPlayer() then return end

	if self:CanPrimaryAttack() and !self:GetHasEmitSound() then
		self:StopSound("TFA_BO4_HELLFIRE.CoolDown")
		self:SetHasEmitSound(true)
		if IsFirstTimePredicted() then
			local fx = EffectData()
			fx:SetStart(ply:GetShootPos())
			fx:SetNormal(self:GetOwner():EyeAngles():Forward())
			fx:SetEntity(self)
			fx:SetAttachment(self:GetMuzzleAttachment())

			TFA.Effects.Create("tfa_bo4_muzzleflash_hellfire", fx)

			self:EmitGunfireSound(self:GetStatL("Primary.Sound"))
		end
	end
end

function SWEP:PostPrimaryAttack()
	local ply = self:GetOwner()
	local plyInWater = ply:WaterLevel() > 2

	if IsValid(ply) and not plyInWater then
		self:SetGlowRatio(math.Approach(self:GetGlowRatio(), 2, FrameTime()*3))
	end

	local aim = self:GetAimVector()
	local ifp = IsFirstTimePredicted()
	if not IsValid(ply) then return end

	local n_range_squared = self:GetStatL("Primary.Range")*self:GetStatL("Primary.Range")
	local n_range_inner_squared = n_range_squared*0.5

	local start_pos = ply:GetShootPos()
	local aim_vec = ply:GetAimVector()

	local hitMask = plyInWater and bit.bor( MASK_SHOT, CONTENTS_GRATE ) or bit.bor( MASK_SHOT, CONTENTS_GRATE, CONTENTS_LIQUID )

	local hitTrace = util.TraceLine({
		start = start_pos,
		endpos = start_pos + (aim_vec*self:GetStatL("Primary.Range")),
		filter = {ply, self},
		mask = hitMask,
	})

	local end_pos = hitTrace.HitPos
	if SERVER then
		local suicide = util.TraceLine({
			start = start_pos,
			endpos = start_pos + (aim_vec*self:GetStatL("Primary.Range")) - vector_up*(8*hitTrace.Fraction),
			filter = {ply, self},
			mask = hitMask,
		})

		local hitEntity = suicide.Entity

		if suicide.Hit and ( not ( hitEntity:IsNPC() or hitEntity:IsNextBot() or hitEntity:IsPlayer() or hitEntity:IsRagdoll() ) or plyInWater ) then
			timer.Simple(0.25*suicide.Fraction, function()
				ParticleEffect(plyInWater and "bo3_uwater_splash" or "bo4_hellfire_impact", suicide.HitPos, suicide.HitNormal:Angle())
				if bit.band(util.PointContents(suicide.HitPos), CONTENTS_LIQUID) == 0 then
					util.Decal("Dark", suicide.HitPos, suicide.HitPos + suicide.Normal*4, self)
				end
			end)
		end
	end

	local tr = {
		filter = {ply, self},
		mask = MASK_SHOT,
	}

	for i, ent in pairs( ents.FindAlongRay( start_pos, end_pos, self.FlameSizeMin, self.FlameSize ) ) do
		if ent == ply then continue end
		if not TFA.WonderWeapon.ShouldDamage(ent, ply, self) then continue end

		local test_origin = ent:WorldSpaceCenter()
		local radial_origin = TFA.WonderWeapon.PointOnSegmentNearestToPoint( start_pos, end_pos, test_origin )

		local bEntUnderwater = ent:WaterLevel() > 2

		local bIsUnderwater = bit.band( util.PointContents( radial_origin ), CONTENTS_LIQUID ) ~= 0
		if ( bIsUnderwater and not bEntUnderwater ) or ( not bIsUnderwater and bEntUnderwater ) then
			continue
		end

		tr.start = radial_origin
		tr.endpos = test_origin

		local trace = util.TraceLine(tr)
		local trace2 = {}

		if TFA.WonderWeapon.FindHullIntersection(ent, trace, trace2) then
			if CLIENT then
				if sv_damage_world and sv_damage_world:GetBool() and CLIENT_RAGDOLLS[ent:GetClass()] and ent.Ignite then
					ent:Ignite(4)
				end

				continue
			end

			local ratio = 1 - math.Clamp((n_range_squared - n_range_squared + n_range_inner_squared) / n_range_inner_squared, 0, 0.5)
			self:InflictDamage(ent, ratio, radial_origin, trace2.HitPos)
		end
	end
end

local cv_doordestruction = GetConVar("sv_tfa_melee_doordestruction")

function SWEP:HandleDoor(ent)
	if CLIENT or not IsValid(ent) then return end

	if not cv_doordestruction:GetBool() then return end

	if ent:GetClass() == "func_door_rotating" or ent:GetClass() == "prop_door_rotating" then
		ent:EmitSound("ambient/materials/door_hit1.wav", 100, math.random(80, 120))

		local newname = "TFABash" .. self:EntIndex()
		self.PreBashName = self:GetName()
		self:SetName(newname)

		ent:SetKeyValue("Speed", "500")
		ent:SetKeyValue("Open Direction", "Both directions")
		ent:SetKeyValue("opendir", "0")
		ent:Fire("unlock", "", .01)
		ent:Fire("openawayfrom", newname, .01)

		timer.Simple(0.02, function()
			if not IsValid(self) or self:GetName() ~= newname then return end

			self:SetName(self.PreBashName)
		end)

		timer.Simple(0.3, function()
			if IsValid(ent) then
				ent:SetKeyValue("Speed", "100")
			end
		end)
	end
end

function SWEP:SecondaryAttack()
	local self2 = self:GetTable()
	local ply = self:GetOwner()
	if not IsValid(ply) then return end

	if not IsValid(self) then return end
	if ply:IsPlayer() and not self:VMIV() then return end
	if not self:CanPrimaryAttack() then return end

	if self:GetStatus() ~= TFA.Enum.STATUS_CHARGE_UP then
		self:SendViewModelAnim(ACT_VM_SECONDARYATTACK)
		self:ScheduleStatus(TFA.Enum.STATUS_CHARGE_UP, 0.25)
		self:SetNextPrimaryFire(self:GetActivityLength())

		self:TakePrimaryAmmo(self:GetStatL("Secondary.AmmoConsumption"))
	end
end

function SWEP:AltAttack()
	local ply = self:GetOwner()
	if not IsValid(ply) then return end

	if TFA.Enum.ReadyStatus[self:GetStatus()] then
		local tornado = self:GetFireTornado()
		if not self:GetHasNuked() and not IsValid(tornado) then
			if (not nzombies and not self:CanPrimaryAttack()) then return end
			if nzombies then
				self:SetHasNuked(true)
			end
			self:TakePrimaryAmmo(self:GetStatL("Secondary.AmmoConsumption"))

			if SERVER then
				local ent = ents.Create(self:GetStatL("Secondary.Projectile"))
				ent:SetModel(self:GetStatL("Secondary.ProjectileModel"))
				ent:SetPos(ply:WorldSpaceCenter())
				ent:SetOwner(ply)
				ent:SetAngles(ply:GetForward():Angle())

				ent.damage = self:GetStatL("Primary.Damage")
				ent.mydamage = self:GetStatL("Primary.Damage")

				ent:Spawn()

				ent:SetOwner(ply)

				self:SetFireTornado(ent)
			end
		elseif IsValid(tornado) then
			tornado:SetActivated(not tornado:GetActivated())
			tornado:SetLocalVelocity(vector_origin)
		end

		self:SendViewModelAnim(ACT_VM_PULLBACK)
		self:ScheduleStatus(TFA.Enum.STATUS_BASHING , self:GetActivityLength())
		self:SetNextPrimaryFire(self:GetStatusEnd())
	end
end

function SWEP:Airblast()
	local ply = self:GetOwner()
	if SERVER and ply:IsPlayer() then
		ply:SetAnimation(PLAYER_ATTACK1)
	end

	local outer_range = self.CylinderRange
	local cylinder_radius = self.CylinderRadius
	local kill_range = self.CylinderKillRange
	local instant_kill_range_squared = 36^2

	local view_pos = ply:GetShootPos()
	local forward_view_angles = self:GetAimVector()
	local end_pos = view_pos + (forward_view_angles * outer_range)

	local start_pos = ply:GetShootPos()
	local aim_vec = ply:GetAimVector()

	local trace = util.TraceLine({
		start = start_pos,
		endpos = start_pos + (aim_vec*self.CylinderRange),
		filter = {ply, self},
		mask = bit.bor( MASK_SHOT, CONTENTS_GRATE ),
	})

	local hitEnt = trace.Entity

	if SERVER then
		if IsValid(hitEnt) and hitEnt.GetMoveType and hitEnt:GetMoveType() == MOVETYPE_PUSH and doorClasses[hitEnt:GetClass()] then
			timer.Simple(0.2*trace.Fraction, function()
				if not IsValid(self) then return end
				if not IsValid(hitEnt) then return end
				self:HandleDoor(hitEnt)
			end)
		end
	else
		local contents = util.PointContents(trace.HitPos - trace.Normal)

		if bit.band(contents, CONTENTS_LIQUID) ~= 0 then
			local uwtrace = util.TraceLine({
				start = view_pos,
				endpos = end_pos,
				mask = CONTENTS_LIQUID,
			})

			local fxdata = EffectData()
			fxdata:SetOrigin(uwtrace.HitPos)
			fxdata:SetNormal(uwtrace.HitNormal)
			fxdata:SetScale(14 * (1 - math.Remap(uwtrace.Fraction, 0, 1, 0, 0.5)))
			fxdata:SetFlags(bit.band(uwtrace.Contents, CONTENTS_SLIME) ~= 0 and 1 or 0)

			util.Effect("gunshotsplash", fxdata, false, true)
		end
	end

	for i, ent in pairs(ents.FindInSphere(view_pos, outer_range*1.1)) do
		if ent == ply then continue end
		if !TFA.WonderWeapon.ShouldDamage(ent, ply, self) then continue end

		local outer_range_squared = outer_range * outer_range
		local cylinder_radius_squared = cylinder_radius * cylinder_radius
		local kill_range_squared = kill_range * kill_range

		local test_origin = ent:WorldSpaceCenter()
		local test_range_squared = view_pos:DistToSqr(test_origin)
		if test_range_squared > outer_range_squared then
			continue // everything else in the list will be out of range
		end

		local normal = (test_origin - view_pos):GetNormalized()
		local dot = forward_view_angles:Dot(normal)
		if 0 > dot then
			continue // guy's behind us
		end

		local radial_origin = TFA.WonderWeapon.PointOnSegmentNearestToPoint( view_pos, end_pos, test_origin )
		if test_origin:DistToSqr(radial_origin) > cylinder_radius_squared then
			continue // guy's outside the range of the cylinder of effect
		end

		if CLIENT then
			self:FlingClientRagdoll(ent, view_pos, forward_view_angles)
			continue
		end

		if SERVER and ent:IsRagdoll() then
			self:FlingServerRagdoll(ent, view_pos, forward_view_angles)
			continue
		end

		if not ent:IsSolid() then continue end

		local trace1 = util.TraceLine({
			start = view_pos,
			endpos = test_origin,
			mask = MASK_SHOT,
			filter = {self, ply},
		})

		local hitpos = trace1.Entity == ent and trace1.HitPos or test_origin

		if not ply:VisibleVec( test_origin ) then
			continue // guy can't actually be hit from where we are
		end

		local dist_ratio = (outer_range_squared - test_range_squared) / (outer_range_squared - instant_kill_range_squared)

		local in_kill_range = test_range_squared < instant_kill_range_squared

		// door busting handled by projectile and only works on doors with hinges
		if self:FlingPushEntities(ent, view_pos, radial_origin, forward_view_angles, hitpos, in_kill_range) then
			continue
		end

		local ply = self:GetOwner()
		local delay = math.Clamp((1 - dist_ratio)*30, 1, 10)
		timer.Simple(math.Clamp(engine.TickInterval()*delay, 0, 0.1), function()
			if not IsValid(self) or not IsValid(ply) or not IsValid(ent) then return end

			local delayed_test_origin = ent:WorldSpaceCenter()
			local delayed_test_range_squared = view_pos:DistToSqr(delayed_test_origin)
			if delayed_test_range_squared > outer_range_squared then
				return
			end

			local trtest = util.TraceLine({
				start = radial_origin,
				endpos = delayed_test_origin,
				mask = MASK_SHOT,
				filter = ent,
				whitelist = true
			})

			if trtest.HitWorld then return end

			self:AirblastDamage(ent, test_range_squared < kill_range_squared, trtest.Entity == ent and trtest.HitPos or hitpos)
		end)
	end
end

function SWEP:FlingClientRagdoll(ent, start, dir)
	local ply = self:GetOwner()
	if not IsValid( ply ) then
		ply = self
	end

	if CLIENT_RAGDOLLS[ ent:GetClass() ] and bit.band( ent:GetSpawnFlags(), 16384 ) == 0 then // SF_RAGDOLLPROP_MOTIONDISABLED
		local flForceScale = Impulse( ent, 200 ) * math.Rand( 0.85, 1.15 )

		for i = 0, ent:GetPhysicsObjectCount() - 1 do
			local phys = ent:GetPhysicsObjectNum( i )

			if IsValid( phys ) then
				local ragTrace = util.TraceLine({
					start = start,
					endpos = phys:LocalToWorld( phys:GetMassCenter() ),
					mask = MASK_SHOT,
					ignoreworld = false,
					hitclientonly = true,
				})

				if ragTrace.Hit and ragTrace.Entity == ent then
					print(ragTrace.Fraction)
					
					phys:Wake()
					phys:EnableMotion( true )

					local vecForce = Vector()
					vecForce:Set( ( dir + ( ent:GetPos() - ply:GetPos() ) ):GetNormalized() )
					vecForce:Mul( flForceScale )
					vecForce:Mul( phys_pushscale:GetFloat() )

					phys:ApplyForceCenter( vecForce + vector_up * Impulse( ent, 60 ) )
				end
			end
		end
	end
end

function SWEP:FlingServerRagdoll(ent, start, dir)
	local ply = self:GetOwner()
	if not IsValid( ply ) then
		ply = self
	end

	local flForceScale = Impulse( ent, 200 ) * math.Rand( 0.85, 1.15 )
	for i = 0, ent:GetPhysicsObjectCount() - 1 do
		local phys = ent:GetPhysicsObjectNum( i )

		if IsValid( phys ) then
			local ragTrace = util.TraceLine({
				start = start,
				endpos = phys:LocalToWorld( phys:GetMassCenter() ),
				mask = MASK_SHOT,
				filter = {self, ply},
			})

			// push away each individual ragdoll phys segment that is visible from the shooter
			if ragTrace.Hit and ragTrace.Entity == ent then
				print(ragTrace.Fraction)
				
				phys:Wake()
				phys:EnableMotion( true )

				local vecForce = Vector()
				vecForce:Set( ( direction + ( ent:GetPos() - ply:GetPos() ) ):GetNormalized() )
				vecForce:Mul( flForceScale )
				vecForce:Mul( phys_pushscale:GetFloat() )

				phys:ApplyForceCenter( vecForce + vector_up*Impulse( ent, 60 ) )
			end
		end
	end
end

function SWEP:FlingPushEntities(ent, start, endpos, direction, hitpos, killrange)
	local PUSH_ENTITIES = {
		[CLASS_HACKED_ROLLERMINE] = true,
		[CLASS_FLARE] = true,
	}

	local ply = self:GetOwner()

	// set off phys cannisters
	if ent:GetClass() == "physics_cannister" then
		ent:Input("Activate")

		local phys = ent:GetPhysicsObject()
		if IsValid(phys) then
			phys:ApplyForceCenter( direction * Impulse( ent, math.random( 20, 40 ) ) + (start - endpos):GetNormalized() * Impulse( ent, 20 ) )
		end

		return true
	end

	// push away certain npcs
	if ent.Classify and PUSH_ENTITIES[ ent:Classify() ] and ent.GetPhysicsObject then
		local phys = ent:GetPhysicsObject()
		if IsValid( phys ) then
			ent:SetGroundEntity(nil)

			phys:Wake()
			phys:ApplyForceCenter( ( direction * Impulse( ent, 200 ) ) + (ent:GetPos() - ply:GetPos()):GetNormalized() * Impulse( ent, 200 ) + vector_up * Impulse( ent, 200 ) )
		end

		return true
	end

	// blow up rollermines that are too close and knock them off cars
	if ent:GetClass() == "npc_rollermine" then
		if IsValid( ent:GetInternalVariable("m_hVehicleStuckTo") ) then
			ent:Input("ConstraintBroken")

			local phys = ent:GetPhysicsObject()
			if IsValid( phys ) then
				ent:SetGroundEntity(nil)

				phys:Wake()
				phys:ApplyForceCenter( ( direction * Impulse( ent, 200 ) ) + (ent:GetPos() - ply:GetPos()):GetNormalized() * Impulse( ent, 200 ) + vector_up * Impulse( ent, 200 ) )
			end

			ParticleEffect("bo3_thundergun_hit", hitpos or ent:GetPos(), (hitpos - start):Angle() - pcf_ang_correction)
		elseif ent:GetPos():DistToSqr(start) < 180^2 then
			timer.Simple(0, function()
				if not IsValid( ent ) or not IsValid( ply ) then return end
				ent:Input("RespondToExplodeChirp")
			end)
		end
	end
end

function SWEP:AirblastDamage(ent, kill, hitpos)
	if CLIENT then return end

	if ent == self:GetFireTornado() then
		ent:SetVelocity(vector_up*200 + norm*400)
		return
	end

	local ply = self:GetOwner()
	if not IsValid(ply) then return end

	local norm = (ent:GetPos() - ply:GetPos()):GetNormalized()

	local force = (ent:GetUp()*math.random(12000,24000) + self:GetAimVector()*math.random(10000,20000)) + norm*math.random(20000,24000)
	if not (ent:IsNPC() or ent:IsPlayer() or ent:IsNextBot() or ent:IsVehicle() or ent:IsRagdoll()) then
		ent:SetGroundEntity(nil)
	end

	local damage = DamageInfo()
	damage:SetDamageType(DMG_MISSILEDEFENSE)
	damage:SetAttacker(self:GetOwner())
	damage:SetInflictor(self)
	damage:SetDamage(( kill and ( ( sv_true_damage and sv_true_damage:GetBool() or nzombies ) and ent:Health() + 666 or self:GetStat("Primary.Damage") ) ) or 75)
	damage:SetDamageForce(force)
	damage:SetDamagePosition(TFA.WonderWeapon.BodyTarget(ent, ply.GetShootPos and ply:GetShootPos() or ply:EyePos(), true, math.random(16) == 1))
	damage:SetReportedPosition(ply:GetShootPos())

	if nzombies and (ent.NZBossType or ent.IsMooBossZombie) then
		damage:SetDamage(math.max(1400, ent:GetMaxHealth() / 12))
	end

	if math.random(10) > 5 then
		sound.Play("TFA_BO3_THUNDERGUN.Impact", hitpos)
	end

	ent:TakeDamageInfo(damage)

	if ( ent:IsNPC() or ent:IsPlayer() or ent:IsNextBot() ) then
		local trace = {["Entity"] = ent, ["Hit"] = true, ["HitPos"] = hitpos or ent:WorldSpaceCenter()}
		self:SendHitMarker(self:GetOwner(), trace, damage)
	end

	if not kill and ent:IsPlayer() then
		ent:SetGroundEntity(nil)
		ent:SetLocalVelocity(ent:GetVelocity() + vector_up*80 + (norm*40))
		ent:SetDSP(32, false)
	end
end

function SWEP:InflictDamage(ent, ratio, pos, hitpos)
	local mydamage = (self:GetStatL("Primary.Damage")*ratio)

	if nzombies and nzRound and nzRound.GetZombieHealth and ent:IsValidZombie() then
		local health = nzRound:GetZombieHealth()

		mydamage = (health*ratio / 2) + 115
		if !(ent.NZBossType or ent.IsMooBossZombie) and ent.BO1BurnSlow and ent:WaterLevel() < 2 then
			ent:BO1BurnSlow(4*ratio)
		end
	end

	local damage = DamageInfo()
	damage:SetDamageType(nzombies and DMG_BURN or bit.bor(DMG_NEVERGIB, DMG_SLOWBURN))
	damage:SetAttacker(self:GetOwner())
	damage:SetInflictor(self)
	damage:SetDamage(mydamage*self:GetStatL("Primary.NumShots"))
	damage:SetDamagePosition(hitpos)
	damage:SetDamageForce((hitpos - pos):GetNormalized())

	if nzombies and (ent.NZBossType or ent.IsMooBossZombie) then
		damage:SetDamage(math.max((60*ratio), ent:GetMaxHealth() / 120))
	end

	local ply = self:GetOwner()
	if !nzombies and ent:WaterLevel() < 2 then
		ent:Ignite(4*ratio)
	end

	ent:TakeDamageInfo(damage)

	if (ent:IsNPC() or ent:IsPlayer() or ent:IsNextBot()) then
		local trace = {["Entity"] = ent, ["Hit"] = true, ["HitPos"] = hitpos}
		self:SendHitMarker(self:GetOwner(), trace, damage)
	end

	if ent:WaterLevel() > 1 then
		ent:Extinguish()
	end
end

function SWEP:OnDrop(...)
	self:StopSound("TFA_BO4_HELLFIRE.Loop")
	self:StopSound("TFA_BO4_HELLFIRE.CoolDown")
	//self.Glow:SetFloat("$emissiveblendstrength", 0)
	return BaseClass.OnDrop(self,...)
end

function SWEP:OwnerChanged(...)
	self:StopSound("TFA_BO4_HELLFIRE.Loop")
	self:StopSound("TFA_BO4_HELLFIRE.CoolDown")
	//self.Glow:SetFloat("$emissiveblendstrength", 0)
	return BaseClass.OwnerChanged(self,...)
end

function SWEP:Holster(...)
	self:StopSound("TFA_BO4_HELLFIRE.Loop")
	self:StopSound("TFA_BO4_HELLFIRE.CoolDown")
	self:StopSoundNet("TFA_BO4_HELLFIRE.Loop")
	self:StopSoundNet("TFA_BO4_HELLFIRE.CoolDown")
	//self.Glow:SetFloat("$emissiveblendstrength", 0)
	return BaseClass.Holster(self,...)
end

function SWEP:ShootBulletInformation()
end

local crosshair_flamethrower = Material("vgui/overlay/hud_flamethrower_reticle.png", "smooth unlitgeneric")
local CMIX_MULT = 1
local c1t = {}
local c2t = {}

local function ColorMix(c1, c2, fac, t)
	c1 = c1 or color_white
	c2 = c2 or color_white
	c1t.r = c1.r
	c1t.g = c1.g
	c1t.b = c1.b
	c1t.a = c1.a
	c2t.r = c2.r
	c2t.g = c2.g
	c2t.b = c2.b
	c2t.a = c2.a

	for k, v in pairs(c1t) do
		if t == CMIX_MULT then
			c1t[k] = Lerp(fac, v, (c1t[k] / 255 * c2t[k] / 255) * 255)
		else
			c1t[k] = Lerp(fac, v, c2t[k])
		end
	end

	return Color(c1t.r, c1t.g, c1t.b, c1t.a)
end

local crosshair_cvar = GetConVar("cl_tfa_bo3ww_crosshair")
local sv_tfa_fixed_crosshair = GetConVar("sv_tfa_fixed_crosshair")
local crossr_cvar = GetConVar("cl_tfa_hud_crosshair_color_r")
local crossg_cvar = GetConVar("cl_tfa_hud_crosshair_color_g")
local crossb_cvar = GetConVar("cl_tfa_hud_crosshair_color_b")
local crosscol = Color(255, 255, 255, 255)

function SWEP:DrawHUDBackground()
	if not crosshair_cvar:GetBool() then return end
	local self2 = self:GetTable()
	local x, y
	
	local ply = LocalPlayer()
	if not ply:IsValid() or self:GetOwner() ~= ply then return false end

	if not ply.interpposx then
		ply.interpposx = ScrW() / 2
	end

	if not ply.interpposy then
		ply.interpposy = ScrH() / 2
	end

	local tr = {}
	tr.start = ply:GetShootPos()
	tr.endpos = tr.start + ply:GetAimVector() * 0x7FFF
	tr.filter = ply
	tr.mask = MASK_NPCSOLID
	local traceres = util.TraceLine(tr)
	local targent = traceres.Entity

	if self:GetOwner():ShouldDrawLocalPlayer() and not ply:GetNW2Bool("ThirtOTS", false) then
		local coords = traceres.HitPos:ToScreen()
		coords.x = math.Clamp(coords.x, 0, ScrW())
		coords.y = math.Clamp(coords.y, 0, ScrH())
		ply.interpposx = math.Approach(ply.interpposx, coords.x, (ply.interpposx - coords.x) * RealFrameTime() * 7.5)
		ply.interpposy = math.Approach(ply.interpposy, coords.y, (ply.interpposy - coords.y) * RealFrameTime() * 7.5)
		x, y = ply.interpposx, ply.interpposy
		-- Center of screen
	elseif sv_tfa_fixed_crosshair:GetBool() then
		x, y = ScrW() / 2, ScrH() / 2
	else
		tr.endpos = tr.start + self:GetAimAngle():Forward() * 0x7FFF
		local pos = util.TraceLine(tr).HitPos:ToScreen()
		x, y = pos.x, pos.y
	end

	local stat = self2.GetStatus(self)
	self2.clrelp = self2.clrelp or 0
	self2.clrelp = math.Approach(
		self2.clrelp,
		TFA.Enum.ReloadStatus[stat] and 0 or 1,
		((TFA.Enum.ReloadStatus[stat] and 0 or 1) - self2.clrelp) * RealFrameTime() * 7)

	local crossa = 255 * math.pow(math.min(1 - (((self2.IronSightsProgressUnpredicted2 or self:GetIronSightsProgress()) and
		not self2.GetStatL(self, "DrawCrosshairIronSights")) and (self2.IronSightsProgressUnpredicted2 or self:GetIronSightsProgress()) or 0),
		1 - self:GetSprintProgress(),
		1 - self:GetInspectingProgress(),
		self2.clrelp),
	2)

	teamcol = self2.GetTeamColor(self, targent)
	crossr = crossr_cvar:GetFloat()
	crossg = crossg_cvar:GetFloat()
	crossb = crossb_cvar:GetFloat()
	crosscol.r = crossr
	crosscol.g = crossg
	crosscol.b = crossb
	crosscol.a = crossa
	crosscol = ColorMix(crosscol, teamcol, 1, CMIX_MULT)
	crossr = crosscol.r
	crossg = crosscol.g
	crossb = crosscol.b
	crossa = crosscol.a

	surface.SetDrawColor(crossr, crossg, crossb, crossa)
	surface.SetMaterial(crosshair_flamethrower)

	if ply:ShouldDrawLocalPlayer() or ply:GetNW2Bool("ThirtOTS", false) then
		surface.DrawTexturedRect(x - 24, y  - 24, 48, 48)
	else
		surface.DrawTexturedRect(ScrW() / 2 - 24, ScrH() / 2 - 24, 48, 48)
	end
end
