local nzombies = engine.ActiveGamemode() == "nzombies"
local dlight_cvar = GetConVar("cl_tfa_fx_wonderweapon_dlights")

SWEP.Base = "tfa_gun_base"
SWEP.Category = "TFA Wonder Weapons"
SWEP.SubCategory = "Black Ops 3"
SWEP.Spawnable = TFA_BASE_VERSION and TFA_BASE_VERSION >= 4.76
SWEP.AdminSpawnable = true
SWEP.UseHands = true
SWEP.Type_Displayed = "#tfa.weapontype.wonderweapon"
SWEP.Author = "FlamingFox"
SWEP.Slot = 3
SWEP.PrintName = "KT-4"
SWEP.DrawCrosshair = true
SWEP.DrawCrosshairIS = false
SWEP.WWCrosshairEnabled = true

--[Model]--
SWEP.ViewModel			= "models/weapons/tfa_bo3/mirg2000/c_mirg2000.mdl"
SWEP.ViewModelFOV = 65
SWEP.WorldModel			= "models/weapons/tfa_bo3/mirg2000/w_mirg2000.mdl"
SWEP.HoldType = "ar2"
SWEP.CameraAttachmentOffsets = {}
SWEP.CameraAttachmentScale = 1
SWEP.MuzzleAttachment = "1"
SWEP.VMPos = Vector(0, 0, 0)
SWEP.VMAng = Vector(0, 0, 0)
SWEP.VMPos_Additive = true

SWEP.Offset = { --Procedural world model animation, defaulted for CS:S purposes.
        Pos = {
        Up = -0.5,
        Right = 1.2,
        Forward = 4,
        },
        Ang = {
		Up = 180,
        Right = 195,
        Forward = 0
        },
		Scale = 1
}

--[Gun Related]--
SWEP.Primary.Sound = "TFA_BO3_MIRG.Shoot"
SWEP.Primary.Ammo = "AR2AltFire"
SWEP.Primary.Automatic = true
SWEP.Primary.RPM = 220
SWEP.Primary.Damage = nzombies and 1600 or 90
SWEP.Primary.NumShots = 1
SWEP.Primary.Knockback = 10
SWEP.Primary.ClipSize = 6
SWEP.Primary.DefaultClip = SWEP.Primary.ClipSize
SWEP.Primary.Delay = 0.35
SWEP.MuzzleFlashEffect	= "tfa_bo3_muzzleflash_mirg2k"
SWEP.DisableChambering = true
SWEP.FiresUnderwater = false
SWEP.MuzzleFlashEnabled = true

--[Firemode]--
SWEP.Primary.BurstDelay = nil
SWEP.DisableBurstFire = true
SWEP.SelectiveFire = false
SWEP.OnlyBurstFire = false
SWEP.BurstFireCount = nil

--[LowAmmo]--
SWEP.FireSoundAffectedByClipSize = false
SWEP.LowAmmoSoundThreshold = 0.33 --0.33
SWEP.LowAmmoSound = nil
SWEP.LastAmmoSound = nil

--[Range]--
SWEP.Primary.Range = -1
SWEP.Primary.RangeFalloff = -1
SWEP.Primary.DisplayFalloff = false
SWEP.DisplayFalloff = false

--[Recoil]--
SWEP.ViewModelPunchPitchMultiplier = 0.5 -- Default value is 0.5
SWEP.ViewModelPunchPitchMultiplier_IronSights = 0.09 -- Default value is 0.09

SWEP.ViewModelPunch_MaxVertialOffset				= 3 -- Default value is 3
SWEP.ViewModelPunch_MaxVertialOffset_IronSights		= 1.95 -- Default value is 1.95
SWEP.ViewModelPunch_VertialMultiplier				= 1 -- Default value is 1
SWEP.ViewModelPunch_VertialMultiplier_IronSights	= 0.25 -- Default value is 0.25

SWEP.ViewModelPunchYawMultiplier = 0.6 -- Default value is 0.6
SWEP.ViewModelPunchYawMultiplier_IronSights = 0.25 -- Default value is 0.25

