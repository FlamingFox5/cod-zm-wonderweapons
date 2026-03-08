local nzombies = engine.ActiveGamemode() == "nzombies"

local WonderWeapons = TFA.WonderWeapon

if CLIENT then
	local crosshair_cvar = GetConVar("cl_tfa_bo3ww_crosshair")

	hook.Add("TFA_DrawCrosshair", "TFA.BO3WW.FOX.DrawCrosshair", function( weapon )
		if not IsValid( weapon ) or not weapon.WWCrosshairEnabled then return end

		if crosshair_cvar:GetBool() then
			return true
		end
	end)
end

if SERVER then
	hook.Add( "EntityTakeDamage", "TFA.BO3WW.FOX.EntityTakeDamage", function( ent, damageinfo )
		if ent:IsPlayer() then
			local pwep = ent:GetActiveWeapon()
			if IsValid(pwep) and pwep.BO3PESEnabled and not pwep.TakingOff then
				local mask = pwep.DamageTypes
				if bit.band( damageinfo:GetDamageType(), bit.bnot( mask ) ) <= 0 then
					return true
				end
			end

			if ent:GetNW2Bool("PESEnabled", false) then
				local wep = ent:GetWeapon("tfa_bo3_pes")
				if IsValid(wep) then //credit to hidden for damagetype code
					local mask = wep.DamageTypes
					if bit.band( damageinfo:GetDamageType(), bit.bnot( mask ) ) <= 0 then
						if wep.LastChatter and wep.LastChatter < CurTime() and math.random( 10 ) == 1 then
							wep:EmitSound( "TFA_BO3_PES.Chatter" )
							wep.LastChatter = CurTime() + ( math.random( 5, 12 ) * 10 )
						end

						return true
					end
				end
			end
		end

		// Slam Attacks block incoming damage in nZombies
		local attacker = damageinfo:GetAttacker()
		if not IsValid(attacker) then return end

		if nzombies and ent:IsPlayer() then
			local wep = ent:GetActiveWeapon()
			if IsValid(wep) and wep.BO3CanSlam and wep:GetDG4Slamming() and not ent:IsOnGround() and attacker:IsValidZombie() then
				return true
			end
		end
	end )

	hook.Add( "OnPlayerHitGround", "TFA.BO3WW.FOX.HitGround", function( ply, inWater, onFloater, speed )
		local weapon = ply:GetActiveWeapon()

		if IsValid( weapon ) and weapon.BO3CanSlam and weapon:GetDG4Slamming() then
			weapon:SetSlamNormal( vector_origin )
			weapon:SetDG4Slamming( false )

			return true
		end
	end )
end

//-------------------------------------------------------------
// Weapon Movement Mechanics
//-------------------------------------------------------------

local vector_down_250 = Vector( 0, 0, 250 )
local vector_down_1000 = Vector( 0, 0, 1000 )
local vecCappedVelocity = Vector()

hook.Add( "SetupMove", "TFA.BO3WW.FOX.SetupMove", function( ply, cmovedata, cusercommand )
	if ply:GetMoveType() ~= MOVETYPE_NOCLIP and ( not nzombies or ( nzombies and ply:GetNotDowned() ) ) then
		local weapon = ply:GetActiveWeapon()

		// Dashing
		if IsValid( weapon ) and weapon.IsTFAWeapon and weapon.BO3CanDash then
			if ply:IsOnGround() and weapon:GetDashing() then
				local ang = cmovedata:GetAngles()
				local fwd = Angle( 0, ang.yaw, ang.roll ):Forward()

				local mult = weapon.BO3DashMult or 1.5
				local speed = weapon.BO3DashSpeed or 1000
				local delta = math.Clamp( weapon:GetStatusProgress() * mult, 0, 1 )

				cmovedata:SetVelocity( fwd * ( speed * delta ) )
			end
		end

		// Slamming
		if IsValid( weapon ) and weapon.IsTFAWeapon and weapon.BO3CanSlam then
			local status = weapon:GetStatus()

			// Launch player forward and into the air
			if status == TFA.Enum.STATUS_GRENADE_PULL then
				ply:SetGroundEntity( nil )
				cmovedata:SetVelocity( weapon:GetSlamNormal() * ( weapon.DG4SlamFwd or 350 ) + ( weapon.DG4SlamUp or vector_down_250 ) )
			end

			// Slam the player downwards while retaining XY directional momentum
			if status == TFA.Enum.STATUS_GRENADE_PULL and CurTime() >= weapon:GetStatusEnd() then
				local CMoveVelocity = cmovedata:GetVelocity()
				vecCappedVelocity:SetUnpacked( CMoveVelocity[1], CMoveVelocity[2], math.Clamp( CMoveVelocity[3], 0, ply:GetJumpPower() ) )

				cmovedata:SetVelocity( vecCappedVelocity - vector_down_1000 )
			end

			// Instantly kill players velocity to sweeten the impact
			if status == TFA.Enum.STATUS_GRENADE_THROW then
				cmovedata:SetVelocity( vector_origin )
			end
		end
	end
end )

