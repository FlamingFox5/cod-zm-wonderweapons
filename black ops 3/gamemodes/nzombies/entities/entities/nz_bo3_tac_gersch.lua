
AddCSLuaFile()

ENT.Base = "nz_ww_tacnade_base"
ENT.PrintName = "Black Hole (nZombies)"

// Custom Settings

ENT.BlackHoleStart = "TFA_BO3_GERSCH.BHStart"

ENT.BlackHoleLoopFar = "TFA_BO3_GERSCH.BHLoopFar"
ENT.BlackHoleLoopClose = "TFA_BO3_GERSCH.BHLoopClose"

ENT.BlackHoleEnding = "TFA_BO3_GERSCH.BHPrePop"
ENT.BlackHoleCollapse = "TFA_BO3_GERSCH.BHPop"

ENT.Kills = 0

ENT.BossRange = 600

// Default Settings

ENT.ForcedKillTime = 30

ENT.Delay = 8
ENT.DelayPaP = 16

ENT.HullMaxs = Vector(1, 1, 1)
ENT.HullMins = ENT.HullMaxs:GetNegated()

ENT.BounceSound = "TFA_BO3_GERSCH.Bounce"
ENT.BounceActivationSpeed = 100
ENT.BounceVelocityRatio = 0.4

ENT.DisablePhysicsOnActivate = true

ENT.ParentToMoveableEntities = true

ENT.ImpactBubbles = true
ENT.ImpactBubblesSize = 32
ENT.ImpactBubblesMagnitude = 0.5

// DLight Settings

ENT.Color = Color(185, 70, 255)
ENT.ColorPaP = Color(255, 40, 10)

ENT.DLightBrightness = 2
ENT.DLightDecay = 1000
ENT.DLightSize = 500

ENT.DLightOnActivated = true

ENT.DLightFlashOnRemove = true

ENT.DLightFlashSize = 500
ENT.DLightFlashDecay = 2000
ENT.DLightFlashBrightness = 2

// nZombies Settings

ENT.BHBomb = true

ENT.NZThrowIcon = Material("vgui/icon/hud_blackhole.png", "unlitgeneric smooth")
ENT.NZTacticalPaP = true

DEFINE_BASECLASS(ENT.Base)

local dlight_cvar = GetConVar("cl_tfa_fx_wonderweapon_dlights")

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end

function ENT:SetupDataTables()
	BaseClass.SetupDataTables(self)

	self:NetworkVarTFA("Bool", "Dying")

	self:NetworkVarTFA("Vector", "TelePos")
end

function ENT:ActivateCustom( phys )
	if CLIENT then return end

	self:SetActivated(true)

	timer.Simple(0, function()
		if not IsValid(self) then return end

		self:SetMoveType(MOVETYPE_NONE)
	end)

	util.ScreenShake(self:GetPos(), 10, 255, 1, 512)

	self:CreateCore()

	self:CreateExitCore()

	self.killtime = CurTime() + self.Delay

	self:SetTargetPriority(TARGET_PRIORITY_SPECIAL)
	UpdateAllZombieTargets(self)

	/*if game.GetMap() == "nz_moon" then
		local plate = ents.FindByName("plates_urt_trigger")[1]
		local filter = ents.FindByName('gersh_filter')[1]
		if IsValid(plate) then
			plate:Input("OnTrigger", self:GetOwner(), filter)
		end
	end*/
end

function ENT:CreateCore()
	local core = ents.Create("prop_dynamic")
	core:SetModel("models/dav0r/hoverball.mdl")
	core:SetModelScale(0.4, 0)
	core:SetPos(self:GetPos() + Vector(0,0,64))
	core:SetAngles(angle_zero)
	core:SetParent(self)
	core:SetMoveType(MOVETYPE_NONE)

	core:Spawn()

	self:DeleteOnRemove(core)

	timer.Simple(0, function()
		core:SetCollisionGroup(COLLISION_GROUP_NONE)
		core:SetSolid(SOLID_NONE)
	end)
	core:SetMaterial("models/weapons/tfa_bo3/gersch/lambert1")

	self.CoreMDL = core

	self.CoreMDL:EmitSound(self.BlackHoleStart)
	self.CoreMDL:EmitSound(self.BlackHoleLoopFar)
	self.CoreMDL:EmitSound(self.BlackHoleLoopClose)

	timer.Simple(0, function()
		if not IsValid(self) then return end
		ParticleEffectAttach(self:GetUpgraded() and "bo3_gersch_loop_pap" or "bo3_gersch_loop", PATTACH_ABSORIGIN_FOLLOW, self.CoreMDL, 0)
	end)
end

