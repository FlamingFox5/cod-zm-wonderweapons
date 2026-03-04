
AddCSLuaFile()

ENT.Base = "tfa_ww_tacnade_base"
ENT.PrintName = "Q.E.D."

// Default Settings

ENT.Delay = 2.5

ENT.SizeOverride = 1

ENT.HullMaxs = Vector(2, 2, 2)
ENT.HullMins = ENT.HullMaxs:GetNegated()

ENT.BounceActivationSpeed = 100
ENT.BounceVelocityRatio = 0.4
ENT.BounceSoundMaterials = {
	[MAT_DIRT] = "TFA_BO3_QED.Bounce.Earth",
	[MAT_METAL] = "TFA_BO3_QED.Bounce.Metal",
	[MAT_WOOD] = "TFA_BO3_QED.Bounce.Wood",
	[0] = "TFA_BO3_QED.Bounce.Metal",
}
ENT.BounceSoundMaterials[MAT_GRATE] = ENT.BounceSoundMaterials[MAT_METAL]
ENT.BounceSoundMaterials[MAT_VENT] = ENT.BounceSoundMaterials[MAT_METAL]
ENT.BounceSoundMaterials[MAT_GRASS] = ENT.BounceSoundMaterials[MAT_DIRT]
ENT.BounceSoundMaterials[MAT_SNOW] = ENT.BounceSoundMaterials[MAT_DIRT]
ENT.BounceSoundMaterials[MAT_SAND] = ENT.BounceSoundMaterials[MAT_DIRT]

ENT.ThrowSound = "TFA_BO3_QED.Think"

ENT.RemoveOnKilltimeEnd = false

ENT.FindSolidOnly = true

// Explosion Settings

ENT.ExplosionBubbles = true
ENT.ExplosionBubblesSize = 200
ENT.ExplosionBubblesMagnitude = 4

ENT.ExplosionMaxBlockingMass = 350
ENT.ExplosionDamageType = nzombies and DMG_BLAST or bit.bor(DMG_BLAST, DMG_AIRBOAT)
ENT.ExplosionHeadShotScale = 3
ENT.ExplosionHitsOwner = false
ENT.ExplosionOwnerDamage = 150

ENT.WaterBlockExplosions = false

ENT.ScreenShakeAmplitude = 10
ENT.ScreenShakeFrequency = 255
ENT.ScreenShakeDuration = 1
ENT.ScreenShakeRange = 500

DEFINE_BASECLASS(ENT.Base)

local dlight_cvar = GetConVar("cl_tfa_fx_wonderweapon_dlights")

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

local doorClasses = {
	["prop_door_rotating"] = true,
	["func_door"] = true,
	["func_door_rotating"] = true,
}

local WonderWeapons = TFA.WonderWeapon
local BodyTarget = WonderWeapons.BodyTarget
local GiveStatus = WonderWeapons.GiveStatus
local HasStatus = WonderWeapons.HasStatus
local ShouldDamage = WonderWeapons.ShouldDamage

function ENT:SetupDataTables()
	BaseClass.SetupDataTables(self)

	self:NetworkVarTFA("Vector", "TelePos")
end

function ENT:ActivateCustom(phys)
	timer.Simple( 0, function()
		if not IsValid( self ) then return end
		self:SetMoveType( MOVETYPE_NONE )
		self:SetCollisionGroup( COLLISION_GROUP_WORLD )
	end )

	self:SetActivated(true)
end

function ENT:Think()
	if CLIENT and dlight_cvar:GetBool() and DynamicLight then
		local dlight = DynamicLight(self:EntIndex())
		if (dlight) then
			local mul = math.Rand(0.6,1.1)

			dlight.pos = self:GetAttachment(1).Pos
			dlight.r = 200*mul
			dlight.g = 220*mul
			dlight.b = 50*mul
			dlight.brightness = 0
			dlight.Decay = 1000
			dlight.Size = 64*mul
			dlight.DieTime = CurTime() + 1
		end
	end

	if SERVER then
		if self.killtime < CurTime() and !self.BlockEffects then
			self:DoRandomEffect()
			return false
		end
	end

	return BaseClass.Think(self)
end

function ENT:DoRandomEffect()
	// return TRUE to override Q.E.D. functionality (if you know what you are doing)
	if hook.Run( "TFA_WonderWeapon_QuantumBombActivate", self ) then return end

	// Special case for doors
	for _, door in pairs( ents.FindInSphere( self:GetPos(), 128 ) ) do
		if door:GetMoveType() == MOVETYPE_PUSH and doorClasses[ door:GetClass() ] then
			local bIsNearby = self:DistToSqr( door:GetPos() ) < 4096 // 64^2

			if math.random( bIsNearby and 10 or 20 ) == 1 then --10% if nearby or 5% if not
				WonderWeapons.QuantumBombData( "OpenDoor" ).OnActivate( self, door )
				return
			end
		end
	end

	// Special case for friendly scripted sequences
	local gState = game.GetGlobalState( "friendly_encounter" )
	if gState and isnumber( gState ) and gState == GLOBAL_ON then
		WonderWeapons.QuantumBombData( "DropEquipment" ).OnActivate( self )
		return
	end

	local effect = TFA.WonderWeapon.WeightedRandom( WonderWeapons.QuantumBombWeights() )

	// return a string of an existing Q.E.D. effect to override the randomly selected one
	local hookEffect = hook.Run( "TFA_WonderWeapon_QuantumBombEffect", self, effect )
	if hookEffect and isstring( hookEffect ) and WonderWeapons.QuantumBombData( hookEffect ) then
		effect = hookEffect
	end

	local data = WonderWeapons.QuantumBombData( effect )
	if data then
		if data.Name then
			self:PrintEffect( effect )
		end
		if data.AnnouncerVox and file.Exists( "sound/"..data.AnnouncerVox, "GAME" ) then
			self:SendAnnouncerVox( data.AnnouncerVox, tobool( data.Global ) )
		end
		if data.OnActivate and isfunction( data.OnActivate ) then
			data.OnActivate( self )
		end
		if data.Remove then
			self:DoCustomRemove( data.Effect or 0 )
		else
			self.BlockEffects = true
		end
	else
		self:Remove()
	end
end

function ENT:DoCustomRemove(val)
	if val and isnumber(val) and val > 0 then
		ParticleEffect("bo3_qed_explode_"..val, self:GetPos(), angle_zero)
	end

	self:EmitSound("TFA_BO3_QED.Poof")

	self:Remove()
end

function ENT:PrintEffect( effect )
	local ply = self:GetOwner()
	if not IsValid(ply) or not ply:IsPlayer() then return end

	net.Start("TFA.BO3WW.FOX.QuantumBomb.Text", true)
		net.WriteString(effect)
	net.Send(ply)
end

function ENT:SendAnnouncerVox( soundpath, global )
	local ply = self:GetOwner()
	if not IsValid(ply) or not ply:IsPlayer() then return end

	net.Start("TFA.BO3WW.FOX.QuantumBomb.Vox", true)
		net.WriteString(soundpath)
	return tobool(global) and net.Broadcast() or net.Send(ply)
end

function ENT:OnRemove()
	BaseClass.OnRemove(self)

	self:StopParticles()
end