hook.Add( "StartCommand", "TFA.BO3WW.FOX.StartCommand", function( ply, cusercommand )
	if ply:GetMoveType() ~= MOVETYPE_NOCLIP and ( not nzombies or ( nzombies and ply:GetNotDowned() ) ) then
		local weapon = ply:GetActiveWeapon()

		if IsValid(weapon) and weapon.IsTFAWeapon then
			if weapon.BO3CanHack then
				local entity = ply:GetEyeTrace().Entity
				local target = weapon:GetHackerTarget()

				// When holding down +USE and looking at a new entity thats different from our current hacker target, switch to hacking the new entity

				if cusercommand:KeyDown(IN_USE) then
					if IsValid(entity) and not IsValid(target) then
						weapon:SetHackerTarget(entity)
					end
				elseif IsValid(target) then
					// No longer holding +USE and reset the hacker target

					weapon:SetHackerTarget(nil)
				end
			end

			// Dash ability weapons disable movement input during said attack
			if weapon.BO3CanDash and ply:IsOnGround() and weapon:GetDashing() then
				cusercommand:RemoveKey(IN_SPEED)
				cusercommand:RemoveKey(IN_JUMP)
				cusercommand:RemoveKey(IN_DUCK)
				cusercommand:ClearMovement()
			end

			// Slam ability weapons disable movement input during said attack
			if weapon.BO3CanSlam and weapon:GetDG4Slamming() then
				cusercommand:RemoveKey(IN_SPEED)
				cusercommand:RemoveKey(IN_JUMP)
				cusercommand:RemoveKey(IN_DUCK)
				cusercommand:ClearMovement()
			end
		end
	end
end )

if CLIENT then
	hook.Add( "GetMotionBlurValues", "TFA.BO3WW.FOX.MotionBlurs", function( horizontal, vertical, forward, rotation )
		local ply = LocalPlayer()
		if not IsValid(ply) then return end

		local weapon = ply:GetActiveWeapon()
		if not IsValid(weapon) then return end

		if weapon.BO3CanSlam and weapon:GetDG4Slamming() then
			local mult = ply:GetVelocity():Length()
			mult = math.Clamp( mult / 300, 0, 1 )

			return horizontal, vertical + 0.005 * mult, forward + 0.05 * mult, rotation
		end

		if weapon.BO3CanDash and weapon:GetDashing() then
			local mult = ply:GetVelocity():Length()
			mult = math.Clamp( mult / 750, 0, 1 )

			return horizontal, vertical, forward + 0.1 * mult, rotation
		end
	end )
end

//-------------------------------------------------------------
// Weapon Steal SWEP
//-------------------------------------------------------------

hook.Add( "PlayerSwitchWeapon", "TFA.BO3WW.FOX.WeaponSteal.SwitchWeapon", function( ply, oldWep, newWep )
	if not IsValid( ply ) or not IsValid( oldWep ) then return end

	if oldWep:GetClass() == "tfa_bo3_wepsteal" and oldWep:GetStatus() == TFA.Enum.STATUS_DRAW then
		return true
	end
end )

