//-------------------------------------------------------------
// Status Effects
//-------------------------------------------------------------

local WonderWeapons = TFA.WonderWeapon

local nzombies = engine.ActiveGamemode() == "nzombies"
local SinglePlayer = game.SinglePlayer()
local sv_true_damage = GetConVar("sv_tfa_bo3ww_cod_damage")

local CLIENT_RAGDOLLS = {
	"class C_ClientRagdoll",
	"class C_HL2MPRagdoll",
}

WonderWeapons.AddStatusEffect("NPC_Modify_CollisionGroup", {
	ShouldCollide = false,

	CollisionGroupOverride = COLLISION_GROUP_NPC,

	Initialize = function( self, entity, duration, collisiongroup )
		if collisiongroup then
			self.CollisionGroupOverride = collisiongroup
		end
	end,
})

WonderWeapons.AddStatusEffect("BO3_Shrinkray_Shrink", {
	ShouldCollide = true,
	CollisionIgnoreWorld = true,

	CollisionGroupOverride = COLLISION_GROUP_DEBRIS,

	ModelScale = 0.5,
	ModelScaleDeltaTime = 0.5,

	DuckedViewHeight = true,

	Initialize = function( self, entity, duration, attacker, upgraded )
		self:SetUpgraded( upgraded )
		self:SetAttacker( attacker )
		self:SetInflictor( entity )

		local ply = self:GetAttacker()
		if IsValid( ply ) and ply.GetActiveWeapon and IsValid( ply:GetActiveWeapon() ) then
			self:SetInflictor( ply:GetActiveWeapon() )
		end

		self.Assistor = self.Attacker

		local headbone = entity:LookupBone( "ValveBiped.Bip01_Head1" ) or entity:LookupBone( "j_head" ) or entity:LookupBone( "head" )
		if headbone then
			entity:ManipulateBoneScale( headbone, Vector(2,2,2) )
		end

		if CLIENT then
			local soundHook = "TFA.BO3WW.FOX.ShrinkSounds." .. self:GetIndex()
			hook.Add( "EntityEmitSound", soundHook, function( data )
				local emitter = data.Entity
				if not IsValid( emitter ) then
					return
				end

				if not IsValid( entity ) or entity:IsMarkedForDeletion() then
					hook.Remove( "EntityEmitSound", soundHook )
					return
				end

				if emitter ~= entity then
					return
				end

				if WonderWeapons.NoShrinkSound[ data.SoundName ] then
					return false
				end

				if not WonderWeapons.NoShrinkSoundMod[ data.OriginalSoundName ] then
					data.Pitch = 168
					return true
				end
			end )
			return
		end

		local sv_shrinkray_damage_mult = GetConVar("sv_tfa_bo3ww_shrinkray_damage_multiplier")

		local damageHook = "TFA.BO3WW.FOX.ShrinkDamage"..self:GetIndex()
		hook.Add( "EntityTakeDamage", damageHook, function( _, damageinfo )
			if not IsValid( entity ) or entity:IsMarkedForDeletion() then
				hook.Remove( "EntityTakeDamage", damageHook )
				return
			end

			local attacker = damageinfo:GetAttacker()
			if IsValid(attacker) and attacker == entity then
				damageinfo:SetDamage( damageinfo:GetDamage() * ( sv_shrinkray_damage_mult and sv_shrinkray_damage_mult:GetFloat() or 0.2 ) )
			end
		end )

		self.MaxGibCount = math.random(2)
		self.OldOBBMins = entity:OBBMins()
		self.OldOBBMaxs = entity:OBBMaxs()

		entity:SetHealth( 1 )

		entity:EmitSound( "TFA_BO3_JGB.ZMB.Shrink" )

		ParticleEffectAttach( entity:WaterLevel() > 2 and "bo3_jgb_shrink_uw" or "bo3_jgb_shrink", PATTACH_POINT_FOLLOW, entity, self.HeadAttachment or 1 )

		self:NPCChaseCheck()
	end,

	Think = function( self, entity )
		if CLIENT then return end

		local npc = self.ChaserNPC
		if IsValid( npc ) then
			if IsValid( entity ) and not entity:Alive() and WonderWeapons.HasStatus( npc, "NPC_Modify_CollisionGroup" ) then
				WonderWeapons.RemoveStatus( npc, "NPC_Modify_CollisionGroup" )
			end

			npc:UpdateEnemyMemory( entity, entity:GetPos() )
			npc:SetSaveValue( "m_vecLastPosition", entity:GetPos() )
			npc:SetSchedule( self:GetKicked() and SCHED_ALERT_STAND or SCHED_FORCED_GO_RUN )
		end

		if self:GetKicked() and not self:GetSquished() and entity:IsOnGround() then
			local groundTrace = util.QuickTrace(entity:GetPos(), vector_up*-4, entity)

			self.MaxGibCount = 3
			self:Squish( groundTrace )
		end
	end,

	EntityCollide = function( self, entity, trace )
		if not entity:Alive() then return end

		local hitEntity = trace.Entity
		if WonderWeapons.HasStatus( hitEntity, "BO3_Shrinkray_Shrink" ) then return end

		if self:GetKicked() then
			if ( not IsValid(hitEntity) or hitEntity ~= self:GetAttacker() ) then
				self.MaxGibCount = 3
				self:Squish( trace )

				local attacker = self:GetAttacker()
				local inflictor = self:GetInflictor()

				local direction = trace.Normal

				local phys = entity:GetPhysicsObject()
				if IsValid( phys ) then
					direction = phys:GetVelocity():GetNormalized()
				end

				if IsValid( hitEntity ) then
					local hitDamage = DamageInfo()
					hitDamage:SetDamage(10)
					hitDamage:SetAttacker(IsValid(attacker) and attacker or hitEntity)
					hitDamage:SetInflictor(IsValid(inflictor) and inflictor or hitEntity)
					hitDamage:SetDamageType(DMG_GENERIC)
					hitDamage:SetDamageForce(direction*200)
					hitDamage:SetDamagePosition(trace.HitPos)
					hitDamage:SetReportedPosition(trace.StartPos)

					hitEntity:DispatchTraceAttack(hitDamage, trace, direction)

					self:SendHitMarker( attacker, inflictor, hitEntity, hitDamage, trace )
				end
			end
		else
			if IsValid( hitEntity ) and ( hitEntity:IsPlayer() or ( hitEntity:IsNPC() and entity:IsPlayer() ) ) then
				local speed = hitEntity:GetVelocity():Length()
				if speed < .1 and !hitEntity:IsNPC() then return end

				self:SetAttacker( hitEntity )
				self:SetInflictor( IsValid( hitEntity:GetActiveWeapon() ) and hitEntity:GetActiveWeapon() or hitEntity )

				local normal = ( entity:GetPos() - hitEntity:GetPos() ):GetNormalized()
				local forward = hitEntity:GetAngles():Forward()
				local dot = forward:Dot( normal )

				if hitEntity:IsNPC() and entity:IsPlayer() then
					self:Kick( trace )
				elseif entity.GetHullType then
					local validSizes = {
						[HULL_HUMAN] = true,
						[HULL_WIDE_HUMAN] = true,
						[HULL_LARGE] = true,
						[HULL_LARGE_CENTERED] = true,
						[HULL_MEDIUM_TALL] = true,
					}

					if validSizes[ entity:GetHullType() ] then
						if dot > .5 and speed > 0 then
							if not self:GetKicked() then
								self:Kick( trace )
							end
						else
							self:Squish( trace )
						end
					else
						self:Squish( trace )
					end
				else
					if dot > .5 and speed > 0 then
						if not self:GetKicked() then
							self:Kick( trace )
						end
					else
						self:Squish( trace )
					end
				end
			end
		end
	end,

	ShouldRemove = function( self, entity )
		return not self:GetKicked() and WonderWeapons.IsCollisionBoxClear( entity:GetPos() + vector_up, entity, self.OldOBBMins, self.OldOBBMaxs ) and entity:GetInternalVariable("m_lifeState") == 0
	end,

	OnRemove = function( self, entity )
		if not IsValid( entity ) then return end

		local headbone = entity:LookupBone("ValveBiped.Bip01_Head1") or entity:LookupBone("j_head") or entity:LookupBone( "head" )
		if headbone then
			entity:ManipulateBoneScale( headbone, Vector( 1, 1, 1 ) )
		end

		local soundHook = "TFA.BO3WW.FOX.ShrinkSounds."..self:GetIndex()
		hook.Remove( "EntityEmitSound", soundHook )

		if CLIENT then return end

		local damageHook = "TFA.BO3WW.FOX.ShrinkDamage"..self:GetIndex()
		hook.Remove( "EntityTakeDamage", damageHook )

		local npc = self.ChaserNPC
		if IsValid( npc ) then
			if WonderWeapons.HasStatus( npc, "NPC_Modify_CollisionGroup" ) then
				WonderWeapons.RemoveStatus( npc, "NPC_Modify_CollisionGroup" )
			end

			local enemy = npc:GetEnemy()
			if IsValid( enemy ) and enemy == entity then
				npc:ClearSchedule()
				npc:ClearEnemyMemory( npc:GetEnemy() )
				npc:SetSchedule( math.random( 3 ) == 1 and SCHED_RELOAD or ( math.random( 2 ) == 1 and SCHED_ALERT_SCAN or SCHED_MOVE_AWAY ) )
			end
		end

		if not self:GetKicked() and entity:GetInternalVariable("m_lifeState") == 0 then
			entity:EmitSound( "TFA_BO3_JGB.ZMB.UnShrink" )

			ParticleEffectAttach( entity:WaterLevel() > 2 and "bo3_jgb_unshrink_uw" or "bo3_jgb_unshrink", PATTACH_POINT_FOLLOW, entity, self.HeadAttachment or 1 )
		end
	end,

	// Custom functions

	MaxGibCount = 1,

	SetKicked = function( self, bool )
		self.Kicked = bool
	end,

	GetKicked = function( self )
		return tobool( self.Kicked )
	end,

	SetSquished = function( self, bool )
		self.Squished = bool
	end,

	GetSquished = function( self )
		return tobool( self.Squished )
	end,

	NPCChaseCheck = function( self )
		local npc = self.Assistor
		local entity = self:GetEntity()

		if not IsValid( npc ) or not npc:IsNPC() then return end
		if not IsValid( entity ) then return end

		npc:ClearSchedule()
		npc:ClearEnemyMemory( npc:GetEnemy() )
		npc:SetEnemy( entity )

		self.ChaserNPC = npc
	end,

	Kick = function(self, trace)
		local entity = self:GetEntity()
		local attacker = self:GetAttacker()
		local inflictor = self:GetInflictor()

		local fx = EffectData()
		fx:SetStart( trace.StartPos )
		fx:SetOrigin( trace.HitPos )
		fx:SetEntity( trace.Entity )
		fx:SetSurfaceProp( trace.SurfaceProps )
		fx:SetHitBox( trace.HitBox )

		util.Effect( "Impact", fx )

		if entity.GetBloodColor and WonderWeapons.ParticleByBloodColor[ entity:GetBloodColor() ] then
			ParticleEffect( WonderWeapons.ParticleByBloodColor[ entity:GetBloodColor() ], trace.HitPos, trace.HitNormal:Angle() )
		end

		entity:EmitSound("TFA_BO3_JGB.ZMB.Kick")
		entity:SetGroundEntity(nil)

		self:SetKicked( true )
		self.CollisionIgnoreWorld = false

		local aim = ( entity:GetPos() - attacker:GetPos() ):GetNormalized()
		local mult = math.Clamp( ( attacker:GetVelocity():Length() / ( attacker:IsNPC() and ( attacker:GetSequenceGroundSpeed( attacker:GetMovementSequence() ) ) or attacker:GetWalkSpeed() ) ), 1, 3 )

		if entity:IsNextBot() then
			local forward = attacker:GetForward() * math.random( 8000, 14000 )
			local side = aim * 8000
			local up = entity:GetUp() * math.random( 8000, 14000 )

			local damageinfo = DamageInfo()
			damageinfo:SetDamage( entity:Health() + 666 )
			damageinfo:SetDamageType( DMG_MISSILEDEFENSE )
			damageinfo:SetAttacker( attacker )
			damageinfo:SetInflictor( inflictor )
			damageinfo:SetDamageForce( ( up * mult ) + ( side * mult ) + ( forward * mult ) )
			damageinfo:SetDamagePosition( trace.HitPos or entity:WorldSpaceCenter() )
			damageinfo:SetReportedPosition( self:GetPos() )

			if entity.IsDrGNextbot and entity.RagdollOnDeath and util.IsValidRagdoll( entity:GetModel() ) then
				entity:DrG_RagdollDeath( damageinfo )
			else
				entity:TakeDamageInfo( damageinfo )
			end

			self:SendHitMarker( attacker, inflictor, entity, damageinfo, trace )

			if nzombies and self.Assistor and self:GetAttacker() ~= self.Assistor and self.Assistor:IsPlayer() then
				local helper = self.Assistor

				timer.Simple( engine.TickInterval(), function()
					if not IsValid( helper ) then return end
					helper:GivePoints(10)
				end )
			end

			if IsValid( attacker ) and attacker:IsPlayer() then
				WonderWeapons.NotifyAchievement( "BO3_Shrinkray_Variety", attacker, entity )
			end

			local headbone = entity:LookupBone( "ValveBiped.Bip01_Head1" ) or entity:LookupBone( "j_head" )
			if headbone then
				entity:ManipulateBoneScale( headbone, Vector( 1, 1, 1 ) )
			end

			return
		end

		if attacker:IsNPC() and entity:IsPlayer() then
			WonderWeapons.GiveStatus( attacker, "NPC_Modify_CollisionGroup", self:GetEndTime() - CurTime(), COLLISION_GROUP_DEBRIS_TRIGGER )
		end

		//ent:SetLocalAngularVelocity( Angle( -speed * mult, math.random( -20, 20 ), 0 ) )

		entity:SetGroundEntity( nil )
		entity:SetPos( entity:GetPos() + vector_up )
		entity:SetVelocity( ( entity:GetUp() * 250 ) * mult + ( aim * 500 ) * mult )
	end,

	EntityTakeDamage = function( self, entity, damageinfo )
		if IsValid( entity ) and damageinfo:GetDamage() >= entity:Health() then
			WonderWeapons.DoDeathEffect( entity, "Remove_Ragdoll" )
		end
	end,

	Squish = function( self, trace )
		local entity = self:GetEntity()
		local attacker = self:GetAttacker()
		local inflictor = self:GetInflictor()

		self:SetSquished( true )

		local damageinfo = DamageInfo()
		damageinfo:SetDamage( entity:Health() + 666 )
		damageinfo:SetAttacker( IsValid( attacker ) and attacker or entity )
		damageinfo:SetInflictor( IsValid( inflictor ) and inflictor or entity )
		damageinfo:SetDamageType( nzombies and DMG_MISSILEDEFENSE or DMG_REMOVENORAGDOLL )
		damageinfo:SetDamagePosition( WonderWeapons.BodyTarget( entity, IsValid( attacker ) and attacker:GetPos() or entity:GetPos(), true ) )
		damageinfo:SetDamageForce( vector_up * -40000 )
		damageinfo:SetReportedPosition( IsValid( attacker ) and attacker:GetPos() or entity:GetPos())

		entity:EmitSound( "TFA_BO3_JGB.ZMB.Squish" )
		entity:SetHealth( 1 )

		//WonderWeapons.DoDeathEffect( entity, "Remove_Ragdoll" )

		entity:TakeDamageInfo( damageinfo )

		if IsValid( attacker ) and attacker:IsPlayer() then
			WonderWeapons.NotifyAchievement( "BO3_Shrinkray_Variety", attacker, entity )

			self:SendHitMarker( attacker, inflictor, entity, damageinfo, trace )
		end

		if nzombies and IsValid( attacker ) and self.Assistor and attacker ~= self.Assistor and self.Assistor:IsPlayer() then
			self.Assistor:GivePoints( 10 )
		end

		local BloodColor = entity.GetBloodColor and entity:GetBloodColor() or DONT_BLEED

		for i = 1, math.random( self.MaxGibCount ) do
			local vecVelocity = Vector( math.random( -100, 100 ), math.random( -100, 100 ), 150 )
			local vecAngleVelocity = Vector( 0, math.random( 400, 1200 ), 0 )
			local randomFacingAngle = Angle(0, math.random( -180, 180 ), 0)

			if trace and trace.Hit then
				vecVelocity = trace.HitNormal * 150 + VectorRand( -100, 100 )
			end

			WonderWeapons.CreateHorrorGib( entity:WorldSpaceCenter(), randomFacingAngle, vecVelocity * math.Rand( 1, i ), vecAngleVelocity, math.Rand( 3, 4 ), BloodColor )
		end

		if trace and trace.Hit then
			local fx = EffectData()
			fx:SetStart( trace.StartPos )
			fx:SetOrigin( trace.HitPos )
			fx:SetEntity( trace.Entity )
			fx:SetSurfaceProp( trace.SurfaceProps )
			fx:SetHitBox( trace.HitBox )

			util.Effect( "Impact", fx )

			local position = WonderWeapons.BodyTarget( entity, entity:GetPos() )

			for i=1, 24 do
				local bloodtrace = {}
				local direction = VectorRand():GetNormalized()

				util.TraceLine({
					start = position,
					endpos = 144 * direction + position,
					mask = bit.bor(MASK_SHOT, bit.bnot(CONTENTS_HITBOX)),
					filter = entity,
					output = bloodtrace
				})

				if bloodtrace.Hit then
					timer.Simple( 0.25 * bloodtrace.Fraction, function()
						if BloodColor ~= nil then
							if BloodColor ~= DONT_BLEED and WonderWeapons.ParticleByBloodColor[ BloodColor ] then
								ParticleEffect(WonderWeapons.ParticleByBloodColor[ BloodColor], bloodtrace.HitPos + bloodtrace.HitNormal*4, bloodtrace.HitNormal:Angle())

								util.Decal(WonderWeapons.DecalByBloodColor[ BloodColor ], bloodtrace.HitPos, bloodtrace.HitPos + bloodtrace.Normal*32)
							end
						else
							ParticleEffect("blood_impact_red_01", bloodtrace.HitPos + bloodtrace.HitNormal*4, bloodtrace.HitNormal:Angle())

							util.Decal("Blood", bloodtrace.HitPos, bloodtrace.HitPos + bloodtrace.Normal*32)
						end
					end )
				end
			end
		end

		if BloodColor and WonderWeapons.ParticleByBloodColor[ BloodColor ] then
			ParticleEffect( WonderWeapons.ParticleByBloodColor[ BloodColor ], entity:EyePos(), entity:EyeAngles() )
		end

		self:SetKicked( true )
		self.CollisionIgnoreWorld = false

		self:Remove()
	end
})

