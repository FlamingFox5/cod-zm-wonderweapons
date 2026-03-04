AddCSLuaFile()

--[Info]--
ENT.Base = "tfa_exp_base"
ENT.PrintName = "Teleport Grenade"

--[Sounds]--

--[Parameters]--
ENT.Range = 64
ENT.TeleportWarmup = 0.15

DEFINE_BASECLASS(ENT.Base)

local dlight_cvar = GetConVar("cl_tfa_fx_wonderweapon_dlights")
local SinglePlayer = game.SinglePlayer()

function ENT:SetupDataTables()
	self:NetworkVar("Vector", 0, "TelePos")
	self:NetworkVar("Bool", 0, "Impacted")
end

function ENT:Draw()
	if self:GetImpacted() then return end

	self:DrawModel()
	self:CreateShadow()

	if !self.pvslight1 or !IsValid(self.pvslight1) then
		self.pvslight1 = CreateParticleSystem(self, "aw_porternade_accent", PATTACH_POINT_FOLLOW, 2)
	end
	if !self.pvslight2 or !IsValid(self.pvslight2) then
		self.pvslight2 = CreateParticleSystem(self, "aw_porternade_accent", PATTACH_POINT_FOLLOW, 3)
	end
	if !self.pvslight3 or !IsValid(self.pvslight3) then
		self.pvslight3 = CreateParticleSystem(self, "aw_porternade_accent", PATTACH_POINT_FOLLOW, 4)
	end
	if !self.pvslight4 or !IsValid(self.pvslight4) then
		self.pvslight4 = CreateParticleSystem(self, "aw_porternade_accent", PATTACH_POINT_FOLLOW, 5)
	end
	if !self.pvslight5 or !IsValid(self.pvslight5) then
		self.pvslight5 = CreateParticleSystem(self, "aw_porternade_accent", PATTACH_POINT_FOLLOW, 6)
	end
	if !self.pvslight6 or !IsValid(self.pvslight6) then
		self.pvslight6 = CreateParticleSystem(self, "aw_porternade_accent", PATTACH_POINT_FOLLOW, 7)
	end
end

function ENT:PhysicsCollide(data, phys)
	if self:GetImpacted() then return end
	self:SetImpacted(true)

	self.HitPos = data.HitPos
	self.HitNorm = data.HitNormal
	self.HitFloor = data.HitNormal:Dot(vector_up*-1) > 0.9

	// freeze
	phys:EnableMotion(false)
	phys:SetVelocityInstantaneous(vector_origin)
	phys:SetVelocity(vector_origin)

	self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE) //fuck you it has to be this way

	timer.Simple(0, function()
		if not IsValid(self) then return end
		self:SetMoveType(MOVETYPE_NONE)
		self:PhysicsDestroy()
	end)

	// bullet impact effect
	local trace = util.TraceLine({
		start = self:GetPos(),
		endpos = data.HitPos + data.OurOldVelocity:GetNormalized(),
		mask = MASK_SHOT,
		filter = {ply, self}
	})

	local fx = EffectData()
	fx:SetStart( trace.StartPos )
	fx:SetOrigin( trace.HitPos )
	fx:SetEntity( trace.Entity )
	fx:SetSurfaceProp( trace.SurfaceProps )
	fx:SetHitBox( trace.HitBox )

	util.Effect( "Impact", fx, false, true )

	sound.Play("weapons/tfa_aw/grenade/grenade_bounce_default_0"..math.random(9)..".wav", data.HitPos, SNDLVL_IDLE, math.random(97,103), 1)

	self:ActivateCustom(data.HitPos - (self.HitFloor and -vector_up or data.HitNormal), data.HitEntity)
end

