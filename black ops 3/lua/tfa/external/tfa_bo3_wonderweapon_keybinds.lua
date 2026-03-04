if CLIENT then
	local akimbo = {
		["tfa_bo3_zapgun"] = true,
		["tfa_bo3_gkzmk3"] = true,
	}
	local sword = {
		["tfa_bo3_zodsword"] = true,
		["tfa_bo3_keepersword"] = true,
	}

	hook.Add("TFA_PopulateKeyBindHints", "BO3.TFA.WW.KeyHints", function(wep, keys)	
		if akimbo[wep:GetClass()] then
			if wep.Akimbo then
				table.insert(keys, 1, {
					label = "Left Gun",
					keys = {wep:GetKeyBind({"+attack"})}
				})
				table.insert(keys, 2, {
					label = "Right Gun",
					keys = {wep:GetKeyBind({"+attack2"})}
				})
			end

			for k, v in pairs(keys) do //no saftey cause im worthless as a coder
				if v.label == "Toggle Safety" then
					table.remove(keys, k)
				end
			end
		end

		if wep:GetClass() == "tfa_bo3_skullgun" then
			table.insert(keys, 1, {
				label = "Vaporize",
				keys = {wep:GetKeyBind({"+attack"})}
			})
			table.insert(keys, 2, {
				label = "Mesmerize",
				keys = {wep:GetKeyBind({"+attack2"})}
			})

			for k, v in pairs(keys) do
				if v.label == "Toggle Safety" then
					table.remove(keys, k)
					break
				end
			end
		end

		if wep:GetClass() == "tfa_bo3_hacker" then
			table.insert(keys, 1, {
				label = "Hack",
				keys = {wep:GetKeyBind({"+use"})}
			})
			table.remove(keys, 3)
		end

		if wep:GetClass() == "tfa_bo3_gauntlet" then
			table.insert(keys, 1, {
				label = wep.up_hat and "Flamethrower" or "Rocket Punch",
				keys = {wep:GetKeyBind({"+attack"})}
			})
			table.insert(keys, 2, {
				label = wep.up_hat and "Launch Whelp" or "Recal Whelp",
				keys = {wep:GetKeyBind({"+attack2"})}
			})
			table.insert(keys, 3, {
				label = "Melee Attack",
				keys = {wep:GetKeyBind({"+zoom"}, "bash")},
			})

			for k, v in pairs(keys) do
				if v.label == "Toggle Safety" then
					table.remove(keys, k)
					break
				end
			end
			table.remove(keys, 4) //fake secondary
		end

		if sword[wep:GetClass()] then
			table.insert(keys, 1, {
				label = "Slash",
				keys = {wep:GetKeyBind({"+attack"})}
			})
			if wep:GetClass() == "tfa_bo3_keepersword" then
				table.insert(keys, 2, {
					label = "Unleash the Archon Sword",
					keys = {wep:GetKeyBind({"+attack2"})}
				})
			end
			if wep:GetClass() == "tfa_bo3_zodsword" then
				table.insert(keys, 2, {
					label = "Lightning Slam",
					keys = {wep:GetKeyBind({"+attack2"})}
				})
			end
			table.insert(keys, 3, {
				label = "Melee Attack",
				keys = {wep:GetKeyBind({"+zoom"}, "bash")},
			})

			table.remove(keys, 4)
			table.remove(keys, 5)
		end

		if wep:GetClass() == "tfa_bo3_dg4" then
			table.insert(keys, 1, {
				label = "Shock Slam",
				keys = {wep:GetKeyBind({"+attack"})},
			})
			table.insert(keys, 2, {
				label = "Power Plant",
				keys = {wep:GetKeyBind({"+attack2"})},
			})
			table.insert(keys, 3, {
				label = "Melee Attack",
				keys = {wep:GetKeyBind({"+zoom"}, "bash")},
			})

			table.remove(keys, 4) //fake secondary
			table.remove(keys, 5)
		end
	end)
end
