//-------------------------------------------------------------
// Status Effects
//-------------------------------------------------------------

local WonderWeapons = TFA.WonderWeapon

local nzombies = engine.ActiveGamemode() == "nzombies"
local SinglePlayer = game.SinglePlayer()
local sv_true_damage = GetConVar("sv_tfa_bo3ww_cod_damage")
local cl_show_dlight = GetConVar("cl_tfa_fx_wonderweapon_dlights")

WonderWeapons.AddStatusEffect("BO4_Alistair_Fireball", {
	ShouldCollide = false,

	BlockAttack = true,

	ZombieSlowWalk = true,

	Initialize = function( self, entity, duration, attacker, inflictor, damage )
		self:SetAttacker( attacker )
		self:SetInflictor( inflictor )
		self:SetDamage( damage or 275 )

		if CLIENT then return end

		self:ModifyMoveSpeed( 0.25, duration )

		entity:EmitSound("TFA_BO4_BLUNDER.Magma.Explode")
		entity:EmitSound("TFA_BO4_BLUNDER.Magma.Explode.Swt")
	end,

	Draw = function( self, entity, visibility )
		entity:AddDrawCallParticle( "burning_character", PATTACH_POINT_FOLLOW, self.ChestAttachment or 1, entity:Health() > 0, "BO4_Alistair_Fireball" )
	end,

	OnStatusEnd = function( self, entity )
		TFA.WonderWeapon.StopDrawParticle( entity, "BO4_Alistair_Fireball", false )

		if SERVER then
			self:InflictDamage( entity )
		end
	end,

	OnRemove = function( self, entity )
		TFA.WonderWeapon.StopDrawParticle( entity, "BO4_Alistair_Fireball", false )
	end,

	InflictDamage = function( self, entity )
		if CLIENT then return end

		local attacker = self:GetAttacker()
		local inflictor = self:GetInflictor()

		local damage = DamageInfo()
		damage:SetDamageType(nzombies and DMG_MISSILEDEFENSE or TFA.WonderWeapon.GetBurnDamage( entity ))
		damage:SetAttacker(IsValid(attacker) and attacker or entity)
		damage:SetInflictor(IsValid(inflictor) and inflictor or entity)
		damage:SetDamage((sv_true_damage and sv_true_damage:GetBool() or nzombies) and entity:Health() + 666 or self:GetDamage())
		damage:SetDamageForce(vector_up)
		damage:SetDamagePosition(TFA.WonderWeapon.BodyTarget(entity, entity:GetPos(), true))
		damage:SetReportedPosition(entity:GetPos())

		if nzombies and (entity.NZBossType or string.find(entity:GetClass(), "zombie_boss")) then
			damage:SetDamage(math.max(1200, entity:GetMaxHealth() / 12))
		end

		if entity:IsNPC() and entity:Alive() and damage:GetDamage() >= entity:Health() then
			entity:SetCondition(COND.NPC_UNFREEZE)
		end

		TFA.WonderWeapon.DoDeathEffect( entity, "BO4_Alistair_Fireball" )

		entity:TakeDamageInfo(damage)

		self:SendHitMarker( attacker, inflictor, entity, damage )
	end,
})

WonderWeapons.AddStatusEffect("BO4_Alistair_Shrink", {
	ShouldCollide = false,

	ShouldFreeze = true,

	BlockAttack = true,

	DoFirePanic = true,

	ModelScale = 0.1,
	ModelScaleDeltaTime = 1,

	CollisionGroupOverride = COLLISION_GROUP_IN_VEHICLE,

	Initialize = function( self, entity, duration, attacker, inflictor, damage )
		self:SetAttacker( attacker )
		self:SetInflictor( inflictor )
		self:SetDamage( damage or 1000 )

		self.ModelScaleDeltaTime = duration

		if CLIENT then return end

		entity:EmitSound("TFA_BO4_ALISTAIR.Charged.Shrink")
	end,

	Draw = function( self, entity, visibility )
		entity:AddDrawCallParticle( "bo4_alistairs_shrink_ent", PATTACH_POINT_FOLLOW, self.HeadAttachment or 1, entity:Health() > 0, "BO4_Alistair_Shrink" )
		entity:AddDrawCallParticle( "bo4_alistairs_shrink_ent_floor", PATTACH_ABSORIGIN_FOLLOW, 1, entity:OnGround(), "BO4_Alistair_Shrink_Ground" )
	end,

	CreateClientsideRagdoll = function( self, entity, ragdoll )
		TFA.WonderWeapon.SafeRemoveRagdoll( ragdoll )
	end,

	CreateEntityRagdoll = function( self, entity, ragdoll )
		TFA.WonderWeapon.SafeRemoveRagdoll( ragdoll )
	end,

	OnStatusEnd = function( self, entity )
		TFA.WonderWeapon.StopDrawParticle( entity, "BO4_Alistair_Shrink", false )
		TFA.WonderWeapon.StopDrawParticle( entity, "BO4_Alistair_Shrink_Ground", false )

		if SERVER then
			self:InflictDamage( entity )
		end
	end,

	OnRemove = function( self, entity )
		TFA.WonderWeapon.StopDrawParticle( entity, "BO4_Alistair_Shrink", false )
		TFA.WonderWeapon.StopDrawParticle( entity, "BO4_Alistair_Shrink_Ground", false )
	end,

	InflictDamage = function( self, entity )
		if CLIENT then return end

		ParticleEffect( "bo4_alistairs_shrink_kill", entity:GetPos(), angle_zero )

		if entity.GetBloodColor then
			local BloodColor = entity.GetBloodColor and entity:GetBloodColor()
			if BloodColor ~= DONT_BLEED and TFA.WonderWeapon.ParticleByBloodColor[ BloodColor ] then
				ParticleEffect(TFA.WonderWeapon.ParticleByBloodColor[ BloodColor ], entity:EyePos(), entity.GetAimVector and entity:GetAimVector():Angle() or entity:GetForward():Angle())
				util.Decal(TFA.WonderWeapon.DecalByBloodColor[BloodColor], entity:GetPos(), entity:GetPos() - vector_up*4)
			end
		else
			ParticleEffect( "blood_impact_red_01", ent:GetPos() + vector_up, ent:GetUp():Angle() )
			util.Decal( "Blood", ent:GetPos(), ent:GetPos() - vector_up*4 )
		end

		local attacker = self:GetAttacker()
		local inflictor = self:GetInflictor()

		local damage = DamageInfo()
		damage:SetDamageType( DMG_REMOVENORAGDOLL )
		damage:SetAttacker( IsValid(attacker) and attacker or entity )
		damage:SetInflictor( IsValid(inflictor) and inflictor or entity )
		damage:SetDamage( ( sv_true_damage and sv_true_damage:GetBool() or nzombies ) and entity:Health() + 666 or self:GetDamage() )
		damage:SetDamageForce( vector_up )
		damage:SetDamagePosition( TFA.WonderWeapon.BodyTarget(entity, entity:GetPos(), true) )
		damage:SetReportedPosition( entity:GetPos() )

		if nzombies and ( entity.NZBossType or string.find( entity:GetClass(), "zombie_boss" ) ) then
			damage:SetDamage( math.max( 1200, entity:GetMaxHealth() / 12 ) )
		end

		if entity:IsNPC() and entity:Alive() and damage:GetDamage() >= entity:Health() then
			entity:SetCondition( COND.NPC_UNFREEZE )
		end

		TFA.WonderWeapon.DoDeathEffect( entity, "Remove_Ragdoll" )

		entity:SetHealth( 1 )

		entity:TakeDamageInfo( damage )

		self:SendHitMarker( attacker, inflictor, entity, damage )

		SafeRemoveEntityDelayed( entity, engine.TickInterval() )
	end,
})

