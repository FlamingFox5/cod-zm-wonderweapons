local nzombies = engine.ActiveGamemode() == "nzombies"
local pvp_cvar = GetConVar("sbox_playershurtplayers")
local sv_true_damage = GetConVar("sv_tfa_bo3ww_cod_damage")
local SinglePlayer = game.SinglePlayer()

local CurTime = CurTime
local IsValid = IsValid

local bit_AND = bit.band

local util_TraceLine = util.TraceLine
local util_PointContents = util.PointContents
local util_ScreenShake = util.ScreenShake

local DispatchEffect = util.Effect

local MASK_SHOT = MASK_SHOT
local MAT_GLASS = MAT_GLASS
local CONTENTS_SLIME = CONTENTS_SLIME
local CONTENTS_LIQUID = bit.bor( CONTENTS_WATER, CONTENTS_SLIME )
local MASK_RADIUS_DAMAGE = bit.band( MASK_SHOT, bit.bnot( CONTENTS_HITBOX ) )
local COLLISION_GROUP_BREAKABLE_GLASS = COLLISION_GROUP_BREAKABLE_GLASS

local BodyTarget = TFA.WonderWeapon.BodyTarget
local GiveStatus = TFA.WonderWeapon.GiveStatus
local HasStatus = TFA.WonderWeapon.HasStatus
local ShouldDamage = TFA.WonderWeapon.ShouldDamage

//-------------------------------------------------------------
// Q.E.D. Effects
//-------------------------------------------------------------

local WonderWeapons = TFA.WonderWeapon

WonderWeapons.QuantumBomb = WonderWeapons.QuantumBomb or {}

local QuantumBombTable = WonderWeapons.QuantumBomb

QuantumBombTable.EffectTypes = QuantumBombTable.EffectTypes or {}

local EffectTypes = QuantumBombTable.EffectTypes

EffectTypes.NONE = 0
EffectTypes.NEUTRAL = 1
EffectTypes.POSITIVE = 2
EffectTypes.NEGATIVE = 3
EffectTypes.WAVEGUN = 4
EffectTypes.GOLDEN = 5

QuantumBombTable.Effects = QuantumBombTable.Effects or {}

local QuantumBombEffects = QuantumBombTable.Effects

function WonderWeapons.AddQuantumBombEffect( id, data )
	QuantumBombEffects[ id ] = data
end

function WonderWeapons.QuantumBombData( id )
	return QuantumBombEffects[ id ] or nil
end

if SERVER then
	util.AddNetworkString("TFA.BO3WW.FOX.QuantumBomb.Vox")
	util.AddNetworkString("TFA.BO3WW.FOX.QuantumBomb.Text")

	QuantumBombTable.CachedWeightTable = {}

	function WonderWeapons.QuantumBombWeights()
		local effect, weight = next( QuantumBombTable.CachedWeightTable )
		if effect ~= nil and weight ~= nil and isnumber( weight ) then
			return QuantumBombTable.CachedWeightTable
		else
			for effect, data in pairs( QuantumBombEffects ) do
				if data.Special then
					continue
				end

				if data and data.Weight and isnumber( data.Weight ) and data.Weight > 0 then
					QuantumBombTable.CachedWeightTable[ effect ] = data.Weight
				end
			end

			hook.Run( "TFA_WonderWeapon_QuantumBombBuildWeights", QuantumBombTable.CachedWeightTable )

			return QuantumBombTable.CachedWeightTable
		end
	end
end

if CLIENT then
	QuantumBombTable.EffectColors = QuantumBombTable.EffectColors or {
		[EffectTypes.NONE] = color_white,
		[EffectTypes.NEUTRAL] = Color(255, 254, 240),
		[EffectTypes.POSITIVE] = Color(100, 255, 100),
		[EffectTypes.NEGATIVE] = Color(255, 100, 100),
		[EffectTypes.WAVEGUN] = Color(200, 100, 255),
		[EffectTypes.GOLDEN] = Color(255, 225, 100),
	}

	net.Receive( "TFA.BO3WW.FOX.QuantumBomb.Text", function(len, ply)
		local effect = net.ReadString()
		local data = WonderWeapons.QuantumBombData[effect]
		if not data or not data.Name then return end

		local finalColor = QuantumBombTable.EffectColors[data.Effect or 0] or color_white
		local finalText = tostring(data.Name)

		local hookText, hookColor = hook.Run( "TFA_WonderWeapon_QuantumBombText", LocalPlayer(), effect, data )
		if hookText ~= nil and isstring( hookText ) and hookText ~= "" then
			finalText = hookText

			if hookColor ~= nil and IsColor( hookColor ) then
				finalColor = hookColor
			end
		end

		chat.AddText( Color(100, 100, 255), "[Quantum Entanglement Device] - ", finalColor, finalText )
	end )

	net.Receive( "TFA.BO3WW.FOX.QuantumBomb.Vox", function(len, ply)
		local soundpath = net.ReadString()

		if file.Exists( "sound/"..soundpath, "GAME" ) then
			surface.PlaySound(soundpath)
		end
	end )
end

