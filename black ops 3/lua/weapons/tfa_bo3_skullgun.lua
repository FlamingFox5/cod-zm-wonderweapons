local nzombies = engine.ActiveGamemode() == "nzombies"
local inf_cvar = GetConVar("sv_tfa_bo3ww_inf_specialist")
local dlight_cvar = GetConVar("cl_tfa_fx_wonderweapon_dlights")
local cl_worldmodel_fx = GetConVar("cl_tfa_fx_wonderweapon_3p")
local sv_damage_world = GetConVar("sv_tfa_bo3ww_environmental_damage")

SWEP.Base = "tfa_gun_base"
SWEP.Category = "TFA Wonder Weapons"
SWEP.SubCategory = "Black Ops 3"
SWEP.Spawnable = TFA_BASE_VERSION and TFA_BASE_VERSION >= 4.76
SWEP.AdminSpawnable = true
SWEP.UseHands = true
SWEP.Type_Displayed = "#tfa.weapontype.specialist"
SWEP.Author = "FlamingFox"
SWEP.Slot = 0
SWEP.PrintName = "Skull of Nan Sapwe"
SWEP.DrawCrosshair = true
SWEP.DrawCrosshairIS = false
SWEP.WWCrosshairEnabled = true
SWEP.AutoSwitchTo = false

--[Model]--
SWEP.ViewModel			= "models/weapons/tfa_bo3/skullgun/c_skullgun.mdl"
SWEP.ViewModelFOV = 65
SWEP.WorldModel			= "models/weapons/tfa_bo3/skullgun/w_skullgun.mdl"
SWEP.HoldType = "pistol"
SWEP.CameraAttachmentOffsets = {}
SWEP.CameraAttachmentScale = 1
SWEP.MuzzleAttachment = "1"
SWEP.VMPos = Vector(0, -6, -1.5)
SWEP.VMAng = Vector(0, 0, 0)
SWEP.VMPos_Additive = true

SWEP.Offset = { --Procedural world model animation, defaulted for CS:S purposes.
        Pos = {
        Up = -0.5,
        Right = 1.2,
        Forward = 3.5,
        },
        Ang = {
		Up = 175,
        Right = 190,
        Forward = 0
        },
		Scale = 1
}

--[Gun Related]--
SWEP.Primary.Sound = "TFA_BO3_SKULL.FireIn"
SWEP.Primary.LoopSound = "TFA_BO3_SKULL.FireLoop"
SWEP.Primary.LoopSoundTail = "TFA_BO3_SKULL.FireOut"
SWEP.Primary.Ammo = nzombies and "none" or "SpecialistCharge"
SWEP.Primary.Automatic = true
SWEP.Primary.RPM = 600
SWEP.Primary.RPM_Semi = nil
SWEP.Primary.RPM_Burst = nil
SWEP.Primary.Damage = nzombies and 115 or 200
SWEP.Primary.Knockback = 0
SWEP.Primary.NumShots = 1
SWEP.Primary.AmmoConsumption = inf_cvar:GetBool() and 0 or 1
SWEP.Primary.AmmoRegen = 1
SWEP.Primary.ClipSize = nzombies and 200 or -1
SWEP.Primary.DefaultClip = 200
SWEP.Primary.DryFireDelay = 0.5
SWEP.MuzzleFlashEffect	= ""
SWEP.MuzzleFlashEnabled = false
SWEP.DisableChambering = true
SWEP.FiresUnderwater = true
SWEP.Secondary.Automatic = true

--[Firemode]--
SWEP.Primary.BurstDelay = nil
SWEP.DisableBurstFire = true
SWEP.SelectiveFire = false
SWEP.OnlyBurstFire = false
SWEP.BurstFireCount = nil

--[LowAmmo]--
SWEP.FireSoundAffectedByClipSize = false
SWEP.LowAmmoSoundThreshold = 0.1 --0.33
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
SWEP.Primary.IronAccuracy = .00
SWEP.IronRecoilMultiplier = 0.6
SWEP.CrouchAccuracyMultiplier = 0.85