--[Spread Related]--
SWEP.Primary.Spread		  = .04
SWEP.Primary.IronAccuracy = .001
SWEP.IronRecoilMultiplier = 0.6
SWEP.CrouchAccuracyMultiplier = 0.85

SWEP.Primary.KickUp				= 0.6
SWEP.Primary.KickDown			= 0.6
SWEP.Primary.KickHorizontal		= 0.2
SWEP.Primary.StaticRecoilFactor	= 0.4

SWEP.Primary.SpreadMultiplierMax = 2
SWEP.Primary.SpreadIncrement = 2
SWEP.Primary.SpreadRecovery = 4

--[Iron Sights]--
SWEP.IronBobMult 	 = 0.065
SWEP.IronBobMultWalk = 0.065
SWEP.data = {}
SWEP.data.ironsights = 1
SWEP.Secondary.IronFOV = 70
SWEP.IronSightsPos = Vector(-5.63, -4.5, -0.92)
SWEP.IronSightsAng = Vector(0, 0, 0)
SWEP.IronSightTime = 0.35

--[Shells]--
SWEP.LuaShellEject = false
SWEP.LuaShellEffect = "ShellEject"
SWEP.LuaShellModel = "models/weapons/tfa_bo3/mirg2000/goop_tube.mdl"
SWEP.LuaShellScale = 1
SWEP.LuaShellEjectDelay = 0
SWEP.ShellAttachment = 2
SWEP.EjectionSmokeEnabled = false

--[Projectile]--
SWEP.Primary.Projectile         = "bo3_ww_mirg" -- Entity to shoot
SWEP.Primary.ProjectileVelocity = 3000 -- Entity to shoot's velocity
SWEP.Primary.ProjectileModel    = "models/dav0r/hoverball.mdl" -- Entity to shoot's model

--[Misc]--
SWEP.AmmoTypeStrings = {ar2altfire = "#tfa.ammo.bo3ww.mirg"}
SWEP.InspectPos = Vector(10, -5, -2)
SWEP.InspectAng = Vector(24, 42, 16)
SWEP.MoveSpeed = 0.925
SWEP.IronSightsMoveSpeed  = SWEP.MoveSpeed * 0.8
SWEP.SafetyPos = Vector(1, -2, -0.5)
SWEP.SafetyAng = Vector(-20, 35, -25)
SWEP.SmokeParticle = ""

--[NZombies]--
SWEP.NZPaPName = "Masamune"
SWEP.NZWonderWeapon = true
SWEP.Primary.MaxAmmo = 36

function SWEP:NZMaxAmmo()
	if CLIENT then return end
	self:GetOwner():SetAmmo( self.Primary_TFA.MaxAmmo, self:GetPrimaryAmmoType() or self.Primary_TFA.Ammo )
	self:SetClip1( self.Primary_TFA.ClipSize )
end

SWEP.Ispackapunched = false
SWEP.MuzzleFlashEffectPAP	= "tfa_bo3_muzzleflash_mirg2k_pap"
SWEP.MoveSpeedPAP = 0.95

function SWEP:OnPaP()
self.Ispackapunched = true

self.Primary_TFA.Damage = 2400

self.MuzzleFlashEffect	= "tfa_bo3_muzzleflash_mirg2k_pap"

self.MoveSpeed = 0.95

self:ClearStatCache()
return true
end

