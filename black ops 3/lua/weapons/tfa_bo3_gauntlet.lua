local nzombies = engine.ActiveGamemode() == "nzombies"
local inf_cvar = GetConVar("sv_tfa_bo3ww_inf_specialist")
local dlight_cvar = GetConVar("cl_tfa_fx_wonderweapon_dlights")
local sv_true_damage = GetConVar("sv_tfa_bo3ww_cod_damage")

SWEP.Base = "tfa_bash_base"
SWEP.Category = "TFA Wonder Weapons"
SWEP.SubCategory = "Black Ops 3"
SWEP.Spawnable = TFA_BASE_VERSION and TFA_BASE_VERSION >= 4.76
SWEP.AdminSpawnable = true
SWEP.UseHands = true
SWEP.Type_Displayed = "#tfa.weapontype.specialist"
SWEP.Author = "FlamingFox"
SWEP.Slot = 0
SWEP.PrintName = "Gauntlet of Siegfried"
SWEP.DrawCrosshair = true
SWEP.DrawCrosshairIS = false
SWEP.WWCrosshairEnabled = true
SWEP.AutoSwitchTo = false

--[Model]--
SWEP.ViewModel			= "models/weapons/tfa_bo3/gauntlet/c_gauntlet.mdl"
SWEP.ViewModel_Alt		= "models/weapons/tfa_bo3/115punch/c_115punch.mdl"
SWEP.ViewModelFOV = 65
SWEP.WorldModel			= "models/weapons/tfa_bo3/gauntlet/w_gauntlet.mdl"
SWEP.WorldModel_Alt		= "models/weapons/tfa_bo3/gauntlet/w_gauntlet.mdl"
SWEP.HoldType = "revolver"
SWEP.CameraAttachmentOffsets = {}
SWEP.CameraAttachmentScale = 1
SWEP.MuzzleAttachment = "1"
SWEP.VMPos = Vector(0, -6, -1.5)
SWEP.VMAng = Vector(0, 0, 0)
SWEP.VMPos_Additive = true

SWEP.Offset = { --Procedural world model animation, defaulted for CS:S purposes.
        Pos = {
        Up = -1,
        Right = 1,
        Forward = 4,
        },
        Ang = {
		Up = 170,
        Right = 185,
        Forward = 0
        },
		Scale = 1
}

--[Gun Related]--
SWEP.Primary.Sound = "TFA_BO3_GAUNTLET.ShootIn"
SWEP.Primary.LoopSound = "TFA_BO3_GAUNTLET.ShootLoop"
SWEP.Primary.LoopSoundTail = "TFA_BO3_GAUNTLET.ShootOut"
SWEP.Primary.Ammo = nzombies and "none" or "SpecialistCharge"
SWEP.Primary.Automatic = true
SWEP.Primary.RPM = 700
SWEP.Primary.RPM_Semi = nil
SWEP.Primary.RPM_Burst = nil
SWEP.Primary.Damage = nzombies and 115 or 20
SWEP.Primary.Knockback = 5
SWEP.Primary.NumShots = 1
SWEP.Primary.AmmoConsumption = inf_cvar:GetBool() and 0 or 1
SWEP.Primary.ClipSize = nzombies and 200 or -1
SWEP.Primary.DefaultClip = 200
SWEP.Primary.DryFireDelay = 0.5
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
SWEP.LowAmmoSoundThreshold = 0.33 --0.33
SWEP.LowAmmoSound = nil
SWEP.LastAmmoSound = nil

--[Range]--
SWEP.Primary.Range = 450
SWEP.Primary.RangeFalloff = -1
SWEP.Primary.DisplayFalloff = false
SWEP.DisplayFalloff = false

--[Recoil]--
SWEP.ViewModelPunchPitchMultiplier = 0.5 -- Default value is 0.5
SWEP.ViewModelPunchPitchMultiplier_IronSights = 0.09 -- Default value is 0.09

SWEP.ViewModelPunch_MaxVertialOffset				= 1 -- Default value is 3
SWEP.ViewModelPunch_MaxVertialOffset_IronSights		= 0.2 -- Default value is 1.95
SWEP.ViewModelPunch_VertialMultiplier				= 1 -- Default value is 1
SWEP.ViewModelPunch_VertialMultiplier_IronSights	= 0.2 -- Default value is 0.25

