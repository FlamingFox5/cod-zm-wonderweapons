//-------------------------------------------------------------
// Death Effects
//-------------------------------------------------------------

local WonderWeapons = TFA.WonderWeapon

local EffectType = WonderWeapons.DeathEffects.Types

local nzombies = engine.ActiveGamemode() == "nzombies"
local sv_damage_world = GetConVar("sv_tfa_bo3ww_environmental_damage")

local vector_down_4 = Vector(0, 0, -4)

WonderWeapons.AddDeathEffect("Remove_Ragdoll", {
	Type = EffectType.ON_RAGDOLL,

	IsValid = function( self, entity )
		return false
	end,

	OnEntity = function( self, entity, duration, upgraded )
	end,

	OnServerRagdoll = function( self, ragdoll, entity, duration )
		WonderWeapons.SafeRemoveRagdoll( ragdoll, duration )
	end,

	OnClientRagdoll = function( self, ragdoll, entity, duration )
		WonderWeapons.SafeRemoveRagdoll( ragdoll, duration )
	end,

	OnRemove = function( self, entity, destroy )
	end,
})

WonderWeapons.AddDeathEffect("BloodyGib_Ragdoll", {
	Type = EffectType.ON_RAGDOLL,

	IsValid = function( self, entity )
		return false
	end,

	OnEntity = function( self, entity, duration, upgraded )
	end,

	OnServerRagdoll = function( self, ragdoll, entity, duration )
		local BloodColor = WonderWeapons.GetBloodName( entity ) or entity.GetBloodColor and entity:GetBloodColor()

		local ImpactEffect = WonderWeapons.ParticleByBloodColor[ BloodColor ]

		if ImpactEffect then
			for i = 0, entity:GetHitBoxCount( 0 ) - 1 do
				local bone = entity:GetHitBoxBone( i, 0 )
				if bone then
					local matrix = entity:GetBoneMatrix( bone )
					if matrix then
						local pos = matrix:GetTranslation()
						local ang = matrix:GetAngles()

						ParticleEffect(ImpactEffect, pos, ang)
					end
				end
			end

			WonderWeapons.DoRadialBloodImpact( ragdoll:GetPos(), 144, 12, ( BloodColor ), bit.bor( MASK_SHOT, bit.bnot( CONTENTS_HITBOX ) ), COLLISION_GROUP_NONE, { entity, ragdoll } )
			WonderWeapons.GibRagdoll( ragdoll )
		end

		WonderWeapons.SafeRemoveRagdoll( ragdoll )
	end,

	OnClientRagdoll = function( self, ragdoll, entity, duration )
		local BloodColor = WonderWeapons.GetBloodName( entity ) or entity.GetBloodColor and entity:GetBloodColor()

		local ImpactEffect = WonderWeapons.ParticleByBloodColor[ BloodColor ]

		if ImpactEffect then
			for i = 0, entity:GetHitBoxCount( 0 ) - 1 do
				local bone = entity:GetHitBoxBone( i, 0 )
				if bone then
					local matrix = entity:GetBoneMatrix( bone )
					if matrix then
						local pos = matrix:GetTranslation()
						local ang = matrix:GetAngles()

						ParticleEffect(ImpactEffect, pos, ang)
					end
				end
			end

			WonderWeapons.DoRadialBloodImpact( ragdoll:GetPos(), 144, 12, ( BloodColor ), bit.bor( MASK_SHOT, bit.bnot( CONTENTS_HITBOX ) ), COLLISION_GROUP_NONE, { entity, ragdoll } )
			WonderWeapons.GibRagdoll( ragdoll )
		end

		WonderWeapons.SafeRemoveRagdoll( ragdoll )
	end,

	OnRemove = function( self, entity, destroy )
	end,
})

