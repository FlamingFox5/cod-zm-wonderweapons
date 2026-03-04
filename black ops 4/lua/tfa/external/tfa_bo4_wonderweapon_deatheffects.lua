//-------------------------------------------------------------
// Death Effects
//-------------------------------------------------------------

local WonderWeapons = TFA.WonderWeapon

local EffectType = WonderWeapons.DeathEffects.Types

local nzombies = engine.ActiveGamemode() == "nzombies"
local sv_damage_world = GetConVar("sv_tfa_bo3ww_environmental_damage")

local vector_down_4 = Vector(0, 0, -4)

WonderWeapons.AddDeathEffect("BO4_Sniperwaffe", {
	Type = bit.bor(EffectType.ON_DEATH, EffectType.ON_RAGDOLL),

	IsValid = function( self, entity )
		return entity.GetDrawCallParticle and IsValid( entity:GetDrawCallParticle( "BO4_Sniperwaffe" ) )
	end,

	OnEntity = function( self, entity, duration, upgraded, headshot )
		upgraded = tobool(upgraded)
		headshot = tobool(headshot)

		entity:EmitSound("TFA_BO3_WAFFE.Sizzle")

		local eyeR, eyeL = WonderWeapons.GetEyesAttachment( entity )
		local bodyAtt = WonderWeapons.GetChestAttachment( entity )
		local headAtt = WonderWeapons.GetHeadAttachment( entity )

		local finalAtt = !headshot and ( bodyAtt ~= nil and bodyAtt or headAtt ) or ( headAtt ~= nil and headAtt or bodyAtt )

		entity:AddDrawCallParticle( upgraded and "bo4_dg1_electrocute_2" or "bo4_dg1_electrocute", PATTACH_POINT_FOLLOW, finalAtt or 1, true, "BO4_Sniperwaffe" )

		if nzombies and entity:IsValidZombie() then
			if not entity.IsMooSpecialZombie and ( not ent.GetDecapitated or not ent:GetDecapitated() ) then
				entity:AddDrawCallParticle( upgraded and "bo4_dg1_eyes_2" or "bo4_dg1_eyes", PATTACH_POINT_FOLLOW, 3, true, "BO4_Sniperwaffe_Eye_L" )
				entity:AddDrawCallParticle( upgraded and "bo4_dg1_eyes_2" or "bo4_dg1_eyes", PATTACH_POINT_FOLLOW, 4, true, "BO4_Sniperwaffe_Eye_R" )
			end
		elseif isnumber( eyeR ) and isnumber( eyeL ) then
			entity:AddDrawCallParticle( upgraded and "bo4_dg1_eyes_2" or "bo4_dg1_eyes", PATTACH_POINT_FOLLOW, eyeL, true, "BO4_Sniperwaffe_Eye_L" )
			entity:AddDrawCallParticle( upgraded and "bo4_dg1_eyes_2" or "bo4_dg1_eyes", PATTACH_POINT_FOLLOW, eyeR, true, "BO4_Sniperwaffe_Eye_R" )
		else
			local eye = entity:LookupAttachment( "eye" )
			if isnumber( eye ) and eye > 0 then
				entity:AddDrawCallParticle( upgraded and "bo4_dg1_eyes_2" or "bo4_dg1_eyes", PATTACH_POINT_FOLLOW, eye, true, "BO4_Sniperwaffe_Eye" )
			end
		end

		if util.QuickTrace( entity:GetPos(), vector_up*-4, entity ).Hit then
			CreateParticleSystemNoEntity( upgraded and "bo4_dg1_ground_2" or "bo4_dg1_ground", entity:GetPos(), Angle(0,0,0) )
		end
	end,

	OnServerRagdoll = function( self, ragdoll, entity, duration, upgraded, headshot )
		entity:StopSound("TFA_BO3_WAFFE.Sizzle")
	end,

	OnServerRagdoll_Client = function( self, ragdoll, entity, duration, upgraded, headshot )
		upgraded = tobool(upgraded)
		headshot = tobool(headshot)

		entity:StopSound("TFA_BO3_WAFFE.Sizzle")
		ragdoll:EmitSound("TFA_BO3_WAFFE.Sizzle")

		local bodyAtt = WonderWeapons.GetChestAttachment( ragdoll )
		local headAtt = WonderWeapons.GetHeadAttachment( ragdoll )

		local finalAtt = !headshot and ( bodyAtt ~= nil and bodyAtt or headAtt ) or ( headAtt ~= nil and headAtt or bodyAtt )

		ragdoll:AddDrawCallParticle( upgraded and "bo4_dg1_electrocute_2" or "bo4_dg1_electrocute", PATTACH_POINT_FOLLOW, finalAtt or 1, true, "BO4_Sniperwaffe" )

		local eyeR, eyeL = WonderWeapons.GetEyesAttachment( ragdoll )

		if nzombies and ragdoll:IsValidZombie() and not ragdoll.IsMooSpecialZombie then
			ragdoll:AddDrawCallParticle( upgraded and "bo4_dg1_eyes_2" or "bo4_dg1_eyes", PATTACH_POINT_FOLLOW, 3, true, "BO4_Sniperwaffe_Eye_L" )
			ragdoll:AddDrawCallParticle( upgraded and "bo4_dg1_eyes_2" or "bo4_dg1_eyes", PATTACH_POINT_FOLLOW, 4, true, "BO4_Sniperwaffe_Eye_R" )
		elseif isnumber( eyeR ) and isnumber( eyeL ) then
			ragdoll:AddDrawCallParticle( upgraded and "bo4_dg1_eyes_2" or "bo4_dg1_eyes", PATTACH_POINT_FOLLOW, eyeL, true, "BO4_Sniperwaffe_Eye_L" )
			ragdoll:AddDrawCallParticle( upgraded and "bo4_dg1_eyes_2" or "bo4_dg1_eyes", PATTACH_POINT_FOLLOW, eyeR, true, "BO4_Sniperwaffe_Eye_R" )
		else
			local eye = entity:LookupAttachment( "eye" )
			if isnumber( eye ) and eye > 0 then
				ragdoll:AddDrawCallParticle( upgraded and "bo4_dg1_eyes_2" or "bo4_dg1_eyes", PATTACH_POINT_FOLLOW, eye, true, "BO4_Sniperwaffe_Eye" )
			end
		end

		if util.QuickTrace( entity:GetPos(), vector_down_4, entity ).Hit then
			CreateParticleSystemNoEntity( upgraded and "bo4_dg1_ground_2" or "bo4_dg1_ground", entity:GetPos(), Angle(0,0,0) )
		end
	end,

	OnClientRagdoll = function( self, ragdoll, entity, duration, upgraded, headshot )
		upgraded = tobool(upgraded)
		headshot = tobool(headshot)

		entity:StopSound("TFA_BO3_WAFFE.Sizzle")
		ragdoll:EmitSound("TFA_BO3_WAFFE.Sizzle")

		local bodyAtt = WonderWeapons.GetChestAttachment( ragdoll )
		local headAtt = WonderWeapons.GetHeadAttachment( ragdoll )

		local finalAtt = !headshot and ( bodyAtt ~= nil and bodyAtt or headAtt ) or ( headAtt ~= nil and headAtt or bodyAtt )

		ragdoll:AddDrawCallParticle( upgraded and "bo4_dg1_electrocute_2" or "bo4_dg1_electrocute", PATTACH_POINT_FOLLOW, finalAtt or 1, true, "BO4_Sniperwaffe" )

		local eyeR, eyeL = WonderWeapons.GetEyesAttachment( ragdoll )

		if nzombies and ragdoll:IsValidZombie() and not ragdoll.IsMooSpecialZombie then
			ragdoll:AddDrawCallParticle( upgraded and "bo4_dg1_eyes_2" or "bo4_dg1_eyes", PATTACH_POINT_FOLLOW, 3, true, "BO4_Sniperwaffe_Eye_L" )
			ragdoll:AddDrawCallParticle( upgraded and "bo4_dg1_eyes_2" or "bo4_dg1_eyes", PATTACH_POINT_FOLLOW, 4, true, "BO4_Sniperwaffe_Eye_R" )
		elseif isnumber( eyeR ) and isnumber( eyeL ) then
			ragdoll:AddDrawCallParticle( upgraded and "bo4_dg1_eyes_2" or "bo4_dg1_eyes", PATTACH_POINT_FOLLOW, eyeL, true, "BO4_Sniperwaffe_Eye_L" )
			ragdoll:AddDrawCallParticle( upgraded and "bo4_dg1_eyes_2" or "bo4_dg1_eyes", PATTACH_POINT_FOLLOW, eyeR, true, "BO4_Sniperwaffe_Eye_R" )
		else
			local eye = entity:LookupAttachment( "eye" )
			if isnumber( eye ) and eye > 0 then
				ragdoll:AddDrawCallParticle( upgraded and "bo4_dg1_eyes_2" or "bo4_dg1_eyes", PATTACH_POINT_FOLLOW, eye, true, "BO4_Sniperwaffe_Eye" )
			end
		end

		if util.QuickTrace( entity:GetPos(), vector_down_4, entity ).Hit then
			CreateParticleSystemNoEntity( upgraded and "bo4_dg1_ground_2" or "bo4_dg1_ground", entity:GetPos(), Angle(0,0,0) )
		end
	end,

	OnRemove = function( self, entity, destroy )
		entity:StopSound("TFA_BO3_WAFFE.Sizzle")

		WonderWeapons.StopDrawParticle( entity, "BO4_Sniperwaffe_Eye_L", destroy )
		WonderWeapons.StopDrawParticle( entity, "BO4_Sniperwaffe_Eye_R", destroy )
		WonderWeapons.StopDrawParticle( entity, "BO4_Sniperwaffe_Eye", destroy )
		WonderWeapons.StopDrawParticle( entity, "BO4_Sniperwaffe", destroy )
	end,
})

