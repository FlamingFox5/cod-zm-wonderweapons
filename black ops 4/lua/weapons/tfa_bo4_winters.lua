local nzombies = engine.ActiveGamemode() == "nzombies"
local dlight_cvar = GetConVar("cl_tfa_fx_wonderweapon_dlights")

SWEP.Base = "tfa_gun_base"
SWEP.Category = "TFA Wonder Weapons"
SWEP.SubCategory = "Black Ops 4"
SWEP.Spawnable = TFA_BASE_VERSION and TFA_BASE_VERSION >= 4.76
SWEP.AdminSpawnable = true
SWEP.UseHands = true
SWEP.Type_Displayed = "#tfa.weapontype.wonderweapon"
SWEP.Author = "FlamingFox"
SWEP.Slot = 1
SWEP.PrintName = nzombies and "Winter's Howl | BO4" or "Winter's Howl"
SWEP.DrawCrosshair = true
SWEP.DrawCrosshairIS = false
SWEP.WWCrosshairEnabled = true

--[Model]--
SWEP.ViewModel			= "models/weapons/tfa_bo4/winters/c_winters.mdl"
SWEP.ViewModelFOV = 65
SWEP.WorldModel			= "models/weapons/tfa_bo4/winters/w_winters.mdl"
SWEP.HoldType = "revolver"
SWEP.CameraAttachmentOffsets = {}
SWEP.CameraAttachmentScale = 1
SWEP.MuzzleAttachment = "1"
SWEP.VMPos = Vector(0, 0, 0)
SWEP.VMAng = Vector(0, 0, 0)
SWEP.VMPos_Additive = true

SWEP.Offset = { --Procedural world model animation, defaulted for CS:S purposes.
        Pos = {
        Up = -2,
        Right = 1.2,
        Forward = 3,
        },
        Ang = {
		Up = -180,
        Right = 190,
        Forward = 0
        },
		Scale = 1
}

--[Gun Related]--
SWEP.Primary.Sound = "TFA_BO4_WINTERS.Shoot"
SWEP.Primary.SoundLyr1 = "TFA_BO4_WINTERS.Act"
SWEP.Primary.SoundLyr2 = "TFA_BO4_WINTERS.Crack"
SWEP.Primary.SoundLyr3 = "TFA_BO4_WINTERS.Lfe"
SWEP.Primary.Ammo = "AlyxGun"
SWEP.Primary.Automatic = false
SWEP.Primary.RPM = 400
SWEP.Primary.RPM_Semi = nil
SWEP.Primary.RPM_Burst = nil
SWEP.Primary.Damage = nzombies and 115 or 80
SWEP.Primary.Knockback = 15
SWEP.Primary.NumShots = 1
SWEP.Primary.AmmoConsumption = 1
SWEP.Primary.ClipSize = 6
SWEP.Primary.DefaultClip = SWEP.Primary.ClipSize
SWEP.Primary.DryFireDelay = 0.5
SWEP.MuzzleFlashEffect = "tfa_bo4_muzzleflash_winters"
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
/*SWEP.Primary.Range = -1
SWEP.Primary.RangeFalloff = -1
SWEP.Primary.DisplayFalloff = false
SWEP.DisplayFalloff = false*/
SWEP.Primary.DisplayFalloff = true
SWEP.Primary.RangeFalloffLUT = {
	bezier = false, -- Whenever to use Bezier or not to interpolate points?
	-- you probably always want it to be set to true
	range_func = "linear", -- function to spline range
	-- "linear" for linear splining.
	-- Possible values are "quintic", "cubic", "cosine", "sinusine", "linear" or your own function
	units = "hu", -- possible values are "inches", "inch", "hammer", "hu" (are all equal)
	-- everything else is considered to be meters
	lut = { -- providing zero point is not required
		-- without zero point it is considered to be as {range = 0, damage = 1}
		{range = 120, damage = 1.0},
		{range = 600, damage = 0.5},
	}
}

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
SWEP.Primary.Spread		  = .01
SWEP.Primary.IronAccuracy = .001
SWEP.IronRecoilMultiplier = 0.6
SWEP.CrouchAccuracyMultiplier = 0.85

SWEP.Primary.KickUp				= 0.6
SWEP.Primary.KickDown			= 0.6
SWEP.Primary.KickHorizontal		= 0.1
SWEP.Primary.StaticRecoilFactor	= 0.4