WonderWeapons.AddQuantumBombEffect("Astro_Pop", {
	Name = "Astronaut Pop",
	//AnnouncerVox = "",
	Effect = EffectTypes.NONE,
	Remove = true,
	Weight = 35,
	Safe = false,
	OnActivate = function(self)
		self:EmitSound("TFA_BO3_QED.AstroPop")
		ParticleEffect("bo3_astronaut_pulse", self:GetPos(), self:GetAngles())

		local vecSrc = self:GetPos()

		local bSubmerged = bit_AND( util_PointContents( vecSrc + vector_up*32 ), CONTENTS_LIQUID ) ~= 0

		if bSubmerged then
			self:DoExplosionBubblesEffect( vecSrc, vector_up, 12, 300 )
		end

		local damage = DamageInfo()
		damage:SetDamageType(DMG_CRUSH)
		damage:SetAttacker(IsValid(self:GetOwner()) and self:GetOwner() or self)
		damage:SetInflictor(IsValid(self.Inflictor) and self.Inflictor or self)
		damage:SetReportedPosition(vecSrc)

		local nearbyEnts = self:FindNearestEntities( vecSrc, 250 )

		local tr = {
			start = vecSrc,
			filter = { self, self.Inflictor },
			mask = MASK_SHOT,
			collsiongroup = COLLISION_GROUP_NONE,
		}

		for k, ent in pairs(nearbyEnts) do
			if ent:IsWeapon() then
				continue
			end

			local isCharacter = ( ent:IsNPC() or ent:IsPlayer() or ent:IsNextBot() )

			local vecSpot = BodyTarget(ent, vecSrc, true, math.random(16) == 1)
			local dir = ( vecSpot - vecSrc ):GetNormalized()

			tr.endpos = vecSpot

			local trace = util_TraceLine(tr)

			if ent:IsPlayer() then
				ent:ViewPunch( Angle( -25, math.random(-10, 10), 0 ) )
				ent:SetGroundEntity(nil)
				ent:SetVelocity( ( ( ent:GetPos() - self:GetPos() ):GetNormalized() * 200 ) + ent:GetUp() * 200 )
			else
				local p = ent:GetParent()
				if !ent:GetNoDraw() and !IsValid( p ) and ent:GetMoveType() ~= MOVETYPE_NONE then
					ent:SetVelocity( ( ( ent:GetPos() - self:GetPos() ):GetNormalized() * 500 ) + ent:GetUp() * 120 )
				end

				damage:SetDamage( ( sv_true_damage == nil or sv_true_damage:GetBool() ) and ent:Health() + 666 or 10000 )
				damage:SetDamageForce( ent:GetUp()*22000 + dir * 10000 )
				damage:SetDamagePosition( trace.Entity == ent and trace.HitPos or vecSpot )
				damage:SetReportedPosition( self:GetPos() )

				if ent:IsNPC() and ent:Alive() and damage:GetDamage() >= ent:Health() then
					ent:SetCondition(COND.NPC_UNFREEZE)
				end

				if trace.Entity == ent then
					trace.HitGroup = trace.HitGroup == HITGROUP_HEAD and HITGROUP_HEAD or HITGROUP_GENERIC

					self:DoImpactEffect( trace, true )

					local hitInWater = bit_AND( util_PointContents( trace.HitPos ), CONTENTS_LIQUID ) ~= 0
					if ( hitInWater and !bSubmerged ) or ( bSubmerged and !hitInWater ) then
						local trace2 = {}

						util_TraceLine({
							start = trace.StartPos,
							endpos = trace.HitPos,
							mask = CONTENTS_LIQUID,
							output = trace2,
						})

						local data = EffectData()
						data:SetOrigin( trace2.HitPos )
						data:SetNormal( trace2.HitNormal )
						data:SetScale( math.random(2,4) )
						data:SetFlags( bit_AND( trace2.Contents, CONTENTS_SLIME ) != 0 && 1 || 0 )

						DispatchEffect( "watersplash", data, false, true )
					end

					ent:DispatchTraceAttack( damage, trace, dir )
				else
					ent:TakeDamageInfo( damage )
				end

				table.insert( tr.filter, ent )

				self:SendHitMarker( ent, damage, trace )
			end
		end
	end,
})

WonderWeapons.AddQuantumBombEffect("Grenade", {
	Name = "Spawn Grenade",
	//AnnouncerVox = "",
	Effect = EffectTypes.NEUTRAL,
	Remove = true,
	Weight = 8,
	Safe = false,
	OnActivate = function(self)
		local grenade = ents.Create("bo3_misc_frag")
		grenade:SetModel("models/weapons/tfa_bo3/grenade/grenade_prop.mdl")
		grenade:SetPos(self:GetPos() + Vector(0,0,24))
		grenade:SetAngles(self:GetAngles())
		grenade:SetOwner(IsValid(self:GetOwner()) and self:GetOwner() or self)

		grenade.Damage = 500
		grenade.mydamage = 500
		grenade.Delay = 1.2

		grenade:Spawn()

		local phys = grenade:GetPhysicsObject()
		if IsValid(phys) then
			phys:SetVelocity(Vector(0,0,250)+VectorRand(-100,100))
		end

		grenade:SetOwner(IsValid(self:GetOwner()) and self:GetOwner() or self)
		grenade.Inflictor = IsValid(self.Inflictor) and self.Inflictor or self
	end,
})

