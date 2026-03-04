AddCSLuaFile()

--[Info]--
ENT.Type = "anim"
ENT.PrintName = "Explosive Tipped Bolt"
ENT.Author = ""
ENT.Contact = ""
ENT.Purpose = ""
ENT.Instructions = ""
ENT.DoNotDuplicate = true
ENT.DisableDuplicator = true

--[Sounds]--
ENT.BeepSound = "TFA_BO3_CROSSBOW.Alert"

--[Parameters]--
ENT.NZThrowIcon = Material("vgui/icon/hud_indicator_arrow.png", "unlitgeneric smooth")
ENT.NZHudIcon = Material("vgui/icon/hud_indicator_arrow.png", "unlitgeneric smooth")

ENT.Delay = 12
ENT.Duration = 2
ENT.DurationPaP = 5
ENT.BeepDelay = 0.35
ENT.Range = 220
ENT.Kills = 0
ENT.DesiredSpeed = 5000

local nzombies = engine.ActiveGamemode() == "nzombies"
local dlight_cvar = GetConVar("cl_tfa_fx_wonderweapon_dlights")
local pvp_cvar = GetConVar("sbox_playershurtplayers")

local CurTime = CurTime
local IsValid = IsValid

local bit_AND = bit.band
local ents_Create = ents.Create

local util_TraceLine = util.TraceLine
local util_TraceHull = util.TraceHull
local util_PointContents = util.PointContents
local util_ScreenShake = util.ScreenShake

local MASK_SHOT = MASK_SHOT
local MAT_GLASS = MAT_GLASS
local CONTENTS_SLIME = CONTENTS_SLIME
local CONTENTS_LIQUID = bit.bor( CONTENTS_WATER, CONTENTS_SLIME )
local COLLISION_GROUP_BREAKABLE_GLASS = COLLISION_GROUP_BREAKABLE_GLASS
local MOVETYPE_NONE = MOVETYPE_NONE

local ParticleEffectAttach = ParticleEffectAttach
local ParticleEffect = ParticleEffect
local EffectData = EffectData
local DispatchEffect = util.Effect
local PlaySound = sound.Play

local LIFE_ALIVE = 0 // alive
local BOLT_HULL_MAXS = Vector( 0.3, 0.3, 0.3 )
local BOLT_HULL_MINS = BOLT_HULL_MAXS:GetNegated()
local BOLT_SPRITE_OFFSET = Vector( 0, 0, 0 )

local DoImpactEffect
local DoWaterSplashEffect
local CreateGlowSprite

