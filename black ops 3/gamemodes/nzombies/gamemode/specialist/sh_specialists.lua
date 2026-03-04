if SERVER then
	hook.Add( "EntityTakeDamage", "NZ.BO4WW.FOX.Specialists.DamageResist", function( ply, damageinfo )
		if not IsValid( ply ) then return end
		if not ply:IsPlayer() then return end

		local wep = ply:GetActiveWeapon()
		if not IsValid( wep ) then return end

		local resistData = wep.NZSpecialistResistanceData
		if resistData and istable( resistData ) then
			local damageTypes = resistData.Types
			local damageRatio = resistData.Percent or 0.9
			local damageMin = resistData.MinimumDamage or 10

			if not damageTypes or not isnumber( damageTypes ) then return end

			if bit.band( damageinfo:GetDamageType(), damageTypes ) ~= 0 then
				local nRatio = math.Clamp( 1 - damageRatio, 0, 1 )
				damageinfo:SetDamage( math.max( damageinfo:GetDamage() * nRatio, math.min( damageMin, dmginfo:GetDamage() ) ) )
			end
		end

		if wep:GetClass() == "tfa_bo4_pathofsorrow" then //melee resist
			if bit.band(dmginfo:GetDamageType(), bit.bor(DMG_SLASH, DMG_CRUSH, DMG_CLUB, DMG_VEHICLE)) ~= 0 then
				dmginfo:SetDamage(math.min(dmginfo:GetDamage()*0.1, 10))
			end
		end

		if wep:GetClass() == "tfa_bo4_overkill" then //bullet/blast resist
			if bit.band(dmginfo:GetDamageType(), bit.bor(DMG_BULLET, DMG_AIRBOAT, DMG_BUCKSHOT, DMG_BLAST, DMG_BLAST_SURFACE, DMG_SONIC, DMG_VEHICLE)) ~= 0 then
				dmginfo:SetDamage(math.min(dmginfo:GetDamage()*0.1, 10))
			end
		end

		if wep:GetClass() == "tfa_bo4_dg5" then //shock/energy resist
			if bit.band(dmginfo:GetDamageType(), bit.bor(DMG_SHOCK, DMG_SONIC, DMG_PLASMA, DMG_ENERGYBEAM, DMG_DISSOLVE, DMG_PARALYZE, DMG_VEHICLE)) ~= 0 then
				dmginfo:SetDamage(math.min(dmginfo:GetDamage()*0.1, 10))
			end
		end

		if wep:GetClass() == "tfa_bo4_hellfire" then //fire/burning resist
			if bit.band(dmginfo:GetDamageType(), bit.bor(DMG_BURN, DMG_SLOWBURN, DMG_VEHICLE)) ~= 0 then
				if ply:IsOnFire() then ply:Extinguish() end
				dmginfo:SetDamage(math.min(dmginfo:GetDamage()*0.1, 10))
			end
		end
	end )

	hook.Add("OnPlayerPickupPowerUp", "NZ.BO3WW.FOX.Specialist.Refill", function( _, id, ent)
		if id == "maxammo" then
			for _, ply in ipairs(player.GetAll()) do
				for _, wep in pairs(ply:GetWeapons()) do
					if wep.IsTFAWeapon and wep.NZSpecialCategory == "specialist" then
						wep:SetClip1(wep.Primary.ClipSize)

						if wep.OnSpecialistRecharged then
							wep:OnSpecialistRecharged()
							wep:CallOnClient("OnSpecialistRecharged", "")
						end
						hook.Run("OnSpecialistRecharged", wep)

						if ply:GetActiveWeapon() ~= wep then
							wep:ResetFirstDeploy()
							wep:CallOnClient("ResetFirstDeploy", "")
						end

						net.Start("TFA.BO3.QED_SND")
							net.WriteString("Specialist")
						net.Send(ply)
					end
				end
			end
		end
	end)

	hook.Add("OnZombieKilled", "NZ.BO3WW.FOX.Specialist.OnKill", function(npc, dmginfo)
		local attacker = dmginfo:GetAttacker()
		local inflictor = dmginfo:GetInflictor()
		if not IsValid(attacker) or not IsValid(inflictor) then return end
		if not attacker:IsPlayer() then return end

		for _, wep in pairs(attacker:GetWeapons()) do
			if wep.IsTFAWeapon and wep.NZSpecialCategory == "specialist" and inflictor:GetClass() ~= wep:GetClass() then
				if wep:Clip1() < wep:GetStatL("Primary.ClipSize") then
					local clipsize = wep:GetStatL("Primary.ClipSize")

					if wep:Clip1() == clipsize then return end
					local amount = wep.AmmoRegen or 1
					if attacker:HasPerk("time") then
						amount = math.Round(amount * 2)
					end

					wep:SetClip1(math.Min(wep:Clip1() + amount, clipsize))

					if wep:Clip1() >= clipsize then
						if wep.OnSpecialistRecharged then
							wep:OnSpecialistRecharged()
							wep:CallOnClient("OnSpecialistRecharged", "")
						end
						hook.Run("OnSpecialistRecharged", wep, attacker, inflictor)

						if attacker:GetActiveWeapon() ~= wep and wep.IsTFAWeapon then
							wep:ResetFirstDeploy()
							wep:CallOnClient("ResetFirstDeploy", "")
						end

						net.Start("TFA.BO3.QED_SND")
							net.WriteString("Specialist")
						net.Send(attacker)
					end
				end
			end
		end
	end)
end

hook.Add("InitPostEntity", "NZ.BO3WW.FOX.Specialist.Key", function()
	nzSpecialWeapons:RegisterSpecialWeaponCategory("specialist", KEY_X)
end)

hook.Add("PlayerSwitchWeapon", "NZ.BO3WW.FOX.Specialist.SwitchWeapon", function(ply, oldWep, newWep)
	if not IsValid(ply) or not IsValid(oldWep) then return end

	if oldWep.IsTFAWeapon and oldWep.NZSpecialCategory == "specialist" then
		if oldWep:Clip1() ~= oldWep.Primary.ClipSize then
			oldWep:SetClip1(math.min(oldWep:Clip1(), oldWep:GetStatL("Primary.ClipSize")/2))
		end
	end

	if newWep.IsTFAWeapon and newWep.NZSpecialCategory == "specialist" then
		if newWep:Clip1() < newWep:GetStatL("Primary.ClipSize") then
			return true
		end
	end
end)