SWEP.Primary.KickUp				= 0.0
SWEP.Primary.KickDown			= 0.0
SWEP.Primary.KickHorizontal		= 0.0
SWEP.Primary.StaticRecoilFactor	= 0.0

SWEP.Primary.SpreadMultiplierMax = 3
SWEP.Primary.SpreadIncrement = 0
SWEP.Primary.SpreadRecovery = 6

--[Iron Sights]--
SWEP.data = {}
SWEP.data.ironsights = 0

--[Shells]--
SWEP.LuaShellEject = false
SWEP.LuaShellEffect = "ShellEject"
SWEP.LuaShellModel = nil
SWEP.LuaShellScale = 1
SWEP.LuaShellEjectDelay = 0
SWEP.ShellAttachment = "0"
SWEP.EjectionSmokeEnabled = false

--[Misc]--
SWEP.InspectPos = Vector(8, -5, -1)
SWEP.InspectAng = Vector(20, 30, 16)
SWEP.MoveSpeed = 1.0
SWEP.IronSightsMoveSpeed = SWEP.MoveSpeed * 0.8
SWEP.SafetyPos = Vector(0, 0, -0)
SWEP.SafetyAng = Vector(-15, 15, -15)
SWEP.SmokeParticle = ""

--[NZombies]--
SWEP.NZWonderWeapon = false
SWEP.NZSpecialCategory = "specialist"
SWEP.NZSpecialWeaponData = {MaxAmmo = 0, AmmoType = "none"}
SWEP.NZHudIcon = Material("vgui/icon/t7_hud_zm_hud_ammo_icon_skull_weapon_ready.png", "unlitgeneric smooth")
SWEP.NZHudIcon_t7 = Material("vgui/icon/t7_hud_zm_hud_ammo_icon_skull_weapon_ready_t7.png", "unlitgeneric smooth")
SWEP.NZHudIcon_t7flash = Material("vgui/icon/t7_hud_zm_hud_ammo_icon_skull_weapon_readyflash.png", "unlitgeneric smooth")

function SWEP:NZSpecialHolster(wep)
	return true
end

function SWEP:OnSpecialistRecharged()
	if CLIENT then
		self.NZPickedUpTime = CurTime()
	end
end

--[Tables]--
SWEP.StatusLengthOverride = {
}