local mImpactMaterials = {
	["carpet"] = {"weapons/tfa_bo3/scavenger/impacts/canvas_00.wav"},
	["ceiling_tile"] = {"weapons/tfa_bo3/scavenger/impacts/canvas_00.wav"},
	["paper"] = {"weapons/tfa_bo3/scavenger/impacts/canvas_00.wav"},
	["papercup"] = {"weapons/tfa_bo3/scavenger/impacts/canvas_00.wav"},
	["cardboard"] = {"weapons/tfa_bo3/scavenger/impacts/canvas_00.wav"},
	["plastic"] = {"weapons/tfa_bo3/scavenger/impacts/canvas_00.wav"},

	["dirt"] = {"weapons/tfa_bo3/scavenger/impacts/dirt_00.wav"},
	["grass"] = {"weapons/tfa_bo3/scavenger/impacts/dirt_00.wav"},
	["gravel"] = {"weapons/tfa_bo3/scavenger/impacts/dirt_00.wav"},

	["jeeptire"] = {"weapons/tfa_bo3/scavenger/impacts/flesh_02.wav", "weapons/tfa_bo3/scavenger/impacts/flesh_03.wav"},
	["rubbertire"] = {"weapons/tfa_bo3/scavenger/impacts/flesh_02.wav", "weapons/tfa_bo3/scavenger/impacts/flesh_03.wav"},
	["rubber"] = {"weapons/tfa_bo3/scavenger/impacts/flesh_02.wav", "weapons/tfa_bo3/scavenger/impacts/flesh_03.wav"},
	["plastic_barel"] = {"weapons/tfa_bo3/scavenger/impacts/flesh_02.wav", "weapons/tfa_bo3/scavenger/impacts/flesh_03.wav"},
	["plastic_barrel_buoyant"] = {"weapons/tfa_bo3/scavenger/impacts/flesh_02.wav", "weapons/tfa_bo3/scavenger/impacts/flesh_03.wav"},
	["plastic_box"] = {"weapons/tfa_bo3/scavenger/impacts/flesh_02.wav", "weapons/tfa_bo3/scavenger/impacts/flesh_03.wav"},
	["watermelon"] = {"weapons/tfa_bo3/scavenger/impacts/flesh_02.wav", "weapons/tfa_bo3/scavenger/impacts/flesh_03.wav"},
	["flesh"] = {"weapons/tfa_bo3/scavenger/impacts/flesh_02.wav", "weapons/tfa_bo3/scavenger/impacts/flesh_03.wav"},
	["bloodyflesh"] = {"weapons/tfa_bo3/scavenger/impacts/flesh_02.wav", "weapons/tfa_bo3/scavenger/impacts/flesh_03.wav"},
	["alienflesh"] = {"weapons/tfa_bo3/scavenger/impacts/flesh_02.wav", "weapons/tfa_bo3/scavenger/impacts/flesh_03.wav"},

	["foliage"] = {"weapons/tfa_bo3/scavenger/impacts/foliage_00.wav"},

	["glass"] = {"weapons/tfa_bo3/scavenger/impacts/glass_00.wav"},
	["glassbottle"] = {"weapons/tfa_bo3/scavenger/impacts/glass_00.wav"},
	["computer"] = {"weapons/tfa_bo3/scavenger/impacts/glass_00.wav"},
	["porcelain"] = {"weapons/tfa_bo3/scavenger/impacts/glass_00.wav"},

	["ice"] = {"weapons/tfa_bo3/scavenger/impacts/ice_00.wav"},

	["armorflesh"] = {"weapons/tfa_bo3/scavenger/impacts/metal_00.wav"},
	["weapon"] = {"weapons/tfa_bo3/scavenger/impacts/metal_00.wav"},
	["solidmetal"] = {"weapons/tfa_bo3/scavenger/impacts/metal_00.wav"},
	["slipperymetal"] = {"weapons/tfa_bo3/scavenger/impacts/metal_00.wav"},
	["roller"] = {"weapons/tfa_bo3/scavenger/impacts/metal_00.wav"},
	["popcan"] = {"weapons/tfa_bo3/scavenger/impacts/metal_00.wav"},
	["paintcan"] = {"weapons/tfa_bo3/scavenger/impacts/metal_00.wav"},
	["metalvent"] = {"weapons/tfa_bo3/scavenger/impacts/metal_00.wav"},
	["metalpanel"] = {"weapons/tfa_bo3/scavenger/impacts/metal_00.wav"},
	["metalgrate"] = {"weapons/tfa_bo3/scavenger/impacts/metal_00.wav"},
	["metal_box"] = {"weapons/tfa_bo3/scavenger/impacts/metal_00.wav"},
	["metal_bouncy"] = {"weapons/tfa_bo3/scavenger/impacts/metal_00.wav"},
	["floating_metal_barrel"] = {"weapons/tfa_bo3/scavenger/impacts/metal_00.wav"},
	["metal_barrel"] = {"weapons/tfa_bo3/scavenger/impacts/metal_00.wav"},
	["metal"] = {"weapons/tfa_bo3/scavenger/impacts/metal_00.wav"},
	["chainlink"] = {"weapons/tfa_bo3/scavenger/impacts/metal_00.wav"},
	["chain"] = {"weapons/tfa_bo3/scavenger/impacts/metal_00.wav"},
	["canister"] = {"weapons/tfa_bo3/scavenger/impacts/metal_00.wav"},
	["item"] = {"weapons/tfa_bo3/scavenger/impacts/metal_00.wav"},
	["ladder"] = {"weapons/tfa_bo3/scavenger/impacts/metal_00.wav"},

	["mud"] = {"weapons/tfa_bo3/scavenger/impacts/mud_01.wav"},
	["quicksand"] = {"weapons/tfa_bo3/scavenger/impacts/mud_01.wav"},
	["slime"] = {"weapons/tfa_bo3/scavenger/impacts/mud_01.wav"},
	["slipperyslime"] = {"weapons/tfa_bo3/scavenger/impacts/mud_01.wav"},

	["tile"] = {"weapons/tfa_bo3/scavenger/impacts/rock_00.wav"},
	["pottery"] = {"weapons/tfa_bo3/scavenger/impacts/rock_00.wav"},
	["rock"] = {"weapons/tfa_bo3/scavenger/impacts/rock_00.wav"},
	["concrete_block"] = {"weapons/tfa_bo3/scavenger/impacts/rock_00.wav"},
	["concrete"] = {"weapons/tfa_bo3/scavenger/impacts/rock_00.wav"},
	["brick"] = {"weapons/tfa_bo3/scavenger/impacts/rock_00.wav"},
	["boulder"] = {"weapons/tfa_bo3/scavenger/impacts/rock_00.wav"},

	["sand"] = {"weapons/tfa_bo3/scavenger/impacts/sand_03.wav"},

	["snow"] = {"weapons/tfa_bo3/scavenger/impacts/snow_01.wav"},

	["wade"] = {"weapons/tfa_bo3/scavenger/impacts/water_00.wav"},
	["water"] = {"weapons/tfa_bo3/scavenger/impacts/water_00.wav"},

	["plaster"] = {"weapons/tfa_bo3/scavenger/impacts/wood_01.wav"},
	["wood_solid"] = {"weapons/tfa_bo3/scavenger/impacts/wood_01.wav"},
	["wood_panel"] = {"weapons/tfa_bo3/scavenger/impacts/wood_01.wav"},
	["wood_plank"] = {"weapons/tfa_bo3/scavenger/impacts/wood_01.wav"},
	["wood_lowdensity"] = {"weapons/tfa_bo3/scavenger/impacts/wood_01.wav"},
	["wood_furniture"] = {"weapons/tfa_bo3/scavenger/impacts/wood_01.wav"},
	["wood_create"] = {"weapons/tfa_bo3/scavenger/impacts/wood_01.wav"},
	["wood_box"] = {"weapons/tfa_bo3/scavenger/impacts/wood_01.wav"},
	["wood"] = {"weapons/tfa_bo3/scavenger/impacts/wood_01.wav"},
	["woodladder"] = {"weapons/tfa_bo3/scavenger/impacts/wood_01.wav"},
}

