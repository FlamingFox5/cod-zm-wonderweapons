local SinglePlayer = game.SinglePlayer()

local CurTime = CurTime
local IsValid = IsValid

local bit_AND = bit.band

local util_TraceLine = util.TraceLine
local util_PointContents = util.PointContents
local util_ScreenShake = util.ScreenShake

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

local comedyday = os.date("%d-%m") == "01-04"

// Explosions & Nades

nzQuantumBomb:AddEffect("Astro_Pop", {
	Name = "Astronaut Pop",
	Effect = EffectTypes.NONE,
	Remove = true,
	Weight = 35,
	Special = false,
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

			local vecSpot = BodyTarget(ent, vecSrc, true)
			local dir = ( vecSpot - vecSrc ):GetNormalized()

			tr.endpos = vecSpot

			local trace = util_TraceLine(tr)

			if ent:IsPlayer() then
				ent:ViewPunch( Angle( -25, math.random(-10, 10), 0 ) )
				ent:SetGroundEntity(nil)
				ent:SetVelocity( ( ( ent:GetPos() - self:GetPos() ):GetNormalized() * 200 ) + ent:GetUp() * 200 )
			else
				local p = ent:GetParent()
				if not ent:GetNoDraw() and not IsValid(p) and ent:GetMoveType() ~= MOVETYPE_NONE then
					ent:SetVelocity( ( ( ent:GetPos() - self:GetPos() ):GetNormalized() * 500 ) + ent:GetUp() * 120 )
				end

				damage:SetDamage( ent:Health() + 666 )
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

nzQuantumBomb:AddEffect("Grenade", {
	Name = "Spawn Grenade",
	Effect = EffectTypes.NEUTRAL,
	Remove = true,
	Weight = 10,
	Special = false,
	Safe = false,
	AprilFools = true,
	AprilFoolsWeight = 5,
	OnActivate = function(self)
		local frag = nzMapping.Settings.grenade or ""
		local wepdata = weapons.Get( tostring( frag ) )

		if wepdata and wepdata.IsTFAWeapon and ( wepdata.ProjectileEntity or wepdata.Primary.Projectile or wepdata.Primary.Round ) then
			local max = math.random(2)
			for i=1, max do
				local grenade = ents.Create( wepdata.ProjectileEntity or wepdata.Primary.Projectile or wepdata.Primary.Round )
				grenade:SetModel( wepdata.Primary.ProjectileModel or wepdata.ProjectileModel or "models/weapons/tfa_bo3/grenade/grenade_prop.mdl" )
				grenade:SetPos(self:GetPos() + Vector(0,0,24))
				grenade:SetAngles(self:GetAngles())
				grenade:SetOwner(IsValid(self:GetOwner()) and self:GetOwner() or self)

				grenade.Damage = 500
				grenade.mydamage = 500
				grenade.Delay = max == 2 and 2.1 or 1.2

				grenade:Spawn()

				local phys = grenade:GetPhysicsObject()
				if IsValid(phys) then
					phys:SetVelocity(Vector(0,0,250)+VectorRand(-100,100))
					if wepdata.ThrowSpin then
						phys:AddAngleVelocity(Vector(math.random(-2000,-500),math.random(-500,-2000),math.random(-500,-2000)))
					end
				end

				grenade:SetOwner(IsValid(self:GetOwner()) and self:GetOwner() or self)
				grenade.Inflictor = IsValid(self.Inflictor) and self.Inflictor or self
			end
		else
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
		end
	end,
})

nzQuantumBomb:AddEffect("Spidernade", {
	Name = "Spawn Widows Wine Semtex",
	Effect = EffectTypes.NEUTRAL,
	Remove = true,
	Weight = 10,
	Special = false,
	Safe = false,
	AprilFools = true,
	AprilFoolsWeight = 5,
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

nzQuantumBomb:AddEffect("Nestingdolls", {
	Name = "Matryoshka Doll",
	Effect = EffectTypes.NEUTRAL,
	Remove = true,
	Weight = 5,
	Special = false,
	Safe = false,
	AprilFools = true,
	AprilFoolsWeight = 2,
	OnActivate = function(self)
		local doll = ents.Create("nz_bo3_tac_matryoshka")
		doll:SetModel("models/weapons/tfa_bo3/matryoshka/matryoshka_prop.mdl")
		doll:SetPos(self:GetPos() + Vector(0,0,6))
		doll:SetAngles(angle_zero)
		doll:SetOwner(IsValid(self:GetOwner()) and self:GetOwner() or self)

		doll.Damage = 100000
		doll.mydamage = 100000
		doll:SetCharacter(math.random(4))

		doll:Spawn()

		local phys = doll:GetPhysicsObject()
		if IsValid(phys) then
			phys:SetVelocity(Vector(0,0,250) + VectorRand(-50,50))
		end

		doll:SetOwner(IsValid(self:GetOwner()) and self:GetOwner() or self)
		doll.Inflictor = IsValid(self.Inflictor) and self.Inflictor or self
	end,
})

nzQuantumBomb:AddEffect("BlackholeBomb", {
	Name = "Gersh Device",
	Effect = EffectTypes.POSITIVE,
	Remove = true,
	Weight = 4,
	Special = false,
	Safe = false,
	OnActivate = function(self)
		local bhbomb = ents.Create("nz_bo3_tac_gersch")
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

nzQuantumBomb:AddEffect("Explosion", {
	Name = "Explosion",
	Effect = EffectTypes.NONE,
	Remove = true,
	Weight = 6,
	Special = false,
	Safe = false,
	AprilFools = true,
	AprilFoolsWeight = 15,
	OnActivate = function(self)	
		self.ExplosionSound1 = "TFA_BO3_QED.NukeFlux"
		self.ExplosionSound2 = "TFA_BO3_GRENADE.Dist"
		self.ExplosionSound3 = "TFA_BO3_GRENADE.Flux"

		self.ExplosionEffectAngleCorrection = Angle(-90,0,0)
		self.ExplosionEffect = "bo3_panzer_explosion"

		self.ExplosionHitsOwner = tobool( comedyday )
		if tobool( comedyday ) then
			self.ExplosionOwnerDamage = 200
		end

		self.Range = 250
		self.Damage = 11500

		self:ScreenShake()

		self:Explode()
	end,
})

// Power-Ups

nzQuantumBomb:AddEffect("Drop_MaxAmmo", {
	Name = "Max Ammo Power-Up",
	Effect = EffectTypes.POSITIVE,
	Remove = true,
	Weight = 0.4,
	Special = false,
	Safe = true,
	OnActivate = function(self)	
		nzPowerUps:SpawnPowerUp(self:GetPos(), "maxammo")
	end,
})

nzQuantumBomb:AddEffect("Drop_DoublePoints", {
	Name = "Double Points Power-Up",
	Effect = EffectTypes.POSITIVE,
	Remove = true,
	Weight = 0.6,
	Special = false,
	Safe = true,
	OnActivate = function(self)	
		nzPowerUps:SpawnPowerUp(self:GetPos(), "dp")
	end,
})

nzQuantumBomb:AddEffect("Drop_InstaKill", {
	Name = "Instakill Power-Up",
	Effect = EffectTypes.POSITIVE,
	Remove = true,
	Weight = 0.4,
	Special = false,
	Safe = true,
	OnActivate = function(self)	
		nzPowerUps:SpawnPowerUp(self:GetPos(), "insta")
	end,
})

nzQuantumBomb:AddEffect("Drop_Kaboom", {
	Name = "Nuke Power-Up",
	Effect = EffectTypes.POSITIVE,
	Remove = true,
	Weight = 0.5,
	Special = false,
	Safe = true,
	OnActivate = function(self)	
		nzPowerUps:SpawnPowerUp(self:GetPos(), "nuke")
	end,
})

nzQuantumBomb:AddEffect("Drop_Carpenter", {
	Name = "Carpenter Power-Up",
	Effect = EffectTypes.POSITIVE,
	Remove = true,
	Weight = 0.8,
	Special = false,
	Safe = true,
	AprilFools = true,
	AprilFoolsWeight = 0.4,
	OnActivate = function(self)	
		nzPowerUps:SpawnPowerUp(self:GetPos(), "carpenter")
	end,
})

nzQuantumBomb:AddEffect("Drop_Firesale", {
	Name = "Firesale Power-Up",
	Effect = EffectTypes.POSITIVE,
	Remove = true,
	Weight = 0.6,
	Special = false,
	Safe = true,
	OnActivate = function(self)	
		nzPowerUps:SpawnPowerUp(self:GetPos(), "firesale")
	end,
})

nzQuantumBomb:AddEffect("Drop_DeathMachine", {
	Name = "Deathmachine Power-Up",
	Effect = EffectTypes.POSITIVE,
	Remove = true,
	Weight = 0.5,
	Special = false,
	Safe = true,
	OnActivate = function(self)	
		nzPowerUps:SpawnPowerUp(self:GetPos(), "deathmachine")
	end,
})

nzQuantumBomb:AddEffect("Drop_BonusPoints", {
	Name = "Zombie Cash Power-Up",
	Effect = EffectTypes.POSITIVE,
	Remove = true,
	Weight = 1,
	Special = false,
	Safe = true,
	OnActivate = function(self)	
		nzPowerUps:SpawnPowerUp(self:GetPos(), "bonuspoints")
	end,
})

nzQuantumBomb:AddEffect("Drop_BonFireSale", {
	Name = "Bonfire Sale Power-Up",
	Effect = EffectTypes.POSITIVE,
	Remove = true,
	Weight = 0.2,
	Special = false,
	Safe = true,
	OnActivate = function(self)	
		nzPowerUps:SpawnPowerUp(self:GetPos(), "bonfiresale")
	end,
})

nzQuantumBomb:AddEffect("Drop_Random", {
	Name = "Random Power-Up",
	//AnnouncerVox = "",
	Effect = EffectTypes.POSITIVE,
	Remove = true,
	Weight = 0.1,
	Special = false,
	Safe = true,
	OnActivate = function(self)	
		nzPowerUps:SpawnPowerUp(self:GetPos())
	end,
})

nzQuantumBomb:AddEffect("Drop_RandomWeapon", {
	Name = "Random Weapon Power-Up",
	//AnnouncerVox = "",
	Effect = EffectTypes.POSITIVE,
	Remove = true,
	Weight = 0.4,
	Special = false,
	Safe = true,
	OnActivate = function(self)	
		nzPowerUps:SpawnPowerUp(self:GetPos(), "weapondrop")
	end,
})

nzQuantumBomb:AddEffect("Drop_RandomPerk", {
	Name = "Random Perk Power-Up",
	//AnnouncerVox = "",
	Effect = EffectTypes.POSITIVE,
	Remove = true,
	Weight = 0.1,
	Special = false,
	Safe = true,
	OnActivate = function(self)	
		nzPowerUps:SpawnPowerUp(self:GetPos(), "bottle")
	end,
})

// Anti Power-Ups

nzQuantumBomb:AddEffect("Drop_AntiMaxAmmo", {
	Name = "Anti Max Ammo Power-Up",
	Effect = EffectTypes.NEGATIVE,
	Remove = true,
	Weight = 0.2,
	Special = false,
	Safe = false,
	AprilFools = true,
	AprilFoolsWeight = 1,
	OnActivate = function(self)	
		nzPowerUps:SpawnAntiPowerUp(self:GetPos(), "maxammo")
	end,
})

nzQuantumBomb:AddEffect("Drop_AntiInstaKill", {
	Name = "Anti Instakill Power-Up",
	Effect = EffectTypes.NEGATIVE,
	Remove = true,
	Weight = 0.3,
	Special = false,
	Safe = false,
	AprilFools = true,
	AprilFoolsWeight = 3,
	OnActivate = function(self)	
		nzPowerUps:SpawnAntiPowerUp(self:GetPos(), "insta")
	end,
})

nzQuantumBomb:AddEffect("Drop_AntiPerkBottle", {
	Name = "Anti Perk Power-Up",
	Effect = EffectTypes.NEGATIVE,
	Remove = true,
	Weight = 0.1,
	Special = false,
	Safe = false,
	AprilFools = true,
	AprilFoolsWeight = 1,
	OnActivate = function(self)	
		nzPowerUps:SpawnAntiPowerUp(self:GetPos(), "bottle")
	end,
})

nzQuantumBomb:AddEffect("Drop_AntiFiresale", {
	Name = "Anti Firesale Power-Up",
	Effect = EffectTypes.NEGATIVE,
	Remove = true,
	Weight = 0.4,
	Special = false,
	Safe = false,
	AprilFools = true,
	AprilFoolsWeight = 3,
	OnActivate = function(self)	
		nzPowerUps:SpawnAntiPowerUp(self:GetPos(), "firesale")
	end,
})

nzQuantumBomb:AddEffect("Drop_AntiBonusPoints", {
	Name = "Anti Zombie Cash Power-Up",
	Effect = EffectTypes.NEGATIVE,
	Remove = true,
	Weight = 0.5,
	Special = false,
	Safe = false,
	AprilFools = true,
	AprilFoolsWeight = 5,
	OnActivate = function(self)	
		nzPowerUps:SpawnAntiPowerUp(self:GetPos(), "bonuspoints")
	end,
})

nzQuantumBomb:AddEffect("Drop_AntiDoublePoints", {
	Name = "Anti Double Points Power-Up",
	Effect = EffectTypes.NEGATIVE,
	Remove = true,
	Weight = 0.2,
	Special = false,
	Safe = false,
	AprilFools = true,
	AprilFoolsWeight = 1,
	OnActivate = function(self)	
		nzPowerUps:SpawnAntiPowerUp(self:GetPos(), "dp")
	end,
})

nzQuantumBomb:AddEffect("Drop_AntiCarpenter", {
	Name = "Anti Carpenter Power-Up",
	Effect = EffectTypes.NEGATIVE,
	Remove = true,
	Weight = 0.2,
	Special = false,
	Safe = false,
	AprilFools = true,
	AprilFoolsWeight = 1,
	OnActivate = function(self)	
		nzPowerUps:SpawnAntiPowerUp(self:GetPos(), "carpenter")
	end,
})

nzQuantumBomb:AddEffect("Drop_AntiKaboom", {
	Name = "Anti Nuke Power-Up",
	Effect = EffectTypes.NEGATIVE,
	Remove = true,
	Weight = 0.1,
	Special = false,
	Safe = false,
	AprilFools = true,
	AprilFoolsWeight = 2,
	OnActivate = function(self)	
		nzPowerUps:SpawnAntiPowerUp(self:GetPos(), "nuke")
	end,
})

// Player Effects

nzQuantumBomb:AddEffect("ZombieTeleport", {
	Name = "Teleport Random Zombie to Player",
	Effect = EffectTypes.NEGATIVE,
	Remove = true,
	Weight = 1,
	Special = false,
	Safe = false,
	AprilFools = true,
	AprilFoolsWeight = 7,
	OnActivate = function(self)
		local ply = self:GetOwner()

		if not nzLevel or not IsValid(nzLevel.ZombieCache[1]) then return end

		for k, ent in nzLevel.GetZombieArray() do
			if not (IsValid(ent) and ent:IsValidZombie() and ent.IsMooZombie and IsValid(ent:GetTarget()) and ent:Alive() and !ent:GetSpecialAnimation() and !ent:GetBlockAttack()) then continue end

			local pos, success = self:FindSpotNearPlayer(ent, ply:GetPos(), 6, 82, 24, 24)
			if not success then
				break
			end

			ent:SetPos(pos)
			if ent.GetPhysicsObject and IsValid(ent:GetPhysicsObject()) then
				ent:GetPhysicsObject():SetPos(pos)
			end
			ent.loco:FaceTowards(ply:GetPos())

			if ent.TempBehaveThread then
				timer.Simple(engine.TickInterval(), function()
					ent:SetPos(pos)
					ent.loco:FaceTowards(ply:GetPos())

					sound.Play("weapons/tfa_bo3/qed/teleports.wav", pos, SNDLVL_TALKING, math.random(97,103), 1)
					ParticleEffect("bo3_qed_explode_1", pos, angle_zero)

					ent.HeavyAttack = true
					ent:TempBehaveThread(function(ent)
						ent:Attack()
					end)
				end)
			end

			break
		end
	end,
})

nzQuantumBomb:AddEffect("RandomTeleport", {
	Name = "Teleport Random Player",
	Effect = EffectTypes.NEGATIVE,
	Remove = true,
	Weight = 3.5,
	Special = false,
	Safe = false,
	AprilFools = true,
	AprilFoolsWeight = 15,
	OnActivate = function(self)
		local ply = self:GetOwner()
		local tab = player.GetAllPlayingAndAlive()
		if tab and not table.IsEmpty(tab) then
			ply = table.Random(tab)
		end

		local available = ents.FindByClass("nz_spawn_zombie_special")
		local pos = ply:GetPos()
		local spawns = {}

		if IsValid(available[1]) and !nzMapping.Settings.specialsuseplayers then
			for k,v in pairs(available) do
				if v.link == nil or nzDoors:IsLinkOpened( v.link ) then -- Only for rooms that are opened (using links)
					if v:IsSuitable() then -- And nothing is blocking it
						table.insert(spawns, v)
					end
				end
			end
			if !IsValid(spawns[1]) then -- Still no open linked ones?! Spawn at a random player spawnpoint
				local pspawns = ents.FindByClass("player_spawns")
				if !IsValid(pspawns[1]) then
					ply:ChatPrint("Couldnt Find Exit Location for QED Teleport")
				else
					pos = pspawns[math.random(#pspawns)]:GetPos()
				end
			else
				pos = spawns[math.random(#spawns)]:GetPos()
			end
		else -- There are no special spawnpoints - Use regular player spawns
			local pspawns = ents.FindByClass("player_spawns")
			if IsValid(pspawns[1]) then
				pos = pspawns[math.random(#pspawns)]:GetPos()
			end
		end

		self:SetTelePos(pos)

		if IsValid(ply) then
			ply:ViewPunch(Angle(-5, math.Rand(-10, 10), 0))
			ply:SetPos(self:GetTelePos())
			ply:SetLocalVelocity(vector_origin)
			timer.Simple(0, function()
				if ply:GetPos() ~= self:GetTelePos() then
					ply:SetPos(self:GetTelePos())
					ply:PrintMessage(2, "// Teleport Failed, Forcing //")
				end
			end)
			ply:EmitSound("TFA_BO3_QED.Teleport")
		end
	end,
})

nzQuantumBomb:AddEffect("RandomTeleportAll", {
	Name = "Teleport All Players",
	Effect = EffectTypes.NEGATIVE,
	Remove = true,
	Weight = 1.5,
	Special = false,
	Safe = false,
	AprilFools = true,
	AprilFoolsWeight = 5,
	OnActivate = function(self)
		local tab = player.GetAllPlayingAndAlive()
		if not tab or table.IsEmpty(tab) then
			tab = player.GetAll()
		end

		for _, ply in ipairs(tab) do
			local available = ents.FindByClass("nz_spawn_zombie_special")
			local pos = ply:GetPos()
			local spawns = {}

			if IsValid(available[1]) and !nzMapping.Settings.specialsuseplayers then
				for k,v in pairs(available) do
					if v.link == nil or nzDoors:IsLinkOpened( v.link ) then -- Only for rooms that are opened (using links)
						if v:IsSuitable() then -- And nothing is blocking it
							table.insert(spawns, v)
						end
					end
				end
				if !IsValid(spawns[1]) then -- Still no open linked ones?! Spawn at a random player spawnpoint
					local pspawns = ents.FindByClass("player_spawns")
					if !IsValid(pspawns[1]) then
						ply:ChatPrint("Couldnt Find Exit Location for QED Teleport")
					else
						pos = pspawns[math.random(#pspawns)]:GetPos()
					end
				else
					pos = spawns[math.random(#spawns)]:GetPos()
				end
			else -- There are no special spawnpoints - Use regular player spawns
				local pspawns = ents.FindByClass("player_spawns")
				if IsValid(pspawns[1]) then
					pos = pspawns[math.random(#pspawns)]:GetPos()
				end
			end

			if IsValid(ply) then
				ply:ViewPunch(Angle(-5, math.Rand(-10, 10), 0))
				ply:SetPos(pos)
				ply:SetLocalVelocity(vector_origin)
				ply:EmitSound("TFA_BO3_QED.Teleport")
				ParticleEffect("bo3_qed_explode_1", ply:GetPos(), angle_zero)
			end
		end
	end,
})

nzQuantumBomb:AddEffect("UpgradeWeapon", {
	Name = "Upgrade all Player's Held Weapon",
	Effect = EffectTypes.POSITIVE,
	Remove = true,
	Weight = 0.1,
	Special = false,
	Safe = true,
	OnActivate = function(self)
		local tab = player.GetAllPlaying()
		if not tab or table.IsEmpty(tab) then
			tab = player.GetAll()
		end

		for _, ply in ipairs(tab) do
			local wep = ply:GetActiveWeapon()
			if wep.NZSpecialCategory and !wep.OnPaP then
				for k, v in pairs(ply:GetWeapons()) do
					if v:GetNWInt("SwitchSlot", 0) > 0 and not v:HasNZModifier("pap") then
						wep = v
						break
					end
				end
			end

			if not IsValid(wep) then continue end
			local repap = wep.Ispackapunched

			ParticleEffect("bo3_qed_explode_1", ply:GetPos(), angle_zero)

			if nzWeps and nzWeps.Updated then
				if wep.NZPaPReplacement then
					local wep2 = ply:Give(wep.NZPaPReplacement)
					wep2:ApplyNZModifier("pap")
					ply:SelectWeapon(wep2:GetClass())
					ply:StripWeapon(wep:GetClass())
				elseif wep.OnPaP then
					if wep:HasNZModifier("pap") then
						wep:ApplyNZModifier("repap")
					else
						wep:ApplyNZModifier("pap")
					end

					wep:ResetFirstDeploy()
					wep:CallOnClient("ResetFirstDeploy", "")
					wep:Deploy()
					wep:CallOnClient("Deploy", "")
				end
			else
				if wep.NZPaPReplacement then
					ply:StripWeapon(wep:GetClass())
					local wep2 = ply:Give(wep.NZPaPReplacement)
					ply:SelectWeapon(wep2)
					timer.Simple(engine.TickInterval(), function()
						if not IsValid(ply) or not IsValid(wep2) then return end

						wep2:ApplyNZModifier("pap")
					end)
				elseif wep.OnPaP then
					ply:StripWeapon(wep:GetClass())
					local wep2 = ply:Give(wep:GetClass())
					ply:SelectWeapon(wep2)
					timer.Simple(engine.TickInterval(), function()
						if not IsValid(ply) or not IsValid(wep2) then return end

						wep2:ApplyNZModifier("pap")
					end)
				end
			end
		end

		net.Start("TFA.BO3.QED_SND")
		net.WriteString("WeaponGive")
		net.Broadcast()
	end,
})

nzQuantumBomb:AddEffect("DowngradeWeapon", {
	Name = "Downgrade Random Player's Weapon",
	Effect = EffectTypes.NEGATIVE,
	Remove = true,
	Weight = 0.1,
	Special = false,
	Safe = false,
	AprilFools = true,
	AprilFoolsWeight = 1,
	OnActivate = function(self)
		local ply = self:GetOwner()
		local tab = player.GetAllPlayingAndAlive()
		for k, v in RandomPairs(tab) do
			if not IsValid(v) then continue end

			local gun = v:GetActiveWeapon()
			if IsValid(gun) and gun:HasNZModifier("pap") then
				ply = v
				break
			end
		end

		local wep = ply:GetActiveWeapon()
		if not wep:HasNZModifier("pap") then return end

		ParticleEffect("bo3_qed_explode_1", ply:GetPos(), angle_zero)

		timer.Simple(0, function()
			if not IsValid(ply) or not IsValid(wep) then return end
			ply:StripWeapon(wep:GetClass())
			ply:Give(wep:GetClass())
		end)

		nzSounds:PlayEnt("Laugh", ply)
	end,
})

nzQuantumBomb:AddEffect("DownPlayer", {
	Name = "Down Random Player",
	Effect = EffectTypes.NEGATIVE,
	Remove = true,
	Weight = 0.1,
	Special = false,
	Safe = false,
	AprilFools = true,
	AprilFoolsWeight = 0.1,
	OnActivate = function(self)
		local ply = self:GetOwner()
		local tab = player.GetAllPlayingAndAlive()
		if tab and not table.IsEmpty(tab) then
			ply = table.Random(tab)
		end

		ply:DownPlayer()
		ParticleEffect("bo3_qed_explode_1", ply:GetPos(), angle_zero)
		nzSounds:PlayEnt("Laugh", ply)
	end,
})

nzQuantumBomb:AddEffect("TakeWeapon", {
	Name = "Take Weapon",
	Effect = EffectTypes.NEGATIVE,
	Remove = true,
	Weight = 0.1,
	Special = false,
	Safe = false,
	AprilFools = true,
	AprilFoolsWeight = 0.1,
	OnActivate = function(self)
		local ply = self:GetOwner()
		local wep = ply:GetActiveWeapon()
		if IsValid(wep) then
			ply:Give("tfa_bo3_wepsteal")
			ply:SelectWeapon("tfa_bo3_wepsteal")

			nzSounds:PlayEnt("Bye", ply)
		end
	end,
})

// Starguns

nzQuantumBomb:AddEffect("Spingun_Launcher", {
	Name = "Summon MAX-GL",
	Effect = EffectTypes.NEGATIVE,
	Remove = true,
	Weight = 1,
	Special = false,
	Safe = false,
	AprilFools = true,
	AprilFoolsWeight = 1,
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

nzQuantumBomb:AddEffect("Spingun_Rifle", {
	Name = "Summon KN-44",
	Effect = EffectTypes.NEGATIVE,
	Remove = true,
	Weight = 2,
	Special = false,
	Safe = false,
	AprilFools = true,
	AprilFoolsWeight = 4,
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

nzQuantumBomb:AddEffect("Spingun_Shotgun", {
	Name = "Summon Haymaker-12",
	Effect = EffectTypes.NEGATIVE,
	Remove = true,
	Weight = 2,
	Special = false,
	Safe = false,
	AprilFools = true,
	AprilFoolsWeight = 4,
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

nzQuantumBomb:AddEffect("Spingun_Raygun", {
	Name = "Summon Raygun",
	Effect = EffectTypes.NEGATIVE,
	Remove = true,
	Weight = 1,
	Special = false,
	Safe = false,
	AprilFools = true,
	AprilFoolsWeight = 1,
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

// Wonder Weapon Effects

nzQuantumBomb:AddEffect("Scavenger_Effect", {
	Name = "Scavenger Explosion",
	Effect = EffectTypes.NONE,
	Remove = true,
	Weight = 2,
	Special = false,
	Safe = false,
	OnActivate = function(self)	
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

nzQuantumBomb:AddEffect("Wunderwaffe_Effect", {
	Name = "Wunderwaffe Effect",
	Effect = EffectTypes.NONE,
	Remove = true,
	Weight = 1,
	Special = false,
	Safe = false,
	OnActivate = function(self)	
		local waff = ents.Create("bo3_ww_wunderwaffe")
		waff:SetModel("models/dav0r/hoverball.mdl")
		waff:SetPos(self:GetPos() + Vector(0,0,24))
		waff:SetAngles(Angle(90,0,0))
		waff:SetOwner(IsValid(self:GetOwner()) and self:GetOwner() or self)
		waff.ZapRange = 600
		waff.Decay = 45

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

nzQuantumBomb:AddEffect("Wavegun_Effect", {
	Name = "Wavegun Effect",
	Effect = EffectTypes.WAVEGUN,
	Remove = true,
	Weight = 1,
	Special = false,
	Safe = false,
	OnActivate = function(self)	
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

nzQuantumBomb:AddEffect("Shrinkray_Effect", {
	Name = "31-79 JGb215 Effect",
	Effect = EffectTypes.GOLDEN,
	Remove = true,
	Weight = 2,
	Special = false,
	Safe = false,
	OnActivate = function(self)	
		self:EmitSound("TFA_BO3_JGB.Flux")

		ParticleEffect("bo3_jgb_impact", self:GetPos(), angle_zero)

		for k, v in pairs(ents.FindInSphere(self:GetPos(), 250)) do
			if ( v:IsNPC() or v:IsNextBot() ) and ShouldDamage(v, self:GetOwner(), self) and not HasStatus(v, "BO3_Shrinkray_Shrink") then
				GiveStatus(v, "BO3_Shrinkray_Shrink", 5, self:GetOwner())
			end
		end
	end,
})

nzQuantumBomb:AddEffect("Monkeybomb_Effect", {
	Name = "Monkeybomb Effect",
	Effect = EffectTypes.GOLDEN,
	Remove = false,
	Weight = 2,
	Special = false,
	Safe = false,
	OnActivate = function(self)
		self.BlockEffects = true
		SafeRemoveEntityDelayed(self, 8)

		self:EmitSound("TFA_BO3_QED.Flare")

		ParticleEffectAttach("bo3_qed_flare", PATTACH_ABSORIGIN_FOLLOW, self, 1)

		self:SetTargetPriority(TARGET_PRIORITY_SPECIAL)
		UpdateAllZombieTargets(self)

		self:CallOnRemove("nz.QED.Flare", function(self)
			self:EmitSound("TFA_BO3_GENERIC.Lightning.Close")
			self:EmitSound("TFA_BO3_GENERIC.Lightning.Flash")
			self:EmitSound("TFA_BO3_GENERIC.Lightning.Snap")
			ParticleEffect("driese_tp_arrival_phase2", self:WorldSpaceCenter(), angle_zero)

			if SERVER then
				local damage = DamageInfo()
				damage:SetAttacker(IsValid(self:GetOwner()) and self:GetOwner() or self)
				damage:SetInflictor(IsValid(self.Inflictor) and self.Inflictor or self)
				damage:SetDamageForce(Vector(0,0,1000))
				damage:SetDamageType(DMG_SHOCK)
				damage:SetReportedPosition(self:GetPos())

				for k, v in pairs(ents.FindInSphere(self:GetPos(), 250)) do
					if v:IsValidZombie() and TFA.WonderWeapon.ShouldDamage(v, self:GetOwner(), self) then
						damage:SetDamagePosition(TFA.WonderWeapon.BodyTarget(v, self:GetPos(), true))
						damage:SetDamage(v:Health() + 666)

						v:EmitSound("TFA_BO3_WAFFE.Sizzle")
						v:EmitSound("TFA_BO3_WAFFE.Zap")

						if v.NZBossType or v.IsMooBossZombie or v.IsMooMiniBoss then
							damage:SetDamage(math.max(6000, v:GetMaxHealth() / 4))
						end

						TFA.WonderWeapon.DoDeathEffect(v, "BO3_Wunderwaffe", math.Rand(4, 6))

						v:TakeDamageInfo(damage)

						self:SendHitMarker(v, damage)
					end
				end
			end

			util.ScreenShake(self:GetPos(), 20, 255, 1.5, 500)
		end)
	end,
})

// Misc / Special Effects

nzQuantumBomb:AddEffect("RecallExcavator", {
	Name = "Recall Excavator",
	Effect = EffectTypes.POSITIVE,
	Remove = true,
	Weight = 0,
	Special = true,
	Safe = true,
	OnActivate = function(self, prop)	
		if prop:GetName() == 'piblade' then
			local pi = ents.FindByName("picons")[1]
			pi:Fire("Press")
		end

		if prop:GetName() == 'omicronblade' then
			local omicron = ents.FindByName("omicroncons")[1]
			omicron:Fire("Press")
		end

		if prop:GetName() == 'epsilonblade' then
			local epsilon = ents.FindByName("epsiloncons")[1]
			epsilon:Fire("Press")
		end
	end,
})

nzQuantumBomb:AddEffect("OpenRandomDoor", {
	Name = "Open a Random Door",
	Effect = EffectTypes.NEUTRAL,
	Remove = true,
	Weight = 0.7,
	Safe = false,
	OnActivate = function(self)	
		local tab = ents.FindInSphere(self:GetPos(), 2048)
		for k, v in RandomPairs(tab) do
			local data = v:GetDoorData()
			if data then
				local datalink = data.link
				if datalink then
					nzDoors:OpenLinkedDoors(datalink, ply)
					ParticleEffect("bo3_qed_explode_1", v:GetPos(), angle_zero)
					//print("saved ya "..string.Comma(data.price).." points")
				end
				break
			end
		end
	end,
})

nzQuantumBomb:AddEffect("CloseRandomBox", {
	Name = "Close the Mystery Box",
	Effect = EffectTypes.NEGATIVE,
	Remove = true,
	Weight = 0,
	Special = true,
	Safe = false,
	OnActivate = function(self, box)	
		if not IsValid(box) then return end

		box:Close()

		for _, ent in pairs(ents.FindByClass("random_box_windup")) do
			if IsValid(ent) and ent.Box and (ent.Box == box) then
				if ent.GetWinding and ent:GetWinding() then
					print("If the weapon windup errors, it can be safely ingnored")
				end
				ent:Remove()
				break
			end
		end
	end,
})

nzQuantumBomb:AddEffect("RevivePlayers", {
	Name = "Revive Downed Players",
	Effect = EffectTypes.POSITIVE,
	Remove = true,
	Weight = 0,
	Special = true,
	Safe = true,
	OnActivate = function(self)	
		local tab = player.GetAllPlaying()
		if not tab or table.IsEmpty(tab) then
			tab = player.GetAll()
		end

		for _, ply in ipairs(tab) do
			if !ply:GetNotDowned() then
				ply:RevivePlayer()
			end
		end
	end,
})

nzQuantumBomb:AddEffect("PerkMachine", {
	Name = "Give all Player's a Perk",
	Effect = EffectTypes.POSITIVE,
	Remove = true,
	Weight = 0,
	Special = true,
	Safe = true,
	OnActivate = function(self, machine)	
		local tab = player.GetAllPlaying()
		if not tab or table.IsEmpty(tab) then
			tab = player.GetAll()
		end

		local id = machine:GetPerkID()
		if not id then return end

		local data = nzPerks:Get(id)
		if not data then return end

		if id == "pap" then
			nzQuantumBomb:ActivateSilent("UpgradeWeapon", self)
		elseif !data.specialmachine then
			for _, ply in ipairs(tab) do
				if not ply:HasPerk(id) then
					ply:GivePerk(id)
				end
			end
		end
	end,
})

nzQuantumBomb:AddEffect("Drop_GerschPowerup", {
	Name = "Gersh Device Weapon Drop",
	Effect = EffectTypes.POSITIVE,
	Remove = true,
	Weight = 0,
	Special = true,
	Safe = false,
	OnActivate = function(self)		
		local weap = ents.Create("nz_bo3_drop_weapon")
		weap:SetGun("tfa_bo3_gersch")
		weap:SetPos(self:GetPos() + Vector(0,0,48))
		weap:Spawn()
	end,
})

nzQuantumBomb:AddEffect("Drop_QEDPowerup", {
	Name = "Q.E.D. Weapon Drop",
	Effect = EffectTypes.POSITIVE,
	Remove = true,
	Weight = 0.5,
	Special = false,
	Safe = false,
	OnActivate = function(self)		
		local weap = ents.Create("nz_bo3_drop_weapon")
		weap:SetGun("tfa_bo3_qed")
		weap:SetPos(self:GetPos() + Vector(0,0,48))
		weap:Spawn()
	end,
})

nzQuantumBomb:AddEffect("SpawnZombies", {
	Name = "Spawn a Horde of Zombies",
	Effect = EffectTypes.NEGATIVE,
	Remove = true,
	Weight = 0.2,
	Special = false,
	Safe = false,
	AprilFools = true,
	AprilFoolsWeight = 2.5,
	OnActivate = function(self)
		local function FindNearestSpawner(pos)
			if not pos or not isvector( pos ) then
				pos = Entity(1):GetPos()
			end

			local nearbyents = {}
			for k, v in pairs(ents.FindByClass("nz_spawn_zombie_normal")) do
				if v.GetSpawner and v:GetSpawner() and v:IsSuitable() then
					table.insert(nearbyents, v)
				end
			end

			table.sort(nearbyents, function(a, b) return IsValid(a) and IsValid(b) and a:GetPos():DistToSqr(pos) < b:GetPos():DistToSqr(pos) end)
			return nearbyents[1]
		end

		local numspawn = nzMapping.Settings.startingspawns
		if not numspawn or numspawn <= 0 then
			numspawn = 24
		end

		for i=1, numspawn do
			local zspawn = FindNearestSpawner(self:GetPos())

			if nzRound:InState(ROUND_PROG) and IsValid(zspawn) then
				if zspawn:IsSuitable() then
					local class = nzMisc.WeightedRandom(zspawn:GetZombieData(), "chance")
					local zombie = ents.Create(class)
					zombie:SetPos(zspawn:GetPos())
					zombie:SetAngles(zspawn:GetAngles())
					zombie:Spawn()

					zombie:SetSpawner(zspawn:GetSpawner())
					zombie:Activate()

					hook.Call("OnZombieSpawned", nzEnemies, zombie, zspawn)

					if nzRound:IsSpecial() then
						local data = nzRound:GetSpecialRoundData()
						if data and data.spawnfunc then
							data.spawnfunc(zombie)
						end
					end
				end

				//zspawn:SetNextSpawn(CurTime() + zspawn:GetSpawner():GetDelay() * 2)
			end
		end
	end,
})

nzQuantumBomb:AddEffect("SpawnBoss", {
	Name = "Spawn Boss Zombie",
	Effect = EffectTypes.NEGATIVE,
	Remove = true,
	Weight = 0.2,
	Special = false,
	Safe = false,
	AprilFools = true,
	AprilFoolsWeight = 1,
	OnActivate = function(self)	
		nzRound:SpawnBoss(nzMapping.Settings.bosstype)
	end,
})

nzQuantumBomb:AddEffect("SuperSprinters", {
	Name = "Zombies Become Super-Sprinters",
	Effect = EffectTypes.NEGATIVE,
	Remove = true,
	Weight = 0.5,
	Special = false,
	Safe = false,
	AprilFools = true,
	AprilFoolsWeight = 4,
	OnActivate = function(self)	
		local ply = self:GetOwner()
		if nzRound:IsSpecial() then return end

		if nzLevel then
			for k, v in nzLevel.GetZombieArray() do
				if not IsValid(v) then continue end
				if v:IsValidZombie() and !(v.NZBossType or v.IsMooBossZombie) and (!v.IsMooSpecial or v.IsMooSpecial and !v.MooSpecialZombie) and v:Alive() then
					v:SetRunSpeed(200)
					v:SpeedChanged()
					v:Retarget()
				end
			end
		else
			for k, v in ipairs(ents.GetAll()) do
				if not IsValid(v) then continue end
				if v:IsValidZombie() and !(v.NZBossType or v.IsMooBossZombie) and (!v.IsMooSpecial or v.IsMooSpecial and !v.MooSpecialZombie) and v:Alive() then
					v:SetRunSpeed(200)
					if v.SpeedChanged then
						v:SpeedChanged()
					end
					v:Retarget()
				end
			end
		end
	end,
})
