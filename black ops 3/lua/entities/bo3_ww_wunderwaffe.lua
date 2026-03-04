
AddCSLuaFile()

ENT.Base = "tfa_ww_base"
ENT.PrintName = "Lightning Ball"

// Custom Settings

// Sounds
ENT.LaunchSound = "TFA_BO3_WAFFE.Ext"
ENT.TrailSound = "TFA_BO3_WAFFE.Loop"
ENT.BounceSound = "TFA_BO3_WAFFE.Bounce"
ENT.ImpactFluxSound = "TFA_BO3_WAFFE.Flux"

ENT.ExplosionSound = "TFA_BO3_WAFFE.Impact"
ENT.ExplosionSoundWater = "TFA_BO3_WAFFE.ImpactWater"

ENT.JumpStartSound = "TFA_BO3_WAFFE.Jump"
ENT.DeathSound = "TFA_BO3_WAFFE.Death"
ENT.SizzleSound = "TFA_BO3_WAFFE.Sizzle"
ENT.ZapEntitySound = "TFA_BO3_WAFFE.Zap"

// Effects
ENT.TrailEffect = "bo3_waffe_trail"
ENT.TrailEffectPaP = "bo3_waffe_trail_2"

ENT.ImpactEffect = "bo3_waffe_impact"
ENT.ImpactEffectPaP = "bo3_waffe_impact_2"

ENT.ElectrocuteEffect = "bo3_waffe_electrocute"
ENT.ElectrocuteEffectPaP = "bo3_waffe_electrocute_2"

ENT.GroundEffect = "bo3_waffe_ground"
ENT.GroundEffectPaP = "bo3_waffe_ground_2"

// Vars
ENT.ArcDelay = 0.2

ENT.MaxChain = 10
ENT.MaxChainPaP = 24

ENT.ZapRange = 300
ENT.ZapRangePaP = 500
ENT.ZapRangeStart = 200

ENT.AttachNPCEffect = false
ENT.PlayerShockRange = 64
ENT.Decay = 20

// Default Settings

ENT.Delay = 10

ENT.InfiniteDamage = true

ENT.NoDrawNoShadow = true

ENT.HullMaxs = Vector(1, 1, 1)
ENT.HullMins = ENT.HullMaxs:GetNegated()

ENT.FindCharacterOnly = true

ENT.WaterSplashSize = 12

ENT.ImpactBubbles = true
ENT.ImpactBubblesSize = 32
ENT.ImpactBubblesMagnitude = 1

//ENT.RemoveInWater = true

ENT.ImpactDecal = "Scorch"

// Explosion Settings

ENT.ScreenShakeAmplitude = 6
ENT.ScreenShakeFrequency = 255
ENT.ScreenShakeDuration = 1
ENT.ScreenShakeRange = 200

// DLight Settings

ENT.Color = Color(200, 230, 255, 255)
ENT.ColorPaP = Color(255, 200, 200, 255)

ENT.DLightBrightness = 2
ENT.DLightDecay = 2000
ENT.DLightSize = 250

DEFINE_BASECLASS(ENT.Base)

local nzombies = engine.ActiveGamemode() == "nzombies"
local damage_cvar = GetConVar("sv_tfa_bo3ww_environmental_damage")
local dlight_cvar = GetConVar("cl_tfa_fx_wonderweapon_dlights")

local BodyTarget = TFA.WonderWeapon.BodyTarget
local ShouldDamage = TFA.WonderWeapon.ShouldDamage
local Impulse = TFA.WonderWeapon.CalculateImpulseForce

local SF_BUTTON_SPARK_IF_OFF = 4096

function ENT:SetupDataTables()
	BaseClass.SetupDataTables(self)

	self:NetworkVarTFA("Bool", "Activated")
	self:NetworkVarTFA("Entity", "Target")
	self:NetworkVarTFA("Int", "Kills")
end