WonderWeapons.AddStatusEffect("BO3_Wavegun_Cook", {
	ShouldCollide = false,

	CollisionGroupOverride = COLLISION_GROUP_IN_VEHICLE,

	ShouldFreeze = true,

	BlockAttack = true,

	DoFirePanic = true,

	Initialize = function( self, entity, duration, attacker, inflictor )
		self:SetAttacker( attacker )
		self:SetInflictor( inflictor )

		local BloodName = WonderWeapons.GetBloodName( entity )

		local effectsByBloodName = {
			[WonderWeapons.BLOOD_RED] = "bo3_wavegun_eyes",
			[WonderWeapons.BLOOD_ZOMBIE] = "bo3_wavegun_eyes_zomb",
			[WonderWeapons.BLOOD_ALIEN] = "bo3_wavegun_eyes_yellow",
			[WonderWeapons.BLOOD_ACID] = "bo3_wavegun_eyes_acid",
			[WonderWeapons.BLOOD_CYBORG] = "bo3_wavegun_eyes_blue",
			[WonderWeapons.BLOOD_SYNTH] = "bo3_wavegun_eyes_synth",
			[WonderWeapons.BLOOD_MECH] = "bo3_wavegun_eyes_oil",
		}

		local dontBleeds = {
			[WonderWeapons.DONT_BLEED] = true,
		}

		if BloodName then
			if not dontBleeds[ BloodName ] then
				self.EyeBloodEffect = effectsByBloodName[ BloodName ] or "bo3_wavegun_eyes"
			end
		else
			self.EyeBloodEffect = "bo3_wavegun_eyes"
		end

		if CLIENT then return end

		timer.Simple( math.Rand(0, 0.5), function()
			if not IsValid( entity ) then return end

			entity:EmitSound( "TFA_BO3_WAVEGUN.Microwave.Cook" )
		end )
	end,

	Draw = function( self, entity, visibility )
		if self.EyeBloodEffect and ( self.MouthAttachment or self.HeadAttachment ) then
			entity:AddDrawCallParticle( self.EyeBloodEffect or "bo3_wavegun_eyes", PATTACH_POINT_FOLLOW, self.MouthAttachment or self.HeadAttachment, entity:Alive(), "BO3_Wavegun_Cook" )
		end

		if self.EyeBloodEffect and self.RightEyeAttachment and self.LeftEyeAttachment then
			entity:AddDrawCallParticle( self.EyeBloodEffect or "bo3_wavegun_eyes", PATTACH_POINT_FOLLOW, self.LeftEyeAttachment, entity:Alive(), "BO3_Wavegun_Cook_Eye_L" )
			entity:AddDrawCallParticle( self.EyeBloodEffect or "bo3_wavegun_eyes", PATTACH_POINT_FOLLOW, self.RightEyeAttachment, entity:Alive(), "BO3_Wavegun_Cook_Eye_R" )
		end
	end,

	OnStatusEnd = function( self, entity )
		WonderWeapons.StopDrawParticle( entity, "BO3_Wavegun_Cook_Eye_L", false )
		WonderWeapons.StopDrawParticle( entity, "BO3_Wavegun_Cook_Eye_R", false )
		WonderWeapons.StopDrawParticle( entity, "BO3_Wavegun_Cook", false )

		if CLIENT then
			if IsValid(entity) and entity:IsRagdoll() then
				WonderWeapons.DoDeathEffect( entity, "BO3_Wavegun_Cook" )
			end
			return
		end

		self:InflictDamage( entity )
	end,

	OnRemove = function( self, entity )
		WonderWeapons.StopDrawParticle( entity, "BO3_Wavegun_Cook_Eye_L", false )
		WonderWeapons.StopDrawParticle( entity, "BO3_Wavegun_Cook_Eye_R", false )
		WonderWeapons.StopDrawParticle( entity, "BO3_Wavegun_Cook", false )
	end,

	// Custom functions

	EntityTakeDamage = function( self, entity, damageinfo )
		if IsValid( entity ) and damageinfo:GetDamage() >= entity:Health() then
			WonderWeapons.DoDeathEffect( entity, "BO3_Wavegun_Cook" )
		end
	end,

	InflictDamage = function( self, entity )
		local attacker = self:GetAttacker()
		local inflictor = self:GetInflictor()

		local force = ( vector_up*math.random(800, 1200) + VectorRand():GetNormalized() )

		local damage = DamageInfo()
		damage:SetAttacker( IsValid(attacker) and attacker or entity )
		damage:SetInflictor( IsValid(inflictor) and inflictor or entity )
		damage:SetDamage( entity:Health() + 666 )
		damage:SetDamageType( nzombies and DMG_ENERGYBEAM or bit.bor( DMG_ENERGYBEAM, DMG_NEVERGIB ) )
		damage:SetDamagePosition( WonderWeapons.BodyTarget( entity, entity.GetShootPos and entity:GetShootPos() or entity:EyePos(), true ) )
		damage:SetDamageForce( entity.WaterLevel and entity:WaterLevel() > 2 and vector_up*-1 or force )
		damage:SetReportedPosition( entity:GetPos() )

		if entity:IsNPC() and entity:Alive() and damage:GetDamage() >= entity:Health() then
			entity:SetCondition( COND.NPC_UNFREEZE )
		end

		//WonderWeapons.DoDeathEffect( entity, "BO3_Wavegun_Cook" )

		if entity:IsNPC() or entity:IsPlayer() or entity:IsNextBot() then
			entity:SetHealth(1)
		end

		entity:TakeDamageInfo(damage)

		self:SendHitMarker( attacker, inflictor, entity, damage )
	end,
})