WonderWeapons.AddQuantumBombEffect("Spidernade", {
	Name = "Spawn Widows Wine Semtex",
	//AnnouncerVox = "",
	Effect = EffectTypes.NEUTRAL,
	Remove = true,
	Weight = 8,
	Safe = false,
	OnActivate = function(self)
		local semtex = ents.Create("bo3_misc_semtex")
		semtex:SetModel("models/weapons/tfa_bo3/semtex/w_semtex.mdl")
		semtex:SetPos(self:GetPos() + Vector(0,0,24))
		semtex:SetAngles(self:GetAngles())
		semtex:SetOwner(IsValid(self:GetOwner()) and self:GetOwner() or self)

		semtex.Damage = 1300
		semtex.mydamage = 1300
		semtex.Delay = 1.2

		semtex:Spawn()

		local phys = semtex:GetPhysicsObject()
		if IsValid(phys) then
			phys:SetVelocity(Vector(0,0,250)+VectorRand(-100,100))
		end

		semtex:SetOwner(IsValid(self:GetOwner()) and self:GetOwner() or self)
		semtex.Inflictor = IsValid(self.Inflictor) and self.Inflictor or self
	end,
})

WonderWeapons.AddQuantumBombEffect("Nestingdolls", {
	Name = "Matryoshka Doll",
	//AnnouncerVox = "",
	Effect = EffectTypes.NEUTRAL,
	Remove = true,
	Weight = 5,
	Safe = false,
	OnActivate = function(self)
		local doll = ents.Create("bo3_tac_matryoshka")
		doll:SetModel("models/weapons/tfa_bo3/matryoshka/matryoshka_prop.mdl")
		doll:SetPos(self:GetPos() + Vector(0,0,6))
		doll:SetAngles(angle_zero)
		doll:SetOwner(IsValid(self:GetOwner()) and self:GetOwner() or self)

		doll.Damage = 100000
		doll.mydamage = 100000
		doll.Delay = 1
		doll:SetCharacter(math.random(4))

		doll:Spawn()

		local phys = doll:GetPhysicsObject()
		if IsValid(phys) then
			phys:SetVelocity(Vector(0,0,250)+VectorRand(-50,50))
		end

		doll:SetOwner(IsValid(self:GetOwner()) and self:GetOwner() or self)
		doll.Inflictor = IsValid(self.Inflictor) and self.Inflictor or self
	end,
})

WonderWeapons.AddQuantumBombEffect("BlackholeBomb", {
	Name = "Gersh Device",
	//AnnouncerVox = "",
	Effect = EffectTypes.POSITIVE,
	Remove = true,
	Weight = 4,
	Safe = false,
	OnActivate = function(self)
		local bhbomb = ents.Create("bo3_tac_gersch")
		bhbomb:SetModel("models/weapons/tfa_bo3/gersch/w_gersch.mdl")
		bhbomb:SetPos(self:GetPos() + Vector(0,0,24))
		bhbomb:SetAngles(angle_zero)
		bhbomb:SetOwner(IsValid(self:GetOwner()) and self:GetOwner() or self)

		bhbomb.Damage = 115
		bhbomb.mydamage = 115

		bhbomb:Spawn()

		local phys = bhbomb:GetPhysicsObject()
		if IsValid(phys) then
			phys:SetVelocity(VectorRand(-25,25))
		end

		bhbomb:SetOwner(IsValid(self:GetOwner()) and self:GetOwner() or self)
		bhbomb.Inflictor = IsValid(self.Inflictor) and self.Inflictor or self
	end,
})

WonderWeapons.AddQuantumBombEffect("RandomTeleport", {
	Name = "Random Teleport",
	//AnnouncerVox = "",
	Effect = EffectTypes.NEGATIVE,
	Remove = true,
	Weight = 5,
	Safe = false,
	OnActivate = function(self)
		local ply = self:GetOwner()

		if navmesh.IsLoaded() then
			local tab = navmesh.Find(self:GetPos(), 60000, 60000, 60000)
			for _, nav in RandomPairs(tab) do
				if IsValid(nav) and not nav:IsUnderwater() then
					self:SetTelePos(nav:GetRandomPoint())
					break
				end
			end
		else
			self:SetTelePos(self:GetRandomSpawnPoint())
		end

		local minBound, maxBound = ply:GetCollisionBounds()
		if ply.GetHull then
			minBound, maxBound = ply:GetHull()
		end

		if not TFA.WonderWeapon.IsCollisionBoxClear( self:GetTelePos(), ply, minBound, maxBound ) then
			ply:PrintMessage(2, "// Teleport Location Blocked //")
			local surroundingTiles = TFA.WonderWeapon.GetSurroundingTiles( ply, self:GetTelePos() )
			local clearPaths = TFA.WonderWeapon.GetClearPaths( ply, self:GetTelePos(), surroundingTiles )	
			for _, tile in pairs( clearPaths ) do
				if TFA.WonderWeapon.IsCollisionBoxClear( tile, ply, minBound, maxBound ) then
					self:SetTelePos( tile )
					ply:PrintMessage(2, "// Teleport Retry Count : "..table.Count( clearPaths ).." //")
					break
				end
			end
		end

		if IsValid(ply) then
			ply:ViewPunch(Angle(-5, math.Rand(-10, 10), 0))
			ply:SetPos(self:GetTelePos())
			ply:SetLocalVelocity(Vector(0,0,0))

			timer.Simple(0, function()
				if ply:GetPos():DistToSqr(self:GetTelePos()) >= 25 then
					ply:SetPos(self:GetTelePos())
					ply:PrintMessage(2, "// Teleport Failed, Forcing  //")
				end
			end)

			ply:EmitSound("TFA_BO3_QED.Teleport")
			ParticleEffect("bo3_qed_explode_1", ply:GetPos(), angle_zero)
		end
	end,
})

