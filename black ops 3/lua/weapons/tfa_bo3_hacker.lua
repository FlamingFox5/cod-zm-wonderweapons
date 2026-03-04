local nzombies = engine.ActiveGamemode() == "nzombies"

SWEP.Base = "tfa_gun_base"
SWEP.Category = "TFA Wonder Weapons"
SWEP.SubCategory = "Black Ops 3"
SWEP.Spawnable = TFA_BASE_VERSION and TFA_BASE_VERSION >= 4.76
SWEP.AdminSpawnable = true
SWEP.UseHands = true
SWEP.Type_Displayed = "#tfa.weapontype.wonderweapon"
SWEP.Purpose = nzombies and nil or "Hack players to heal them, Hack NPCs to convert them into allies, Hack doors to unlock and open them"
SWEP.Author = "FlamingFox"
SWEP.Slot = 5
SWEP.PrintName = "Hacker Device"
SWEP.DrawCrosshair = true
SWEP.DrawCrosshairIS = false
SWEP.AutoSwitchTo = false

--[Model]--
SWEP.ViewModel			= "models/weapons/tfa_bo3/hacker/c_hacker.mdl"
SWEP.ViewModelFOV = 65
SWEP.WorldModel			= "models/weapons/tfa_bo3/hacker/w_hacker.mdl"
SWEP.HoldType = "slam"
SWEP.CameraAttachmentOffsets = {}
SWEP.CameraAttachmentScale = 1
SWEP.MuzzleAttachment = "1"
SWEP.VMPos = Vector(0, 0, 0)
SWEP.VMAng = Vector(0, 0, 0)
SWEP.VMPos_Additive = true

SWEP.Offset = { --Procedural world model animation, defaulted for CS:S purposes.
		Pos = {
		Up = 3,
		Right = 3,
		Forward = 4,
		},
		Ang = {
		Up = -60,
		Right = 180,
		Forward = -5
		},
		Scale = 1
}

--[Gun Related]--
SWEP.Primary.Sound = nil
SWEP.Primary.Ammo = ""
SWEP.Primary.Automatic = false
SWEP.Primary.RPM = 80
SWEP.Primary.RPM_Semi = nil
SWEP.Primary.RPM_Burst = nil
SWEP.Primary.Damage = 115
SWEP.Primary.Knockback = 0
SWEP.Primary.NumShots = 1
SWEP.Primary.AmmoConsumption = 1
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = 0
SWEP.Primary.DryFireDelay = nil
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
SWEP.Primary.Range = -1
SWEP.Primary.RangeFalloff = -1
SWEP.Primary.DisplayFalloff = false
SWEP.DisplayFalloff = false

--[Spread Related]--
SWEP.Primary.Spread		  = .00
SWEP.Primary.IronAccuracy = .00
SWEP.IronRecoilMultiplier = 0.0
SWEP.CrouchAccuracyMultiplier = 0.0

SWEP.Primary.KickUp				= 0.0
SWEP.Primary.KickDown			= 0.0
SWEP.Primary.KickHorizontal		= 0.0
SWEP.Primary.StaticRecoilFactor	= 0.0

SWEP.Primary.SpreadMultiplierMax = 0
SWEP.Primary.SpreadIncrement = 0
SWEP.Primary.SpreadRecovery = 0

--[Iron Sights]--
SWEP.data = {}
SWEP.data.ironsights = 0

--[Shells]--
SWEP.LuaShellEject = false
SWEP.EjectionSmokeEnabled = false

--[Misc]--
SWEP.InspectPos = Vector(1, -3, -2)
SWEP.InspectAng = Vector(15, -15, 0)
SWEP.MoveSpeed = 1
SWEP.IronSightsMoveSpeed  = SWEP.MoveSpeed * 0.8
SWEP.SafetyPos = Vector(1, -2, -0.5)
SWEP.SafetyAng = Vector(-20, 35, -25)