WonderWeapons.AddStatusEffect("BO3_Skullgun_Stun", {
	ShouldCollide = false,

	ShouldFreeze = true,

	BlockAttack = true,

	DoFirePanic = true,

	Initialize = function( self, entity, duration )
		if CLIENT then return end

		entity:EmitSound("TFA_BO3_SKULL.Breathe")
	end,

	Draw = function( self, entity, visibility )
		if self.RightEyeAttachment and self.LeftEyeAttachment then
			entity:AddDrawCallParticle( "bo3_skull_stun", PATTACH_POINT_FOLLOW, self.LeftEyeAttachment, entity:Alive(), "BO3_Skullgun_Stun_Eye_L" )
			entity:AddDrawCallParticle( "bo3_skull_stun", PATTACH_POINT_FOLLOW, self.RightEyeAttachment, entity:Alive(), "BO3_Skullgun_Stun_Eye_R" )
		end
		entity:AddDrawCallParticle( "bo3_skull_stun_halo", PATTACH_POINT_FOLLOW, self.HeadAttachment or 1, entity:Alive(), "BO3_Skullgun_Stun" )
	end,

	OnStatusEnd = function( self, entity )
		WonderWeapons.StopDrawParticle( entity, "BO3_Skullgun_Stun_Eye_L", false )
		WonderWeapons.StopDrawParticle( entity, "BO3_Skullgun_Stun_Eye_R", false )
		WonderWeapons.StopDrawParticle( entity, "BO3_Skullgun_Stun", false )
	end,

	OnRemove = function( self, entity )
		WonderWeapons.StopDrawParticle( entity, "BO3_Skullgun_Stun_Eye_L", false )
		WonderWeapons.StopDrawParticle( entity, "BO3_Skullgun_Stun_Eye_R", false )
		WonderWeapons.StopDrawParticle( entity, "BO3_Skullgun_Stun", false )
	end,
})

