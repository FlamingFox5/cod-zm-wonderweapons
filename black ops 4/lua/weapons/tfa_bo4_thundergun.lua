local nzombies = engine.ActiveGamemode() == "nzombies"
local dlight_cvar = GetConVar("cl_tfa_fx_wonderweapon_dlights")
local tpfx_cvar = GetConVar("cl_tfa_fx_wonderweapon_3p")
local sv_true_damage = GetConVar("sv_tfa_bo3ww_cod_damage")
local sv_damage_world = GetConVar("sv_tfa_bo3ww_environmental_damage")

SWEP.Base = "tfa_gun_base"
SWEP.Category = "TFA Wonder Weapons"
SWEP.SubCategory = "Black Ops 4"
SWEP.Spawnable = TFA_BASE_VERSION and TFA_BASE_VERSION >= 4.76
SWEP.AdminSpawnable = true
SWEP.UseHands = true
SWEP.Type_Displayed = "#tfa.weapontype.wonderweapon"
SWEP.Author = "FlamingFox"
SWEP.Slot = 2
SWEP.PrintName = nzombies and "Thundergun | BO4" or "Thundergun"
SWEP.DrawCrosshair = true
SWEP.DrawCrosshairIS = false
SWEP.WWCrosshairEnabled = true

--[Model]--
SWEP.ViewModel			= "models/weapons/tfa_bo4/thundergun/c_thundergun.mdl"
SWEP.ViewModelFOV = 65
SWEP.WorldModel			= "models/weapons/tfa_bo4/thundergun/w_thundergun.mdl"
SWEP.HoldType = "shotgun"
SWEP.CameraAttachmentOffsets = {}
SWEP.CameraAttachmentScale = 1
SWEP.MuzzleAttachment = "1"
SWEP.VMPos = Vector(2, 0, -1)
SWEP.VMAng = Vector(0, 0, 0)
SWEP.VMPos_Additive = true

SWEP.Offset = { --Procedural world model animation, defaulted for CS:S purposes.
        Pos = {
        Up = 0,
        Right = 1.2,
        Forward = 3.5,
        },
        Ang = {
		Up = 180,
        Right = 190,
        Forward = 0
        },
		Scale = 1
}

--[Gun Related]--
SWEP.Primary.Sound = "TFA_BO4_THUNDERGUN.Shoot"
SWEP.Primary.SoundLyr1 = "TFA_BO4_THUNDERGUN.Flux"
SWEP.Primary.Ammo = "Thumper"
SWEP.Primary.Automatic = false
SWEP.Primary.RPM = 60
SWEP.Primary.Damage = 115
SWEP.Primary.NumShots = 1
SWEP.Primary.AmmoConsumption = 1
SWEP.Primary.Knockback = 0
SWEP.Primary.ClipSize = 2
SWEP.Primary.DefaultClip = SWEP.Primary.ClipSize
SWEP.MuzzleFlashEffect	= "tfa_bo4_muzzleflash_thundergun"
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
		{range = 480, damage = 1.0},
		{range = 900, damage = 0.6522},
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
SWEP.Primary.Spread		  = .001
SWEP.Primary.IronAccuracy = .001
SWEP.IronRecoilMultiplier = 0.6
SWEP.CrouchAccuracyMultiplier = 0.85

SWEP.Primary.KickUp				= 1.5
SWEP.Primary.KickDown			= 1.2
SWEP.Primary.KickHorizontal		= 0.0
SWEP.Primary.StaticRecoilFactor	= 0.35

SWEP.Primary.SpreadMultiplierMax = 3
SWEP.Primary.SpreadIncrement = 3
SWEP.Primary.SpreadRecovery = 4

--[Projectile]--
SWEP.Primary.Projectile         = "bo4_ww_thundergun" -- Entity to shoot
SWEP.Primary.ProjectileVelocity = 1500 -- Entity to shoot's velocity
SWEP.Primary.ProjectileModel    = "models/dav0r/hoverball.mdl" -- Entity to shoot's model