WonderWeapons.AddDeathEffect("BO3_Wunderwaffe", {
	Type = bit.bor( EffectType.ON_DEATH, EffectType.ON_RAGDOLL ),

	IsValid = function( self, entity )
		return entity.GetDrawCallParticle and IsValid( entity:GetDrawCallParticle( "BO3_Wunderwaffe" ) )
	end,

	OnEntity = function( self, entity, duration, upgraded, headshot )
		upgraded = tobool(upgraded)
		headshot = tobool(headshot)

		local isCharacter = entity:IsNPC() or entity:IsNextBot() or entity:IsPlayer() or entity:IsRagdoll()
		if isCharacter then
			entity:EmitSound("TFA_BO3_WAFFE.Sizzle")
		end

		local eyeR, eyeL = WonderWeapons.GetEyesAttachment( entity )
		local bodyAtt = WonderWeapons.GetChestAttachment( entity )
		local headAtt = WonderWeapons.GetHeadAttachment( entity )

		local finalAtt = !headshot and ( bodyAtt ~= nil and bodyAtt or headAtt ) or ( headAtt ~= nil and headAtt or bodyAtt )

		entity:AddDrawCallParticle( upgraded and "bo3_waffe_electrocute_2" or "bo3_waffe_electrocute", PATTACH_POINT_FOLLOW, finalAtt or 1, true, "BO3_Wunderwaffe" )

		if bodyAtt then
			entity:AddDrawCallParticle( upgraded and "bo3_waffe_electrocute_flare_2" or "bo3_waffe_electrocute_flare", PATTACH_POINT_FOLLOW, finalAtt, true, "BO3_Wunderwaffe_Flare" )
		end

		if nzombies and entity:IsValidZombie() then
			if not entity.IsMooSpecialZombie and ( not ent.GetDecapitated or not ent:GetDecapitated() ) then
				entity:AddDrawCallParticle( upgraded and "bo3_waffe_eyes_2" or "bo3_waffe_eyes", PATTACH_POINT_FOLLOW, 3, true, "BO3_Wunderwaffe_Eye_L" )
				entity:AddDrawCallParticle( upgraded and "bo3_waffe_eyes_2" or "bo3_waffe_eyes", PATTACH_POINT_FOLLOW, 4, true, "BO3_Wunderwaffe_Eye_R" )
			end
		elseif isnumber( eyeR ) and isnumber( eyeL ) then
			entity:AddDrawCallParticle( upgraded and "bo3_waffe_eyes_2" or "bo3_waffe_eyes", PATTACH_POINT_FOLLOW, eyeL, true, "BO3_Wunderwaffe_Eye_L" )
			entity:AddDrawCallParticle( upgraded and "bo3_waffe_eyes_2" or "bo3_waffe_eyes", PATTACH_POINT_FOLLOW, eyeR, true, "BO3_Wunderwaffe_Eye_R" )
		else
			local eye = entity:LookupAttachment( "eye" )
			if isnumber( eye ) and eye > 0 then
				entity:AddDrawCallParticle( upgraded and "bo3_waffe_eyes_2" or "bo3_waffe_eyes", PATTACH_POINT_FOLLOW, eye, true, "BO3_Wunderwaffe_Eye" )
			end
		end

		if isCharacter then
			entity:AddDrawCallParticle( upgraded and "bo3_waffe_ground_2" or "bo3_waffe_ground", PATTACH_ABSORIGIN_FOLLOW, 1, true, "BO3_Wunderwaffe_Ground" )
		end
	end,

	OnServerRagdoll = function( self, ragdoll, entity, duration, upgraded, headshot )
		entity:StopSound("TFA_BO3_WAFFE.Sizzle")
		ragdoll:EmitSound("TFA_BO3_WAFFE.Sizzle")
	end,

	OnServerRagdoll_Client = function( self, ragdoll, entity, duration, upgraded, headshot )
		upgraded = tobool(upgraded)
		headshot = tobool(headshot)

		entity:StopSound("TFA_BO3_WAFFE.Sizzle")

		local bodyAtt = WonderWeapons.GetChestAttachment( ragdoll )
		local headAtt = WonderWeapons.GetHeadAttachment( ragdoll )

		local finalAtt = !headshot and ( bodyAtt ~= nil and bodyAtt or headAtt ) or ( headAtt ~= nil and headAtt or bodyAtt )

		ragdoll:AddDrawCallParticle( upgraded and "bo3_waffe_electrocute_2" or "bo3_waffe_electrocute", PATTACH_POINT_FOLLOW, finalAtt or 1, true, "BO3_Wunderwaffe" )

		if bodyAtt then
			ragdoll:AddDrawCallParticle( upgraded and "bo3_waffe_electrocute_flare_2" or "bo3_waffe_electrocute_flare", PATTACH_POINT_FOLLOW, finalAtt, true, "BO3_Wunderwaffe_Flare" )
		end

		local eyeR, eyeL = WonderWeapons.GetEyesAttachment( ragdoll )

		if nzombies and ragdoll:IsValidZombie() and not ragdoll.IsMooSpecialZombie then
			ragdoll:AddDrawCallParticle( upgraded and "bo3_waffe_eyes_2" or "bo3_waffe_eyes", PATTACH_POINT_FOLLOW, 3, true, "BO3_Wunderwaffe_Eye_L" )
			ragdoll:AddDrawCallParticle( upgraded and "bo3_waffe_eyes_2" or "bo3_waffe_eyes", PATTACH_POINT_FOLLOW, 4, true, "BO3_Wunderwaffe_Eye_R" )
		elseif isnumber( eyeR ) and isnumber( eyeL ) then
			ragdoll:AddDrawCallParticle( upgraded and "bo3_waffe_eyes_2" or "bo3_waffe_eyes", PATTACH_POINT_FOLLOW, eyeL, true, "BO3_Wunderwaffe_Eye_L" )
			ragdoll:AddDrawCallParticle( upgraded and "bo3_waffe_eyes_2" or "bo3_waffe_eyes", PATTACH_POINT_FOLLOW, eyeR, true, "BO3_Wunderwaffe_Eye_R" )
		else
			local eye = entity:LookupAttachment( "eye" )
			if isnumber( eye ) and eye > 0 then
				ragdoll:AddDrawCallParticle( upgraded and "bo3_waffe_eyes_2" or "bo3_waffe_eyes", PATTACH_POINT_FOLLOW, eye, true, "BO3_Wunderwaffe_Eye" )
			end
		end

		/*local mouthAtt = WonderWeapons.GetMouthAttachment( entity )
		if ( mouthAtt ) then
			ragdoll:AddDrawCallParticle(  upgraded and "bo3_waffe_eyes_2" or "bo3_waffe_eyes", PATTACH_POINT_FOLLOW, mouthAtt, true, "BO3_Wunderwaffe_Mouth" )
		end*/

		ragdoll:AddDrawCallParticle( upgraded and "bo3_waffe_ground_2" or "bo3_waffe_ground", PATTACH_ABSORIGIN_FOLLOW, 1, true, "BO3_Wunderwaffe_Ground" )
	end,

	OnClientRagdoll = function( self, ragdoll, entity, duration, upgraded, headshot )
		upgraded = tobool(upgraded)
		headshot = tobool(headshot)

		entity:StopSound("TFA_BO3_WAFFE.Sizzle")
		ragdoll:EmitSound("TFA_BO3_WAFFE.Sizzle")

		local bodyAtt = WonderWeapons.GetChestAttachment( ragdoll )
		local headAtt = WonderWeapons.GetHeadAttachment( ragdoll )

		local finalAtt = !headshot and ( bodyAtt ~= nil and bodyAtt or headAtt ) or ( headAtt ~= nil and headAtt or bodyAtt )

		ragdoll:AddDrawCallParticle( upgraded and "bo3_waffe_electrocute_2" or "bo3_waffe_electrocute", PATTACH_POINT_FOLLOW, finalAtt or 1, true, "BO3_Wunderwaffe" )

		if bodyAtt then
			ragdoll:AddDrawCallParticle( upgraded and "bo3_waffe_electrocute_flare_2" or "bo3_waffe_electrocute_flare", PATTACH_POINT_FOLLOW, finalAtt, true, "BO3_Wunderwaffe_Flare" )
		end

		local eyeR, eyeL = WonderWeapons.GetEyesAttachment( ragdoll )

		if nzombies and ragdoll:IsValidZombie() and not ragdoll.IsMooSpecialZombie then
			ragdoll:AddDrawCallParticle( upgraded and "bo3_waffe_eyes_2" or "bo3_waffe_eyes", PATTACH_POINT_FOLLOW, 3, true, "BO3_Wunderwaffe_Eye_L" )
			ragdoll:AddDrawCallParticle( upgraded and "bo3_waffe_eyes_2" or "bo3_waffe_eyes", PATTACH_POINT_FOLLOW, 4, true, "BO3_Wunderwaffe_Eye_R" )
		elseif isnumber( eyeR ) and isnumber( eyeL ) then
			ragdoll:AddDrawCallParticle( upgraded and "bo3_waffe_eyes_2" or "bo3_waffe_eyes", PATTACH_POINT_FOLLOW, eyeL, true, "BO3_Wunderwaffe_Eye_L" )
			ragdoll:AddDrawCallParticle( upgraded and "bo3_waffe_eyes_2" or "bo3_waffe_eyes", PATTACH_POINT_FOLLOW, eyeR, true, "BO3_Wunderwaffe_Eye_R" )
		else
			local eye = entity:LookupAttachment( "eye" )
			if isnumber( eye ) and eye > 0 then
				ragdoll:AddDrawCallParticle( upgraded and "bo3_waffe_eyes_2" or "bo3_waffe_eyes", PATTACH_POINT_FOLLOW, eye, true, "BO3_Wunderwaffe_Eye" )
			end
		end

		/*local mouthAtt = WonderWeapons.GetMouthAttachment( entity )
		if ( mouthAtt ) then
			ragdoll:AddDrawCallParticle(  upgraded and "bo3_waffe_eyes_2" or "bo3_waffe_eyes", PATTACH_POINT_FOLLOW, mouthAtt, true, "BO3_Wunderwaffe_Mouth" )
		end*/

		ragdoll:AddDrawCallParticle( upgraded and "bo3_waffe_ground_2" or "bo3_waffe_ground", PATTACH_ABSORIGIN_FOLLOW, 1, true, "BO3_Wunderwaffe_Ground" )
	end,

	OnRemove = function( self, entity, destroy )
		entity:StopSound("TFA_BO3_WAFFE.Sizzle")

		WonderWeapons.StopDrawParticle( entity, "BO3_Wunderwaffe_Eye_L", destroy )
		WonderWeapons.StopDrawParticle( entity, "BO3_Wunderwaffe_Eye_R", destroy )
		WonderWeapons.StopDrawParticle( entity, "BO3_Wunderwaffe_Eye", destroy )
		WonderWeapons.StopDrawParticle( entity, "BO3_Wunderwaffe_Ground", destroy )
		WonderWeapons.StopDrawParticle( entity, "BO3_Wunderwaffe_Flare", destroy )
		WonderWeapons.StopDrawParticle( entity, "BO3_Wunderwaffe_Mouth", destroy )
		WonderWeapons.StopDrawParticle( entity, "BO3_Wunderwaffe", destroy )
	end,
})

