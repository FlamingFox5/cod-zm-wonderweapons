local nzombies = engine.ActiveGamemode() == "nzombies"
local sv_shrink_all = GetConVar("sv_tfa_bo3ww_shrinkray_shrink_all")

SWEP.Base = "tfa_bash_base"
SWEP.Category = "TFA Wonder Weapons"
SWEP.SubCategory = "Black Ops 3"
SWEP.Spawnable = TFA_BASE_VERSION and TFA_BASE_VERSION >= 4.76
SWEP.AdminSpawnable = true
SWEP.UseHands = true
SWEP.Type_Displayed = "#tfa.weapontype.wonderweapon"
SWEP.Author = "FlamingFox"
SWEP.Slot = 2
SWEP.PrintName = "Ull's Arrow"
SWEP.DrawCrosshair = true
SWEP.DrawCrosshairIS = false

--[Model]--
SWEP.ViewModel			= "models/weapons/tfa_bo3/staff_ice/c_staff_ice.mdl"
SWEP.ViewModelCombined	= "models/weapons/tfa_bo3/staff_ice/c_staff_ice.mdl"
SWEP.ViewModelFOV = 65
SWEP.WorldModel			= "models/weapons/tfa_bo3/staff_ice/w_staff_ice.mdl"
SWEP.WorldModelCombined	= "models/weapons/tfa_bo3/staff_ice/w_staff_ice.mdl"
SWEP.HoldType = "crossbow"
SWEP.CameraAttachmentOffsets = {}
SWEP.CameraAttachmentScale = 1
SWEP.MuzzleAttachment = 1
SWEP.MuzzleAttachmentSilenced = 1
SWEP.VMPos = Vector(0, -6, -1.5)
SWEP.VMAng = Vector(0, 0, 0)
SWEP.VMPos_Additive = true

SWEP.Offset = { --Procedural world model animation, defaulted for CS:S purposes.
        Pos = {
        Up = -2,
        Right = 1.5,
        Forward = 4.5,
        },
        Ang = {
		Up = 170,
        Right = 190,
        Forward = 0
        },
		Scale = 1
}

--[Gun Related]--
SWEP.Primary.Sound = "TFA_BO3_STAFF_ICE.Shoot"
SWEP.Primary.SilencedSound = "TFA_BO3_STAFF_REV.Shoot"
SWEP.Primary.Ammo = "CombineCannon"
SWEP.Primary.Automatic = false
SWEP.Primary.RPM = 360
SWEP.Primary.RPM_Wave = 120
SWEP.Primary.RPM_Semi = nil
SWEP.Primary.RPM_Burst = nil
SWEP.Primary.Damage = nzombies and 1150 or 2500
SWEP.Primary.Knockback = 5
SWEP.Primary.NumShots = 6
SWEP.Primary.AmmoConsumption = 1
SWEP.Primary.ClipSize = 9
SWEP.Primary.DefaultClip = SWEP.Primary.ClipSize
SWEP.Primary.DryFireDelay = 0.5
SWEP.MuzzleFlashEffect	= "tfa_bo3_muzzleflash_icestaff"
SWEP.MuzzleFlashEffectSilenced = "tfa_bo3_muzzleflash_revivestaff"
SWEP.DisableChambering = true
SWEP.FiresUnderwater = true

--[Bash]--
SWEP.Secondary.CanBash = true
SWEP.Secondary.BashDamage = nzombies and 1200 or 15
SWEP.Secondary.BashSound = "TFA_BO3_STAFFS.Melee"
SWEP.Secondary.BashHitSound = "TFA_BO3_STAFFS.MeleeHit"
SWEP.Secondary.BashHitSound_Flesh = "TFA_BO3_STAFFS.MeleeHitFlesh"
SWEP.Secondary.BashLength = 55
SWEP.Secondary.BashDelay = 0.2
SWEP.Secondary.BashEnd = 0.7
SWEP.Secondary.BashDamageType = DMG_SLASH
SWEP.Secondary.BashInterrupt = false

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
SWEP.ViewModelPunchPitchMultiplier = 0.3 -- Default value is 0.5
SWEP.ViewModelPunchPitchMultiplier_IronSights = 0.09 -- Default value is 0.09