if CLIENT then
	hook.Add( "HUDWeaponPickedUp", "TFA.BO3WW.FOX.WeaponSteal.PickedUp", function( weapon )
		if not IsValid( weapon ) then return end

		if weapon:GetClass() == "tfa_bo3_wepsteal" then
			return true
		end
	end )

	//-------------------------------------------------------------
	// Gibbing Cooked Ragdolls
	//-------------------------------------------------------------

	local AMMO_FORCE_DROP_IF_CARRIED = 1

	local CLIENT_RAGDOLLS = {
		"class C_ClientRagdoll",
		"class C_HL2MPRagdoll",
	}

	G_RagdollIsCooking = false

	hook.Add( "PostEntityFireBullets", "TFA.BO3WW.FOX.ClientFireBullets", function( entity, data )
		if not G_RagdollIsCooking then return end

		local attacker = data.Attacker
		local trace = data.Trace
		local damage = data.Damage
		local force = data.Force

		ammoData = game.GetAmmoData( data.AmmoType )
		local flags = ammoData.flags
		if flags and flags == AMMO_INTERPRET_PLRDAMAGE_AS_DAMAGE_TO_PLAYER then
			damage = ammoData.plydmg
		end

		if damage <= 0 then return end

		local ragtrace = util_TraceLine({
			start = trace.StartPos,
			endpos = trace.HitPos,
			mask = MASK_SHOT,
			ignoreworld = true,

			hitclientonly = true,
			whitelist = true,
			filter = CLIENT_RAGDOLLS,
		})

		if !IsValid( ragdoll.Entity ) then return end

		local ragdoll = ragtrace.Entity
		local mDeathFX = WonderWeapons.GetDeathEffect( ragdoll, "BO3_Wavegun_Cook" )
		if mDeathFX then
			if ragdoll.RagdollIntegrity == nil then
				ragdoll.RagdollIntegrity = 25
			end
			if isnumber( ragdoll.RagdollIntegrity ) then
				ragdoll.RagdollIntegrity = ragdoll.RagdollIntegrity - damage
			end

			local flRagdollHealth = ragdoll.RagdollIntegrity

			if ( mDeathFX:GetStartTime() + (mDeathFX:GetDuration() / 2) < CurTime() ) or force >= 20 or ( flags and flags == AMMO_FORCE_DROP_IF_CARRIED ) or ( flRagdollHealth ~= nil and isnumber( flRagdollHealth ) and flRagdollHealth <= 0 ) then
				WonderWeapons.RemoveStatus( ragdoll, "BO3_Wavegun_Cook" )
				WonderWeapons.DoDeathEffect( ragdoll, "BO3_Wavegun_Pop" )
			else
				local physicsObject = ragdoll:GetPhysicsObjectNum( ragtrace.PhysicsBone )
				if IsValid( physicsObject ) then
					physicsObject:ApplyForceOffset( ragtrace.Normal*force, ragtrace.HitPos )
				end
			end
		end
	end )

	//-------------------------------------------------------------
	// OnScreen Indicators
	//-------------------------------------------------------------

	WonderWeapons.Indicators = WonderWeapons.Indicators or {}
	WonderWeapons.Indicators['bo3_ww_crossbow'] = Material("vgui/icon/hud_indicator_arrow.png", "smooth unlitgeneric")
	WonderWeapons.Indicators['bo3_ww_scavenger'] = Material("vgui/icon/hud_indicator_sniper_explosive.png", "smooth unlitgeneric")

	local ents_FindInSphere = ents.FindInSphere

	local cl_screenvisuals = GetConVar("cl_tfa_bo3ww_screen_visuals")

	if !nzombies then
		hook.Add("HUDPaint", "TFA.BO3WW.FOX.Indicators.HudPaint", function()
			local ply = LocalPlayer()
			if not IsValid(ply) then return end

			if cl_screenvisuals ~= nil and (cl_screenvisuals:GetInt() ~= 1 and cl_screenvisuals:GetInt() ~= 2) then
				return
			end

			local dents = {}
			local pos = ply:GetPos()
			local Indicators = WonderWeapons.Indicators

			for _, ent in pairs( ents_FindInSphere( pos, 350 ) ) do
				if Indicators[ ent:GetClass() ] then
					local dir = ply:EyeAngles():Forward()
					local facing = ( pos - ent:GetPos() ):GetNormalized()

					if ( facing:Dot( dir ) + 1 ) / 2 > 0.45 then
						table.insert( dents, ent )
					end
				end
			end

			for _, ent in ipairs( dents ) do
				if ent:GetCreationTime() + 0.2 > CurTime() then continue end

				local totaldist = 350^2
				local distfade = 250^2
				local playerpos = pos:DistToSqr( ent:GetPos() )
				local fadefac = 1 - math.Clamp( ( playerpos - totaldist + distfade ) / distfade, 0, 1 )

				local dir = ( ent:GetPos() - ply:GetShootPos() ):Angle()
				dir = dir - EyeAngles()
				local angle = dir.y + 90

				local x = ( math.cos( math.rad( angle ) ) * ScreenScale( 128 ) ) + ScrW() / 2
				local y = ( math.sin( math.rad( angle ) ) * -ScreenScale( 128 ) ) + ScrH() / 2

				surface.SetMaterial( Indicators[ ent:GetClass() ] )
				surface.SetDrawColor( ColorAlpha( color_white, 255 * fadefac ) )
				surface.DrawTexturedRect( x, y, ScreenScale( 24 ), ScreenScale( 24 ) )
			end
		end)
	end
