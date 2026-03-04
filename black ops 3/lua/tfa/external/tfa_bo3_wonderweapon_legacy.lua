
//----------------------------------------------------------------
// Legacy Functions, DO NOT USE THESE! USE THE NEW SYSTEM INSTEAD!
//----------------------------------------------------------------

if SERVER then
	util.AddNetworkString("TFA.BO3.QED_SND")
	util.AddNetworkString("TFA.BO3.REMOVERAG")

	net.Receive("TFA.BO3.REMOVERAG", function(len, ply)
		local ply = net.ReadEntity()
		if not IsValid( ply ) then return end

		SafeRemoveEntity( ply:GetRagdollEntity() )
	end)

	function TFA.BO3GiveAchievement(description, iconpath, ply, trophy)
		if not IsValid(ply) or not ply:IsPlayer() then
			return
		end
		if description == nil or not isstring(description) or description == "" then
			return
		end
		if not file.Exists( "materials/"..iconpath, "GAME" ) then
			return
		end
		if trophy == nil or not isnumber(trophy) or trophy < 1 or trophy > 3 then
			trophy = 1
		end

		net.Start("TFA.BO3.ACHIEVEMENT", true)
			net.WriteString(description)
			net.WriteString(iconpath)
			net.WriteInt(trophy, 4)
		net.Send(ply)
	end


	hook.Add( "PlayerSpawn", "TFA.BO3WW.FOX.LegacyRemoveRagdoll", function( ply, trans )
		if not IsValid(ply) then return end

		if ply:GetNW2Bool( "RemoveRagdoll", false ) then
			ply:SetNW2Bool( "RemoveRagdoll", false )
		end
	end )

	hook.Add( "CreateEntityRagdoll", "TFA.BO3WW.FOX.LegacyRemoveRagdoll", function( entity, ragdoll )
		if not IsValid( entity ) or not IsValid( ragdoll ) then return end

		if entity:GetNW2Bool( "RemoveRagdoll", false ) then
			TFA.WonderWeapon.SafeRemoveRagdoll( ragdoll, engine.TickInterval() )
		end
	end )
end

TFA.QEDSounds = {
	WeaponTake = "weapons/tfa_bo3/qed/vox/zmb_vox_ann_random_weapon_0.wav",
	MaxAmmo = "weapons/tfa_bo3/qed/vox/zmb_vox_ann_powerup_maxammo_0.wav",
	StealAmmo = "weapons/tfa_bo3/qed/vox/zmb_vox_ann_points_negative.wav",
	WeaponGive = "weapons/tfa_bo3/qed/vox/zmb_vox_ann_random_weapon_1.wav",
	DeathMachine = "weapons/tfa_bo3/qed/vox/death_machine.wav",
	Tesla = "weapons/tfa_bo3/qed/vox/ann_tesla_02.wav",
	Specialist = "weapons/tfa_bo3/dg4/sword_ready_3p.wav",
	MonkeyUpgrade = "weapons/tfa_bo3/monkeybomb/monkey_kill_confirm.wav",
	Shield = "weapons/tfa_bo3/zm_common.all.sabl.4316.wav",
	Raygun = "weapons/tfa_bo3/zm_common.all.sabl.510.wav",
}

if CLIENT then
	net.Receive("TFA.BO3.QED_SND", function(len, ply)
		local event = net.ReadString()
		local snd = TFA.QEDSounds[event]

		surface.PlaySound(snd)
	end)

	net.Receive("TFA.BO3.ACHIEVEMENT", function(len, ply)
		local actext = net.ReadString()
		local acicon = net.ReadString()
		local actype = net.ReadInt(8)

		TFA.WonderWeapon.DoAchievementOverlay( actext, acicon, actype )
	end)

	hook.Add( "CreateClientsideRagdoll", "TFA.BO3WW.FOX.LegacyRemoveRagdoll", function( entity, ragdoll )
		if not IsValid( entity ) or not IsValid( ragdoll ) then return end

		if entity:GetNW2Bool( "RemoveRagdoll", false ) then
			TFA.WonderWeapon.SafeRemoveRagdoll( ragdoll, engine.TickInterval() )
		end
	end )
end

//------------------------------------------------------------------------------
// Legacy Status Effect Functions, DO NOT USE THESE! USE THE NEW SYSTEM INSTEAD!
//------------------------------------------------------------------------------

local ENTITY = FindMetaTable("Entity")