SWEP.ViewModelPunchYawMultiplier = 0.4 -- Default value is 0.6
SWEP.ViewModelPunchYawMultiplier_IronSights = 0.15 -- Default value is 0.25

--[Spread Related]--
SWEP.Primary.Spread		  = .04
SWEP.Primary.IronAccuracy = .03
SWEP.IronRecoilMultiplier = 0.6
SWEP.CrouchAccuracyMultiplier = 0.85

SWEP.Primary.KickUp				= 0.2
SWEP.Primary.KickDown			= 0.1
SWEP.Primary.KickHorizontal		= 0.15
SWEP.Primary.StaticRecoilFactor	= 0.5

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

--[Bash]--
SWEP.Secondary.CanBash = true
SWEP.Secondary.BashDamage = 4000
SWEP.Secondary.BashSound = Sound("TFA_BO3_GAUNTLET.ShootShort")
SWEP.Secondary.BashHitSound = Sound("TFA_BO3_GAUNTLET.Hit")
SWEP.Secondary.BashHitSound_Flesh = Sound("TFA_BO3_GAUNTLET.Hit")
SWEP.Secondary.BashLength = 55
SWEP.Secondary.BashDelay = 0.2
SWEP.Secondary.BashDamageType = bit.bor(DMG_SLASH, DMG_CLUB)
SWEP.Secondary.BashInterrupt = false

SWEP.Secondary.AmmoConsumption = inf_cvar:GetBool() and 0 or 10
SWEP.Secondary.Damage = 10

--[Misc]--
SWEP.InspectPos = Vector(8, -5, -1)
SWEP.InspectAng = Vector(20, 30, 16)
SWEP.MoveSpeed = 0.95
SWEP.IronSightsMoveSpeed = SWEP.MoveSpeed * 0.8
SWEP.SafetyPos = Vector(0, 0, -0)
SWEP.SafetyAng = Vector(-15, 15, -15)
SWEP.SmokeParticle = ""

--[NZombies]--
SWEP.NZWonderWeapon = false
SWEP.NZSpecialCategory = "specialist"
SWEP.NZSpecialWeaponData = {MaxAmmo = 0, AmmoType = "none"}
SWEP.NZHudIcon = Material("vgui/icon/uie_t7_zm_dragon_gauntlet_ammo_icon_gun_ready.png", "unlitgeneric smooth")
SWEP.NZHudIcon_t7 = Material("vgui/icon/uie_t7_zm_dragon_gauntlet_ammo_icon_gun_ready_t7.png", "unlitgeneric smooth")
SWEP.NZHudIcon_t7flash = Material("vgui/icon/uie_t7_zm_dragon_gauntlet_ammo_icon_gun_readyflash.png", "unlitgeneric smooth")

SWEP.AmmoRegen = 2

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
},
[ACT_VM_HOLSTER] = {
{ ["time"] = 2 / 30, ["type"] = "sound", ["value"] = Sound("weapon_bo3_cloth.short") },
{ ["time"] = 5 / 30, ["type"] = "sound", ["value"] = Sound("weapon_bo3_gear.rattle") },
},
[ACT_VM_DRAW_DEPLOYED] = {
{ ["time"] = 0, ["type"] = "sound", ["value"] = Sound("TFA_BO3_GAUNTLET.Shake") },
{ ["time"] = 25 / 30, ["type"] = "sound", ["value"] = Sound("TFA_BO3_GAUNTLET.Attach") },
},
[ACT_VM_DETACH_SILENCER] = {
{ ["time"] = 15 / 30, ["type"] = "sound", ["value"] = Sound("TFA_BO3_GAUNTLET.Attach") },
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
[1] = {atts = {"bo3_115punch_att"}, order = 1, hidden = true},
}

SWEP.WElements = {
	["armthingy"] = { type = "Model", model = "models/weapons/tfa_bo3/gauntlet/w_gauntlet_elbow.mdl", bone = "ValveBiped.Bip01_R_Forearm", rel = "", pos = Vector(1, 1, 1), angle = Angle(-5, 10, 10), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bonemerge = false, active = true, bodygroup = {} },
}

