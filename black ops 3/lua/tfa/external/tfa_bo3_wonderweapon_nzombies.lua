local nzombies = engine.ActiveGamemode() == "nzombies"
if not nzombies then return end

if SERVER then
	hook.Add( "WeaponEquip", "NZ.BO3WW.FOX.WeaponEquip", function( weapon )
		if weapon.WWPickupStinger and not weapon.HasEmitEquipSound then
			weapon.HasEmitEquipSound = true

			net.Start("TFA.BO3.QED_SND")
				net.WriteString("Raygun")
			net.Broadcast()
		end
	end )

	hook.Add("OnZombieKilled", "NZ.BO3WW.FOX.OnZombieKilled", function(entity, damageinfo)
		if not IsValid(entity) then return end

		local weapon = damageinfo:GetInflictor()
		local gun = damageinfo:GetWeapon()
		if IsValid(gun) and gun:IsWeapon() and gun.IsTFAWeapon then
			weapon = gun
		end

		if IsValid(weapon) and weapon.GetKillCount and weapon.BO3CanDash and weapon:GetDashing() then
			weapon:SetKillCount(weapon:GetKillCount() + 1)
		end

		if entity:PanzerDGLifted() then
			for _, ply in pairs(player.GetAllPlaying()) do
				if !TFA.WonderWeapon.HasAchievement( ply, "BO3_Panzer_Airborne_Kill" ) then
					TFA.WonderWeapon.NotifyAchievement( "BO3_Panzer_Airborne_Kill", ply, entity )
				end
			end
		end
	end)
end

hook.Add("InitPostEntity", "NZ.BO3WW.FOX.RegisterSpecials", function()
	nzSpecialWeapons:AddSpecialGrenade( "tfa_bo3_gstrike", 3, false, 1.4, false, 0.4 )
	nzSpecialWeapons:AddSpecialGrenade( "tfa_bo3_monkeybomb", 3, false, 2, false, 0.4 )
	nzSpecialWeapons:AddSpecialGrenade( "tfa_bo3_lilarnie", 3, false, 2, false, 0.4 )
	nzSpecialWeapons:AddSpecialGrenade( "tfa_bo3_qed", 3, false, 1.1, false, 0.4 )
	nzSpecialWeapons:AddSpecialGrenade( "tfa_bo3_gersch", 3, false, 1.7, false, 0.4 )
	nzSpecialWeapons:AddSpecialGrenade( "tfa_bo3_matryoshka", 3, false, 1.4, false, 0.4 )

	nzSpecialWeapons:AddDisplay( "tfa_nz_bo3_deathmachine", false, function(wep) return false end )
end)