WonderWeapons.AddDeathEffect("BO3_Octobomb", {
	Type = bit.bor(EffectType.ON_DEATH, EffectType.ON_RAGDOLL),

	IsValid = function( self, entity )
		return entity.GetDrawCallParticle and IsValid( entity:GetDrawCallParticle( "BO3_Octobomb" ) )
	end,

	OnEntity = function( self, entity, duration, upgraded )
		entity:AddDrawCallParticle( tobool(upgraded) and "bo3_lilarnie_zomb_2" or "bo3_lilarnie_zomb", PATTACH_POINT_FOLLOW, 1, true, "BO3_Octobomb" )
	end,

	OnServerRagdoll_Client = function( self, ragdoll, entity, duration, upgraded )
		ragdoll:AddDrawCallParticle( tobool(upgraded) and "bo3_lilarnie_zomb_2" or "bo3_lilarnie_zomb", PATTACH_POINT_FOLLOW, 1, true, "BO3_Octobomb" )
	end,

	OnClientRagdoll = function( self, ragdoll, entity, duration, upgraded )
		ragdoll:AddDrawCallParticle( tobool(upgraded) and "bo3_lilarnie_zomb_2" or "bo3_lilarnie_zomb", PATTACH_POINT_FOLLOW, 1, true, "BO3_Octobomb" )
	end,

	OnRemove = function( self, entity, destroy )
		WonderWeapons.StopDrawParticle( entity, "BO3_Octobomb", destroy )
	end,
})

