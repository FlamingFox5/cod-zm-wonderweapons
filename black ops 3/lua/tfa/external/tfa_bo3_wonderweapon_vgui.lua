//-------------------------------------------------------------
// Spawnmenu Utility Settings
//-------------------------------------------------------------

local WonderWeapons = TFA.WonderWeapon

local function tfaOptionWonderWeapon(panel)
	--Here are whatever default categories you want.
	local tfaOptionSV = {
		Options = {},
		CVars = {},
		Label = "Server Settings",
		MenuButton = "1",
		Folder = "tfa_bo3ww_settings_server"
	}

	tfaOptionSV.Options["#preset.default"] = {
		["sv_tfa_bo3ww_achievements"] = 1,
		["sv_tfa_bo3ww_inf_specialist"] = 0,
		["sv_tfa_bo3ww_friendly_fire"] = 1,
		["sv_tfa_bo3ww_npc_friendly_fire"] = 0,
		["sv_tfa_bo3ww_vehicle_damage"] = 1,
		["sv_tfa_bo3ww_environmental_damage"] = 1,
		["sv_tfa_bo3ww_shrinkray_shrink_players"] = 1,
		["sv_tfa_bo3ww_shrinkray_damage_multiplier"] = 0.2,
		["sv_tfa_bo3ww_shrinkray_shrink_all"] = 0,
		["sv_tfa_bo3ww_monkeybomb_use_los"] = 0,
		["sv_tfa_bo3ww_cod_damage"] = 0,
	}

	tfaOptionSV.CVars = table.GetKeys(tfaOptionSV.Options["#preset.default"])
	panel:AddControl("ComboBox", tfaOptionSV)

	panel:Help("#tfa.settings.server")

	TFA.CheckBoxNet(panel, "Enable Achievements", "sv_tfa_bo3ww_achievements")
	TFA.CheckBoxNet(panel, "Enable Specialist Infinite Ammo", "sv_tfa_bo3ww_inf_specialist")
	TFA.CheckBoxNet(panel, "Enable True CoD Zombie Damage", "sv_tfa_bo3ww_cod_damage")
	TFA.CheckBoxNet(panel, "Players Damage Friendly NPCs", "sv_tfa_bo3ww_friendly_fire")
	TFA.CheckBoxNet(panel, "NPCs Damage Friendly NPCs", "sv_tfa_bo3ww_npc_friendly_fire")

	local tfaOptionVeh = {
		Options = {},
		CVars = {},
		Label = "Vehicle Damage",
		MenuButton = "0",
		Folder = "tfa_bo3ww_settings_vehicle"
	}

	tfaOptionVeh.Options["Disabled"] = {
		sv_tfa_bo3ww_vehicle_damage = "0"
	}

	tfaOptionVeh.Options["Enabled"] = {
		sv_tfa_bo3ww_vehicle_damage = "1"
	}

	tfaOptionVeh.CVars = table.GetKeys(tfaOptionVeh.Options["Enabled"])
	panel:AddControl("ComboBox", tfaOptionVeh)

	TFA.CheckBoxNet(panel, "Damage Non Character Entities", "sv_tfa_bo3ww_environmental_damage")
	TFA.CheckBoxNet(panel, "Enable Shrinking Players", "sv_tfa_bo3ww_shrinkray_shrink_players")
	TFA.CheckBoxNet(panel, "Enable Shrinking Huge and Tiny NPCs", "sv_tfa_bo3ww_shrinkray_shrink_all")
	TFA.NumSliderNet(panel, "Shrunk Entity Damage Mult", "sv_tfa_bo3ww_shrinkray_damage_multiplier", 0, 1, 2)

	TFA.CheckBoxNet(panel, "Monkeybomb Requires LOS", "sv_tfa_bo3ww_monkeybomb_use_los")

	panel:Help("")

	local tfaOptionCL = {
		Options = {},
		CVars = {},
		Label = "Client Settings",
		MenuButton = "1",
		Folder = "tfa_bo3ww_settings_client"
	}

	tfaOptionCL.Options["#preset.default"] = {
		["cl_tfa_bo3ww_crosshair"] = 1,
		["cl_tfa_bo3ww_achievements"] = 1,
		["cl_tfa_bo3ww_screen_visuals"] = 1,
		["cl_tfa_fx_wonderweapon_dlights"] = 1,
		["cl_tfa_fx_wonderweapon_muzzleflash_dlights"] = 1,
		["cl_tfa_fx_wonderweapon_3p"] = 1,
		["cl_tfa_fx_wonderweapon_gibs_max"] = 5,
		["cl_tfa_fx_wonderweapon_gibs_multiplier"] = 1,
	}

	tfaOptionCL.CVars = table.GetKeys(tfaOptionCL.Options["#preset.default"])
	panel:AddControl("ComboBox", tfaOptionCL)

	panel:Help("#tfa.settings.client")

	panel:CheckBox("Enable Custom Crosshair Overrides", "cl_tfa_bo3ww_crosshair")
	panel:CheckBox("Enable Achievements", "cl_tfa_bo3ww_achievements")

	local tfaOptionVisual = {
		Options = {},
		CVars = {},
		Label = "Screen Visuals",
		MenuButton = "0",
		Folder = "tfa_bo3ww_settings_vehicle"
	}

	tfaOptionVisual.Options["Disabled"] = {
		cl_tfa_bo3ww_screen_visuals = "0"
	}

	tfaOptionVisual.Options["Full"] = {
		cl_tfa_bo3ww_screen_visuals = "1"
	}

	tfaOptionVisual.Options["Overlays Only"] = {
		cl_tfa_bo3ww_screen_visuals = "2"
	}

	tfaOptionVisual.Options["Visionset Mod Only"] = {
		cl_tfa_bo3ww_screen_visuals = "3"
	}

	tfaOptionVisual.Options["Visionset & Statuseffect Only"] = {
		cl_tfa_bo3ww_screen_visuals = "4"
	}

	tfaOptionVisual.CVars = table.GetKeys(tfaOptionVisual.Options["Full"])
	panel:AddControl("ComboBox", tfaOptionVisual)

	local tfaOptionDlight = {
		Options = {},
		CVars = {},
		Label = "Dynamic Lights",
		MenuButton = "0",
		Folder = "tfa_bo3ww_settings_dlight"
	}

	tfaOptionDlight.Options["Disabled"] = {
		cl_tfa_fx_wonderweapon_dlights = "0"
	}

	tfaOptionDlight.Options["Full"] = {
		cl_tfa_fx_wonderweapon_dlights = "1"
	}

	tfaOptionDlight.Options["Minimal"] = {
		cl_tfa_fx_wonderweapon_dlights = "2"
	}

	tfaOptionDlight.CVars = table.GetKeys(tfaOptionDlight.Options["Full"])
	panel:AddControl("ComboBox", tfaOptionDlight)

	panel:CheckBox("Enable Muzzleflash Dynamic Light", "cl_tfa_fx_wonderweapon_muzzleflash_dlights")
	panel:CheckBox("Enable Thirdperson Particle Effects", "cl_tfa_fx_wonderweapon_3p")
	panel:NumSlider("Maximum Gibs", "cl_tfa_fx_wonderweapon_gibs_max", 0, 100, 0)
	panel:NumSlider("Gib Count Mult", "cl_tfa_fx_wonderweapon_gibs_multiplier", 0, 20, 0)

	local btnPESMenu = panel:Button("P.E.S. Customization Menu")
	btnPESMenu.DoClick = function()
		RunConsoleCommand("fox_pes_menu")
	end
end

local function tfaAddOption()
	spawnmenu.AddToolMenuOption("Utilities", "TFA SWEP Base Settings", "TFA_BO3WonderWeapon_SV", "Wonder Weapons", "", "", tfaOptionWonderWeapon)
end

hook.Add("PopulateToolMenu", "TFA.BO3WW.FOX.SpawnMenu", tfaAddOption)