WonderWeapons.AddStatusEffect("BO3_Skullgun_Kill", {
	ShouldCollide = false,

	ShouldFreeze = true,

	BlockAttack = true,

	DoFirePanic = true,

	Initialize = function( self, entity, duration, attacker, inflictor, damage )
		self:SetAttacker( attacker )
		self:SetInflictor( inflictor )
		self:SetDamage( damage or 200 )

		if CLIENT then return end

		local hull_too_big = {
			[HULL_LARGE] = true,
			[HULL_LARGE_CENTERED] = true,
			[HULL_MEDIUM_TALL] = true,
		}

		self.finalpos = entity:GetPos() + vector_up*math.Rand(15,25)

		// entity is 'too big' to lift into the air
		if entity.GetHullType then
			if hull_too_big[entity:GetHullType()] then
				self.finalpos = nil
			else
				local colMins, colMaxs = entity:GetCollisionBounds()

				local maxX = math.max( math.abs( colMins[1] ), colMaxs[1] )
				local maxY = math.max( math.abs( colMins[2] ), colMaxs[2] )

				if ( ( ( maxX > 20 or maxY > 20 ) and colMaxs[3] > 36 ) or colMaxs[3] > 76 )  then
					self.finalpos = nil
				end
			end
		end

		if nzombies and entity:IsValidZombie() and entity.PlaySound then
			entity:PlaySound("weapons/tfa_bo3/skullgun/skull_scream_0"..math.random(0,3)..".wav", 80, math.random(95, 105), 0.5, 2)
		else
			if entity.GetHullType then
				if entity:GetHullType() == HULL_HUMAN then
					entity:EmitSound("TFA_BO3_SKULL.Scream")
				end
			else
				entity:EmitSound("TFA_BO3_SKULL.Scream")
			end
		end

		if entity:IsNPC() then
			entity:SetCondition( COND.FLOATING_OFF_GROUND )
		end
	end,

	Think = function( self, entity )
		if CLIENT then return end

		if self.finalpos and entity:IsNPC() then
			entity:SetGroundEntity( Entity(0) )
			entity:SetPos( LerpVector( FrameTime()*5, entity:GetPos(), self.finalpos ) )
		end

		local time = 1 + math.random(5)*0.1
		if self:GetEndTime() > ( self:GetStartTime() + time ) then
			self:InflictDamage( entity )
			self:Remove()
		end
	end,

	Draw = function( self, entity, visibility )
		if self.RightEyeAttachment and self.LeftEyeAttachment then
			entity:AddDrawCallParticle( "bo3_skull_kill", PATTACH_POINT_FOLLOW, self.LeftEyeAttachment, entity:Alive(), "BO3_Skullgun_Kill_Eye_L" )
			entity:AddDrawCallParticle( "bo3_skull_kill", PATTACH_POINT_FOLLOW, self.RightEyeAttachment, entity:Alive(), "BO3_Skullgun_Kill_Eye_R" )
		end
		if ( self.MouthAttachment or self.EyeAttachment ) then
			entity:AddDrawCallParticle( "bo3_skull_kill", PATTACH_POINT_FOLLOW, self.MouthAttachment or self.EyeAttachment, entity:Alive(), "BO3_Skullgun_Kill" )
		end
	end,

	OnStatusEnd = function( self, entity )
		WonderWeapons.StopDrawParticle( entity, "BO3_Skullgun_Kill_Eye_L", false )
		WonderWeapons.StopDrawParticle( entity, "BO3_Skullgun_Kill_Eye_R", false )
		WonderWeapons.StopDrawParticle( entity, "BO3_Skullgun_Kill", false )
	end,

	OnRemove = function( self, entity )
		WonderWeapons.StopDrawParticle( entity, "BO3_Skullgun_Kill_Eye_L", false )
		WonderWeapons.StopDrawParticle( entity, "BO3_Skullgun_Kill_Eye_R", false )
		WonderWeapons.StopDrawParticle( entity, "BO3_Skullgun_Kill", false )

		if CLIENT then return end

		if entity:IsNPC() then
			entity:ClearCondition( COND.FLOATING_OFF_GROUND )
		end
	end,

	InflictDamage = function( self, entity )
		local attacker = self:GetAttacker()
		local inflictor = self:GetInflictor()

		entity:EmitSound( "TFA_BO3_GENERIC.Gib" )
		entity:EmitSound( "TFA_BO3_GENERIC.Lfe" )

		local damage = DamageInfo()
		damage:SetAttacker( IsValid(attacker) and attacker or entity )
		damage:SetInflictor( IsValid(inflictor) and inflictor or entity )
		damage:SetDamage( ( sv_true_damage and sv_true_damage:GetBool() or nzombies ) and entity:Health() + 666 or self:GetDamage() )
		damage:SetDamageType( DMG_ENERGYBEAM )
		damage:SetDamagePosition( WonderWeapons.BodyTarget( entity, entity.GetShootPos and entity:GetShootPos() or entity:EyePos(), true, math.random(6) == 1 ) )
		damage:SetDamageForce( entity:GetUp()*200 )
		damage:SetReportedPosition( entity:GetPos() )

		if entity:IsNPC() and entity:Alive() and damage:GetDamage() >= entity:Health() then
			entity:SetCondition( COND.NPC_UNFREEZE )
		end

		WonderWeapons.DoDeathEffect( entity, "BO3_Wavegun_Pop" )

		if nzombies and (entity.NZBossType or string.find(entity:GetClass(), "zombie_boss")) then
			damage:SetDamage(math.max(1600, entity:GetMaxHealth() / 6))
		else
			entity:SetHealth(1)
		end

		entity:TakeDamageInfo(damage)

		self:SendHitMarker( attacker, inflictor, entity, damage )
	end,
})