WonderWeapons.AddQuantumBombEffect("DamageNearby", {
	Name = "Damage Nearby Players",
	//AnnouncerVox = "",
	Effect = EffectTypes.NEGATIVE,
	Remove = true,
	Weight = 1,
	Safe = false,
	OnActivate = function(self)
		local vecSrc = self:GetPos()

		local damage = DamageInfo()
		damage:SetDamageType(DMG_CRUSH)
		damage:SetReportedPosition(vecSrc)

		local tr = {
			start = vecSrc,
			filter = { self, self.Inflictor },
			mask = MASK_SHOT,
			collsiongroup = COLLISION_GROUP_NONE,
		}

		for _, ent in pairs(ents.FindInSphere(vecSrc, 500)) do
			if not ent:IsPlayer() and not ent:Alive() then continue end

			local vecSpot = BodyTarget(ent, vecSrc, true)
			local dir = ( vecSpot - vecSrc ):GetNormalized()

			tr.endpos = vecSpot

			local trace = util_TraceLine(tr)

			damage:SetDamage( ent:Health() - 1 )
			damage:SetDamageForce( dir * 200 )
			damage:SetDamagePosition( trace.Entity == ent and trace.HitPos or vecSpot )
			damage:SetAttacker( ent )

			ent:SetArmor( 0 )

			if trace.Entity == ent then
				trace.HitGroup = trace.HitGroup == HITGROUP_HEAD and HITGROUP_HEAD or HITGROUP_GENERIC

				self:DoImpactEffect( trace )

				ent:DispatchTraceAttack( damage, trace, dir )
			else
				ent:TakeDamageInfo( damage )
			end

			ParticleEffect( "bo3_qed_explode_3", ent:GetPos(), angle_zero )

			table.insert( tr.filter, ent )

			self:SendHitMarker( ent, damage, trace )
		end
	end,
})

WonderWeapons.AddQuantumBombEffect("TakeAmmo", {
	Name = "Strip Ammo",
	AnnouncerVox = "weapons/tfa_bo3/qed/vox/zmb_vox_ann_points_negative.wav",
	Effect = EffectTypes.NEGATIVE,
	Remove = true,
	Weight = 0.5,
	Safe = false,
	OnActivate = function(self)
		local ply = self:GetOwner()
		if IsValid(ply) and ply:IsPlayer() and ply:Alive() then
			local wep = ply:GetActiveWeapon()
			if IsValid(wep) then
				ply:SetAmmo(0, wep:GetPrimaryAmmoType())
				ply:SetAmmo(0, wep:GetSecondaryAmmoType())
			end
		end
	end,
})

WonderWeapons.AddQuantumBombEffect("TakeWeapon", {
	Name = "Yoink",
	AnnouncerVox = "weapons/tfa_bo3/qed/vox/zmb_vox_ann_points_negative.wav",
	Effect = EffectTypes.NEGATIVE,
	Remove = true,
	Weight = 0.5,
	Safe = false,
	OnActivate = function(self)
		local ply = self:GetOwner()
		if IsValid(ply) and ply:IsPlayer() and ply:Alive() then
			local wep = ply:GetActiveWeapon()
			if IsValid(wep) then
				ply:SetActiveWeapon(nil)
				ply:Give("tfa_bo3_wepsteal")
				ply:SelectWeapon("tfa_bo3_wepsteal")
				ply:StripWeapon(wep:GetClass())
			end
		end
	end,
})