function ENT:PhysicsCollide(data, phys)
	if self:GetActivated() then return end

	self.killtime = CurTime() + self.Delay

	SafeRemoveEntityDelayed(self, self.Delay)

	self:StopSound(self.TrailSound)

	local trace = self:CollisionDataToTrace(data)
	local direction = data.OurOldVelocity:GetNormalized()
	local hitEntity = trace.Entity
	local owner = self:GetOwner()

	self:DoImpactEffect(trace)

	if data.TheirNewVelocity:Length() < 20 then
		ParticleEffect(self.ImpactEffect, data.HitPos - data.HitNormal, data.HitNormal:Angle() - Angle(90,0,0))
	end

	if damage_cvar and damage_cvar:GetBool() then
		self:CheckHammerIO(trace)
	end

	if trace.Hit and IsValid(hitEntity) and ShouldDamage(hitEntity, owner, self) then
		local hitDamage = DamageInfo()
		hitDamage:SetDamage(50)
		hitDamage:SetAttacker(IsValid(owner) and owner or self)
		hitDamage:SetInflictor(IsValid(self.Inflictor) and self.Inflictor or self)
		hitDamage:SetDamageType(nzombies and DMG_SHOCK or bit.bor( DMG_SHOCK, DMG_NEVERGIB ))
		hitDamage:SetDamageForce(direction*2000)
		hitDamage:SetDamagePosition(trace.HitPos)
		hitDamage:SetReportedPosition(trace.StartPos)

		local hitCharacter = hitEntity:IsNPC() or hitEntity:IsNextBot() or hitEntity:IsPlayer()
		if (hitCharacter or hitEntity:IsRagdoll()) then
			TFA.WonderWeapon.DoDeathEffect(hitEntity, "BO3_Wunderwaffe", math.Rand( 4, 6 ), self:GetUpgraded())
			
			if hitCharacter and self.DeathSound then
				hitEntity:EmitSound(self.DeathSound)
			end

			if hitCharacter and self.ZapEntitySound then
				sound.Play(self.ZapEntitySound, self.HitPos)
			end
		elseif ( damage_cvar == nil or damage_cvar:GetBool() ) then
			TFA.WonderWeapon.DoDeathEffect(hitEntity, "BO3_Wunderwaffe", math.Rand( 3, 4 ), self:GetUpgraded())
		end

		hitEntity:DispatchTraceAttack(hitDamage, trace, direction)

		self:SendHitMarker(hitEntity, hitDamage, trace)
	end

	// ricochet sparks taking into account our prior direction
	local hitDot = trace.HitNormal:Dot(-direction)
	direction:Add(2 * hitDot * trace.HitNormal)
	direction:Normalize()

	local fx = EffectData()
	fx:SetOrigin(data.HitPos)
	fx:SetNormal(direction)
	fx:SetScale(1)
	fx:SetMagnitude(4)

	util.Effect("ElectricSpark", fx, false, true)

	TFA.WonderWeapon.ShockClientRagdolls( data.HitPos, 16, self:GetUpgraded() )

	self:PhysicsStop(phys)

	self:OnCollide(data.HitEntity, data.HitPos - data.HitNormal)
end

function ENT:EntityCollide(trace)
	if self:GetActivated() then return end

	self.killtime = CurTime() + self.Delay
	SafeRemoveEntityDelayed(self, self.Delay)

	self:StopSound(self.TrailSound)
	
	self:PhysicsStop(phys)

	local hitEntity = trace.Entity

	self:DoImpactEffect(trace)

	ParticleEffect(self.ImpactEffect, trace.HitPos, trace.HitNormal:Angle() - Angle(90,0,0))

	if damage_cvar and damage_cvar:GetBool() then
		self:CheckHammerIO(trace)
	end

	local hitCharacter = hitEntity:IsNPC() or hitEntity:IsNextBot() or hitEntity:IsPlayer()

	if !hitCharacter then
		local hitDamage = DamageInfo()
		hitDamage:SetDamage(50)
		hitDamage:SetAttacker(IsValid(self:GetOwner()) and self:GetOwner() or self)
		hitDamage:SetInflictor(IsValid(self.Inflictor) and self.Inflictor or self)
		hitDamage:SetDamageType(nzombies and DMG_SHOCK or bit.bor( DMG_SHOCK, DMG_NEVERGIB ))
		hitDamage:SetDamageForce(trace.Normal*2000)
		hitDamage:SetDamagePosition(trace.HitPos)
		hitDamage:SetReportedPosition(trace.StartPos)

		if hitEntity:IsRagdoll() then
			TFA.WonderWeapon.DoDeathEffect(hitEntity, "BO3_Wunderwaffe", math.Rand( 4, 6 ), self:GetUpgraded())
			
			if hitCharacter and self.DeathSound then
				hitEntity:EmitSound(self.DeathSound)
			end

			if hitCharacter and self.ZapEntitySound then
				sound.Play(self.ZapEntitySound, self.HitPos)
			end
		elseif ( damage_cvar == nil or damage_cvar:GetBool() ) then
			TFA.WonderWeapon.DoDeathEffect(hitEntity, "BO3_Wunderwaffe", math.Rand( 3, 4 ), self:GetUpgraded())
		end

		hitEntity:DispatchTraceAttack(hitDamage, trace, trace.HitNormal)

		self:SendHitMarker(hitEntity, hitDamage, trace)
	end

	local fx = EffectData()
	fx:SetOrigin( trace.HitPos )
	fx:SetNormal( trace.HitNormal )
	fx:SetScale( 1 )
	fx:SetMagnitude( 4 )

	util.Effect( "ElectricSpark", fx, false, true )

	if not (hitEntity:IsPlayer() or hitEntity:IsNPC() or hitEntity:IsNextBot()) then
		util.Decal("Scorch", trace.HitPos, trace.HitPos + trace.Normal*4)
	end

	self:OnCollide(trace.HitEntity, trace.HitPos)
	return false
