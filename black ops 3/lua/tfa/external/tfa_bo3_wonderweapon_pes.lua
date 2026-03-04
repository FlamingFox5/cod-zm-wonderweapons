//-------------------------------------------------------------
// Pressure Suit Helmet System
//-------------------------------------------------------------

// SERVER

local nzombies = engine.ActiveGamemode() == "nzombies"

if SERVER then
	util.AddNetworkString( "TFA.BO3WW.FOX.PressureSuit.ToServer" )
	util.AddNetworkString( "TFA.BO3WW.FOX.PressureSuit.ToClient" )

	net.Receive( "TFA.BO3WW.FOX.PressureSuit.ToServer", function( length, ply )
		local nSteam64 = net.ReadUInt64()
		local pesOffsets = net.ReadTable()

		net.Start( "TFA.BO3WW.FOX.PressureSuit.ToClient" )
			net.WriteUInt64( nSteam64 )
			net.WriteTable( pesOffsets )
		net.SendOmit( ply )
	end )

	return
end

// CLIENT

local WonderWeapons = TFA.WonderWeapon

WonderWeapons.PressureSuitOffsets = {}
WonderWeapons.PressureSuitBlacklist = {}

//-------------------------------------------------------------
// Rendering Functionality
//-------------------------------------------------------------

local cl_screenvisuals = GetConVar("cl_tfa_bo3ww_screen_visuals")

hook.Add("RenderScreenspaceEffects", "TFA.BO3WW.FOX.PES.Screenspace",function()
	if !nzombies and cl_screenvisuals ~= nil and ( cl_screenvisuals:GetInt() ~= 1 and cl_screenvisuals:GetInt() ~= 2 ) then
		return
	end

	local ply = LocalPlayer()
	if not IsValid(ply) then return end
	if IsValid( ply:GetObserverTarget() ) then
		ply = ply:GetObserverTarget()
	end

	if ply:GetNW2Bool( "PESEnabled", false ) and ply:HasWeapon( 'tfa_bo3_pes' ) and not ply:ShouldDrawLocalPlayer() then
		DrawMaterialOverlay( "vgui/overlay/pes_overlay", 1 )
	end
end)

local default_offsets = {
	[1] = 0, // Forward/Backwards
	[2] = 0, // Left/Right
	[3] = 0, // Up/Down
	[4] = 1, // Scale X
	[5] = 1, // Scale Y
	[6] = 1, // Scale Z
	[7] = 0, // Pitch
	[8] = 0, // Yaw
	[9] = 0, // Roll
	[10] = "ValveBiped.Bip01_Head1", // Bone
}

local MATERIAL_VAR_DEBUG = 1
local MATERIAL_VAR_ALPHATEST = 256
local MATERIAL_VAR_MODEL = 2048
local MATERIAL_VAR_NOCULL = 8192
local MATERIAL_VAR_ALLOWALPHATOCOVERAGE = 536870912

local cl_psuitplayercolor = GetConVar("cl_tfa_bo3ww_pes_playercolor")
local cl_psuittranslucent = GetConVar("cl_tfa_bo3ww_pes_msaa_translucent")
local cl_psuitdisabled = GetConVar("cl_tfa_bo3ww_pes_hide_model")

local vecVisorColor = Vector(1, .5, .1)

G_IMatSuitVisor = CreateMaterial("PressureSuitVisor", "VertexLitGeneric", {
	["$basetexture"] = "models/weapons/tfa_bo3/pes/i_c_t7_zm_dlchd_moon_pressuresuit_visor_d",
	["$bumpmap"] = "models/weapons/tfa_bo3/pes/i_c_t7_zm_dlchd_moon_pressuresuit_visor_n",
	["$phongexponenttexture"] = "models/weapons/tfa_bo3/pes/i_c_t7_zm_dlchd_moon_pressuresuit_visor_s",
	["$alphatest"] = "0",
	["$allowalphatocoverage"] = "1",

	["$phong"] = "1",
	["$phongboost"] = "25",
	["$phongfresnelranges"]	= "[.78 .9 1]",
	["$phongtint"] = "[1 .5 .1]",

	["$envmap"]	= "env_cubemap",
	["$envmaptint"]	= "[1 .5 .1]",
	["$normalmapalphaenvmapmask"]= "1",
	["$envmapfresnel"]= "1",
} )

G_PressureSuitHelmet = ClientsideModel( "models/weapons/tfa_bo3/pes/w_pes.mdl" )
G_PressureSuitHelmet:SetNoDraw( true )