WonderWeapons.AddStatusEffect("BO4_Alistair_Tornado", {
	ShouldCollide = false,

	ShouldFreeze = true,

	BlockAttack = true,

	CollisionGroupOverride = COLLISION_GROUP_IN_VEHICLE,

	Initialize = function( self, entity, duration, attacker, inflictor )
		self:SetAttacker( attacker )
		self:SetInflictor( inflictor )

		if CLIENT then return end

		self.gibtime1 = 1 + math.Rand(-0.25,0.25)
		self.gibtime2 = 2 + math.Rand(-0.25,0.25)
		self.gibtime3 = 3 + math.Rand(-0.25,0.25)
		self.gibtime4 = 4 + math.Rand(-0.25,0.25)
	end,

	Think = function( self, entity )
		if CLIENT then return end

		if nzombies and IsValid( entity ) and entity.GibRandom and !entity.IsMooSpecial then
			if ( self:GetStartTime() + self.gibtime1 ) < CurTime() then
				self:GibArmL( entity )
			end
			if ( self:GetStartTime() + self.gibtime2 ) < CurTime() then
				self:GibArmR( entity )
			end
			if ( self:GetStartTime() + self.gibtime3 ) < CurTime() then
				self:GibLegL( entity )
			end
			if ( self:GetStartTime() + self.gibtime4 ) < CurTime() then
				self:GibLegR( entity )
			end
		end
	end,

	OnStatusEnd = function( self, entity )
		if SERVER then
			self:InflictDamage( entity )
		end
	end,

	OnRemove = function( self, entity )
	end,

	GibArmR = function( self, entity )
		if CLIENT then return end

		if not IsValid(entity) then return end
		if not entity.DeflateBones then return end

		if entity.RArmOff then return end
		entity.RArmOff = true

		if nzombies then
			local ply = self:GetAttacker()
			if IsValid( ply ) and ply:IsPlayer() then
				ply:GivePoints(10)
			end
		end

		local relbone = entity:LookupBone("j_elbow_ri")
		if relbone then
			entity:DeflateBones({
				"j_elbow_ri",
				"j_wrist_ri",
				"j_wristtwist_ri",
				"j_thumb_ri_1",
				"j_thumb_ri_2",
				"j_thumb_ri_3",
				"j_index_ri_1",
				"j_index_ri_2",
				"j_index_ri_3",
				"j_mid_ri_1",
				"j_mid_ri_2",
				"j_mid_ri_3",
				"j_ring_ri_1",
				"j_ring_ri_2",
				"j_ring_ri_3",
				"j_pinky_ri_1",
				"j_pinky_ri_2",
				"j_pinky_ri_3",
			})

			entity:EmitSound( "nz_moo/zombies/gibs/gib_0" .. math.random(3) .. ".mp3", 100 )
			if not entity.MarkedForDeath then
				ParticleEffectAttach( "ins_blood_dismember_limb", 4, entity, 6 )
			end
		end
	end,

	GibArmL = function( self, entity )
		if CLIENT then return end

		if not IsValid(entity) then return end
		if not entity.DeflateBones then return end

		if entity.LArmOff then return end
		entity.LArmOff = true

		if nzombies then
			local ply = self:GetAttacker()
			if IsValid( ply ) and ply:IsPlayer() then
				ply:GivePoints(10)
			end
		end

		local lelbone = entity:LookupBone("j_elbow_le")
		if lelbone then
			entity:DeflateBones({
				"j_elbow_le",
				"j_wrist_le",
				"j_wristtwist_le",
				"j_thumb_le_1",
				"j_thumb_le_2",
				"j_thumb_le_3",
				"j_index_le_1",
				"j_index_le_2",
				"j_index_le_3",
				"j_mid_le_1",
				"j_mid_le_2",
				"j_mid_le_3",
				"j_ring_le_1",
				"j_ring_le_2",
				"j_ring_le_3",
				"j_pinky_le_1",
				"j_pinky_le_2",
				"j_pinky_le_3",
			})

			entity:EmitSound( "nz_moo/zombies/gibs/gib_0" .. math.random(3) .. ".mp3", 100 )
			if not entity.MarkedForDeath then
				ParticleEffectAttach( "ins_blood_dismember_limb", 4, entity, 5 )
			end
		end
	end,

	GibLegR = function( self, entity )
		if CLIENT then return end

		if not IsValid(entity) then return end
		if not entity.DeflateBones then return end

		if entity.RlegOff then return end
		entity.RlegOff = true

		if nzombies then
			local ply = self:GetAttacker()
			if IsValid( ply ) and ply:IsPlayer() then
				ply:GivePoints(10)
			end
		end

		local relbone = entity:LookupBone("j_knee_ri")
		if relbone then
			entity:DeflateBones({
				"j_knee_ri",
				"j_knee_bulge_ri",
				"j_ankle_ri",
				"j_ball_ri",
			})

			entity:EmitSound( "nz_moo/zombies/gibs/gib_0" .. math.random(3) .. ".mp3", 100 )
			if not entity.MarkedForDeath then
				ParticleEffectAttach( "ins_blood_dismember_limb", 4, entity, 8 )
			end
		end
	end,

	GibLegL = function( self, entity )
		if CLIENT then return end

		if not IsValid(entity) then return end
		if not entity.DeflateBones then return end

		if entity.LlegOff then return end
		entity.LlegOff = true

		if nzombies then
			local ply = self:GetAttacker()
			if IsValid( ply ) and ply:IsPlayer() then
				ply:GivePoints(10)
			end
		end

		local relbone = entity:LookupBone("j_knee_le")
		if relbone then
			entity:DeflateBones({
				"j_knee_le",
				"j_knee_bulge_le",
				"j_ankle_le",
				"j_ball_le",
			})

			entity:EmitSound( "nz_moo/zombies/gibs/gib_0" .. math.random(3) .. ".mp3", 100 )
			if not entity.MarkedForDeath then
				ParticleEffectAttach( "ins_blood_dismember_limb", 4, entity, 7 )
			end
		end
	end,

	InflictDamage = function( self, entity )
		if CLIENT then return end

		if nzombies and entity.GibHead then 
			entity:GibHead()
		else
			entity:EmitSound("TFA_BO3_GENERIC.Gore")
		end

		if entity.GetBloodColor then
			local BloodColor = entity.GetBloodColor and entity:GetBloodColor()
			if BloodColor ~= DONT_BLEED and TFA.WonderWeapon.ParticleByBloodColor[ BloodColor ] then
				ParticleEffect(TFA.WonderWeapon.ParticleByBloodColor[ BloodColor ], entity:EyePos(), entity.GetAimVector and entity:GetAimVector():Angle() or entity:GetForward():Angle())
			end
		else
			ParticleEffect("blood_impact_red_01", entity:EyePos(), entity.GetAimVector and entity:GetAimVector():Angle() or entity:GetForward():Angle())
		end

		local attacker = self:GetAttacker()
		local inflictor = self:GetInflictor()

		local damage = DamageInfo()
		damage:SetDamageType(DMG_MISSILEDEFENSE)
		damage:SetAttacker(IsValid(attacker) and attacker or entity)
		damage:SetInflictor(IsValid(inflictor) and inflictor or entity)
		damage:SetDamage(entity:Health() + 666)
		damage:SetDamageForce(vector_up)
		damage:SetDamagePosition(TFA.WonderWeapon.BodyTarget(entity, entity:GetPos(), true))
		damage:SetReportedPosition(entity:GetPos())

		if nzombies and ( entity.NZBossType or string.find( entity:GetClass(), "zombie_boss" ) ) then
			damage:SetDamage(math.max(1000, entity:GetMaxHealth() / 10))
		end

		if entity:IsNPC() and entity:Alive() and damage:GetDamage() >= entity:Health() then
			entity:SetCondition(COND.NPC_UNFREEZE)
		end

		entity:TakeDamageInfo(damage)

		self:SendHitMarker( attacker, inflictor, entity, damage )
	end,
})