end

function ENT:Initialize()
	BaseClass.Initialize(self)

	self:EmitSound(self.LaunchSound)

	if self:GetUpgraded() then
		self.TrailEffect = self.TrailEffectPaP
		self.ImpactEffect = self.ImpactEffectPaP
		self.ElectrocuteEffect = self.ElectrocuteEffectPaP
		self.GroundEffect = self.GroundEffectPaP

		self.MaxChain = self.MaxChainPaP
		self.ZapRange = self.ZapRangePaP
	end
end

function ENT:CheckHammerIO(trace)
	local nearbyEnts = ents.FindInSphere( trace.HitPos, 8 )

	for _, button in pairs(nearbyEnts) do
		if button:GetClass() == 'func_button' and button:GetInternalVariable( 'm_bLocked' ) == true and not button:HasSpawnFlags( SF_BUTTON_SPARK_IF_OFF ) then
			// recreate SF_BUTTON_SPARK_IF_OFF think function

			button:AddSpawnFlags( SF_BUTTON_SPARK_IF_OFF )

			local direction = (trace.HitPos - button:GetPos()):GetNormalized()

			local hookName = "WaffeButtonSparkler" .. button:EntIndex()

			local flNextSparkThink = CurTime() + math.Rand( 0, 1.5 )
			local flSparkThinkEnd = CurTime() + math.random( 4, 6 )

			hook.Add( "Think", hookName, function()
				if not IsValid( button ) then
					hook.Remove( hookName )
					return
				end

				if flSparkThinkEnd < CurTime() then
					button:RemoveSpawnFlags( SF_BUTTON_SPARK_IF_OFF )
					hook.Remove( hookName )
					return
				end

				if flNextSparkThink > CurTime() then return end
				flNextSparkThink = CurTime() + math.Rand( 0, 1.5 )

				local fx = EffectData()
				fx:SetOrigin(button:WorldSpaceCenter())
				fx:SetRadius(1)
				fx:SetMagnitude(2)
				fx:SetScale(1)
				fx:SetNormal(direction)
				fx:SetEntity(button)

				util.Effect( "ElectricSpark", fx )

				button:EmitSound( "DoSpark" )
			end )

			break
		end

		if button:GetClass() == 'func_button' and button:GetInternalVariable('m_bLocked') == false then
			local qtr = util.QuickTrace(trace.HitPos, -trace.HitNormal*8, self)
			if qtr.Hit and IsValid( qtr.Entity ) and qtr.Entity == button then
				button:Fire('Press', nil, 0, owner, owner)
				break
			end
		end
	end

	for _, laser in pairs(nearbyEnts) do
		if laser:GetClass() == 'env_laser' and not laser:IsEffectActive(EF_NODRAW) then
			local resetHook = "WaffeLaserReset"..(laser:CreatedByMap() and laser:MapCreationID() or laser:GetCreationID())
			if timer.Exists(resetHook) then
				timer.Remove(resetHook)
			end

			laser:Fire('Toggle', nil, 0, owner, owner)

			local name = laser:GetInternalVariable('LaserTarget')
			if name and isstring( name ) and name ~= "" then
				local targets = ents.FindByName(name)
				for _, model in pairs(targets) do
					model:Fire('Toggle', nil, 0, owner, owner)
				end
			end

			timer.Create(resetHook, math.Rand(3, 4), 1, function()
				if not IsValid( laser ) then return end
				if not laser:IsEffectActive(EF_NODRAW) then return end

				laser:Fire('Toggle', nil, 0, owner, owner)

				local name = laser:GetInternalVariable('LaserTarget')
				if name and isstring( name ) and name ~= "" then
					local targets = ents.FindByName(name)
					for _, model in pairs(targets) do
						model:Fire('Toggle', nil, 0, owner, owner)
					end
				end
			end)

			break
		end
	end
end