--[Iron Sights]--
SWEP.data = {}
SWEP.data.ironsights = 0

--[Shells]--
SWEP.LuaShellEject = false
SWEP.LuaShellEffect = "ShellEject"
SWEP.LuaShellModel = "models/weapons/tfa_bo4/thundergun/wind_reel.mdl"
SWEP.LuaShellScale = 1.2
SWEP.LuaShellEjectDelay = 0
SWEP.ShellAttachment = 2
SWEP.EjectionSmokeEnabled = false

--[Misc]--
SWEP.AmmoTypeStrings = {thumper = "Wind Reels"}
SWEP.InspectPos = Vector(10, -5, -2)
SWEP.InspectAng = Vector(24, 42, 16)
SWEP.MoveSpeed = 0.9
SWEP.IronSightsMoveSpeed  = SWEP.MoveSpeed * 0.8
SWEP.SafetyPos = Vector(1, -2, -0.5)
SWEP.SafetyAng = Vector(-20, 35, -25)
SWEP.SmokeParticle = ""

--[NZombies]--
SWEP.NZPaPName = "Zeus Cannon"
SWEP.NZWonderWeapon = true
SWEP.Primary.MaxAmmo = 12

function SWEP:NZMaxAmmo()

	local ammo_type = self:GetPrimaryAmmoType() or self.Primary_TFA.Ammo

	if SERVER then
		self.Owner:SetAmmo( self.Primary.MaxAmmo, ammo_type )
		self:SetClip1( self.Primary.ClipSize )
	end
end

SWEP.Ispackapunched = false
SWEP.Primary.ClipSizePAP = 4
SWEP.Primary.MaxAmmoPAP = 24
SWEP.MoveSpeedPAP = 0.95

function SWEP:OnPaP()
self.Ispackapunched = true
self.Primary_TFA.ClipSize = 4
self.Primary_TFA.MaxAmmo = 24
self.MoveSpeed = 0.95
self:ClearStatCache()
return true
end

