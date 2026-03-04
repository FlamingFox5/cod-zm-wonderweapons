local SinglePlayer = game.SinglePlayer()

local CurTime = CurTime
local IsValid = IsValid

local comedyday = os.date("%d-%m") == "01-04"

//-------------------------------------------------------------
// Q.E.D. Effects
//-------------------------------------------------------------

nzQuantumBomb = nzQuantumBomb or AddNZModule("QuantumBomb")

nzQuantumBomb.EffectTypes = nzQuantumBomb.EffectTypes or {}

local EffectTypes = nzQuantumBomb.EffectTypes

EffectTypes.NONE = 0
EffectTypes.NEUTRAL = 1 //offwhite
EffectTypes.POSITIVE = 2 //green
EffectTypes.NEGATIVE = 3 //red
EffectTypes.WAVEGUN = 4 //purple
EffectTypes.GOLDEN = 5 //yellow

nzQuantumBomb.Effects = nzQuantumBomb.Effects or {}

local QuantumBombEffects = nzQuantumBomb.Effects

function nzQuantumBomb:AddEffect( id, data )
	QuantumBombEffects[ id ] = data
end

function nzQuantumBomb:GetEffect( id )
	return QuantumBombEffects[ id ] or nil
end

if SERVER then
	util.AddNetworkString("NZ.BO3WW.FOX.QuantumBomb.Vox")
	util.AddNetworkString("NZ.BO3WW.FOX.QuantumBomb.Text")

	nzQuantumBomb.CachedWeightTable = {}

	function nzQuantumBomb:GetWeightedTable()
		local effect, weight = next( nzQuantumBomb.CachedWeightTable )
		if effect ~= nil and weight ~= nil and isnumber( weight ) then
			return nzQuantumBomb.CachedWeightTable
		else
			for effect, data in pairs( QuantumBombEffects ) do
				if data.Special then
					continue
				end

				if comedyday and !data.AprilFools then
					continue
				end

				if data and data.Weight and isnumber( data.Weight ) and data.Weight > 0 then
					nzQuantumBomb.CachedWeightTable[ effect ] = comedyday and data.AprilFoolsWeight or data.Weight
				end
			end

			hook.Run( "TFA_WonderWeapon_QuantumBombBuildWeights", nzQuantumBomb.CachedWeightTable )

			return nzQuantumBomb.CachedWeightTable
		end
	end

	function nzQuantumBomb:ActivateEffect( id, projectile, ... )
		if not IsValid( projectile ) then
			return
		end

		if not id or not isstring( id ) or id == "" then
			return
		end

		local data = nzQuantumBomb:GetEffect( id )

		if not data or not data.OnActivate then
			return
		end

		if projectile.PrintEffect and data.Name then
			projectile:PrintEffect( effect, projectile.EffectNameOverride or data.Name )
		end

		if projectile.SendAnnouncerVox and data.AnnouncerVox and file.Exists( "sound/"..data.AnnouncerVox, "GAME" ) then
			projectile:SendAnnouncerVox( data.AnnouncerVox, tobool( data.Global ) )
		end

		return data.OnActivate( projectile, ... )
	end

	function nzQuantumBomb:ActivateSilent( id, projectile, ... )
		if not IsValid( projectile ) then
			return
		end

		if not id or not isstring( id ) or id == "" then
			return
		end

		local data = nzQuantumBomb:GetEffect( id )

		if not data or not data.OnActivate then
			return
		end

		return data.OnActivate( projectile, ... )
	end
end

if CLIENT then
	local color_red = Color(255, 0, 0, 255)

	nzQuantumBomb.EffectColors = nzQuantumBomb.EffectColors or {
		[EffectTypes.NONE] = color_white,
		[EffectTypes.NEUTRAL] = Color(255, 254, 240),
		[EffectTypes.POSITIVE] = Color(100, 255, 100),
		[EffectTypes.NEGATIVE] = Color(255, 100, 100),
		[EffectTypes.WAVEGUN] = Color(200, 100, 255),
		[EffectTypes.GOLDEN] = Color(255, 225, 100),
	}

	net.Receive( "NZ.BO3WW.FOX.QuantumBomb.Text", function(len, ply)
		local effect = net.ReadString()
		local text = net.ReadString()

		local data = nzQuantumBomb:GetEffect( effect )
		if not data then return end

		local finalText = data.Name or "ERROR"
		if text ~= "" then
			finalText = text
		end

		local finalColor = finalText == "ERROR" and color_red or nzQuantumBomb.EffectColors[data.Effect or 0] or color_white

		local hookText, hookColor = hook.Run( "TFA_WonderWeapon_QuantumBombText", LocalPlayer(), text, effect, data )
		if hookText ~= nil and isstring( hookText ) and hookText ~= "" then
			finalText = hookText

			if hookColor ~= nil and IsColor( hookColor ) then
				finalColor = hookColor
			end
		end

		chat.AddText( Color(100, 100, 255), "[Quantum Entanglement Device] - ", finalColor, finalText )
	end )

	net.Receive( "NZ.BO3WW.FOX.QuantumBomb.Vox", function(len, ply)
		local soundpath = net.ReadString()

		if file.Exists( "sound/"..soundpath, "GAME" ) then
			surface.PlaySound(soundpath)
		end
	end )
end