WonderWeapons.AddStatusEffect("BO3_WidowsWine_Web", {
	ShouldCollide = false,

	ShouldFreeze = true,

	BlockAttack = true,

	DoFirePanic = true,

	Initialize = function( self, entity, duration, attacker )
		self:SetAttacker( attacker )

		if CLIENT then return end
		self.nextattack = CurTime() + math.Rand(1, 2)

		entity:EmitSound("TFA_BO3_SPIDERNADE.Loop")
	end,

	Think = function( self, entity )
		if CLIENT then return end

		if self.nextattack == nil or self.nextattack < CurTime() then
			self:InflictDamage( entity )
			self.nextattack = CurTime() + math.Rand(1.5, 3)
		end
	end,

	Draw = function( self, entity, visibility )
		entity:AddDrawCallParticle( "bo3_spidernade_zomb", PATTACH_POINT_FOLLOW, self.ChestAttachment or 1, entity:Alive(), "BO3_WidowsWine_Web" )
	end,

	OnStatusEnd = function( self, entity )
		WonderWeapons.StopDrawParticle( entity, "BO3_WidowsWine_Web", false )

		entity:StopSound("TFA_BO3_SPIDERNADE.Loop")

		entity:EmitSound("TFA_BO3_SPIDERNADE.End")
	end,

	OnRemove = function( self, entity )
		WonderWeapons.StopDrawParticle( entity, "BO3_WidowsWine_Web", false )

		entity:StopSound("TFA_BO3_SPIDERNADE.Loop")
	end,

	InflictDamage = function( self, entity )
		if CLIENT then return end

		local attacker = self:GetAttacker()

		local damage = DamageInfo()
		damage:SetDamage( 10 )
		damage:SetDamageType( DMG_RADIATION )
		damage:SetAttacker( IsValid(attacker) and attacker or entity )
		damage:SetDamageForce( vector_up )
		damage:SetDamagePosition( WonderWeapons.BodyTarget( entity, IsValid( attacker ) and ( attacker.GetShootPos and attacker:GetShootPos() or attacker:EyePos() ) or entity:GetPos() ) )
		damage:SetReportedPosition( entity:GetPos() )

		if entity:IsNPC() and entity:Alive() and damage:GetDamage() >= entity:Health() then
			entity:SetCondition( COND.NPC_UNFREEZE )
		end

		entity:TakeDamageInfo( damage )

		if IsValid( attacker ) and attacker:IsPlayer() then
			local inflictor = attacker:GetActiveWeapon()

			self:SendHitMarker( attacker, inflictor, entity, damage )
		end
	end,
})