WonderWeapons.AddStatusEffect("BO4_Alistair_Toxic", {
	ShouldCollide = false,

	BlockAttack = true,

	BlockPlayerAttack = true,

	ZombieSlowWalk = true,

	Initialize = function( self, entity, duration, attacker, inflictor, damage )
		self:SetAttacker( attacker )
		self:SetInflictor( inflictor )
		self:SetDamage( damage or 250 )

		if CLIENT then return end

		self:ModifyMoveSpeed( 0.25, math.Clamp( duration / 4, 0.1, 0.5 ) )
	end,

	Draw = function( self, entity, visibility )
		entity:AddDrawCallParticle( "bo4_alistairs_toxic_zomb", PATTACH_POINT_FOLLOW, self.HeadAttachment or 1, entity:Health() > 0, "BO4_Alistair_Toxic" )
	end,

	OnStatusEnd = function( self, entity )
		TFA.WonderWeapon.StopDrawParticle( entity, "BO4_Alistair_Toxic", false )

		if SERVER then
			self:InflictDamage( entity )
		end
	end,

	OnRemove = function( self, entity )
		TFA.WonderWeapon.StopDrawParticle( entity, "BO4_Alistair_Toxic", false )
	end,

	Think = function( self, entity )
		if CLIENT then return end

		if IsValid( self:GetAttacker() ) and entity:IsNPC() then
			self:StupidNPC( entity )
		end
	end,

	FindFreeSpot = function( self, entity )
		local finalPos = entity:GetPos()

		if GM.PlayerSelectSpawn then
			local spawn = GM:PlayerSelectSpawn( ply, false )
			if ( IsValid( spawn ) ) then
				finalPos = spawn:GetPos()
			end
		end

		if navmesh.IsLoaded() then
			local tab = navmesh.Find( entity:GetPos(), 10000, 10000, 10000 )
			for _, nav in RandomPairs( tab ) do
				if IsValid( nav ) and not nav:IsUnderwater() then
					finalPos = nav:GetRandomPoint()
					break
				end
			end
		end

		local minBound, maxBound = entity:OBBMins(), entity:OBBMaxs()
		if not TFA.WonderWeapon.IsCollisionBoxClear( finalPos, entity, minBound, maxBound ) then
			local surroundingTiles = TFA.WonderWeapon.GetSurroundingTiles( entity, finalPos )
			local clearPaths = TFA.WonderWeapon.GetClearPaths( entity, finalPos, surroundingTiles )	

			for _, tile in pairs( clearPaths ) do
				if TFA.WonderWeapon.IsCollisionBoxClear( tile, entity, minBound, maxBound ) then
					finalPos = tile
					break
				end
			end
		end

		return finalPos
	end,

	StartCommand = function( self, entity, cusercmd )
		if IsFirstTimePredicted() then
			local RNGSeed = self.StatusEffect .. entity:EntIndex() .. CurTime()

			if self.NextRandomEyeAngle == nil then
				self.NextRandomEyeAngle = CurTime() + util.SharedRandom( RNGSeed, 0.5, 0.8, self:GetIndex() )
			end

			if self.NextRandomEyeAngle and self.NextRandomEyeAngle < CurTime() then
				self.NextRandomEyeAngle = CurTime() + util.SharedRandom( RNGSeed, 0.5, 0.8, self:GetIndex() )

				local pitch = util.SharedRandom( RNGSeed, -79, 79, self:GetIndex() + 69 )
				local yaw = util.SharedRandom( RNGSeed, 0, 180, self:GetIndex() - 69 )

				self.RandomEyeAngle = Angle( pitch, yaw, 0 )
			end
		end

		cusercmd:ClearButtons()
		cusercmd:ClearMovement()

		if self.RandomEyeAngle then
			cusercmd:SetForwardMove( 1000 )

			entity:SetEyeAngles( LerpAngle( FrameTime() * 6, entity:EyeAngles(), self.RandomEyeAngle ) )
		end
	end,

	InputMouseApply = function( self, entity, cusercmd, x, y, angle )
		cusercmd:SetMouseX(0)
		cusercmd:SetMouseY(0)

		return true
	end,

	StupidNPC = function( self, entity )
		if CLIENT then return end

		if IsValid( entity ) and entity:IsNPC() then
			if entity:GetEnemy() ~= self:GetAttacker() then
				entity:ClearSchedule()
				entity:ClearEnemyMemory( entity:GetEnemy() )

				entity:SetEnemy( self:GetAttacker() )

				local finalPos = self:FindFreeSpot( entity )
				entity:UpdateEnemyMemory( self:GetAttacker(), finalPos )
				entity:SetSaveValue( "m_vecLastPosition", finalPos )
			end

			entity:SetSchedule( SCHED_FORCED_GO_RUN )
		end
	end,

	InflictDamage = function( self, entity )
		if CLIENT then return end

		sound.Play("TFA_BO4_ALISTAIR.HeadPop", entity:EyePos(), SNDLVL_NORM, math.random(97, 103), 1)

		if entity.GetBloodColor then
			local BloodColor = entity.GetBloodColor and entity:GetBloodColor()
			if BloodColor ~= DONT_BLEED and TFA.WonderWeapon.ParticleByBloodColor[ BloodColor ] then
				ParticleEffect(TFA.WonderWeapon.ParticleByBloodColor[ BloodColor ], entity:EyePos(), entity.GetAimVector and entity:GetAimVector():Angle() or entity:GetForward():Angle())
				util.Decal(TFA.WonderWeapon.DecalByBloodColor[BloodColor], entity:GetPos(), entity:GetPos() - vector_up*4)
			end
		else
			ParticleEffect( "blood_impact_red_01", ent:GetPos() + vector_up, ent:GetUp():Angle() )
			util.Decal( "Blood", ent:GetPos(), ent:GetPos() - vector_up*4 )
		end

		local attacker = self:GetAttacker()
		local inflictor = self:GetInflictor()

		local damage = DamageInfo()
		damage:SetDamageType( DMG_ALWAYSGIB )
		damage:SetAttacker( IsValid(attacker) and attacker or entity )
		damage:SetInflictor( IsValid(inflictor) and inflictor or entity )
		damage:SetDamage( ( sv_true_damage and sv_true_damage:GetBool() or nzombies ) and entity:Health() + 666 or self:GetDamage() )
		damage:SetDamageForce( vector_up )
		damage:SetDamagePosition( TFA.WonderWeapon.BodyTarget(entity, entity:GetPos(), true) )
		damage:SetReportedPosition( entity:GetPos() )

		if nzombies and ( entity.NZBossType or string.find( entity:GetClass(), "zombie_boss" ) ) then
			damage:SetDamage( math.max( 1200, entity:GetMaxHealth() / 12 ) )
		end

		if entity:IsNPC() and entity:Alive() and damage:GetDamage() >= entity:Health() then
			entity:SetCondition( COND.NPC_UNFREEZE )
		end

		entity:TakeDamageInfo( damage )

		self:SendHitMarker( attacker, inflictor, entity, damage )

		SafeRemoveEntityDelayed( entity, 0 )
	end,
})

