
AddCSLuaFile()

ENT.Base = "tfa_ww_base"
ENT.PrintName = "Keeper Sword"

// Custom Settings

ENT.Life = 25

ENT.Kills = 0
ENT.MaxKills = 24
ENT.RPM = 120

ENT.ReturnSound = "TFA_BO3_KPRSWORD.Return"

ENT.TargetRange = 256

// Default Settings

ENT.Delay = 60

ENT.InfiniteDamage = true

ENT.Range = 160

ENT.TrailSound = "TFA_BO3_KPRSWORD.Loop"

ENT.TrailEffect = "bo3_keepersword_trail"
ENT.TrailAttachType = PATTACH_POINT_FOLLOW
ENT.TrailAttachPoint = 2

ENT.HullMaxs = Vector(4, 2, 32)
ENT.HullMins = Vector(-4, -2, 0)

ENT.FindCharacterOnly = true

ENT.WaterSplashSize = 10

ENT.ImpactBubbles = true
ENT.ImpactBubblesSize = 64
ENT.ImpactBubblesMagnitude = 1

// DLight Settings

ENT.Color = Color(255, 50, 10)

ENT.DLightBrightness = 1
ENT.DLightDecay = 1000
ENT.DLightSize = 200

DEFINE_BASECLASS( ENT.Base )

local nzombies = engine.ActiveGamemode() == "nzombies"
local pvp_bool = GetConVar("sbox_playershurtplayers")
local dlight_cvar = GetConVar("cl_tfa_fx_wonderweapon_dlights")
local SinglePlayer = game.SinglePlayer()

local BodyTarget = TFA.WonderWeapon.BodyTarget

function ENT:SetupDataTables()
	BaseClass.SetupDataTables(self)

	self:NetworkVarTFA("Bool", "Activated")

	self:NetworkVarTFA("Float", "NextPrimaryFire")

	self:NetworkVarTFA("Entity", "Attacker")
	self:NetworkVarTFA("Entity", "Inflictor")
end

if SERVER then
	function ENT:GravGunPickupAllowed()
		return false
	end
end

function ENT:GravGunPunt()
	return false
end

function ENT:EntityCollide(trace)
	if not self:GetActivated() then
		return
	end

	local hitEntity = trace.Entity

	self.Kills = self.Kills + 1
	
	self:IgnoreEntityCollisions( hitEntity, 1.5 )

	self:IgnoreEntity( hitEntity, 1.5 )

	if self.Kills >= self.MaxKills then
		self:SetActivated(false)
	end

	local hitDamage = DamageInfo()
	hitDamage:SetDamage(self:GetTrueDamage(hitEntity))
	hitDamage:SetAttacker(IsValid(self:GetAttacker()) and self:GetAttacker() or self)
	hitDamage:SetInflictor(IsValid(self:GetInflictor()) and self:GetInflictor() or self)
	hitDamage:SetDamagePosition(math.random(4) == 1 and trace.HitPos or BodyTarget(hitEntity, trace.StartPos, false, true))
	hitDamage:SetDamageType(bit.bor(DMG_SLOWBURN, DMG_SLASH))
	hitDamage:SetReportedPosition(trace.StartPos)

	if nzombies and (hitEntity.NZBossType or hitEntity.IsMooBossZombie or hitEntity.IsMooMiniBoss) then
		hitDamage:SetDamage(math.max(1200, hitEntity:GetMaxHealth() / 8))
	end

	hitEntity:Ignite(1.5)

	if hitEntity:IsNPC() then
		hitEntity:SetHealth(1)
		hitEntity:SetCondition(COND.NPC_UNFREEZE)
	end

	hitEntity:TakeDamageInfo(hitDamage)

	self:SendHitMarker(hitEntity, hitDamage, trace)

	ParticleEffect("bo3_keepersword_hit", trace.HitPos, trace.Normal)

	sound.Play("TFA_BO3_ZODSWORD.Impact", trace.HitPos)

	if IsValid( self.Target ) then
		self:SetAngles( -self.Target:GetForward():Angle() )
	end

	self:SetNextPrimaryFire( CurTime() + ( 60 / self.RPM ) )

	local EnumToSeq = self:SelectWeightedSequence( ACT_RESET )
	self:ResetSequence( EnumToSeq )

	local huntPos = IsValid( ply ) and ply:GetPos() or self:GetPos()
	self.Target = self:FindNearestEntity( huntPos, self.Range )
end

function ENT:Initialize()
	BaseClass.Initialize(self)

	self:SetActivated(true)

	self.AutomaticFrameAdvance = true
	self:ResetSequence("idle")

	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:AddGameFlag( FVPHYSICS_NO_PLAYER_PICKUP )
		phys:AddGameFlag( FVPHYSICS_CONSTRAINT_STATIC )
	end

	if CLIENT then return end

	self.Ratio = engine.TickInterval()*5

	self.EndTime = CurTime() + self.Life
end

function ENT:Think()
	if SERVER then
		if self.Target and IsValid( self.Target ) and self:GetNextPrimaryFire() < CurTime() then
			if self:GetSequence() ~= self:SelectWeightedSequence( ACT_WALK ) then
				self:ResetSequence( "locomote" )
			end

			local normalized = ( self.Target:EyePos() - self:GetPos() ):GetNormalized()

			self:SetPos( LerpVector( self.Ratio, self:GetPos(), self.Target:EyePos() + normalized*4 ) )
			self:SetAngles( LerpAngle( self.Ratio, self:GetAngles(), normalized:Angle() ) )
		end

		if self:GetActivated() and ( not self.Target or not IsValid( self.Target ) ) and self:GetNextPrimaryFire() < CurTime() then
			if self:GetSequence() ~= self:SelectWeightedSequence(ACT_IDLE) then
				self:ResetSequence( "idle" )
			end

			self.Target = self:FindNearestEntity( self:GetPos(), self.TargetRange )

			if IsValid(ply) and ply:Alive() then
				local forward = Angle( 0, ply:EyeAngles()[2], ply:EyeAngles()[3] ):Forward()
				local finalpos = ply:GetShootPos() + self:GetRight() * 30 + forward * 40
				self:SetPos( LerpVector( self.Ratio, self:GetPos(), finalpos ) )

				local finalang = Angle(0, ply:GetAimVector():Angle()[2], 0)
				self:SetAngles( LerpAngle( self.Ratio, self:GetAngles(), finalang ) )
			end
		end

		if not self:GetActivated() and not IsValid( self.Target ) then
			if IsValid(ply) then
				if ply:Alive() then
					self:SetPos( LerpVector( 0.1, self:GetPos(), ply:GetShootPos() ) )
					self:SetAngles( LerpAngle( 0.1, self:GetAngles(), -ply:GetForward():Angle() ) )

					if self:GetPos():DistToSqr( ply:GetShootPos() ) < 16^2 then
						self:Remove()
					end
				else
					self:Remove()
				end
			end
		end

		if self.EndTime and self.EndTime < CurTime() and self:GetActivated() then
			self:SetActivated(false)
		end
	end

	return BaseClass.Think(self)
end

function ENT:ReturnToOwner()
	self:StopSound(self.TrailSound)

	local ent = self:GetOwner()
	if not IsValid(ent) or not ent.GetActiveWeapon then return end

	ent:EmitSound(self.ReturnSound)

	if not nzombies then
		local wep = ent:GetWeapon("tfa_bo3_keepersword")
		if IsValid(wep) then
			wep:SetHasNuked(false)
		end
	end

	self:Remove()
end

function ENT:OnRemove()
	BaseClass.OnRemove(self)

	self:ReturnToOwner()
end