--[Tables]--
SWEP.StatusLengthOverride = {
    [ACT_VM_RELOAD] = 40 / 30,
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
[ACT_VM_DRAW] = {
{ ["time"] = 0, ["type"] = "sound", ["value"] = Sound("weapon_bo3_cloth.med") },
{ ["time"] = 5 / 30, ["type"] = "sound", ["value"] = Sound("weapon_bo3_gear.rattle") },
},
[ACT_VM_HOLSTER] = {
{ ["time"] = 0, ["type"] = "sound", ["value"] = Sound("TFA_BO3_MIRG.Stop") },
{ ["time"] = 2 / 30, ["type"] = "sound", ["value"] = Sound("weapon_bo3_cloth.med") },
{ ["time"] = 5 / 30, ["type"] = "sound", ["value"] = Sound("weapon_bo3_gear.rattle") },
},
[ACT_VM_IDLE] = {
{ ["time"] = 0, ["type"] = "sound", ["value"] = Sound("TFA_BO3_MIRG.Idle") },
},
[ACT_VM_DRAW_DEPLOYED] = {
{ ["time"] = 10 / 30, ["type"] = "sound", ["value"] = Sound("TFA_BO3_MIRG.Prime") },
{ ["time"] = 10 / 30, ["type"] = "sound", ["value"] = Sound("TFA_BO3_MIRG.Start") },
{ ["time"] = 30 / 30, ["type"] = "sound", ["value"] = Sound("TFA_BO3_MIRG.Rechamber") },
{ ["time"] = 40 / 30, ["type"] = "lua", value = function(self)
	self:DaSmokey()

	if SERVER then
		local fx = EffectData()
		fx:SetEntity(self)
		fx:SetFlags(self.Ispackapunched and 1 or 0)

		local filter = RecipientFilter()
		filter:AddPVS(self:GetOwner():GetShootPos())
		filter:RemovePlayer(self:GetOwner())
		if not self:IsFirstPerson() then
			filter:AddPlayer(self:GetOwner())
		end

		util.Effect("tfa_bo3_mirg2k_3p", fx, nil, filter)
	end
end, client = true, server = true},
},
[ACT_VM_RELOAD] = {
{ ["time"] = 0, ["type"] = "sound", ["value"] = Sound("TFA_BO3_MIRG.Stop") },
{ ["time"] = 5 / 30, ["type"] = "lua", value = function(self) self:SetMainGlow(false) end, client = true, server = true},
{ ["time"] = 10 / 30, ["type"] = "sound", ["value"] = Sound("TFA_BO3_MIRG.Magout") },
{ ["time"] = 10 / 30, ["type"] = "lua", value = function(self) self:EventShell() end, client = true, server = true},
{ ["time"] = 10 / 30, ["type"] = "lua", value = function(self) self.Bodygroups_W = {[1] = 1} end, client = true, server = true},
{ ["time"] = 35 / 30, ["type"] = "sound", ["value"] = Sound("TFA_BO3_MIRG.Magin") },
{ ["time"] = 35 / 30, ["type"] = "lua", value = function(self) self.Bodygroups_W = {[1] = 0} end, client = true, server = true},
{ ["time"] = 35 / 30, ["type"] = "lua", value = function(self) self:SetMainGlow(true) end, client = true, server = true},
{ ["time"] = 65 / 30, ["type"] = "sound", ["value"] = Sound("TFA_BO3_MIRG.Rechamber") },
{ ["time"] = 65 / 30, ["type"] = "sound", ["value"] = Sound("TFA_BO3_MIRG.Start") },
{ ["time"] = 75 / 30, ["type"] = "lua", value = function(self)
	self:DaSmokey()

	if SERVER then
		local fx = EffectData()
		fx:SetEntity(self)
		fx:SetFlags(self.Ispackapunched and 1 or 0)

		local filter = RecipientFilter()
		filter:AddPVS(self:GetOwner():GetShootPos())
		filter:RemovePlayer(self:GetOwner())
		if not self:IsFirstPerson() then
			filter:AddPlayer(self:GetOwner())
		end

		util.Effect("tfa_bo3_mirg2k_3p", fx, nil, filter)
	end
end, client = true, server = true},
},
}

--[Shit]--
SWEP.AllowViewAttachment = true --Allow the view to sway based on weapon attachment while reloading or drawing, IF THE CLIENT HAS IT ENABLED IN THEIR CONVARS.
SWEP.Sprint_Mode = TFA.Enum.LOCOMOTION_ANI -- ANI = mdl, HYBRID = ani + lua, Lua = lua only
SWEP.Sights_Mode = TFA.Enum.LOCOMOTION_HYBRID -- ANI = mdl, HYBRID = lua but continue idle, Lua = stop mdl animation
SWEP.Idle_Mode = TFA.Enum.IDLE_BOTH --TFA.Enum.IDLE_DISABLED = no idle, TFA.Enum.IDLE_LUA = lua idle, TFA.Enum.IDLE_ANI = mdl idle, TFA.Enum.IDLE_BOTH = TFA.Enum.IDLE_ANI + TFA.Enum.IDLE_LUA
SWEP.Idle_Blend = 0.25 --Start an idle this far early into the end of a transition
SWEP.Idle_Smooth = 0.05 --Start an idle this far early into the end of another animation
SWEP.SprintBobMult = 0