--[Tables]--
SWEP.StatusLengthOverride = {
	[ACT_VM_RELOAD] = 85 / 30,
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
{ ["time"] = 5 / 30, ["type"] = "lua", value = function(self) self:SetGlowLevel(self:Clip1Adjusted()) self:SetMainGlow(self:Clip1() > 0) self:UpdateViewmodelParticles() end, client = true, server = true},
},
[ACT_VM_HOLSTER] = {
{ ["time"] = 2 / 30, ["type"] = "sound", ["value"] = Sound("weapon_bo3_cloth.med") },
{ ["time"] = 5 / 30, ["type"] = "sound", ["value"] = Sound("weapon_bo3_gear.rattle") },
},
[ACT_VM_DRAW_DEPLOYED] = {
{ ["time"] = 0, ["type"] = "sound", ["value"] = Sound("TFA_BO4_THUNDERGUN.Raise") },
{ ["time"] = 5 / 30, ["type"] = "lua", value = function(self) self:SetGlowLevel(self:Clip1Adjusted()) self:SetMainGlow(self:Clip1() > 0) self:UpdateViewmodelParticles() end, client = true, server = true},
},
[ACT_VM_RELOAD] = {
{ ["time"] = 5 / 30, ["type"] = "sound", ["value"] = Sound("TFA_BO4_THUNDERGUN.Open") },
{ ["time"] = 25 / 30, ["type"] = "sound", ["value"] = Sound("TFA_BO4_THUNDERGUN.MagOut") },
{ ["time"] = 30 / 30, ["type"] = "lua", value = function(self)
	self.Bodygroups_W = {[1] = 1}

	if SERVER then
		local fx = EffectData()
		fx:SetEntity(self)
		fx:SetFlags(1)

		local filter = RecipientFilter()
		filter:AddPVS(self:GetOwner():GetShootPos())
		filter:RemovePlayer(self:GetOwner())
		if not self:IsFirstPerson() then
			filter:AddPlayer(self:GetOwner())
		end

		util.Effect("tfa_bo3_thundergun_3p", fx, nil, filter)
	end
end, client = true, server = true},
{ ["time"] = 30 / 30, ["type"] = "lua", value = function(self) self:EventShell() end, client = true, server = true},
{ ["time"] = 30.5 / 30, ["type"] = "lua", value = function(self) self:EventShell() end, client = true, server = true},
{ ["time"] = 50 / 30, ["type"] = "lua", value = function(self) self.Bodygroups_W = {[1] = 0} end, client = true, server = true},
{ ["time"] = 55 / 30, ["type"] = "sound", ["value"] = Sound("TFA_BO4_THUNDERGUN.MagIn") },
{ ["time"] = 84 / 30, ["type"] = "sound", ["value"] = Sound("TFA_BO4_THUNDERGUN.Close") },
{ ["time"] = 85 / 30, ["type"] = "lua", value = function(self) self:SetGlowLevel(self:Clip1Adjusted()) self:SetMainGlow(self:Clip1() > 0) self:UpdateViewmodelParticles() end, client = true, server = true},
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

SWEP.FP_FX = {}
SWEP.TP_FX = {}

SWEP.CylinderRadius = 180
SWEP.CylinderRange = 900
SWEP.CylinderKillRange = 480

SWEP.Bodygroups_W = {
	[1] = 0
}

SWEP.StatCache_Blacklist = {
	["Bodygroups_W"] = true,
}

--[Coding]--
DEFINE_BASECLASS( SWEP.Base )

local sp = game.SinglePlayer()
local developer = GetConVar("developer")
local cvar_papcamoww = GetConVar("nz_papcamo_ww")
local phys_pushscale = GetConVar("phys_pushscale")

local RAGDOLL_FILTER = {
	"class C_ClientRagdoll",
	"class C_HL2MPRagdoll",
}

local CLIENT_RAGDOLLS = {
	["class C_ClientRagdoll"] = true,
	["class C_HL2MPRagdoll"] = true,
}

if SERVER then
	local PUSH_ENTITIES = {
		[CLASS_HACKED_ROLLERMINE] = true,
		[CLASS_FLARE] = true,
	}
end

local Impulse = TFA.WonderWeapon.CalculateImpulseForce

function SWEP:SetupDataTables()
	BaseClass.SetupDataTables(self)
	
	self:NetworkVarTFA("Float", "NextWave")
	self:NetworkVarTFA("Int", "GlowLevel")
	self:NetworkVarTFA("Bool", "MainGlow")

	self:SetNextWave(CurTime() + self:SharedRandom(8, 10))
end

function SWEP:PreDrawViewModel(vm, ...)
	BaseClass.PreDrawViewModel(self, vm, ...)

	local status = self:GetStatus()
	local bShouldGlow = self.GetMainGlow and ( self:GetMainGlow() and IsValid( self.OwnerViewModel ) ) or false

	if ( TFA.Enum.ReadyStatus[status] or status == TFA.Enum.STATUS_SHOOTING ) then
		for i = 1, 4 do
			self:AddDrawCallViewModelParticle( "bo3_thundergun_vm_mag", PATTACH_POINT_FOLLOW, i + 6, bShouldGlow and self:GetGlowLevel() >= i )
		end
	end
end

function SWEP:DrawWorldModel(...)
	BaseClass.DrawWorldModel(self, ...)

	if self.Bodygroups_W and self.Bodygroups_W[1] ~= 0 and not TFA.Enum.ReloadStatus[self:GetStatus()] then
		self.Bodygroups_W[1] = 0
	end

	local status = self:GetStatus()
	local bShouldGlow = self.GetMainGlow and ( self:GetMainGlow() and tpfx_cvar:GetBool() ) or false

	for i = 1, 4 do
		self:AddDrawCallWorldModelParticle( "bo3_thundergun_3p_mag", PATTACH_POINT_FOLLOW, i + (9 - self:GetGlowLevel()), ( bShouldGlow and !TFA.Enum.HolsterStatus[status] and !TFA.Enum.ReloadStatus[status] ) and ( !self:IsCarriedByLocalPlayer() or !self:IsFirstPerson() ) and self:GetGlowLevel() >= i )
	end
end

function SWEP:UpdateViewmodelParticles()
	if SERVER then return end
	if not self:VMIV() then return end

	local bShouldGlow = self.GetMainGlow and ( self:GetMainGlow() and IsValid( self.OwnerViewModel ) ) or false

	for i = 1, 4 do
		self:AddDrawCallViewModelParticle( "bo3_thundergun_vm_mag", PATTACH_POINT_FOLLOW, i + 6, bShouldGlow and self:GetGlowLevel() >= i )
	end
end

function SWEP:PostPrimaryAttack()
	local ply = self:GetOwner()
	local ifp = IsFirstTimePredicted()
	if not IsValid(ply) then return end

	local lyr1 = self:GetStat("Primary.SoundLyr1")
	if lyr1 and ifp then
		self:EmitGunfireSound(lyr1)
	end

	self:SetGlowLevel(math.Clamp(self:Clip1Adjusted(), 0, 4))
	self:SetMainGlow(self:Clip1() > 0)

	if sp and SERVER then
		self:CallOnClient("UpdateViewmodelParticles")
	end
	self:UpdateViewmodelParticles()

	if SERVER then
		local fx = EffectData()
		fx:SetEntity(self)
		fx:SetFlags(0)

		local filter = RecipientFilter()
		filter:AddPVS(self:GetOwner():GetShootPos())
		filter:RemovePlayer(self:GetOwner())
		if not self:IsFirstPerson() then
			filter:AddPlayer(self:GetOwner())
		end

		util.Effect("tfa_bo3_thundergun_3p", fx, nil, filter)
	end

	self:ThundergunCylinderDamage()
end

function SWEP:Clip1Adjusted()
	return ( self:Clip1() < 1 or self.Ispackapunched ) and self:Clip1() or ( ( self:Clip1() > 1 ) and 4 or 2 )
end

function SWEP:ThundergunCylinderDamage()
	local ply = self:GetOwner()

	local inner_range = self.CylinderKillRange
	local outer_range = self.CylinderRange
	local cylinder_radius = self.CylinderRadius

	local view_pos = ply:GetShootPos()
	local forward_view_angles = ply:IsPlayer() and ply:GetAimVector() or self:GetAimVector()
	local end_pos = view_pos + (forward_view_angles * outer_range)

	local outer_range_squared = outer_range * outer_range
	local cylinder_radius_squared = cylinder_radius * cylinder_radius
	local inner_range_squared = inner_range * inner_range
	local instant_kill_range_squared = 48^2

	for i, ent in pairs(ents.FindInSphere(view_pos, outer_range*1.1)) do
		if ent:IsWeapon() then
			continue
		end
		if ent == ply then
			continue
		end

		if !TFA.WonderWeapon.ShouldDamage( ent, ply, self ) and ( ( target.Classify == nil or !isfunction( target.Classify ) ) or !PUSH_ENTITIES[ target:Classify() ] ) then
			continue
		end

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

		local dist_ratio = (outer_range_squared - test_range_squared) / (outer_range_squared - instant_kill_range_squared)

		local in_kill_range = test_range_squared < inner_range_squared

		local delay = math.Clamp( ( 1 - dist_ratio ) * 60, 1, 60 )

		if CLIENT then
			timer.Simple( math.Clamp( engine.TickInterval() * delay, 0, 0.5 ), function()
				if not IsValid(self) or not IsValid(ply) or not IsValid(ent) then return end

				self:FlingClientRagdoll( ent, view_pos, forward_view_angles )
			end )

			continue
		end

		if SERVER and ent:IsRagdoll() then
			timer.Simple( math.Clamp( engine.TickInterval() * delay, 0, 0.5 ), function()
				if not IsValid(self) or not IsValid(ply) or not IsValid(ent) then return end

				self:FlingServerRagdoll( ent, view_pos, forward_view_angles )
			end )

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

		if not ply:VisibleVec( hitpos ) then
			continue // guy can't actually be hit from where we are
		end

		// door busting handled by projectile and only works on doors with hinges
		if self:FlingPushEntities(ent, view_pos, radial_origin, forward_view_angles, hitpos, in_kill_range, delay) then
			continue
		end

		timer.Simple( math.Clamp( engine.TickInterval() * delay, 0, 0.5 ), function()
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
				hitworld = true,
				filter = ent,
				whitelist = true
			})

			if trtest.HitWorld then return end

			self:ThundergunDamage(ent, in_kill_range, trtest.Entity == ent and trtest.HitPos or hitpos)
		end )
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
					whitelist = true,
					filter = RAGDOLL_FILTER,
				})

				if ragTrace.Hit and ragTrace.Entity == ent and ragTrace.Fraction > 0.94 then
					debugoverlay.Axis(ragTrace.HitPos, ragTrace.HitNormal:Angle(), 5, 5, false)

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

	if bit.band( ent:GetSpawnFlags(), 16384 ) == 0 then
		local flForceScale = 20000 * math.Rand( 0.85, 1.15 )

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
					phys:Wake()
					phys:EnableMotion( true )

					local vecForce = Vector()
					vecForce:Set( ( direction + ( ent:GetPos() - ply:GetPos() ) ):GetNormalized() )
					vecForce:Mul( flForceScale )
					vecForce:Mul( phys_pushscale:GetFloat() )

					phys:ApplyForceCenter( vecForce + vector_up*math.random(8000,12000) )
				end
			end
		end
	end
