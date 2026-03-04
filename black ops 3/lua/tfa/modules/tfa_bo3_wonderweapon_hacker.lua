local nzombies = engine.ActiveGamemode() == "nzombies"
local pvp_cvar = GetConVar("sbox_playershurtplayers")
local SinglePlayer = game.SinglePlayer()

//-------------------------------------------------------------
// Hacker Device
//-------------------------------------------------------------

local WonderWeapons = TFA.WonderWeapon

WonderWeapons.HackerDevice = WonderWeapons.HackerDevice or {}

local HackerTable = WonderWeapons.HackerDevice

HackerTable.Utilities = HackerTable.Utilities or {}

local HackerUtilities = HackerTable.Utilities

function WonderWeapons.AddHackerUtility( class, data )
	HackerUtilities[ class ] = data

	if data.LinkedClasses and istable( data.LinkedClasses ) then
		for _, linkedclass in pairs( data.LinkedClasses ) do
			HackerUtilities[ linkedclass ] = data
		end
	end
end

function WonderWeapons.HackerUtilityData( class )
	return HackerUtilities[ class ] or nil
end

WonderWeapons.AddHackerUtility("func_door", {
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
		return true
	end,
	
	OnActivate = function( self, owner, entity )
		if SERVER then
			entity:Fire("unlock", "", .01)
			entity:Fire("Open")
		end

		entity:EmitSound("TFA_BO3_HACKER.Success")
	end,

	LinkedClasses = {"func_door_rotating", "prop_door_rotating"},
})

WonderWeapons.AddHackerUtility("player", {
	HintString = function( self, owner, entity )
		return "Heal "..entity:Nick()
	end,
	
	Price = function( self, owner, entity )
		return 500
	end,
	
	Duration = function( self, owner, entity )
		return 7
	end,
	
	Condition = function( self, owner, entity )
		return owner:Armor() > 0 and ( entity:Health() < entity:GetMaxHealth() )
	end,
	
	OnActivate = function( self, owner, entity )
		if SERVER then
			local armor = owner:Armor()
			local hp = entity:Health()
			local maxhp = entity:GetMaxHealth()
			local diff = math.Clamp( maxhp - hp, 0, armor * 2 )

			owner:SetArmor( math.max( math.Round( armor - ( diff / 2 ) ), 0 ) )
			entity:SetHealth( math.Clamp( hp + diff, hp, maxhp ) )
		end

		entity:EmitSound("TFA_BO3_HACKER.Success")
	end,
})

