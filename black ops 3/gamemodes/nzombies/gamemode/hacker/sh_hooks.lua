
if SERVER then
	hook.Add("AllowPlayerPickup", "NZ.BO3WW.FOX.Hacker.AllowPlayerPickup", function(ply, ent)
		local wep = ply:GetActiveWeapon()

		if IsValid(wep) and wep.IsTFAWeapon and wep.BO3CanHack then
			return false
		end
	end)

	hook.Add("PlayerUse", "NZ.BO3WW.FOX.Hacker.PlayerUse", function(ply, ent)
		if not IsValid(ply) or not IsValid(ent) then return end
		local wep = ply:GetActiveWeapon()
		if not IsValid(wep) then return end

		if IsValid(wep) and wep.IsTFAWeapon and wep.BO3CanHack then
			return false
		end
	end)

	hook.Add("OnRoundStart", "NZ.BO3WW.FOX.Hacker.RoundStartMoney", function()
		local round = tonumber( nzRound:GetNumber() )

		for _, ply in ipairs( player.GetAll() ) do
			local wep = ply:GetWeapon("tfa_bo3_hacker")

			if IsValid( wep ) and wep.equipment_got_in_round then
				local rounds_kept = ( round - wep.equipment_got_in_round )

				if round > 10 and rounds_kept > 0 then
					rounds_kept = math.min( rounds_kept, 5 )
					local score = rounds_kept * 100
					ply:GivePoints( score )
				end

				break
			end
		end
	end)

	hook.Add("OnRoundEnd", "NZ.BO3WW.FOX.Hacker.GameOver", function()
		if nzRound:InState( ROUND_CREATE ) or nzRound:InState( ROUND_GO ) then
			for k, v in pairs( ents.FindByClass("nz_bo3_hacker") ) do
				v:Remove()
			end

			for k, v in pairs( ents.FindByClass("wall_buys") ) do
				if v.GetHacked and v:GetHacked() then
					local ang = v:GetAngles()
					ang:RotateAroundAxis( ang:Up(), 180 )
					ang:RotateAroundAxis( ang:Right(), 180 )

					v:SetAngles( ang )
					v:SetHacked( false )
				end
			end
		end
	end)
end

hook.Add("PostConfigLoad", "NZ.BO3WW.FOX.Hacker.Remove", function()
	if nzRound:InState( ROUND_CREATE ) or nzRound:InState( ROUND_GO ) then
		for k, v in pairs( ents.FindByClass("nz_bo3_hacker") ) do
			v:Remove()
		end
	end
end)

hook.Add("OnGameBegin", "NZ.BO3WW.FOX.Hacker.InitialSpawn", function(nzRound)
	if not IsValid(ents.FindByClass("nz_bo3_hacker")[1]) then
		hook.Call("RespawnHackerDevice")
	end
end)

hook.Add("RespawnHackerDevice", "NZ.BO3WW.FOX.Hacker.Respawn", function()
	if (nzRound:InState(ROUND_CREATE) or nzRound:InState(ROUND_GO)) then return end

	local hacker_spawns = {}
	for _, v in pairs(ents.FindByClass("nz_bo3_hacker_spawn")) do
		table.insert(hacker_spawns, {
			pos = v:GetPos(),
			angle = v:GetAngles(),
		})
	end
	if #hacker_spawns <= 0 then print("no hacker spawns found") return end

	print("The hacker has been removed from the game. Spawning it again.")

	local spawn = hacker_spawns[math.random(#hacker_spawns)]
	local hacker = ents.Create("nz_bo3_hacker")
	hacker:SetModel("models/weapons/tfa_bo3/hacker/hacker_prop.mdl")
	hacker:SetPos(spawn.pos)
	hacker:SetAngles(spawn.angle)
	hacker:Spawn()
end)