WonderWeapons.AddQuantumBombEffect("DropEquipment", {
	Name = "Equipment Drop",
	Effect = EffectTypes.POSITIVE,
	Remove = true,
	Weight = 1.5,
	Safe = true,
	OnActivate = function(self)
		local startPos = self:GetPos()
		local minBound = Vector(-12, -12, 0)
		local maxBound = Vector(12, 12, 18)

		local ammoTable = {
			[1] = "item_ammo_ar2",
			[2] = "item_ammo_ar2_altfire",
			[3] = "item_ammo_pistol",
			[4] = "item_ammo_smg1",
			[5] = "item_ammo_357",
			[6] = "item_ammo_crossbow",
			[7] = "item_box_buckshot",
			[8] = "item_rpg_round",
			[9] = "item_ammo_smg1_grenade",
			[10] = "weapon_frag",
			[11] = "weapon_slam",
			[12] = "weapon_alyxgun",
		}

		local ammoWeights = {
			[1] = 1,
			[2] = 0,
			[3] = 2,
			[4] = 3,
			[5] = 2,
			[6] = 1,
			[7] = 1,
			[8] = 0,
			[9] = 1,
			[10] = 0,
			[11] = 0,
			[12] = 0,
		}

		local ammoCrates = {}
		local ammoCounts = {}

		local ply = self:GetOwner()
		if IsValid( ply ) and ply:IsPlayer() then
			for id, count in pairs( ply:GetAmmo() ) do
				if ammoTable[id] and count > 0 then
					local max = game.GetAmmoMax( id )
					local ratio = 1 - math.Clamp( count / max, 0, 1 )

					ammoCrates[ammoTable[id]] = math.min( math.ceil( 10 * ratio ) + ammoWeights[id], 1 )
					ammoCounts[ammoTable[id]] = ( ratio < 0.1 ) and math.random( 3, 4 ) or ( ratio < 0.25 ) and math.random( 4 ) or ( ratio < 0.75 ) and math.random( 3 ) or math.random( 2 )
				end
			end

			local count = table.Count( ammoCrates )
			if count < 4 then
				for id, ammo in RandomPairs( ammoTable ) do
					ammoCrates[ammo] = math.random( 10 )
					ammoCounts[ammo] = math.random( 3 )

					count = 1 + count
					if count >= 4 then
						break
					end
				end
			end
		else
			ammoCrates["item_ammo_ar2"] = 10 + ammoWeights[id]
			ammoCounts["item_ammo_ar2"] = math.random( 3 )

			ammoCrates["item_ammo_pistol"] = 10 + ammoWeights[id]
			ammoCounts["item_ammo_pistol"] = math.random( 3 )

			ammoCrates["item_ammo_smg1"] = 10 + ammoWeights[id]
			ammoCounts["item_ammo_smg1"] = math.random( 3 )

			ammoCrates["item_ammo_357"] = 10 + ammoWeights[id]
			ammoCounts["item_ammo_357"] = math.random( 3 )
			
			ammoCrates["item_box_buckshot"] = 10 + ammoWeights[id]
			ammoCounts["item_box_buckshot"] = math.random( 3 )
			
			ammoCrates["item_ammo_ar2_altfire"] = 10 + ammoWeights[id]
			ammoCounts["item_ammo_ar2_altfire"] = math.random( 3 )

			ammoCrates["weapon_frag"] = 10 + ammoWeights[id]
			ammoCounts["weapon_frag"] = 3
		end

		for i = 1, math.min( 4, table.Count( ammoCrates ) ) do
			timer.Simple( i * 0.25, function()
				local tTeleportFilter = { self }

				// hull trace check, increasing check range each time it fails up to 4x players hull width
				if not TFA.WonderWeapon.IsCollisionBoxClear( startPos, tTeleportFilter, minBound, maxBound, true ) then
					for i = 1, 4 do
						local surroundingTiles = TFA.WonderWeapon.GetSurroundingTiles( ply, startPos, checkRange*i )
						local clearPaths = TFA.WonderWeapon.GetClearPaths( ply, startPos, surroundingTiles )	

						for _, tile in pairs( clearPaths ) do
							if TFA.WonderWeapon.IsCollisionBoxClear( tile, tTeleportFilter, minBound, maxBound, true ) then
								local itemClass = TFA.WonderWeapon.WeightedRandom( ammoCrates )

								ammoCrates[ itemClass ] = nil

								local crate = ents.Create( "item_item_crate" )
								crate:SetPos( tile )
								crate:SetAngles( self.GetRoll and self:GetRoll() or self:GetAngles() )

								crate:SetKeyValue( "CrateType", 0 )
								crate:SetKeyValue( "ItemClass", "item_dynamic_resupply" ) //itemClass
								crate:SetKeyValue( "ItemCount", ammoCounts[itemClass] )

								crate:Spawn()

								crate:Activate()
								break
							end
						end
					end
				else
					local itemClass = TFA.WonderWeapon.WeightedRandom( ammoCrates )

					ammoCrates[ itemClass ] = nil

					local crate = ents.Create( "item_item_crate" )
					crate:SetPos( startPos )
					crate:SetAngles( self.GetRoll and self:GetRoll() or self:GetAngles() )

					crate:SetKeyValue( "CrateType", 0 )
					crate:SetKeyValue( "ItemClass", itemClass )
					crate:SetKeyValue( "ItemCount", ammoCounts[itemClass] )

					crate:Spawn()

					crate:Activate()
				end
			end )
		end
	end,
})

WonderWeapons.AddQuantumBombEffect("MaxAmmo", {
	Name = "Max Ammo",
	AnnouncerVox = "weapons/tfa_bo3/qed/vox/zmb_vox_ann_powerup_maxammo_0.wav",
	Effect = EffectTypes.POSITIVE,
	Remove = true,
	Weight = 1,
	Safe = true,
	OnActivate = function(self)
		local ply = self:GetOwner()
		if IsValid(ply) and ply:IsPlayer() then
			for _, wep in pairs(ply:GetWeapons()) do
				if IsValid(wep) then
					if wep.NZMaxAmmo then
						wep:NZMaxAmmo()
					else
						local AmmoToAdd = wep:GetMaxClip1() * 5
						local AmmoToAdd2 = wep:GetMaxClip2() * 5

						ply:GiveAmmo(AmmoToAdd, wep:GetPrimaryAmmoType())
						ply:GiveAmmo(AmmoToAdd2, wep:GetSecondaryAmmoType())
						wep:SetClip1(wep:GetMaxClip1())
						wep:SetClip2(wep:GetMaxClip2())
					end
				end
			end
		end

		ply:EmitSound("TFA_BO3_QED.MaxAmmo")
	end,
})

