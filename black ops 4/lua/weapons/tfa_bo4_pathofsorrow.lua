local nzombies = engine.ActiveGamemode() == "nzombies"
local inf_cvar = GetConVar("sv_tfa_bo3ww_inf_specialist")
local dlight_cvar = GetConVar("cl_tfa_fx_wonderweapon_dlights")
local damage_cvar = GetConVar("sv_tfa_bo3ww_environmental_damage")
local coddamage_cvar = GetConVar("sv_tfa_bo3ww_cod_damage")

SWEP.Base = "tfa_melee_base"
SWEP.Category = "TFA Wonder Weapons"
SWEP.SubCategory = "Black Ops 4"
SWEP.Spawnable = TFA_BASE_VERSION and TFA_BASE_VERSION >= 4.76
SWEP.AdminSpawnable = true
SWEP.UseHands = true
SWEP.Type_Displayed = "#tfa.weapontype.specialist"
SWEP.Purpose = "Carried by Takeo Masaki through both victory and sacrifice, the Path of Sorrows is a tragic blade with many more tales to tell."
SWEP.Author = "FlamingFox"
SWEP.Slot = 0
SWEP.PrintName = nzombies and "Path of Sorrows | BO4" or "Path of Sorrows"
SWEP.DrawCrosshair = true
SWEP.DrawCrosshairIronSights = false
SWEP.WWCrosshairEnabled = true
SWEP.AutoSwitchTo = false

--[Model]--
SWEP.ViewModel			= "models/weapons/tfa_bo4/katana/c_katana.mdl"
SWEP.ViewModelFOV = 65
SWEP.WorldModel			= "models/weapons/tfa_bo4/katana/w_katana.mdl"
SWEP.HoldType = "melee2"
SWEP.CameraAttachmentOffsets = {}
SWEP.CameraAttachmentScale = 1
SWEP.VMPos = Vector(0, 0, 0)
SWEP.VMAng = Vector(0, 0, 0)
SWEP.VMPos_Additive = true

SWEP.Offset = { --Procedural world model animation, defaulted for CS:S purposes.
	Pos = {
		Up = 0.5,
		Right = 1.5,
		Forward = 3,
	},
	Ang = {
		Up = -180,
		Right = 180,
		Forward = 0
	},
	Scale = 1
}

--[Gun Related]--
SWEP.Primary.Sound = "TFA_BO4_KATANA.Slash"
SWEP.Primary.Ammo = nzombies and "none" or "AlyxGun"
SWEP.Primary.Automatic = true
SWEP.Primary.RPM = 100
SWEP.Primary.Damage = 115
SWEP.Primary.NumShots = 1
SWEP.Primary.AmmoConsumption = inf_cvar:GetBool() and 0 or 5
SWEP.Primary.Knockback = 0
SWEP.Primary.ClipSize = nzombies and 100 or -1
SWEP.Primary.DefaultClip = 100
SWEP.Primary.Delay = 0.35
SWEP.Primary.DamageType = bit.bor(DMG_SLASH, DMG_SLOWBURN)

SWEP.Primary.MaxCombo = 0
SWEP.Primary.Attacks = {
	{
		["act"] = ACT_VM_MISSLEFT,
		["len"] = 90,
		["src"] = Vector(0,0,0), -- Trace source; X ( +right, -left ), Y ( +forward, -back ), Z ( +up, -down )
		["dir"] = Vector(-72,36,0), -- Trace direction/length; X ( +right, -left ), Y ( +forward, -back ), Z ( +up, -down )
		["dmg"] = 115,
		["dmgtype"] = DMG_SLASH,
		["delay"] = 0.2,
		["snd"] = "TFA_BO4_KATANA.Slash",
		["viewpunch"] = Angle(2,4,0),
		["viewpunchb"] = Angle(2,-4,0),
		["hitflesh"] = "TFA_BO3_ZODSWORD.Impact",
		["hitworld"] = "TFA_BO3_STAFFS.MeleeHit",
		["end"] = 0.9,
		["hull"] = 10,
		["maxhits"] = 666,
	}
}