SWEP.ViewModelPunch_MaxVertialOffset				= 1.5 -- Default value is 3
SWEP.ViewModelPunch_MaxVertialOffset_IronSights		= 1 -- Default value is 1.95
SWEP.ViewModelPunch_VertialMultiplier				= 0.5 -- Default value is 1
SWEP.ViewModelPunch_VertialMultiplier_IronSights	= 0.15 -- Default value is 0.25

SWEP.ViewModelPunchYawMultiplier = 0.3 -- Default value is 0.6
SWEP.ViewModelPunchYawMultiplier_IronSights = 0.1 -- Default value is 0.25

--[Spread Related]--
SWEP.Primary.Spread		  = .1
SWEP.Primary.IronAccuracy = .1
SWEP.IronRecoilMultiplier = 0.6
SWEP.CrouchAccuracyMultiplier = 0.85

SWEP.Primary.KickUp				= 0.5
SWEP.Primary.KickDown			= 0.3
SWEP.Primary.KickHorizontal		= 0.25
SWEP.Primary.StaticRecoilFactor	= 0.45

SWEP.Primary.SpreadMultiplierMax = 2
SWEP.Primary.SpreadIncrement = 2
SWEP.Primary.SpreadRecovery = 4

--[Iron Sights]--
SWEP.IronBobMult 	 = 0.065
SWEP.IronBobMultWalk = 0.065
SWEP.data = {}
SWEP.data.ironsights = 0
SWEP.Secondary.IronFOV = 70
SWEP.IronSightsPos = Vector(-4, -4, 0.8)
SWEP.IronSightsAng = Vector(0, -1.2, 0)
SWEP.IronSightTime = 0.3

--[Shells]--
SWEP.LuaShellEject = false
SWEP.LuaShellEffect = "ShellEject"
SWEP.LuaShellModel = nil
SWEP.LuaShellScale = 1
SWEP.LuaShellEjectDelay = 0
SWEP.ShellAttachment = "0"
SWEP.EjectionSmokeEnabled = false

--[Projectile]--
SWEP.Primary.Projectile         = "bo3_ww_icestaff" -- Entity to shoot
SWEP.Primary.ProjectileVelocity = 4000 -- Entity to shoot's velocity
SWEP.Primary.ProjectileModel    = "models/dav0r/hoverball.mdl" -- Entity to shoot's model

--[Misc]--
SWEP.AmmoTypeStrings = {combinecannon = "Gem"}
SWEP.InspectPos = Vector(0, -2, -3)
SWEP.InspectAng = Vector(15, 0, 0)
SWEP.InspectPos_WAVE = Vector(10, -5, -2)
SWEP.InspectAng_WAVE = Vector(24, 42, 16)
SWEP.MoveSpeed = 0.95
SWEP.IronSightsMoveSpeed = SWEP.MoveSpeed * 0.8
SWEP.SafetyPos = Vector(0, 0, 1)
SWEP.SafetyAng = Vector(-15, 0, 0)
SWEP.SmokeParticle = ""

--[NZombies]--
SWEP.NZPaPName = "Ull's Arrow"
SWEP.NZWonderWeapon = true
SWEP.Primary.MaxAmmo = 90
SWEP.Secondary.MaxAmmo = 3
SWEP.NZHudIcon = Material("vgui/icon/uie_t5hud_icon_grenade_launcher.png", "unlitgeneric smooth")
SWEP.NZHudIcon_t7 = Material("vgui/icon/uie_t7_zm_hud_ammo_icon_wavegun_active.png", "unlitgeneric smooth")
SWEP.NZHudIcon_t7zod = Material("vgui/icon/uie_t7_zm_hud_ammo_icon_wavegun_active_bw.png", "unlitgeneric smooth")
SWEP.NZHudIcon_t7tomb = Material("vgui/icon/uie_t7_zm_hud_ammo_icon_wavegun_active_bw.png", "unlitgeneric smooth")