WonderWeapons.AddStatusEffect("BO3_Ragnarok_Lift_Boss", {
	ShouldCollide = false,

	ShouldFreeze = true,

	BlockAttack = true,
})

WonderWeapons.AddStatusEffect("BO3_KT4_Infection", {
	ShouldCollide = false,

	Initialize = function( self, entity, duration, attacker, inflictor, damage, upgraded )
		self:SetAttacker( attacker )
		self:SetInflictor( inflictor )
		self:SetDamage( damage or 100 )
		self:SetUpgraded( upgraded )

		if CLIENT then return end

		self:ModifyMoveSpeed( 0, duration )

		entity:EmitSound("TFA_BO3_MIRG.Spore.Infect")
		entity:EmitSound("TFA_BO3_MIRG.Spore.Grow")
	end,

	Draw = function( self, entity, visibility )
		entity:AddDrawCallParticle( self:GetUpgraded() and "bo3_mirg2k_zomb_2" or "bo3_mirg2k_zomb", PATTACH_POINT_FOLLOW, self.ChestAttachment or 1, entity:Alive(), "BO3_KT4_Infection" )
	end,

	OnStatusEnd = function( self, entity )
		WonderWeapons.StopDrawParticle( entity, "BO3_KT4_Infection", false )

		if CLIENT then return end

		self:InflictDamage( entity )

		self:Explode( entity )
	end,

	OnRemove = function( self, entity )
		WonderWeapons.StopDrawParticle( entity, "BO3_KT4_Infection", false )
	end,

	InflictDamage = function( self, entity )
		if CLIENT then return end

		entity:EmitSound("TFA_BO3_MIRG.Spore.Explode")

		ParticleEffect(self:GetUpgraded() and "bo3_mirg2k_explode_2" or "bo3_mirg2k_explode", entity:WorldSpaceCenter(), Angle(0,0,0))

		local attacker = self:GetAttacker()
		local inflictor = self:GetInflictor()

		local damage = DamageInfo()
		damage:SetDamageType(DMG_RADIATION)
		damage:SetAttacker(IsValid(attacker) and attacker or entity)
		damage:SetInflictor(IsValid(inflictor) and inflictor or entity)
		damage:SetDamage( ( sv_true_damage and sv_true_damage:GetBool() or nzombies ) and entity:Health() + 666 or self:GetDamage())
		damage:SetDamageForce(vector_up)
		damage:SetDamagePosition(WonderWeapons.BodyTarget(entity, entity:GetPos(), true))
		damage:SetReportedPosition(entity:GetPos())

		if nzombies and (entity.NZBossType or string.find(entity:GetClass(), "zombie_boss")) then
			damage:SetDamage(math.max(1200, entity:GetMaxHealth() / 12))
		end

		if entity:IsNPC() and entity:Alive() and damage:GetDamage() >= entity:Health() then
			entity:SetCondition(COND.NPC_UNFREEZE)
		end

		entity.MirgSporeKilled = true

		entity:TakeDamageInfo(damage)

		entity.MirgSporeKilled = nil

		self:SendHitMarker( attacker, inflictor, entity, damage )
	end,

	Explode = function( self, entity )
		if CLIENT then return end

		local attacker = self:GetAttacker()
		local inflictor = self:GetInflictor()

		local damage = DamageInfo()
		damage:SetAttacker(IsValid(attacker) and attacker or entity)
		damage:SetInflictor(IsValid(inflictor) and inflictor or entity)
		damage:SetDamageType(nzombies and DMG_RADIATION or bit.bor(DMG_RADIATION, DMG_BLAST))
		damage:SetReportedPosition(entity:GetPos())

		for k, v in pairs(ents.FindInSphere(entity:GetPos(), self:GetUpgraded() and 90 or 60)) do
			if (v:IsNPC() or v:IsNextBot() or v:IsPlayer()) then
				if v == entity then continue end
				if v:IsPlayer() then continue end

				local mStatus = WonderWeapons.GetStatus(v, "BO3_KT4_Infection")
				if mStatus then
					if self.ChainReact then
						mStatus.ChainReact = true
						mStatus:SetEndTime(math.min(mStatus:GetEndTime(), CurTime() + math.Rand(0.2,0.5)))
					end
					continue
				end

				if v:Health() <= 0 then continue end

				v:EmitSound("TFA_BO3_MIRG.ImpactSwt")

				ParticleEffect(self:GetUpgraded() and "bo3_mirg2k_explode_2" or "bo3_mirg2k_explode", v:WorldSpaceCenter(), angle_zero)

				damage:SetDamage(self:GetDamage())

				if nzombies and (v.NZBossType or v.IsMooBossZombie or string.find(v:GetClass(), "zombie_boss")) then
					damage:SetDamage(math.max(1200, v:GetMaxHealth()/12))
				end

				damage:SetDamageForce(v:GetUp()*8000 + (v:GetPos() - entity:GetPos()):GetNormalized()*6000)
				damage:SetDamagePosition(WonderWeapons.BodyTarget(v, entity:GetPos(), true))

				if v:IsNPC() and v:Alive() and damage:GetDamage() >= v:Health() then
					v:SetCondition(COND.NPC_UNFREEZE)
				end

				v:TakeDamageInfo(damage)

				self:SendHitMarker( attacker, inflictor, entity, damage )
			end
		end
	end,
})

