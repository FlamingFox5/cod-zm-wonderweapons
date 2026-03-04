local nzombies = engine.ActiveGamemode() == "nzombies"
local inf_cvar = GetConVar("sv_tfa_bo3ww_inf_specialist")
local dlight_cvar = GetConVar("cl_tfa_fx_wonderweapon_dlights")

SWEP.Base = "tfa_gun_base"
SWEP.Category = "TFA Wonder Weapons"
SWEP.SubCategory = "Black Ops 4"
SWEP.Spawnable = TFA_BASE_VERSION and TFA_BASE_VERSION >= 4.76
SWEP.AdminSpawnable = true
SWEP.UseHands = true
SWEP.Type_Displayed = "#tfa.weapontype.specialist"
SWEP.Purpose = "Inspired by designs of the DG-4 and perfected in Richtofen's Lab, the Ragnarok DG-5 converts trace quantities of Element 115 into reckless amounts of electricity."
SWEP.Author = "FlamingFox"
SWEP.Slot = 0
SWEP.PrintName = nzombies and "Ragnarok DG-5 | BO4" or "Ragnarok DG-5"
SWEP.DrawCrosshair = false
SWEP.DrawCrosshairIronSights = false
SWEP.AutoSwitchTo = false

--[Model]--
SWEP.ViewModel			= "models/weapons/tfa_bo4/dg5/c_dg5.mdl"
SWEP.ViewModelFOV = 65
SWEP.WorldModel			= "models/weapons/tfa_bo4/dg5/w_dg5.mdl"
SWEP.HoldType = "duel"
SWEP.CameraAttachmentOffsets = {}
SWEP.CameraAttachmentScale = 2
SWEP.MuzzleAttachment = "1"
SWEP.VMPos = Vector(0, 0, 0)
SWEP.VMAng = Vector(0, 0, 0)
SWEP.VMPos_Additive = true

SWEP.Offset = { --Procedural world model animation, defaulted for CS:S purposes.
        Pos = {
        Up = 0,
        Right = 1,
        Forward = 3.5,
        },
        Ang = {
		Up = 90,
        Right = 180,
        Forward = 0
        },
		Scale = 1
}

--[Gun Related]--
SWEP.Primary.Sound = nil
SWEP.Primary.Ammo = nzombies and "none" or "AlyxGun"
SWEP.Primary.Automatic = false
SWEP.Primary.RPM = 90
SWEP.Primary.Damage = 115
SWEP.Primary.NumShots = 1
SWEP.Primary.AmmoConsumption = inf_cvar:GetBool() and 0 or 5
SWEP.Primary.AmmoRegen = 1
SWEP.Primary.Knockback = 0
SWEP.Primary.ClipSize = nzombies and 100 or -1
SWEP.Primary.DefaultClip = 100
SWEP.Primary.Delay = 0.35
SWEP.Secondary.AmmoConsumption = inf_cvar:GetBool() and 0 or 10
SWEP.MuzzleFlashEffect = "tfa_bo3_muzzleflash_dg4"
SWEP.DisableChambering = true
SWEP.FiresUnderwater = false
SWEP.Delay = 0.1

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

SWEP.ViewModelPunch_MaxVertialOffset				= 2 -- Default value is 3
SWEP.ViewModelPunch_MaxVertialOffset_IronSights		= 1.95 -- Default value is 1.95
SWEP.ViewModelPunch_VertialMultiplier				= 1 -- Default value is 1
SWEP.ViewModelPunch_VertialMultiplier_IronSights	= 0.25 -- Default value is 0.25

SWEP.ViewModelPunchYawMultiplier = 0.6 -- Default value is 0.6
SWEP.ViewModelPunchYawMultiplier_IronSights = 0.25 -- Default value is 0.25

--[Spread Related]--
SWEP.Primary.Spread		  = .04
SWEP.Primary.IronAccuracy = .08
SWEP.IronRecoilMultiplier = 0.7
SWEP.CrouchAccuracyMultiplier = 0.85

SWEP.Primary.KickUp				= 1.0
SWEP.Primary.KickDown			= 1.0
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
SWEP.LuaShellScale = 1
SWEP.LuaShellEjectDelay = 0
SWEP.ShellAttachment = "0"
SWEP.EjectionSmokeEnabled = false