function SWEP:NZMaxAmmo()
	local ammo_type = self:GetPrimaryAmmoType() or self.Primary.Ammo
	local ammo_type2 = self:GetSecondaryAmmoType() or self.Secondary.Ammo

	if SERVER then
		self.Owner:SetAmmo( self.Primary.MaxAmmo, ammo_type )
		self:SetClip1( self.Primary.ClipSize )
		self:SetClip2( self.Secondary.ClipSize )

		self.Owner:SetAmmo( self.Secondary.MaxAmmo, ammo_type2 )
		self:SetClip3( self.Tertiary.ClipSize )
    end
end

SWEP.Ispackapunched = false

function SWEP:OnPaP()
return true
end

--[Tables]--
SWEP.StatusLengthOverride = {
    [ACT_VM_RELOAD] = 45 / 30,
    [ACT_VM_RELOAD_SILENCED] = 45 / 30,
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
{ ["time"] = 0, ["type"] = "sound", ["value"] = Sound("weapon_bo3_cloth.short") },
{ ["time"] = 5 / 30, ["type"] = "sound", ["value"] = Sound("weapon_bo3_gear.rattle") },
{ ["time"] = 0, ["type"] = "sound", ["value"] = Sound("TFA_BO3_STAFFS.Pullout") },
},
[ACT_VM_HOLSTER] = {
{ ["time"] = 2 / 30, ["type"] = "sound", ["value"] = Sound("weapon_bo3_cloth.short") },
{ ["time"] = 5 / 30, ["type"] = "sound", ["value"] = Sound("weapon_bo3_gear.rattle") },
{ ["time"] = 0, ["type"] = "sound", ["value"] = Sound("TFA_BO3_STAFFS.Putaway") },
},
[ACT_VM_DRAW_DEPLOYED] = {
{ ["time"] = 0, ["type"] = "sound", ["value"] = Sound("weapon_bo3_cloth.short") },
{ ["time"] = 5 / 30, ["type"] = "sound", ["value"] = Sound("weapon_bo3_gear.rattle") },
{ ["time"] = 10 / 30, ["type"] = "sound", ["value"] = Sound("TFA_BO3_STAFFS.Pullout") },
{ ["time"] = 30 / 30, ["type"] = "sound", ["value"] = Sound("TFA_BO3_STAFFS.Draw") },
},
[ACT_VM_DETACH_SILENCER] = {
{ ["time"] = 0, ["type"] = "sound", ["value"] = Sound("TFA_BO3_STAFFS.Pullout") },
},
[ACT_VM_ATTACH_SILENCER] = {
{ ["time"] = 0, ["type"] = "sound", ["value"] = Sound("TFA_BO3_STAFFS.Putaway") },
},
[ACT_VM_RELOAD] = {
{ ["time"] = 5 / 30, ["type"] = "sound", ["value"] = Sound("TFA_BO3_STAFFS.ReloadIn") },
{ ["time"] = 5 / 30, ["type"] = "sound", ["value"] = Sound("TFA_BO3_STAFFS.Lever") },
{ ["time"] = 25 / 30, ["type"] = "sound", ["value"] = Sound("TFA_BO3_STAFFS.Reload") },
{ ["time"] = 40 / 30, ["type"] = "sound", ["value"] = Sound("TFA_BO3_STAFFS.ReloadOut") },
},
}

--[Shit]--
SWEP.AllowViewAttachment = true --Allow the view to sway based on weapon attachment while reloading or drawing, IF THE CLIENT HAS IT ENABLED IN THEIR CONVARS.
SWEP.Sprint_Mode = TFA.Enum.LOCOMOTION_ANI -- ANI = mdl, HYBRID = ani + lua, Lua = lua only
SWEP.Sights_Mode = TFA.Enum.LOCOMOTION_HYBRID -- ANI = mdl, HYBRID = lua but continue idle, Lua = stop mdl animation
SWEP.Idle_Mode = TFA.Enum.IDLE_BOTH --TFA.Enum.IDLE_DISABLED = no idle, TFA.Enum.IDLE_LUA = lua idle, TFA.Enum.IDLE_ANI = mdl idle, TFA.Enum.IDLE_BOTH = TFA.Enum.IDLE_ANI + TFA.Enum.IDLE_LUA
SWEP.Idle_Blend = 0.25 --Start an idle this far early into the end of a transition
SWEP.Idle_Smooth = 0.05 --Start an idle this far early into the end of another animation
SWEP.SprintBobMult = 1