SWEP.Secondary.MaxCombo = 0
SWEP.Secondary.Attacks = {
	{
		["act"] = ACT_VM_MISSLEFT,
		["len"] = 90,
		["src"] = Vector(0,0,0), -- Trace source; X ( +right, -left ), Y ( +forward, -back ), Z ( +up, -down )
		["dir"] = Vector(72,36,0), -- Trace direction/length; X ( +right, -left ), Y ( +forward, -back ), Z ( +up, -down )
		["dmg"] = 115,
		["dmgtype"] = DMG_SLASH,
		["delay"] = 0.2,
		["snd"] = "TFA_BO4_KATANA.Slash",
		["viewpunch"] = Angle(2,4,0),
		["viewpunchb"] = Angle(2,-4,0),
		["hitflesh"] = "TFA_BO3_ZODSWORD.Impact",
		["hitworld"] = "TFA_BO3_STAFFS.MeleeHit",
		["end"] = 0.95,
		["hull"] = 10,
		["maxhits"] = 666,
	}
}

SWEP.Secondary.Sound = "TFA_BO4_KATANA.Dash"
SWEP.Secondary.AmmoConsumption = inf_cvar:GetBool() and 0 or 10
SWEP.Secondary.Damage = 20

SWEP.MuzzleFlashEffect = ""
SWEP.DisableChambering = true
SWEP.FiresUnderwater = true
SWEP.Delay = 0.1
SWEP.AmmoRegen = 1

--[Range]--
SWEP.Primary.Range = -1
SWEP.Primary.RangeFalloff = -1
SWEP.Primary.DisplayFalloff = false
SWEP.DisplayFalloff = false

--[Iron Sights]--
SWEP.data = {}
SWEP.data.ironsights = 0

--[Misc]--
SWEP.InspectPos = Vector(4, 0, 1)
SWEP.InspectAng = Vector(0, 15, 15)
SWEP.MoveSpeed = 1.0
SWEP.IronSightsMoveSpeed  = SWEP.MoveSpeed * 0.8
SWEP.SafetyPos = Vector(-12, 0, -1)
SWEP.SafetyAng = Vector(0, -20, -45)
SWEP.SmokeParticle = ""
SWEP.AllowSprintAttack = false
SWEP.Secondary.CanBash = false

--[NZombies]--
SWEP.NZWonderWeapon = false
SWEP.NZSpecialCategory = "specialist"
SWEP.NZSpecialWeaponData = {MaxAmmo = 0, AmmoType = "none"}

SWEP.NZSpecialistResistanceData = {
	Types = bit.bor(DMG_SLASH, DMG_CRUSH, DMG_CLUB, DMG_VEHICLE),
	Percent = 0.9, // 0 - 1, 1 being 100% reduction
	MinimumDamage = 10,
}

SWEP.NZHudIcon = Material("vgui/icon/ui_icon_equipment_zm_katana_lvl3_dark.png", "unlitgeneric smooth")

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