function ENT:ActivateCustom(hitPosition, hitEntity)
	local ply = self:GetOwner()
	if not IsValid(ply) then
		self:Remove()
		return
	end

	if hitPosition == nil or not isvector(hitPosition) or hitPosition:IsZero() then
		hitPosition = self:GetPos()
	end

	// impact effects
	ParticleEffect("aw_porternade_impact", self.HitPos, self.HitNorm:Angle() - Angle(90,0,0))

	util.Decal("FadingScorch", self.HitPos, self.HitPos + self.HitNorm*4)

	util.ScreenShake(self:GetPos(), 10, 255, 0.5, 128)

	sound.Play("weapons/tfa_aw/grenade/emp/wpn_emp_grenade_exp_v2_0"..math.random(3)..".wav", self:GetPos(), SNDLVL_NORM, math.random(97,103), 1)
	sound.Play("weapons/tfa_aw/grenade/emp/wpn_emp_grenade_sub_01.wav", self:GetPos(), SNDLVL_NORM, math.random(97,103), 1)

	if ply:IsPlayer() then
		// in ulx jail
		if ply.jail then
			self.bHasFailed = true
			self:Remove()
			return
		end
		// in vehicle
		if ply:GetVehicle() ~= NULL then
			self.bHasFailed = true
			self:Remove()
			return
		end
		// frozen or should not be able to move
		if ply:GetMoveType() ~= MOVETYPE_WALK or ply:IsFrozen() then
			self.bHasFailed = true
			self:Remove()
			return
		end
	end

	// dont worry about players or NPCs for finding the starting point
	local hitFilter = {ply, self}
	if hitEntity and IsValid(hitEntity) and (hitEntity:IsNPC() or hitEntity:IsNextBot() or hitEntity:IsPlayer()) then
		table.insert(hitFilter, hitEntity)
	end

	local minBound, maxBound = ply:GetHull()
	local startPos = hitPosition
	local checkRange = math.max(12, maxBound.x, maxBound.y)

	// pull back away from point of impact by the width of the player (incase we hit a wall)
	local test = util.TraceLine({
		start = startPos,
		endpos = startPos - self.HitNorm*checkRange,
		mask = MASK_PLAYERSOLID_BRUSHONLY,
		filter = hitFilter,
	})

	if test.Hit then
		// if we hit something start from the midway between it and our original start
		startPos = startPos - self.HitNorm*(checkRange*(test.Fraction*0.5))

		debugoverlay.Axis(startPos, self.HitNorm:Angle(), 10, 4, true)
	else
		// else use the end point of the trace
		startPos = test.HitPos
	end

	// trace down to find the floor (incase we hit a wall)
	local trace = util.TraceLine({
		start = startPos,
		endpos = startPos - vector_up*288,
		mask = MASK_PLAYERSOLID,
		filter = hitFilter,
	})

	if trace.Hit then
		// offset by 1 in the direction the floor is facing (up usually)
		self:SetTelePos(trace.HitPos + trace.HitNormal)
	else
		// no floor to teleport to (or too high up)
		self.bHasFailed = true
		self:Remove()
		return
	end

	// were in a playerclip (check after finding a suitable starting point incase we hit a wall high up where theres a playerclip)
	if ply:IsPlayer() then
		if bit.band(util.PointContents(self:GetTelePos()), CONTENTS_PLAYERCLIP) == CONTENTS_PLAYERCLIP then
			self.bHasFailed = true
			self:Remove()
			return
		end
	end

	debugoverlay.Line(self:GetTelePos(), startPos, 4, Color(255, 0, 0, 255), false)

	local bSuccess = true
	local nAttempts = 0
	local tTeleportFilter = {self, ply}

	// hull trace check, increasing check range each time it fails up to 4x players hull width
	if not TFA.WonderWeapon.IsCollisionBoxClear(self:GetTelePos(), tTeleportFilter, minBound, maxBound, true ) then
		bSuccess = false

		ply:PrintMessage(2, "// Teleport Location Blocked //")

		for i = 1, 4 do
			local surroundingTiles = TFA.WonderWeapon.GetSurroundingTiles( ply, self:GetTelePos(), checkRange*i )
			local clearPaths = TFA.WonderWeapon.GetClearPaths( ply, self:GetTelePos(), surroundingTiles )	

			for _, tile in pairs( clearPaths ) do
				nAttempts = nAttempts + 1

				if TFA.WonderWeapon.IsCollisionBoxClear( tile, tTeleportFilter, minBound, maxBound, true ) then
					bSuccess = true

					self:SetTelePos( tile )
					break
				end
			end

			if bSuccess then
				break
			end
		end
	end

	if nAttempts > 0 then
		ply:PrintMessage(2, "// Teleport Retry Count : "..nAttempts.." //")
	end

	if not bSuccess then
		ply:PrintMessage(2, "// Total Failure //")

		self.bHasFailed = true
		self:Remove()
		return
	end

	// damage enemies at teleport point
	self:Explode(self:GetTelePos())

	// pre teleport player effect
	ParticleEffectAttach("aw_porternade_player", PATTACH_ABSORIGIN_FOLLOW, ply, 0)

	// untarget enemies
	for _, enemy in ipairs(ents.GetAll()) do
		if IsValid(enemy) and enemy:IsNPC() and enemy:GetEnemy() == ply then
			enemy:IgnoreEnemyUntil(ply, CurTime() + 1)
		end
	end

	// for modifying player movement
	ply:SetNW2Float("TFA.PorternadeTeleporting", CurTime() + (self.TeleportWarmup + 0.25))

	// delay teleport
	local teleportTimer = "aw_porternade_windup"..self:EntIndex()
	self.TeleportTimerName = teleportTimer
	timer.Create(teleportTimer, self.TeleportWarmup, 1, function()
		if not IsValid(self) then return end
		if not IsValid(ply) then return end

		SafeRemoveEntityDelayed(self, 0)

		local playerPos = ply:GetPos()
		util.Decal("Scorch", self:GetTelePos(), self:GetTelePos() - vector_up*4)

		local phys = ply:GetPhysicsObject()
		if phys:IsValid() then
			if ply:IsPlayer() then
				ply:SetLocalVelocity(vector_origin)
				ply:SetVelocity(vector_origin)
			end
			phys:SetVelocity(vector_origin)
		end

		ply:ViewPunch(Angle(-5, math.Rand(-10, 10), 0))
		ply:SetPos(self:GetTelePos())

		// post teleport effects
		ply:SetNW2Float("TFA.PorternadeFade", CurTime() + 0.5) // screen visuals
		ply:SetNW2Float("TFA.PorternadeDuration", 0.5)

		ParticleEffect("aw_porternade_teleport", ply:GetPos(), vector_up:Angle())

		util.ScreenShake(self:GetTelePos(), 10, 255, 1, 256)

		local sndFilter = RecipientFilter()
		sndFilter:AddPAS(playerPos)
		sndFilter:RemovePlayer(ply)

		// thirdperson sound
		if sndFilter:GetCount() > 0 then
			EmitSound("weapons/tfa_aw/grenade/teleport/player_teleport_thirdperson_"..math.random(5)..".wav", playerPos, 0, CHAN_AUTO, 1, SNDLVL_NORM, 0, math.random(97,103), 0, sndFilter)
		end

		local sndFilter = RecipientFilter()
		sndFilter:RemoveAllPlayers()
		sndFilter:AddPlayer(ply)

		// firstperson sound
		EmitSound("weapons/tfa_aw/grenade/teleport/player_teleport_"..math.random(5)..".wav", ply:GetPos(), ply:EntIndex(), CHAN_AUTO, 1, SNDLVL_NORM, 0, math.random(97,103), 0, sndFilter)

		self:Remove()
	end)