end

if nzombies then return end

//-------------------------------------------------------------
// Skullgun Illusionary Brush / IO System
//-------------------------------------------------------------

if SERVER then
	util.AddNetworkString("TFA.BO3WW.FOX.MapEntitiesRequest")
	util.AddNetworkString("TFA.BO3WW.FOX.MapEntitiesSend")

	local flMessageDelay = 0

	WonderWeapons.MapEntsToNetwork = WonderWeapons.MapEntsToNetwork or {}
	WonderWeapons.MapEntsToNetwork["func_illusionary"] = true
	WonderWeapons.MapEntsToNetwork["trigger_teleport"] = true
	WonderWeapons.MapEntsToNetwork["trigger_teleport_relative"] = true
	WonderWeapons.MapEntsToNetwork["info_teleport_destination"] = true
	WonderWeapons.MapEntsToNetwork["info_target_gunshipcrash"] = true

	local MapBrushEntities = WonderWeapons.MapEntsToNetwork

	net.Receive( "TFA.BO3WW.FOX.MapEntitiesRequest", function( len, ply )
		if not IsValid( ply ) then return end

		local entlist = ents.GetAll()
		local num = 0
		for i, brush in pairs( entlist ) do
			if WonderWeapons.MapEntsToNetwork[ brush:GetClass() ] then
				num = 1 + num

				if num % 3 == 0 then
					flMessageDelay = 0.5 + flMessageDelay
				end

				local index = brush:CreatedByMap() and brush:MapCreationID() or brush:EntIndex()
				local mins, maxs = brush:GetModelBounds()
				local position = brush:GetPos()

				timer.Simple(flMessageDelay, function()
					if not IsValid( ply ) then return end
					if not IsValid( brush ) then return end

					net.Start("TFA.BO3WW.FOX.MapEntitiesSend")
						net.WriteString(brush:GetName())
						net.WriteString(brush:GetClass())
						net.WriteVector(position)
						net.WriteVector(mins or vector_origin)
						net.WriteVector(maxs or vector_origin)
						net.WriteUInt(index, MAX_EDICT_BITS)
					net.Send(ply)
				end)
			end
		end
	end )
end