WonderWeapons.AddQuantumBombEffect("Deathmachine", {
	Name = "Death Machine",
	AnnouncerVox = "weapons/tfa_bo3/qed/vox/death_machine.wav",
	Effect = EffectTypes.POSITIVE,
	Remove = true,
	Weight = 1,
	Safe = true,
	OnActivate = function(self)
		local ply = self:GetOwner()

		ply:EmitSound("TFA_BO3_QED.Pickup")

		ply:Give("tfa_bo3_minigun_zm")
		if ply:IsPlayer() then
			ply:SelectWeapon("tfa_bo3_minigun_zm")
		end
	end,
})

WonderWeapons.AddQuantumBombEffect("Wunderwaffe", {
	Name = "Wunderwaffe",
	AnnouncerVox = "weapons/tfa_bo3/qed/vox/ann_tesla_02.wav",
	Effect = EffectTypes.POSITIVE,
	Remove = true,
	Weight = 1,
	Safe = true,
	OnActivate = function(self)
		local ply = self:GetOwner()

		ply:EmitSound("TFA_BO3_QED.Pickup")

		ply:Give("tfa_bo3_wunderwaffe")
		if ply:IsPlayer() then
			ply:SelectWeapon("tfa_bo3_wunderwaffe")
		end
	end,
})

WonderWeapons.AddQuantumBombEffect("RandomWeapon", {
	Name = "Random Weapon Drop",
	//AnnouncerVox = "",
	Effect = EffectTypes.POSITIVE,
	Remove = true,
	Weight = 2,
	Safe = true,
	OnActivate = function(self)
		local weapon = ents.Create("bo3_powerup_weapon")
		weapon:SetPos(self:GetPos() + Vector(0,0,54))
		weapon:SetOwner(self:GetOwner())
		weapon:SetAngles(angle_zero)

		weapon:Spawn()
	end,
})

WonderWeapons.AddQuantumBombEffect("SpingunLauncher", {
	Name = "Summon MAX-GL",
	//AnnouncerVox = "",
	Effect = EffectTypes.NEGATIVE,
	Remove = true,
	Weight = 4,
	Safe = false,
	OnActivate = function(self)
		local spingun = ents.Create("bo3_misc_spingun")
		spingun:SetModel("models/weapons/tfa_bo3/qed/w_maxgl.mdl")
		spingun:SetPos(self:GetPos() + Vector(0,0,54))
		spingun:SetAngles(angle_zero)
		spingun:SetOwner(self:GetOwner())

		spingun.ShootSound = "TFA_BO3_QED.MAXGL.Fire"
		spingun.NumShots = 1
		spingun.Damage = 500
		spingun.RPM = 500
		spingun.ClipSize = 30

		spingun.Projectile = "bo3_misc_40mm"
		spingun.ProjectileVelocity = 3000
		spingun.ProjectileModel = "models/weapons/tfa_bo3/qed/w_maxgl_proj.mdl"

		spingun:Spawn()
	end,
})

WonderWeapons.AddQuantumBombEffect("SpingunRifle", {
	Name = "Summon KN-44",
	//AnnouncerVox = "",
	Effect = EffectTypes.NEGATIVE,
	Remove = true,
	Weight = 4,
	Safe = false,
	OnActivate = function(self)
		local spingun = ents.Create("bo3_misc_spingun")
		spingun:SetModel("models/weapons/tfa_bo3/qed/w_kn44.mdl")
		spingun:SetPos(self:GetPos() + Vector(0,0,54))
		spingun:SetAngles(angle_zero)
		spingun:SetOwner(self:GetOwner())

		spingun.ShootSound = "TFA_BO3_QED.KN44.Fire"
		spingun.NumShots = 1
		spingun.Damage = 35
		spingun.RPM = 500
		spingun.ClipSize = 30
		spingun.Spread = Vector(0.05, 0.05, 0)

		spingun:Spawn()
	end,
})

WonderWeapons.AddQuantumBombEffect("SpingunShotgun", {
	Name = "Summon Haymaker-12",
	//AnnouncerVox = "",
	Effect = EffectTypes.NEGATIVE,
	Remove = true,
	Weight = 4,
	Safe = false,
	OnActivate = function(self)
		local spingun = ents.Create("bo3_misc_spingun")
		spingun:SetModel("models/weapons/tfa_bo3/qed/w_haymaker.mdl")
		spingun:SetPos(self:GetPos() + Vector(0,0,54))
		spingun:SetAngles(angle_zero)
		spingun:SetOwner(self:GetOwner())

		spingun.ShootSound = "TFA_BO3_QED.HMKR.Fire"
		spingun.NumShots = 8
		spingun.Damage = 8
		spingun.RPM = 500
		spingun.ClipSize = 30
		spingun.Spread = Vector(0.1, 0.1, 0)
		spingun.MuzzleType = 7

		spingun:Spawn()
	end,
})