--[Misc]--
SWEP.InspectPos = Vector(0, 0, 1.5)
SWEP.InspectAng = Vector(10, 0, 0)
SWEP.MoveSpeed = 0.975
SWEP.IronSightsMoveSpeed  = SWEP.MoveSpeed * 0.8
SWEP.SafetyPos = Vector(1, -2, -0.5)
SWEP.SafetyAng = Vector(-20, 35, -25)
SWEP.SmokeParticle = ""

--[NZombies]--
SWEP.NZWonderWeapon = false
SWEP.NZSpecialCategory = "specialist"
SWEP.NZSpecialWeaponData = {MaxAmmo = 0, AmmoType = "none"}

SWEP.NZSpecialistResistanceData = {
	Types = bit.bor(DMG_SHOCK, DMG_SONIC, DMG_PLASMA, DMG_ENERGYBEAM, DMG_DISSOLVE, DMG_PARALYZE, DMG_VEHICLE),
	Percent = 0.9, // 0 - 1, 1 being 100% reduction
	MinimumDamage = 10,
}

SWEP.NZHudIcon = Material("vgui/icon/ui_icon_equipment_zm_gravityspikes_lv3_dark.png", "unlitgeneric smooth")
SWEP.NZHudIcon_t7 = Material("vgui/icon/t7_hud_zm_hud_ammo_icon_spike_ready_t7.png", "unlitgeneric smooth")
SWEP.NZHudIcon_t7flash = Material("vgui/icon/t7_hud_zm_hud_ammo_icon_spike_readyflash.png", "unlitgeneric smooth")

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
SWEP.SequenceRateOverride = {
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
{ ["time"] = 0, ["type"] = "sound", ["value"] = Sound("TFA_BO4_DG5.Raise") },
{ ["time"] = 0, ["type"] = "lua", value = function(self) self:CleanParticles() end, client = true, server = true},
},
[ACT_VM_DRAW] = {
{ ["time"] = 0, ["type"] = "sound", ["value"] = Sound("TFA_BO3_DG4.Draw") },
{ ["time"] = 0, ["type"] = "lua", value = function(self) self:CleanParticles() end, client = true, server = true},
},
[ACT_VM_HOLSTER] = {
{ ["time"] = 0, ["type"] = "sound", ["value"] = Sound("TFA_BO3_JGB.Stop") },
{ ["time"] = 5 / 30, ["type"] = "lua", value = function(self) self:CleanParticles() end, client = true, server = true},
},
[ACT_VM_PULLPIN] = {
{ ["time"] = 0, ["type"] = "sound", ["value"] = Sound("TFA_BO4_DG5.Activate") },
},
[ACT_VM_DEPLOY] = {
{ ["time"] = 10 / 30, ["type"] = "sound", ["value"] = Sound("TFA_BO4_DG5.Strike") },
},
[ACT_VM_HITCENTER] = {
{ ["time"] = 0, ["type"] = "sound", ["value"] = Sound("TFA_BO4_DG5.Clap") },
{ ["time"] = 5 / 30, ["type"] = "sound", ["value"] = Sound("TFA_BO4_DG5.SparkLoop") },
{ ["time"] = 10 / 30, ["type"] = "lua", ["value"] = function(self) self:AOEShock() end, client = true, server = true},
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

SWEP.WElements = {
	["dg5_dw"] = { type = "Model", model = "models/weapons/tfa_bo4/dg5/w_dg5.mdl", bone = "ValveBiped.Bip01_L_Hand", rel = "", pos = Vector(3, 1.2, 0), angle = Angle(0, 90, 0), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bonemerge = false, active = true, bodygroup = {} },
}

SWEP.Callback = {}
SWEP.BO3CanSlam = true
SWEP.DG4SlamFwd = 400
SWEP.DG4SlamUp = Vector(0,0,150)
SWEP.fakekills = 0

SWEP.WWFP_FX = "bo4_dg5_vm"
SWEP.WWFP_ATT = 3
SWEP.WWFP_ATTb = 4
SWEP.WWFP_ATTc = 5
SWEP.WWFP_ATTd = 6

SWEP.WW3P_FX = "bo4_dg5_3p"
SWEP.WW3P_ATT = 5
SWEP.WW3P_ATTb = 6

--[Coding]--
DEFINE_BASECLASS( SWEP.Base )

local CurTime = CurTime
local sp = game.SinglePlayer()
local pvp_bool = GetConVar("sbox_playershurtplayers")
local tpfx_cvar = GetConVar("cl_tfa_fx_wonderweapon_3p")
local developer = GetConVar("developer")

function SWEP:SetupDataTables()
	BaseClass.SetupDataTables(self)

	self:NetworkVarTFA("Bool", "DG4Slamming")
	self:NetworkVarTFA("Bool", "HasNuked")

	self:NetworkVarTFA("Vector", "SlamNormal")

	self:NetworkVarTFA("Bool", "Sparking")
	self:NetworkVarTFA("Float", "SparkTime")
end

function SWEP:WalkBob(pos, ang, ...)
	if self:GetDG4Slamming() then
		return pos, ang
	end

	return BaseClass.WalkBob(self, pos, ang, ...)
end

function SWEP:Deploy(...)
	local bDeploy = BaseClass.Deploy(self, ...)

	if SERVER and self.IsFirstDeploy then
		TFA.WonderWeapon.SpecialistDeploy(self, self:GetOwner(), 128)
	end

	return bDeploy
end

function SWEP:PreDrawViewModel(vm, ...)
	BaseClass.PreDrawViewModel(self, vm, ...)

	if not TFA.Enum.HolsterStatus[self:GetStatus()] then
		self:AddDrawCallViewModelParticle(self.WWFP_FX, PATTACH_POINT_FOLLOW, tonumber(self.WWFP_ATT), true)
		self:AddDrawCallViewModelParticle(self.WWFP_FX, PATTACH_POINT_FOLLOW, tonumber(self.WWFP_ATTb), true)
		self:AddDrawCallViewModelParticle(self.WWFP_FX, PATTACH_POINT_FOLLOW, tonumber(self.WWFP_ATTc), true)
		self:AddDrawCallViewModelParticle(self.WWFP_FX, PATTACH_POINT_FOLLOW, tonumber(self.WWFP_ATTd), true)
	end

	self:AddDrawCallViewModelParticle("bo4_dg5_vm_charged", PATTACH_POINT_FOLLOW, 7, self:GetSparking())
	self:AddDrawCallViewModelParticle("bo4_dg5_vm_charged", PATTACH_POINT_FOLLOW, 8, self:GetSparking())

	if self.OwnerViewModel and IsValid(self.OwnerViewModel) and dlight_cvar:GetBool() and DynamicLight then
		self.DLight = self.DLight or DynamicLight(self.OwnerViewModel:EntIndex(), false)
		if self.DLight then
			self.DLight.pos = self:GetOwner():GetShootPos()
			self.DLight.r = 45
			self.DLight.g = 165
			self.DLight.b = 255
			self.DLight.decay = 2000
			self.DLight.brightness = self:GetSparking() and 4 or 1
			self.DLight.size = 128
			self.DLight.dietime = CurTime() + 0.5
		end
	end
end

function SWEP:DrawWorldModel(...)
	BaseClass.DrawWorldModel(self, ...)

	self:AddDrawCallWorldModelParticle(self.WW3P_FX, PATTACH_POINT_FOLLOW, tonumber(self.WW3P_ATT), tpfx_cvar:GetBool() and not TFA.Enum.HolsterStatus[self:GetStatus()])
	self:AddDrawCallWorldModelParticle(self.WW3P_FX, PATTACH_POINT_FOLLOW, tonumber(self.WW3P_ATTb), tpfx_cvar:GetBool() and not TFA.Enum.HolsterStatus[self:GetStatus()])

	self:AddDrawCallWorldModelElementParticle("dg5_dw", self.WW3P_FX, PATTACH_POINT_FOLLOW, tonumber(self.WW3P_ATT), tpfx_cvar:GetBool() and not TFA.Enum.HolsterStatus[self:GetStatus()], "dg5_dw")
	self:AddDrawCallWorldModelElementParticle("dg5_dw", self.WW3P_FX, PATTACH_POINT_FOLLOW, tonumber(self.WW3P_ATTb), tpfx_cvar:GetBool() and not TFA.Enum.HolsterStatus[self:GetStatus()], "dg5_dwb")

	if dlight_cvar:GetBool() and DynamicLight then
		self.DLight = self.DLight or DynamicLight(self:EntIndex(), false)

		local pos = self:GetPos()
		local ply = self:GetOwner()
		if IsValid( ply ) and ply.GetShootPos then
			pos = ply:GetShootPos()
		end

		if self.DLight then
			self.DLight.pos = pos
			self.DLight.r = 45
			self.DLight.g = 165
			self.DLight.b = 255
			self.DLight.decay = 2000
			self.DLight.brightness = self:GetSparking() and 4 or 0
			self.DLight.size = 128
			self.DLight.dietime = CurTime() + 0.5
		end
	end
end

function SWEP:ChoosePullAnim()
	if not self:OwnerIsValid() then return end

	if self.Callback.ChoosePullAnim then
		self.Callback.ChoosePullAnim(self)
	end

	if self:GetOwner():IsPlayer() then
		self:GetOwner():SetAnimation(PLAYER_JUMP)
	end

	self:SendViewModelAnim(ACT_VM_PULLPIN)

	if sp then
		self:CallOnClient("AnimForce", ACT_VM_PULLPIN)
	end

	return true, ACT_VM_PULLPIN
end

function SWEP:ChooseShootAnim()
	if not self:OwnerIsValid() then return end

	if self.Callback.ChooseShootAnim then
		self.Callback.ChooseShootAnim(self)
	end

	if self:GetOwner():IsPlayer() then
		self:GetOwner():SetAnimation(PLAYER_ATTACK1)
	end

	local tanim = ACT_VM_THROW
	self:SendViewModelAnim(tanim)

	if sp then
		self:CallOnClient("AnimForce", tanim)
	end

	return true, tanim
end

function SWEP:ThrowStart()
	local ply = self:GetOwner()
	local success, tanim, animType = self:ChooseShootAnim()
	local range = 200

	self:ScheduleStatus(TFA.Enum.STATUS_GRENADE_THROW, self.Delay)

	self:ShootEffectsCustom()
	local qtr = util.QuickTrace(self:GetPos(), Vector(0,0,-32), {ply, self})
	util.Decal("Scorch", qtr.HitPos - qtr.HitNormal, qtr.HitPos + qtr.HitNormal)

	if self:GetSparking() then
		range = 350
		self:SetSparkTime(CurTime() + 0.25)
	end

	if SERVER then
		local tr = {
			start = self:GetPos(),
			filter = {self, ply},
			mask = MASK_SHOT
		}

		local damage = DamageInfo()
		damage:SetAttacker(ply)
		damage:SetInflictor(self)
		damage:SetDamageType(DMG_ENERGYBEAM)
		damage:SetReportedPosition(ply:GetShootPos())

		for k, v in pairs(ents.FindInSphere(ply:GetShootPos(), range)) do
			if not v:IsWorld() and v:IsSolid() then
				if v == ply then continue end
				if !TFA.WonderWeapon.ShouldDamage(v, ply, self) then continue end

				tr.endpos = v:WorldSpaceCenter()
				local tr1 = util.TraceLine(tr)
				if tr1.HitWorld then continue end

				local hitpos = tr1.Entity == v and tr1.HitPos or tr.endpos

				damage:SetDamage(nzombies and v:Health() or self:GetStat("Primary.Damage"))
				damage:SetDamageForce(v:GetUp()*20000 + (v:GetPos() - ply:GetPos()):GetNormalized() * 15000)
				damage:SetDamagePosition(hitpos)

				if nzombies and (v.NZBossType or v.IsMooBossZombie or v.IsMooMiniBoss) then
					damage:SetDamage(math.max(1000, v:GetMaxHealth() / 8))
					damage:ScaleDamage(math.Round(nzRound:GetNumber()/12))
				end

				if damage:GetDamage() >= v:Health() then
					v:SetNW2Bool("DG4Killed", true)
				end

				if v:IsNPC() and v:HasCondition(COND.NPC_FREEZE) then
					v:SetCondition(COND.NPC_UNFREEZE)
				end

				v:TakeDamageInfo(damage)

				if (v:IsNPC() or v:IsPlayer() or v:IsNextBot()) then
					local trace = {["Entity"] = v, ["Hit"] = true, ["HitPos"] = hitpos}
					self:SendHitMarker(ply, trace, damage)
				end
			end
		end

		util.ScreenShake(ply:GetPos(), 7, 255, 1, range*1.5)
	end

	//if IsFirstTimePredicted() then
		self:EmitGunfireSound("TFA_BO4_DG5.Reverb")
		self:EmitGunfireSound("TFA_BO4_DG5.Impact")
		self:EmitGunfireSound("TFA_BO4_DG5.Strike")
	//end

	if success then
		self.LastNadeAnim = tanim
		self.LastNadeAnimType = animType
		self.LastNadeDelay = self.Delay
	end
end

function SWEP:PrimaryAttack()
	local self2 = self:GetTable()
	local ply = self:GetOwner()
	if not IsValid(ply) then return end

	if not IsValid(self) then return end
	if ply:IsPlayer() and not self:VMIV() then return end
	if not self:CanPrimaryAttack() then return end
	if nzombies and not ply:GetNotDowned() then return end

	local _, tanim = self:ChoosePullAnim()

	self:ScheduleStatus(TFA.Enum.STATUS_GRENADE_PULL, self:GetActivityLength(tanim))
	self:TakePrimaryAmmo(self:GetStatL("Primary.AmmoConsumption"))

	local ang = self:GetAimVector():Angle()
	local fwd = Angle(0,ang.yaw,ang.roll):Forward()

	if SERVER then
		if not ply:IsPlayer() then
			ply:EmitSound("TFA_BO3_DG4.Activate")
			ply:SetLocalVelocity(fwd*1000 + Vector(0,0,250))
		end
	end

	self:KillInSphere(60)
	self:SetSlamNormal(fwd)
	self:SetDG4Slamming(true)
end

function SWEP:Think2(...)
	if not self:OwnerIsValid() then return end

	local stat = self:GetStatus()
	local statusend = CurTime() >= self:GetStatusEnd()
	local ply = self:GetOwner()

	if nzombies and ply:IsPlayer() then
		if ply:GetAmmoCount(self:GetPrimaryAmmoType()) > 0 then
			ply:SetAmmo(0, self:GetPrimaryAmmoType())
		end
	end

	if stat == TFA.Enum.STATUS_GRENADE_PULL then
		if statusend then
			self:SetStatus(TFA.Enum.STATUS_GRENADE_READY, math.huge)
		end
	end

	if stat == TFA.Enum.STATUS_GRENADE_READY then
		if ply:WaterLevel() > 2 then
			self:SendViewModelAnim(ACT_VM_THROW)
			self:SetStatus(TFA.GetStatus("idle"))
			self:SetSlamNormal(vector_origin)
			self:SetDG4Slamming(false)
		end

		if SERVER then
			for k, v in pairs(ents.FindInSphere(ply:GetPos(), 80)) do
				if v:IsNPC() or v:IsNextBot() then
					if v == ply then continue end
					if nzombies and (v.NZBossType or string.find(v:GetClass(), "zombie_boss")) then continue end
					v:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
				end
			end
		end
		if ply:IsOnGround() then
			self:ThrowStart()
		end
	end

	if stat == TFA.Enum.STATUS_GRENADE_THROW and statusend then
		if self.LastNadeAnim then
			local len = self:GetActivityLength(self.LastNadeAnim, true, self.LastNadeAnimType)
			self:ScheduleStatus(TFA.Enum.STATUS_GRENADE_THROW_WAIT, len - (self.LastNadeDelay or len))
		end
	end

	if stat == TFA.Enum.STATUS_RAGNAROK_DEPLOY and statusend then
		self:PlantDG4()
	end

	if stat == TFA.Enum.STATUS_GRENADE_THROW_WAIT and statusend then
		self:SetStatus(TFA.GetStatus("idle"))
	end

	if self:GetStatus() == TFA.Enum.STATUS_BASHING and not self:GetSparking() then
		if self:GetStatusProgress() > 0.5 then
			self:SetSparking(true)
		end
	end

	if self:GetSparking() then
		if CurTime() > self:GetSparkTime() then
			self:SetSparking(false)
			self:EmitSound("TFA_BO4_DG5.Stop")
			self:StopSound("TFA_BO4_DG5.SparkLoop")
			self:StopSoundNet("TFA_BO4_DG5.SparkLoop")
		end

		if SERVER then
			for k, v in pairs(ents.FindInSphere(ply:GetShootPos(), 64)) do
				if (v:IsNPC() or v:IsNextBot()) and v:Health() > 0 then
					if v == ply then continue end

					if not v:BO4IsShocked() then
						local fx = EffectData()
						fx:SetStart(ply:GetShootPos() - vector_up*10)
						fx:SetOrigin(v:EyePos())
						fx:SetFlags(0)

						local receipt = RecipientFilter()
						receipt:AddPlayer(ply)
						receipt:AddPVS(ply:GetShootPos())

						util.Effect("tfa_bo3_waffe_jump", fx, true, receipt)
					end

					v:BO4Shock(0.2, ply, self)
				end
			end
		end
	end

	return BaseClass.Think2(self, ...)
end

function SWEP:SecondaryAttack()
	local ply = self:GetOwner()
	if not self:CanPrimaryAttack() then return end
	if nzombies and not self:GetOwner():GetNotDowned() then return end

	self:SetSparkTime(CurTime() + 10)
	self:TakePrimaryAmmo(self:GetStatL("Secondary.AmmoConsumption"))

	self:SendViewModelAnim(ACT_VM_HITCENTER)
	self:ScheduleStatus(TFA.Enum.STATUS_BASHING, self:GetActivityLength())
	self:SetNextPrimaryFire(self:GetActivityLength())
end

function SWEP:CanAltAttack()
	local tr = util.QuickTrace(self:GetOwner():GetShootPos(), Vector(0,0,-128), {self:GetOwner(), self})
	return tr.HitWorld and self:CanPrimaryAttack() and (nzombies and self:Clip1() or self:Ammo1()) >= self:GetStatL("Secondary.AmmoConsumption")
end

function SWEP:AltAttack()
	if not self:CanAltAttack() then return end
	if nzombies and not self:GetOwner():GetNotDowned() then return end

	self:SetHasNuked(true)
	self:SendViewModelAnim(ACT_VM_DEPLOY)
	self:ScheduleStatus(TFA.Enum.STATUS_RAGNAROK_DEPLOY, self:GetActivityLength())
	self:SetNextPrimaryFire(self:GetStatusEnd())
end

function SWEP:PlantDG4()
	if CLIENT then return end
	local ply = self:GetOwner()
	local ang = self:GetAimVector():Angle()
	ang = Angle(0, ang.yaw, ang.roll)

	local pos = ply:GetShootPos()
	local tr = util.QuickTrace(pos, Vector(0,0,-128), {ply, self})
	if not tr.HitWorld then return end

	self:StopSound("TFA_BO4_DG5.SparkLoop")

	local ent = ents.Create("bo4_specialist_dg5")
	ent:SetModel("models/hunter/blocks/cube05x1x05.mdl")
	ent:SetPos(tr.HitPos + tr.HitNormal*15)
	ent:SetAngles(ang)
	ent:SetOwner(ply)

	ent:SetWeapon(self)
	ent:SetAmmoCount(math.min(nzombies and self:Clip1() or self:Ammo1(), 100))
	ent.Damage = self.mydamage
	ent.mydamage = self.mydamage

	ent:Spawn()

	ent:SetOwner(ply)
	ent.WeaponClass = self:GetClass()

	if nzombies then
		ply:SetUsingSpecialWeapon(false)
		ply:EquipPreviousWeapon()
		ply:SetUsingSpecialWeapon(false)
	else
		ply:StripWeapon(self:GetClass())
	end
end

function SWEP:AOEShock()
	local ply = self:GetOwner()
	local self2 = self:GetTable()
	if not IsValid(ply) then return end

	if self:VMIV() then
		ParticleEffectAttach("bo4_dg5_spark", PATTACH_POINT_FOLLOW, self.OwnerViewModel, 3)
		ParticleEffectAttach("bo4_dg5_spark", PATTACH_POINT_FOLLOW, self.OwnerViewModel, 4)
	end

	if CLIENT then return end

	local fx = EffectData()
	fx:SetEntity(self)

	local filter = RecipientFilter()
	filter:AddPVS(ply:GetShootPos())
	if IsValid(ply) and self:IsFirstPerson() then
		filter:RemovePlayer(ply)
	end

	if filter:GetCount() > 0 then
		util.Effect("tfa_bo4_dg5_3p", fx, true, filter)
	end

	for k, v in pairs(ents.FindInSphere(ply:GetShootPos(), 300)) do
		if (v:IsNPC() or v:IsNextBot()) and v:Health() > 0 then
			if v == ply then continue end
			if v:BO4IsShocked() then continue end
			if self.fakekills == 2 then continue end

			local fx = EffectData()
			fx:SetStart(ply:GetShootPos() - vector_up*10)
			fx:SetOrigin(v:EyePos())
			fx:SetFlags(0)

			local receipt = RecipientFilter()
			receipt:AddPlayer(ply)
			receipt:AddPVS(ply:GetShootPos())

			util.Effect("tfa_bo3_waffe_jump", fx, true, receipt)
			//util.ParticleTracerEx("bo3_waffe_jump", ply:GetShootPos()-Vector(0,0,10), v:EyePos(), false, self:EntIndex(), v:EntIndex())

			v:BO4Shock(math.Rand(1.6,2.2), ply, self)
			self.fakekills = self.fakekills + 1
		end
	end

	self.fakekills = 0
end

function SWEP:KillInSphere(range)
	if CLIENT then return end
	range = range or 120

	local ply = self:GetOwner()
	local damage = DamageInfo()
	damage:SetAttacker(ply)
	damage:SetInflictor(self)
	damage:SetDamageType(DMG_MISSILEDEFENSE)

	for k, v in pairs(ents.FindInSphere(ply:GetShootPos(), range)) do
		if v:IsNPC() or v:IsNextBot() then
			if v == ply then continue end
			if nzombies and (v.NZBossType or string.find(v:GetClass(), "zombie_boss")) then continue end
			if !TFA.WonderWeapon.ShouldDamage(v, ply, self) then continue end

			damage:SetDamage(v:Health() + 666)
			damage:SetDamageForce(v:GetUp()*10000 + (v:GetPos() - self:GetPos()):GetNormalized() * 15000)
			damage:SetDamagePosition(v:WorldSpaceCenter())

			v:TakeDamageInfo(damage)

			local trace = {["Entity"] = v, ["Hit"] = true, ["HitPos"] = v:WorldSpaceCenter()}
			self:SendHitMarker(ply, trace, damage)
		end
	end
end

function SWEP:CycleSafety()
end

function SWEP:OnDrop(...)
	self:StopSound("TFA_BO3_DG4.Idle")
	self:StopSound("TFA_BO4_DG5.SparkLoop")

	self:SetDG4Slamming(false)
	self:SetSparking(false)
	return BaseClass.OnDrop(self,...)
end

function SWEP:OwnerChanged(...)
	self:StopSound("TFA_BO3_DG4.Idle")
	self:StopSound("TFA_BO4_DG5.SparkLoop")

	self:SetDG4Slamming(false)
	self:SetSparking(false)
	return BaseClass.OwnerChanged(self,...)
end

function SWEP:Holster( ... )
	if self:GetDG4Slamming() then
		return false
	end

	self:CleanParticles()
	self:SetSparking(false)
	self:StopSoundNet("TFA_BO3_DG4.Idle")
	self:StopSoundNet("TFA_BO4_DG5.SparkLoop")

	return BaseClass.Holster(self,...)
end

function SWEP:IsSpecial()
	return true
end