end

function ENT:Initialize(...)
	BaseClass.Initialize(self, ...)

	self:PhysicsInitSphere(2, "default")
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	self:DrawShadow(true)

	if !SinglePlayer or (SinglePlayer and SERVER) then
		ParticleEffectAttach("aw_porternade_trail", PATTACH_ABSORIGIN_FOLLOW, self, 1)
	end

	self:NextThink(CurTime())

	if CLIENT then return end
	self:SetTrigger(true)
	SafeRemoveEntityDelayed(self, 24)
end

function ENT:Think()
	if CLIENT and self:GetImpacted() and dlight_cvar:GetBool() and DynamicLight then
		self.DLight = self.DLight or DynamicLight(self:EntIndex(), false)
		if self.DLight then
			self.DLight.pos = self:GetPos()
			self.DLight.r = 105
			self.DLight.g = 230
			self.DLight.b = 255
			self.DLight.brightness = 1
			self.DLight.Decay = 1000
			self.DLight.Size = 256
			self.DLight.dietime = CurTime() + 1
		end
	end

	self:NextThink(CurTime())
	return true
end

function ENT:DoExplosionEffect()
end

function ENT:Explode(pos)
	if not pos or isvector(pos) or pos:IsZero() then
		pos = self:GetPos()
	end

	local ply = self:GetOwner()
	local tr = {
		start = pos,
		filter = {ply, self},
		mask = MASK_SHOT
	}

	self.Damage = self.mydamage or self.Damage

	local damage = DamageInfo()
	damage:SetAttacker(IsValid(ply) and ply or self)
	damage:SetInflictor(IsValid(self.Inflictor) and self.Inflictor or self)
	damage:SetDamageType(DMG_DISSOLVE)
	damage:SetDamage(self.Damage)

	for k, v in pairs(ents.FindInSphere(pos, self.Range)) do
		if not (v:IsNPC() or v:IsNextBot() or v:IsVehicle()) then continue end
		if !TFA.WonderWeapon.ShouldDamage(v, ply, self) then continue end

		tr.endpos = v:WorldSpaceCenter()
		local tr1 = util.TraceLine(tr)
		if tr1.HitWorld then continue end

		local hitpos = tr1.Entity == v and tr1.HitPos or tr.endpos

		damage:SetDamagePosition(hitpos)
		damage:SetDamageForce(tr1.Normal*6000)

		v:TakeDamageInfo(damage)
	end
end

function ENT:OnRemove()
end