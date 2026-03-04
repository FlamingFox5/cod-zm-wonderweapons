local SinglePlayer = game.SinglePlayer()

nzHackerDevice:AddUtility("func_door", {
	HintString = function( self, owner, entity )
		return "Hack Door"
	end,
	
	Price = function( self, owner, entity )
		return 200
	end,
	
	Duration = function( self, owner, entity )
		return 30
	end,
	
	Condition = function( self, owner, entity )
		if entity.GetDoorData then
			local doorData = entity:GetDoorData()
			if doorData and istable(doorData) and doorData.buyable ~= nil then
				return tobool(doorData.buyable)
			end
		end

		return false
	end,
	
	OnActivate = function( self, owner, entity )
		if SERVER then
			local data = entity:GetDoorData()
			if !data then return end

			local datalink = data.link
			if datalink then
				nzDoors:OpenLinkedDoors(datalink, owner)
			else
				nzDoors:OpenDoor(entity)
			end

			owner:TakePoints(200, true)
		end

		entity:EmitSound("TFA_BO3_HACKER.Success")
	end,

	LinkedClasses = {"func_door_rotating", "prop_door_rotating"},
})

nzHackerDevice:AddUtility("player", {
	HintString = function( self, owner, entity )
		return "Give "..entity:Nick().." 500 Points"
	end,
	
	Price = function( self, owner, entity )
		return 500
	end,
	
	Duration = function( self, owner, entity )
		return 7
	end,
	
	Condition = function( self, owner, entity )
		return true
	end,
	
	OnActivate = function( self, owner, entity )
		if SERVER then
			entity:GivePoints(500, true)
			owner:TakePoints(500, true)
		end

		entity:EmitSound("TFA_BO3_HACKER.Success")
	end,
})

nzHackerDevice:AddUtility("prop_buys", {
	HintString = function( self, owner, entity )
		return "Hack Blockade"
	end,
	
	Price = function( self, ply, entity )
		return 200
	end,
	
	Duration = function( self, owner, entity )
		return 30
	end,
	
	Condition = function( self, owner, entity )
		if entity.GetDoorData then
			local doorData = entity:GetDoorData()
			if doorData and istable(doorData) and doorData.buyable ~= nil then
				return tobool(doorData.buyable)
			end
		end

		return false
	end,
	
	OnActivate = function( self, owner, entity )
		if SERVER then
			local data = entity:GetDoorData()
			if !data then return end

			local datalink = data.link
			if datalink then
				nzDoors:OpenLinkedDoors(datalink, owner)
			else
				nzDoors:OpenDoor(entity)
			end

			owner:TakePoints(200, true)
		end

		entity:EmitSound("TFA_BO3_HACKER.Success")
	end,

	LinkedClasses = {"wall_block"},
})

nzHackerDevice:AddUtility("nz_buildtable", {
	HintString = function( self, owner, entity )
		return "Complete Buildable"
	end,
	
	Price = function( self, owner, entity )
		return 0
	end,
	
	Duration = function( self, owner, entity )
		return 2.5
	end,
	
	Condition = function( self, owner, entity )
		return !entity:GetBrutusLocked() and !entity:GetCompleted() and entity:GetRemainingParts() <= 0 and !nzRound:InState(ROUND_CREATE)
	end,
	
	OnActivate = function( self, owner, entity )
		if SERVER then
			for k, v in pairs(ents.FindByClass("nz_buildable")) do
				if v:GetBuildable() == entity:GetBuildable() then
					if !v:GetActivated() then
						v:Trigger()
					else
						nzBuilds:UpdateHeldParts(v)
					end
				end
			end

			for k, v in pairs(ents.FindByClass("nz_digsite")) do
				if v:GetOverride() and v:GetBuildable() == entity:GetBuildable() and not v:GetActivated() then
					v:Trigger()
				end
			end

			entity:StopParticles()

			entity:StopSound(entity.BuildLoopSound or "NZ.Buildable.Craft.Loop")
			if not entity.ClassicSounds then
				entity:StopSound("NZ.Buildable.Craft.LoopSweet")
			end

			if IsValid(entity.CraftedModel) then
				ParticleEffect("nzr_building_poof", entity.CraftedModel:WorldSpaceCenter(), angle_zero)
				entity.CraftedModel:Reset()
			end

			if IsValid(entity.CraftedModel2) then
				entity.CraftedModel2:Reset()
			end

			entity:SetCompleted(true)

			entity:EmitSound(entity.BuildEndSound or "NZ.Buildable.Craft.Finish")
			if not entity.ClassicSounds then
				entity:EmitSound("NZ.Buildable.Craft.FinishSweet")
			end

			owner:GivePoints(2000, true)
		end

		entity:EmitSound("TFA_BO3_HACKER.Success")
	end,
})