if ENTITY then
	// 31-79 JGb215

	if SERVER then
		ENTITY.BO3Shrink = function(self, duration, upgraded, attacker)
			TFA.WonderWeapon.GiveStatus( self, "BO3_Shrinkray_Shrink", tonumber(duration), attacker, tobool(upgraded) )
		end
	end

	ENTITY.BO3IsShrunk = function(self)
		return TFA.WonderWeapon.HasStatus( self, "BO3_Shrinkray_Shrink" )
	end

	ENTITY.BO3IsKicked = function(self)
		local mStatus = TFA.WonderWeapon.GetStatus( self, "BO3_Shrinkray_Shrink" )
		if not mStatus then return end
		return mStatus:GetKicked()
	end

	// Wavegun

	if SERVER then
		ENTITY.BO3Microwave = function(self, duration, upgraded, inflictor)
			TFA.WonderWeapon.GiveStatus( self, "BO3_Wavegun_Cook", tonumber(duration), attacker, inflictor )
		end
	end

	ENTITY.BO3IsCooking = function(self)
		return TFA.WonderWeapon.HasStatus( self, "BO3_Wavegun_Cook" )
	end

	// Skull of Nan Sapwe Stun

	if SERVER then
		ENTITY.BO3Mystify = function(self, duration)
			TFA.WonderWeapon.GiveStatus( self, "BO3_Skullgun_Stun", tonumber(duration) )
		end
	end

	ENTITY.BO3IsMystified = function(self)
		return TFA.WonderWeapon.HasStatus( self, "BO3_Skullgun_Stun" )
	end

	// Skull of Nan Sapwe Kill

	if SERVER then
		ENTITY.BO3SkullStun = function(self, duration, attacker, inflictor)
			TFA.WonderWeapon.GiveStatus( self, "BO3_Skullgun_Kill", tonumber(duration), attacker, inflictor )
		end
	end

	ENTITY.BO3IsSkullStund = function(self)
		return TFA.WonderWeapon.HasStatus( self, "BO3_Skullgun_Kill" )
	end

	ENTITY.BO3SkullStunEndTime = function(self)
		local mStatus = TFA.WonderWeapon.GetStatus( self, "BO3_Skullgun_Kill" )
		if not mStatus then return end
		return mStatus:GetEndTime()
	end

	ENTITY.BO3SkullStunStartTime = function(self)
		local mStatus = TFA.WonderWeapon.GetStatus( self, "BO3_Skullgun_Kill" )
		if not mStatus then return end
		return mStatus:GetStartTime()
	end

	// Widows Wine Webbed

	if SERVER then
		ENTITY.BO3SpiderWeb = function(self, duration, attacker)
			TFA.WonderWeapon.GiveStatus( self, "BO3_WidowsWine_Web", tonumber(duration), attacker )
		end
	end

	ENTITY.BO3IsWebbed = function(self)
		return TFA.WonderWeapon.HasStatus( self, "BO3_WidowsWine_Web" )
	end

	// KT-4 Infected

	if SERVER then
		ENTITY.BO3Spore = function(self, duration, attacker, inflictor, upgraded, damage)
			TFA.WonderWeapon.GiveStatus( self, "BO3_KT4_Infection", tonumber(duration), attacker, inflictor, tonumber(damage), tobool(upgraded))
		end
	end

	ENTITY.BO3IsSpored = function(self)
		return TFA.WonderWeapon.HasStatus( self, "BO3_KT4_Infection" )
	end

	// Apothicon Servant Pull

	if SERVER then
		ENTITY.BO3PortalPull = function(self, duration, attacker, inflictor, vector)
			TFA.WonderWeapon.GiveStatus( self, "BO3_Portal_Pull", tonumber(duration), attacker, inflictor, vector)
		end
	end

	ENTITY.BO3IsPulledIn = function(self)
		return TFA.WonderWeapon.HasStatus( self, "BO3_Portal_Pull" )
	end

	// Ragnarok DG4 Boss Lifting

	if SERVER then
		ENTITY.PanzerDGLift = function(self, duration)
			TFA.WonderWeapon.GiveStatus( self, "BO3_Ragnarok_Lift_Boss", tonumber(duration) )
		end
	end

	ENTITY.PanzerDGLifted = function(self)
		return TFA.WonderWeapon.HasStatus( self, "BO3_Ragnarok_Lift_Boss" )
	end
end