WonderWeapons.AddDeathEffect("BO3_Ragnarok", {
	Type = bit.bor(EffectType.ON_DEATH, EffectType.ON_RAGDOLL),
	
	IsValid = function( self, entity )
		return entity.GetDrawCallParticle and IsValid( entity:GetDrawCallParticle( "BO3_Ragnarok" ) )
	end,
	
	OnEntity = function( self, entity, duration )
		entity:AddDrawCallParticle( "bo3_dg4_zomb", PATTACH_POINT_FOLLOW, 1, true, "BO3_Ragnarok" )
	end,
	
	OnServerRagdoll_Client = function( self, ragdoll, entity, duration )
		ragdoll:AddDrawCallParticle( "bo3_dg4_zomb", PATTACH_POINT_FOLLOW, 1, true, "BO3_Ragnarok" )
	end,
	
	OnClientRagdoll = function( self, ragdoll, entity, duration )
		ragdoll:AddDrawCallParticle( "bo3_dg4_zomb", PATTACH_POINT_FOLLOW, 1, true, "BO3_Ragnarok" )
	end,
	
	OnRemove = function( self, entity, destroy )
		WonderWeapons.StopDrawParticle( entity, "BO3_Ragnarok", destroy )
	end,
})

WonderWeapons.AddDeathEffect("BO3_Gersh_Soul", {
	Type = EffectType.ON_RAGDOLL,

	IsValid = function(self, entity)
		return false
	end,

	OnEntity = function(self, entity)
	end,

	OnServerRagdoll = function(self, ragdoll, entity, duration)
		sound.Play("TFA_BO3_GERSCH.Suck", entity:EyePos(), SNDLVL_TALKING, math.random(97,103), 1)

		ParticleEffect("bo3_gersch_kill", entity:WorldSpaceCenter(), angle_zero)

		WonderWeapons.SafeRemoveRagdoll( ragdoll )
	end,

	OnClientRagdoll = function(self, ragdoll, entity, duration)
		sound.Play("TFA_BO3_GERSCH.Suck", entity:EyePos(), SNDLVL_TALKING, math.random(97,103), 1)

		CreateParticleSystemNoEntity("bo3_gersch_kill", entity:WorldSpaceCenter())

		WonderWeapons.SafeRemoveRagdoll( ragdoll )
	end,

	OnRemove = function( self, entity, destroy )
	end,
})

WonderWeapons.AddDeathEffect("BO3_Wavegun_Pop", {
	Type = EffectType.ON_RAGDOLL,

	IsValid = function( self, entity )
		return false
	end,

	OnEntity = function( self, entity, duration )
	end,

	OnServerRagdoll = function( self, ragdoll, entity, duration )
		local BloodName = WonderWeapons.GetBloodName( entity )
		local BloodColor = entity.GetBloodColor and entity:GetBloodColor()

		local effectsByBloodName = {
			[WonderWeapons.BLOOD_RED] = "bo3_wavegun_pop",
			[WonderWeapons.BLOOD_ZOMBIE] = "bo3_wavegun_pop_zomb",
			[WonderWeapons.BLOOD_ALIEN] = "bo3_wavegun_pop_yellow",
			[WonderWeapons.BLOOD_ACID] = "bo3_wavegun_pop_acid",
			[WonderWeapons.BLOOD_CYBORG] = "bo3_wavegun_pop_blue",
			[WonderWeapons.BLOOD_SYNTH] = "bo3_wavegun_pop_synth",
			[WonderWeapons.BLOOD_MECH] = "bo3_wavegun_pop_oil",
		}

		local dontBleeds = {
			[WonderWeapons.DONT_BLEED] = true,
		}

		local BloodPopEffect = BloodName and effectsByBloodName[ BloodName ]

		if bit.band( util.PointContents( ragdoll:GetPos() ), bit.bor( CONTENTS_WATER, CONTENTS_SLIME ) ) ~= 0 then
			ParticleEffectAttach("bo3_wavegun_pop_uwater", PATTACH_ABSORIGIN_FOLLOW, ragdoll, 1)
		end

		if BloodPopEffect then
			ParticleEffectAttach(BloodPopEffect, PATTACH_ABSORIGIN_FOLLOW, ragdoll, 1)

			if !dontBleeds[BloodName] then
				WonderWeapons.DoRadialBloodImpact( ragdoll:GetPos(), 144, 16, ( BloodName or BloodColor ), bit.bor( MASK_SHOT, bit.bnot( CONTENTS_HITBOX ) ), COLLISION_GROUP_NONE, { entity, ragdoll } )
			end
		end

		WonderWeapons.SafeRemoveRagdoll( ragdoll, engine.TickInterval() )
	end,
	
	OnClientRagdoll = function( self, ragdoll, entity, duration )
		local BloodName = WonderWeapons.GetBloodName( entity )
		local BloodColor = entity.GetBloodColor and entity:GetBloodColor()

		local effectsByBloodName = {
			[WonderWeapons.BLOOD_RED] = "bo3_wavegun_pop",
			[WonderWeapons.BLOOD_ZOMBIE] = "bo3_wavegun_pop_zomb",
			[WonderWeapons.BLOOD_ALIEN] = "bo3_wavegun_pop_yellow",
			[WonderWeapons.BLOOD_ACID] = "bo3_wavegun_pop_acid",
			[WonderWeapons.BLOOD_CYBORG] = "bo3_wavegun_pop_blue",
			[WonderWeapons.BLOOD_SYNTH] = "bo3_wavegun_pop_synth",
			[WonderWeapons.BLOOD_MECH] = "bo3_wavegun_pop_oil",
		}

		local dontBleeds = {
			[WonderWeapons.DONT_BLEED] = true,
		}

		local BloodPopEffect = BloodName and effectsByBloodName[ BloodName ]

		if bit.band( util.PointContents( ragdoll:GetPos() ), bit.bor( CONTENTS_WATER, CONTENTS_SLIME ) ) ~= 0 then
			ParticleEffectAttach("bo3_wavegun_pop_uwater", PATTACH_ABSORIGIN_FOLLOW, ragdoll, 1)
		end

		if BloodPopEffect then
			ParticleEffectAttach(BloodPopEffect, PATTACH_ABSORIGIN_FOLLOW, ragdoll, 1)

			if !dontBleeds[BloodName] then
				WonderWeapons.DoRadialBloodImpact( ragdoll:GetPos(), 144, 16, ( BloodName or BloodColor ), bit.bor( MASK_SHOT, bit.bnot( CONTENTS_HITBOX ) ), COLLISION_GROUP_NONE, { entity, ragdoll } )
			end
		end

		WonderWeapons.SafeRemoveRagdoll( ragdoll, engine.TickInterval() )
	end,

	OnRemove = function( self, entity, destroy )
	end,
})