function ENT:SetupDataTables()
	self:NetworkVar("Bool", 0, "Upgraded")
	self:NetworkVar("Bool", 1, "Blink")
	self:NetworkVar("Bool", 2, "Impacted")
	self:NetworkVar("Float", 0, "BeepTimer")
end

function ENT:Draw()
	if self:GetCreationTime() + 0.1 > CurTime() then return end
	self:DrawModel()

	if self:GetBlink() and self.color then
		render.SetMaterial(Material("effects/blueflare1"))
		render.DrawSprite(self:GetAttachment(1).Pos, 12, 12, self.color)
	end

	if nzombies then return end
	if self:GetCreationTime() + 0.2 > CurTime() then return end

	local icon = surface.GetTextureID("models/weapons/tfa_bo3/crossbow/i_crossbow_indicator")
	local angle = LocalPlayer():EyeAngles()
	local pos = self:WorldSpaceCenter() + Vector(0,0,15)
	local totaldist = 400^2
	local distfade = 300^2
	local playerpos = LocalPlayer():GetPos():DistToSqr(self:GetPos())
	local fadefac = 1 - math.Clamp((playerpos - totaldist + distfade) / distfade, 0, 1)

	angle = Angle(angle.x, angle.y, 0)
	angle:RotateAroundAxis(angle:Up(), -90)
	angle:RotateAroundAxis(angle:Forward(), 90)

	if IsValid(LocalPlayer()) and self:GetImpacted() then
		cam.Start3D2D(pos, angle, 1)
			surface.SetTexture(icon)
			surface.SetDrawColor(255,255,255,255*fadefac)
			surface.DrawTexturedRect(-8, -8, 16,16)
		cam.End3D2D()
	end