WonderWeapons.AddQuantumBombEffect("SpingunRaygun", {
	Name = "Summon Raygun",
	//AnnouncerVox = "",
	Effect = EffectTypes.NEGATIVE,
	Remove = true,
	Weight = 1,
	Safe = false,
	OnActivate = function(self)	
		local raychance = math.random(2)
		local mdl1 = "models/weapons/tfa_bo3/raygun/w_raygun.mdl"
		local mdl2 = "models/weapons/tfa_bo3/mk2/w_mk2.mdl"
		local mk2 = raychance == 1

		local spingun = ents.Create("bo3_misc_spingun")
		spingun:SetModel(mk2 and mdl2 or mdl1)
		spingun:SetPos(self:GetPos() + Vector(0,0,54))
		spingun:SetAngles(angle_zero)
		spingun:SetOwner(self:GetOwner())

		spingun.ShootSound = mk2 and "TFA_BO3_MK2.Shoot" or "TFA_BO3_RAYGUN.Shoot"
		spingun.NumShots = 1
		spingun.Damage = 1150
		spingun.RPM = 600
		spingun.ClipSize = 20

		spingun.MuzzleFlashEffect = mk2 and "tfa_bo3_muzzleflash_raygunmk2_qed" or "tfa_bo3_muzzleflash_raygun_qed"
		spingun.MuzzleFlashColor = Color(90, 255, 10)
		
		spingun.Projectile = mk2 and "bo3_ww_mk2" or "bo3_ww_raygun"
		spingun.ProjectileVelocity = 3500
		spingun.ProjectileModel = "models/dav0r/hoverball.mdl"
		
		spingun:Spawn()
	end,
})

WonderWeapons.AddQuantumBombEffect("OpenDoor", {
	Name = "Unlock Door",
	//AnnouncerVox = "",
	Effect = EffectTypes.POSITIVE,
	Remove = true,
	Special = true,
	Weight = 0,
	Safe = true,
	OnActivate = function(self, ent)
		local doorClasses = {
			["prop_door_rotating"] = true,
			["func_door"] = true,
			["func_door_rotating"] = true,
		}

		if not IsValid(ent) then
			for k, v in pairs(ents.FindInSphere(self:GetPos(), 64)) do
				if v:GetMoveType() == MOVETYPE_PUSH and doorClasses[v:GetClass()] then
					ent = v
					break
				end
			end
		end

		if ent.TFADoorUntouchable and ent.TFADoorUntouchable > CurTime() then
			self:DoCustomRemove(EffectTypes.NEGATIVE)
		end

		ent:EmitSound("ambient/materials/door_hit1.wav", 100, math.random(90, 110))

		self.oldname = self:GetName()
		self:SetName("bashingent" .. self:EntIndex())

		local lastspeed = ent:GetInternalVariable("Speed")
		if lastspeed == nil or not isnumber(lastspeed) then
			lastspeed = 100
		end

		ent:Fire("unlock", "", .01)
		ent:SetKeyValue("Speed", "500")
		ent:SetKeyValue("Open Direction", "Both directions")
		ent:SetKeyValue("opendir", "0")
		ent:Fire("openawayfrom", "bashingent" .. self:EntIndex(), .01)

		timer.Simple(0.02, function()
			if IsValid(self) then
				self:SetName(self.oldname)
			end
		end)
		timer.Simple(0.3, function()
			if IsValid(ent) then
				ent:SetKeyValue("Speed", tostring(lastspeed))
			end
		end)

		ent.TFADoorUntouchable = CurTime() + 5
	end,
})

WonderWeapons.AddQuantumBombEffect("ScavengerEffect", {
	Name = "Scavenger Explosion",
	//AnnouncerVox = "",
	Effect = EffectTypes.NONE,
	Remove = true,
	Weight = 3,
	Safe = false,
	OnActivate = function(self, ent)	
		if math.random(0, 3) == 1 then
			self.ExplosionSound = "TFA_BO3_SCAVENGER.ExplodePaP"
			self.ExplosionEffect = "bo3_scavenger_explosion_2"
		else
			self.ExplosionSound = "TFA_BO3_SCAVENGER.Explode"
			self.ExplosionEffect = "bo3_scavenger_explosion"
		end

		self.ExplosionHitsOwner = true

		self.Range = 250
		self.Damage = 11500

		self:ScreenShake()

		self:Explode()
	end,
})

WonderWeapons.AddQuantumBombEffect("WunderwaffeEffect", {
	Name = "Wunderwaffe Effect",
	//AnnouncerVox = "",
	Effect = EffectTypes.NONE,
	Remove = true,
	Weight = 2,
	Safe = false,
	OnActivate = function(self, ent)	
		local waff = ents.Create("bo3_ww_wunderwaffe")
		waff:SetModel("models/dav0r/hoverball.mdl")
		waff:SetPos(self:GetPos() + Vector(0,0,24))
		waff:SetAngles(Angle(90,0,0))
		waff:SetOwner(IsValid(self:GetOwner()) and self:GetOwner() or self)

		waff:Spawn()

		local ang = Angle(90,0,0)
		local dir = ang:Forward() 
		dir:Mul(500)

		waff:SetVelocity(dir)
		local phys = waff:GetPhysicsObject()
		if IsValid(phys) then
			phys:SetVelocity(dir)
		end

		waff:SetOwner(self:GetOwner())
		waff.Inflictor = IsValid(self.Inflictor) and self.Inflictor or self
	end,
})

