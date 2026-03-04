local nzombies = engine.ActiveGamemode() == "nzombies"
local dlight_cvar = GetConVar("cl_tfa_fx_wonderweapon_dlights")
local tpfx_cvar = GetConVar("cl_tfa_fx_wonderweapon_3p")

SWEP.Base = "tfa_gun_base"
SWEP.Category = "TFA Wonder Weapons"
SWEP.SubCategory = "Black Ops 3"
SWEP.Spawnable = TFA_BASE_VERSION and TFA_BASE_VERSION >= 4.76
SWEP.AdminSpawnable = true
SWEP.UseHands = true
SWEP.Type_Displayed = "#tfa.weapontype.wonderweapon"
SWEP.Author = "FlamingFox"
SWEP.Slot = 2
SWEP.PrintName = "Wunderwaffe DG-2"
SWEP.DrawCrosshair = true
SWEP.DrawCrosshairIS = false
SWEP.WWCrosshairEnabled = true

--[Model]--
SWEP.ViewModel			= "models/weapons/tfa_bo3/wunderwaffe/c_wunderwaffe.mdl"
SWEP.ViewModelFOV = 65
SWEP.WorldModel			= "models/weapons/tfa_bo3/wunderwaffe/w_wunderwaffe.mdl"
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
        Right = 1,
        Forward = 3.5,
        },
        Ang = {
		Up = 180,
        Right = 195,
        Forward = 0
        },
		Scale = 1
}

--[Gun Related]--
SWEP.Primary.Sound = "TFA_BO3_WAFFE.Shoot"
SWEP.Primary.Ammo = "AR2AltFire"
SWEP.Primary.Automatic = false
SWEP.Primary.RPM = 60
SWEP.Primary.Damage = nzombies and 115 or 1000
SWEP.Primary.NumShots = 1
SWEP.Primary.AmmoConsumption = 1
SWEP.Primary.ClipSize = 3
SWEP.Primary.DefaultClip = SWEP.Primary.ClipSize
SWEP.Primary.Knockback = 80
SWEP.MuzzleFlashEffect = "tfa_bo3_muzzleflash_waffe"
SWEP.DisableChambering = true
SWEP.FiresUnderwater = true

--[Firemode]--
SWEP.Primary.BurstDelay = nil
SWEP.DisableBurstFire = true
SWEP.SelectiveFire = false
SWEP.OnlyBurstFire = false
SWEP.BurstFireCount = nil

--[LowAmmo]--
SWEP.FireSoundAffectedByClipSize = true
SWEP.LowAmmoSoundThreshold = 0.33 --0.33
SWEP.LowAmmoSound = ""
SWEP.LastAmmoSound = "TFA_BO3_WAFFE.ShootLast"

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
SWEP.Primary.Spread		  = .035
SWEP.Primary.IronAccuracy = .001
SWEP.IronRecoilMultiplier = 0.6
SWEP.CrouchAccuracyMultiplier = 0.85

SWEP.Primary.KickUp				= 0.6
SWEP.Primary.KickDown			= 0.6
SWEP.Primary.KickHorizontal		= 0.5
SWEP.Primary.StaticRecoilFactor	= 0.4

SWEP.Primary.SpreadMultiplierMax = 3
SWEP.Primary.SpreadIncrement = 3
SWEP.Primary.SpreadRecovery = 4

--[Iron Sights]--
SWEP.IronBobMult 	 = 0.065
SWEP.IronBobMultWalk = 0.065
SWEP.data = {}
SWEP.data.ironsights = 1
SWEP.IronInSound = "weapon_bo3_gear.rattle"
SWEP.IronOutSound = "weapon_bo3_gear.rattle"
SWEP.Secondary.IronFOV = 70
SWEP.IronSightsPos = Vector(-5.13, -4, -0.82)
SWEP.IronSightsAng = Vector(0, 0, 0)
SWEP.IronSightTime = 0.45