function ENT:OnWaterEnter(waterTrace, collisionTrace)
	self:StopSound(self.TrailSound)

	sound.Play(self.ExplosionSoundWater, waterTrace.HitPos)

	self.HitPos = waterTrace.HitPos
	self.HitNormal = -waterTrace.HitNormal
	self.HitEntity = waterTrace.Entity
	self:SetHitPos(self.HitPos)

	local fx = EffectData()
	fx:SetOrigin(waterTrace.HitPos)
	fx:SetNormal(-waterTrace.HitNormal)
	fx:SetScale(1)
	fx:SetMagnitude(4)

	util.Effect("ElectricSpark", fx, false, true)

	ParticleEffect(self.ImpactEffect, waterTrace.HitPos - waterTrace.HitNormal, waterTrace.HitNormal:Angle() + Angle(90,0,0))

	local fx = EffectData()
	fx:SetOrigin(waterTrace.HitPos)
	fx:SetNormal(collisionTrace.Normal)
	fx:SetScale(2)

	util.Effect("MetalSpark", fx, false, true)

	self:Remove()
end

function ENT:OnCollide(ent, vecSrc)
	if self:GetActivated() then return end
	self:SetActivated(true)

	self.BlockCollisionTrace = true

	self:ScreenShake(vecSrc)

	self:EmitSound(self.ExplosionSound)
	self:StopSound(self.TrailSound)

	self:PhysicsStop()

	local ply = self:GetOwner()

	timer.Simple(0, function()
		if not IsValid(self) then return end
		self:SetMoveType(MOVETYPE_NONE)
		self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
		self:SetPos(vecSrc)
		self:StopParticles()

		if self.FiredFromAFuckingGun and IsValid(ply) and !nZSTORM then
			local direction = (ply:WorldSpaceCenter() - vecSrc):GetNormalized()
			local trace = util.TraceLine({
				start = vecSrc,
				endpos = vecSrc + direction*self.PlayerShockRange,
				filter = self,
				mask = MASK_SHOT,
			})

			// self damage cause i hate you :)
			if trace.Hit and trace.Entity == ply then
				local hitDamage = DamageInfo()
				hitDamage:SetDamage(50 * math.Remap(math.Clamp(1 - trace.Fraction, 0, 1), 0, 1, 0.4, 1))
				hitDamage:SetAttacker(nzombies and self or ply)
				hitDamage:SetInflictor(self)
				hitDamage:SetDamageType(nzombies and DMG_SHOCK or bit.bor( DMG_SHOCK, DMG_NEVERGIB ))
				hitDamage:SetDamageForce(direction*200)
				hitDamage:SetDamagePosition(trace.HitPos)
				hitDamage:SetReportedPosition(trace.StartPos)

				ply:DispatchTraceAttack(hitDamage, trace, direction)
			end
		end

		self:SetTarget(self:FindNearestEntity(self:GetPos(), self.ZapRangeStart, nil, true))

		if not IsValid(self:GetTarget()) then
			self:CreateGlowSprite(0, self.Color, 255, 0.8, nil, nil, nil, self:GetHitPos())
			self:Remove()
			return
		end

		self:Zap(self:GetTarget())

		self:SetKills(0)

		if self.JumpStartSound then
			self:EmitSound(self.JumpStartSound)
		end

		if self.ImpactFluxSound then
			sound.Play(self.ImpactFluxSound, vecSrc)
		end

		local timername = "waffechaintimer"..self:EntIndex()
		timer.Create(timername, self.ArcDelay, self.MaxChain, function()
			if not IsValid(self) then
				timer.Stop(timername)
				timer.Remove(timername)
				return
			end

			self:SetTarget(self:FindNearestEntity(self:GetPos(), self.ZapRange, nil, true))

			if not IsValid(self:GetTarget()) then
				timer.Stop(timername)
				timer.Remove(timername)
				SafeRemoveEntity(self)
				return
			end

			local tr = util.TraceLine({
				start = self:WorldSpaceCenter(),
				endpos = self:GetTarget():EyePos(),
				filter = {self, self:GetTarget(), self:GetOwner()},
				mask = MASK_SOLID_BRUSHONLY,
			}) //instead of removing if we hit a wall, just increase the decay penalty.

			self.ZapRange = self.ZapRange - (self.Decay * (tr.HitWorld and 3 or 1))
			self:Zap(self:GetTarget())
			self:SetKills(self:GetKills() + 1)

			if self:GetKills() == 5 then
				local wep = self:GetOwner():GetActiveWeapon()
				if IsValid(wep) and string.find(wep:GetClass(), "wunderwaffe") then
					wep:EmitSound("TFA_BO3_WAFFE.Meow.Happy")

					if wep.HappyLights then
						wep:CallOnClient("HappyLights")
					end

					if wep.GetNextWave and (wep:GetNextWave() - 2) < CurTime() then
						wep:SetNextWave(CurTime() + math.Rand(2, 4))
					end
				end
			end

			if self:GetKills() >= self.MaxChain then
				timer.Stop(timername)
				timer.Remove(timername)
				self:Remove()
				return
			end
		end)
	end)