end

function ENT:Initialize(...)
	local mdl = self:GetModel()
	if not mdl or mdl == "" or mdl == "models/error.mdl" then
		self:SetModel(self.DefaultModel)
	end

	self:DrawShadow( true )
	self:SetMoveType( MOVETYPE_NONE )
	self:SetCollisionGroup( COLLISION_GROUP_IN_VEHICLE )
	self:SetSolid( SOLID_NONE )
	self:SetNotSolid( true )

	self.killtime = CurTime() + self.Delay
	self:SetBeepTimer(CurTime() + self.BeepDelay)

	if self:GetUpgraded() then
		self.color = Color(255,20,0,255)
		self.Duration = self.DurationPaP
	else
		self.color = Color(120,255,70,255)
	end

	self:NextThink( CurTime() )

	if CLIENT then return end

	local ply = self:GetOwner()
	if not self.Inflictor and ply:IsValid() and ply:GetActiveWeapon():IsValid() then
		self.Inflictor = ply:GetActiveWeapon()
	end

	self.Damage = self.mydamage or self.Damage
	self.Speed = self.DesiredSpeed
	self.Gravity = ( GetConVar( "sv_gravity" ):GetInt() / ( 1 / engine.TickInterval() ) )*0.25
	self.FrameTime = engine.TickInterval()
	self.Direction = self:GetAngles():Forward()

	// Entity water level
	if bit_AND( util_PointContents(self:GetPos()), CONTENTS_LIQUID ) != 0 then
		self.IsUnderwater = true
	else
		self.IsUnderwater = false
	end

	util.SpriteTrail(self, 1, self.color, false, 5, 1, 0.2, 2, "effects/laser_citadel1.vmt")
end