--[Shells]--
SWEP.LuaShellEject = false
SWEP.LuaShellEffect = "ShellEject"
SWEP.LuaShellModel = "models/weapons/tfa_bo3/wunderwaffe/tesla_bulb.mdl"
SWEP.LuaShellScale = 1.2
SWEP.LuaShellEjectDelay = 0
SWEP.ShellAttachment = 2
SWEP.EjectionSmokeEnabled = false

--[Projectile]--
SWEP.Primary.Projectile         = "bo3_ww_wunderwaffe" -- Entity to shoot
SWEP.Primary.ProjectileVelocity = 3500 -- Entity to shoot's velocity
SWEP.Primary.ProjectileModel    = "models/dav0r/hoverball.mdl" -- Entity to shoot's model

--[Misc]--
SWEP.AmmoTypeStrings = {ar2altfire = "Tesla Bulbs"}
SWEP.InspectPos = Vector(10, -5, -2)
SWEP.InspectAng = Vector(24, 42, 16)
SWEP.MoveSpeed = 0.9
SWEP.IronSightsMoveSpeed  = SWEP.MoveSpeed * 0.8
SWEP.SafetyPos = Vector(1, -2, -0.5)
SWEP.SafetyAng = Vector(-20, 35, -25)
SWEP.SmokeParticle = ""

--[NZombies]--
SWEP.NZPaPName = "Wunderwaffe DG-3 JZ"
SWEP.NZWonderWeapon = true
SWEP.Primary.MaxAmmo = 15

function SWEP:NZMaxAmmo()

	local ammo_type = self:GetPrimaryAmmoType() or self.Primary_TFA.Ammo

	if SERVER then
		self.Owner:SetAmmo( self.Primary.MaxAmmo, ammo_type )
		self:SetClip1( self.Primary.ClipSize )
	end
end

SWEP.Ispackapunched = false
SWEP.MuzzleFlashEffectPAP = "tfa_bo3_muzzleflash_waffe_pap"
SWEP.Primary.ClipSizePAP = 6
SWEP.Primary.MaxAmmoPAP = 30
SWEP.MoveSpeedPAP = 0.95

function SWEP:OnPaP()
self.Ispackapunched = true

self.MuzzleFlashEffect = "tfa_bo3_muzzleflash_waffe_pap"

self.Primary_TFA.ClipSize = 6
self.Primary_TFA.MaxAmmo = 30

self.MoveSpeed = 0.95

self.Skin = 1
self:SetSkin(1)

self.VElements["glass"].skin = 1

if self.CleanModels then
	self:CleanModels(self:GetStatRaw("ViewModelElements", TFA.LatestDataVersion))
end

self:ClearStatCache()
return true
end