SWEP.Primary.SpreadMultiplierMax = 2
SWEP.Primary.SpreadIncrement = 2
SWEP.Primary.SpreadRecovery = 4

--[Iron Sights]--
SWEP.IronBobMult 	 = 0.065
SWEP.IronBobMultWalk = 0.065
SWEP.data = {}
SWEP.data.ironsights = 1
SWEP.Secondary.IronFOV = 75
SWEP.IronSightsPos = Vector(-7.305, 0, 1.5)
SWEP.IronSightsAng = Vector(0, 0, 0)
SWEP.IronSightTime = 0.3

--[Shells]--
SWEP.LuaShellEject = false
SWEP.LuaShellEffect = "ShellEject"
SWEP.LuaShellModel = "models/weapons/tfa_bo4/winters/freeze_clip.mdl"
SWEP.LuaShellScale = 1
SWEP.LuaShellEjectDelay = 0
SWEP.ShellAttachment = 2
SWEP.EjectionSmokeEnabled = false

--[Projectile]--
SWEP.Primary.Projectile         = "bo4_ww_winters" -- Entity to shoot
SWEP.Primary.ProjectileVelocity = 2000 -- Entity to shoot's velocity
SWEP.Primary.ProjectileModel    = "models/hunter/plates/plate.mdl" -- Entity to shoot's model

--[Misc]--
SWEP.AmmoTypeStrings = {alyxgun = "#tfa.ammo.bo4ww.winters"}
SWEP.InspectPos = Vector(8, -5, -1)
SWEP.InspectAng = Vector(20, 30, 16)
SWEP.MoveSpeed = 1.0
SWEP.IronSightsMoveSpeed = SWEP.MoveSpeed * 0.8
SWEP.SafetyPos = Vector(0, 0, -0)
SWEP.SafetyAng = Vector(-15, 15, -15)
SWEP.SmokeParticle = ""

--[NZombies]--
SWEP.NZPaPName = "Winter's Fury"
SWEP.NZWonderWeapon = true
SWEP.Primary.MaxAmmo = 48
SWEP.Ispackapunched = false
SWEP.NZHudIcon = Material("vgui/icon/hud_winters_howl_bo4.png", "unlitgeneric smooth")

function SWEP:NZMaxAmmo()
    local ammo_type = self:GetPrimaryAmmoType() or self.Primary.Ammo
	self:GetOwner():SetAmmo( self.Primary.MaxAmmo, ammo_type )
	self:SetClip1( self.Primary.ClipSize )
end

function SWEP:OnPaP()
	self.Ispackapunched = true

	self.RoundDropOffInterval = 10
	self.CylinderRadius = 180 // 15 feet
	self.CylinderRange = 900 // 75 feet
	self.CylinderInnerRange = 200 // 17 feet

	self.Primary.ClipSize = 9
	self.Primary.MaxAmmo = 96
	self.Primary.Damage = 115

	self.Primary_TFA.ClipSize = 9
	self.Primary_TFA.MaxAmmo = 96
	self.Primary_TFA.Damage = 115

	self.Primary.RangeFalloffLUT = {
		bezier = false,
		range_func = "linear",
		units = "hu",
		lut = {
			{range = 200, damage = 1.0},
			{range = 900, damage = 0.5},
		}
	}

	self.Primary_TFA.RangeFalloffLUT = self.Primary.RangeFalloffLUT

	self:ClearStatCache()
	return true
end