function ENT:Think()
	if CLIENT and dlight_cvar:GetBool() and DynamicLight then
		local dlight = DynamicLight(self:EntIndex())
		if dlight and self:GetImpacted() and self:GetBlink() then
			dlight.pos = self:GetAttachment(1).Pos
			dlight.r = self.color.r
			dlight.g = self.color.g
			dlight.b = self.color.b
			dlight.brightness = 0.5
			dlight.Decay = 1000
			dlight.Size = 64
			dlight.DieTime = CurTime() + 0.5
		end
	end

	if SERVER then
		if self:GetImpacted() and self:GetBeepTimer() <= CurTime() then
			self:EmitSound(self.BeepSound)

			self.BeepDelay = math.max(self.BeepDelay - (self:GetUpgraded() and .02 or .05), 0.1)

			self:SetBlink(not self:GetBlink())
			self:SetBeepTimer(CurTime() + self.BeepDelay)
		end

		if self:GetImpacted() and self:GetUpgraded() and not nzombies then
			self:MonkeyBombNXB()
			self:MonkeyBomb()
		end

		if self.killtime < CurTime() then
			self:Explode()
			self:Remove()
			return false
		end

		local speed = self.Speed
		local gravity = self.Gravity
		local direction = self.Direction
		local isUnderwater = self.IsUnderwater

		local curTime = CurTime()

		direction:Mul( speed )
		direction[ 3 ] = direction[ 3 ] - gravity
		speed = direction:Length()
		direction:Normalize()

		local position = self:GetPos()
		local owner = self:GetOwner()
		local distance = speed * self.FrameTime
		local myfilter = nzombies and table.Copy(player.GetAll()) or {owner}
		table.insert(myfilter, self)

		local trace = {} 
		local trace2 = {}
		local hitEntity
		local hitCharacter = false
		local hitRagdoll = false
		local hitDot = 0
		local hitsPerFrame = 0

		if !self:GetImpacted() then
			repeat
				util_TraceHull( {
					start = position,
					endpos = distance * direction + position,
					filter = myfilter,
					mask = MASK_SHOT,
					maxs = BOLT_HULL_MAXS,
					mins = BOLT_HULL_MINS,
					output = trace,
				} )

				self:WaterLevelThink(trace)

				if trace.Hit then
					if trace.Fraction == 0 then
						trace.Normal:Set( direction )
					end

					if !nzombies and trace.HitSky then
						position:Set( trace.HitPos )

						self:Remove()
						return
					end

					hitEntity = trace.Entity

					speed = 0
					hitDot = trace.HitNormal:Dot( -direction )
					hitRagdoll = hitEntity:GetClass() == "prop_ragdoll"
					hitCharacter = hitEntity:IsNPC() || hitEntity:IsPlayer() || hitEntity:IsNextBot()

					if hitEntity:GetCollisionGroup() == COLLISION_GROUP_BREAKABLE_GLASS then
						position:Set( trace.HitPos )
						hitEntity:Input( "Break" )
						break
					end

					if trace.MatType == MAT_GLASS && hitEntity:GetInternalVariable( "m_lifeState" ) != LIFE_ALIVE then
						position:Set( trace.HitPos )
						break
					end

					position:Set( trace.HitPos )

					if hitCharacter then
						if TFA.WonderWeapon.FindHullIntersection( hitEntity, trace, trace2 ) then
							trace.HitPos:Set( trace2.HitPos )
							trace.HitBox = trace2.HitBox
							trace.PhysicsBone = trace2.PhysicsBone
							trace.HitGroup = trace2.HitGroup
						else
							trace.UnreliableHitPos = true
						end
					end

					// Deal damage to the entity hit
					local hitDamage = DamageInfo()
					hitDamage:SetDamage(10)
					hitDamage:SetAttacker(IsValid(owner) and owner or self)
					hitDamage:SetInflictor(self)
					hitDamage:SetDamageType(DMG_BULLET)
					hitDamage:SetDamageForce(direction*2000)
					hitDamage:SetDamagePosition(trace.HitPos)

					hitEntity:DispatchTraceAttack(hitDamage, trace, direction)

					if !self.HasImpacted then
						self.HasImpacted = true
						self.killtime = CurTime() + self.Duration
					end

					self.hitdata = trace

					if nzombies then
						self:MonkeyBombNZ()
						if hitEntity:IsValidZombie() and not (hitEntity.NZBossType or hitEntity.IsMooBossZombie or hitEntity.IsMooMiniBoss) then
							hitEntity:SetBlockAttack(true)
						end
					else
						self:MonkeyBomb()
					end

					DoImpactEffect(trace)

					if ( hitCharacter || hitRagdoll ) then
						PlaySound( "TFA_BO3_CROSSBOW.Impact.Flesh", trace.HitPos )
					else
						local soundTab = mImpactMaterials[util.GetSurfacePropName(trace.SurfaceProps)]
						local finalSound = "TFA_BO3_CROSSBOW.Impact.Rock"
						if soundTab and istable(soundTab) then
							finalSound = soundTab[math.random(#soundTab)]
						end

						PlaySound( finalSound, trace.HitPos )
					end

					if not trace.HitWorld and hitEntity:GetInternalVariable( "m_lifeState" ) == LIFE_ALIVE then
						self:SetParentFromTrace( trace )
					else
						self:SetPos( position )
						self:SetAngles( direction:Angle() )
					end

					local sprite = CreateGlowSprite( self.Duration - 1 )
					if sprite then
						sprite:SetParent(self)
						sprite:SetLocalPos(self:WorldToLocal(self:GetAttachment(3).Pos))
					end

					self:SetImpacted( true )

					sound.EmitHint(SOUND_DANGER, position, 512, 0.2, owner)
					break
				end

				position:Set( trace.HitPos )
				distance = distance * ( 1 - trace.Fraction )

				hitsPerFrame = 1 + hitsPerFrame
			until ( distance <= 0 || hitsPerFrame > 3 ) // Stop tracing

			if !self:GetImpacted() then
				self:SetPos( position )
				self:SetAngles( direction:Angle() )
			end

			self.Speed = speed
			self.Gravity = gravity
			self.IsUnderwater = isUnderwater
		end

		local p = self:GetParent()
		if IsValid(p) and p:GetMaxHealth() > 0 and (p:GetInternalVariable( "m_lifeState" ) ~= LIFE_ALIVE or (nzombies and p:IsValidZombie() and !p:IsAlive())) then
			self:DropFromParent()
		end
	end

	self:NextThink(CurTime())
	return true
end

function ENT:WaterLevelThink(trace)
	local trace4 = {}

	if bit_AND( util_PointContents( trace.HitPos ), CONTENTS_LIQUID ) != 0 then
		if not isUnderwater then
			isUnderwater = true

			util_TraceLine({
				start = position,
				endpos = trace.HitPos,
				mask = CONTENTS_LIQUID,
				output = trace4,
			})

			DoWaterSplashEffect( trace4 )
		end
 	 elseif isUnderwater then
		isUnderwater = false

		util_TraceLine({
			start = trace.HitPos,
			endpos = position,
			mask = CONTENTS_LIQUID,
			output = trace4,
		})

		DoWaterSplashEffect( trace4 )
	end
end

function ENT:DropFromParent()
	if not self:GetImpacted() then return end
	self:SetImpacted(false)

	self.LastParent = self:GetParent()
	if IsValid(self.LastParent) then
		if self.KillSelfString then
			self.LastParent:RemoveCallOnRemove(self.KillSelfString)
		end
		if self.LastParent:IsPlayer() then
			self:SetPreventTransmit(self.LastParent, false)
		end
	end

	local pos = self:GetPos()
	local ang = self:GetAngles()

	self:SetParent(nil)

	self:SetPos(pos)
	self:SetAngles(ang)

	self.Gravity = self.Gravity*8
	self.Speed = 1
end

ENT.ExplosionSound = "BaseExplosionEffect.Sound"

function ENT:DoExplosionEffect()
	local effectdata = EffectData()
	effectdata:SetOrigin(self:GetPos())

	util.Effect("HelicopterMegaBomb", effectdata)
	util.Effect("Explosion", effectdata)

	self:EmitSound(self.ExplosionSound)
end

function ENT:Explode()
	self.Damage = self.mydamage or self.Damage

	local ply = self:GetOwner()
	local tr = {
		start = self:GetPos(),
		filter = {self, ply},
		mask = MASK_SHOT
	}

	local ply = self:GetOwner()
	for k, v in pairs(ents.FindInSphere(self:GetPos(), self.Range)) do
		if not v:IsWorld() and v:IsSolid() then
			if v == self then continue end

			tr.endpos = v:WorldSpaceCenter()
			local tr1 = util.TraceLine(tr)
			if tr1.HitWorld then continue end

			local own = v:GetOwner()
			if IsValid(own) and (own == ply or (nzombies and own:IsPlayer())) then continue end
			if v:IsPlayer() and IsValid(ply) and v ~= ply and !hook.Run("PlayerShouldTakeDamage", v, ply) then continue end
			if nzombies and (v:IsPlayer() and v ~= self:GetOwner()) then continue end

			self:InflictDamage(v, tr1.Entity == v and tr1.HitPos or tr.endpos, tr1.Normal)
		end
	end

	if self.hitdata then
		util.Decal("Scorch", self.hitdata.HitPos - self.hitdata.HitNormal, self.hitdata.HitPos + self.hitdata.HitNormal)
	end

	util_ScreenShake(self:GetPos(), 10, 255, 1, 512)

	self:DoExplosionEffect()
	SafeRemoveEntity(self)
end

function ENT:InflictDamage(ent, hitpos, hitnorm)
	local ply = self:GetOwner()
	local p = self:GetParent()

	local damage = DamageInfo()
	damage:SetDamage(self.Damage)
	damage:SetAttacker(IsValid(ply) and ply or self)
	damage:SetInflictor(IsValid(self.Inflictor) and self.Inflictor or self)
	damage:SetDamageForce(ent:GetUp()*12000 + (hitnorm or (ent:GetPos() - self:GetPos())):GetNormalized() * 10000)
	damage:SetDamageType(bit.bor(DMG_BLAST, DMG_AIRBOAT))
	damage:SetDamagePosition(hitpos or ent:WorldSpaceCenter())

	if ent == ply then
		local distfac = self:GetPos():Distance(ent:GetPos())
		distfac = 1 - math.Clamp(distfac/self.Range, 0, 1)
		damage:SetDamage(200*distfac)
	end

	if nzombies and (ent.NZBossType or ent.IsMooBossZombie) then
		damage:ScaleDamage(math.max(math.Round(nzRound:GetNumber()/10, 1), self:GetUpgraded() and 2 or 1))
	end

	if damage:GetDamage() >= ent:Health() and ent:IsNPC() and ent:HasCondition(COND.NPC_FREEZE) then
		ent:SetCondition(COND.NPC_UNFREEZE)
	end

	ent:TakeDamageInfo(damage)

	if SERVER and (ent:IsNPC() or ent:IsNextBot()) and ent:Health() <= 0 then
		self.Kills = self.Kills + 1
		if self.Kills == 6 and IsValid(ply) and ply:IsPlayer() and IsValid(p) and (p:IsPlayer() or (p:IsNPC() and p:Disposition(ply) == D_LI)) then
			if not ply.bo3crossbowachievement then
				TFA.BO3GiveAchievement("Sacrificial Lamb", "vgui/overlay/achievment/sacrificial_lamb.png", ply)
				ply.bo3crossbowachievement = true
			end
		end
	end
end

function ENT:MonkeyBomb()
	if CLIENT then return end
	for k, v in pairs(ents.FindInSphere(self:GetPos(), 2048)) do
		if v == self:GetOwner() then continue end
		if IsValid(v) and v:IsNPC() then
			if v:GetEnemy() ~= self then
				v:ClearSchedule()
				v:ClearEnemyMemory(v:GetEnemy())

				v:SetEnemy(self)
			end

			v:UpdateEnemyMemory(self, self:GetPos())
			v:SetSaveValue("m_vecLastPosition", self:GetPos())
			v:SetSchedule(SCHED_FORCED_GO_RUN)
		end
	end
end

function ENT:MonkeyBombNXB()
	if CLIENT then return end
	for k, v in pairs(ents.FindInSphere(self:GetPos(), 2048)) do
		if v == self:GetOwner() then continue end
		if IsValid(v) and v:IsNextBot() then
			v.loco:FaceTowards(self:GetPos())
			v.loco:Approach(self:GetPos(), 99)
			if v.SetEnemy then
				v:SetEnemy(self)
			end
		end
	end
end

function ENT:MonkeyBombNZ()
	if not self:GetUpgraded() then return end
	if CLIENT then return end
	self:SetTargetPriority(TARGET_PRIORITY_SPECIAL)
	UpdateAllZombieTargets(self)
end

function ENT:OnRemove()
	if SERVER then
		for k, v in pairs(ents.FindInSphere(self:GetPos(), 4096)) do
			if v:IsNPC() and v:GetEnemy() == self then
				v:ClearSchedule()
				v:ClearEnemyMemory(v:GetEnemy())

				v:SetSchedule(SCHED_ALERT_STAND)
			end
		end
	end
end

function ENT:SetParentFromTrace( trace )
	local origin = 1 * trace.Normal // adjust the bolt position
	origin:Add( trace.HitPos )

	local hitEntity = trace.Entity
	local bone = hitEntity:TranslatePhysBoneToBone( trace.PhysicsBone )

	if bone && bone >= 0 then
		// A multi-bone skeleton (a ragdoll, player, NPC...)
		local boneMatrix = hitEntity:GetBoneMatrix( bone )

		if !boneMatrix then
			// Bone ID is out of bounds or the entity has no model (how did it manage to get hit?)
			self:Remove()
			return false
		end

		// Have to manually set local position/angle in this case
		local position, angles = WorldToLocal( origin, trace.Normal:Angle(), boneMatrix:GetTranslation(), boneMatrix:GetAngles() )

		self:FollowBone( hitEntity, bone )
		self:SetLocalPos( position )
		self:SetLocalAngles( angles )

		if hitEntity:IsPlayer() then
			// Save bandwidth, this player will not draw this bolt anyway
			self:SetPreventTransmit( hitEntity, true )
		end
	else
		// A zero- or mono-bone skeleton, most likely a prop
		self:SetPos( origin )
		self:SetAngles( trace.Normal:Angle() )

		self:SetParent( hitEntity )
	end

	//self:SetTransmitWithParent( true )
	if not trace.HitWorld then
		self.KillSelfString = "sticky_fixme"..self:EntIndex()
		hitEntity:CallOnRemove(self.KillSelfString, function(ent)
			if not IsValid(self) then return end
			local parent = self:GetParent()
			if IsValid(parent) and parent == ent then
				self:DropFromParent()
			end
		end)
	end

	return true
end

// Bullet impact
function DoImpactEffect( trace )
	local data = EffectData()
	data:SetStart( trace.StartPos )
	data:SetOrigin( trace.HitPos )
	data:SetEntity( trace.Entity )
	data:SetSurfaceProp( trace.SurfaceProps )
	data:SetHitBox( trace.HitBox )

	DispatchEffect( "Impact", data, false, true )
end

// Sprite
function CreateGlowSprite( dietime )
	dietime = ( dietime ~= nil ) and ( dietime ) or ( 3 )

	local sprite = ents_Create( "env_sprite" )

	if !sprite:IsValid() then return false end

	sprite:SetKeyValue( "spawnflags", 1 ) // start on
	sprite:SetKeyValue( "model", "sprites/light_glow02_noz.vmt" )

	sprite:SetKeyValue( "rendermode", 3 ) // glow
	sprite:SetKeyValue( "renderfx", 14 ) // constant glow
	sprite:SetKeyValue( "rendercolor", "255 255 255" )
	sprite:SetKeyValue( "renderamt", 128 )
	sprite:SetKeyValue( "scale", 0.1 )

	sprite:Spawn()

	SafeRemoveEntityDelayed( sprite, dietime + 1 )

	// Fade the sprite in the next X seconds
	local SpriteFadeTime = CurTime() + ( dietime + 1 )
	local SpriteFade = "crossbow_sprite_fade" .. sprite:EntIndex()

	timer.Simple( dietime, function()
		timer.Create( SpriteFade, 0, 0, function()
			if not IsValid( sprite ) then timer.Remove( SpriteFade ) return end

			local deltaTime = SpriteFadeTime - CurTime()
			if deltaTime > 0 then
				sprite:SetKeyValue( "renderamt", 128 * deltaTime )
			else
				sprite:Remove()
				timer.Remove( SpriteFade )
			end
		end )
	end )

	return sprite
end