WonderWeapons.AddStatusEffect("BO4_Katana_Stealth", {
	ShouldCollide = false,

	ScreenSpaceEffect = "bo4_katana_screen",

	ScreenSpaceMaterial = "effects/invuln_overlay_red",

	PlayerNoTarget = true,

	Initialize = function( self, entity, duration )
		if CLIENT then return end

		self:ModifyMoveSpeed( 1.25, 0 )
	end,

	Draw = function( self, entity, visibility )
		local ourplayer = LocalPlayer()
		entity:AddDrawCallParticle( "bo4_katana_player", PATTACH_POINT_FOLLOW, 1, ( entity ~= ourplayer or ourplayer:ShouldDrawLocalPlayer() ) and entity:Health() > 0, "BO4_Katana_Stealth" )
	end,

	OnRemove = function( self, entity )
		TFA.WonderWeapon.StopDrawParticle( entity, "BO4_Katana_Stealth", false )
	end,
})

WonderWeapons.AddStatusEffect("BO4_Orion_Shock", {
	ShouldCollide = false,

	ShouldFreeze = true,

	BlockAttack = true,

	DoFirePanic = true,

	CollisionGroupOverride = COLLISION_GROUP_WORLD,

	Initialize = function( self, entity, duration, attacker, inflictor, damage )
		self:SetAttacker( attacker )
		self:SetInflictor( inflictor )
		self:SetDamage( damage or 1000 )

		if CLIENT then return end

		entity:EmitSound("TFA_BO4_SCORPION.Arc")
	end,

	Draw = function( self, entity, visibility )
		entity:AddDrawCallParticle( "bo4_scorpion_shock", PATTACH_POINT_FOLLOW, self.HeadAttachment or 1, entity:Health() > 0, "BO4_Orion_Shock" )
		//entity:AddDrawCallParticle( "bo4_scorpion_shock_ground", PATTACH_ABSORIGIN_FOLLOW, 1, entity:OnGround(), "BO4_Orion_Shock_Ground" )

		if entity.CNewParticlesTable then
			local CNPLoop = entity.CNewParticlesTable["BO4_Orion_Shock"]
			if CNPLoop and IsValid( CNPLoop ) then
				CNPLoop:SetControlPoint(3, entity:WorldSpaceCenter())
			end
		end
	end,

	OnStatusEnd = function( self, entity )
		TFA.WonderWeapon.StopDrawParticle( entity, "BO4_Orion_Shock", false )
		TFA.WonderWeapon.StopDrawParticle( entity, "BO4_Orion_Shock_Ground", false )

		if SERVER then
			self:InflictDamage( entity )
		end
	end,

	OnRemove = function( self, entity )
		TFA.WonderWeapon.StopDrawParticle( entity, "BO4_Orion_Shock", false )
		TFA.WonderWeapon.StopDrawParticle( entity, "BO4_Orion_Shock_Ground", false )
	end,

	InflictDamage = function( self, entity )
		if CLIENT then return end

		sound.Play("TFA_BO4_SCORPION.Kill", entity:EyePos(), SNDLVL_NORM, math.random(97, 103), 1)

		local attacker = self:GetAttacker()
		local inflictor = self:GetInflictor()

		local damage = DamageInfo()
		damage:SetDamageType(DMG_DISSOLVE)
		damage:SetAttacker(IsValid(attacker) and attacker or entity)
		damage:SetInflictor(IsValid(inflictor) and inflictor or entity)
		damage:SetDamage(( entity:GetMaxHealth() / 6 ) + self:GetDamage())
		damage:SetDamageForce(vector_up)
		damage:SetDamagePosition(TFA.WonderWeapon.BodyTarget(entity, entity:GetPos(), true))
		damage:SetReportedPosition(entity:GetPos())

		if nzombies and nzRound and nzRound.GetZombieHealth and entity:IsValidZombie() then
			local round = math.max(nzRound:GetNumber(), 1)
			local health = nzRound:GetZombieHealth()

			damage:SetDamage( ( health / 6 ) + self:GetDamage() )
		end

		if nzombies and ( entity.NZBossType or entity.IsMooBossZombie ) then
			damage:SetDamage(math.max(800, entity:GetMaxHealth() / 16))
		end

		if entity:IsNPC() and entity:Alive() and damage:GetDamage() >= entity:Health() then
			entity:SetCondition(COND.NPC_UNFREEZE)
		end

		entity:TakeDamageInfo(damage)

		self:SendHitMarker( attacker, inflictor, entity, damage )
	end,
})