WonderWeapons.AddDeathEffect("BO4_Alistair_Fireball", {
	Type = bit.bor(EffectType.ON_DEATH, EffectType.ON_RAGDOLL),

	IsValid = function( self, entity )
		return false
	end,

	OnEntity = function( self, entity, duration, upgraded )
		if entity:GetRenderFX() ~= kRenderFxRagdoll then
			ParticleEffectAttach( "bo4_alistairs_fireball_kill", PATTACH_POINT_FOLLOW, entity, 1 )
		end

		sound.Play( "TFA_BO4_ALISTAIR.Charged.FireExpl", entity:WorldSpaceCenter(), SNDLVL_NORM, math.random(97,103), 1 )
	end,

	OnServerRagdoll = function( self, ragdoll, entity, duration )
		WonderWeapons.SafeRemoveRagdoll( ragdoll, engine.TickInterval() )
	end,

	OnClientRagdoll = function( self, ragdoll, entity, duration )
		WonderWeapons.SafeRemoveRagdoll( ragdoll, engine.TickInterval() )
	end,

	OnRemove = function( self, entity, destroy )
	end,
})

WonderWeapons.AddDeathEffect("BO4_Ragnarok", {
	Type = bit.bor(EffectType.ON_DEATH, EffectType.ON_RAGDOLL),

	IsValid = function(self, entity)
		return entity.GetDrawCallParticle and IsValid( entity:GetDrawCallParticle( "BO4_Ragnarok" ) )
	end,

	OnEntity = function(self, entity, duration)
		entity:AddDrawCallParticle( "bo3_dg4_zomb", PATTACH_POINT_FOLLOW, 1, true, "BO4_Ragnarok" )
	end,

	OnServerRagdoll = function( self, ragdoll, entity, duration, upgraded, headshot )
		entity:StopSound("TFA_BO3_WAFFE.Sizzle")
	end,

	OnServerRagdoll_Client = function(self, ragdoll, entity, duration)
		entity:StopSound("TFA_BO3_WAFFE.Sizzle")
		ragdoll:EmitSound("TFA_BO3_WAFFE.Sizzle")

		ragdoll:AddDrawCallParticle( "bo3_dg4_zomb", PATTACH_POINT_FOLLOW, 1, true, "BO4_Ragnarok" )
	end,

	OnClientRagdoll = function(self, ragdoll, entity, duration)
		entity:StopSound("TFA_BO3_WAFFE.Sizzle")
		ragdoll:EmitSound("TFA_BO3_WAFFE.Sizzle")

		ragdoll:AddDrawCallParticle( "bo3_dg4_zomb", PATTACH_POINT_FOLLOW, 1, true, "BO4_Ragnarok" )
	end,

	OnRemove = function(self, entity, destroy)
		WonderWeapons.StopDrawParticle( entity, "BO4_Ragnarok", destroy )
	end,
})