nzHackerDevice:AddUtility("nz_hackerbutton", {
	HintString = function( self, owner, entity )
		return "Hack Button"
	end,
	
	Price = function( self, owner, entity )
		return 0
	end,
	
	Duration = function( self, owner, entity )
		return entity.GetTime and entity:GetTime() or 4
	end,
	
	Condition = function( self, owner, entity )
		return entity.GetHaxLock and ( entity:GetHaxLock() == 0 ) or false
	end,
	
	OnActivate = function( self, owner, entity )
		if SERVER then
		end

		entity:EmitSound("TFA_BO3_HACKER.Success")
	end,
})

nzHackerDevice:AddUtility("nz_bo3_hackerbutton", {
	HintString = function( self, owner, entity )
		local hintString = entity.GetHintString and entity:GetHintString() or ""
		if hintString ~= nil and hintString ~= "" then
			return hintString
		end

		return "Hack"
	end,
	
	Price = function( self, owner, entity )
		return entity.GetPrice and entity:GetPrice() or 0
	end,
	
	Duration = function( self, owner, entity )
		return entity.GetTime and entity:GetTime() or 4
	end,
	
	Condition = function( self, owner, entity )
		return entity.Hackable and entity:Hackable() or false
	end,
	
	OnActivate = function( self, owner, entity )
		if SERVER and entity.Hack then
			entity:Hack( owner )
		end

		entity:EmitSound("TFA_BO3_HACKER.Success")
	end,
})

nzHackerDevice:AddUtility("breakable_entry", {
	HintString = function( self, owner, entity )
		return "Hack Barricade"
	end,
	
	Price = function( self, owner, entity )
		return 0
	end,
	
	Duration = function( self, owner, entity )
		return 5
	end,
	
	Condition = function( self, owner, entity )
		return entity:GetHasPlanks() and ( GetConVar("nz_difficulty_barricade_planks_max"):GetInt() > entity:GetNumPlanks() )
	end,
	
	OnActivate = function( self, owner, entity )
		if SERVER then
			entity:ResetPlanks(true)

			if self.LastBoardRepairRound and nzRound:GetNumber() ~= self.LastBoardRepairRound then
				self.BoardsRepaired = 0
				self.LastBoardRepairRound = nzRound:GetNumber()
			else
				if self.LastBoardRepairRound == nil then
					self.LastBoardRepairRound = nzRound:GetNumber()
				end
				self.BoardsRepaired = self.BoardsRepaired + 1
			end

			if self.BoardsRepaired < 4 then
				owner:GivePoints(100, true)
			else
				owner:TakePoints(50, true)
			end
		end

		entity:EmitSound("TFA_BO3_HACKER.Success")
	end,
})