SWEP.EventTable = {
[ACT_VM_DRAW] = {
{ ["time"] = 5 / 30, ["type"] = "sound", ["value"] = Sound("TFA_BO4_KATANA.Draw") },
},
[ACT_VM_HOLSTER] = {
{ ["time"] = 1 / 30, ["type"] = "sound", ["value"] = Sound("TFA_BO4_KATANA.Holster") },
},
[ACT_VM_DRAW_DEPLOYED] = {
{ ["time"] = 1 / 30, ["type"] = "sound", ["value"] = Sound("TFA_BO4_OVERKILL.Deploy") },
{ ["time"] = 1 / 30, ["type"] = "sound", ["value"] = Sound("TFA_BO4_KATANA.Deploy") },
},
[ACT_VM_MISSLEFT] = {
{ ["time"] = 15 / 30, ["type"] = "sound", ["value"] = Sound("TFA_BO4_KATANA.Slash") },
},
[ACT_VM_MISSRIGHT] = {
{ ["time"] = 15 / 30, ["type"] = "sound", ["value"] = Sound("TFA_BO4_KATANA.Slash") },
},
[ACT_VM_PULLBACK] = {
{ ["time"] = 0, ["type"] = "sound", ["value"] = Sound("TFA_BO4_KATANA.Grab") },
{ ["time"] = 5 / 30, ["type"] = "sound", ["value"] = Sound("TFA_BO4_KATANA.Ult") },
},
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

--[Shit]--
SWEP.AllowViewAttachment = true --Allow the view to sway based on weapon attachment while reloading or drawing, IF THE CLIENT HAS IT ENABLED IN THEIR CONVARS.
SWEP.Sprint_Mode = TFA.Enum.LOCOMOTION_ANI -- ANI = mdl, HYBRID = ani + lua, Lua = lua only
SWEP.Sights_Mode = TFA.Enum.LOCOMOTION_HYBRID -- ANI = mdl, HYBRID = lua but continue idle, Lua = stop mdl animation
SWEP.Idle_Mode = TFA.Enum.IDLE_BOTH --TFA.Enum.IDLE_DISABLED = no idle, TFA.Enum.IDLE_LUA = lua idle, TFA.Enum.IDLE_ANI = mdl idle, TFA.Enum.IDLE_BOTH = TFA.Enum.IDLE_ANI + TFA.Enum.IDLE_LUA
SWEP.Idle_Blend = 0.25 --Start an idle this far early into the end of a transition
SWEP.Idle_Smooth = 0.05 --Start an idle this far early into the end of another animation
SWEP.SprintBobMult = 0

SWEP.BO3CanDash = true
SWEP.BO3DashMult = 3

SWEP.DTapActivities = {
	[ACT_VM_PRIMARYATTACK] = true,
	[ACT_VM_PRIMARYATTACK_EMPTY] = true,
	[ACT_VM_PRIMARYATTACK_SILENCED] = true,
	[ACT_VM_PRIMARYATTACK_1] = true,
	[ACT_VM_SECONDARYATTACK] = true,
	[ACT_VM_MISSLEFT] = true,
}

SWEP.WW3P_FX = "bo4_katana_3p"
SWEP.WW3P_ATT = 2

SWEP.WWFP_FX = "bo4_katana_vm"
SWEP.WWFP_ATT = 2

--[Coding]--
DEFINE_BASECLASS( SWEP.Base )

local tpfx_cvar = GetConVar("cl_tfa_fx_wonderweapon_3p")
local l_CT = CurTime

function SWEP:SetupDataTables()
	BaseClass.SetupDataTables(self)

	self:NetworkVarTFA("Bool", "Dashing")
	self:NetworkVarTFA("Bool", "HasNuked")
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

			self:AddDrawCallViewModelParticle("bo4_katana_vm", PATTACH_POINT_FOLLOW, 2, true)
		end)
		return true
	end
end

function SWEP:PreDrawViewModel(vm, ...)
	BaseClass.PreDrawViewModel(self, vm, ...)

	local status = self:GetStatus()

	if not TFA.Enum.HolsterStatus[self:GetStatus()] then
		self:AddDrawCallViewModelParticle(self.WWFP_FX, PATTACH_POINT_FOLLOW, tonumber(self.WWFP_ATT), true)
	end

	if IsValid(self.OwnerViewModel) and dlight_cvar:GetBool() and DynamicLight then
		self.DLight = self.DLight or DynamicLight(self.OwnerViewModel:EntIndex(), false)
		if self.DLight then
			local attpos = self.OwnerViewModel:GetAttachment(1)

			if (attpos and attpos.Pos) then
				self.DLight.pos = attpos.Pos
				self.DLight.dir = attpos.Ang:Forward()
				self.DLight.r = 255
				self.DLight.g = 0
				self.DLight.b = 0
				self.DLight.decay = 2000
				self.DLight.brightness = 1
				self.DLight.size = 64
				self.DLight.dietime = CurTime() + 0.5
			end
		end
	end
end

function SWEP:DrawWorldModel(...)
	BaseClass.DrawWorldModel(self, ...)

	self:AddDrawCallWorldModelParticle(self.WW3P_FX, PATTACH_POINT_FOLLOW, tonumber(self.WW3P_ATT), tpfx_cvar:GetBool() and not TFA.Enum.HolsterStatus[self:GetStatus()])