SWEP.up_hat = true
SWEP.CanBeSilenced = true

SWEP.Secondary.Sound = SWEP.Primary.Sound
SWEP.Secondary.ClipSize = 1
SWEP.Secondary.DefaultClip = 3
SWEP.Secondary.AmmoConsumption = 1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "AR2AltFire"
SWEP.Secondary.RPM = 120
SWEP.Secondary.Damage = 115

SWEP.SpeedColaActivities = {
	[ACT_VM_DRAW] = true,
	[ACT_VM_DRAW_EMPTY] = true,
	[ACT_VM_DRAW_SILENCED] = true,
	[ACT_VM_DRAW_DEPLOYED or 0] = true,
	[ACT_VM_RELOAD] = true,
	[ACT_VM_RELOAD_EMPTY] = true,
	[ACT_VM_RELOAD_SILENCED] = true,
	[ACT_VM_HOLSTER] = true,
	[ACT_VM_HOLSTER_EMPTY] = true,
	[ACT_VM_HOLSTER_SILENCED] = true,
	[ACT_SHOTGUN_RELOAD_START] = true,
	[ACT_SHOTGUN_RELOAD_FINISH] = true,
	[ACT_VM_RELOAD2] = true,
	[ACT_VM_RELOAD_DEPLOYED] = true,
	[ACT_VM_ATTACH_SILENCER] = true,
	[ACT_VM_DETACH_SILENCER] = true,
}

SWEP.StatCache_Blacklist = {
	["Primary.Projectile"] = true,
	["Primary.ProjectileVelocity"] = true,
	["Primary.KickUp"] = true,
	["Primary.KickDown"] = true,
	["Primary.KickHorizontal"] = true,

	["MuzzleFlashEffect"] = true,
	["MuzzleFlashEffectSilenced"] = true,
}

DEFINE_BASECLASS( SWEP.Base )

local l_CT = CurTime
local sp = game.SinglePlayer()
local dryfire_cvar = GetConVar("sv_tfa_allow_dryfire")
local developer = GetConVar("developer")
local cvar_papcamoww = GetConVar("nz_papcamo_ww")

local CLIENT_RAGDOLLS = {
	["class C_ClientRagdoll"] = true,
	["class C_HL2MPRagdoll"] = true,
}

function SWEP:PreDrawViewModel(vm, wep, ply)
	if self.Ispackapunched and (!cvar_papcamoww or (cvar_papcamoww and cvar_papcamoww:GetBool())) then
		if self:GetSilenced() then
			vm:SetSubMaterial(0, self.nzPaPCamo)
			vm:SetSubMaterial(1, self.nzPaPCamo)
			vm:SetSubMaterial(2, self.nzPaPCamo)
			vm:SetSubMaterial(3, self.nzPaPCamo)
		else
			vm:SetSubMaterial(0, self.nzPaPCamo)
			vm:SetSubMaterial(1, self.nzPaPCamo)
			vm:SetSubMaterial(5, self.nzPaPCamo)
			vm:SetSubMaterial(6, self.nzPaPCamo)
		end
	else
		vm:SetSubMaterial(0, nil)
		vm:SetSubMaterial(1, nil)
		vm:SetSubMaterial(2, nil)
		vm:SetSubMaterial(3, nil)
		vm:SetSubMaterial(5, nil)
		vm:SetSubMaterial(6, nil)
	end
end

function SWEP:SetupDataTables()
	BaseClass.SetupDataTables(self)

	self:NetworkVarTFA("Int", "GlowLevel")
	self:NetworkVarTFA("Float", "BeginChargeTime")
	self:NetworkVarTFA("Float", "TotalChargeTime")