WonderWeapons.AddStatusEffect("BO4_Orion_Spinner", {
	ShouldCollide = false,

	ShouldFreeze = true,

	BlockAttack = true,

	DoFirePanic = true,

	CollisionGroupOverride = COLLISION_GROUP_WORLD,

	Initialize = function( self, entity, duration, attacker, inflictor, damage, upgraded )
		self:SetAttacker( attacker )
		self:SetInflictor( inflictor )
		self:SetDamage( damage or 1000 )
		self:SetUpgraded( tobool(upgraded) )

		if CLIENT then return end

		local direction = physenv.GetGravity():GetNormalized()

		util.Decal("Rollermine.Crater", entity:GetPos(), entity:GetPos() + direction*-8, entity)

		entity:EmitSound("TFA_BO4_SCORPION.Shock")
		entity:EmitSound("TFA_BO4_SCORPION.Spin")

		self.NextAttack = CurTime()
		self.ShockedEntities = {}
	end,

	Think = function( self, entity )
		if CLIENT then return end

		local attacker = self:GetAttacker()
		local inflictor = self:GetInflictor()

		if self.NextAttack and self.NextAttack < CurTime() then
			for _, victim in pairs( ents.FindInSphere( entity:GetPos(), 120 ) ) do
				if victim:IsNPC() or victim:IsNextBot() then
					if victim == entity then continue end
					if not TFA.WonderWeapon.ShouldDamage(victim, attacker, inflictor) then continue end

					if TFA.WonderWeapon.HasStatus(victim, "BO4_Orion_Spinner") then continue end

					if TFA.WonderWeapon.HasStatus(victim, "BO4_Orion_Shock") then
						local mStatus = TFA.WonderWeapon.GetStatus(victim, "BO4_Orion_Shock")
						if mStatus then
							if !mStatus.NextScorpionJolt then
								mStatus.NextScorpionJolt = CurTime() + math.Rand(0.9, 1.2)
							end

							if mStatus.NextScorpionJolt and mStatus.NextScorpionJolt < CurTime() then
								mStatus.NextScorpionJolt = CurTime() + math.Rand(0.9, 1.2)
								mStatus:InflictDamage( victim )
							end
						end
						continue
					end

					local time = ( math.random(9, 12) * 0.5 ) * math.Rand( 0.9, 1.1 )
					if nzombies and nzPowerUps and nzPowerUps.IsPowerupActive and nzPowerUps:IsPowerupActive("insta") then
						time = 1
					end

					local fx = EffectData()
					fx:SetStart(TFA.WonderWeapon.BodyTarget(entity, entity:GetPos()))
					fx:SetOrigin(victim:WorldSpaceCenter())
					fx:SetEntity(victim)

					util.Effect("tfa_bo4_scorpion_jump", fx)

					TFA.WonderWeapon.GiveStatus(victim, "BO4_Orion_Shock", time, attacker, inflictor)

					if not self.ShockedEntities[ victim ] then
						victim.StatusEffectSpinnerInfectionHost = entity
						self.ShockedEntities[ victim ] = CurTime()
					end

					break
				end
			end

			self.NextAttack = CurTime() + ( self:GetUpgraded() and math.Rand(0.2, 0.25) or math.Rand(0.2, 0.4) )
		end
	end,

	Draw = function( self, entity, visibility )
		entity:AddDrawCallParticle( "bo4_scorpion_spinner", PATTACH_POINT_FOLLOW, self.HeadAttachment or 1, entity:Health() > 0, "BO4_Orion_Spinner" )
		//entity:AddDrawCallParticle( "bo4_scorpion_spinner_ground", PATTACH_ABSORIGIN_FOLLOW, 1, entity:OnGround(), "BO4_Orion_Spinner_Ground" )

		if entity.CNewParticlesTable then
			local CNPLoop = entity.CNewParticlesTable["BO4_Orion_Spinner"]
			if CNPLoop and IsValid( CNPLoop ) then
				CNPLoop:SetControlPoint(3, entity:WorldSpaceCenter())
			end
		end

		if cl_show_dlight:GetBool() and DynamicLight and entity:Health() > 0 then
			self.DLight = self.DLight or DynamicLight( entity:EntIndex(), false )

			if self.DLight then
				self.DLight.pos = entity:GetPos()
				self.DLight.dir = entity:GetUp():GetNegated()
				self.DLight.r = 250
				self.DLight.g = 255
				self.DLight.b = 120
				self.DLight.decay = 1000
				self.DLight.brightness = 0
				self.DLight.size = 144
				self.DLight.dietime = CurTime() + 1
			end
		elseif self.DLight then
			self.DLight.dietime = -1
		end
	end,

	OnStatusEnd = function( self, entity )
		TFA.WonderWeapon.StopDrawParticle( entity, "BO4_Orion_Spinner", false )
		TFA.WonderWeapon.StopDrawParticle( entity, "BO4_Orion_Spinner_Ground", false )

		entity:StopSound("TFA_BO4_SCORPION.Spin")

		if SERVER then
			self:InflictDamage( entity )

			for victim, _ in pairs( self.ShockedEntities ) do
				if TFA.WonderWeapon.HasStatus( victim, "BO4_Orion_Shock" ) and victim.StatusEffectSpinnerInfectionHost and victim.StatusEffectSpinnerInfectionHost == entity then
					TFA.WonderWeapon.RemoveStatus( victim, "BO4_Orion_Shock" )
				end
			end

			self.ShockedEntities = nil
		end
	end,

	EntityTakeDamage = function( self, entity, damageinfo )
		damageinfo:SetDamageType(bit.bor(DMG_DISSOLVE, DMG_SHOCK))
	end,

	OnRemove = function( self, entity )
		TFA.WonderWeapon.StopDrawParticle( entity, "BO4_Orion_Spinner", false )
		TFA.WonderWeapon.StopDrawParticle( entity, "BO4_Orion_Spinner_Ground", false )

		if IsValid( entity ) then
			entity:StopSound("TFA_BO4_SCORPION.Spin")
		end

		if SERVER and self.ShockedEntities then
			for victim, _ in pairs( self.ShockedEntities ) do
				if TFA.WonderWeapon.HasStatus( victim, "BO4_Orion_Shock" ) and victim.StatusEffectSpinnerInfectionHost and victim.StatusEffectSpinnerInfectionHost == entity then
					TFA.WonderWeapon.RemoveStatus( victim, "BO4_Orion_Shock" )
				end
			end
		end
	end,

	InflictDamage = function( self, entity )
		if CLIENT then return end

		sound.Play("TFA_BO4_SCORPION.Kill", entity:EyePos(), SNDLVL_NORM, math.random(97, 103), 1)

		local attacker = self:GetAttacker()
		local inflictor = self:GetInflictor()

		local damage = DamageInfo()
		damage:SetDamageType(nzombies and DMG_DISSOLVE or bit.bor(DMG_DISSOLVE, DMG_SHOCK))
		damage:SetAttacker(IsValid(attacker) and attacker or entity)
		damage:SetInflictor(IsValid(inflictor) and inflictor or entity)
		damage:SetDamage((sv_true_damage and sv_true_damage:GetBool() or nzombies) and entity:Health() + 666 or self:GetDamage())
		damage:SetDamageForce(vector_up)
		damage:SetDamagePosition(TFA.WonderWeapon.BodyTarget(entity, entity:GetPos(), true))
		damage:SetReportedPosition(entity:GetPos())

		if nzombies and (entity.NZBossType or string.find(entity:GetClass(), "zombie_boss")) then
			damage:SetDamage(math.max(1200, entity:GetMaxHealth() / 12))
		end

		if entity:IsNPC() and entity:Alive() and damage:GetDamage() >= entity:Health() then
			entity:SetCondition(COND.NPC_UNFREEZE)
		end

		entity:TakeDamageInfo(damage)

		self:SendHitMarker( attacker, inflictor, entity, damage )
	end,
})

