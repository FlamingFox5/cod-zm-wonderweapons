//-------------------------------------------------------------
// Achievements
//-------------------------------------------------------------

local WonderWeapons = TFA.WonderWeapon

local AchievementTable = WonderWeapons.Achievements

if not AchievementTable then return end

local TrophyType = AchievementTable.TrophyTypes

local nzombies = engine.ActiveGamemode() == "nzombies"

WonderWeapons.AddAchievement("BO4_Orion_Penetration_Kills", {
	Name = "Constellation Prize",

	IconPath = "vgui/overlay/achievement/Constellation_Prize.png",

	Trophy = TrophyType.BRONZE,

	Points = 950,

	Call = function( ply, entity, projectile )
		if CLIENT then return end

		if not IsValid( ply ) then return end
		if not IsValid( entity ) then return end
		if not IsValid( projectile ) then return end

		if WonderWeapons.HasAchievement( ply, "BO4_Orion_Penetration_Kills" ) then return end

		if not ( entity:IsNPC() or entity:IsNextBot() or entity:IsPlayer() ) then return end

		if projectile:GetCharged() then return end

		local hookName = "Achievement.BO4_Orion_Penetration_Kills"..entity:EntIndex()
		hook.Add( "PostEntityTakeDamage", hookName, function( postEntity, postDamageinfo, bTook )
			if not IsValid( ply ) then
				hook.Remove( "PostEntityTakeDamage", hookName )
				return
			end

			if ( postEntity == entity ) then
				hook.Remove( "PostEntityTakeDamage", hookName )

				if ( bTook ) and ( postEntity:Health() <= 0 ) then
					if projectile.BO4_Orion_Penetration_Kills == nil then
						projectile.BO4_Orion_Penetration_Kills = 0
					end

					projectile.BO4_Orion_Penetration_Kills = 1 + projectile.BO4_Orion_Penetration_Kills

					if ( projectile.BO4_Orion_Penetration_Kills >= 9 ) then
						WonderWeapons.GiveAchievement( ply, "BO4_Orion_Penetration_Kills" )
					end
				end
			end
		end)
	end,

	Reset = function( ply )
		if not IsValid( ply ) then return end
	end,
})

WonderWeapons.AddAchievement("BO4_Alistair_Shrink_Kills", {
	Name = "Shrinking Feeling",

	IconPath = "vgui/overlay/achievement/Shrinking_Feeling.png",

	Trophy = TrophyType.BRONZE,

	Points = 950,

	Call = function( ply, entity, projectile )
		if CLIENT then return end

		if not IsValid( ply ) then return end
		if not IsValid( entity ) then return end
		if not IsValid( projectile ) then return end

		if WonderWeapons.HasAchievement( ply, "BO4_Alistair_Shrink_Kills" ) then return end

		if not ( entity:IsNPC() or entity:IsNextBot() or entity:IsPlayer() ) then return end

		local hookName = "Achievement.BO4_Alistair_Shrink_Kills"..entity:EntIndex()
		hook.Add( "PostEntityTakeDamage", hookName, function( postEntity, postDamageinfo, bTook )
			if not IsValid( ply ) then
				hook.Remove( "PostEntityTakeDamage", hookName )
				return
			end

			if ( postEntity == entity ) then
				hook.Remove( "PostEntityTakeDamage", hookName )

				if ( bTook ) and ( postEntity:Health() <= 0 ) then
					if projectile.BO4_Alistair_Shrink_Kills == nil then
						projectile.BO4_Alistair_Shrink_Kills = 0
					end

					projectile.BO4_Alistair_Shrink_Kills = 1 + projectile.BO4_Alistair_Shrink_Kills

					if ( projectile.BO4_Alistair_Shrink_Kills >= 15 ) then
						WonderWeapons.GiveAchievement( ply, "BO4_Alistair_Shrink_Kills" )
					end
				end
			end
		end)
	end,
	
	Reset = function( ply )
		if not IsValid( ply ) then return end
	end,
})

WonderWeapons.AddAchievement("BO4_Winters_Freeze_Kills", {
	Name = "Breaking the Ice",

	IconPath = "vgui/overlay/achievement/Breaking_the_Ice.png",

	Trophy = TrophyType.GOLD,

	Points = 2500,

	Call = function( ply, entity )
		if CLIENT then return end

		if not IsValid( ply ) then return end
		if not IsValid( entity ) then return end

		if WonderWeapons.HasAchievement( ply, "BO4_Winters_Freeze_Kills" ) then return end

		if not ( entity:IsNPC() or entity:IsNextBot() or entity:IsPlayer() ) then return end

		if ply.BO4_Winters_Freeze_Kills == nil then
			ply.BO4_Winters_Freeze_Kills = 0
		end

		ply.BO4_Winters_Freeze_Kills = 1 + ply.BO4_Winters_Freeze_Kills

		if ( ply.BO4_Winters_Freeze_Kills >= 115 ) then
			WonderWeapons.GiveAchievement( ply, "BO4_Winters_Freeze_Kills" )
		end
	end,

	Reset = function( ply )
		if not IsValid( ply ) then return end
		ply.BO4_Winters_Freeze_Kills = 0
	end,
})