if CLIENT then
	local vecLineStart = Vector()
	local vecLineEnd = Vector()

	local mat_rope = Material("particles/custom/misc/beam_nocolor_noz.vmt")

	local color_offwhite = Color(255, 250, 240, 255)

	WonderWeapons.MapBrushEntities = WonderWeapons.MapBrushEntities or {}

	local MapBrushEntities = WonderWeapons.MapBrushEntities

	hook.Add( "PreDrawEffects", "TFA.BO3WW.FOX.DrawBrushEntities", function()
		local ply = LocalPlayer()
		if IsValid( ply:GetObserverTarget() ) then
			ply = ply:GetObserverTarget()
		end

		if ply.GetActiveWeapon then
			local wep = ply:GetActiveWeapon()
			local vecPlayer = ply:GetShootPos()

			// Skull must be equipped
			if IsValid( wep ) and wep:GetClass() == "tfa_bo3_skullgun" then
				for index, data in pairs( MapBrushEntities ) do
					local vecPos = data.pos
					local vecMins = data.mins
					local vecMaxs = data.maxs
					local flFade = data.fade

					/*local trace = util.TraceLine({
						start = vecPlayer,
						endpos = vecPos + vector_up * ( vecMaxs[3]*0.5 ),
						mask = MASK_SOLID_BRUSHONLY,
						filter = ply,
					})

					if trace.HitWorld then return end*/

					local flDistance = vecPos:Distance(vecPlayer)
					local flDistRatio = ( 1 - math.Clamp( ( flDistance - 260 + 60 ) / 60, 0, 1 ) )

					// Brush must be visible and within 260 units, and must be using flashlight mode on Skullgun
					if wep:GetStatus() == TFA.Enum.STATUS_SHOOTING and wep:GetAttackType() == 1 and vecPos:Distance(vecPlayer) < 260 then
						local angle = 1 - math.cos( math.rad(40) )

						local vecAim = ply:EyeAngles():Forward()
						local vecDir = ( vecPlayer - vecPos ):GetNormalized()
						local flDot = ( vecDir:Dot( vecAim ) + 1 ) / 2
						if flDot > angle then continue end

						MapBrushEntities[index].fade = math.Clamp(FrameTime()*4 + flFade, 0, 1)
					elseif flFade > 0 then
						MapBrushEntities[index].fade = math.Clamp(flFade - FrameTime()*0.5, 0, 1)
					end

					local bPointEntity = data.point
					local ParticleList = data.particles

					flFade = MapBrushEntities[index].fade

					// Box Outline
					if flFade > 0.5 then
						if bPointEntity then
							if not ParticleList[1] or not IsValid( ParticleList[1] ) then
								ParticleList[1] = CreateParticleSystemNoEntity("bo3_skull_ground", vecPos, angle_zero)
							end
						else
							//color_offwhite = ColorAlpha( color_offwhite, 255*( flFade * flDistRatio ) )

							//render.SetMaterial( mat_rope )

							// Bottom 4.
							vecLineStart:SetUnpacked( vecMins.x, vecMins.y, vecMins.z )
							vecLineStart:Add( vecPos )

							vecLineEnd:SetUnpacked( vecMaxs.x, vecMins.y, vecMins.z )
							vecLineEnd:Add( vecPos )

							if not ParticleList[1] or not IsValid( ParticleList[1] ) then
								ParticleList[1] = CreateParticleSystemNoEntity("bo3_skullgun_outline", vecPos, angle_zero)

								local lineFX = ParticleList[1]
								if lineFX and IsValid( lineFX ) then
									lineFX:SetControlPoint(0, vecLineStart)
									lineFX:SetControlPoint(1, vecLineEnd)
								end
							end
							//render.DrawBeam( vecLineStart, vecLineEnd, 4, 0, 1, color_offwhite )

							vecLineStart:SetUnpacked( vecMins.x, vecMins.y, vecMins.z )
							vecLineStart:Add( vecPos )

							vecLineEnd:SetUnpacked( vecMins.x, vecMaxs.y, vecMins.z )
							vecLineEnd:Add( vecPos )

							if not ParticleList[2] or not IsValid( ParticleList[2] ) then
								ParticleList[2] = CreateParticleSystemNoEntity("bo3_skullgun_outline", vecPos, angle_zero)

								local lineFX = ParticleList[2]
								if lineFX and IsValid( lineFX ) then
									lineFX:SetControlPoint(0, vecLineStart)
									lineFX:SetControlPoint(1, vecLineEnd)
								end
							end
							//render.DrawBeam( vecLineStart, vecLineEnd, 4, 0, 1, color_offwhite )

							vecLineStart:SetUnpacked( vecMaxs.x, vecMins.y, vecMins.z )
							vecLineStart:Add( vecPos )

							vecLineEnd:SetUnpacked( vecMaxs.x, vecMaxs.y, vecMins.z )
							vecLineEnd:Add( vecPos )

							if not ParticleList[3] or not IsValid( ParticleList[3] ) then
								ParticleList[3] = CreateParticleSystemNoEntity("bo3_skullgun_outline", vecPos, angle_zero)

								local lineFX = ParticleList[3]
								if lineFX and IsValid( lineFX ) then
									lineFX:SetControlPoint(0, vecLineStart)
									lineFX:SetControlPoint(1, vecLineEnd)
								end
							end
							//render.DrawBeam( vecLineStart, vecLineEnd, 4, 0, 1, color_offwhite )

							vecLineStart:SetUnpacked( vecMaxs.x, vecMaxs.y, vecMins.z )
							vecLineStart:Add( vecPos )

							vecLineEnd:SetUnpacked( vecMins.x, vecMaxs.y, vecMins.z )
							vecLineEnd:Add( vecPos )

							if not ParticleList[4] or not IsValid( ParticleList[4] ) then
								ParticleList[4] = CreateParticleSystemNoEntity("bo3_skullgun_outline", vecPos, angle_zero)

								local lineFX = ParticleList[4]
								if lineFX and IsValid( lineFX ) then
									lineFX:SetControlPoint(0, vecLineStart)
									lineFX:SetControlPoint(1, vecLineEnd)
								end
							end
							//render.DrawBeam( vecLineStart, vecLineEnd, 4, 0, 1, color_offwhite )

							// Top 4.
							vecLineStart:SetUnpacked( vecMins.x, vecMins.y, vecMaxs.z )
							vecLineStart:Add( vecPos )

							vecLineEnd:SetUnpacked( vecMaxs.x, vecMins.y, vecMaxs.z )
							vecLineEnd:Add( vecPos )

							if not ParticleList[5] or not IsValid( ParticleList[5] ) then
								ParticleList[5] = CreateParticleSystemNoEntity("bo3_skullgun_outline", vecPos, angle_zero)

								local lineFX = ParticleList[5]
								if lineFX and IsValid( lineFX ) then
									lineFX:SetControlPoint(0, vecLineStart)
									lineFX:SetControlPoint(1, vecLineEnd)
								end
							end
							//render.DrawBeam( vecLineStart, vecLineEnd, 4, 0, 1, color_offwhite )

							vecLineStart:SetUnpacked( vecMins.x, vecMins.y, vecMaxs.z )
							vecLineStart:Add( vecPos )

							vecLineEnd:SetUnpacked( vecMins.x, vecMaxs.y, vecMaxs.z )
							vecLineEnd:Add( vecPos )

							if not ParticleList[6] or not IsValid( ParticleList[6] ) then
								ParticleList[6] = CreateParticleSystemNoEntity("bo3_skullgun_outline", vecPos, angle_zero)

								local lineFX = ParticleList[6]
								if lineFX and IsValid( lineFX ) then
									lineFX:SetControlPoint(0, vecLineStart)
									lineFX:SetControlPoint(1, vecLineEnd)
								end
							end
							//render.DrawBeam( vecLineStart, vecLineEnd, 4, 0, 1, color_offwhite )

							vecLineStart:SetUnpacked( vecMaxs.x, vecMins.y, vecMaxs.z )
							vecLineStart:Add( vecPos )

							vecLineEnd:SetUnpacked( vecMaxs.x, vecMaxs.y, vecMaxs.z )
							vecLineEnd:Add( vecPos )

							if not ParticleList[7] or not IsValid( ParticleList[7] ) then
								ParticleList[7] = CreateParticleSystemNoEntity("bo3_skullgun_outline", vecPos, angle_zero)

								local lineFX = ParticleList[7]
								if lineFX and IsValid( lineFX ) then
									lineFX:SetControlPoint(0, vecLineStart)
									lineFX:SetControlPoint(1, vecLineEnd)
								end
							end
							//render.DrawBeam( vecLineStart, vecLineEnd, 4, 0, 1, color_offwhite )

							vecLineStart:SetUnpacked( vecMaxs.x, vecMaxs.y, vecMaxs.z )
							vecLineStart:Add( vecPos )

							vecLineEnd:SetUnpacked( vecMins.x, vecMaxs.y, vecMaxs.z )
							vecLineEnd:Add( vecPos )

							if not ParticleList[8] or not IsValid( ParticleList[8] ) then
								ParticleList[8] = CreateParticleSystemNoEntity("bo3_skullgun_outline", vecPos, angle_zero)

								local lineFX = ParticleList[8]
								if lineFX and IsValid( lineFX ) then
									lineFX:SetControlPoint(0, vecLineStart)
									lineFX:SetControlPoint(1, vecLineEnd)
								end
							end
							//render.DrawBeam( vecLineStart, vecLineEnd, 4, 0, 1, color_offwhite )

							// Connecting 4.
							vecLineStart:SetUnpacked( vecMins.x, vecMins.y, vecMins.z )
							vecLineStart:Add( vecPos )

							vecLineEnd:SetUnpacked( vecMins.x, vecMins.y, vecMaxs.z )
							vecLineEnd:Add( vecPos )

							if not ParticleList[9] or not IsValid( ParticleList[9] ) then
								ParticleList[9] = CreateParticleSystemNoEntity("bo3_skullgun_outline", vecPos, angle_zero)

								local lineFX = ParticleList[9]
								if lineFX and IsValid( lineFX ) then
									lineFX:SetControlPoint(0, vecLineStart)
									lineFX:SetControlPoint(1, vecLineEnd)
								end
							end
							//render.DrawBeam( vecLineStart, vecLineEnd, 4, 0, 1, color_offwhite )

							vecLineStart:SetUnpacked( vecMins.x, vecMaxs.y, vecMins.z )
							vecLineStart:Add( vecPos )

							vecLineEnd:SetUnpacked( vecMins.x, vecMaxs.y, vecMaxs.z )
							vecLineEnd:Add( vecPos )

							if not ParticleList[10] or not IsValid( ParticleList[10] ) then
								ParticleList[10] = CreateParticleSystemNoEntity("bo3_skullgun_outline", vecPos, angle_zero)

								local lineFX = ParticleList[10]
								if lineFX and IsValid( lineFX ) then
									lineFX:SetControlPoint(0, vecLineStart)
									lineFX:SetControlPoint(1, vecLineEnd)
								end
							end
							//render.DrawBeam( vecLineStart, vecLineEnd, 4, 0, 1, color_offwhite )

							vecLineStart:SetUnpacked( vecMaxs.x, vecMaxs.y, vecMins.z )
							vecLineStart:Add( vecPos )

							vecLineEnd:SetUnpacked( vecMaxs.x, vecMaxs.y, vecMaxs.z )
							vecLineEnd:Add( vecPos )

							if not ParticleList[11] or not IsValid( ParticleList[11] ) then
								ParticleList[11] = CreateParticleSystemNoEntity("bo3_skullgun_outline", vecPos, angle_zero)

								local lineFX = ParticleList[11]
								if lineFX and IsValid( lineFX ) then
									lineFX:SetControlPoint(0, vecLineStart)
									lineFX:SetControlPoint(1, vecLineEnd)
								end
							end
							//render.DrawBeam( vecLineStart, vecLineEnd, 4, 0, 1, color_offwhite )

							vecLineStart:SetUnpacked( vecMaxs.x, vecMins.y, vecMins.z )
							vecLineStart:Add( vecPos )

							vecLineEnd:SetUnpacked( vecMaxs.x, vecMins.y, vecMaxs.z )
							vecLineEnd:Add( vecPos )

							if not ParticleList[12] or not IsValid( ParticleList[12] ) then
								ParticleList[12] = CreateParticleSystemNoEntity("bo3_skullgun_outline", vecPos, angle_zero)

								local lineFX = ParticleList[12]
								if lineFX and IsValid( lineFX ) then
									lineFX:SetControlPoint(0, vecLineStart)
									lineFX:SetControlPoint(1, vecLineEnd)
								end
							end
							//render.DrawBeam( vecLineStart, vecLineEnd, 4, 0, 1, color_offwhite )
						end
					else
						for i, CNParticle in pairs( ParticleList ) do
							if CNParticle and IsValid( CNParticle ) then
								CNParticle:StopEmission()
							end
						end
					end
				end
			end
		end
	end )

	net.Receive( "TFA.BO3WW.FOX.MapEntitiesSend", function( length )
		local name = net.ReadString()
		local class = net.ReadString()
		local position = net.ReadVector()
		local mins = net.ReadVector()
		local maxs = net.ReadVector()
		local index = net.ReadUInt(MAX_EDICT_BITS)

		class = string.lower(class)

		local bPointEntity = false
		local nStart, nEnd = string.find( class, "info_" )
		if nStart and nStart == 1 then
			bPointEntity = true
		end

		MapBrushEntities[index] = { pos = position, mins = mins, maxs = maxs, name = name, class = class, point = bPointEntity, particles = {}, fade = 0 }
	end )

	hook.Add( "InitPostEntity", "TFA.BO3WW.FOX.MapEntitiesRequest", function()
		hook.Add( "Think", "TFA.BO3WW.FOX.MapEntitiesRequest", function()
			if not IsValid( LocalPlayer() ) then return end

			hook.Remove( "Think", "TFA.BO3WW.FOX.MapEntitiesRequest" )

			net.Start("TFA.BO3WW.FOX.MapEntitiesRequest")
			net.SendToServer()
		end )
	end )
end