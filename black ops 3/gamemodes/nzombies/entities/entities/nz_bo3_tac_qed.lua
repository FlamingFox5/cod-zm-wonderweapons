
AddCSLuaFile()

ENT.Base = "nz_ww_tacnade_base"
ENT.PrintName = "Q.E.D. (nZombies)"

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

// nZombies Settings

ENT.NZThrowIcon = Material("vgui/icon/hud_quantum_bomb.png", "unlitgeneric smooth")

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

local WonderWeapons = TFA.WonderWeapon
local BodyTarget = WonderWeapons.BodyTarget
local GiveStatus = WonderWeapons.GiveStatus
local HasStatus = WonderWeapons.HasStatus
local ShouldDamage = WonderWeapons.ShouldDamage
local WeightedRandom = TFA.WonderWeapon.WeightedRandom

DEFINE_BASECLASS(ENT.Base)

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

	local tab = player.GetAllPlaying()
	if not tab or table.IsEmpty(tab) then
		tab = player.GetAll()
	end

	//check for players to be revived first
	for _, ply in pairs(tab) do
		if not ply:GetNotDowned() then
			if math.random(15) <= (1 * #tab) then --6.6%
				nzQuantumBomb:ActivateEffect( "Revive_All_Players", self )
				return
			end
		end
	end

	//check for open box
	if math.random(200) <= 1 and !nzPowerUps:IsPowerupActive("firesale") then --0.5%
		local box = ents.FindByClass("random_box")[1]
		if IsValid(box) and box.Close and box.GetOpen and box:GetOpen() then
			nzQuantumBomb:ActivateEffect( "Close_Random_Box", self, box )
			return
		end
	end

	//check nearby entities
	for k, v in pairs(ents.FindInSphere(self:GetPos(), 128)) do
		//perk machine
		if v:GetClass() == 'perk_machine' then
			if math.random(100) <= 1 then --1%
				nzQuantumBomb:ActivateEffect( "Perk_Machine", self, v )
				return
			end
		end

		//blackhole
		if v:GetClass() == 'nz_bo3_tac_gersch' then
			if math.random(25) <= 1 then --4%
				nzQuantumBomb:ActivateEffect( "Gersh_Powerup", self )
				return
			end
		end

		//excavator
		local m_BladeNames = {
			['piblade'] = true,
			['omicronblade'] = true,
			['epsilonblade'] = true
		}

		if v:GetClass() == 'prop_dynamic' and m_BladeNames[ v:GetName() ] and v:GetSequence() == 3 then
			nzQuantumBomb:ActivateEffect( "RecallExcavator", self, v )
			return
		end
	end

	local effect = WeightedRandom( nzQuantumBomb:GetWeightedTable() )

	// return a string of an existing Q.E.D. effect to overwrite the randomly selected one
	local hookEffect = hook.Run( "TFA_WonderWeapon_QuantumBombEffect", self, effect )
	if hookEffect and isstring( hookEffect ) and nzQuantumBomb:GetEffect( hookEffect ) then
		effect = hookEffect
	end

	nzQuantumBomb:ActivateEffect( effect, self )

	local data = nzQuantumBomb:GetEffect( effect )
	if data then
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

function ENT:PrintEffect( effect, name )
	local ply = self:GetOwner()
	if not IsValid(ply) or not ply:IsPlayer() then return end

	net.Start("NZ.BO3WW.FOX.QuantumBomb.Text", true)
		net.WriteString(effect)
		net.WriteString(name)
	net.Send(ply)
end

function ENT:SendAnnouncerVox( soundpath, global )
	local ply = self:GetOwner()
	if not IsValid(ply) or not ply:IsPlayer() then return end

	net.Start("NZ.BO3WW.FOX.QuantumBomb.Vox", true)
		net.WriteString(soundpath)
	return tobool(global) and net.Broadcast() or net.Send(ply)
end

function ENT:OnRemove()
	BaseClass.OnRemove(self)

	self:StopParticles()
end

function ENT:FindSpotNearPlayer(ent, pos, accuracy, range, stepd, stepu)
	local targ = ent:GetTarget()

	pos = pos or targ:GetPos()
	range = range or 100
	stepd = stepd or 25
	stepu = stepu or 25
	accuracy = accuracy or 6

	local posOG = pos
	local failed = true
	local navfailed = true

	if navmesh.IsLoaded() then
		local tab = navmesh.Find(pos, range, stepd, stepu)
		local postab = {}

		for i=1, accuracy do
			for _, nav in RandomPairs(tab) do
				if IsValid(nav) and not nav:IsUnderwater() then
					local testpos = nav:GetRandomPoint()
					if testpos:DistToSqr(pos) > 256 then
						table.insert(postab, testpos)
						break
					end
				end
			end
		end

		if not table.IsEmpty(postab) then
			table.sort(postab, function(a, b) return a:DistToSqr(pos) < b:DistToSqr(pos) end)
			pos = postab[1]
		else
			navfailed = true
		end
	end

	local minBound, maxBound = ent:OBBMins(), ent:OBBMaxs()
	if not TFA.WonderWeapon.IsCollisionBoxClear( pos, ent, minBound, maxBound ) then
		local surroundingTiles = TFA.WonderWeapon.GetSurroundingTiles( ent, pos )
		local clearPaths = TFA.WonderWeapon.GetClearPaths( ent, pos, surroundingTiles )	
		for _, tile in pairs( clearPaths ) do
			if TFA.WonderWeapon.IsCollisionBoxClear( tile, ent, minBound, maxBound ) and tile:DistToSqr(posOG) > 256 then
				pos = tile
				failed = false
				break
			end
		end
	else
		if pos ~= posOG then
			failed = false
		end
	end

	return pos + vector_up, failed or navfailed
end