--[NZombies]--
SWEP.NZPaPName = "Golden Hacker Device"
SWEP.NZWonderWeapon = true
SWEP.NZSpecialCategory = "shield"
SWEP.NZSpecialWeaponData = {MaxAmmo = 0, AmmoType = "none"}
SWEP.NZSpecialShowHUD = true
SWEP.NZHudIcon = Material("vgui/icon/uie_t5hud_icon_hacker.png", "unlitgeneric smooth")
SWEP.NZHudIcon_t7 = Material("vgui/icon/uie_t7_zm_hud_ammo_icon_hack_active.png", "unlitgeneric smooth")
SWEP.NZHudIcon_t7zod = Material("vgui/icon/uie_t7_zm_hud_ammo_icon_hack_active_bw.png", "unlitgeneric smooth")
SWEP.NZHudIcon_t7tomb = Material("vgui/icon/uie_t7_zm_hud_ammo_icon_hack_active_bw.png", "unlitgeneric smooth")
SWEP.Ispackapunched = false

SWEP.SpeedColaFactor = 1
SWEP.DTapSpeed = 1
SWEP.DTap2Speed = 1
SWEP.SpeedColaActivities = {}
SWEP.DTapActivities = {}

function SWEP:NZSpecialHolster(wep)
	self:StopSound("TFA_BO3_HACKER.Loop")
	return true
end

function SWEP:IsSpecial()
	return true
end

function SWEP:OnPaP()
self.Ispackapunched = true
self.HackerRange = 180
self.HackerRangeSqr = 32400
self.NZHudIcon = Material("vgui/icon/uie_t5hud_icon_hacker_gold.png", "unlitgeneric smooth")

self.Skin = 1
self:SetSkin(1)
self.PrintName = "Golden Hacker Device"
self:SetNW2String("PrintName", "Golden Hacker Device")

local ply = self:GetOwner()
if IsValid(ply) and !ply.HackerDevicePAP then
	ply.HackerDevicePAP = true
end