nzHackerDevice:AddUtility("perk_machine", {
	HintString = function( self, owner, entity )
		if entity:GetPerkID() == "pap" then
			if IsValid( ents.FindByName( "pap_gatef" )[1] ) then
				return "Hack Pack-a-Punch"
			end

			return ""
		else
			local perkData = nzPerks:Get( entity:GetPerkID() )
			local perktype = nzPerks:GetMachineType( nzMapping.Settings.perkmachinetype )
			local perkname = {
				["IW"] = "name_skin",
				["VG"] = "name_vg",
			}

			local perkname = perkData.name
			local customname = perkname[ perktype ]
			if customname and perkData[ customname ] then
				perkname = perkData[ customname ]
			end

			return "Refund " .. perkname .. " [" .. string.Comma(entity:GetPrice()) .. "]"
		end
	end,
	
	Price = function( self, owner, entity )
		return 0
	end,
	
	Duration = function( self, owner, entity )
		return 5
	end,
	
	Condition = function( self, owner, entity )
		return ( entity:GetPerkID() == "pap" and IsValid( ents.FindByName( "pap_gatef" )[1] ) ) or owner:HasPerk( entity:GetPerkID() )
	end,
	
	OnActivate = function( self, owner, entity )
		if SERVER then
			if entity:GetPerkID() == "pap" then
				local door1 = ents.FindByName("pap_gatel")[1]
				local door2 = ents.FindByName("pap_gatef")[1]
				local door3 = ents.FindByName("pap_gater")[1]

				if IsValid(door1) then
					door1:Fire("Open", nil, engine.TickInterval(), owner, owner)
					door2:Fire("Open", nil, engine.TickInterval(), owner, owner)
					door3:Fire("Open", nil, engine.TickInterval(), owner, owner)

					owner:GivePoints(1000, true)

					timer.Simple(30, function() 
						if not IsValid(door1) then return end
						door1:Fire("Close")
						door2:Fire("Close")
						door3:Fire("Close")
					end)
				end
			else
				owner:RemovePerk( entity:GetPerkID() )
				owner:GivePoints( entity:GetPrice(), true )

				owner:EmitSound("TFA_BO3_HACKER.Throwup")
			end
		end

		entity:EmitSound("TFA_BO3_HACKER.Success")
	end,
})

nzHackerDevice:AddUtility("drop_powerup", {
	HintString = function( self, owner, entity )
		if entity.GetAnti and entity:GetAnti() then
			return "Cleanse Power-Up"
		elseif entity:GetPowerUp() == "firesale" then
			return "Convert to "..nzPowerUps:Get("bonfiresale").name
		elseif entity:GetPowerUp() == "maxammo" then
			return "Convert to "..nzPowerUps:Get("firesale").name
		else
			return "Convert to "..nzPowerUps:Get("maxammo").name
		end

		return "Hack Power-Up"
	end,
	
	Price = function( self, owner, entity )
		return 5000
	end,
	
	Duration = function( self, owner, entity )
		return 4
	end,
	
	Condition = function( self, owner, entity )
		if IsValid(entity:GetParent()) then
			return false
		end
		if entity.GetActivated then
			return entity:GetActivated()
		else
			return true
		end
	end,
	
	OnActivate = function( self, owner, entity )
		if SERVER then
			local vecPowerUpOffset = Vector(0,0,50)

			if entity.GetAnti and entity:GetAnti() then
				nzPowerUps:SpawnPowerUp(entity:GetPos() - vecPowerUpOffset, entity:GetPowerUp())
				entity:Remove()
			elseif entity:GetPowerUp() == "firesale" then
				nzPowerUps:SpawnPowerUp(entity:GetPos() - vecPowerUpOffset, "bonfiresale")
				entity:Remove()
			elseif entity:GetPowerUp() == "maxammo" then
				nzPowerUps:SpawnPowerUp(entity:GetPos() - vecPowerUpOffset, "firesale")
				entity:Remove()
			else
				nzPowerUps:SpawnPowerUp(entity:GetPos() - vecPowerUpOffset, "maxammo")
				entity:Remove()
			end

			owner:TakePoints(5000, true)
		end

		entity:EmitSound("TFA_BO3_HACKER.Success")
	end,
})

nzHackerDevice:AddUtility("wall_buys", {
	HintString = function( self, owner, entity )
		local weaponData = weapons.Get(entity:GetWepClass())
		if weaponData then
			local bHacked = entity:GetHacked()
			local nPrice = entity:GetPrice()

			local ammo_price = math.ceil( ( nPrice - ( nPrice % 10 ) ) / 2 )
			local ammo_price_pap = 4500

			local printName = weaponData.PrintName
			// name ends with 's'
			if string.Right(printName, 1) == "s" then
				if bHacked then
					return "Revert "..printName.."' Price - Ammo ["..string.Comma(ammo_price).."], Upgraded Ammo ["..string.Comma(ammo_price_pap).."]"
				else
					return "Flip "..printName.."' Price - Upgraded Ammo ["..string.Comma(ammo_price).."], Ammo ["..string.Comma(ammo_price_pap).."]"
				end
			else
				if bHacked then
					return "Revert "..printName.."'s Price - Ammo ["..string.Comma(ammo_price).."], Upgraded Ammo ["..string.Comma(ammo_price_pap).."]"
				else
					return "Flip "..printName.."'s Price - Upgraded Ammo ["..string.Comma(ammo_price).."], Ammo ["..string.Comma(ammo_price_pap).."]"
				end
			end
		else
			return "Hack Wall Weapon"
		end
	end,

	Price = function( self, owner, entity )
		if entity.GetHacked and entity:GetHacked() then
			return 0
		end
		return 3000
	end,
	
	Duration = function( self, owner, entity )
		return 2.5
	end,
	
	Condition = function( self, owner, entity )
		if entity.GetHacked then
			return entity.GetBought and entity:GetBought() or false
		end
		return false
	end,
	
	OnActivate = function( self, owner, entity )
		if SERVER then
			local ang = entity:GetAngles()
			ang:RotateAroundAxis(ang:Up(), 180)
			ang:RotateAroundAxis(ang:Right(), 180)
			
			local bWasHacked = entity:GetHacked()

			entity:SetAngles(ang)
			entity:SetHacked(not entity:GetHacked())

			if not bWasHacked then
				owner:TakePoints(3000, true)
			end
		end

		entity:EmitSound("TFA_BO3_HACKER.Success")
	end,
})

