//-------------------------------------------------------------
// Achievements
//-------------------------------------------------------------

local WonderWeapons = TFA.WonderWeapon

local AchievementTable = WonderWeapons.Achievements

local TrophyType = AchievementTable.TrophyTypes

local nzombies = engine.ActiveGamemode() == "nzombies"

WonderWeapons.AddAchievement("BO3_Scavenger_Long_Range", {
	Name = "Shooting on Location",

	IconPath = "vgui/overlay/achievement/scavenger.png",

	Trophy = TrophyType.BRONZE,

	Points = 950,

	Call = function( ply, entity, projectile )
		if CLIENT then return end

		if not IsValid( ply ) then return end
		if not IsValid( entity ) then return end
		if WonderWeapons.HasAchievement( ply, "BO3_Scavenger_Long_Range" ) then return end
		if not ( entity:IsNPC() or entity:IsNextBot() or entity:IsPlayer() ) then return end

		local hookName = "Achievement.BO3_Scavenger_Long_Range"..entity:EntIndex()
		hook.Add( "PostEntityTakeDamage", hookName, function( postEntity, postDamageinfo, bTook )
			if not IsValid( ply ) then
				hook.Remove( "PostEntityTakeDamage", hookName )
				return
			end

			if ( postEntity == entity ) then
				hook.Remove( "PostEntityTakeDamage", hookName )

				if ( bTook ) and ( postEntity:Health() <= 0 ) and ( ply:GetPos():Distance(projectile:GetPos()) > 1600 ) then
					if projectile.BO3_Scavenger_Long_Range_Kills == nil then
						projectile.BO3_Scavenger_Long_Range_Kills = 0
					end

					projectile.BO3_Scavenger_Long_Range_Kills = 1 + projectile.BO3_Scavenger_Long_Range_Kills

					if ( projectile.BO3_Scavenger_Long_Range_Kills >= 6 ) then
						WonderWeapons.GiveAchievement( ply, "BO3_Scavenger_Long_Range" )
					end
				end
			end
		end)
	end,

	Reset = function( ply )
		if not IsValid( ply ) then return end
	end,
})

WonderWeapons.AddAchievement("BO3_Shrinkray_Variety", {
	Name = "Small Consolation",

	IconPath = "vgui/overlay/achievement/shrinkray.png",

	Trophy = TrophyType.BRONZE,

	Points = 950,

	Call = function( ply, entity )
		if CLIENT then return end

		if not IsValid( ply ) then return end
		if not IsValid( entity ) then return end
		if WonderWeapons.HasAchievement( ply, "BO3_Shrinkray_Variety" ) then return end
		if not ( entity:IsNPC() or entity:IsNextBot() or entity:IsPlayer() ) then return end

		if not AchievementTable.ShrinkrayClasses then
			AchievementTable.ShrinkrayClasses = {}
		end

		if not AchievementTable.ShrinkrayClasses[ ply:SteamID64() ] then
			AchievementTable.ShrinkrayClasses[ ply:SteamID64() ] = {}
		end

		if not AchievementTable.ShrinkrayClasses[ ply:SteamID64() ][ entity:GetClass() ] then
			AchievementTable.ShrinkrayClasses[ ply:SteamID64() ][ entity:GetClass() ] = true
		end

		if table.Count(AchievementTable.ShrinkrayClasses[ ply:SteamID64() ]) >= 4 then
			WonderWeapons.GiveAchievement( ply, "BO3_Shrinkray_Variety" )
		end
	end,
	
	Reset = function( ply )
		if not IsValid( ply ) then return end

		if not AchievementTable.ShrinkrayClasses then
			AchievementTable.ShrinkrayClasses = {}
		end

		AchievementTable.ShrinkrayClasses[ ply:SteamID64() ] = {}
	end,
})