self:ClearStatCache()
return true
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
{ ["time"] = 1 / 30, ["type"] = "sound", ["value"] = Sound("TFA_BO3_HACKER.Open") },
{ ["time"] = 5 / 30, ["type"] = "lua", value = function(self) self.Skin = self.Ispackapunched and 1 or 0 end, client = true, server = true},
},
[ACT_VM_HOLSTER] = {
{ ["time"] = 1 / 30, ["type"] = "sound", ["value"] = Sound("TFA_BO3_HACKER.Close") },
},
[ACT_VM_PRIMARYATTACK] = {
{ ["time"] = 5 / 30, ["type"] = "sound", ["value"] = Sound("TFA_BO3_HACKER.Loop") },
{ ["time"] = 40 / 30, ["type"] = "sound", ["value"] = Sound("TFA_BO3_HACKER.PenOut") },
},
[ACT_VM_PULLBACK] = {
{ ["time"] = 15 / 30, ["type"] = "sound", ["value"] = Sound("TFA_BO3_HACKER.PenIn") },
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

SWEP.BO3CanHack = true
SWEP.HackerRange = 80
SWEP.HackerRangeSqr = 6400
SWEP.equipment_got_in_round = 0

--[Coding]--
DEFINE_BASECLASS( SWEP.Base )

local WonderWeapons = TFA.WonderWeapon
local HackerUtil = nzombies and nzHackerDevice.GetUtility or WonderWeapons.HackerUtilityData

local l_CT = CurTime

function SWEP:SetupDataTables(...)
	BaseClass.SetupDataTables(self, ...)

	self:NetworkVarTFA("Entity", "HackerTarget")
end

function SWEP:Equip(...)
	if nzombies then
		self.equipment_got_in_round = tonumber(nzRound:GetNumber())
		self.LastBoardRepairRound = tonumber(nzRound:GetNumber())
	end

	return BaseClass.Equip(self, ...)
end

if nzombies then
	function SWEP:Equip(ply)
		if SERVER then
			if ply.HackerDevicePAP then
				timer.Simple(0, function()
					if not IsValid(self) then return end
					self:ApplyNZModifier("pap")
				end)
			end
		end

		return BaseClass.Equip(self, ply)
	end
end

function SWEP:ResetHack(doanim)
	self:StopSound("TFA_BO3_HACKER.Loop")
	self:StopSoundNet("TFA_BO3_HACKER.Loop")
	self:SetHackerTarget(nil)

	if doanim then
		self:SendViewModelAnim(ACT_VM_PULLBACK)
		self:ScheduleStatus(TFA.Enum.STATUS_HACKING_END, self:GetActivityLength())
		self:SetNextPrimaryFire(self:GetStatusEnd())
	end
end

function SWEP:CanHack()
	local stat = self:GetStatus()
	local ply = self:GetOwner()
	local ent = self:GetHackerTarget()

	if not IsValid(ent) then
		return false
	end

	if not TFA.Enum.ReadyStatus[stat] and stat ~= TFA.Enum.STATUS_HACKING then
		return false
	end

	local hackerData = HackerUtil( ent:GetClass() )

	if not hackerData then
		return false
	end

	if not hackerData.Condition( self, ply, ent ) then
		return false
	end

	if nzombies and not ply:CanAfford( hackerData.Price( self, ply, ent ) ) then
		return false
	end

	if ( ply:GetShootPos():DistToSqr( ent:WorldSpaceCenter() ) > self.HackerRangeSqr ) then
		return false
	end

	if self:GetSprintProgress() >= 0.1 and not self:GetStatL("AllowSprintAttack", false) then
		return false
	end

	if l_CT() < self:GetNextPrimaryFire() then return false end

	return true
end

function SWEP:Think2(...)
	local ply = self:GetOwner()
	local target = self:GetHackerTarget()
	local status = self:GetStatus()

	if self:CanHack() and status ~= TFA.Enum.STATUS_HACKING then
		local hackerData = HackerUtil( target:GetClass() )

		local duration = hackerData and hackerData.Duration( self, ply, target ) or 5
		if nzombies and self:HasNZModifier("pap") then
			duration = math.max( math.Round( duration / 2, 1 ), 1 )
		end

		self:ScheduleStatus( TFA.Enum.STATUS_HACKING, duration )
		self:SendViewModelAnim( ACT_VM_PRIMARYATTACK )
	elseif !self:CanHack() and status == TFA.Enum.STATUS_HACKING then
		self:ScheduleStatus( TFA.Enum.STATUS_HACKING_END, self:GetActivityLength( ACT_VM_PULLBACK ) )
		self:ResetHack( true )
	end

	if status == TFA.Enum.STATUS_HACKING and l_CT() > self:GetStatusEnd() and IsValid( target ) then
		self:ScheduleStatus( TFA.Enum.STATUS_HACKING_END, self:GetActivityLength( ACT_VM_PULLBACK ) )
		self:SetNextPrimaryFire( self:GetStatusEnd() )

		local hackerData = HackerUtil( target:GetClass() )
		hackerData.OnActivate( self, ply, target )

		self:ResetHack(true)

		if IsFirstTimePredicted() then
			self:EmitSound("TFA_BO3_HACKER.Finish")
		end

		if SERVER and IsValid(ply) then
			if nzombies then
				local hacks = ply.HackerHacks or 0
				ply.HackerHacks = hacks + 1

				self:SetClip1(ply.HackerHacks)

				if ply.HackerHacks == 30 and not self:HasNZModifier("pap") then
					if nzBuilds then
						self:EmitSound("NZ.BO2.Shovel.Upgrade")
					end

					self:ApplyNZModifier("pap")

					self:ResetFirstDeploy()
					self:CallOnClient("ResetFirstDeploy")
					self:Deploy()
					self:CallOnClient("Deploy")
				end
			end

			if ply:IsPlayer() and not TFA.WonderWeapon.HasAchievement( ply, "BO3_Hacker_First_Use" ) then
				TFA.WonderWeapon.NotifyAchievement( "BO3_Hacker_First_Use", ply )
			end
		end
	end

	return BaseClass.Think2(self,...)
end

function SWEP:ChooseIdleAnim(...)
	if self:GetStatus() == TFA.Enum.STATUS_HACKING then return end
	return BaseClass.ChooseIdleAnim(self, ...)
end

local color_black_100 = Color(0, 0, 0, 100)
local color_black_180 = Color(0, 0, 0, 180)

function SWEP:DrawHUDBackground()
	local ply = self:GetOwner()
	local tr = ply:GetEyeTrace()
	local entity = tr.Entity
	local status = self:GetStatus()
	local w, h = ScrW(), ScrH()
	local scale = ((w/1920)+1)/2
	local lowres = scale < 0.96
	local font = "DermaLarge"

	if nzombies then
		font = "nz.small."..GetFontType(nzMapping.Settings.mainfont)
		if lowres then
			font = ("nz.points."..GetFontType(nzMapping.Settings.smallfont))
		end
	end

	if status == TFA.Enum.STATUS_HACKING then
		draw.SimpleTextOutlined( "Hacking", font, w/2, h/2 + 60*scale, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 2, color_black_100 )
	end

	if IsValid(entity) and not self:CanHack() then
		local hackerData = HackerUtil( entity:GetClass() )

		if nzombies and hackerData then
			if ply:GetShootPos():DistToSqr( ply:GetEyeTrace().HitPos ) < self.HackerRangeSqr and hackerData.Condition( self, ply, entity ) then
				local hintString = hackerData.HintString( self, ply, entity )
				local price = hackerData.Price( self, ply, entity )

				local text = "Press & Hold "..string.upper( input.LookupBinding("+USE") ).." - "
				if hintString then
					if price > 0 then
						text = text..hintString.." [Cost: "..string.Comma(price).."]"
					else
						text = text..hintString
					end
				else
					if price > 0 then
						text = text.."Hack [Cost: "..string.Comma(price).."]"
					else
						text = text.."Hack"
					end
				end

				if nzDisplay and nzDisplay.modernHUDs and nzDisplay.modernHUDs[ nzMapping.Settings.hudtype ] then
					surface.SetFont( font )
					surface.SetDrawColor( color_black_100 )

					local wd, ht = surface.GetTextSize( text )
					surface.DrawRect( w/2 - ((wd/2)+12), h - 280*scale - (ht/2), wd + 24, ht )
				end

				draw.SimpleTextOutlined( text, font, w/2, h - 280*scale, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, color_black_100 )
			end
		elseif !nzombies and hackerData then
			if ply:GetShootPos():DistToSqr(entity:WorldSpaceCenter()) < self.HackerRangeSqr then
				local hintString = hackerData.HintString( self, ply, entity )
				local text = "Press & Hold "..string.upper( input.LookupBinding("+USE") ).." - "..( hintString or "Hack" )

				draw.SimpleTextOutlined( text, font, w/2, h/2 + 80*scale, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, color_black_100 )
			end
		end
	end

	if status == TFA.Enum.STATUS_HACKING then
		local ct = l_CT()
		local time = self:GetStatusEnd() - ct
		local ctime = self:GetStatusEnd() - self:GetStatusStart()
		if !time or !ctime then return end

		surface.SetDrawColor(color_black_180)
		surface.DrawRect(w/2 - 150, h - 600*scale, 300, 20)
		surface.SetDrawColor(color_white)

		if time < ct then
			surface.DrawRect(w/2 - 145, h - 595*scale, 290 * (1-time/ctime), 10)
		else
			surface.DrawRect(w/2 - 145, h - 595*scale, 290, 10)
		end
	end
end

function SWEP:PrimaryAttack()
	return false
end

function SWEP:SecondaryAttack()
	return false
end

function SWEP:Reload()
	return false
end

function SWEP:CycleSafety()
	return false
end

function SWEP:OnDrop(...)
	self:ResetHack(false)
	return BaseClass.OnDrop(self,...)
end

function SWEP:OwnerChanged(...)
	self:ResetHack(false)
	return BaseClass.OwnerChanged(self,...)
end

function SWEP:Holster(...)
	self:ResetHack(false)
	return BaseClass.Holster(self,...)
end

function SWEP:OnRemove(...)
	if SERVER and nzombies and not IsValid(ents.FindByClass("nz_bo3_hacker")[1]) then
		hook.Call("RespawnHackerDevice")
	end
	return BaseClass.OnRemove(self,...)
end