nzHackerDevice:AddUtility("random_box_windup", {
	HintString = function( self, owner, entity )
		if self:GetNW2Bool("HackerWindupReroll", false) then
			return "Drop "..weapons.Get(entity:GetWepClass()).PrintName.." as a Power-Up"
		end
		return "Reroll "..weapons.Get(entity:GetWepClass()).PrintName
	end,
	
	Price = function( self, owner, entity )
		return 600
	end,
	
	Duration = function( self, owner, entity )
		return 2
	end,
	
	Condition = function( self, owner, entity )
		return !entity:GetWinding() and !entity:GetIsTeddy()
	end,
	
	OnActivate = function( self, owner, entity )
		if SERVER then
			local box = entity.Box
			if not IsValid(box) then return end

			if box.GunHacked then
				local weap = ents.Create("nz_bo3_drop_weapon")
				weap:SetGun(entity:GetWepClass())
				weap:SetPos(entity:GetPos() + box:GetUp()*12)
				weap:SetAngles(entity:GetAngles())
				weap:Spawn()

				box:Close()
				entity:Remove()

				owner:GivePoints(nzMapping.Settings.rboxprice or 950, true)

				box.GunHacked = nil
				self:SetNW2Bool("HackerWindupReroll", false)

				box:RemoveCallOnRemove("HackerRerollFix."..box:EntIndex())
			else
				entity:Remove()
				box:Close()

				box:BuyWeapon(owner)
				owner:GivePoints(math.max((nzMapping.Settings.rboxprice or 950) - math.Round((nzMapping.Settings.rboxprice or 950)*0.63157894737), 5))

				box.GunHacked = self
				self.HackedBoxEntity = box
				self:SetNW2Bool("HackerWindupReroll", true)

				box:CallOnRemove("HackerRerollFix."..box:EntIndex(), function( removed )
					local hacker = removed.GunHacked
					if IsValid( hacker ) and IsValid( hacker.HackedBoxEntity ) and hacker.HackedBoxEntity == removed and hacker:GetNW2Bool("HackerWindupReroll", false) then
						hacker:SetNW2Bool("HackerWindupReroll", false)
					end
				end)
			end
		end

		entity:EmitSound("TFA_BO3_HACKER.Success")
	end,
})