--[Tables]--
SWEP.StatusLengthOverride = {
	[ACT_VM_RELOAD] = 100 / 30,
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
{ ["time"] = 0, ["type"] = "lua", value = function(self) self:CleanParticles() end, client = true, server = false},
{ ["time"] = 0, ["type"] = "sound", ["value"] = Sound("weapon_bo3_cloth.med") },
{ ["time"] = 5 / 30, ["type"] = "sound", ["value"] = Sound("weapon_bo3_gear.rattle") },
{ ["time"] = 5 / 30, ["type"] = "lua", value = function(self) self:SetGlowLevel(math.ceil(math.Clamp(self:CalcAmmoPap(), 0, 3))) self:SetMainGlow(self:Clip1() > 0) self:UpdateViewmodelParticles() end, client = true, server = true},
{ ["time"] = 15 / 30, ["type"] = "sound", ["value"] = Sound("TFA_BO3_WAFFE.Meow.Idle") },
},
[ACT_VM_HOLSTER] = {
{ ["time"] = 2 / 30, ["type"] = "sound", ["value"] = Sound("weapon_bo3_cloth.med") },
{ ["time"] = 5 / 30, ["type"] = "sound", ["value"] = Sound("weapon_bo3_gear.rattle") },
},
[ACT_VM_DRAW_DEPLOYED] = {
{ ["time"] = 0, ["type"] = "lua", value = function(self) self:CleanParticles() end, client = true, server = false},
{ ["time"] = 0, ["type"] = "lua", value = function(self) self:SetGlowLevel(0) self:SetMainGlow(false) self:UpdateViewmodelParticles() end, client = true, server = true},
{ ["time"] = 0, ["type"] = "sound", ["value"] = Sound("weapon_bo3_cloth.med") },
{ ["time"] = 15 / 30, ["type"] = "sound", ["value"] = Sound("TFA_BO3_WAFFE.FlipOn") },
{ ["time"] = 20 / 30, ["type"] = "lua", value = function(self) self:SetGlowLevel(math.ceil(math.Clamp(self:CalcAmmoPap(), 0, 3))) self:SetMainGlow(self:Clip1() > 0) self:UpdateViewmodelParticles() end, client = true, server = true},
},
[ACT_VM_RELOAD] = {
{ ["time"] = 0, ["type"] = "sound", ["value"] = Sound("TFA_BO3_WAFFE.Start") },
{ ["time"] = 20 / 30, ["type"] = "sound", ["value"] = Sound("TFA_BO3_WAFFE.FlipOff") },
{ ["time"] = 25 / 30, ["type"] = "lua", value = function(self) self:CleanParticles() end, client = true, server = false},
{ ["time"] = 25 / 30, ["type"] = "lua", value = function(self) self:SetGlowLevel(0) self:SetMainGlow(false) self:UpdateViewmodelParticles() end, client = true, server = true},
{ ["time"] = 45 / 30, ["type"] = "sound", ["value"] = Sound("TFA_BO3_WAFFE.Pullback") },
{ ["time"] = 55 / 30, ["type"] = "lua", value = function(self) self:EventShell() end, client = true, server = true},
{ ["time"] = 55.5 / 30, ["type"] = "lua", value = function(self) self:EventShell() end, client = true, server = true},
{ ["time"] = 56 / 30, ["type"] = "lua", value = function(self) self:EventShell() end, client = true, server = true},
{ ["time"] = 55 / 30, ["type"] = "lua", value = function(self) self.Bodygroups_W = {[1] = 1} end, client = true, server = true},
{ ["time"] = 95 / 30, ["type"] = "sound", ["value"] = Sound("TFA_BO3_WAFFE.ClipIn") },
{ ["time"] = 95 / 30, ["type"] = "lua", value = function(self) self.Bodygroups_W = {[1] = 0} end, client = true, server = true},
{ ["time"] = 115 / 30, ["type"] = "lua", value = function(self)
	if SERVER then
		local ply = self:GetOwner()
		local fx = EffectData()
		fx:SetEntity(self)
		fx:SetAttachment(7)

		local filter = RecipientFilter()
		filter:AddPVS(ply:GetShootPos())
		filter:AddPlayer(ply)
		if IsValid(ply) and self:IsFirstPerson() then
			filter:RemovePlayer(ply)
		end

		if filter:GetCount() > 0 then
			util.Effect("tfa_bo3_waffe_eject", fx, true, filter)
		end
	end
end, client = false, server = true},
{ ["time"] = 115 / 30, ["type"] = "sound", ["value"] = Sound("TFA_BO3_WAFFE.Release") },
{ ["time"] = 145 / 30, ["type"] = "sound", ["value"] = Sound("TFA_BO3_WAFFE.FlipOn") },
{ ["time"] = 150 / 30, ["type"] = "lua", value = function(self) self:SetGlowLevel(math.ceil(math.Clamp(self:CalcAmmoPap(), 0, 3))) self:SetMainGlow(self:Clip1() > 0) self:UpdateViewmodelParticles() end, client = true, server = true},
{ ["time"] = 175 / 30, ["type"] = "sound", ["value"] = Sound("TFA_BO3_WAFFE.Meow.Sweets") },
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

SWEP.VElements = {
	["glass"] = { type = "Model", model = "models/weapons/tfa_bo3/wunderwaffe/c_wunderwaffe_bulbs.mdl", bone = "tag_weapon", rel = "", pos = Vector(0, 0, 0), angle = Angle(0, 0, 0), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bonemerge = true, active = true, translucent = true, bodygroup = {} },
}
SWEP.Bodygroups_W = {
	[1] = 0
}

SWEP.Attachments = {
[1] = {atts = {"bo3_packapunch"}, order = 1, hidden = engine.ActiveGamemode() == "nzombies"},
}

SWEP.Glow = Material("models/weapons/tfa_bo3/wunderwaffe/mtl_wpn_t7_zmb_dg2_glow.vmt")
SWEP.Lights = {
	[0] = Material("models/weapons/tfa_bo3/wunderwaffe/mtl_wpn_t7_zmb_dg2_bulb3.vmt"),
	[1] = Material("models/weapons/tfa_bo3/wunderwaffe/mtl_wpn_t7_zmb_dg2_bulb2.vmt"),
	[2] = Material("models/weapons/tfa_bo3/wunderwaffe/mtl_wpn_t7_zmb_dg2_bulb1.vmt"),
}

SWEP.StatCache_Blacklist = {
	["VElements"] = true,
	["Bodygroups_W"] = true,
}

SWEP.GlowColor = Color(200, 230, 255, 255)
SWEP.GlowColorUpgraded = Color(255, 200, 200, 255)

--[Effects]--
DEFINE_BASECLASS( SWEP.Base )

local sp = game.SinglePlayer()
local cvar_papcamoww = GetConVar("nz_papcamo_ww")
local CONTENTS_LIQUID = bit.bor( CONTENTS_WATER, CONTENTS_SLIME )

function SWEP:SetupDataTables()
	BaseClass.SetupDataTables(self)
	
	self:NetworkVarTFA("Float", "NextWave")
	self:NetworkVarTFA("Float", "NextGlow")
	self:NetworkVarTFA("Int", "GlowLevel")
	self:NetworkVarTFA("Bool", "MainGlow")
end

function SWEP:PreSpawnProjectile(ent)
	ent.FiredFromAFuckingGun = true
	ent:SetUpgraded(self.Ispackapunched)
	ent:SetOwner(self:GetOwner())
end

function SWEP:PrePrimaryAttack()
	if CLIENT then return end

	local ply = self:GetOwner()
	if not IsValid(ply) then return end

	// underwater shoot your self

	local view_pos = ply.GetShootPos and ply:GetShootPos() or ply:EyePos()
	if bit.band(util.PointContents(view_pos), CONTENTS_LIQUID) == 0 then return end

	self.StoredProjectileClass = self:GetStatL("Primary.Projectile")

	self.Primary_TFA.Projectile = nil
	self.Primary.Projectile = nil
	self:ClearStatCache("Primary.Projectile")

	local ent = ents.Create(self.StoredProjectileClass)

	ent:SetPos(ply:GetPos())
	ent:SetOwner(self:GetOwner())
	ent:SetAngles(ply:GetAimVector():Angle())

	ent.damage = self:GetStatL("Primary.Damage")
	ent.mydamage = self:GetStatL("Primary.Damage")

	if self:GetStatL("Primary.ProjectileModel") then
		ent:SetModel(self:GetStatL("Primary.ProjectileModel"))
	end

	self:PreSpawnProjectile(ent)

	ent:Spawn()

	if self.ProjectileModel then
		ent:SetModel(self:GetStatL("Primary.ProjectileModel"))
	end

	ent:SetOwner(self:GetOwner())

	self:PostSpawnProjectile(ent)

	ent:OnCollide(ply, ply:GetPos())
end

function SWEP:PostPrimaryAttack()
	local ply = self:GetOwner()
	local ifp = IsFirstTimePredicted()
	if ifp then
		self:EmitGunfireSound("TFA_BO3_WAFFE.Ext")
	end

	if SERVER and self.StoredProjectileClass then
		self.Primary_TFA.Projectile = self.StoredProjectileClass
		self.Primary.Projectile = self.StoredProjectileClass
		self:ClearStatCache("Primary.Projectile")

		self.StoredProjectileClass = nil
	end

	if not self:VMIV() then return end

	if ifp then
		ParticleEffectAttach( self.Ispackapunched and "bo3_waffe_vm_arcs_2" or "bo3_waffe_vm_arcs", PATTACH_POINT_FOLLOW, self.OwnerViewModel, 1)
	end

	if sp and SERVER then
		self:CallOnClient("UpdateViewmodelParticles")
	end
	self:UpdateViewmodelParticles()

	self:SetGlowLevel(math.ceil(math.Clamp(self:CalcAmmoPap(), 0, 3)))
	self:SetMainGlow(self:Clip1() > 0)
end

function SWEP:PreDrawViewModel(vm, ...)
	BaseClass.PreDrawViewModel(self, vm, ...)

	if self.Ispackapunched then
		self.Skin = 1
		self:SetSkin(1)

		self.VElements["glass"].skin = 1

		local model = self.VElements["glass"].curmodel
		if IsValid(model) and model:GetSkin() ~= 1 then
			model:SetSkin(1)
		end
	else
		self.Skin = 0
		self:SetSkin(0)

		self.VElements["glass"].skin = 0

		local model = self.VElements["glass"].curmodel
		if IsValid(model) and model:GetSkin() ~= 0 then
			model:SetSkin(0)
		end
	end

	if self.Ispackapunched and (!cvar_papcamoww or (cvar_papcamoww and cvar_papcamoww:GetBool())) then
		vm:SetSubMaterial(0, self.nzPaPCamo)
		vm:SetSubMaterial(2, self.nzPaPCamo)
		vm:SetSubMaterial(4, self.nzPaPCamo)
		vm:SetSubMaterial(5, self.nzPaPCamo)
		vm:SetSubMaterial(9, self.nzPaPCamo)
		vm:SetSubMaterial(8, self.nzPaPCamo)
		vm:SetSubMaterial(3, self.nzPaPCamo)
	else
		vm:SetSubMaterial(0, nil)
		vm:SetSubMaterial(2, nil)
		vm:SetSubMaterial(4, nil)
		vm:SetSubMaterial(5, nil)
		vm:SetSubMaterial(9, nil)
		vm:SetSubMaterial(8, nil)
	end

	local status = self:GetStatus()
	local bShouldGlow = self.GetMainGlow and ( self:GetMainGlow() and IsValid( self.OwnerViewModel ) ) or false

	if TFA.Enum.ReadyStatus[status] or ( status == TFA.Enum.STATUS_SHOOTING ) then
		for i = 1, 3 do
			self:AddDrawCallViewModelParticle( self.Ispackapunched and "bo3_waffe_bulbs_pap" or "bo3_waffe_bulbs", PATTACH_POINT_FOLLOW, i + 2, bShouldGlow and self:GetGlowLevel() >= i )
		end

		self:AddDrawCallViewModelParticle( self.Ispackapunched and "bo3_waffe_bulbs_pap" or "bo3_waffe_bulbs_main", PATTACH_POINT_FOLLOW, 6, bShouldGlow )
	end

	if self:GetNextGlow() > CurTime() and dlight_cvar:GetBool() and DynamicLight then
		self.DLight = self.DLight or DynamicLight(self:EntIndex(), false)
		if self.OwnerViewModel and IsValid(self.OwnerViewModel) and self.DLight then
			local attpos = self.OwnerViewModel:GetAttachment(1)

			if (attpos and attpos.Pos) then
				self.DLight.pos = attpos.Pos
				self.DLight.r = upg and self.GlowColorUpgraded.r or self.GlowColor.r
				self.DLight.g = upg and self.GlowColorUpgraded.g or self.GlowColor.g
				self.DLight.b = upg and self.GlowColorUpgraded.b or self.GlowColor.b
				self.DLight.decay = 500
				self.DLight.brightness = 1
				self.DLight.size = 128
				self.DLight.dietime = CurTime() + 1
			end
		end
	end
end

function SWEP:DrawWorldModel(...)
	BaseClass.DrawWorldModel(self, ...)

	if self.Ispackapunched then
		self.Skin = 1
		self:SetSkin(1)
	elseif self.Skin == 1 then
		self.Skin = 0
		self:SetSkin(0)
	end

	if self.Bodygroups_W and self.Bodygroups_W[1] ~= 0 and not TFA.Enum.ReloadStatus[self:GetStatus()] then
		self.Bodygroups_W[1] = 0
	end

	local status = self:GetStatus()
	local bShouldGlow = self.GetMainGlow and ( self:GetMainGlow() and tpfx_cvar:GetBool() and !TFA.Enum.HolsterStatus[status] ) or false

	if !TFA.Enum.ReloadStatus[status] then
		for i = 1, 3 do
			self:AddDrawCallWorldModelParticle( self.Ispackapunched and "bo3_waffe_bulbs_pap_3p" or "bo3_waffe_bulbs_3p", PATTACH_POINT_FOLLOW, i + (5 - self:GetGlowLevel()), bShouldGlow and ( !self:IsCarriedByLocalPlayer() or !self:IsFirstPerson() ) and self:GetGlowLevel() >= i )
		end

		self:AddDrawCallWorldModelParticle( self.Ispackapunched and "bo3_waffe_bulbs_pap_3p" or "bo3_waffe_bulbs_main_3p", PATTACH_POINT_FOLLOW, 6, bShouldGlow and ( !self:IsCarriedByLocalPlayer() or !self:IsFirstPerson() ) )
	end

	if self:GetNextGlow() > CurTime() and dlight_cvar:GetInt() == 1 and DynamicLight then
		self.DLight = self.DLight or DynamicLight(self:EntIndex(), false)
		if self.DLight then
			local attpos = self:GetAttachment(1)
			local upg = self.Ispackapunched

			if (attpos and attpos.Pos) then
				self.DLight.pos = attpos.Pos
				self.DLight.dir = attpos.Ang:Forward()
				self.DLight.r = upg and self.GlowColorUpgraded.r or self.GlowColor.r
				self.DLight.g = upg and self.GlowColorUpgraded.g or self.GlowColor.g
				self.DLight.b = upg and self.GlowColorUpgraded.b or self.GlowColor.b
				self.DLight.decay = 1000
				self.DLight.brightness = 0
				self.DLight.size = 128
				self.DLight.dietime = CurTime() + 1
			end
		end
	end
end

function SWEP:CalcAmmoPap()
	if self.Ispackapunched then
		return self:Clip1()/2
	end
	return self:Clip1()
end

function SWEP:UpdateViewmodelParticles()
	if SERVER then
		if not sp then
			self:CallOnClient("UpdateViewmodelParticles")
		end
		return
	end
	if not self:VMIV() then return end

	local bShouldGlow = self.GetMainGlow and ( self:GetMainGlow() and IsValid( self.OwnerViewModel ) ) or false

	for i = 1, 3 do
		self:AddDrawCallViewModelParticle( self.Ispackapunched and "bo3_waffe_bulbs_pap" or "bo3_waffe_bulbs", PATTACH_POINT_FOLLOW, i + 2, bShouldGlow and self:GetGlowLevel() >= i )
	end

	self:AddDrawCallViewModelParticle( self.Ispackapunched and "bo3_waffe_bulbs_pap" or "bo3_waffe_bulbs_main", PATTACH_POINT_FOLLOW, 6, bShouldGlow )
end

function SWEP:Think2(...)
	if SERVER then
		local nMax = math.ceil( math.Clamp( self:CalcAmmoPap(), 0, 3 ) )
		if self:GetGlowLevel() ~= nMax and TFA.Enum.ReadyStatus[self:GetStatus()] then
			self:SetGlowLevel( nMax )
		end

		local bActive = self:Clip1() > 0
		if self:GetMainGlow() ~= bActive and TFA.Enum.ReadyStatus[self:GetStatus()] then
			self:SetMainGlow( bActive )
		end

		if self.Bodygroups_W and self.Bodygroups_W[1] ~= 0 and not TFA.Enum.ReloadStatus[self:GetStatus()] then
			self.Bodygroups_W[1] = 0
		end
	end

	if not self:GetNextWave() then
		self:SetNextWave( CurTime() + self:SharedRandom(8, 10) )
	end

	if TFA.Enum.ReadyStatus[self:GetStatus()] and self:GetNextWave() < CurTime() then
		self:SetNextWave( CurTime() + self:SharedRandom(8, 14) )
		self:SetNextGlow( CurTime() + 0.6 )

		if self:VMIV() then
			ParticleEffectAttach( self.Ispackapunched and "bo3_waffe_idle_2" or "bo3_waffe_idle", PATTACH_POINT_FOLLOW, self.OwnerViewModel, 1 )
			if CLIENT and not sp and not self:IsFirstPerson() then
				ParticleEffectAttach( self.Ispackapunched and "bo3_waffe_3p_2" or "bo3_waffe_3p", PATTACH_POINT_FOLLOW, self, 1 )
			end
		end

		if SERVER then
			local ply = self:GetOwner()
			local fx = EffectData()
			fx:SetEntity(self)
			fx:SetAttachment(1)
			fx:SetFlags(self.Ispackapunched and 2 or 1)

			local filter = RecipientFilter()
			filter:AddPVS(ply:GetShootPos())
			if IsValid(ply) and self:IsFirstPerson() then
				filter:RemovePlayer(ply)
			end

			if filter:GetCount() > 0 then
				util.Effect("tfa_bo3_waffe_3p", fx, true, filter)
			end
		end

		if IsFirstTimePredicted() then
			self:EmitSound("TFA_BO3_WAFFE.Meow.Calm")
		end
	end

	return BaseClass.Think2(self, ...)
end

function SWEP:ShootBulletInformation(...)
	if self.StoredProjectileClass then return end

	BaseClass.ShootBulletInformation(self, ...)
end

function SWEP:HappyLights()
	ParticleEffectAttach("bo3_waffe_chirp", PATTACH_POINT_FOLLOW, self.OwnerViewModel, 1)

	for i=1, self:Clip1() do
		if self:CalcAmmoPap() > (i - 1) then
			ParticleEffectAttach(self.Ispackapunched and "bo3_waffe_bulbs_happy_pap" or "bo3_waffe_bulbs_happy", PATTACH_POINT_FOLLOW, self.OwnerViewModel, i + 2)
		end
	end

	if self:Clip1() > 0 then
		ParticleEffectAttach(self.Ispackapunched and "bo3_waffe_bulbs_happy_pap" or "bo3_waffe_bulbs_happy_main", PATTACH_POINT_FOLLOW, self.OwnerViewModel, 6)
	end
end

function SWEP:OnRestore()
	if self.LastSaveRestoreChatter and self.LastSaveRestoreChatter + 10 > CurTime() then return end

	self.LastSaveRestoreChatter = CurTime()

	self:EmitSound("TFA_BO3_WAFFE.Meow.Idle")

	self:HappyLights()

	if (self:GetNextWave() - 2) < CurTime() then
		self:SetNextWave( CurTime() + self:SharedRandom(2, 4) )
	end
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