WonderWeapons.AddStatusEffect("BO3_Portal_Pull", {
	ShouldCollide = false,

	CollisionGroupOverride = COLLISION_GROUP_WORLD,

	ShouldFreeze = true,

	Initialize = function( self, entity, duration, attacker, inflictor, vector )
		self:SetAttacker( attacker )
		self:SetInflictor( inflictor )
		self:SetEndPos( vector )
	end,

	Think = function( self, entity )
		if CLIENT then return end

		local fraction = 1 - math.Clamp((self:GetEndTime() - CurTime()) / self:GetDuration(), 0, 1)
		local rate = fraction * ( self:GetDuration() * engine.TickInterval() ) * 2

		if entity:IsNPC() then
			entity:SetGroundEntity(Entity(0))
			entity:SetPos(LerpVector(rate, entity:GetPos(), self:GetEndPos()))
		end

		if entity:IsNextBot() then
			entity:SetGroundEntity(Entity(0))

			if entity:GetPos().z < self:GetEndPos().z then
				entity:SetPos(LerpVector(fraction, entity:GetPos(), entity:GetPos() + entity:OBBCenter()))
			end

			entity:SetPos(LerpVector(rate, entity:GetPos(), self:GetEndPos()))
			entity.loco:SetVelocity((self:GetEndPos() - entity:GetPos()):GetNormalized() * 30)
		end

		if entity:GetPos():DistToSqr(self:GetEndPos()) <= 576 then
			self:InflictDamage( entity )
			self:Remove()
			return false
		end
	end,

	OnStatusEnd = function( self, entity )
		if CLIENT then return end

		self:InflictDamage( entity )
	end,

	OnRemove = function( self, entity )
	end,

	SetEndPos = function( self, vector )
		self.EndPos = vector
	end,

	GetEndPos = function( self )
		return self.EndPos
	end,

	InflictDamage = function( self, entity )
		if CLIENT then return end

		entity:EmitSound("TFA_BO3_IDGUN.Portal.CrushEnd")

		local attacker = self:GetAttacker()
		local inflictor = self:GetInflictor()

		local damage = DamageInfo()
		damage:SetDamageType(DMG_REMOVENORAGDOLL)
		damage:SetAttacker(IsValid(attacker) and attacker or entity)
		damage:SetInflictor(IsValid(inflictor) and inflictor or entity)
		damage:SetDamage(entity:Health() + 666)
		damage:SetDamageForce(vector_up)
		damage:SetDamagePosition(WonderWeapons.BodyTarget(entity, entity:GetPos(), true))
		damage:SetReportedPosition(self:GetEndPos())

		if nzombies and (entity.NZBossType or entity.IsMooBossZombie or entity.IsMooMiniBoss) then
			damage:SetDamage(math.max(1200, entity:GetMaxHealth() / 12))
		else
			entity:SetHealth(1)
		end

		if entity:IsNPC() and entity:Alive() and damage:GetDamage() >= entity:Health() then
			entity:SetCondition(COND.NPC_UNFREEZE)
		end

		WonderWeapons.DoDeathEffect( entity, "Remove_Ragdoll" )

		entity:TakeDamageInfo(damage)

		self:SendHitMarker( attacker, inflictor, entity, damage )
	end,
})