nzHackerDevice:AddUtility("random_box_spawns", {
	HintString = function( self, owner, entity )
		if self:GetNW2Bool("HackerWindupReroll", false) then
			return "Drop "..weapons.Get(entity:GetWepClass()).PrintName.." as a Power-Up"
		end
		return "Reroll "..weapons.Get(entity:GetWepClass()).PrintName
	end,
	
	Price = function( self, owner, entity )
		return 1200
	end,
	
	Duration = function( self, owner, entity )
		return 4
	end,
	
	Condition = function( self, owner, entity )
		local box = ents.FindByClass("random_box")[1]
		local bBoxed = false

		local trace = util.QuickTrace( entity:WorldSpaceCenter(), vector_up*12, entity )
		local hitEntity = trace.Entity

		if IsValid(hitEntity) and hitEntity:GetClass() == "random_box" then
			bBoxed = true
		end

		return IsValid(box) and !bBoxed and !box:GetOpen() and ( box.GetActivated and box:GetActivated() or box.GetActivated == nil )
	end,
	
	OnActivate = function( self, owner, entity )
		if SERVER then
			local box = ents.FindByClass("random_box")[1]
			if IsValid(box) and !box:GetOpen() then
				box:MarkForRemoval()

				local rboxSpawns = ents.FindByClass("random_box_spawns")
				for _, rbox in pairs( rboxSpawns ) do
					if rbox.PossibleSpawn then
						rbox.StoredPossibleSpawn = true
						rbox.PossibleSpawn = false
					end
					rbox:SetBodygroup( 1, 0 )
					rbox.Box = nil
				end

				entity.PossibleSpawn = true

				nzRandomBox.Spawn( box.SpawnPoint, true )

				timer.Simple( engine.TickInterval(), function()
					for _, rbox in pairs( rboxSpawns ) do
						if rbox.StoredPossibleSpawn then
							rbox.StoredPossibleSpawn = nil
							rbox.PossibleSpawn = true
						end
					end

					if IsValid( entity ) and IsValid( owner ) then
						entity.PossibleSpawn = false
						entity.Box:BuyWeapon( owner )
						owner:TakePoints( math.max( 1200 - ( nzMapping.Settings.rboxprice or 950 ), 0 ), true )
					end
				end )
			end
		end

		entity:EmitSound("TFA_BO3_HACKER.Success")
	end,
})

nzHackerDevice:AddUtility("cod_plantedshield", {
	HintString = function( self, owner, entity )
		local shieldOwner = entity:GetOwner()
		if IsValid(shieldOwner) then
			return "Repair "..( shieldOwner.Nick and shieldOwner:Nick() or string.NiceName( shieldOwner:GetClass() ) ).."'s Shield"
		else
			return "Repair Shield"
		end
	end,
	
	Price = function( self, owner, entity )
		return 1000
	end,
	
	Duration = function( self, owner, entity )
		return 3
	end,
	
	Condition = function( self, owner, entity )
		return true
	end,
	
	OnActivate = function( self, owner, entity )
		if entity.Bakuretsu then
			entity:Bakuretsu()
		end

		if SERVER then
			entity:SetHealth( entity:GetMaxHealth() )
			entity:SetBodygroup( 0, 0 )
			entity.Damage = 0

			owner:TakePoints( 1000, true )
		end

		entity:EmitSound("TFA_BO3_HACKER.Success")
	end,
})

nzHackerDevice:AddUtility("prop_thumper", {
	HintString = function( self, owner, entity )
		return "Toggle Thumer"
	end,
	
	Price = function( self, owner, entity )
		return 0
	end,
	
	Duration = function( self, owner, entity )
		return 7
	end,
	
	Condition = function( self, owner, entity )
		return true
	end,
	
	OnActivate = function( self, owner, entity )
		if SERVER then
			entity:Fire("Disable")
		end

		entity:EmitSound("TFA_BO3_HACKER.Success")
	end,
})

nzHackerDevice:AddUtility("item_healthcharger", {
	HintString = function( self, owner, entity )
		return "Recharge Health Charger"
	end,
	
	Price = function( self, owner, entity )
		return 500
	end,
	
	Duration = function( self, owner, entity )
		return 10
	end,
	
	Condition = function( self, owner, entity )
		return true
	end,
	
	OnActivate = function( self, owner, entity )
		if SERVER then
			entity:Fire("Recharge")
		end

		entity:EmitSound("TFA_BO3_HACKER.Success")
	end,
})

nzHackerDevice:AddUtility("item_suitcharger", {
	HintString = function( self, owner, entity )
		return "Recharge Suit Charger"
	end,
	
	Price = function( self, owner, entity )
		return entity:HasSpawnFlags( 8192 ) and 1000 or 500
	end,
	
	Duration = function( self, owner, entity )
		return entity:HasSpawnFlags( 8192 ) and 10 or 5
	end,
	
	Condition = function( self, owner, entity )
		return true
	end,
	
	OnActivate = function( self, owner, entity )
		if SERVER then
			if IsValid(owner) and owner:IsPlayer() then
				owner:TakePoints( entity:HasSpawnFlags( 8192 ) and 1000 or 500, true )
			end
			entity:Fire("Recharge")
		end

		entity:EmitSound("TFA_BO3_HACKER.Success")
	end,
})