end

function SWEP:FlingPushEntities(ent, start, endpos, direction, hitpos, killrange, delay)
	local ply = self:GetOwner()

	// set off phys cannisters
	if ent:GetClass() == "physics_cannister" then
		timer.Simple( math.Clamp( engine.TickInterval() * delay, 0, 0.5 ), function()
			if not IsValid(self) or not IsValid(ply) or not IsValid(ent) then return end

			ent:Input( "Activate" )

			local phys = ent:GetPhysicsObject()
			if IsValid( phys ) then
				phys:ApplyForceCenter( direction * Impulse( ent, math.random( 20, 40 ) ) + (start - endpos):GetNormalized() * Impulse( ent, 20 ) )
			end
		end )

		return true // dont do damage
	end

	// push away certain npcs
	if ent.Classify and isfunction( ent.Classify ) and PUSH_ENTITIES[ ent:Classify() ] and ent.GetPhysicsObject then
		timer.Simple( math.Clamp( engine.TickInterval() * delay, 0, 0.5 ), function()
			if not IsValid(self) or not IsValid(ply) or not IsValid(ent) then return end

			local phys = ent:GetPhysicsObject()
			if IsValid( phys ) then
				ent:SetGroundEntity(nil)

				phys:Wake()
				phys:ApplyForceCenter( ( direction * Impulse( ent, 200 ) ) + (ent:GetPos() - ply:GetPos()):GetNormalized() * Impulse( ent, 200 ) + vector_up * Impulse( ent, 200 ) )
			end
		end )

		return true // dont do damage
	end

	// blow up rollermines that are too close and knock them off cars
	if ent:GetClass() == "npc_rollermine" then
		timer.Simple( math.Clamp( engine.TickInterval() * delay, 0, 0.5 ), function()
			if not IsValid(self) or not IsValid(ply) or not IsValid(ent) then return end

			if IsValid( ent:GetInternalVariable("m_hVehicleStuckTo") ) then
				ent:Input( "ConstraintBroken" )

				local phys = ent:GetPhysicsObject()
				if IsValid( phys ) then
					ent:SetGroundEntity(nil)

					phys:Wake()
					phys:ApplyForceCenter( ( direction * Impulse( ent, 200 ) ) + (ent:GetPos() - ply:GetPos()):GetNormalized() * Impulse( ent, 200 ) + vector_up * Impulse( ent, 200 ) )
				end

				ParticleEffect( "bo3_thundergun_hit", hitpos or ent:GetPos(), (hitpos - start):Angle() - pcf_ang_correction )
			elseif ent:GetPos():DistToSqr( start ) < 180^2 then
				timer.Simple( 0, function()
					if not IsValid( ent ) or not IsValid( ply ) then return end
					ent:Input( "RespondToExplodeChirp", self:GetOwner(), self )
				end )
			end
		end )
	end