end

function SWEP:Deploy(...)
	local bDeploy = BaseClass.Deploy(self, ...)

	if SERVER and self.IsFirstDeploy then
		TFA.WonderWeapon.SpecialistDeploy(self, self:GetOwner(), 128)
	end

	return bDeploy
end

function SWEP:PrimaryAttack()
	local ply = self:GetOwner()

	if IsValid(ply) and ply:IsNPC() then
		local _, attk = self:ChoosePrimaryAttack()
		if not attk then return end
		local owv = self:GetOwner()

		timer.Simple(0.5, function()
			if IsValid(self) and IsValid(owv) and owv:IsCurrentSchedule(SCHED_MELEE_ATTACK1) then
				self:Strike(attk, 5)
			end
		end)

		self:SetNextPrimaryFire(CurTime() + attk["end"] or 1)

		timer.Simple(self:GetNextPrimaryFire() - CurTime(), function()
			if IsValid(owv) then
				owv:ClearSchedule()
			end
		end)

		self:GetOwner():SetSchedule(SCHED_MELEE_ATTACK1)
		return
	end

	if self:GetSprinting() and not self:GetStatL("AllowSprintAttack", false) then return end
	if self:IsSafety() then return end
	if not self:VMIV() then return end
	if !self:CanPrimaryAttack() then return end
	if not TFA.Enum.ReadyStatus[self:GetStatus()] then return end

	local maxcombo = self:GetStatL("Primary.MaxCombo", 0)
	if maxcombo > 0 and self:GetComboCount() >= maxcombo then return end

	local ind, attack = self:ChoosePrimaryAttack()
	if not attack then return end

	--We have attack isolated, begin attack logic
	self:PlaySwing(attack.act)

	self:TakePrimaryAmmo(self:GetStatL("Primary.AmmoConsumption"))
	if IsFirstTimePredicted() then
		if self:VMIV() then
			ParticleEffectAttach("bo4_katana_trail", PATTACH_POINT_FOLLOW, self.OwnerViewModel, 1)
		end
		self:EmitSound(attack.snd)
		if ply.Vox then
			ply:Vox("bash", 4)
		end
	end

	self:SetVP(true)
	self:SetVPPitch(attack.viewpunch.p)
	self:SetVPYaw(attack.viewpunch.y)
	self:SetVPRoll(attack.viewpunch.r)
	self:SetVPTime(CurTime() + 0.05 / self:GetAnimationRate(attack.act))

	self.up_hat = false
	self:ScheduleStatus(TFA.Enum.STATUS_SHOOTING, attack.delay / self:GetAnimationRate(attack.act))
	self:SetMelAttackID(ind)
	self:SetNextPrimaryFire(CurTime() + attack["end"] / self:GetAnimationRate(attack.act))

	ply:SetAnimation(PLAYER_ATTACK1)

	self:SetNextSecondaryFire(CurTime() + 12/30 / self:GetAnimationRate())
end

function SWEP:CanSecondaryAttack()
	return BaseClass.CanPrimaryAttack(self) and (nzombies and self:Clip1() or self:Ammo1()) >= self:GetStatL("Secondary.AmmoConsumption")
end

function SWEP:SecondaryAttack()
	local ply = self:GetOwner()
	if not IsValid(ply) then return end

	if ply:IsPlayer() and not self:VMIV() then return end
	if not self:CanSecondaryAttack() then return end
	if not ply:OnGround() then return end
	if nzombies and not ply:GetNotDowned() then return end

	self:EmitSoundNet(self:GetStatL("Secondary.Sound"))

	self:SendViewModelAnim(ACT_VM_MISSRIGHT)
	self:ScheduleStatus(TFA.Enum.STATUS_GRENADE_PULL, 25/30 / self:GetAnimationRate())
	self:SetNextPrimaryFire(CurTime() + self:GetActivityLength())
	self:TakePrimaryAmmo(self:GetStatL("Secondary.AmmoConsumption"))

	if IsFirstTimePredicted() and self:VMIV() then
		ParticleEffectAttach("bo4_katana_trail", PATTACH_POINT_FOLLOW, self.OwnerViewModel, 1)
	end

	self:SetDashing(true)