WonderWeapons.AddDeathEffect("BO3_Wolfbow_Ghost", {
	Type = EffectType.ON_RAGDOLL,

	IsValid = function( self, entity )
		local timerName = "WonderWeapon.Wolfbow_Ghost."..self:GetIndex()
		return timer.Exists( timerName )
	end,

	OnEntity = function( self, entity, duration )
	end,

	OnServerRagdoll = function( self, ragdoll, entity, duration )
		ragdoll:SetCollisionGroup(COLLISION_GROUP_DEBRIS)

		local timerName = "WonderWeapon.Wolfbow_Ghost."..self:GetIndex()
		timer.Create( timerName, math.Rand( 0.5, 1 ), 1, function()
			if ragdoll:IsValid() then
				ParticleEffect( "bo3_qed_explode_1", ragdoll:GetPos(), angle_zero )

				WonderWeapons.SafeRemoveRagdoll( ragdoll, engine.TickInterval() )
			end
		end )
	end,

	OnServerRagdoll_Client = function( self, ragdoll, entity, duration )
		local function BlendGhost( self )
			local num = render.GetBlend()

			render.SuppressEngineLighting( false )
			render.MaterialOverride( Material("models/zmb/ghost/ghost_glow.vmt") )
			render.SetBlend( 0.1 )

			self:DrawModel()

			render.SetBlend( num )
			render.MaterialOverride( nil )
			render.SuppressEngineLighting( false )
		end

		ragdoll.RenderOverride = BlendGhost
	end,

	OnClientRagdoll = function( self, ragdoll, entity, duration )
		local function BlendGhost( self )
			local num = render.GetBlend()

			render.SuppressEngineLighting( false )
			render.MaterialOverride( Material("models/zmb/ghost/ghost_glow.vmt") )
			render.SetBlend( 0.1 )
			self:DrawModel()
			render.SetBlend( num )
			render.MaterialOverride( nil )
			render.SuppressEngineLighting( false )
		end

		ragdoll.RenderOverride = BlendGhost
		ragdoll:SetCollisionGroup(COLLISION_GROUP_DEBRIS)

		local timerName = "WonderWeapon.Wolfbow_Ghost."..self:GetIndex()
		timer.Create( timerName, math.Rand( 0.5, 1 ), 1, function()
			if ragdoll:IsValid() then
				CreateParticleSystemNoEntity( "bo3_qed_explode_1", ragdoll:GetPos() )

				WonderWeapons.SafeRemoveRagdoll( ragdoll, engine.TickInterval() )
			end
		end )
	end,

	OnRemove = function(self, entity, destroy)
		entity.RenderOverride = nil

		local timerName = "WonderWeapon.Wolfbow_Ghost."..self:GetIndex()
		if timer.Exists( timerName ) then
			timer.Remove( timerName )
		end
	end,
})