WonderWeapons.AddStatusEffect("BO4_Ragnarok_Shock", {
	ShouldCollide = false,

	ShouldFreeze = true,

	BlockAttack = true,

	DoFirePanic = true,

	CollisionGroupOverride = COLLISION_GROUP_WORLD,

	Initialize = function( self, entity, duration, attacker, inflictor, damage )
		self:SetAttacker( attacker )
		self:SetInflictor( inflictor )
		self:SetDamage( damage or 115 )

		if CLIENT then return end

		self.Traptime = 2
		if nzombies and nzPowerUps and nzPowerUps.IsPowerupActive and nzPowerUps:IsPowerupActive( "insta" ) then
			self.Traptime = 0.5
		end

		entity:EmitSound("TFA_BO4_DG5.ShockLoop")
	end,

	Draw = function( self, entity, visibility )
		entity:AddDrawCallParticle( "bo4_dg5_shock", PATTACH_POINT_FOLLOW, self.HeadAttachment or 1, entity:Health() > 0, "BO4_Ragnarok_Shock" )
	end,

	Think = function( self, entity )
		if CLIENT then return end

		if IsValid( entity ) and ( self:GetEndTime() - self:GetStartTime() ) > self.Traptime then
			entity:EmitSound("TFA_BO4_DG5.ShockEnd")

			self:InflictDamage( entity )

			self:Remove()
		end
	end,

	OnStatusEnd = function( self, entity )
		TFA.WonderWeapon.StopDrawParticle( entity, "BO4_Ragnarok_Shock", false )

		entity:StopSound("TFA_BO4_DG5.ShockLoop")
	end,

	OnRemove = function( self, entity )
		TFA.WonderWeapon.StopDrawParticle( entity, "BO4_Ragnarok_Shock", false )

		if IsValid( entity ) then
			entity:StopSound("TFA_BO4_DG5.ShockLoop")
		end
	end,

	InflictDamage = function( self, entity )
		if CLIENT then return end

		entity:EmitSound("TFA_BO3_GENERIC.Gore")

		sound.Play("TFA_BO3_WAFFE.Pop", entity:EyePos(), SNDLVL_NORM, math.random(97, 103), 1)

		if entity.GetBloodColor then
			local BloodColor = entity.GetBloodColor and entity:GetBloodColor()
			if BloodColor ~= DONT_BLEED and TFA.WonderWeapon.ParticleByBloodColor[ BloodColor ] then
				ParticleEffect(TFA.WonderWeapon.ParticleByBloodColor[ BloodColor ], entity:EyePos(), entity.GetAimVector and entity:GetAimVector():Angle() or entity:GetForward():Angle())
			end
		else
			ParticleEffect("blood_impact_red_01", entity:EyePos(), entity.GetAimVector and entity:GetAimVector():Angle() or entity:GetForward():Angle())
		end

		local attacker = self:GetAttacker()
		local inflictor = self:GetInflictor()

		local damage = DamageInfo()
		damage:SetDamageType(DMG_ENERGYBEAM)
		damage:SetAttacker(IsValid(attacker) and attacker or entity)
		damage:SetInflictor(IsValid(inflictor) and inflictor or entity)
		damage:SetDamage((sv_true_damage and sv_true_damage:GetBool() or nzombies) and entity:Health() + 666 or self:GetDamage())
		damage:SetDamageForce(vector_up)
		damage:SetDamagePosition(TFA.WonderWeapon.BodyTarget(entity, entity:GetPos(), true))
		damage:SetReportedPosition(entity:GetPos())

		if nzombies and ( entity.NZBossType or string.find( entity:GetClass(), "zombie_boss" ) ) then
			damage:SetDamage(math.max(1000, entity:GetMaxHealth() / 10))
		end

		if entity:IsNPC() and entity:Alive() and damage:GetDamage() >= entity:Health() then
			entity:SetCondition(COND.NPC_UNFREEZE)
		end

		TFA.WonderWeapon.DoDeathEffect( entity, "BO4_Ragnarok", math.Rand( 2.5, 4 ) )

		entity:TakeDamageInfo(damage)

		self:SendHitMarker( attacker, inflictor, entity, damage )
	end,
})

WonderWeapons.AddStatusEffect("BO4_MagmaGat_Burn", {
	ShouldCollide = false,

	BlockAttack = true,

	ZombieSlowWalk = true,

	Initialize = function( self, entity, duration, attacker, inflictor, damage )
		self:SetAttacker( attacker )
		self:SetInflictor( inflictor )
		self:SetDamage( damage or ( nzombies and 600 or 125 ) )

		if CLIENT then
			entity:EmitSound("npc/headcrab/headcrab_burning_loop2.wav")
			return
		end

		self:ModifyMoveSpeed( 0.25, duration )
	end,

	Draw = function( self, entity, visibility )
		entity:AddDrawCallParticle( "burning_character", PATTACH_POINT_FOLLOW, self.ChestAttachment or 1, entity:Health() > 0, "BO4_MagmaGat_Burn" )
	end,

	OnStatusEnd = function( self, entity )
		if SERVER then
			self:InflictDamage( entity )
		end
	end,

	CreateClientsideRagdoll = function( self, entity, ragdoll )
		if not entity:IsOnFire() then
			entity:StopSound( "npc/headcrab/headcrab_burning_loop2.wav" )
		end

		ragdoll:AddDrawCallParticle( "burning_character", PATTACH_POINT_FOLLOW, self.ChestAttachment or 1, true, "BO4_MagmaGat_Burn" )

		timer.Simple( math.Rand( 2, 4 ), function()
			if not IsValid( ragdoll ) then return end
			TFA.WonderWeapon.StopDrawParticle( ragdoll, "BO4_MagmaGat_Burn", false )
		end )
	end,

	CreateEntityRagdoll = function( self, entity, ragdoll )
		if not entity:IsOnFire() then
			entity:StopSound( "npc/headcrab/headcrab_burning_loop2.wav" )
		end

		ragdoll:AddDrawCallParticle( "burning_character", PATTACH_POINT_FOLLOW, self.ChestAttachment or 1, true, "BO4_MagmaGat_Burn" )

		timer.Simple( math.Rand( 2, 4 ), function()
			if not IsValid( ragdoll ) then return end
			TFA.WonderWeapon.StopDrawParticle( ragdoll, "BO4_MagmaGat_Burn", false )
		end )
	end,

	OnRemove = function( self, entity )
		TFA.WonderWeapon.StopDrawParticle( entity, "BO4_MagmaGat_Burn", false )

		if IsValid( entity ) and not entity:IsOnFire() then
			entity:StopSound( "npc/headcrab/headcrab_burning_loop2.wav" )
		end
	end,

	InflictDamage = function( self, entity )
		if CLIENT then return end

		local finalPos = math.random(2) == 1 and TFA.WonderWeapon.BodyTarget( entity:GetPos(), true ) or entity:WorldSpaceCenter()
		if self.ChestAttachment then
			local attData = entity:GetAttachment( self.ChestAttachment )

			if ( attData and attData.Pos ) and math.random(4) == 1 then
				finalPos = attData.Pos
			end
		end

		ParticleEffect( "bo4_magmagat_explode", finalPos, Angle(0,0,0) )

		entity:EmitSound( "TFA_BO4_BLUNDER.Magma.Explode" )
		entity:EmitSound( "TFA_BO4_BLUNDER.Magma.Explode.Swt" )

		local attacker = self:GetAttacker()
		local inflictor = self:GetInflictor()

		local damage = DamageInfo()
		damage:SetDamageType( TFA.WonderWeapon.GetBurnDamage( entity ) )
		damage:SetAttacker( IsValid(attacker) and attacker or entity )
		damage:SetInflictor( IsValid(inflictor) and inflictor or entity )
		damage:SetDamage( ( sv_true_damage and sv_true_damage:GetBool() or nzombies ) and entity:Health() + 666 or self:GetDamage() )
		damage:SetDamageForce( vector_up)
		damage:SetDamagePosition( TFA.WonderWeapon.BodyTarget( ntity, entity:GetPos(), true ) )
		damage:SetReportedPosition( entity:GetPos() )

		if nzombies and ( entity.NZBossType or string.find( entity:GetClass(), "zombie_boss" ) ) then
			damage:SetDamage( math.max( 1200, entity:GetMaxHealth() / 12 ) )
		end

		if entity:IsNPC() and entity:Alive() and damage:GetDamage() >= entity:Health() then
			entity:SetCondition( COND.NPC_UNFREEZE )
		end

		entity:TakeDamageInfo( damage )

		self:SendHitMarker( attacker, inflictor, entity, damage )
	end,
})