SWEP.Attachments = {
[1] = {atts = {"bo3_packapunch"}, order = 1, hidden = engine.ActiveGamemode() == "nzombies"},
}

SWEP.Bodygroups_W = {
	[1] = 0
}

SWEP.ChargeStages = 3
SWEP.ChargeStageTime = .7

SWEP.Lights = {
	[0] = Material("models/weapons/tfa_bo3/mirg2000/mtl_wpn_t7_zmb_dlc2_mirg2000_glow3.vmt"),
	[1] = Material("models/weapons/tfa_bo3/mirg2000/mtl_wpn_t7_zmb_dlc2_mirg2000_glow2.vmt"),
	[2] = Material("models/weapons/tfa_bo3/mirg2000/mtl_wpn_t7_zmb_dlc2_mirg2000_glow1.vmt"),
}

SWEP.Glow = Material("models/weapons/tfa_bo3/mirg2000/mtl_wpn_t7_zmb_dlc2_mirg2000_glo.vmt")

SWEP.FP_FX = {}
SWEP.TP_FX = {}

SWEP.StatCache_Blacklist = {
	["Bodygroups_W"] = true,
}

--[Coding]--
DEFINE_BASECLASS( SWEP.Base )

local cvar_papcamoww = GetConVar("nz_papcamo_ww")

function SWEP:DaSmokey()
	if self:VMIV() and IsFirstTimePredicted() then
		ParticleEffectAttach(self.Ispackapunched and "bo3_mirg2k_vm_smoke_2" or "bo3_mirg2k_vm_smoke", PATTACH_POINT_FOLLOW, self.OwnerViewModel, 8)
		ParticleEffectAttach(self.Ispackapunched and "bo3_mirg2k_vm_smoke_2" or "bo3_mirg2k_vm_smoke", PATTACH_POINT_FOLLOW, self.OwnerViewModel, 9)
		ParticleEffectAttach(self.Ispackapunched and "bo3_mirg2k_vm_smoke_2" or "bo3_mirg2k_vm_smoke", PATTACH_POINT_FOLLOW, self.OwnerViewModel, 10)
	end
end

function SWEP:SetupDataTables()
	BaseClass.SetupDataTables(self)

	self:NetworkVarTFA("Int", "GlowLevel")
	self:NetworkVarTFA("Float", "BeginChargeTime")
	self:NetworkVarTFA("Float", "TotalChargeTime")
	self:NetworkVarTFA("Bool", "HasEmitSound")
	self:NetworkVarTFA("Bool", "MainGlow")

	self:SetGlowLevel(0)
	self:SetMainGlow(true)
end

function SWEP:PreDrawViewModel(vm, ...)
	BaseClass.PreDrawViewModel(self, vm, ...)

	if self.Ispackapunched then
		self.Skin = 1
		self:SetSkin(1)
	else
		self.Skin = 0
		self:SetSkin(0)
	end

	if self.Ispackapunched then
		if !cvar_papcamoww or (cvar_papcamoww and cvar_papcamoww:GetBool()) then
			vm:SetSubMaterial(3, self.nzPaPCamo)
			vm:SetSubMaterial(4, self.nzPaPCamo)
			vm:SetSubMaterial(7, self.nzPaPCamo)
			vm:SetSubMaterial(12, self.nzPaPCamo)
		end
	else
		vm:SetSubMaterial(3, nil)
		vm:SetSubMaterial(4, nil)
		vm:SetSubMaterial(7, nil)
		vm:SetSubMaterial(12, nil)
	end

	if IsValid(self.OwnerViewModel) then
		for i = 1, 3 do
			self:AddDrawCallViewModelParticle("bo3_mirg2k_charged", PATTACH_POINT_FOLLOW, 6 - i, TFA.Enum.ReadyStatus[self:GetStatus()] and self:GetGlowLevel() >= i)
		end

		if self:GetMainGlow() and dlight_cvar:GetBool() and DynamicLight then
			self.DLight = self.DLight or DynamicLight(self.OwnerViewModel:EntIndex(), false)
			if self.DLight then
				local attpos = self.OwnerViewModel:GetAttachment(6)
				local upgraded = self.Ispackapunched

				if (attpos and attpos.Pos) then
					self.DLight.pos = attpos.Pos
					self.DLight.dir = attpos.Ang:Forward()
					self.DLight.r = 0
					self.DLight.g = 255
					self.DLight.b = upgraded and 255 or 0
					self.DLight.decay = 1000
					self.DLight.brightness = 1
					self.DLight.size = 32
					self.DLight.dietime = CurTime() + 1
				end
			end
		end
	end