hook.Add( "PostPlayerDraw" , "TFA.BO3WW.FOX.PES.DrawHelmet", function( ply, flags )
	if cl_psuitdisabled:GetBool() then
		return
	end

	if not IsValid( ply ) or not ply:Alive() then return end

	if ply:GetNW2Bool( "PESEnabled", false ) and ply:HasWeapon( 'tfa_bo3_pes' ) then
		local playerdata = WonderWeapons.PressureSuitOffsets[ ply:SteamID64() ] or default_offsets
		local blacklistdata = WonderWeapons.PressureSuitBlacklist[ ply:SteamID64() ] or 0

		// completely block the blacklisted player
		if tonumber( blacklistdata ) > 1 then
			return
		end

		local strBoneName = playerdata[ 10 ]
		local nHeadBone = ply:LookupBone( strBoneName or "ValveBiped.Bip01_Head1" )
		if nHeadBone then
			local matrix = ply:GetBoneMatrix( nHeadBone )
			if matrix then
				local pos = matrix:GetTranslation()
				local ang = matrix:GetAngles()

				local modelScale = Vector( 1, 1, 1 )
				modelScale:Mul( ply:GetModelScale() )

				local vecScale = Vector( playerdata[4], playerdata[5], playerdata[6] )
				local vecOffset = ( ang:Right() * playerdata[1] ) + ( ang:Up() * playerdata[2] ) + ( ang:Forward() * playerdata[3] )

				// ignore any custom offsets of the blacklisted player
				if tonumber( blacklistdata ) > 0 then
					vecScale = Vector( 1, 1, 1 )
					vecOffset = Vector()
				end

				local matScale = Matrix()
				matScale:Scale(vecScale)
				matScale:Scale(modelScale)

				pos = pos + ( ang:Forward() * ( 2.5 * modelScale ) ) + ( ang:Right() * ( 1.5 * modelScale ) ) + vecOffset

				ang:RotateAroundAxis( ang:Right(), -90 )
				ang:RotateAroundAxis( ang:Up(), -90 )

				ang:RotateAroundAxis( ang:Right(), playerdata[7] )
				ang:RotateAroundAxis( ang:Up(), playerdata[8] )
				ang:RotateAroundAxis( ang:Forward(), playerdata[9] )

				local retVal = hook.Run("TFA_WonderWeapon_PreDrawPressureSuitHelmet", ply, G_PressureSuitHelmet, pos, ang, matScale, matrix )
				if retVal ~= nil and tobool( retVal ) then // return true in hook to stop rendering of PES helmet for given player
					return
				end

				if cl_psuittranslucent:GetBool() then
					G_IMatSuitVisor:SetInt( "$flags", bit.bor( MATERIAL_VAR_ALPHATEST, MATERIAL_VAR_ALLOWALPHATOCOVERAGE, MATERIAL_VAR_NOCULL ) )
				end

				if cl_psuitplayercolor:GetBool() then
					local vecPlyColor = ply:GetPlayerColor()
					G_IMatSuitVisor:SetVector( "$phongtint", vecPlyColor )
					G_IMatSuitVisor:SetVector( "$envmaptint", vecPlyColor )
					G_IMatSuitVisor:SetVector( "$color2", vecPlyColor )
				end

				G_PressureSuitHelmet:SetSubMaterial( 6, "!PressureSuitVisor" )

				G_PressureSuitHelmet:EnableMatrix( "RenderMultiply", matScale )

				G_PressureSuitHelmet:SetPos( pos )
				G_PressureSuitHelmet:SetAngles( ang )

				G_PressureSuitHelmet:SetRenderOrigin( pos )
				G_PressureSuitHelmet:SetRenderAngles( ang )

				G_PressureSuitHelmet:SetupBones()
				G_PressureSuitHelmet:DrawModel()

				G_PressureSuitHelmet:SetRenderOrigin()
				G_PressureSuitHelmet:SetRenderAngles()

				G_IMatSuitVisor:SetVector( "$phongtint", vecVisorColor )
				G_IMatSuitVisor:SetVector( "$envmaptint", vecVisorColor )
				G_IMatSuitVisor:SetVector( "$color2", Vector( 1, 1, 1 ) )
				G_IMatSuitVisor:SetInt( "$flags", MATERIAL_VAR_DEBUG )

				G_PressureSuitHelmet:SetSubMaterial( 6, nil )
			end
		end
	end
end )

// credit to garrys mod playermodel selector & LibertyForce's enhanced playermodel selector

// https://github.com/Facepunch/garrysmod/blob/master/garrysmod/gamemodes/sandbox/gamemode/editor_player.lua
// https://github.com/LibertyForce-Gmod/Enhanced-PlayerModel-Selector/blob/master/lua/autorun/lf_playermodel_selector.lua

//-------------------------------------------------------------
// Menu
//-------------------------------------------------------------

local Menu = { }
local window
local default_animations = { "idle_all_01", "menu_combine", "pose_standing_02", "menu_gman" }
local currentanim = 0
local LocalData = { }
local SaveData = { }
local Blacklist = { }

local color_background = Color(100, 100, 100, 127)
local color_hidden = Color(200, 200, 200, 127)

local vecVisorColor = Vector(1, .5, .1)

if !file.Exists("fox_wonderweapons", "DATA") then
	file.CreateDir("fox_wonderweapons")
end

if file.Exists( "fox_wonderweapons/pes_data.txt", "DATA" ) then
	local pes_data = file.Read( "fox_wonderweapons/pes_data.txt", "DATA" )
	local loaded = util.JSONToTable( pes_data )
	if istable( loaded ) then
		for name, data in pairs( loaded ) do
			SaveData[ tostring( name ) ] = data
		end
		loaded = nil
	end
end

if file.Exists( "fox_wonderweapons/pes_blacklist.txt", "DATA" ) then
	local pes_blacklist = file.Read( "fox_wonderweapons/pes_blacklist.txt", "DATA" )
	local loaded = util.JSONToTable( pes_blacklist )
	if istable( loaded ) then
		for steamid, value in pairs( loaded ) do
			Blacklist[ tonumber( steamid ) ] = tonumber( value )
		end
		loaded = nil
	end
end

local lastmodel = ""
local lastupdate = 0

hook.Add( "Think", "TFA.BO3WW.FOX.PES.OffsetUpdate", function()
	local ply = LocalPlayer()
	if IsValid( ply ) then
		local curmodel = string.lower( ply:GetModel() )
		if lastmodel and curmodel and tostring( lastmodel ) ~= tostring( curmodel ) then
			lastmodel = curmodel

			local modeldata = SaveData[ curmodel ] or WonderWeapons.PressureSuitDefaults[ curmodel ]
			if modeldata then
				WonderWeapons.PressureSuitOffsets[ ply:SteamID64() ] = table.Copy( modeldata )

				if !LocalData[ curmodel ] then
					LocalData[ curmodel ] = {}
				end

				LocalData[ curmodel ] = table.Copy( modeldata )
			else
				WonderWeapons.PressureSuitOffsets[ ply:SteamID64() ] = table.Copy( default_offsets )
			end

			local strWaitTimer = "WonderWeapons.PES.UpdateWaiter"
			local nWait = ( lastupdate + 2 ) > CurTime() and 2 or 0

			if timer.Exists( strWaitTimer ) then
				timer.Remove( strWaitTimer )
			end

			timer.Create( strWaitTimer, nWait, 1, function()
				if game.SinglePlayer() and not IsValid( ply ) then
					return
				end

				local nSteam64 = ply:SteamID64()
				local pesOffsets = WonderWeapons.PressureSuitOffsets[ ply:SteamID64() ]

				if not pesOffsets or not istable( pesOffsets ) then
					return
				end

				net.Start( "TFA.BO3WW.FOX.PressureSuit.ToServer" )
					net.WriteUInt64( nSteam64 )
					net.WriteTable( pesOffsets )
				net.SendToServer()
			end )

			lastupdate = CurTime()
		end
	end
end )

local function KeyboardOn( pnl )
	if ( IsValid( window ) and IsValid( pnl ) and pnl:HasParent( window ) ) then
		window:SetKeyboardInputEnabled( true )
	end
end
hook.Add( "OnTextEntryGetFocus", "TFA.BO3WW.FOX.PES.GetFocus", KeyboardOn )

local function KeyboardOff( pnl )
	if ( IsValid( window ) and IsValid( pnl ) and pnl:HasParent( window ) ) then
		window:SetKeyboardInputEnabled( false )
	end
end
hook.Add( "OnTextEntryLoseFocus", "TFA.BO3WW.FOX.PES.LoseFocus", KeyboardOff )