WonderWeapons.AddAchievement("BO3_Gersh_Kills", {
	Name = "They are going THROUGH!",

	IconPath = "vgui/overlay/achievement/blackhole.png",

	Trophy = TrophyType.BRONZE,

	Points = 950,

	Call = function( ply, entity, projectile )
		if CLIENT then return end

		if not IsValid( ply ) then return end
		if not IsValid( entity ) then return end
		if WonderWeapons.HasAchievement( ply, "BO3_Gersh_Kills" ) then return end
		if not ( entity:IsNPC() or entity:IsNextBot() ) then return end

		if projectile.BO3_Gersh_Kills == nil then
			projectile.BO3_Gersh_Kills = 0
		end

		projectile.BO3_Gersh_Kills = 1 + projectile.BO3_Gersh_Kills

		if ( projectile.BO3_Gersh_Kills >= 6 ) then
			WonderWeapons.GiveAchievement( ply, "BO3_Gersh_Kills" )
		end
	end,

	Reset = function( ply )
		if not IsValid( ply ) then return end
	end,
})

WonderWeapons.AddAchievement("BO3_KT4_Infection", {
	Name = "Crop Duster",

	IconPath = "vgui/overlay/achievement/mirg2000.png",

	Trophy = TrophyType.BRONZE,

	Points = 950,

	Call = function( ply, entity )
		if CLIENT then return end

		if not IsValid( ply ) then return end
		if not IsValid( entity ) then return end
		if WonderWeapons.HasAchievement( ply, "BO3_KT4_Infection" ) then return end
		if not ( entity:IsNPC() or entity:IsNextBot() or entity:IsPlayer() ) then return end

		if ply.BO3_KT4_Infections == nil then
			ply.BO3_KT4_Infections = 0
		end

		ply.BO3_KT4_Infections = 1 + ply.BO3_KT4_Infections

		if ( ply.BO3_KT4_Infections >= 10 ) then
			WonderWeapons.GiveAchievement( ply, "BO3_KT4_Infection" )
		end
	end,

	Reset = function( ply )
		if not IsValid( ply ) then return end
		ply.BO3_KT4_Infections = 0
	end,
})

WonderWeapons.AddAchievement("BO3_Panzer_Airborne_Kill", {
	Name = "Not Big Enough",

	IconPath = "vgui/overlay/achievement/panzer.png",

	Trophy = TrophyType.SILVER,

	Points = 2250,

	Call = function( ply, entity )
		if CLIENT then return end

		if not IsValid( ply ) then return end
		if not IsValid( entity ) then return end
		if WonderWeapons.HasAchievement( ply, "BO3_Panzer_Airborne_Kill" ) then return end
		if not ( entity:IsNPC() or entity:IsNextBot() or entity:IsPlayer() ) then return end

		if ply:GetPos():DistToSqr( entity:GetPos() ) <= 3240000 then // 1800 units
			WonderWeapons.GiveAchievement( ply, "BO3_Panzer_Airborne_Kill" )
		end
	end,

	Reset = function( ply )
		if not IsValid( ply ) then return end
	end,
})

WonderWeapons.AddAchievement("BO3_Hacker_First_Use", {
	Name = "One Small Hack for a Man...",

	IconPath = "vgui/overlay/achievement/hacker.png",

	Trophy = TrophyType.BRONZE,

	Points = 950,

	Call = function( ply )
		if CLIENT then return end

		if not IsValid( ply ) then return end
		if WonderWeapons.HasAchievement( ply, "BO3_Hacker_First_Use" ) then return end

		WonderWeapons.GiveAchievement( ply, "BO3_Hacker_First_Use" )
	end,

	Reset = function( ply )
		if not IsValid( ply ) then return end
	end,
})

WonderWeapons.AddAchievement("UGX_Boss_Gersh_Teleport", {
	Name = "They can teleport too!?",

	IconPath = "vgui/overlay/achievment/Full_Lockdown.png",

	Trophy = TrophyType.BRONZE,

	Points = 950,

	Call = function( ply )
		if CLIENT then return end

		if not IsValid( ply ) then return end
		if WonderWeapons.HasAchievement( ply, "UGX_Boss_Gersh_Teleport" ) then return end

		WonderWeapons.GiveAchievement( ply, "UGX_Boss_Gersh_Teleport" )
	end,

	Reset = function( ply )
		if not IsValid( ply ) then return end
	end,
})