end

function SWEP:DrawWorldModel(...)
	BaseClass.DrawWorldModel(self, ...)

	if self.Bodygroups_W and self.Bodygroups_W[1] ~= 0 and not TFA.Enum.ReloadStatus[self:GetStatus()] then
		self.Bodygroups_W[1] = 0
	end

	if self.Ispackapunched then
		self.Skin = 1
		self:SetSkin(1)
	elseif self.Skin == 1 then
		self.Skin = 0
		self:SetSkin(0)
	end

	local status = self:GetStatus()

	for i = 1, 3 do
		self:AddDrawCallWorldModelParticle("bo3_mirg2k_charged_3p", PATTACH_POINT_FOLLOW, 6 - i, TFA.Enum.ReadyStatus[status] and (not self:IsCarriedByLocalPlayer() or not self:IsFirstPerson()) and self:GetGlowLevel() >= i)
	end

	if self:GetMainGlow() and dlight_cvar:GetInt() == 1 and DynamicLight then
		self.DLight = self.DLight or DynamicLight(self:EntIndex(), false)
		if self.DLight then
			local attpos = self:GetAttachment(6)

			if (attpos and attpos.Pos) then
				self.DLight.pos = attpos.Pos
				self.DLight.dir = attpos.Ang:Forward()
				self.DLight.r = 0
				self.DLight.g = 200
				self.DLight.b = 0
				self.DLight.decay = 2000
				self.DLight.brightness = 1
				self.DLight.size = 64
				self.DLight.dietime = CurTime() + 0.5
			end
		end
	end
end

-- thank you tf2 source code
function SWEP:PrimaryAttack()
	local ply = self:GetOwner()
	if not IsValid(ply) then return end
	if not self:CanPrimaryAttack() then return end

	if not ply:IsPlayer() then
		return BaseClass.PrimaryAttack(self)
	end

	if ply.KeyDown and ply:KeyDown(IN_RELOAD) then return end

	if self:GetBeginChargeTime() <= 0 then
		self:SetBeginChargeTime(CurTime())

		self:EmitSoundNet("TFA_BO3_MIRG.Charge2")

		if not self:GetHasEmitSound() then
			self:EmitGunfireSound("TFA_BO3_MIRG.Charge1")
			self:SetHasEmitSound(true)
		end

		self:SetGlowLevel(self:GetGlowLevel() + 1)
		if self:GetGlowLevel() >= self.ChargeStages then
			self:DaSmokey()

			if SERVER then
				local fx = EffectData()
				fx:SetEntity(self)
				fx:SetFlags(self.Ispackapunched and 1 or 0)

				local filter = RecipientFilter()
				filter:AddPVS(ply:GetShootPos())
				filter:RemovePlayer(ply)
				if not self:IsFirstPerson() then
					filter:AddPlayer(ply)
				end

				util.Effect("tfa_bo3_mirg2k_3p", fx, nil, filter)
			end
		end
	else
		if self:GetGlowLevel() < math.min(self:Clip1(), self.ChargeStages) then
			self:SetTotalChargeTime(CurTime() - self:GetBeginChargeTime())

			if self:GetTotalChargeTime() >= self.ChargeStageTime then
				self:SetBeginChargeTime(0)
			end
		end

		local progress = self:GetBeginChargeTime() + self.ChargeStageTime
		progress = 1 - math.Clamp((progress - CurTime()) / self.ChargeStageTime, 0, 1)

		if progress >= 0.2 and progress <= 0.2 + engine.TickInterval() then //hehehe
			if IsFirstTimePredicted() then self:EmitSoundNet("TFA_BO3_MIRG.Charge3") end
		end
	end