WonderWeapons.AddDeathEffect("BO3_Annihilator_Gib", {
	Type = EffectType.ON_RAGDOLL,

	IsValid = function( self, entity )
		local timerName = "WonderWeapon.Annihilator_Gib." .. self:GetIndex()
		return timer.Exists( timerName )
	end,

	OnEntity = function( self, entity, duration )
	end,

	OnServerRagdoll = function( self, ragdoll, entity, duration )
		local BloodName = WonderWeapons.GetBloodName( entity )
		local BloodColor = entity.GetBloodColor and entity:GetBloodColor()

		local ExplosionBloodEffect = WonderWeapons.ExplosionByBloodColor[ BloodColor or BloodName ]

		ragdoll:AddCallback( "PhysicsCollide", function( _, data )
			if data.Speed < 60 then return end

			if IsValid( data.HitEntity ) and ( data.HitEntity:GetCollisionGroup() == COLLISION_GROUP_BREAKABLE_GLASS ) then
				data.HitEntity:Input( "break" )
			end

			local phys = data.PhysObject
			if IsValid( phys ) then
				local LastVelocity = data.OurOldVelocity
				local LastSpeed = math.max( LastVelocity:Length(), data.Speed )
				phys:SetVelocity( LastVelocity:GetNormalized() * LastSpeed )
			end

			WonderWeapons.DoBloodyFleshImpact( ragdoll.BloodColor, data.HitPos, data.HitNormal, "physics/glass/glass_largesheet_break" .. math.random(3) .. ".wav" )
		end )

		ragdoll:SetCollisionGroup( COLLISION_GROUP_DEBRIS )

		for i=0, ragdoll:GetPhysicsObjectCount()-1 do
			construct.SetPhysProp( nil, ragdoll, i, nil, { GravityToggle = false } )
		end

		local timerName = "WonderWeapon.Annihilator_Gib." .. self:GetIndex()
		timer.Create( timerName, math.Rand( 0.1, 0.4 ), 1, function()
			if not ragdoll:IsValid() then return end

			if ExplosionBloodEffect then
				ParticleEffect( ExplosionBloodEffect, ragdoll:GetPos(), angle_zero )

				ragdoll:EmitSound( "TFA_BO3_ANNIHILATOR.Gib" )
				ragdoll:EmitSound( "TFA_BO3_ANNIHILATOR.Exp" )

				WonderWeapons.DoRadialBloodImpact( ragdoll:GetPos(), 512, 64, ( BloodName or BloodColor ), bit.bor( MASK_SHOT, bit.bnot( CONTENTS_HITBOX ) ), COLLISION_GROUP_NONE, { entity, ragdoll } )
				WonderWeapons.GibRagdoll( ragdoll )
			end

			WonderWeapons.SafeRemoveRagdoll( ragdoll )
		end )
	end,

	OnClientRagdoll = function( self, ragdoll, entity, duration )
		local BloodName = WonderWeapons.GetBloodName( entity )
		local BloodColor = entity.GetBloodColor and entity:GetBloodColor()

		local ExplosionBloodEffect = WonderWeapons.ExplosionByBloodColor[ BloodColor or BloodName ]

		ragdoll:AddCallback("PhysicsCollide", function( _, data )
			if data.Speed < 60 then return end

			WonderWeapons.DoBloodyFleshImpact( ragdoll.BloodColor, data.HitPos, data.HitNormal, "physics/flesh/flesh_impact_hard" .. math.random(6) .. ".wav" )
		end)

		ragdoll:SetCollisionGroup( COLLISION_GROUP_DEBRIS )

		for i = 0, ragdoll:GetPhysicsObjectCount() - 1 do
			local phys = ragdoll:GetPhysicsObjectNum( i )
			phys:EnableGravity( false )
		end

		local timerName = "WonderWeapon.Annihilator_Gib."..self:GetIndex()
		timer.Create( timerName, math.Rand( 0.1, 0.4 ), 1, function()
			if not ragdoll:IsValid() then return end

			if ExplosionBloodEffect then
				CreateParticleSystemNoEntity( ExplosionBloodEffect, ragdoll:GetPos() )

				ragdoll:EmitSound( "TFA_BO3_ANNIHILATOR.Gib" )
				ragdoll:EmitSound( "TFA_BO3_ANNIHILATOR.Exp" )

				WonderWeapons.DoRadialBloodImpact( ragdoll:GetPos(), 512, 64, ( BloodName or BloodColor ), bit.bor( MASK_SHOT, bit.bnot( CONTENTS_HITBOX ) ), COLLISION_GROUP_NONE, { entity, ragdoll } )
				WonderWeapons.GibRagdoll( ragdoll )
			end

			WonderWeapons.SafeRemoveRagdoll( ragdoll )
		end )
	end,

	OnRemove = function( self, entity, destroy )
		local timerName = "WonderWeapon.Annihilator_Gib." .. self:GetIndex()
		if timer.Exists( timerName ) then
			timer.Remove( timerName )
		end
	end,
})