function ENT:CreateExitCore()
	local core2 = ents.Create("prop_dynamic")
	core2:SetModel("models/dav0r/hoverball.mdl")
	core2:SetModelScale(0.4, 0)
	core2:SetPos(self:GetTelePos() + Vector(0,0,64))
	core2:SetAngles(angle_zero)
	core2:SetParent(self)
	core2:SetMoveType(MOVETYPE_NONE)

	core2:Spawn()

	self:DeleteOnRemove(core2)

	timer.Simple(0, function()
		core2:SetCollisionGroup( COLLISION_GROUP_NONE )
		core2:SetSolid( SOLID_NONE )
	end)

	core2:SetMaterial("models/weapons/tfa_bo3/gersch/lambert1")

	self.CoreMDL2 = core2

	self.CoreMDL2:EmitSound(self.BlackHoleLoopClose)

	timer.Simple(0, function()
		if not IsValid(self) then return end
		ParticleEffectAttach(self:GetUpgraded() and "bo3_gersch_loop_2_pap" or "bo3_gersch_loop_2", PATTACH_ABSORIGIN_FOLLOW, self.CoreMDL2, 0)
	end)
end

function ENT:Initialize(...)
	BaseClass.Initialize(self, ...)

	if CLIENT then return end

	self:ConstructTeleportPos()
end

function ENT:Think()
	if SERVER then
		local ply = self:GetOwner()

		local core = self.CoreMDL
		if self:GetActivated() and IsValid(core) then
			local ply = self:GetOwner()
			local pos = self:GetPos()

			local killtrigger = ents.FindInSphere(core:GetPos(), 42)

			for k, v in pairs(killtrigger) do
				if v:IsValidZombie() then
					if v.NZBossType or v.IsMooBossZombie or v.IsMooMiniBoss then continue end
					if string.find(v:GetClass(), "zombie_boss") then continue end
					if v.SpawnProtection then continue end

					if !TFA.WonderWeapon.ShouldDamage(v, ply, self) then continue end

					self:InflictDamage(v)
				end

				if v:IsPlayer() and not v:IsOnGround() and math.abs(v:GetVelocity()[3]) > 0 then
					local vel = v:GetVelocity()
					v:SetPos(self:GetTelePos() + Vector(0,0,4))
					v:SetGroundEntity(nil)
					v:SetLocalVelocity(vel)

					sound.Play("TFA_BO3_GERSCH.Teleport", core:GetPos())
					v:EmitSound("TFA_BO3_GERSCH.TeleOut")

					ParticleEffectAttach("bo3_gersch_player_insanity", PATTACH_ABSORIGIN_FOLLOW, v, 1)
					self:BossCheck(v)
				end
			end
		end

		if self:GetDying() and self.CoreMDL and IsValid(self.CoreMDL) then
			self:SetPos(self:GetPos() + vector_up*0.7)
		end

		if self:GetActivated() and ( self.killtime - 1.4 ) < CurTime() and !self:GetDying() then
			self:EmitSound(self.BlackHoleEnding)

			if core and IsValid(core) then
				core:StopSound(self.BlackHoleLoopFar)
				core:StopSound(self.BlackHoleLoopClose)
				
				core:StopParticles()
				core:SetParent(nil)
			end

			if self.CoreMDL2 and IsValid(self.CoreMDL2) then
				self.CoreMDL2:SetParent(nil)
			end

			timer.Simple(0, function()
				if not (IsValid(self) and IsValid(core)) then return end
				ParticleEffectAttach(self:GetUpgraded() and "bo3_gersch_end_pap" or "bo3_gersch_end", PATTACH_ABSORIGIN_FOLLOW, core, 0)
			end)

			SafeRemoveEntityDelayed(self, 1.4)
			self:SetModelScale(0.1, 1.4)

			self:SetDying(true)
		end
	end

	return BaseClass.Think(self)
end

function ENT:BossCheck(ply)
	if not IsValid(ply) then return end

	for k, ent in pairs(ents.FindInSphere(self:GetPos(), self.BossRange)) do
		if not ent.IsMooBossZombie then continue end
		if not ent.GetTarget then continue end

		local target = ent:GetTarget()
		local core = self.CoreMDL
		local goalpos = self:GetPos()

		if IsValid(target) and target:EntIndex() == ply:EntIndex() then
			local timername = "panzer_redirect"..ent:EntIndex()
			local tickrate = 1 / engine.TickInterval()

			timer.Create(timername, 0, 4*tickrate, function() //4 seconds
				if not IsValid(ent) or not IsValid(core) or not IsValid(self) then timer.Remove(timername) return end

				ent.loco:FaceTowards(goalpos)
				ent.loco:Approach(goalpos, 99)

				if ent:GetPos():DistToSqr(goalpos) < 10000 then
					ent:SetPos(self:GetTelePos() + vector_up)
					core:EmitSound("TFA_BO3_GERSCH.Teleport")
					ent:EmitSound("TFA_BO3_GERSCH.TeleOut")

					ParticleEffectAttach("bo3_gersch_player_insanity", PATTACH_POINT_FOLLOW, ent, 1)

					if IsValid(ply) and ply:IsPlayer() then
						TFA.WonderWeapon.NotifyAchievement( "UGX_Boss_Gersh_Teleport", ply )
					end
					timer.Remove(timername)
				end
			end)
		end
	end