end

function SWEP:ThundergunDamage(ent, kill, hitpos)
	if CLIENT then return end

	local ply = self:GetOwner()
	if not IsValid(ply) then return end

	local norm = (ent:GetPos() - ply:GetPos()):GetNormalized()

	local force = (ent:GetUp()*math.random(18000,24000) + self:GetAimVector()*math.random(14000,20000)) + norm*math.random(32000,36000)
	if not (ent:IsNPC() or ent:IsPlayer() or ent:IsNextBot() or ent:IsVehicle() or ent:IsRagdoll()) then
		ent:SetGroundEntity(nil)
	end

	local damage = DamageInfo()
	damage:SetDamageType(nzombies and DMG_MISSILEDEFENSE or bit.bor(DMG_SONIC, DMG_MISSILEDEFENSE))
	damage:SetAttacker(ply)
	damage:SetInflictor(self)
	damage:SetDamage(( kill and ( ( sv_true_damage and sv_true_damage:GetBool() or nzombies ) and ent:Health() + 666 or self:GetStatL("Primary.Damage") ) ) or 75)
	damage:SetDamageForce(force)
	damage:SetDamagePosition(TFA.WonderWeapon.BodyTarget(ent, ply.GetShootPos and ply:GetShootPos() or ply:EyePos(), true, math.random(16) == 1))
	damage:SetReportedPosition(ply:GetShootPos())

	if nzombies and (ent.NZBossType or ent.IsMooBossZombie or ent.IsMooMiniBoss) then
		damage:SetDamage(math.max(1800, ent:GetMaxHealth() / 8))
		damage:ScaleDamage(math.Round(nzRound:GetNumber()/10))
	end

	if math.random(10) > 5 then
		sound.Play("TFA_BO3_THUNDERGUN.Impact", hitpos)
	end

	ent:TakeDamageInfo(damage)

	if (ent:IsNPC() or ent:IsPlayer() or ent:IsNextBot()) then
		local trace = {["Entity"] = ent, ["Hit"] = true, ["HitPos"] = hitpos or ent:WorldSpaceCenter()}
		self:SendHitMarker(ply, trace, damage)
	end

	if not kill and ent:IsPlayer() then
		ent:SetGroundEntity(nil)
		ent:SetLocalVelocity(ent:GetVelocity() + vector_up*80 + (norm*40))
		ent:SetDSP(32, false)
	end