WonderWeapons.AddDeathEffect("BO3_Wavegun_Cook", {
	Type = EffectType.ON_RAGDOLL,

	IsValid = function( self, entity )
		local timerName = "WonderWeapon.Wavegun_Cook." .. self:GetIndex()
		return timer.Exists( timerName )
	end,

	OnEntity = function( self, entity, duration )
	end,

	OnServerRagdoll = function( self, ragdoll, entity, duration, dontinflate )
		local BloodName = WonderWeapons.GetBloodName( entity )
		local BloodColor = entity.GetBloodColor and entity:GetBloodColor()

		local effectsByBloodName = {
			[WonderWeapons.BLOOD_RED] = "bo3_wavegun_pop",
			[WonderWeapons.BLOOD_ZOMBIE] = "bo3_wavegun_pop_zomb",
			[WonderWeapons.BLOOD_ALIEN] = "bo3_wavegun_pop_yellow",
			[WonderWeapons.BLOOD_ACID] = "bo3_wavegun_pop_acid",
			[WonderWeapons.BLOOD_CYBORG] = "bo3_wavegun_pop_blue",
			[WonderWeapons.BLOOD_SYNTH] = "bo3_wavegun_pop_synth",
			[WonderWeapons.BLOOD_MECH] = "bo3_wavegun_pop_oil",
		}

		local dontBleeds = {
			[WonderWeapons.DONT_BLEED] = true,
		}

		local BloodPopEffect = BloodName and effectsByBloodName[ BloodName ]

		local bonescale = 1
		local cookTimer = "WonderWeapon.Wavegun_Cook." .. self:GetIndex()

		ragdoll:SetCollisionGroup( COLLISION_GROUP_DEBRIS )

		if ragdoll:WaterLevel() < 3 then
			for i = 0, ragdoll:GetPhysicsObjectCount() - 1 do
				construct.SetPhysProp( nil, ragdoll, i, nil, { GravityToggle = false } )
			end
		end

		timer.Create( cookTimer, math.Rand( 1.5, 2 ), 1, function()
			if not IsValid( ragdoll ) then
				timer.Remove( cookTimer )
				return
			end

			if bit.band( util.PointContents( ragdoll:GetPos() ), bit.bor( CONTENTS_WATER, CONTENTS_SLIME ) ) ~= 0 then
				ParticleEffectAttach( "bo3_wavegun_pop_uwater", PATTACH_ABSORIGIN_FOLLOW, ragdoll, 1 )
			end

			if BloodPopEffect then
				ParticleEffectAttach( BloodPopEffect, PATTACH_ABSORIGIN_FOLLOW, ragdoll, 1 )

				if !dontBleeds[BloodName] then
					ragdoll:EmitSound("TFA_BO3_GENERIC.Gib")

					WonderWeapons.GibRagdoll( ragdoll )
				end

				WonderWeapons.DoRadialBloodImpact( ragdoll:GetPos(), 144, 16, ( BloodName or BloodColor ), bit.bor( MASK_SHOT, bit.bnot( CONTENTS_HITBOX ) ), COLLISION_GROUP_NONE, { entity, ragdoll } )
			end

			ragdoll:EmitSound("TFA_BO3_WAVEGUN.Microwave.Ding")

			WonderWeapons.SafeRemoveRagdoll( ragdoll, engine.TickInterval()*2 )
		end )
	end,

	OnServerRagdoll_Client = function( self, ragdoll, entity, duration, dontinflate )
		local BloodName = WonderWeapons.GetBloodName( entity )
		local BloodColor = entity.GetBloodColor and entity:GetBloodColor()

		local eyesByBloodName = {
			[WonderWeapons.BLOOD_RED] = "bo3_wavegun_eyes",
			[WonderWeapons.BLOOD_ZOMBIE] = "bo3_wavegun_eyes_zomb",
			[WonderWeapons.BLOOD_ALIEN] = "bo3_wavegun_eyes_yellow",
			[WonderWeapons.BLOOD_ACID] = "bo3_wavegun_eyes_acid",
			[WonderWeapons.BLOOD_CYBORG] = "bo3_wavegun_eyes_blue",
			[WonderWeapons.BLOOD_SYNTH] = "bo3_wavegun_eyes_synth",
			[WonderWeapons.BLOOD_SYNTH] = "bo3_wavegun_eyes_oil",
		}

		local dontBleeds = {
			[WonderWeapons.DONT_BLEED] = true,
		}

		local bonescale = 1

		local EyeBloodEffect
		if BloodName and !dontBleeds[ BloodName ] then
			EyeBloodEffect = eyesByBloodName[ BloodName ] or "bo3_wavegun_eyes"
		end

		local eyeR, eyeL = WonderWeapons.GetEyesAttachment( entity )
		local mouthAtt = WonderWeapons.GetMouthAttachment( entity )
		local headAtt = WonderWeapons.GetHeadAttachment( entity )

		if EyeBloodEffect ~= nil and ( mouthAtt or headAtt ) then
			ragdoll:AddDrawCallParticle( EyeBloodEffect, PATTACH_POINT_FOLLOW, mouthAtt or headAtt, true, "BO3_Wavegun_Cook" )
		end

		if EyeBloodEffect ~= nil and eyeR and eyeL then
			ragdoll:AddDrawCallParticle( EyeBloodEffect, PATTACH_POINT_FOLLOW, eyeL, true, "BO3_Wavegun_Cook_Eye_L" )
			ragdoll:AddDrawCallParticle( EyeBloodEffect, PATTACH_POINT_FOLLOW, eyeR, true, "BO3_Wavegun_Cook_Eye_R" )
		end

		if !tobool(dontinflate) then
			local inflateTimer = "WonderWeapon.Wavegun_Inflate." .. self:GetIndex()
			timer.Create( inflateTimer, 0.015, 0, function()
				if not IsValid( ragdoll ) then
					timer.Remove( inflateTimer )
					return
				end

				for i = 0, ragdoll:GetBoneCount(), 1 do
					ragdoll:ManipulateBoneScale( i, Vector( bonescale, bonescale, bonescale ) )
				end

				bonescale = bonescale + ( 0.015 / 2 )

				if bonescale > 2 then
					bonescale = 2
				end
			end )
		end
	end,

	OnClientRagdoll = function( self, ragdoll, entity, duration, dontinflate )
		G_RagdollIsCooking = true

		local BloodName = WonderWeapons.GetBloodName( entity )
		local BloodColor = entity.GetBloodColor and entity:GetBloodColor()

		local effectsByBloodName = {
			[WonderWeapons.BLOOD_RED] = "bo3_wavegun_pop",
			[WonderWeapons.BLOOD_ZOMBIE] = "bo3_wavegun_pop_zomb",
			[WonderWeapons.BLOOD_ALIEN] = "bo3_wavegun_pop_yellow",
			[WonderWeapons.BLOOD_ACID] = "bo3_wavegun_pop_acid",
			[WonderWeapons.BLOOD_CYBORG] = "bo3_wavegun_pop_blue",
			[WonderWeapons.BLOOD_SYNTH] = "bo3_wavegun_pop_synth",
			[WonderWeapons.BLOOD_MECH] = "bo3_wavegun_pop_oil",
		}

		local dontBleeds = {
			[WonderWeapons.DONT_BLEED] = true,
		}

		local eyesByBloodName = {
			[WonderWeapons.BLOOD_RED] = "bo3_wavegun_eyes",
			[WonderWeapons.BLOOD_ZOMBIE] = "bo3_wavegun_eyes_zomb",
			[WonderWeapons.BLOOD_ALIEN] = "bo3_wavegun_eyes_yellow",
			[WonderWeapons.BLOOD_ACID] = "bo3_wavegun_eyes_acid",
			[WonderWeapons.BLOOD_CYBORG] = "bo3_wavegun_eyes_blue",
			[WonderWeapons.BLOOD_SYNTH] = "bo3_wavegun_eyes_synth",
			[WonderWeapons.BLOOD_SYNTH] = "bo3_wavegun_eyes_oil",
		}

		local BloodPopEffect = BloodName and effectsByBloodName[ BloodName ]

		local bonescale = 1
		local inflateTimer = "WonderWeapon.Wavegun_Inflate." .. self:GetIndex()
		local cookTimer = "WonderWeapon.Wavegun_Cook." .. self:GetIndex()

		local EyeBloodEffect
		if BloodName and !dontBleeds[ BloodName ] then
			EyeBloodEffect = eyesByBloodName[ BloodName ] or "bo3_wavegun_eyes"
		end

		local eyeR, eyeL = WonderWeapons.GetEyesAttachment( entity )
		local mouthAtt = WonderWeapons.GetMouthAttachment( entity )
		local headAtt = WonderWeapons.GetHeadAttachment( entity )

		if EyeBloodEffect ~= nil and ( mouthAtt or headAtt ) then
			ragdoll:AddDrawCallParticle( EyeBloodEffect, PATTACH_POINT_FOLLOW, mouthAtt or headAtt, true, "BO3_Wavegun_Cook" )
		end

		if EyeBloodEffect ~= nil and eyeR and eyeL then
			ragdoll:AddDrawCallParticle( EyeBloodEffect, PATTACH_POINT_FOLLOW, eyeL, true, "BO3_Wavegun_Cook_Eye_L" )
			ragdoll:AddDrawCallParticle( EyeBloodEffect, PATTACH_POINT_FOLLOW, eyeR, true, "BO3_Wavegun_Cook_Eye_R" )
		end

		ragdoll:SetCollisionGroup( COLLISION_GROUP_DEBRIS )

		if ragdoll:WaterLevel() < 3 then
			for i=0, ragdoll:GetPhysicsObjectCount()-1 do
				local phys = ragdoll:GetPhysicsObjectNum(i)
				phys:EnableGravity(false)
			end
		end

		if !tobool(dontinflate) then
			timer.Create( inflateTimer, 0.015, 0, function()
				if not IsValid( ragdoll ) then
					timer.Remove(inflateTimer)
					return
				end

				for i = 0, ragdoll:GetBoneCount(), 1 do
					ragdoll:ManipulateBoneScale( i, Vector( bonescale, bonescale, bonescale ) )
				end

				bonescale = bonescale + ( 0.015 / 2 )

				if bonescale > 2 then
					bonescale = 2
				end
			end )
		end

		timer.Create( cookTimer, math.Rand( 1.5, 2 ), 1, function()
			if not IsValid( ragdoll ) then
				timer.Remove( cookTimer )
				return
			end

			if bit.band( util.PointContents( ragdoll:GetPos() ), bit.bor( CONTENTS_WATER, CONTENTS_SLIME ) ) ~= 0 then
				ParticleEffectAttach( "bo3_wavegun_pop_uwater", PATTACH_ABSORIGIN_FOLLOW, ragdoll, 1 )
			end

			if BloodPopEffect then
				ParticleEffectAttach( BloodPopEffect, PATTACH_ABSORIGIN_FOLLOW, ragdoll, 1 )

				if !dontBleeds[BloodName] then
					ragdoll:EmitSound("TFA_BO3_GENERIC.Gib")

					WonderWeapons.GibRagdoll( ragdoll )
				end

				WonderWeapons.DoRadialBloodImpact( ragdoll:GetPos(), 144, 16, ( BloodName or BloodColor ), bit.bor( MASK_SHOT, bit.bnot( CONTENTS_HITBOX ) ), COLLISION_GROUP_NONE, { entity, ragdoll } )
			end

			ragdoll:EmitSound("TFA_BO3_WAVEGUN.Microwave.Ding")

			WonderWeapons.SafeRemoveRagdoll( ragdoll, engine.TickInterval() )
		end )
	end,

	OnRemove = function( self, entity, destroy )
		if CLIENT then
			local bResetGlobal = true

			local DeathEffectIndex = WonderWeapons.DeathEffects.Index
			if DeathEffectIndex then
				for i, mDeathFX in pairs( DeathEffectIndex ) do
					if mDeathFX and mDeathFX ~= self and mDeathFX.DeathEffect == "BO3_Wavegun_Cook" then
						bResetGlobal = false
						break
					end
				end
			end

			if bResetGlobal then
				G_RagdollIsCooking = false
			end
		end

		local inflateTimer = "WonderWeapon.Wavegun_Inflate." .. self:GetIndex()
		local cookTimer = "WonderWeapon.Wavegun_Cook." .. self:GetIndex()

		if timer.Exists( cookTimer ) then
			timer.Remove( cookTimer )
		end

		if timer.Exists( inflateTimer ) then
			for i = 0, entity:GetBoneCount(), 1 do
				entity:ManipulateBoneScale( i, Vector( 1, 1, 1 ) )
			end
			timer.Remove( inflateTimer )
		end

		WonderWeapons.StopDrawParticle( entity, "BO3_Wavegun_Cook_Eye_L", destroy )
		WonderWeapons.StopDrawParticle( entity, "BO3_Wavegun_Cook_Eye_R", destroy )
		WonderWeapons.StopDrawParticle( entity, "BO3_Wavegun_Cook", destroy )
	end,
})