end

function ENT:GerschSuck(ent)
	if not IsValid(ent) then return end

	if ent.HasSequence then
		if ent:HasSequence(ent.BlackHoleDeathSequences[1]) then
			if (ent.ShouldCrawl or ent:GetCrawler()) and ent.BlackHoleCrawlDeathSequences then
				ent:DoDeathAnimation(ent.BlackHoleCrawlDeathSequences[math.random(#ent.BlackHoleCrawlDeathSequences)])
			else
				ent:DoDeathAnimation(ent.BlackHoleDeathSequences[math.random(#ent.BlackHoleDeathSequences)])
			end
		end
	else
		if (ent.ShouldCrawl or ent:GetCrawler()) and ent.BlackHoleCrawlDeathSequences then
			ent:DoDeathAnimation(ent.BlackHoleCrawlDeathSequences[math.random(#ent.BlackHoleCrawlDeathSequences)])
		else
			ent:DoDeathAnimation(ent.BlackHoleDeathSequences[math.random(#ent.BlackHoleDeathSequences)])
		end
	end
end

function ENT:InflictDamage(ent)
	local ply = self:GetOwner()
	local damage = DamageInfo()
	damage:SetDamage(ent:Health() + 666)
	damage:SetInflictor(self)
	damage:SetAttacker(IsValid(self:GetOwner()) and self:GetOwner() or self)
	damage:SetDamageType(DMG_ENERGYBEAM)
	damage:SetDamagePosition(TFA.WonderWeapon.BodyTarget(ent, self:GetPos(), true))
	damage:SetDamageForce(vector_up)

	if IsValid(self.CoreMDL) then
		damage:SetReportedPosition(self.CoreMDL:GetPos())
	else
		damage:SetReportedPosition(self:GetPos())
	end

	TFA.WonderWeapon.DoDeathEffect( "BO3_Gersh_Soul", ent )

	ent:SetHealth(1)
	ent:TakeDamageInfo(damage)

	self:SendHitMarker(ent, damage)

	if IsValid( ply ) and ply:IsPlayer() then
		TFA.WonderWeapon.NotifyAchievement( "BO3_Gersh_Kills", ply, ent, self )
	end

	if ent:IsValidZombie() and ent.DoDeathAnimation and ent.BlackHoleDeathSequences then
		self:GerschSuck(ent)
	end

	local startVec = self.CoreMDL2:GetPos()
	local vecVelocity = Vector( math.random( -200, 200 ), math.random( -200, 200 ), math.random( 100, 200 ) )
	local vecAngleVelocity = Vector( 0, math.random( 1000, 2000 ), 0 )
	local randomFacingAngle = Angle(0, math.random( -180, 180 ), 0)

	TFA.WonderWeapon.CreateHorrorGib( startVec, randomFacingAngle, vecVelocity, vecAngleVelocity, math.Rand( 3, 4 ), ent.GetBloodColor and ent:GetBloodColor() or DONT_BLEED )
end

function ENT:ConstructTeleportPos()
	local available = ents.FindByClass("nz_spawn_zombie_special")
	local pos = vector_origin
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
				--ply:Spawn()
				ply:ChatPrint("Couldnt Find Exit Location for Gersch")
			else
				pos = pspawns[math.random(#pspawns)]:GetPos()
			end
		else
			pos = spawns[math.random(#spawns)]:GetPos()
		end
	else -- There exists no special spawnpoints - Use regular player spawns
		local pspawns = ents.FindByClass("player_spawns")
		if IsValid(pspawns[1]) then
			pos = pspawns[math.random(#pspawns)]:GetPos()
		end
	end

	self:SetTelePos(pos)
end

function ENT:OnRemove()
	if SERVER then
		if IsValid(self.CoreMDL) and IsValid(self.CoreMDL2) then
			ParticleEffect(self:GetUpgraded() and "bo3_gersch_explode_pap" or "bo3_gersch_explode", self.CoreMDL:GetPos(), angle_zero)

			util.ScreenShake(self:GetPos(), 10, 255, 1, 512)

			self.CoreMDL:StopSound(self.BlackHoleLoopFar)
			self.CoreMDL:StopSound(self.BlackHoleLoopClose)
			self.CoreMDL:EmitSound(self.BlackHoleCollapse)

			self.CoreMDL2:StopSound(self.BlackHoleLoopFar)
			self.CoreMDL2:StopSound(self.BlackHoleLoopClose)
			self.CoreMDL2:EmitSound(self.BlackHoleCollapse)

			SafeRemoveEntity(self.CoreMDL)
			SafeRemoveEntity(self.CoreMDL2)
		end
	end
end