end

function SWEP:CanSecondaryAttack()
	local self2 = self:GetTable()

	local v = hook.Run("TFA_PreCanPrimaryAttack", self)
	if v ~= nil then return v end

	stat = self:GetStatus()

	if not TFA.Enum.ReadyStatus[stat] and stat ~= TFA.Enum.STATUS_SHOOTING then
		if self:GetStatL("LoopedReload") and TFA.Enum.ReloadStatus[stat] then
			self:SetReloadLoopCancel(true)
		end

		return false
	end

	if self:GetSprintProgress() >= 0.1 and not self:GetStatL("AllowSprintAttack", false) then
		return false
	end

	if self:GetStatL("Secondary.ClipSize") <= 0 and self:Ammo1() < self:GetStatL("Secondary.AmmoConsumption") then
		return false
	end

	if self:GetPrimaryClipSize(true) > 0 and self:Clip2() < self:GetStatL("Secondary.AmmoConsumption") then
		return false
	end

	if self2.GetStatL(self, "Primary.FiresUnderwater") == false and self:GetOwner():WaterLevel() >= 3 then
		self:SetNextSecondaryFire(l_CT() + 0.5)
		self:EmitSound(self:GetStatL("Primary.Sound_Blocked"))
		return false
	end

	self2.SetHasPlayedEmptyClick(self, false)

	if l_CT() < self:GetNextSecondaryFire() then return false end

	local v2 = hook.Run("TFA_CanPrimaryAttack", self)
	if v2 ~= nil then return v2 end

	return true
end

function SWEP:Think2(...)
	local ply = self:GetOwner()

	if ply:IsPlayer() and ply:KeyDown(IN_USE) and ply:KeyPressed(IN_RELOAD) and self:GetStatus() ~= TFA.Enum.STATUS_SILENCER_TOGGLE then
		if not self:GetSilenced() then
			local _, tanim, ttype = self:PlayAnimation(self:GetStat("BaseAnimations.silencer_attach"))
		else
			local _, tanim, ttype = self:PlayAnimation(self:GetStat("BaseAnimations.silencer_detach"))
		end
		self:ScheduleStatus(TFA.Enum.STATUS_SILENCER_TOGGLE, self:GetActivityLength(tanim))
		self:SetNextPrimaryFire(self.GetNextCorrectedPrimaryFire(self, self:GetActivityLength(tanim, true)+0.1))
	end

	if self:GetStatus() == TFA.Enum.STATUS_SILENCER_TOGGLE then
		if not self.up_hat and self:GetSilenced() then
			self:DetachWaveGun()
			if sp then
				self:CallOnClient("DetachWaveGun")
			end
		end

		if CurTime() > self:GetStatusEnd() and not self:GetSilenced() then
			self:AttachWaveGun()
			if sp then
				self:CallOnClient("AttachWaveGun")
			end
		end
	end

	return BaseClass.Think2(self, ...)
end

function SWEP:AttachWaveGun()
	self.ViewModelKitOld = self.ViewModelKitOld or self.ViewModel
	self.WorldModelKitOld = self.WorldModelKitOld or self.WorldModel
	self.ViewModel = self:GetStat("ViewModelCombined") or self.ViewModel
	self.WorldModel = self:GetStat("WorldModelCombined") or self.WorldModel

	if IsValid(self.OwnerViewModel) then
		self.OwnerViewModel:SetModel(self.ViewModel)
		timer.Simple(0, function()
			if not IsValid(self) then return end
			self:SendViewModelAnim(ACT_VM_IDLE)
		end)
	end

	//self:SetSilenced(false) --inverted for some reason
	//self.Silenced = self:GetSilenced()

	self.Primary_TFA.Projectile = "bo3_ww_wavegun"
	self.Primary_TFA.KickUp = 1.5
	self.Primary_TFA.KickDown = 1
	self.Primary_TFA.KickHorizontal = 0.5

	self.up_hat = false

	self:SetModel(self.WorldModel)
	self:SetNextIdleAnim(-1)
end