WonderWeapons.AddHackerUtility("prop_thumper", {
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

WonderWeapons.AddHackerUtility("item_healthcharger", {
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

WonderWeapons.AddHackerUtility("item_suitcharger", {
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
			entity:Fire("Recharge")
		end

		entity:EmitSound("TFA_BO3_HACKER.Success")
	end,
})

WonderWeapons.AddHackerUtility("cod_plantedshield", {
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
		return owner:Armor() >= 50
	end,
	
	OnActivate = function( self, owner, entity )
		if entity.Bakuretsu then
			entity:Bakuretsu()
		end

		if SERVER then
			entity:SetHealth( entity:GetMaxHealth() )
			entity:SetBodygroup( 0, 0 )
			entity.Damage = 0

			owner:SetArmor( math.max( owner:Armor() - 50, 0 ) )
		end

		entity:EmitSound("TFA_BO3_HACKER.Success")
	end,
})

local passive = {
	"npc_seagull", "npc_crow", "npc_piegon",  "monster_cockroach",
	"npc_dog", "npc_gman", "npc_antlion_grub",
	-- "monster_scientist", -- Can't attack, but does run away
	"monster_nihilanth", -- Doesn't attack from spawn menu, so not allowing to change his dispositions
	"npc_turret_floor" -- Uses a special input for this sort of stuff
}

local friendly = {
	"npc_monk", "npc_alyx", "npc_barney", "npc_citizen",
	"npc_turret_floor", "npc_dog", "npc_vortigaunt",
	"npc_kleiner", "npc_eli", "npc_magnusson", "npc_breen", "npc_mossman", -- They can use SHOTGUNS!
	"npc_fisherman", -- He sorta can use shotgun
	"monster_barney", "monster_scientist"
}

local hostile = {
	"npc_turret_ceiling", "npc_combine_s", "npc_combinegunship", "npc_combinedropship",
	"npc_cscanner", "npc_clawscanner", "npc_turret_floor", "npc_helicopter", "npc_hunter", "npc_manhack",
	"npc_stalker", "npc_rollermine", "npc_strider", "npc_metropolice", "npc_turret_ground",
	"npc_cscanner", "npc_clawscanner", "npc_combine_camera", -- These are friendly to enemies

	"monster_human_assassin", "monster_human_grunt", "monster_turret", "monster_miniturret", "monster_sentry"
}

local monsters = {
	"npc_antlion", "npc_antlion_worker", "npc_antlionguard", "npc_barnacle", "npc_fastzombie", "npc_fastzombie_torso",
	"npc_headcrab", "npc_headcrab_fast", "npc_headcrab_black", "npc_headcrab_poison", "npc_poisonzombie", "npc_zombie", "npc_zombie_torso", "npc_zombine",
	"monster_alien_grunt", "monster_alien_slave", "monster_babycrab", "monster_headcrab", "monster_bigmomma", "monster_bullchicken", "monster_barnacle",
	"monster_alien_controller", "monster_gargantua", "monster_nihilanth", "monster_snark", "monster_zombie", "monster_tentacle", "monster_houndeye"
}

local NPCsThisWorksOn = {}

local function RecalcUsableNPCs()
	-- Not resetting NPCsThisWorksOn as you can't remove classes from the tables below
	-- Not including passive monsters here, you can't make them hostile or friendly
	for _, class in pairs( friendly ) do NPCsThisWorksOn[ class ] = true end
	for _, class in pairs( hostile ) do NPCsThisWorksOn[ class ] = true end
	for _, class in pairs( monsters ) do NPCsThisWorksOn[ class ] = true end
end

local friendliedNPCs = {}
local hostaliziedNPCs = {}

local function SetRelationships( ent, tab, status )
	for id, fnpc in pairs( tab ) do
		if ( !IsValid( fnpc ) ) then table.remove( tab, id ) continue end
		fnpc:AddEntityRelationship( ent, status, 999 )
		ent:AddEntityRelationship( fnpc, status, 999 )
	end
end

local function ProcessOtherNPC( ent )
	if ( table.HasValue( friendly, ent:GetClass() ) && !table.HasValue( hostaliziedNPCs, ent ) ) then -- It's a friendly that isn't made hostile
		SetRelationships( ent, friendliedNPCs, D_LI )
		SetRelationships( ent, hostaliziedNPCs, D_HT )
	elseif ( table.HasValue( hostile, ent:GetClass() ) && !table.HasValue( friendliedNPCs, ent ) ) then -- It's a hostile that isn't made friendly
		SetRelationships( ent, friendliedNPCs, D_HT )
		SetRelationships( ent, hostaliziedNPCs, D_LI )
	elseif ( table.HasValue( monsters, ent:GetClass() ) && !table.HasValue( friendliedNPCs, ent ) && !table.HasValue( hostaliziedNPCs, ent ) ) then -- It's a monster that isn't made friendly or hostile to the player
		SetRelationships( ent, friendliedNPCs, D_HT )
		SetRelationships( ent, hostaliziedNPCs, D_HT )
	end
end

local master_npc_list = {}
table.Add(master_npc_list, friendly)
table.Add(master_npc_list, hostile)
table.Add(master_npc_list, monsters)

WonderWeapons.AddHackerUtility("npc_monk", {
	HintString = function( self, owner, entity )
		return "Convert "..( string.NiceName( entity:GetClass() ) ).." to Ally"
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
			RecalcUsableNPCs()

			if entity:GetClass() == "npc_turret_floor" then
				entity:Fire("SelfDestruct")
				return
			end

			if ( entity:IsNPC() && !table.HasValue( passive, entity:GetClass() ) && NPCsThisWorksOn[ entity:GetClass() ] ) then 
				table.insert( friendliedNPCs, entity )
				table.RemoveByValue( hostaliziedNPCs, entity )

				-- Remove the NPC from any squads so the console doesn't spam. TODO: Add a suffix like _friendly instead?
				entity:Fire( "SetSquad", "" )

				-- Special case for stalkers
				if ( entity:GetClass() == "npc_stalker" ) then
					entity:SetSaveValue( "m_iPlayerAggression", 0 )
				end

				-- Is this even necessary anymore?
				for id, class in pairs( friendly ) do entity:AddRelationship( class .. " D_LI 999" ) end
				for id, class in pairs( monsters ) do entity:AddRelationship( class .. " D_HT 999" ) end
				for id, class in pairs( hostile ) do entity:AddRelationship( class .. " D_HT 999" ) end

				SetRelationships( entity, friendliedNPCs, D_LI )
				SetRelationships( entity, hostaliziedNPCs, D_HT )

				for id, oent in pairs( ents.GetAll() ) do
					if ( oent:IsNPC() && oent != entity ) then ProcessOtherNPC( oent ) end
				end

				entity:Activate()
			end
		end

		entity:EmitSound("TFA_BO3_HACKER.Success")
	end,

	LinkedClasses = table.Copy(master_npc_list)
})

if SERVER and !nzombies then
	// Disable default source engine +USE behavior when holding the Hacker Device
	//  nzombies overrides this anyways but its still usefull for sandbox

	hook.Add("AllowPlayerPickup", "TFA.BO3WW.FOX.Hacker.AllowPlayerPickup", function(ply, ent)
		local wep = ply:GetActiveWeapon()

		if IsValid(wep) and wep.IsTFAWeapon and wep.BO3CanHack then
			return false
		end
	end)

	hook.Add("PlayerUse", "TFA.BO3WW.FOX.Hacker.PlayerUse", function(ply, ent)
		if not IsValid(ply) or not IsValid(ent) then return end
		local wep = ply:GetActiveWeapon()
		if not IsValid(wep) then return end

		if IsValid(wep) and wep.IsTFAWeapon and wep.BO3CanHack then
			return false
		end
	end)
end