WonderWeapons.AddStatusEffect("BO4_Winters_Slow", {
	ShouldCollide = false,

	ScreenSpaceEffect = "bo4_freezegun_screen",

	//ScreenSpaceMaterial = "vgui/overlay/i_frost_r.png",

	Initialize = function( self, entity, duration, ratio, delta )
		if not ratio or not isnumber( ratio ) or ratio < 0 then
			ratio = 1
		end

		if not delta or not isnumber( delta ) or delta < 0 then
			delta = 0
		end

		self:SetRatio( ratio )

		if CLIENT then return end

		self:ModifyMoveSpeed( self:GetRatio(), delta )
	end,

	Update = function( self, entity, duration, ratio, delta, forced )
		if not ratio or not isnumber( ratio ) then
			return
		end

		if ratio > self:GetRatio() and not forced then
			return
		end

		self:SetRatio( ratio )

		if CLIENT then return end

		self:ModifyMoveSpeed( self:GetRatio(), 0 )
	end,

	Draw = function( self, entity, visibility )
		local ourplayer = LocalPlayer()
		entity:AddDrawCallParticle( "bo4_freezegun_zomb_smoke", PATTACH_ABSORIGIN_FOLLOW, 1, ( entity ~= ourplayer or ourplayer:ShouldDrawLocalPlayer() ) and entity:Health() > 0, "BO4_Winters_Slow" )
	end,

	OnRemove = function( self, entity )
		TFA.WonderWeapon.StopDrawParticle( entity, "BO4_Winters_Slow", false )
	end,

	Ratio = 1,

	SetRatio = function( self, float )
		self.Ratio = tonumber( float )
	end,

	GetRatio = function( self )
		return self.Ratio or 1
	end,
})