end

function SWEP:CanAltAttack()
	local stat = self:GetStatus()

	if not TFA.Enum.ReadyStatus[stat] and stat ~= TFA.Enum.STATUS_SHOOTING then
		if self:GetStatL("LoopedReload") and TFA.Enum.ReloadStatus[stat] then
			self:SetReloadLoopCancel(true)
		end
		return false
	end

	if self:GetSprintProgress() >= 0.1 and not self:GetStatL("AllowSprintAttack", false) then
		return false
	end

	if l_CT() < self:GetNextPrimaryFire() then return false end

	return true
end

function SWEP:AltAttack()
	local ply = self:GetOwner()
	if not IsValid(ply) then return end

	if ply:IsPlayer() and not self:VMIV() then return end
	if not self:CanAltAttack() then return end
	if nzombies and not ply:GetNotDowned() then return end
	if nzombies and self:GetHasNuked() then return end
	if ply:BO4IsStealth() then return end

	self:SendViewModelAnim(ACT_VM_PULLBACK)
	self:ScheduleStatus(TFA.Enum.STATUS_BLOCKING , self:GetActivityLength())
	self:SetNextPrimaryFire(self:GetStatusEnd())
	if nzombies then self:SetHasNuked(true) end

	if SERVER then
		self:TakePrimaryAmmo(self:GetStatL("Secondary.AmmoConsumption"))
		ply:BO4KatanaStealth(30)
	end
end

function SWEP:ApplyDamage(trace, dmginfo, attk)
	local damage, force = dmginfo:GetBaseDamage(), dmginfo:GetDamageForce()
	dmginfo:SetDamagePosition(trace.HitPos)
	dmginfo:SetReportedPosition(trace.StartPos)
	dmginfo:SetDamageForce(force*6)

	local ent = trace.Entity
	if nzombies and IsValid(ent) then
		if trace.HitGroup ~= HITGROUP_HEAD then
			trace.HitGroup = HITGROUP_GENERIC
		end

		damage = ent:Health() + 666
		dmginfo:SetDamageType(DMG_MISSILEDEFENSE)
		dmginfo:SetDamage(damage)

		if string.find(ent:GetClass(), "nz_zombie_boss") then
			damage = math.max(800, ent:GetMaxHealth() / 12)
			dmginfo:SetDamage(damage)
		end
	end

	if coddamage_cvar ~= nil and coddamage_cvar:GetBool() and trace.HitGroup ~= HITGROUP_HEAD then
		trace.HitGroup = HITGROUP_GENERIC
	end

	if SERVER and IsValid(ent) and ent.Ignite then
		if nzombies then
			if ent:IsValidZombie() then
				ent:Ignite(3)
			end
		elseif ( ent:IsNPC() or ent:IsNextBot() or ent:IsPlayer() ) or ( damage_cvar == nil or damage_cvar:GetBool() ) then
			ent:Ignite(3)
		end
	end

	trace.Entity:DispatchTraceAttack(dmginfo, trace, self:GetOwner():EyeAngles():Forward())

	dmginfo:SetDamage(damage)

	self:ApplyForce(trace.Entity, dmginfo:GetDamageForce(), trace.HitPos)
	self:SetMelAttackID(1)
end