--[Tables]--
SWEP.StatusLengthOverride = {
    [ACT_VM_RELOAD] = 55 / 30,
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
{ ["time"] = 1 / 30, ["type"] = "sound", ["value"] = Sound("weapon_bo3_cloth.short") },
{ ["time"] = 5 / 30, ["type"] = "sound", ["value"] = Sound("weapon_bo3_gear.rattle") },
},
[ACT_VM_HOLSTER] = {
{ ["time"] = 2 / 30, ["type"] = "sound", ["value"] = Sound("weapon_bo3_cloth.short") },
{ ["time"] = 5 / 30, ["type"] = "sound", ["value"] = Sound("weapon_bo3_gear.rattle") },
},
[ACT_VM_DRAW_DEPLOYED] = {
{ ["time"] = 1 / 30, ["type"] = "sound", ["value"] = Sound("weapon_bo3_cloth.short") },
{ ["time"] = 5 / 30, ["type"] = "sound", ["value"] = Sound("weapon_bo3_gear.rattle") },
{ ["time"] = 5 / 30, ["type"] = "sound", ["value"] = Sound("TFA_BO4_WINTERS.Spin") },
},
[ACT_VM_RELOAD] = {
{ ["time"] = 1 / 30, ["type"] = "sound", ["value"] = Sound("TFA_BO4_WINTERS.Open") },
{ ["time"] = 5 / 30, ["type"] = "lua", value = function(self) self:SetMainGlow(false) end, client = true, server = true},
{ ["time"] = 25 / 30, ["type"] = "lua", value = function(self) self.Bodygroups_W = {[1] = 1} end, client = true, server = true},
{ ["time"] = 30 / 30, ["type"] = "lua", value = function(self) self:EventShell() end, client = true, server = true},
{ ["time"] = 50 / 30, ["type"] = "sound", ["value"] = Sound("TFA_BO4_WINTERS.Insert") },
{ ["time"] = 55 / 30, ["type"] = "lua", value = function(self) self.Bodygroups_W = {[1] = 0} end, client = true, server = true},
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

SWEP.RoundDropOffInterval = 5
SWEP.CylinderRadius = 120 // 10 feet
SWEP.CylinderRange = 600 // 50 feet
SWEP.CylinderInnerRange = 150 // 13 feet

SWEP.Bodygroups_W = {
	[1] = 0
}

SWEP.WElements = {
	["reload_mag"] = { type = "Model", model = "models/weapons/tfa_bo4/winters/freeze_clip.mdl", bone = "ValveBiped.Bip01_L_Hand", rel = "", pos = Vector(4, 3, 1), angle = Angle(-190, 20, -80), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bonemerge = false, active = false, bodygroup = {} },
}

SWEP.StatCache_Blacklist = {
	["Bodygroups_W"] = true,
	["WElements"] = true,
}

DEFINE_BASECLASS( SWEP.Base )

local developer = GetConVar("developer")

function SWEP:SetupDataTables()
	BaseClass.SetupDataTables(self)
	
	self:NetworkVarTFA("Float", "NextWave")
	self:NetworkVarTFA("Int", "GlowLevel")
	self:NetworkVarTFA("Bool", "MainGlow")

	self:SetGlowLevel(3)
	self:SetMainGlow(true)
end

function SWEP:PreDrawViewModel(vm, ...)
	BaseClass.PreDrawViewModel(self, vm, ...)

	local status = self:GetStatus()
	if self.OwnerViewModel and IsValid(self.OwnerViewModel) then
		self:AddDrawCallViewModelParticle("bo4_freezegun_vm", PATTACH_POINT_FOLLOW, 7, true)
		self:AddDrawCallViewModelParticle("bo4_freezegun_vm_coils", PATTACH_POINT_FOLLOW, 3, true)

		if dlight_cvar:GetBool() and DynamicLight then
			self.DLight = self.DLight or DynamicLight(self.OwnerViewModel:EntIndex(), true)

			if self.DLight and !TFA.Enum.HolsterStatus[status] then
				local attpos = self.OwnerViewModel:GetAttachment(3)

				if (attpos and attpos.Pos) then
					self.DLight.pos = attpos.Pos
					self.DLight.dir = attpos.Ang:Forward()
					self.DLight.r = 50
					self.DLight.g = 200
					self.DLight.b = 255
					self.DLight.decay = 1000
					self.DLight.brightness = 0.5
					self.DLight.size = 64
					self.DLight.dietime = CurTime() + 1
				end
			end
		elseif self.DLight then
			self.DLight.dietime = -1
		end
	end
end

function SWEP:DrawWorldModel(...)
	BaseClass.DrawWorldModel(self, ...)

	local status = self:GetStatus()
	if self.Bodygroups_W and self.Bodygroups_W[1] ~= 0 and not TFA.Enum.ReloadStatus[status] then
		self.Bodygroups_W[1] = 0
	end

	local bHolstering = TFA.Enum.HolsterStatus[status]
	if dlight_cvar:GetBool() and DynamicLight and (!self.GetMainGlow or self:GetMainGlow()) then
		self.DLight = self.DLight or DynamicLight(self:EntIndex(), false)

		if self.DLight and !bHolstering then
			local attpos = self:GetAttachment(3)

			if (attpos and attpos.Pos) then
				self.DLight.pos = attpos.Pos
				self.DLight.dir = attpos.Ang:Forward()
				self.DLight.r = 50
				self.DLight.g = 200
				self.DLight.b = 255
				self.DLight.decay = 2000
				self.DLight.brightness = 0.5
				self.DLight.size = 64
				self.DLight.dietime = CurTime() + 0.5
			end
		end
	elseif self.DLight then
		self.DLight.dietime = -1
	end

	local WorldModelElements = self:GetStatRaw("WorldModelElements", TFA.LatestDataVersion)

	if WorldModelElements and istable( WorldModelElements ) then
		local statusProgress = self:GetStatusProgress()
		if status == TFA.Enum.STATUS_RELOADING and statusProgress > 0.56 then
			local ElementModel = WorldModelElements[ "reload_mag" ].curmodel
			if ElementModel and IsValid( ElementModel ) then
				self.DLight = self.DLight or DynamicLight(self:EntIndex(), false)

				if self.DLight and !bHolstering then
					//if (attpos and attpos.Pos) then
						self.DLight.pos = ElementModel:GetPos()
						self.DLight.dir = ElementModel:GetForward()
						self.DLight.r = 50
						self.DLight.g = 200
						self.DLight.b = 255
						self.DLight.decay = 2000
						self.DLight.brightness = 0.5
						self.DLight.size = 64
						self.DLight.dietime = CurTime() + 0.5
					//end
				end
			end

			if WorldModelElements["reload_mag"] and !WorldModelElements["reload_mag"].active then
				WorldModelElements["reload_mag"].active = true
			end
		elseif WorldModelElements["reload_mag"] and WorldModelElements["reload_mag"].active then
			WorldModelElements["reload_mag"].active = false
		end
	end
end

function SWEP:CompleteReload(...)
	BaseClass.CompleteReload(self, ...)

	self:SetGlowLevel(self:Clip1Adjusted())
	self:SetMainGlow(true)
end

function SWEP:Clip1Adjusted()
	return self.Ispackapunched and math.ceil(self:Clip1()/3) or math.ceil(self:Clip1()/2)
end

function SWEP:Think2(...)
	local ply = self:GetOwner()

	if SERVER then
		local nClip = math.Clamp(self:Clip1Adjusted(), 0, 3)
		if self:GetGlowLevel() ~= nClip and not TFA.Enum.ReloadStatus[self:GetStatus()] then
			self:SetGlowLevel(nClip)
		end

		if !self:GetMainGlow() and not TFA.Enum.ReloadStatus[self:GetStatus()] then
			self:SetMainGlow(true)
		end

		if self.Bodygroups_W and self.Bodygroups_W[1] ~= 0 and not TFA.Enum.ReloadStatus[self:GetStatus()] then
			self.Bodygroups_W[1] = 0
		end
	end

	return BaseClass.Think2(self, ...)
end

function SWEP:PostPrimaryAttack()
	local ply = self:GetOwner()
	local ifp = IsFirstTimePredicted()
	if not IsValid(ply) then return end

	local lyr1 = self:GetStatL("Primary.SoundLyr1")
	if lyr1 and ifp then
		self:EmitGunfireSound(lyr1)
	end
	
	local lyr2 = self:GetStatL("Primary.SoundLyr2")
	if lyr2 and ifp then
		self:EmitGunfireSound(lyr2)
	end

	local lyr3 = self:GetStatL("Primary.SoundLyr3")
	if lyr3 and ifp then
		self:EmitGunfireSound(lyr3)
	end

	self:SetGlowLevel(math.Clamp(self:Clip1Adjusted(), 0, 3))

	if SERVER then
		self:FreezegunCylinder()
	end
end

function SWEP:PreSpawnProjectile(ent)
	local ply = self:GetOwner()
	if ply.GetHull then
		local mins, maxs = ply:GetHull()
		local finalPos = ply:GetShootPos() + ply:GetAimVector()*math.max(maxs[1], maxs[2])
		ent:SetPos(finalPos)
	end
end

function SWEP:PostSpawnProjectile(ent)
	if not util.IsInWorld(ent:GetPos()) then
		SafeRemoveEntityDelayed(ent, 0)
	end
end

local function enemy_percent_damaged_by_freezegun(d, e)
	if not IsValid(e) then return 0 end
	return math.Clamp(1 - (d / e:Health()), .33, 1)
end

function SWEP:FreezegunCylinder()
	if CLIENT then return end
	local ply = self:GetOwner()

	local inner_range = self.CylinderInnerRange
	local outer_range = self.CylinderRange
	local cylinder_radius = self.CylinderRadius

	local view_pos = ply:GetShootPos()
	local forward_view_angles = ply:IsPlayer() and ply:GetAimVector() or self:GetAimVector()
	local end_pos = view_pos + (forward_view_angles*outer_range)

	local inner_range_squared = inner_range * inner_range
	local outer_range_squared = outer_range * outer_range
	local cylinder_radius_squared = cylinder_radius * cylinder_radius

	for i, ent in pairs(ents.FindInSphere(view_pos, outer_range*1.1)) do
		if not (ent:IsNPC() or ent:IsPlayer() or ent:IsNextBot()) then continue end
		if ent:BO4IsFrozen() then continue end

		if ent == ply then continue end
		if !TFA.WonderWeapon.ShouldDamage(ent, ply, self) then continue end

		local test_origin = ent:WorldSpaceCenter()
		local test_range_squared = view_pos:DistToSqr(test_origin)
		if test_range_squared > outer_range_squared then
			continue
		end

		local normal = (test_origin - view_pos):GetNormalized()
		local dot = forward_view_angles:Dot(normal)
		if 0 > dot then
			continue
		end

		local radial_origin = TFA.WonderWeapon.PointOnSegmentNearestToPoint( view_pos, end_pos, test_origin )
		if test_origin:DistToSqr(radial_origin) > cylinder_radius_squared then
			continue
		end

		local tr1 = util.TraceLine({
			start = radial_origin,
			endpos = test_origin,
			filter = {self, ply},
			mask = MASK_SHOT_HULL,
		})

		local hitpos = tr1.Entity == ent and tr1.HitPos or ent:WorldSpaceCenter()
		if not ply:VisibleVec(hitpos) then
			continue
		end

		local damagefinal = self:GetStat("Primary.Damage")
		if nzombies and nzRound and nzRound.GetZombieHealth and ent:IsValidZombie() then
			local round = math.max(nzRound:GetNumber(), 1)
			local health = nzRound:GetZombieHealth()

			damagefinal = math.max(health / math.Clamp(round/self.RoundDropOffInterval, 1, 3), damagefinal)
		end

		local dist_ratio = (outer_range_squared - test_range_squared) / (outer_range_squared - inner_range_squared) 
		local damage = tonumber(Lerp(dist_ratio, damagefinal / 2, damagefinal))
		normal = normal + (test_origin - radial_origin):GetNormalized()*0.5

		local delay = math.Clamp((1 - dist_ratio)*30, 1, 30)
		timer.Simple(math.Clamp(engine.TickInterval()*delay, 0, 0.3), function()
			if not IsValid(self) or not IsValid(ply) or not IsValid(ent) then return end
			if ent:Health() <= 0 then return end

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

			self:FreezegunDamage(ent, damage, normal*200, hitpos)
		end)
	end
end

function SWEP:FreezegunDamage(ent, amount, force, hitpos)
	local damage = DamageInfo()
	damage:SetDamageType(nZSTORM and DMG_VEHICLE or DMG_REMOVENORAGDOLL)
	damage:SetAttacker(self:GetOwner())
	damage:SetInflictor(self)
	damage:SetDamage(math.Clamp(ent:Health() - 1, 1, amount))
	damage:SetDamageForce(force)
	damage:SetDamagePosition(hitpos)

	if nzombies and (ent.NZBossType or string.find(ent:GetClass(), "zombie_boss")) then
		damage:SetDamage(math.max(800, ent:GetMaxHealth() / 12))
		damage:ScaleDamage(math.Clamp(math.Round(nzRound:GetNumber()/12, 1), 1, 3))
	end

	ent:TakeDamageInfo(damage)

	if (ent:IsNPC() or ent:IsPlayer() or ent:IsNextBot()) then
		local trace = {["Entity"] = ent, ["Hit"] = true, ["HitPos"] = hitpos or ent:WorldSpaceCenter()}
		self:SendHitMarker(self:GetOwner(), trace, damage)
	end

	if IsValid(ent) and ent:Health() > 0 then
		if nzombies and (ent.NZBossType or string.find(ent:GetClass(), "zombie_boss")) then return end
		if ent:IsPlayer() and not ent:Alive() then return end

		if ent:Health() <= 1 then
			if nzombies and nzPowerUps:IsPowerupActive("insta") then return end

			ent:BO4WintersFreeze(math.Rand(4,5), self:GetOwner(), self)
		elseif ent:Health() > 1 then
			ent:BO4WintersSlow(10, enemy_percent_damaged_by_freezegun(amount, ent))
		end
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