WonderWeapons.AddStatusEffect("BO4_Winters_Freeze", {
	ShouldCollide = true,
	CollisionIgnoreWorld = true,

	ShouldFreeze = true,

	BlockAttack = true,

	DoFirePanic = true,

	CollisionGroupOverride = COLLISION_GROUP_PASSABLE_DOOR,

	ScreenSpaceEffect = "bo4_freezegun_screen",

	//ScreenSpaceMaterial = "vgui/overlay/i_frost_r.png",

	Initialize = function( self, entity, duration, attacker, inflictor, damage )
		self:SetAttacker( attacker )
		self:SetInflictor( inflictor )
		self:SetDamage( damage or 500 ) // ignored in nzombies

		if entity.SetOverlay then
			entity:SetOverlay( "models/weapons/tfa_bo4/winters/mtl_p_rus_icicles_out", color_transparent )
		else
			entity:SetMaterial( "models/weapons/tfa_bo4/winters/rus_ter_ice_slush" )
		end

		if CLIENT then
			local boneID = entity:LookupBone("ValveBiped.Bip01_Spine2") or entity:LookupBone("ValveBiped.Bip01_Spine")

			if not boneID then
				for i = 1, entity:GetBoneCount() do
					local boneName = entity:GetBoneName( i - 1 )
					if string.find(boneName, "spine", -6) or string.sub(boneName, 1, 5) == "spine" then
						boneID = i - 1
						break
					end
				end
			end

			local Chunk = ents.CreateClientProp( "models/weapons/tfa_bo4/winters/ice_chunk.mdl" )
			Chunk:SetModel( "models/weapons/tfa_bo4/winters/ice_chunk.mdl" )
			Chunk:SetBodygroup( 0, math.random(0, 1) )
			Chunk.AutomaticFrameAdvance = true
			//Chunk:SetAutomaticFrameAdvance( true )

			if boneID then
				Chunk:SetPos( entity:WorldSpaceCenter() )
				Chunk:SetAngles( entity:GetAngles() )
				Chunk:SetParent( entity )
				//Chunk:FollowBone( entity , boneID )
			else
				Chunk:SetPos( entity:WorldSpaceCenter() )
				Chunk:SetAngles( Angle( 0, 0, 0 ) )
				Chunk:SetParent( entity )
			end

			Chunk:SetModelScale( entity:BoundingRadius() / 60, 0 )

			Chunk:PhysicsInit( SOLID_NONE )
			Chunk:SetMoveType( MOVETYPE_NONE )
			Chunk:SetSolid( SOLID_NONE )

			Chunk:SetCollisionGroup( COLLISION_GROUP_IN_VEHICLE )

			Chunk:Spawn()

			local hookName = "TFA.BO4WW.Fox.Freezegun.Chunk." .. self:GetIndex()
			hook.Add("EntityRemoved", hookName, function( ent, bFullUpdate )
				if ( bFullUpdate ) then return end

				if not IsValid( entity ) then
					hook.Remove( "EntityRemoved", hookName )
				end

				if ent == entity and IsValid( Chunk ) then
					Chunk:Remove()
				end
			end)

			self.IceChunkModel = Chunk
			self.IceChunkScale = entity:BoundingRadius() / 25
			self.IceChunkScaleDelta = math.max( duration * math.Rand(0.6, 0.9), 0 )

			return
		end

		entity:EmitSound( "weapons/tfa_bo4/winters/zm_office.all.sabl.47" .. math.random( 2, 4 ) .. ".wav", math.random( 70, 80 ), math.random( 97, 103 ), 1, CHAN_STATIC )
	end,

	Draw = function( self, entity, visibility )
		if entity.SetOverlay then
			local flFadeTime = math.min( 1.5, self:GetEndTime() - self:GetStartTime() )
			local flFadeRatio = 1 - math.Clamp( ( ( self:GetStartTime() + flFadeTime ) - CurTime() ) / flFadeTime, 0, 1 )

			entity:SetOverlay( "models/weapons/tfa_bo4/winters/mtl_p_rus_icicles_out", ColorAlpha( color_white, 255 * flFadeRatio ) )
		end

		local Chunk = self.IceChunkModel
		if IsValid( Chunk ) and Chunk:GetModelScale() < self.IceChunkScale then
			local flScaleRatio = 1 - math.Clamp( ( ( self:GetStartTime() + self.IceChunkScaleDelta ) - CurTime() ) / self.IceChunkScaleDelta, 0, 1 )

			Chunk:SetModelScale( math.max( Chunk:GetModelScale(), self.IceChunkScale * flScaleRatio ) )
		end

		local ourplayer = LocalPlayer()

		entity:AddDrawCallParticle( "bo4_freezegun_zomb_smoke", PATTACH_POINT_FOLLOW, self.ChestAttachment or 1, ( entity ~= ourplayer or ourplayer:ShouldDrawLocalPlayer() ) and entity:Health() > 0, "BO4_Winters_Freeze" )
	end,

	Think = function( self, entity )
	end,

	EntityTakeDamage = function( self, entity, damageinfo )
		local newAttacker = damageinfo:GetAttacker()
		if IsValid( newAttacker ) and newAttacker:Alive() and newAttacker ~= self:GetAttacker() then
			self:SetAttacker( newAttacker )
		end

		self:InflictDamage( entity, damageinfo:GetDamagePosition(), damageinfo:GetReportedPosition(), math.max( self:GetDamage() or damageinfo:GetDamage() ) )

		if newAttacker ~= self:GetOriginalAttacker() then
			self:SendHitMarker( self:GetOriginalAttacker(), inflictor, entity, damage )
		end

		if bit.band( damageinfo:GetDamageType(), bit.bor( DMG_SLASH, DMG_CLUB, DMG_CRUSH ) ) ~= 0 then
			self:Explode( damageinfo:GetDamagePosition() )
		end

		return true
	end,

	EntityCollide = function( self, entity, trace )
		local hitEntity = trace.Entity

		local phys = hitEntity:GetPhysicsObject()
		if hitEntity:IsPlayer() or ( IsValid( phys ) and ( phys:GetMass() >= 25 and phys:GetVelocity():Length() >= 300 ) ) then
			self:SetAttacker( hitEntity )

			self:InflictDamage( entity, trace.HitPos, trace.StartPos )
		end
	end,

	CreateClientsideRagdoll = function( self, entity, ragdoll )
		TFA.WonderWeapon.SafeRemoveRagdoll( ragdoll )
	end,

	CreateEntityRagdoll = function( self, entity, ragdoll )
		TFA.WonderWeapon.SafeRemoveRagdoll( ragdoll )
	end,

	OnStatusEnd = function( self, entity )
		if self.IceChunkModel and IsValid( self.IceChunkModel ) then
			SafeRemoveEntity( self.IceChunkModel )
		end

		if SERVER then
			self:InflictDamage( entity )
		end
	end,

	OnRemove = function( self, entity )
		TFA.WonderWeapon.StopDrawParticle( entity, "BO4_Winters_Freeze", false )

		if entity.SetOverlay then
			entity:SetOverlay( "" )
		else
			entity:SetMaterial( "" )
		end

		if self.IceChunkModel and IsValid( self.IceChunkModel ) then
			SafeRemoveEntity( self.IceChunkModel )
		end
	end,

	// Custom

	Explode = function( self, hitpos )
		local entity = self:GetEntity()

		if hitpos == nil or not isvector( hitpos ) or hitpos:IsZero() then
			hitpos = TFA.WonderWeapon.BodyTarget( entity, entity:GetPos() )
		end

		local attacker = self:GetAttacker()
		local inflictor = self:GetInflictor()

		local damage = DamageInfo()
		damage:SetAttacker( IsValid( attacker ) and attacker or self )
		damage:SetInflictor( IsValid( inflictor ) and inflictor or self )
		damage:SetDamage( 500 )
		damage:SetDamageType( DMG_MISSILEDEFENSE )
		damage:SetReportedPosition( hitpos )

		for _, ent in pairs( ents.FindInSphere( entity:GetPos(), 120 ) ) do
			if not ent:IsWorld() and ent:IsSolid() then
				if ent == entity then continue end

				if TFA.WonderWeapon.HasStatus( ent, "BO4_Winters_Freeze" ) then
					local mStatus = TFA.WonderWeapon.GetStatus( ent, "BO4_Winters_Freeze" )
					if IsValid( attacker ) then
						mStatus:SetAttacker( attacker )
					end

					mStatus:InflictDamage( ent, nil, hitpos )

					if attacker ~= self:GetOriginalAttacker() then
						self:SendHitMarker( self:GetOriginalAttacker(), inflictor, entity, damage )
					end

					break
				end

				if ent:IsPlayer() then continue end
				if not TFA.WonderWeapon.ShouldDamage( ent, attacker, inflictor ) then continue end

				damage:SetDamageForce( ent:GetUp()*10000 + ( ent:GetPos() - entity:GetPos() ):GetNormalized() * 15000 )
				damage:SetDamagePosition( TFA.WonderWeapon.BodyTarget( ent, entity:GetPos(), true ) )

				if ent:IsNPC() and ent:Alive() and ent:Health() > 0 then
					ent:SetCondition( COND.NPC_UNFREEZE )
				end

				ent:TakeDamageInfo( damage )
			end
		end
	end,

	InflictDamage = function( self, entity, hitpos, startpos, damageoverride )
		if CLIENT then return end
		if entity.StatusEffectDamage then return end // in theory this shouldnt be needed

		if startpos == nil or not isvector( startpos ) or startpos:IsZero() then
			startpos = entity:GetPos()
		end

		if hitpos == nil or not isvector( hitpos ) or hitpos:IsZero() then
			hitpos = TFA.WonderWeapon.BodyTarget( entity, startpos )
		end

		ParticleEffectAttach( "bo4_freezegun_shatter", PATTACH_ABSORIGIN_FOLLOW, entity, 1 )

		sound.Play( "TFA_BO4_WINTERS.Shatter", entity:GetPos(), SNDLVL_70dB, math.random( 97, 103 ), 1 )

		local attacker = self:GetAttacker()
		local inflictor = self:GetInflictor()

		local damage = DamageInfo()
		damage:SetDamageType( nZSTORM and DMG_VEHICLE or DMG_DIRECT )
		damage:SetAttacker( IsValid(attacker) and attacker or entity )
		damage:SetInflictor( IsValid(inflictor) and inflictor or entity )
		damage:SetDamage( ( sv_true_damage and sv_true_damage:GetBool() or nzombies ) and entity:Health() + 666 or ( damageoverride or self:GetDamage() ) )
		damage:SetDamageForce( vector_up )
		damage:SetDamagePosition( hitpos )
		damage:SetReportedPosition( startpos )

		if nzombies and ( entity.NZBossType or string.find( entity:GetClass(), "zombie_boss" ) ) then
			damage:SetDamage( math.max( 1000, entity:GetMaxHealth() / 10 ) )
		end

		if entity:IsNPC() and entity:Alive() and damage:GetDamage() >= entity:Health() then
			entity:SetCondition( COND.NPC_UNFREEZE )
		end

		entity.StatusEffectDamage = true

		TFA.WonderWeapon.DoDeathEffect( entity, "Remove_Ragdoll", engine.TickInterval() )

		entity:TakeDamageInfo( damage )

		entity.StatusEffectDamage = nil

		self:SendHitMarker( attacker, inflictor, entity, damage )

		if IsValid(attacker) and attacker:IsPlayer() and ( entity:IsNPC() or entity:IsNextBot() or entity:IsPlayer() ) then
			TFA.WonderWeapon.NotifyAchievement( "BO4_Winters_Freeze_Kills", attacker, entity, self )
		end

		self:Remove()
	end,
})