SWEP.WorldModelBoneMods = {
	["tag_dragon_world"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
}

SWEP.StatCache_Blacklist = {
	["Secondary.BashDelay"] = true,
	["HoldType"] = true,
	["InspectPos"] = true,
	["InspectAng"] = true,
}

SWEP.FlameSize = Vector(1,1,1)
SWEP.FlameDistance = 24

SWEP.up_hat = true
SWEP.BO3CanDash = true
SWEP.BO3DashMult = 1

DEFINE_BASECLASS( SWEP.Base )

local MASK_SHOT = MASK_SHOT
local CONTENTS_SLIME = CONTENTS_SLIME
local CONTENTS_LIQUID = bit.bor( CONTENTS_WATER, CONTENTS_SLIME )

local sp = game.SinglePlayer()

function SWEP:SetupDataTables()
	BaseClass.SetupDataTables(self)

	self:NetworkVarTFA("Bool", "Dashing")
	self:NetworkVarTFA("Bool", "HasEmitSound")
end

function SWEP:CycleSafety()
end

function SWEP:PreDrawViewModel(...)
	BaseClass.PreDrawViewModel(self, ...)

	if self.OwnerViewModel and IsValid(self.OwnerViewModel) and dlight_cvar:GetBool() and DynamicLight then
		self.DLight = self.DLight or DynamicLight(self.OwnerViewModel:EntIndex())
		if self.DLight then
			local attpos = self.OwnerViewModel:GetAttachment(2)

			if (attpos and attpos.Pos) then
				self.DLight.pos = attpos.Pos + attpos.Ang:Up()*9
				self.DLight.dir = attpos.Ang:Forward()
				self.DLight.r = 45
				self.DLight.g = 255
				self.DLight.b = 45
				self.DLight.decay = 1000
				self.DLight.brightness = 0.5
				self.DLight.size = 40
				self.DLight.dietime = CurTime() + 1
			end
		end
	end
end

function SWEP:DrawWorldModel(...)
	BaseClass.DrawWorldModel(self, ...)

	if dlight_cvar:GetInt() == 1 and DynamicLight then
		self.DLight = self.DLight or DynamicLight(self:EntIndex(), false)
		if self.DLight then
			local attpos = self:GetAttachment(1)

			if (attpos and attpos.Pos) then
				self.DLight.pos = attpos.Pos
				self.DLight.dir = attpos.Ang:Forward()
				self.DLight.r = 45
				self.DLight.g = 255
				self.DLight.b = 45
				self.DLight.decay = 2000
				self.DLight.brightness = 1
				self.DLight.size = 64
				self.DLight.dietime = CurTime() + 0.5
			end
		end
	end
end

function SWEP:Deploy(...)
	local bDeploy = BaseClass.Deploy(self, ...)

	if SERVER and self.IsFirstDeploy then
		TFA.WonderWeapon.SpecialistDeploy(self, self:GetOwner(), 128)
	end

	return bDeploy
end

function SWEP:AdjustMouseSensitivity()
	if self:GetDashing() then
		return 0.25
	end

	if self:GetStatus() == TFA.Enum.STATUS_BASHING_WAIT then
		return math.max(0.25, self:GetStatusProgress())
	end
end

function SWEP:AttachWaveGun()
	self.ViewModelKitOld = self.ViewModelKitOld or self.ViewModel
	self.WorldModelKitOld = self.WorldModelKitOld or self.WorldModel
	self.ViewModel = self:GetStat("ViewModel_Alt") or self.ViewModel
	self.WorldModel = self:GetStat("WorldModel_Alt") or self.WorldModel
	if IsValid(self.OwnerViewModel) then
		self.OwnerViewModel:SetModel(self.ViewModel)
		timer.Simple(0, function()
			self:SendViewModelAnim(ACT_VM_DRAW)
		end)
	end

	self:SetSilenced(false) --inverted for some reason
	self.Silenced = self:GetSilenced()

	self.Secondary_TFA.BashDelay = 0.65
	self.BO3DashMult = 2

	self.up_hat = false
	self.HoldType = "fist"
	self.PrintName = "115 Punch"

	self.InspectPos = Vector(0, -1, -1)
	self.InspectAng = Vector(15, 0, 0)

	self.WorldModelBoneMods["tag_dragon_world"].scale = Vector(0,0,0)

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

	self:SetSilenced(true) --inverted for some reason
	self.Silenced = self:GetSilenced()

	self.Secondary_TFA.BashDelay = 0.2
	self.BO3DashMult = 1
	
	self.up_hat = true
	self.HoldType = "pistol"
	self.PrintName = "Gauntlet of Siegfried"

	self.InspectPos = Vector(8, -5, -1)
	self.InspectAng = Vector(20, 30, 16)

	self.WorldModelBoneMods["tag_dragon_world"].scale = Vector(1,1,1)

	local _, tanim, ttype = self:PlayAnimation(self:GetStat("BaseAnimations.silencer_detach"))

	self:ScheduleStatus(TFA.Enum.STATUS_SILENCER_TOGGLE, self:GetActivityLength(tanim))
	self:SetNextPrimaryFire(self.GetNextCorrectedPrimaryFire(self, self:GetActivityLength(tanim, true)+0.1))
end

function SWEP:PrePrimaryAttack()
	local ply = self:GetOwner()
	if not IsValid(ply) then return end
	if !ply:IsPlayer() then return end
	if self:GetSilenced() then return end

	if self:CanPrimaryAttack() and !self:GetHasEmitSound() then
		self:SetHasEmitSound(true)
		if IsFirstTimePredicted() then
			local fx = EffectData()
			fx:SetStart(ply:GetShootPos())
			fx:SetNormal(self:GetOwner():EyeAngles():Forward())
			fx:SetEntity(self)
			fx:SetAttachment(self:GetMuzzleAttachment())

			TFA.Effects.Create("tfa_bo3_muzzleflash_gauntlet", fx)

			self:EmitGunfireSound(self:GetStatL("Primary.Sound"))
		end
	end
end

function SWEP:PostPrimaryAttack()
	if CLIENT then return end

	local ply = self:GetOwner()
	local aim = self:GetAimVector()
	if not IsValid(ply) then return end

	local plyInWater = ply:WaterLevel() > 2

	local n_range_squared = self:GetStatL("Primary.Range")*self:GetStatL("Primary.Range")
	local n_range_inner_squared = n_range_squared*0.5

	local start_pos = ply:GetShootPos()
	local aim_vec = ply:IsPlayer() and self:GetAimVector() or ply:GetAimVector()

	local hitMask = plyInWater and bit.bor( MASK_SHOT, CONTENTS_GRATE ) or bit.bor( MASK_SHOT, CONTENTS_GRATE, CONTENTS_LIQUID )

	local hitTrace = util.TraceLine({
		start = start_pos,
		endpos = start_pos + (aim_vec*self:GetStatL("Primary.Range")),
		filter = {ply, self},
		mask = hitMask,
	})

	local suicide = util.TraceLine({
		start = start_pos,
		endpos = start_pos + (aim_vec*self:GetStatL("Primary.Range")) - vector_up*(12*hitTrace.Fraction),
		filter = {ply, self},
		mask = hitMask,
	})

	local end_pos = hitTrace.HitPos
	local hitEntity = suicide.Entity
	local hitCharacter = ( hitEntity:IsNPC() or hitEntity:IsNextBot() or hitEntity:IsPlayer() or hitEntity:IsRagdoll() )

	if suicide.Hit and not hitCharacter then
		timer.Simple( 0.25 * suicide.Fraction, function()
			ParticleEffect( plyInWater and "bo3_uwater_splash" or "bo3_gauntlet_impact", suicide.HitPos, suicide.HitNormal:Angle() )
			if bit.band( util.PointContents( suicide.HitPos ), CONTENTS_LIQUID ) == 0 then
				util.Decal( "Dark", suicide.HitPos, suicide.HitPos + suicide.Normal * 4, self )
			end
		end )
	end

	local tr = {
		filter = {ply, self},
		mask = MASK_SHOT,
	}

	for i, ent in pairs( ents.FindAlongRay( start_pos, end_pos, self.FlameSizeMin, self.FlameSize ) ) do
		if ent ~= ply and TFA.WonderWeapon.ShouldDamage(ent, ply, self) then
			local test_origin = ent:WorldSpaceCenter()
			local radial_origin = TFA.WonderWeapon.PointOnSegmentNearestToPoint(start_pos, end_pos, test_origin )

			local bEntUnderwater = ent:WaterLevel() > 2

			local bIsUnderwater = bit.band(util.PointContents(radial_origin), CONTENTS_LIQUID) ~= 0
			if ( bIsUnderwater and not bEntUnderwater ) or ( not bIsUnderwater and bEntUnderwater ) then
				continue
			end

			tr.start = radial_origin
			tr.endpos = test_origin

			local trace = util.TraceLine(tr)
			local trace2 = {}

			if TFA.WonderWeapon.FindHullIntersection(ent, trace, trace2) then
				local ratio = 1 - math.Clamp((n_range_squared - n_range_squared + n_range_inner_squared) / n_range_inner_squared, 0, 0.5)
				self:InflictDamage(ent, ratio, radial_origin, trace2.HitPos)
			end
		end
	end
end

function SWEP:PrimaryAttack()
	if self:GetSilenced() then
		self:AltAttack()
		return
	end

	return BaseClass.PrimaryAttack(self)
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
		self:CallOnClient("Recoil")
	end

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

function SWEP:SecondaryAttack()
	local self2 = self:GetTable()
	local ply = self:GetOwner()
	if not IsValid(ply) then return end
	if not self:CanPrimaryAttack() and not self:GetSilenced() then return end
	if not TFA.Enum.ReadyStatus[self:GetStatus()] or self:GetSprinting() then return end

	local _, tanim = self:ChooseSilenceAnim(not self:GetSilenced())
	self:ScheduleStatus(TFA.Enum.STATUS_SILENCER_TOGGLE, self:GetActivityLength(tanim, true))
	self:SetNextPrimaryFire(self2.GetNextCorrectedPrimaryFire(self, self:GetActivityLength(tanim, true)+0.1))
end

function SWEP:AltAttack()
	local ply = self:GetOwner()
	if not IsValid(ply) then return end
	if not self:CanPrimaryAttack() then return end
	if not ply:IsOnGround() then return end
	if not TFA.Enum.ReadyStatus[self:GetStatus()] or self:GetSprinting() then return end
	if nzombies and not self:GetOwner():GetNotDowned() then return end

	self:TakePrimaryAmmo(self:GetStatL("Secondary.AmmoConsumption"))
	if self:GetSilenced() and self:VMIV() then
		if IsFirstTimePredicted() then
			ParticleEffectAttach("bo3_gauntlet_dash", PATTACH_POINT_FOLLOW, self.OwnerViewModel, 6)
		end
	end
	self:SetDashing(true)

	return BaseClass.AltAttack(self)
end

function SWEP:Think2(...)
	local ply = self:GetOwner()
	local status = self:GetStatus()
	local statusend = CurTime() >= self:GetStatusEnd()

	if nzombies and ply:IsPlayer() and ply:GetAmmoCount(self:GetPrimaryAmmoType()) > 0 then
		ply:SetAmmo(0, self:GetPrimaryAmmoType())
	end

	if self:GetHasEmitSound() and status ~= TFA.Enum.STATUS_SHOOTING then
		self:SetHasEmitSound(false)
	end

	if status == TFA.Enum.STATUS_SILENCER_TOGGLE then
		if not self.up_hat and self:GetSilenced() then
			self:DetachWaveGun()
			if sp and SERVER then
				self:CallOnClient("DetachWaveGun")
			end
		end
		if CurTime() > self:GetStatusEnd() and not self:GetSilenced() then
			self:AttachWaveGun()
			if sp and SERVER then
				self:CallOnClient("AttachWaveGun")
			end
		end
	end

	if status == TFA.Enum.STATUS_BASHING then
		if self:GetSilenced() then
			self:DoRadiusDamage()
		end
		if statusend then
			self:SetDashing(false)
		end
	end

	if status == TFA.Enum.STATUS_BASHING_WAIT then
		if self:GetSilenced() then
			self:DoRadiusDamage()
		end
	end

	return BaseClass.Think2(self, ...)
end

function SWEP:DoRadiusDamage()
	if CLIENT then return end

	local ply = self:GetOwner()
	if not IsValid(ply) then return end

	local vecSrc = ply:GetShootPos()

	local ply = self:GetOwner()

	local naerbyEnts = ents.FindInSphere(ply:GetShootPos(), 48)

	local tr = {
		start = vecSrc,
		filter = { self, ply },
		mask = MASK_SHOT,
		collsiongroup = COLLISION_GROUP_NONE,
	}

	local damageinfo = DamageInfo()
	damageinfo:SetAttacker(ply)
	damageinfo:SetInflictor(self)
	damageinfo:SetDamageType(DMG_DIRECT)
	damageinfo:SetReportedPosition(vecSrc)

	for _, ent in RandomPairs(naerbyEnts) do
		if ent == ply or ent:IsWeapon() or !ent:IsSolid() then continue end
		if !TFA.WonderWeapon.ShouldDamage(ent, ply, self) then continue end

		if ent.LastDashAttackHurt and ent.LastDashAttackHurt[self:GetCreationID()] and (ent.LastDashAttackHurt[self:GetCreationID()] + 0.2 > CurTime()) then continue end

		local vecSpot = TFA.WonderWeapon.BodyTarget(ent, vecSrc, true)

		local dir = ( vecSpot - vecSrc ):GetNormalized()

		tr.endpos = vecSpot

		local trace = util.TraceLine(tr)

		damageinfo:SetDamageForce( ent:GetUp() * math.random(12000,16000) + dir * math.random(14000,16000) )
		damageinfo:SetDamagePosition( trace.Entity == ent and trace.HitPos or vecSpot )

		local isCharacter = ( ent:IsNPC() or ent:IsNextBot() or ent:IsPlayer() )
		damageinfo:SetDamage(isCharacter and ( ( sv_true_damage and sv_true_damage:GetBool() or nzombies ) and ent:Health() + 666 or self:GetStatL("Secondary.Damage") ) or 20)

		if !isCharacter and !ent:IsVehicle() and ent.GetPhysicsObject then
			damageinfo:SetDamage(ent:Health() + 666)
		end

		if nzombies and (ent.NZBossType or ent.IsMooBossZombie or ent.IsMooMiniBoss) then
			damageinfo:SetDamage(math.max(100, ent:GetMaxHealth() / 40))
		end

		if not ent.LastDashAttackHurt then ent.LastDashAttackHurt = {} end
		ent.LastDashAttackHurt[self:GetCreationID()] = CurTime()

		if trace.Entity == ent then
			trace.HitGroup = trace.HitGroup == HITGROUP_HEAD and HITGROUP_HEAD or HITGROUP_GENERIC

			local hitInWater = bit.band( util.PointContents( trace.HitPos ), CONTENTS_LIQUID ) ~= 0
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
				data:SetFlags( bit.band( trace2.Contents, CONTENTS_SLIME ) != 0 && 1 || 0 )

				util.Effect( "watersplash", data, false, true )
			end

			ent:DispatchTraceAttack( damageinfo, trace, dir )
		else
			ent:TakeDamageInfo( damageinfo )
		end

		if ply:IsPlayer() then
			self:SendHitMarker(ply, trace, damageinfo)
		end
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
	damage:SetDamageType(bit.bor(DMG_BULLET, TFA.WonderWeapon.GetBurnDamage( ent )))
	damage:SetAttacker(self:GetOwner())
	damage:SetInflictor(self)
	damage:SetDamage(mydamage*self:GetStatL("Primary.NumShots"))
	damage:SetDamagePosition(hitpos)
	damage:SetDamageForce((hitpos - pos):GetNormalized())
	damage:SetReportedPosition(self:GetOwner():GetShootPos())

	if nzombies and (ent.NZBossType or ent.IsMooBossZombie) then
		damage:SetDamage(math.max((60*ratio), ent:GetMaxHealth() / 120))
	end

	local ply = self:GetOwner()
	if !nzombies and ent:WaterLevel() < 2 then
		ent:Ignite(4*ratio)
	end

	ent:TakeDamageInfo(damage)

	local trace = {["Entity"] = ent, ["Hit"] = true, ["HitPos"] = hitpos or ent:WorldSpaceCenter()}
	self:SendHitMarker(self:GetOwner(), trace, damage)

	if ent:WaterLevel() > 1 then
		ent:Extinguish()
	end
end

function SWEP:ShootBulletInformation()
end

function SWEP:Holster(...)
	if self:GetDashing() then
		return false
	end
	return BaseClass.Holster(self, ...)
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

function SWEP:DrawHUDBackground() //copy pasting entire fuctions for a single line change B)
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