function SWEP:Think2(...)
	local ply = self:GetOwner()
	local status = self:GetStatus()
	local statusend = CurTime() >= self:GetStatusEnd()
	local slashwait = self:GetNextSecondaryFire()

	if self.up_hat and slashwait ~= 0 and slashwait < CurTime() then
		self:SetMelAttackID(-1)
		self.up_hat = false
		self:ScheduleStatus(TFA.Enum.STATUS_SHOOTING, 5/30)
		ply:SetAnimation(PLAYER_ATTACK1)

		local attack = self:GetStatL("Primary.Attacks")[1]

		self:SetVP(true)
		self:SetVPPitch(attack.viewpunchb.p)
		self:SetVPYaw(attack.viewpunchb.y)
		self:SetVPRoll(attack.viewpunchb.r)
		self:SetVPTime(CurTime() + attack.delay / self:GetAnimationRate(attack.act))

		self:SetNextSecondaryFire(0)
	end

	if nzombies and ply:IsPlayer() then
		if ply:GetAmmoCount(self:GetPrimaryAmmoType()) > 0 then
			ply:SetAmmo(0, self:GetPrimaryAmmoType())
		end
	end

	if status == TFA.Enum.STATUS_GRENADE_PULL and self:GetDashing() then
		self:KatanaDash()
		if statusend then
			ply:SetAnimation(PLAYER_ATTACK1)
			ply:ViewPunch(Angle(6,2,0))
			self:SetDashing(false)
			if IsFirstTimePredicted() then
				self:Strike(self:GetStatL("Primary.Attacks")[1], self.Precision)
			end
		end
	end

	return BaseClass.Think2(self, ...)
end

function SWEP:ProcessHoldType(...)
	if self:GetStatus() == TFA.Enum.STATUS_GRENADE_PULL then
		self:SetHoldType("melee")
		return "melee"
	else
		return BaseClass.ProcessHoldType(self, ...)
	end
end

function SWEP:KatanaDash()
	if CLIENT then return end
	local ply = self:GetOwner()

	local damage = DamageInfo()
	damage:SetAttacker(ply)
	damage:SetInflictor(self)
	damage:SetDamageType(DMG_MISSILEDEFENSE)

	local tr = {
		start = ply:EyePos(),
		filter = {self, ply},
		mask = MASK_SHOT,
	}

	local bPlayerStopped = false
	for k, v in RandomPairs(ents.FindInSphere(ply:GetShootPos(), 48)) do
		if not v:IsWorld() and v:IsSolid() then
			if v.LastDashAttackHurt and v.LastDashAttackHurt[self:GetCreationID()] and (v.LastDashAttackHurt[self:GetCreationID()] + 0.2 > CurTime()) then continue end
			if v == ply then continue end
			if !TFA.WonderWeapon.ShouldDamage(v, ply, self) then continue end

			local test_origin = v:EyePos()
			if not ply:VisibleVec(test_origin) then continue end

			tr.endpos = test_origin
			local tr1 = util.TraceLine(tr)
			local hitpos = tr1.Entity == v and tr1.HitPos or test_origin

			local isAlive = ( v:IsNPC() or v:IsNextBot() or v:IsPlayer() )
			damage:SetDamage(( isAlive and ( ( coddamage_cvar ~= nil and coddamage_cvar:GetBool() ) or nzombies ) ) and v:Health() + 666 or self:GetStat("Secondary.Damage"))
			damage:SetDamageForce(v:GetUp()*15000 + (v:GetPos() - self:GetPos()):GetNormalized() * 15000)
			damage:SetDamagePosition(hitpos)
			damage:SetDamageType(nzombies and DMG_BURN or bit.bor( TFA.WonderWeapon.GetBurnDamage(v), DMG_SLASH ))

			if nzombies and (v.NZBossType or v.IsMooBossZombie or v.IsMooMiniBoss) then
				damage:SetDamage(math.max(100, v:GetMaxHealth() / 40))
			end

			if not v.LastDashAttackHurt then v.LastDashAttackHurt = {} end
			v.LastDashAttackHurt[self:GetCreationID()] = CurTime()

			v:Ignite(4)
			v:TakeDamageInfo(damage)

			if isAlive then
				sound.Play("TFA_BO3_ZODSWORD.Impact", hitpos)
				util.ScreenShake(v:GetPos(), 5, 255, 0.5, 90)
			end

			if !bPlayerStopped then
				bPlayerStopped = true
				ply:SetLocalVelocity(vector_origin)
			end
		end
	end
end

function SWEP:OnDrop(...)
	self:SetDashing(false)
	return BaseClass.OnDrop(self,...)
end

function SWEP:OwnerChanged(...)
	self:SetDashing(false)
	return BaseClass.OwnerChanged(self,...)
end

function SWEP:Holster( ... )
	self:SetDashing(false)
	return BaseClass.Holster(self,...)
end