end

function SWEP:LaunchGrenade()
	if self:GetGlowLevel() > 0 then
		self:TakePrimaryAmmo(self:GetGlowLevel() - 1)
	end

	self:SetHasEmitSound(false)

	if self:GetGlowLevel() == 1 then
		self:StopSoundNet("TFA_BO3_MIRG.Charge1")
		self:StopSoundNet("TFA_BO3_MIRG.Charge2")
		self:StopSoundNet("TFA_BO3_MIRG.Charge3")
	end

	return BaseClass.PrimaryAttack(self)
end

function SWEP:ResetLock()
	if self:GetBeginChargeTime() == 0 then
		return
	end

	self:SetGlowLevel(0)
	self:SetBeginChargeTime(0)
	self:SetHasEmitSound(false)
end

function SWEP:PostPrimaryAttack()
	self:EmitGunfireSound("TFA_BO3_MIRG.Shoot.Charge."..self:GetGlowLevel())

	local ply = self:GetOwner()
	if SERVER and IsValid(ply) and ply:IsPlayer() and !TFA.WonderWeapon.HasAchievement( ply, "BO3_KT4_Infection" ) then
		TFA.WonderWeapon.ResetAchievement( ply, "BO3_KT4_Infection" )
	end
end

function SWEP:Think2(...)
	if SERVER then
		if not self:GetMainGlow() and not TFA.Enum.ReloadStatus[self:GetStatus()] then
			self:SetMainGlow(true)
		end
	end

	local ply = self:GetOwner()
	if ply:IsPlayer() then
		if TFA.Enum.ReadyStatus[self:GetStatus()] and not self:GetSprinting() then
			if self:GetBeginChargeTime() > 0 and not ply:KeyDown(IN_ATTACK) then
				self:LaunchGrenade()
				self:ResetLock()
			end
		else
			self:ResetLock()
		end
	end

	return BaseClass.Think2(self, ...)
end

function SWEP:Reload(...)
	local ply = self:GetOwner()
	if ply:IsPlayer() then
		if self:GetGlowLevel() > 0 or ply:KeyDown(IN_ATTACK) then
			self:ResetLock()

			self:SetStatus(TFA.GetStatus("idle"))
			self:SetNextPrimaryFire(CurTime() + self.ChargeStageTime)
			return
		end
	end

	BaseClass.Reload(self, ...) 
end

function SWEP:PreSpawnProjectile(ent)
	ent:SetCharge(self:GetGlowLevel())
	ent:SetUpgraded(self.Ispackapunched)
end

function SWEP:OnDrop(...)
	self:StopSound("TFA_BO3_MIRG.Idle")
	self:StopSoundNet("TFA_BO3_MIRG.Idle")
	return BaseClass.OnDrop(self,...)
end

function SWEP:OwnerChanged(...)
	self:StopSound("TFA_BO3_MIRG.Idle")
	self:StopSoundNet("TFA_BO3_MIRG.Idle")
	return BaseClass.OwnerChanged(self,...)
end

function SWEP:Holster( ... )
	self:StopSound("TFA_BO3_MIRG.Idle")
	self:StopSoundNet("TFA_BO3_MIRG.Idle")
	return BaseClass.Holster(self,...)
end

local crosshair_chemgun = Material("vgui/overlay/chemicalgelgun_reticle.png", "smooth unlitgeneric")
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
	surface.SetMaterial(crosshair_chemgun)

	if ply:ShouldDrawLocalPlayer() or ply:GetNW2Bool("ThirtOTS", false) then
		surface.DrawTexturedRect(x - 114, y  - 114, 228, 228)
	else
		surface.DrawTexturedRect(ScrW() / 2 - 114, ScrH() / 2 - 114, 228, 228)
	end
end