function Menu.Setup()
	local ply = LocalPlayer()
	if not IsValid( ply ) then return end

	local fw, fh = math.min( ScrW() - 16, 960 ), math.min( ScrH() - 16, 700 )
	local scale = ( ScrW() / 1920 + 1 ) / 2

	local ourcolor = color_background	
	if ply.GetPlayerColor then
		ourcolor = ply:GetPlayerColor():ToColor()
	end

	local curOffsets = WonderWeapons.PressureSuitOffsets[ ply:SteamID64() ] or default_offsets

	window = vgui.Create( "DFrame" )
	window:SetSize( fw, fh )
	window:SetVisible( true )
	window:SetDraggable( true )
	window:SetScreenLock( false )
	window:ShowCloseButton( true )
	window:SetTitle( ply:GetInfo("cl_playermodel") )
	window:Center()
	window:MakePopup()
	window:SetKeyboardInputEnabled( false )

	window.btnMinim:SetEnabled( false )
	window.btnMaxim:SetEnabled( false )
	window.btnMinim:SetVisible( false )
	window.btnMaxim:SetVisible( false )

	Menu.Window = window
	Menu.DragEnabled = true
	Menu.Pos = Vector( -100, 0, -61 )
	Menu.Angles = Angle( 0, 0, 0 )

	window.Paint = function( self, w, h )
		draw.RoundedBox( 10, 0, 0, w, h, ColorAlpha( ourcolor, 90 ) )
		return true
	end

	local mdl = window:Add( "DModelPanel" )
	mdl:Dock( FILL )
	mdl:SetFOV( 36 )
	mdl:SetCamPos( Vector( 0, 0, 0 ) )
	mdl:SetDirectionalLight( BOX_RIGHT, Color( 255, 160, 80, 255 ) )
	mdl:SetDirectionalLight( BOX_LEFT, Color( 80, 160, 255, 255 ) )
	mdl:SetAmbientLight( Vector( -64, -64, -64 ) )
	mdl:SetAnimated( true )
	mdl:SetLookAt( Vector( -100, 0, -22 ) )

	mdl.Angles = Angle( 0, 0, 0 )
	mdl.Pos = Vector( -100, 0, -61 )

	function mdl:DefaultPos()
		mdl.Angles = Angle( 0, 0, 0 )
		mdl.Pos = Vector( -100, 0, -61 )
		mdl.Drag = 0
	end

	function mdl:PlayAnimation()
		if ( !mdl or !IsValid( mdl.Entity ) ) then return end

		local anim = default_animations[ math.random( #default_animations ) ]

		local iSeq = mdl.Entity:LookupSequence( anim )
		if ( iSeq > 0 ) then
			mdl.Entity:ResetSequence( iSeq )
		end
	end

	function Menu.Save()
		local ply = LocalPlayer()
		local model = ply:GetInfo( "cl_playermodel" )
		local modelname = string.lower( player_manager.TranslatePlayerModel( model ) )

		local modeldata = LocalData[ modelname ] or WonderWeapons.PressureSuitDefaults[ modelname ]
		if modeldata then
			WonderWeapons.PressureSuitOffsets[ ply:SteamID64() ] = table.Copy( modeldata )

			if !Menu.SaveHack then
				SaveData[ modelname ] = table.Copy( modeldata )
			end
		else
			WonderWeapons.PressureSuitOffsets[ ply:SteamID64() ] = table.Copy( default_offsets )
		end

		file.Write( "fox_wonderweapons/pes_data.txt", util.TableToJSON( SaveData ) )
	end

	function Menu.UpdateModel()
		local model = ply:GetInfo( "cl_playermodel" )
		local modelname = string.lower( player_manager.TranslatePlayerModel( model ) )

		mdl:SetModel( modelname )
		mdl.Entity.GetPlayerColor = function() return Vector( GetConVar( "cl_playercolor" ):GetString() ) end
		mdl.Entity:SetPos( Vector( -100, 0, -61 ) )

		local skin = ply:GetInfoNum( "cl_playerskin", 0 )
		mdl.Entity:SetSkin( skin )

		local groups = ply:GetInfo( "cl_playerbodygroups" )
		if ( groups == nil ) then
			groups = ""
		end

		local groups = string.Explode( " ", groups )

		for k = 0, mdl.Entity:GetNumBodyGroups() - 1 do
			local v = tonumber( groups[ k + 1 ] ) or 0
			mdl.Entity:SetBodygroup( k, v )
		end

		local modeldata = ( SaveData[ modelname ] or WonderWeapons.PressureSuitDefaults[ modelname ] )

		if modeldata then
			if !LocalData[ modelname ] then
				LocalData[ modelname ] = {}
			end

			LocalData[ modelname ] = table.Copy( modeldata )
		end

		if Menu.LastModel and tostring( modelname ) ~= tostring( Menu.LastModel ) then
			if ( modeldata ) then
				timer.Simple(0, function()
					Menu.Update()

					Menu.OffsetX:SetValue( modeldata[1] or 0 )
					Menu.OffsetY:SetValue( modeldata[2] or 0 )
					Menu.OffsetZ:SetValue( modeldata[3] or 0 )

					Menu.ScaleX:SetValue( modeldata[4] or 1 )
					Menu.ScaleY:SetValue( modeldata[5] or 1 )
					Menu.ScaleZ:SetValue( modeldata[6] or 1 )

					Menu.RotationP:SetValue( modeldata[7] or 0 )
					Menu.RotationY:SetValue( modeldata[8] or 0 )
					Menu.RotationR:SetValue( modeldata[9] or 0 )

					Menu.BoneName:SetValue( modeldataBoneName or "ValveBiped.Bip01_Head1" )
				end)
			else
				timer.Simple(0, function()
					Menu.OffsetX:SetValue( 0 )
					Menu.OffsetY:SetValue( 0 )
					Menu.OffsetZ:SetValue( 0 )

					Menu.ScaleX:SetValue( 1 )
					Menu.ScaleY:SetValue( 1 )
					Menu.ScaleZ:SetValue( 1 )

					Menu.RotationP:SetValue( 0 )
					Menu.RotationY:SetValue( 0 )
					Menu.RotationR:SetValue( 0 )

					Menu.BoneName:SetValue( "ValveBiped.Bip01_Head1" )
				end)
			end
		end

		Menu.LastModel = modelname

		mdl.PlayAnimation()
		mdl.DefaultPos()
	end

	Menu.UpdateModel()

	Menu.ApplyButton = window:Add( "DButton" )
	Menu.ApplyButton:SetSize( 120, 30 )
	Menu.ApplyButton:SetPos( fw - 560, 30 )
	Menu.ApplyButton:SetText( "Save & Apply" )
	Menu.ApplyButton.DoClick = function()
		if Menu.LastModel and !LocalData[ Menu.LastModel ] then
			LocalData[ Menu.LastModel ] = table.Copy( default_offsets )
		end

		Menu.Save()

		timer.Simple(0, function()
			Menu.SavesPanel.Update()
		end)
	end

	Menu.ResetButton = window:Add( "DButton" )
	Menu.ResetButton:SetSize( 40, 20 )
	Menu.ResetButton:SetPos( 5, fh - 25 )
	Menu.ResetButton:SetText( "Reset" )
	Menu.ResetButton.DoClick = mdl.DefaultPos

	Menu.DraggingCheck = window:Add( "DCheckBox" )
	Menu.DraggingCheck:SetPos( 5, 30 )
	Menu.DraggingCheck:SetValue( true )
	Menu.DraggingCheck.DoClick = function()
		Menu.DragEnabled = !Menu.DragEnabled
		Menu.DraggingCheck:SetValue( Menu.DragEnabled )
		mdl.Drag = 0
	end

	//-------------------------------------------------------------
	// Main Sheet
	//-------------------------------------------------------------

	local controls = window:Add( "DPropertySheet" )
	controls:Dock( RIGHT )
	controls:SetSize( 430, 0 )

	local slidercontrols = controls:Add( "DPanel" )
	local slidertab = controls:AddSheet( "Customization", slidercontrols, "icon16/vector.png" )
	slidercontrols:DockPadding( 8, 8, 8, 8 )

	local slidercontrolspanel = slidercontrols:Add( "DPanelList" )
	slidercontrolspanel:EnableVerticalScrollbar( true )
	slidercontrolspanel:Dock( FILL )

	local settingscontrols = controls:Add( "DPanel" )
	local settingstab = controls:AddSheet( "Settings", settingscontrols, "icon16/cog.png" )
	settingscontrols:DockPadding( 8, 8, 8, 8 )

	local settingscontrolspanel = settingscontrols:Add( "DPanelList" )
	settingscontrolspanel:EnableVerticalScrollbar( true )
	settingscontrolspanel:Dock( FILL )

	local savescontrols = controls:Add( "DPanel" )
	local savestab = controls:AddSheet( "Saved Presets", savescontrols, "icon16/tab.png" )
	savescontrols:DockPadding( 8, 8, 8, 8 )

	local togglecontrols = controls:Add( "DPanel" )
	local toggletab = controls:AddSheet( "Blacklist", togglecontrols, "icon16/user_red.png" )
	togglecontrols:DockPadding( 8, 8, 8, 8 )

	//-------------------------------------------------------------
	// Customization Panel
	//-------------------------------------------------------------

	Menu.OffsetX = vgui.Create( "DNumSlider" )
	Menu.OffsetX:Dock( TOP )
	Menu.OffsetX:SetText( "Offset X" )
	Menu.OffsetX:SetDark( true )
	Menu.OffsetX:SetTall( 50 )
	Menu.OffsetX:SetDecimals( 3 )
	Menu.OffsetX:SetMin( -2.5 )
	Menu.OffsetX:SetMax( 2.5 )
	Menu.OffsetX:SetValue( curOffsets[1] )
	Menu.OffsetX.Dir = 1
	Menu.OffsetX.OnValueChanged = function() Menu.Update() end

	slidercontrolspanel:AddItem( Menu.OffsetX )

	Menu.OffsetY = vgui.Create( "DNumSlider" )
	Menu.OffsetY:Dock( TOP )
	Menu.OffsetY:SetText( "Offset Y" )
	Menu.OffsetY:SetDark( true )
	Menu.OffsetY:SetTall( 50 )
	Menu.OffsetY:SetDecimals( 3 )
	Menu.OffsetY:SetMin( -2.5 )
	Menu.OffsetY:SetMax( 2.5 )
	Menu.OffsetY:SetValue( curOffsets[2] )
	Menu.OffsetY.Dir = 2
	Menu.OffsetY.OnValueChanged = function() Menu.Update() end

	slidercontrolspanel:AddItem( Menu.OffsetY )

	Menu.OffsetZ = vgui.Create( "DNumSlider" )
	Menu.OffsetZ:Dock( TOP )
	Menu.OffsetZ:SetText( "Offset Z" )
	Menu.OffsetZ:SetDark( true )
	Menu.OffsetZ:SetTall( 50 )
	Menu.OffsetZ:SetDecimals( 3 )
	Menu.OffsetZ:SetMin( -2.5 )
	Menu.OffsetZ:SetMax( 2.5 )
	Menu.OffsetZ:SetValue( curOffsets[3] )
	Menu.OffsetZ.Dir = 3
	Menu.OffsetZ.OnValueChanged = function() Menu.Update() end

	slidercontrolspanel:AddItem( Menu.OffsetZ )

	Menu.ScaleX = vgui.Create( "DNumSlider" )
	Menu.ScaleX:Dock( TOP )
	Menu.ScaleX:SetText( "Scale X" )
	Menu.ScaleX:SetDark( true )
	Menu.ScaleX:SetTall( 50 )
	Menu.ScaleX:SetDecimals( 3 )
	Menu.ScaleX:SetMin( 0.0001 )
	Menu.ScaleX:SetMax( 1.65 )
	Menu.ScaleX:SetValue( curOffsets[4] )
	Menu.ScaleX.OnValueChanged = function() Menu.Update() end

	slidercontrolspanel:AddItem( Menu.ScaleX )

	Menu.ScaleY = vgui.Create( "DNumSlider" )
	Menu.ScaleY:Dock( TOP )
	Menu.ScaleY:SetText( "Scale Y" )
	Menu.ScaleY:SetDark( true )
	Menu.ScaleY:SetTall( 50 )
	Menu.ScaleY:SetDecimals( 3 )
	Menu.ScaleY:SetMin( 0.0001 )
	Menu.ScaleY:SetMax( 1.65 )
	Menu.ScaleY:SetValue( curOffsets[5] )
	Menu.ScaleY.OnValueChanged = function() Menu.Update() end

	slidercontrolspanel:AddItem( Menu.ScaleY )

	Menu.ScaleZ = vgui.Create( "DNumSlider" )
	Menu.ScaleZ:Dock( TOP )
	Menu.ScaleZ:SetText( "Scale Z" )
	Menu.ScaleZ:SetDark( true )
	Menu.ScaleZ:SetTall( 50 )
	Menu.ScaleZ:SetDecimals( 3 )
	Menu.ScaleZ:SetMin( 0.0001 )
	Menu.ScaleZ:SetMax( 1.65 )
	Menu.ScaleZ:SetValue( curOffsets[6] )
	Menu.ScaleZ.OnValueChanged = function() Menu.Update() end

	slidercontrolspanel:AddItem( Menu.ScaleZ )

	Menu.RotationP = vgui.Create( "DNumSlider" )
	Menu.RotationP:Dock( TOP )
	Menu.RotationP:SetText( "Pitch" )
	Menu.RotationP:SetDark( true )
	Menu.RotationP:SetTall( 50 )
	Menu.RotationP:SetMin( -180 )
	Menu.RotationP:SetMax( 180 )
	Menu.RotationP:SetValue( curOffsets[7] )
	Menu.RotationP.OnValueChanged = function() Menu.Update() end

	slidercontrolspanel:AddItem( Menu.RotationP )

	Menu.RotationY = vgui.Create( "DNumSlider" )
	Menu.RotationY:Dock( TOP )
	Menu.RotationY:SetText( "Yaw" )
	Menu.RotationY:SetDark( true )
	Menu.RotationY:SetTall( 50 )
	Menu.RotationY:SetMin( -180 )
	Menu.RotationY:SetMax( 180 )
	Menu.RotationY:SetValue( curOffsets[8] )
	Menu.RotationY.OnValueChanged = function() Menu.Update() end

	slidercontrolspanel:AddItem( Menu.RotationY )

	Menu.RotationR = vgui.Create( "DNumSlider" )
	Menu.RotationR:Dock( TOP )
	Menu.RotationR:SetText( "Roll" )
	Menu.RotationR:SetDark( true )
	Menu.RotationR:SetTall( 50 )
	Menu.RotationR:SetMin( -180 )
	Menu.RotationR:SetMax( 180 )
	Menu.RotationR:SetValue( curOffsets[9] )
	Menu.RotationR.OnValueChanged = function() Menu.Update() end

	slidercontrolspanel:AddItem( Menu.RotationR )

	Menu.BoneName = vgui.Create( "DTextEntry" )
	Menu.BoneName:Dock( TOP )
	Menu.BoneName:SetUpdateOnType( true )
	Menu.BoneName:SetValue( ( curOffsets[10] and isstring( curOffsets[10] ) ) and curOffsets[10] or "ValveBiped.Bip01_Head1" )
	Menu.BoneName.OnValueChange = function() Menu.Update() end

	slidercontrolspanel:AddItem( Menu.BoneName )

	Menu.ResetXButton = Menu.OffsetX:Add( "DButton" )
	Menu.ResetXButton:SetSize( 60, 20 )
	Menu.ResetXButton:SetPos( 60, 20 - 5 )
	Menu.ResetXButton:SetText( "Reset" )
	Menu.ResetXButton.DoClick = function()
		local model = ply:GetInfo( "cl_playermodel" )
		local modelname = string.lower( player_manager.TranslatePlayerModel( model ) )
		if modelname then
			local modeldata = WonderWeapons.PressureSuitDefaults[ modelname ]
			if modeldata and modeldata[1] then
				Menu.OffsetX:SetValue( modeldata[1] )
			else
				Menu.OffsetX:SetValue( 0 )
			end
		else
			Menu.OffsetX:SetValue( 0 )
		end
	end

	Menu.ResetYButton = Menu.OffsetY:Add( "DButton" )
	Menu.ResetYButton:SetSize( 60, 20 )
	Menu.ResetYButton:SetPos( 60, 20 - 5 )
	Menu.ResetYButton:SetText( "Reset" )
	Menu.ResetYButton.DoClick = function()
		local model = ply:GetInfo( "cl_playermodel" )
		local modelname = string.lower( player_manager.TranslatePlayerModel( model ) )
		if modelname then
			local modeldata = WonderWeapons.PressureSuitDefaults[ modelname ]
			if modeldata and modeldata[2] then
				Menu.OffsetY:SetValue( modeldata[2] )
			else
				Menu.OffsetY:SetValue( 0 )
			end
		else
			Menu.OffsetY:SetValue( 0 )
		end
	end

	Menu.ResetZButton = Menu.OffsetZ:Add( "DButton" )
	Menu.ResetZButton:SetSize( 60, 20 )
	Menu.ResetZButton:SetPos( 60, 20 - 5 )
	Menu.ResetZButton:SetText( "Reset" )
	Menu.ResetZButton.DoClick = function()
		local model = ply:GetInfo( "cl_playermodel" )
		local modelname = string.lower( player_manager.TranslatePlayerModel( model ) )
		if modelname then
			local modeldata = WonderWeapons.PressureSuitDefaults[ modelname ]
			if modeldata and modeldata[3] then
				Menu.OffsetZ:SetValue( modeldata[3] )
			else
				Menu.OffsetZ:SetValue( 0 )
			end
		else
			Menu.OffsetZ:SetValue( 0 )
		end
	end

	Menu.ResetScaleXButton = Menu.ScaleX:Add( "DButton" )
	Menu.ResetScaleXButton:SetSize( 60, 20 )
	Menu.ResetScaleXButton:SetPos( 60, 20 - 5 )
	Menu.ResetScaleXButton:SetText( "Reset" )
	Menu.ResetScaleXButton.DoClick = function()
		local model = ply:GetInfo( "cl_playermodel" )
		local modelname = string.lower( player_manager.TranslatePlayerModel( model ) )
		if modelname then
			local modeldata = WonderWeapons.PressureSuitDefaults[ modelname ]
			if modeldata and modeldata[4] then
				Menu.ScaleX:SetValue( modeldata[4] )
			else
				Menu.ScaleX:SetValue( 1 )
			end
		else
			Menu.ScaleX:SetValue( 1 )
		end
	end

	Menu.ResetScaleYButton = Menu.ScaleY:Add( "DButton" )
	Menu.ResetScaleYButton:SetSize( 60, 20 )
	Menu.ResetScaleYButton:SetPos( 60, 20 - 5 )
	Menu.ResetScaleYButton:SetText( "Reset" )
	Menu.ResetScaleYButton.DoClick = function()
		local model = ply:GetInfo( "cl_playermodel" )
		local modelname = string.lower( player_manager.TranslatePlayerModel( model ) )
		if modelname then
			local modeldata = WonderWeapons.PressureSuitDefaults[ modelname ]
			if modeldata and modeldata[5] then
				Menu.ScaleY:SetValue( modeldata[5] )
			else
				Menu.ScaleY:SetValue( 1 )
			end
		else
			Menu.ScaleY:SetValue( 1 )
		end
	end

	Menu.ResetScaleZButton = Menu.ScaleZ:Add( "DButton" )
	Menu.ResetScaleZButton:SetSize( 60, 20 )
	Menu.ResetScaleZButton:SetPos( 60, 20 - 5 )
	Menu.ResetScaleZButton:SetText( "Reset" )
	Menu.ResetScaleZButton.DoClick = function()
		local model = ply:GetInfo( "cl_playermodel" )
		local modelname = string.lower( player_manager.TranslatePlayerModel( model ) )
		if modelname then
			local modeldata = WonderWeapons.PressureSuitDefaults[ modelname ]
			if modeldata and modeldata[6] then
				Menu.ScaleZ:SetValue( modeldata[6] )
			else
				Menu.ScaleZ:SetValue( 1 )
			end
		else
			Menu.ScaleZ:SetValue( 1 )
		end
	end

	Menu.ResetPitchButton = Menu.RotationP:Add( "DButton" )
	Menu.ResetPitchButton:SetSize( 60, 20 )
	Menu.ResetPitchButton:SetPos( 60, 20 - 5 )
	Menu.ResetPitchButton:SetText( "Reset" )
	Menu.ResetPitchButton.DoClick = function()
		local model = ply:GetInfo( "cl_playermodel" )
		local modelname = string.lower( player_manager.TranslatePlayerModel( model ) )
		if modelname then
			local modeldata = WonderWeapons.PressureSuitDefaults[ modelname ]
			if modeldata and modeldata[7] then
				Menu.RotationP:SetValue( modeldata[7] )
			else
				Menu.RotationP:SetValue( 0 )
			end
		else
			Menu.RotationP:SetValue( 0 )
		end
	end

	Menu.ResetYawButton = Menu.RotationY:Add( "DButton" )
	Menu.ResetYawButton:SetSize( 60, 20 )
	Menu.ResetYawButton:SetPos( 60, 20 - 5 )
	Menu.ResetYawButton:SetText( "Reset" )
	Menu.ResetYawButton.DoClick = function()
		local model = ply:GetInfo( "cl_playermodel" )
		local modelname = string.lower( player_manager.TranslatePlayerModel( model ) )
		if modelname then
			local modeldata = WonderWeapons.PressureSuitDefaults[ modelname ]
			if modeldata and modeldata[8] then
				Menu.RotationY:SetValue( modeldata[8] )
			else
				Menu.RotationY:SetValue( 0 )
			end
		else
			Menu.RotationY:SetValue( 0 )
		end
	end

	Menu.ResetRollButton = Menu.RotationR:Add( "DButton" )
	Menu.ResetRollButton:SetSize( 60, 20 )
	Menu.ResetRollButton:SetPos( 60, 20 - 5 )
	Menu.ResetRollButton:SetText( "Reset" )
	Menu.ResetRollButton.DoClick = function()
		local model = ply:GetInfo( "cl_playermodel" )
		local modelname = string.lower( player_manager.TranslatePlayerModel( model ) )
		if modelname then
			local modeldata = WonderWeapons.PressureSuitDefaults[ modelname ]
			if modeldata and modeldata[9] then
				Menu.RotationR:SetValue( modeldata[9] )
			else
				Menu.RotationR:SetValue( 0 )
			end
		else
			Menu.RotationR:SetValue( 0 )
		end
	end

	function Menu.Update()
		local model = ply:GetInfo( "cl_playermodel" )
		local modelname = string.lower( player_manager.TranslatePlayerModel( model ) )

		if !LocalData[ modelname ] then
			LocalData[ modelname ] = {}
		end

		LocalData[ modelname ][ 1 ] = math.Round( Menu.OffsetX:GetValue(), 4 )
		LocalData[ modelname ][ 2 ] = math.Round( Menu.OffsetY:GetValue(), 4 )
		LocalData[ modelname ][ 3 ] = math.Round( Menu.OffsetZ:GetValue(), 4 )
		LocalData[ modelname ][ 4 ] = math.Round( Menu.ScaleX:GetValue(), 4 )
		LocalData[ modelname ][ 5 ] = math.Round( Menu.ScaleY:GetValue(), 4 )
		LocalData[ modelname ][ 6 ] = math.Round( Menu.ScaleZ:GetValue(), 4 )
		LocalData[ modelname ][ 7 ] = math.Round( Menu.RotationP:GetValue(), 4 )
		LocalData[ modelname ][ 8 ] = math.Round( Menu.RotationY:GetValue(), 4 )
		LocalData[ modelname ][ 9 ] = math.Round( Menu.RotationR:GetValue(), 4 )
		LocalData[ modelname ][ 10 ] = tostring( Menu.BoneName:GetValue() )
	end

	//-------------------------------------------------------------
	// Saved Customizations
	//-------------------------------------------------------------

	Menu.SavesPanel = savescontrols:Add( "DListView" )
	Menu.SavesPanel:Dock( LEFT )
	Menu.SavesPanel:DockMargin( 0, 0, 20, 0 )
	Menu.SavesPanel:SetWidth( 395 )
	Menu.SavesPanel:SetMultiSelect( true )
	Menu.SavesPanel:AddColumn( "Remove Saved Presets" )

	function Menu.SavesPanel.Update()
		Menu.SavesPanel:Clear()

		for modelname, data in pairs( SaveData ) do
			local line = Menu.SavesPanel:AddLine( player_manager.TranslateToPlayerModelName( modelname ) )
			line.Columns[ 1 ]:Dock( LEFT )
			line.Columns[ 1 ]:DockMargin( 16, 0, 0, 0 )

			local delbutn = line:Add( "DImageButton" )
			delbutn:SetImage("icon16/delete.png")
			delbutn:SetPos( 0, 0 )
			delbutn:SetSize( 16, 16 )
			delbutn.DoClick = function()
				LocalData[ modelname ] = nil
				SaveData[ modelname ] = nil

				Menu.SaveHack = true

				Menu.Save()

				Menu.SaveHack = nil

				Menu.UpdateModel()

				timer.Simple(0, function()
					if not line then
						return
					end

					line:Remove()

					timer.Simple(0, function()
						if not Menu or not Menu.SavesPanel then
							return
						end

						Menu.SavesPanel:SortByColumn( 1 )
					end)
				end)
			end
		end

		Menu.SavesPanel:SortByColumn( 1 )
	end

	Menu.SavesPanel.Update()

	//-------------------------------------------------------------
	// Settings Panel
	//-------------------------------------------------------------

	Menu.TranslucentToggle = vgui.Create( "DCheckBoxLabel" )
	Menu.TranslucentToggle:Dock( TOP )
	Menu.TranslucentToggle:SetText( "Enable visor translucency" )
	Menu.TranslucentToggle:SetDark( true )
	Menu.TranslucentToggle:SetTall( 30 )
	Menu.TranslucentToggle:SetConVar("cl_tfa_bo3ww_pes_msaa_translucent")
	Menu.TranslucentToggle:SetValue( GetConVar("cl_tfa_bo3ww_pes_msaa_translucent"):GetInt() )

	settingscontrolspanel:AddItem( Menu.TranslucentToggle )

	local t = vgui.Create( "DLabel" )
	t:Dock( TOP )
	t:SetAutoStretchVertical( true )
	t:SetText( "Looks really bad with low/no MSAA antialiasing." )
	t:SetDark( true )
	t:SetWrap( true )

	settingscontrolspanel:AddItem( t )

	Menu.ColorToggle = vgui.Create( "DCheckBoxLabel" )
	Menu.ColorToggle:Dock( TOP )
	Menu.ColorToggle:SetText( "Visor uses player color" )
	Menu.ColorToggle:SetDark( true )
	Menu.ColorToggle:SetTall( 30 )
	Menu.ColorToggle:SetConVar("cl_tfa_bo3ww_pes_playercolor")
	Menu.ColorToggle:SetValue( GetConVar("cl_tfa_bo3ww_pes_playercolor"):GetInt() )

	settingscontrolspanel:AddItem( Menu.ColorToggle )

	Menu.HideToggle = vgui.Create( "DCheckBoxLabel" )
	Menu.HideToggle:Dock( TOP )
	Menu.HideToggle:SetText( "Hide model on all players" )
	Menu.HideToggle:SetDark( true )
	Menu.HideToggle:SetTall( 30 )
	Menu.HideToggle:SetConVar("cl_tfa_bo3ww_pes_hide_model")
	Menu.HideToggle:SetValue( GetConVar("cl_tfa_bo3ww_pes_hide_model"):GetInt() )

	settingscontrolspanel:AddItem( Menu.HideToggle )

	//-------------------------------------------------------------
	// Blacklist Panel
	//-------------------------------------------------------------

	local togglepanel = togglecontrols:Add( "DListView" )
	togglepanel:Dock( LEFT )
	togglepanel:DockMargin( 0, 0, 20, 0 )
	togglepanel:SetWidth( 395 )
	togglepanel:SetMultiSelect( true )
	togglepanel:AddColumn( "Players" )

	function togglepanel.Update()
		togglepanel:Clear()

		for _, p in pairs( player.GetAll() ) do
			/*if p:EntIndex() == ply:EntIndex() then
				continue
			end*/

			local line = togglepanel:AddLine( p:Nick() )
			line.Columns[ 1 ]:Dock( LEFT )
			line.Columns[ 1 ]:DockMargin( 32, 0, 0, 0 )

			local blacklistdata = Blacklist[ p:SteamID64() ]

			local lockbutn = line:Add( "DImageButton" )
			lockbutn:SetImage( ( blacklistdata and blacklistdata == 1 ) and "icon16/lock.png" or "icon16/lock_open.png" )
			lockbutn:SetPos( 0, 0 )
			lockbutn:SetSize( 16, 16 )
			lockbutn:SetColor( color_white )
			lockbutn.Disabled = false
			lockbutn.DoClick = function()
				lockbutn.Disabled = !lockbutn.Disabled

				if Blacklist[ p:SteamID64() ] and Blacklist[ p:SteamID64() ] == 2 then
					return
				end

				if lockbutn.Disabled then
					lockbutn:SetColor( color_hidden )
					lockbutn:SetImage( "icon16/lock.png" )
					Blacklist[ p:SteamID64() ] = 1
				else
					lockbutn:SetColor( color_white )
					lockbutn:SetImage( "icon16/lock_open.png" )
					Blacklist[ p:SteamID64() ] = 0
				end

				WonderWeapons.PressureSuitBlacklist = table.Copy( Blacklist )

				file.Write( "fox_wonderweapons/pes_blacklist.txt", util.TableToJSON( Blacklist ) )
			end

			local hidebutn = line:Add( "DImageButton" )
			hidebutn:SetImage("icon16/eye.png")
			hidebutn:SetPos( 16, 0 )
			hidebutn:SetSize( 16, 16 )
			hidebutn:SetColor( ( blacklistdata and blacklistdata == 2 ) and color_hidden or color_white )
			hidebutn.Hidden = false
			hidebutn.DoClick = function()
				hidebutn.Hidden = !hidebutn.Hidden

				if hidebutn.Hidden then
					hidebutn:SetColor( color_hidden )
					Blacklist[ p:SteamID64() ] = 2
				else
					hidebutn:SetColor( color_white )
					Blacklist[ p:SteamID64() ] = tobool( lockbutn.Disabled ) and 1 or 0
				end

				WonderWeapons.PressureSuitBlacklist = table.Copy( Blacklist )

				file.Write( "fox_wonderweapons/pes_blacklist.txt", util.TableToJSON( Blacklist ) )
			end
		end

		togglepanel:SortByColumn( 1 )
	end

	togglepanel.Update()

	//-------------------------------------------------------------
	// Model Rendering
	//-------------------------------------------------------------

	function mdl:DragMousePress( button )
		self.PressX, self.PressY = input.GetCursorPos()
		self.PressStart = RealTime()
		self.Pressed = button
		self.Drag = 0
	end

	function mdl:OnMouseWheeled( delta )
		self.WheelD = delta * -5
		self.Wheeled = true
	end

	function mdl:DragMouseRelease()
		self.Pressed = false
	end

	function mdl:RunAnimation()
		self.Entity:FrameAdvance( ( RealTime() - self.LastPaint ) * self.m_fAnimSpeed )
	end

	function mdl:PostDrawModel( Entity )
		if ( !ClientsideModel ) then return end

		if cl_psuitdisabled:GetBool() then
			return
		end

		if !IsValid( self.HelmetEntity ) then
			self.HelmetEntity = ClientsideModel( "models/weapons/tfa_bo3/pes/w_pes.mdl", RENDERGROUP_OTHER )
		else
			self.HelmetEntity:SetNoDraw( true )
			self.HelmetEntity:SetIK( false )

			local model = ply:GetInfo( "cl_playermodel" )
			local modelname = string.lower( player_manager.TranslatePlayerModel( model ) )

			local playerdata = LocalData[ modelname ] or WonderWeapons.PressureSuitDefaults[ modelname ] or default_offsets
			local blacklistdata = WonderWeapons.PressureSuitBlacklist[ LocalPlayer():SteamID64() ] or 0

			if tonumber( blacklistdata ) > 1 then
				return
			end

			local strBoneName = playerdata[ 10 ]
			local nHeadBone = ply:LookupBone( strBoneName or "ValveBiped.Bip01_Head1" )
			if nHeadBone then
				local matrix = Entity:GetBoneMatrix( nHeadBone )
				if matrix then
					local pos = matrix:GetTranslation()
					local ang = matrix:GetAngles()

					local modelScale = Vector( 1, 1, 1 )
					modelScale:Mul( Entity:GetModelScale() )

					local vecScale = Vector( playerdata[4], playerdata[5], playerdata[6] )
					local vecOffset = ( ang:Right() * playerdata[1] ) + ( ang:Up() * playerdata[2] ) + ( ang:Forward() * playerdata[3] )

					if tonumber( blacklistdata ) > 0 then
						vecScale = Vector( 1, 1, 1 )
						vecOffset = Vector()
					end

					local matScale = Matrix()
					matScale:Scale(vecScale)
					matScale:Scale(modelScale)

					pos = pos + ( ang:Forward() * ( 2.5 * modelScale ) ) + ( ang:Right() * ( 1.5 * modelScale ) ) + vecOffset

					ang:RotateAroundAxis( ang:Right(), -90 )
					ang:RotateAroundAxis( ang:Up(), -90 )

					ang:RotateAroundAxis( ang:Right(), playerdata[7] )
					ang:RotateAroundAxis( ang:Up(), playerdata[8] )
					ang:RotateAroundAxis( ang:Forward(), playerdata[9] )

					if cl_psuittranslucent:GetBool() then
						G_IMatSuitVisor:SetInt( "$flags", bit.bor( MATERIAL_VAR_ALPHATEST, MATERIAL_VAR_ALLOWALPHATOCOVERAGE, MATERIAL_VAR_NOCULL ) )
					end

					if cl_psuitplayercolor:GetBool() then
						local vecPlyColor = Entity:GetPlayerColor()
						G_IMatSuitVisor:SetVector( "$phongtint", vecPlyColor )
						G_IMatSuitVisor:SetVector( "$envmaptint", vecPlyColor )
						G_IMatSuitVisor:SetVector( "$color2", vecPlyColor )
					end

					self.HelmetEntity:SetSubMaterial( 6, "!PressureSuitVisor" )

					self.HelmetEntity:EnableMatrix( "RenderMultiply", matScale )

					self.HelmetEntity:SetPos( pos )
					self.HelmetEntity:SetAngles( ang )

					self.HelmetEntity:SetRenderOrigin( pos )
					self.HelmetEntity:SetRenderAngles( ang )

					self.HelmetEntity:DrawModel()

					self.HelmetEntity:SetRenderOrigin()
					self.HelmetEntity:SetRenderAngles()

					G_IMatSuitVisor:SetVector( "$phongtint", vecVisorColor )
					G_IMatSuitVisor:SetVector( "$envmaptint", vecVisorColor )
					G_IMatSuitVisor:SetVector( "$color2", Vector( 1, 1, 1 ) )
					G_IMatSuitVisor:SetInt( "$flags", MATERIAL_VAR_DEBUG )

					self.HelmetEntity:SetSubMaterial( 6, nil )
				end
			end
		end
	end

	function mdl:LayoutEntity( Entity )
		if self.bAnimated then
			self:RunAnimation()
		end

		if self.Pressed == MOUSE_LEFT then
			local mx, my = input.GetCursorPos()
			self.Angles = self.Angles - Angle( 0, ( self.PressX or mx ) - mx, 0 )

			// below this is big stinky
			if Menu.DragEnabled then
				local difference = math.abs(self.PressX - mx)

				if difference <= 0 and !self.DragDelta then
					self.DragDelta = RealTime() // mouse has stopped moving
				elseif self.DragDelta and difference > ( 10 * scale ) then
					self.DragDelta = nil // mouse is moving again
				end

				// clear drag if we stop moving for 200ms
				if self.DragDelta and self.DragDelta + 0.2 < RealTime() then
					self.DragDelta = nil
					self.Drag = 0
				end

				// decrease drag when mouse movement drops below threshold
				if self.Drag and difference < ( 10 * scale ) then
					self.Drag = math.Approach( self.Drag, 0, FrameTime() * 5 )
				end

				// increase drag value by difference from last mouse location (in pixels) divided by 100 (scaled by monitor resolution)
				if self.PressX and difference > 0 then
					self.Drag = math.Clamp( ( self.Drag or 0 ) + ( ( self.PressX - mx ) / ( 100 * scale ) ), -20, 20 )
				end
			end

			self.PressX, self.PressY = input.GetCursorPos()
		end

		if self.Pressed == MOUSE_MIDDLE then
			local mx, my = input.GetCursorPos()
			self.Pos = self.Pos - Vector( 0, ( self.PressX*(0.5) or mx*(0.5) ) - mx*(0.5), ( self.PressY*(-0.5) or my*(-0.5) ) - my*(-0.5) )

			self.PressX, self.PressY = input.GetCursorPos()
		end

		if Menu.DragEnabled then
			if self.Drag and !self.Pressed then
				self.Drag = math.Approach( self.Drag, 0, FrameTime() * 2 )

				if math.abs( self.Drag ) > 0 then
					self.Angles = Angle( 0, self.Angles[2] - self.Drag, 0 )
				end
			end
		end

		if self.Wheeled then
			self.Wheeled = false
			self.Pos = self.Pos - Vector( self.WheelD, 0, 0 )
		end

		Entity:SetAngles( self.Angles )
		Entity:SetPos( self.Pos )
	end

	WonderWeapons.PressureSuitMenu = Menu
end

function Menu.Toggle()
	if IsValid( window ) then
		window:ToggleVisible()
	else
		Menu.Setup()
	end
end

concommand.Add( "fox_pes_menu", Menu.Toggle )

net.Receive( "TFA.BO3WW.FOX.PressureSuit.ToClient", function( length, ply )
	local nSteam64 = net.ReadUInt64()
	local pesOffsets = net.ReadTable()

	WonderWeapons.PressureSuitOffsets[ nSteam64 ] = pesOffsets
end )