end

function ENT:Zap(ent)
	self.HeadShot = math.random(10) < 4
	self.HitPos = BodyTarget(ent, self:GetPos(), true, self.HeadShot)

	local ply = IsValid(self:GetOwner()) and self:GetOwner() or self

	local fx = EffectData()
	fx:SetStart(self:GetPos())
	fx:SetOrigin(self.HitPos)
	fx:SetFlags(self:GetUpgraded() and 1 or 0)

	util.Effect("tfa_bo3_waffe_jump", fx)

	if ( ent:IsNPC() or ent:IsNextBot() or ent:IsPlayer() ) then
		TFA.WonderWeapon.DoDeathEffect(ent, "BO3_Wunderwaffe", math.Rand( 4, 6 ), self:GetUpgraded(), self.HeadShot)
	else
		ParticleEffectAttach(self.ElectrocuteEffect, PATTACH_POINT_FOLLOW, ent, 1)
		if ent:OnGround() then
			ParticleEffectAttach(self.GroundEffect, PATTACH_ABSORIGIN_FOLLOW, ent, 1)
		end
	end

	if self.BounceSound then
		self:EmitSound(self.BounceSound)
	end

	if self.DeathSound then
		ent:EmitSound(self.DeathSound)
	end

	if self.SizzleSound then
		ent:EmitSound(self.SizzleSound)
	end

	if self.ZapEntitySound then
		sound.Play(self.ZapEntitySound, self.HitPos)
	end

	if self.HeadShot then
		if ent.GetBloodColor then
			local BloodParticle = TFA.WonderWeapon.ParticleByBloodColor[ent:GetBloodColor()]
			if BloodParticle then
				ParticleEffect(BloodParticle, self.HitPos, ent:EyeAngles())
			end
		end

		sound.Play("TFA_BO3_WAFFE.Pop", self.HitPos)
		sound.Play("TFA_BO3_GENERIC.Gore", self.HitPos)
	end

	local finalPos = self.HitPos
	timer.Simple( 0, function()
		if not IsValid( self ) then return end
		self:SetPos( finalPos )
	end )

	self:InflictDamage(ent)

	self:IgnoreEntity(ent, 1.5)
end

function ENT:InflictDamage(ent)
	if CLIENT then return end
	local ply = self:GetOwner()

	local damage = DamageInfo()
	damage:SetDamage(self:GetTrueDamage(ent))
	damage:SetAttacker(IsValid(ply) and ply or self)
	damage:SetInflictor(IsValid(self.Inflictor) and self.Inflictor or self)
	damage:SetDamageType(nzombies and DMG_SHOCK or bit.bor( DMG_SHOCK, DMG_NEVERGIB ))
	damage:SetDamageForce(ent:GetUp()*1000 + (ent:GetPos() - self:GetPos()):GetNormalized()*Impulse(ent, 80))
	damage:SetDamagePosition(self.HitPos or ent:WorldSpaceCenter())
	damage:SetReportedPosition(self:GetPos())

	if nzombies and (ent.NZBossType or ent.IsMooBossZombie or ent.IsMooMiniBoss) then
		damage:SetDamage(math.max(2200, ent:GetMaxHealth() / 9))
	end

	if ent:IsNPC() and ent:Alive() and damage:GetDamage() >= ent:Health() then
		ent:SetCondition(COND.NPC_UNFREEZE)
	end

	ent:TakeDamageInfo(damage)

	self:SendHitMarker(ent, damage)
end

function ENT:OnRemove()
	self:StopSound("TFA_BO3_WAFFE.Loop")
	self:StopSound(self.TrailSound)

	if CLIENT and self:GetKills() <= 0 and dlight_cvar:GetBool() and DynamicLight then
		self.DLight = self.DLight or DynamicLight(self:EntIndex())
		if (self.DLight) then
			self.DLight.pos = !self:GetHitPos():IsZero() and self:GetHitPos() or self:GetPos()
			self.DLight.r = self.Color.r
			self.DLight.g = self.Color.g
			self.DLight.b = self.Color.b
			self.DLight.brightness = 2
			self.DLight.Decay = 500
			self.DLight.Size = 300
			self.DLight.DieTime = CurTime() + 2
		end
	end
end