function SWEP:DetachWaveGun()
	if self.ViewModelKitOld then
		self.ViewModel = self.ViewModelKitOld
		if IsValid(self.OwnerViewModel) then
			self.OwnerViewModel:SetModel(self.ViewModel)
		end
		self.ViewModelKitOld = nil
	end

	if self.WorldModelKitOld then
		self.WorldModel = self.WorldModelKitOld
		self:SetModel(self.WorldModel)
		self.ViewModelKitOld = nil
	end

	//self:SetSilenced(true) --inverted for some reason
	//self.Silenced = self:GetSilenced()

	self.Primary_TFA.Projectile = "bo3_ww_zapguns"
	self.Primary_TFA.KickUp = 0.5
	self.Primary_TFA.KickDown = 0.3
	self.Primary_TFA.KickHorizontal = 0.25

	self.up_hat = true

	local _, tanim, ttype = self:PlayAnimation(self:GetStat("BaseAnimations.silencer_detach"))

	self:ScheduleStatus(TFA.Enum.STATUS_SILENCER_TOGGLE, self:GetActivityLength(tanim))
	self:SetNextPrimaryFire(self.GetNextCorrectedPrimaryFire(self, self:GetActivityLength(tanim, true)+0.1))
end

function SWEP:Reload(...)
	if !self:GetSilenced() then
		return BaseClass.Reload(self, ...)
	else
		return BaseClass.Reload2(self, ...)
	end
end

function SWEP:CompleteReload(...)
	if hook.Run("TFA_CompleteReload", self) then return end

	if self:GetSilenced() then
		local maxclip = self:GetMaxClip2()
		local curclip = self:Clip2()
		local amounttoreplace = math.min(maxclip - curclip, self:Ammo1())

		self:TakeSecondaryAmmo(amounttoreplace * -1)
		return
	end

	return BaseClass.CompleteReload(self, ...)
end

function SWEP:GetSecondaryDelay()
	local rpm2 = self:GetStat("Secondary.RPM")
	if rpm2 and rpm2 > 0 then
		return 60 / rpm2
	end
end

function SWEP:SecondaryAttack(...)
	if self:GetSilenced() then
		return BaseClass.SecondaryAttack(self,...)
	end

	local self2 = self:GetTable()
	local ply = self:GetOwner()
	if not IsValid(ply) then return end

	if not IsValid(self) then return end
	if ply:IsPlayer() and not self:VMIV() then return end
	if not self:CanSecondaryAttack() then return end

	self:PreSecondaryAttack()
	if hook.Run("TFA_PrimaryAttack", self) then return end

	self.MuzzleFlashEffect = self.Ispackapunched and "tfa_bo3_muzzleflash_zapgun_pap" or "tfa_bo3_muzzleflash_zapgun_right"

	self:ToggleAkimbo(true, 1)
	self:SetAkimboAttackValue(1)
	self:TriggerAttack("Secondary", 2)

	self:SetNextSecondaryFire(self2.GetNextCorrectedPrimaryFire(self, self2.GetSecondaryDelay(self)))

	if ply:IsPlayer() and ply:KeyDown(IN_USE) then return end
	self:PostSecondaryAttack()
	hook.Run("TFA_PostPrimaryAttack", self)
end

function SWEP:Holster(...)
	if self:GetSilenced() and self:GetStatus() == TFA.Enum.STATUS_SILENCER_TOGGLE then
		return false
	end
	return BaseClass.Holster(self, ...)
end

local draw = draw
local surface = surface
local render = render
local Vector = Vector
local TFA = TFA
local math = math

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

local sv_tfa_fixed_crosshair = GetConVar("sv_tfa_fixed_crosshair")
local crossr_cvar = GetConVar("cl_tfa_hud_crosshair_color_r")
local crossg_cvar = GetConVar("cl_tfa_hud_crosshair_color_g")
local crossb_cvar = GetConVar("cl_tfa_hud_crosshair_color_b")
local crosscol = Color(255, 255, 255, 255)

function SWEP:DrawHUDBackground()
	if not self:GetSilenced() then return end
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