WonderWeapons.AddQuantumBombEffect("WavegunEffect", {
	Name = "Wavegun Effect",
	//AnnouncerVox = "",
	Effect = EffectTypes.WAVEGUN,
	Remove = true,
	Weight = 2,
	Safe = false,
	OnActivate = function(self, ent)	
		if not IsValid(self.Inflictor) then
			self.Inflictor = self
		end

		self:EmitSound("TFA_BO3_ZAPGUN.Flux")

		for k, v in pairs(ents.FindInSphere(self:GetPos(), 250)) do
			if ( v:IsNPC() or v:IsNextBot() ) and ShouldDamage(v, self:GetOwner(), self) and not HasStatus(v, "BO3_Wavegun_Cook") then
				GiveStatus(v, "BO3_Wavegun_Cook", math.Rand(2.8,3.4), self:GetOwner(), self.Inflictor)
			end
		end
	end,
})

WonderWeapons.AddQuantumBombEffect("ShrinkrayEffect", {
	Name = "31-79 JGb215 Effect",
	//AnnouncerVox = "",
	Effect = EffectTypes.GOLDEN,
	Remove = true,
	Weight = 2,
	Safe = false,
	OnActivate = function(self, ent)	
		self:EmitSound("TFA_BO3_JGB.Flux")

		ParticleEffect("bo3_jgb_impact", self:GetPos(), angle_zero)

		for k, v in pairs(ents.FindInSphere(self:GetPos(), 250)) do
			if ( v:IsNPC() or v:IsNextBot() ) and ShouldDamage(v, self:GetOwner(), self) and not HasStatus(v, "BO3_Shrinkray_Shrink") then
				GiveStatus(v, "BO3_Shrinkray_Shrink", 5, self:GetOwner())
			end
		end
	end,
})

WonderWeapons.AddQuantumBombEffect("Explosion", {
	Name = "Explosion",
	//AnnouncerVox = "",
	Effect = EffectTypes.NEUTRAL,
	Remove = true,
	Weight = 5,
	Safe = false,
	OnActivate = function(self, ent)	
		self.ExplosionEffectAngleCorrection = Angle(-90,0,0)
		self.ExplosionSound = "TFA_BO3_QED.NukeFlux"
		self.ExplosionEffect = "bo3_panzer_explosion"

		self.ExplosionHitsOwner = true

		self.Range = 200
		self.Damage = 2500

		self:ScreenShake()

		self:Explode()
	end,
})

WonderWeapons.AddQuantumBombEffect("SpawnEnemies", {
	Name = "Spawn Enemies",
	//AnnouncerVox = "",
	Effect = EffectTypes.NEGATIVE,
	Remove = true,
	Weight = 2,
	Safe = false,
	OnActivate = function(self, ent)
		local function UndoAdd(ent, ply, qtype)
			if IsValid(ent) and IsValid(ply) and ply:IsPlayer() then
				local names = {
					[0] = "Q.E.D. Enemy",
					[1] = "Q.E.D. Zombie",
					[2] = "Q.E.D. Combine",
					[3] = "Q.E.D. Antlions",
				}

				cleanup.Add(ply, "NPC", ent)

				undo.Create(names[qtype] or names[0])
					undo.AddEntity(ent)
					undo.SetPlayer(ply)
				undo.Finish()
			end
		end

		local radv = 128
		local pos = self:GetPos()
		local ply = self:GetOwner()
		local enttype = math.random(3)

		local tr = {}
		tr.start = pos
		tr.filter = self

		local models = {
			[1] = "models/combine_soldier.mdl",
			[2] = "models/combine_soldier.mdl",
			[3] = "models/combine_super_soldier.mdl"
		}

		local nades = {
			[1] = 5,
			[2] = 0,
			[3] = 10
		}

		local weapon = {
			[1] = "weapon_smg1",
			[2] = "weapon_shotgun",
			[3] = "weapon_ar2"
		}

		local i = 1
		while i <= 9 do
			local chance = math.random(3)
			local offset = VectorRand() * Vector(radv, radv, 0)

			tr.endpos = pos + offset

			local traceres = util.TraceLine(tr)
			local entpos = pos + traceres.Normal * math.Clamp(traceres.Fraction, 0, 1) * offset:Length()

			if enttype == 3 then
				local acid = math.random(5) == 1
				local ants = {
					[1] = "npc_antlion",
					[2] = "npc_antlion",
					[3] = "npc_antlionworker"
				}

				local ent = ents.Create(i == 1 and "npc_antlionguard" or ants[chance])
				ent:SetPos(entpos)
				if acid and i == 1 then
					ent:SetKeyValue("cavernbreed", "1")
					ent:SetKeyValue("incavern", "1")
				end

				ent:Spawn()

				UndoAdd(ent, ply, enttype)
			elseif enttype == 2 then
				local ent = ents.Create("npc_combine_s")
				ent:SetPos(entpos)
				ent:SetModel(models[chance])
				ent:SetKeyValue( "SquadName", "overwatch" )
				ent:SetKeyValue( "Numgrenades", nades[chance] )

				if chance == 2 then
					ent:SetKeyValue( "skin", 1 )
				end

				ent:Spawn()
				ent:Give(weapon[chance])

				UndoAdd(ent, ply, enttype)
			elseif enttype == 1 then
				local zombies = {
					[1] = "npc_zombie",
					[2] = "npc_fastzombie",
					[3] = "npc_poisonzombie"
				}

				local ent = ents.Create(zombies[chance])
				ent:SetPos(entpos)
				ent:Spawn()

				UndoAdd(ent, ply, enttype)
			end
			i = i + 1
		end
	end,
})
