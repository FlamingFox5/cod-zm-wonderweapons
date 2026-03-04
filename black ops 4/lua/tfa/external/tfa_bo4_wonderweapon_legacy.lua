
//------------------------------------------------------------------------------
// Legacy Status Effect Functions, DO NOT USE THESE! USE THE NEW SYSTEM INSTEAD!
//------------------------------------------------------------------------------

local ENTITY = FindMetaTable("Entity")

if ENTITY then
	// Alistair Folly

	if SERVER then
		ENTITY.BO4FireBall = function(self, duration, attacker, inflictor, damage)
			TFA.WonderWeapon.GiveStatus( self, "BO4_Alistair_Fireball", tonumber(duration), attacker, inflictor, damage )
		end

		ENTITY.BO4Shrink = function(self, duration, attacker, inflictor)
			TFA.WonderWeapon.GiveStatus( self, "BO4_Alistair_Shrink", tonumber(duration), attacker, inflictor )
		end

		ENTITY.BO4Tornado = function(self, duration, attacker, inflictor)
			TFA.WonderWeapon.GiveStatus( self, "BO4_Alistair_Tornado", tonumber(duration), attacker, inflictor )
		end

		ENTITY.BO4Toxic = function(self, duration, attacker, inflictor, damage)
			TFA.WonderWeapon.GiveStatus( self, "BO4_Alistair_Toxic", tonumber(duration), attacker, inflictor, tonumber(damage) )
		end
	end

	ENTITY.BO4IsIgnited = function(self)
		return TFA.WonderWeapon.HasStatus( self, "BO4_Alistair_Fireball" )
	end

	ENTITY.BO4IsShrunk = function(self)
		return TFA.WonderWeapon.HasStatus( self, "BO4_Alistair_Shrink" )
	end

	ENTITY.BO4IsTornado = function(self)
		return TFA.WonderWeapon.HasStatus( self, "BO4_Alistair_Tornado" )
	end

	ENTITY.BO4IsToxic = function(self)
		return TFA.WonderWeapon.HasStatus( self, "BO4_Alistair_Toxic" )
	end

	// Magmagat

	if SERVER then
		ENTITY.BO4Magma = function(self, duration, attacker, inflictor, damage)
			TFA.WonderWeapon.GiveStatus( self, "BO4_MagmaGat_Burn", tonumber(duration), attacker, inflictor, damage )
		end
	end

	ENTITY.BO4IsMagmaIgnited = function(self)
		return TFA.WonderWeapon.HasStatus( self, "BO4_MagmaGat_Burn" )
	end

	// Winter's Howl

	if SERVER then
		ENTITY.BO4WintersFreeze = function( self, duration, attacker, inflictor, damage )
			TFA.WonderWeapon.GiveStatus( self, "BO4_Winters_Freeze", tonumber(duration), attacker, inflictor, damage )
		end

		ENTITY.BO4WintersSlow = function( self, duration, ratio )
			TFA.WonderWeapon.GiveStatus( self, "BO4_Winters_Slow", tonumber(duration), tonumber(ratio) )
		end
	end

	ENTITY.BO4IsFrozen = function(self)
		return TFA.WonderWeapon.HasStatus( self, "BO4_Winters_Freeze" )
	end

	ENTITY.BO4IsSlowed = function(self)
		return TFA.WonderWeapon.HasStatus( self, "BO4_Winters_Slow" )
	end

	// Path of Sorrow

	if SERVER then
		ENTITY.BO4KatanaStealth = function(self, duration )
			TFA.WonderWeapon.GiveStatus( self, "BO4_Katana_Stealth", tonumber(duration) )
		end
	end

	ENTITY.BO4IsStealth = function(self)
		return TFA.WonderWeapon.HasStatus( self, "BO4_Katana_Stealth" )
	end

	// Death of Orion

	if SERVER then
		ENTITY.BO4Scorp = function(self, duration, attacker, inflictor, damage)
			TFA.WonderWeapon.GiveStatus( self, "BO4_Orion_Shock", tonumber(duration), attacker, inflictor, damage )
		end

		ENTITY.BO4Speeen = function(self, duration, attacker, inflictor, damage)
			TFA.WonderWeapon.GiveStatus( self, "BO4_Orion_Spinner", tonumber(duration), attacker, inflictor, damage )
		end
	end

	ENTITY.BO4IsScorped = function(self)
		return TFA.WonderWeapon.HasStatus( self, "BO4_Orion_Shock" )
	end

	ENTITY.BO4IsSpinning = function(self)
		return TFA.WonderWeapon.HasStatus( self, "BO4_Orion_Spinner" )
	end

	// Ragnarok DG5

	if SERVER then
		ENTITY.BO4Shock = function(self, duration, attacker, inflictor, damage)
			TFA.WonderWeapon.GiveStatus( self, "BO4_Ragnarok_Shock", tonumber(duration), attacker, inflictor, damage )
		end
	end

	ENTITY.BO4IsShocked = function(self)
		return TFA.WonderWeapon.HasStatus( self, "BO4_Ragnarok_Shock" )
	end
end