end

function SWEP:Think2(...)
	if SERVER then
		local nClip = math.Clamp(self:Clip1Adjusted(), 0, 4)
		if self:GetGlowLevel() ~= nClip and TFA.Enum.ReadyStatus[self:GetStatus()] then
			self:SetGlowLevel(nClip)
		end

		local bActive = tobool(self:Clip1() > 0)
		if self:GetMainGlow() ~= bActive and TFA.Enum.ReadyStatus[self:GetStatus()] then
			self:SetMainGlow(bActive)
		end

		if self.Bodygroups_W and self.Bodygroups_W[1] ~= 0 and not TFA.Enum.ReloadStatus[self:GetStatus()] then
			self.Bodygroups_W[1] = 0
		end
	end

	if TFA.Enum.ReadyStatus[self:GetStatus()] and self:GetNextWave() < CurTime() then
		self:SetNextWave(CurTime() + self:SharedRandom(12, 16))
		if IsFirstTimePredicted() then self:EmitSoundNet("TFA_BO3_THUNDERGUN.Idle") end
	end

	return BaseClass.Think2(self, ...)
end

function SWEP:Reload(...)
	if self:Ammo1() < 1 or self:Clip1() > 0 then 
		return
	end
	BaseClass.Reload(self, ...) 
end

function SWEP:PreSpawnProjectile(ent)
	ent:SetUpgraded(self.Ispackapunched)
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