SWEP.ShootAnimation = {
	["in"] = {
		["type"] = TFA.Enum.ANIMATION_SEQ, --Sequence or act
		["value"] = "fire_in", --Number for act, String/Number for sequence
	},
	["loop"] = {
		["type"] = TFA.Enum.ANIMATION_SEQ, --Sequence or act
		["value"] = "fire_loop", --Number for act, String/Number for sequence
		["is_idle"] = true
	},
	["out"] = {
		["type"] = TFA.Enum.ANIMATION_SEQ, --Sequence or act
		["value"] = "fire_out", --Number for act, String/Number for sequence
	}
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
{ ["time"] = 0, ["type"] = "sound", ["value"] = Sound("TFA_BO3_SKULL.Raise") },
},
[ACT_VM_HOLSTER] = {
{ ["time"] = 0, ["type"] = "sound", ["value"] = Sound("weapon_bo3_cloth.short") },
{ ["time"] = 5 / 30, ["type"] = "sound", ["value"] = Sound("weapon_bo3_gear.rattle") },
},
[ACT_VM_DRAW_DEPLOYED] = {
{ ["time"] = 15 / 30, ["type"] = "sound", ["value"] = Sound("TFA_BO3_SKULL.FirstDraw") },
{ ["time"] = 26 / 30, ["type"] = "lua", value = function(self) self:SetGlowRatio(1) end, client = true, server = true},
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

SWEP.StatCache_Blacklist = {
	["MuzzleFlashEffect"] = true,
}

SWEP.CylinderRadius = 300

SWEP.WW3P_FX = "bo3_skull_3p"
SWEP.WW3P_ATT = 1

SWEP.WWFP_FX = "bo3_skull_vm"
SWEP.WWFP_ATT = 2

SWEP.LastBreakableDamageTick = {}

DEFINE_BASECLASS( SWEP.Base )

local _sp = game.SinglePlayer()

function SWEP:SetupDataTables(...)
	BaseClass.SetupDataTables(self,...)

	self:NetworkVarTFA("Bool", "HasEmitSound")
	self:NetworkVarTFA("Int", "AttackType")
	self:NetworkVarTFA("Float", "GlowRatio")
end

function SWEP:ShootBulletInformation()
end

function SWEP:FireAnimationEvent(pos, ang, event, options, ent)
	if (event == 5001) then
		timer.Simple(0, function()
			if not IsValid(ent) then return end

			local parent = ent:GetParent()
			local owner = (IsValid(parent) and parent.GetActiveWeapon) and parent or ent:GetOwner()
			local wep = ent

			if not (IsValid(wep) and wep:IsWeapon()) and IsValid(owner) and owner.GetActiveWeapon then
				wep = owner:GetActiveWeapon()
			end
			if not (IsValid(wep) and wep:IsWeapon()) and owner:IsWeapon() then
				wep = owner
			end

			if not (IsValid(wep) and wep:IsWeapon()) then return end

			if wep.WWFP_FX then return end

			wep:AddDrawCallViewModelParticle(wep.WWFP_FX, PATTACH_POINT_FOLLOW, tonumber(wep.WWFP_ATT), true)
		end)
		return true
	end
end

function SWEP:PreDrawViewModel(...)
	BaseClass.PreDrawViewModel(self, ...)

	self:AddDrawCallViewModelParticle(self.WWFP_FX, PATTACH_POINT_FOLLOW, tonumber(self.WWFP_ATT), true)
end

function SWEP:DrawWorldModel(...)
	BaseClass.DrawWorldModel(self, ...)

	self:AddDrawCallWorldModelParticle(self.WW3P_FX, PATTACH_POINT_FOLLOW, tonumber(self.WW3P_ATT), cl_worldmodel_fx:GetBool() and !TFA.Enum.HolsterStatus[self:GetStatus()])
end

function SWEP:Deploy(...)
	local bDeploy = BaseClass.Deploy(self, ...)

	if SERVER and self.IsFirstDeploy then
		TFA.WonderWeapon.SpecialistDeploy(self, self:GetOwner(), 128)
	end

	return bDeploy
end

function SWEP:CanSecondaryAttack(...)
	if self:GetNextSecondaryFire() > CurTime() then
		return false
	end

	return BaseClass.CanPrimaryAttack(self, ...)
end

//yeah, we copy paste to change one thing
function SWEP:TriggerAttack(tableName, clipID)
	local self2 = self:GetTable()
	local ply = self:GetOwner()

	local fnname = clipID == 2 and "Secondary" or "Primary"

	if TFA.Enum.ShootReadyStatus[self:GetShootStatus()] then
		self:SetShootStatus(TFA.Enum.SHOOT_IDLE)
	end

	if self:GetStatRawL("CanBeSilenced") and (ply.KeyDown and self:KeyDown(IN_USE)) and (SERVER or not sp) and (ply.GetInfoNum and ply:GetInfoNum("cl_tfa_keys_silencer", 0) == 0) then
		local _, tanim, ttype = self:ChooseSilenceAnim(not self:GetSilenced())
		self:ScheduleStatus(TFA.Enum.STATUS_SILENCER_TOGGLE, self:GetActivityLength(tanim, true, ttype))

		return
	end

	self["SetNext" .. fnname .. "Fire"](self, self2["GetNextCorrected" .. fnname .. "Fire"](self, self2.GetFireDelay(self)))

	if self:GetMaxBurst() > 1 then
		self:SetBurstCount(math.max(1, self:GetBurstCount() + 1))
	end

	if self:GetStatL("PumpAction") and self:GetReloadLoopCancel() then return end

	self:SetStatus(TFA.Enum.STATUS_SHOOTING, self["GetNext" .. fnname .. "Fire"](self))
	self:ToggleAkimbo()
	self:IncreaseRecoilLUT()

	local ifp = IsFirstTimePredicted()

	local _, tanim, ttype = self:ChooseShootAnim(ifp)

	//ply:SetAnimation(PLAYER_ATTACK1)

	if SERVER and self:GetStatL(tableName .. ".SoundHint_Fire") then
		sound.EmitHint(bit.bor(SOUND_COMBAT, SOUND_CONTEXT_GUNFIRE), self:GetPos(), self:GetSilenced() and 500 or 1500, 0.2, self:GetOwner())
	end

	if self:GetStatL(tableName .. ".Sound") and ifp and not (sp and CLIENT) then
		if ply:IsPlayer() and self:GetStatL(tableName .. ".LoopSound") and self:ShouldEmitGunfireLoop(tableName) then
			self:EmitGunfireLoop()
		else
			local tgtSound = self:GetStatL(tableName .. ".Sound")

			if self:GetSilenced() then
				tgtSound = self:GetStatL(tableName .. ".SilencedSound", tgtSound)
			end

			if (not sp and SERVER) or not self:IsFirstPerson() then
				tgtSound = self:GetSilenced() and self:GetStatL(tableName .. ".SilencedSound_World", tgtSound) or self:GetStatL(tableName .. ".Sound_World", tgtSound)
			end

			self:EmitGunfireSound(tgtSound)
		end

		self:EmitLowAmmoSound()
	end

	self2["Take" .. fnname .. "Ammo"](self, self:GetStatL(tableName .. ".AmmoConsumption"))

	if self["Clip" .. clipID](self) == 0 and self:GetStatL(tableName .. ".ClipSize") > 0 then
		self["SetNext" .. fnname .. "Fire"](self, math.max(self["GetNext" .. fnname .. "Fire"](self), l_CT() + (self:GetStatL(tableName .. ".DryFireDelay", self:GetActivityLength(tanim, true, ttype)))))
	end

	self:ShootBulletInformation()
	self:UpdateJamFactor()
	local _, CurrentRecoil = self:CalculateConeRecoil()
	self:Recoil(CurrentRecoil, ifp)

	-- shouldn't this be not required since recoil state is completely networked?
	if sp and SERVER then
		self:CallOnClient("Recoil", "")
	end

	/*if self:GetStatL(tableName .. ".MuzzleFlashEnabled", self:GetStatL("MuzzleFlashEnabled")) and (not self:IsFirstPerson() or not self:GetStatL(tableName .. ".AutoDetectMuzzleAttachment", self:GetStatL("AutoDetectMuzzleAttachment"))) then
		self:ShootEffectsCustom()
	end*/

	self:DoAmmoCheck(clipID)

	-- Condition self:GetStatus() == TFA.Enum.STATUS_SHOOTING is always true?
	if self:GetStatus() == TFA.Enum.STATUS_SHOOTING and self:GetStatL("PumpAction") then
		if self["Clip" .. clipID](self) == 0 and self:GetStatL("PumpAction.value_empty") then
			self:SetReloadLoopCancel(true)
		elseif (self:GetStatL(tableName .. ".ClipSize") < 0 or self["Clip" .. clipID](self) > 0) and self:GetStatL("PumpAction.value") then
			self:SetReloadLoopCancel(true)
		end
	end
end

function SWEP:PrePrimaryAttack()
	local ply = self:GetOwner()
	if not IsValid(ply) then return end
	if !ply:IsPlayer() then return end
	if !self:CanPrimaryAttack() then return end

	self:SetAttackType(0)

	if !self:GetHasEmitSound() then
		self:StopSound("TFA_BO3_SKULL.Flashlight")
		self:SetHasEmitSound(true)

		if IsFirstTimePredicted() then
			local fx = EffectData()
			fx:SetStart(ply:GetShootPos())
			fx:SetNormal(self:GetOwner():EyeAngles():Forward())
			fx:SetEntity(self)
			fx:SetAttachment(self:GetMuzzleAttachment())

			TFA.Effects.Create("tfa_bo3_muzzleflash_skullgun", fx)

			self:EmitGunfireSound(self:GetStatL("Primary.Sound"))
		end
	end
end

function SWEP:HackFixCleanup()
	if not CLIENT then return end
	if not self:VMIV() then return end

	local vm = self.OwnerViewModel
	if IsValid( vm ) then
		self:StopParticles()
		vm:StopParticles()
	end
end

function SWEP:PostPrimaryAttack()
	self:SetGlowRatio(1)

	self:SetNextSecondaryFire(self:GetStatusEnd() + engine.TickInterval())

	if CLIENT then return end
	local ply = self:GetOwner()

	local angle = 1 - math.cos( math.rad( 40 ) )
	local pos = ply:GetShootPos()
	local range = self.CylinderRadius
	local array = ents.FindInSphere( pos, range )

	local rpm = self:GetStatL("Primary.RPM")
	local tick = engine.TickInterval()

	for i, ent in pairs( array ) do
		if ( sv_damage_world == nil or sv_damage_world:GetBool() ) and ( ( ent:GetCollisionGroup() == COLLISION_GROUP_BREAKABLE_GLASS ) or ( ent:GetClass() == "func_breakable" ) ) then
			local dir = ply:EyeAngles():Forward()
			local facing = ( ply:GetShootPos() - ent:GetPos() ):GetNormalized()
			if ( facing:Dot( dir ) + 1 ) / 2 > angle then continue end

			local uniqueID = ent:CreatedByMap() and ent:MapCreationID() or ent:GetCreationID()

			if not self.LastBreakableDamageTick[ uniqueID ] then
				self.LastBreakableDamageTick[ uniqueID ] = CurTime()
			end

			if self.LastBreakableDamageTick and self.LastBreakableDamageTick[ uniqueID ] and ( self.LastBreakableDamageTick[ uniqueID ] + math.Rand(0.8,1.6) > CurTime() ) then continue end

			ent:Input( "Break" )
		end

		if ent:IsNextBot() or ent:IsNPC() then
			if ent:Health() <= 0 then continue end
			if not ply:VisibleVec(ent:GetPos()) then continue end

			local dir = ply:EyeAngles():Forward()
			local facing = ( ply:GetShootPos() - ( ent.GetShootPos and ent:GetShootPos() or ent:EyePos() ) ):GetNormalized()
			if ( facing:Dot( dir ) + 1 ) / 2 > angle then continue end

			TFA.WonderWeapon.GiveStatus( ent, "BO3_Skullgun_Kill", 60/rpm + 0.1, ply, self, self:GetStatL("Primary.Damage") )
			//ent:BO3SkullStun(60/rpm + tick, ply, self)
		end
	end
end

function SWEP:PreSecondaryAttack()
	local ply = self:GetOwner()
	if not IsValid(ply) then return end
	if !ply:IsPlayer() then return end
	if !self:CanPrimaryAttack() then return end

	self:SetAttackType(1)

	if !self:GetHasEmitSound() then
		self:SetHasEmitSound(true)
		if IsFirstTimePredicted() then
			self:EmitGunfireSound("TFA_BO3_SKULL.Flashlight")

			local fx = EffectData()
			fx:SetStart(ply:GetShootPos())
			fx:SetNormal(self:GetOwner():EyeAngles():Forward())
			fx:SetEntity(self)
			fx:SetAttachment(self:GetMuzzleAttachment())

			TFA.Effects.Create("tfa_bo3_muzzleflash_skullgun_mist", fx)
		end
	end
end

function SWEP:SecondaryAttack()
	local ply = self:GetOwner()
	if not IsValid(ply) then return end

	if not IsValid(self) then return end
	if ply:IsPlayer() and not self:VMIV() then return end
	if not self:CanSecondaryAttack() then return end

	self:PreSecondaryAttack()
	if hook.Run("TFA_SecondaryAttack", self) then return end

	self:SetNextPrimaryFire(self:GetNextCorrectedPrimaryFire(self:GetFireDelay()) + engine.TickInterval())
	self:SetNextSecondaryFire(self:GetNextCorrectedPrimaryFire(self:GetFireDelay()))
	self:SetStatus(TFA.Enum.STATUS_SHOOTING, self:GetNextPrimaryFire())
	self:TakePrimaryAmmo(self:GetStatL("Primary.AmmoConsumption"))

	if (nzombies and self:Clip1() or self:Ammo1()) == 0 and self:GetStatL("Primary.ClipSize") > 0 then
		self:SetNextPrimaryFire(math.max(self:GetNextPrimaryFire(), CurTime() + (self:GetStatL("Primary.DryFireDelay", self:GetActivityLength(tanim, true)))))
	end

	self:PostSecondaryAttack()
end

function SWEP:PostSecondaryAttack()
	self:SetGlowRatio(1)

	if CLIENT then return end
	local ply = self:GetOwner()

	local angle = 1 - math.cos( math.rad(45) )
	local pos = ply:GetShootPos()
	local range = self.CylinderRadius
	local array = ents.FindInSphere( pos, range )

	local rpm = self:GetStatL("Primary.RPM")
	local tick = engine.TickInterval()
	
	for i, ent in pairs( array ) do
		if ent:IsNextBot() or ent:IsNPC() then
			if ent:Health() <= 0 then continue end
			if not ply:VisibleVec( ent:GetPos() ) then continue end

			local dir = ply:EyeAngles():Forward()
			local facing = ( ply:GetShootPos() - ( ent.GetShootPos and ent:GetShootPos() or ent:EyePos() ) ):GetNormalized()
			if ( facing:Dot( dir ) + 1 ) / 2 > angle then continue end

			TFA.WonderWeapon.GiveStatus( ent, "BO3_Skullgun_Stun", 60/rpm + 0.1 )
			//ent:BO3Mystify(60/rpm + tick)
		end
	end
end

function SWEP:Think2(...)
	local ply = self:GetOwner()

	if nzombies and ply:IsPlayer() then
		if ply:GetAmmoCount(self:GetPrimaryAmmoType()) > 0 then
			ply:SetAmmo(0, self:GetPrimaryAmmoType())
		end
	end

	local status = self:GetStatus()
	local statusend = CurTime() > self:GetStatusEnd()
	local statusratio = self:GetStatusProgress()

	if self:GetGlowRatio() > 0 and ( status ~= TFA.Enum.STATUS_SHOOTING and ( status ~= TFA.Enum.STATUS_DRAW or statusratio > 0.8 ) ) then
		self:SetGlowRatio(math.Approach(self:GetGlowRatio(), 0, FrameTime()*4))
	end

	local status = self:GetStatus()
	if self:GetHasEmitSound() and ( status ~= TFA.Enum.STATUS_SHOOTING or ( ply.KeyDown and !ply:KeyDown( self:GetAttackType() == 0 and IN_ATTACK or IN_ATTACK2 ) and statusend ) ) then
		self:SetHasEmitSound(false)

		if IsFirstTimePredicted() then
			self:HackFixCleanup()
			self:StopSound("TFA_BO3_SKULL.Flashlight")
			self:StopSoundNet("TFA_BO3_SKULL.Flashlight")
		end

		self.LastBreakableDamageTick = {}
	end

	return BaseClass.Think2(self, ...)
end

function SWEP:CycleSafety()
end

function SWEP:IsSpecial()
	return true
end

function SWEP:OnDrop(...)
	self:StopSound("TFA_BO3_SKULL.Flashlight")
	return BaseClass.OnDrop(self,...)
end

function SWEP:OwnerChanged(...)
	self:StopSound("TFA_BO3_SKULL.Flashlight")
	return BaseClass.OwnerChanged(self,...)
end

function SWEP:Holster( ... )
	self:StopSoundNet("TFA_BO3_SKULL.Flashlight")
	return BaseClass.Holster(self,...)
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
