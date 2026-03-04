EFFECT.Life = 0.1

//-- DLight
EFFECT.FlashSize = 300
EFFECT.FlashSizeSilenced = 400
EFFECT.FlashDecay = 2000
EFFECT.FlashLife = 0.5
EFFECT.FlashBrightness = 2
EFFECT.FlashSizeRandomMin = 0.95
EFFECT.FlashSizeRandomMax = 1.05
EFFECT.Color = Color(255, 255, 255, 255)

//-- Effect
EFFECT.MuzzleEffect = "bo3_jgb_muzzleflash"
EFFECT.MuzzleEffectThirdperson = nil // if the muzzleflash effect should use a difference particle effect when not being called on the viewmodel

EFFECT.UseCustomMuzzleColor = false // if the muzzleflash effect should use EFFECT.Color to overwrite its color
EFFECT.ColorControlPoint = 2 // what control point to use when assigning the color to the CNewParticleSystem (required if using EFFECT.UseCustomMuzzleColor)
EFFECT.WaterLevelControlPoint = 6 // what control point for setting the water level for clip planes in underwater effects
EFFECT.UsePlayerColor = false // dlight and muzzleflash effect will use PLAYER:GetPlayerColor() for EFFECT.Color instead (if owner entity is a player)

//-- Looping
EFFECT.LoopingEffect = false // this EFFECT entity wont be removed until WEAPON:GetStatus() does not return STATUS_SHOOTING, usefull for flamethrowers
EFFECT.CleanLoopingParticles = false // if the particle effect should be removed when this entity is removed, usefull for flamethrowers

//-- Spawning
EFFECT.SpawnOnPlayer = false // particle will spawn at players origin using ParticleEffect(), used for gravity spikes and the zod sword slam attack
EFFECT.SpawnAngle = Angle(0,0,0) // only used with EFFECT.SpawnOnPlayer

//-- Misc
EFFECT.CleanParticles = false // if the weapon should be cleaned of all particle effects right before the muzzleflash effect is called, not used by anything

local CONTENTS_LIQUID = bit.bor( CONTENTS_WATER, CONTENTS_SLIME )
local dlight_cvar = GetConVar("cl_tfa_fx_wonderweapon_muzzleflash_dlights")
local ang

function EFFECT:Init(data)
	self.WeaponEnt = data:GetEntity()
	if not IsValid(self.WeaponEnt) then return end

	self.IsViewModel = false
	self.WeaponEntOG = self.WeaponEnt
	self.Attachment = data:GetAttachment()
	self.Position = self:GetTracerShootPos(data:GetOrigin(), self.WeaponEnt, self.Attachment)

	if self.CleanParticles and self.WeaponEnt.CleanParticles then
		self.WeaponEnt:CleanParticles()
	end

	if IsValid(self.WeaponEnt:GetOwner()) then
		
		if self.WeaponEnt:IsCarriedByLocalPlayer() then
			
			if self.WeaponEnt:GetOwner():ShouldDrawLocalPlayer() then
				ang = self.WeaponEnt:GetOwner():EyeAngles()
				ang:Normalize()
				self.Forward = ang:Forward()
			else
				self.WeaponEnt = self.WeaponEnt.OwnerViewModel
				self.IsViewModel = true
			end
		else
			ang = self.WeaponEnt:GetOwner():EyeAngles()
			ang:Normalize()
			self.Forward = ang:Forward()
		end
	end

	if IsValid(self.WeaponEntOG) and self.WeaponEntOG.MuzzleAttachment then
		self.Attachment = self.WeaponEnt:LookupAttachment(self.WeaponEntOG.MuzzleAttachment)

		if not self.Attachment or self.Attachment <= 0 then
			self.Attachment = 1
		end

		if self.WeaponEntOG.Akimbo then
			self.Attachment = 2 - self.WeaponEntOG.AnimCycle
		end
	end

	self.ColorVector = self.Color:ToVector()
	self.Forward = self.Forward or data:GetNormal()
	self.Angle = self.Forward:Angle()
	self.Right = self.Angle:Right()
	self.vOffset = self.Position
	self.Silenced = false

	if self.WeaponEntOG.GetSilenced and self.WeaponEntOG:GetSilenced() then
		self.Silenced = true
	end

	local ownerent = self.WeaponEnt:GetOwner()
	if not IsValid(ownerent) then return end

	if self.UsePlayerColor and ownerent.GetPlayerColor then
		local pvec = ownerent:GetPlayerColor()

		self.Color = pvec:ToColor()
		self.ColorVector = pvec
	end

	self.OwnerEnt = ownerent
	self.Dist = self.vOffset:Distance(self.OwnerEnt:EyePos())
	self.WasUnderwater = self.IsUnderwater or ( self.OwnerEnt:WaterLevel() > 2 )
	self.IsUnderwater = self.OwnerEnt:WaterLevel() > 2

	if dlight_cvar:GetBool() and ( !self.IsUnderwater or ( self.IsUnderwater and not self.NoFlashUnderwater ) ) then
		self:CreateDLight()
	end

	self.DieTime = CurTime() + math.max(self.DLight and self.FlashLife or 0, self.Life)

	if !self.IsViewModel and self.WeaponEntOG.Akimbo and self.WeaponEntOG.GetAnimCycle and self.WeaponEntOG:GetAnimCycle() == 0 then
		
		local WorldModelElements = self.WeaponEntOG:GetStatRawL("WorldModelElements")

		if WorldModelElements and WorldModelElements['gun_left'] and IsValid( WorldModelElements['gun_left'].curmodel ) then
			self.WeaponEnt = WorldModelElements['gun_left'].curmodel
		end
	end

	self:CreateCustomParticles()
end

function EFFECT:Think()
	if self.LoopingEffect and IsValid(self.WeaponEntOG) and self.WeaponEntOG.GetStatus and (self.WeaponEntOG:GetStatus() == TFA.Enum.STATUS_SHOOTING) then
		self.IsUnderwater = self.OwnerEnt:WaterLevel() > 2

		self.DieTime = CurTime() + math.min(engine.TickInterval(), self.Life)

		if self.DLight then
			if self.IsUnderwater then
				self.DLightSnuffed = true
				self.DLight.dietime = -1
			else
				self.DLight.size = self.FlashSize * math.Rand(self.FlashSizeRandomMin, self.FlashSizeRandomMax)
				self.DLight.dietime = CurTime() + self.FlashLife
			end
		end
	end

	if self.LoopingEffect and ( self.IsUnderwater ~= self.WasUnderwater ) then
		self.WasUnderwater = self.IsUnderwater

		if self.MuzzleFlashCNP and IsValid(self.MuzzleFlashCNP) then
			self.MuzzleFlashCNP:StopEmission()
		end

		if self.MuzzleBubblesCNP and IsValid(self.MuzzleBubblesCNP) then
			self.MuzzleBubblesCNP:StopEmission()
		end

		self:CreateCustomParticles()

		if self.DLightSnuffed and !self.IsUnderwater then
			self.DLightSnuffed = nil
			self:CreateDLight()
		end
	end

	if CurTime() > self.DieTime or !self.DieTime then
		
		if self.LoopingEffect and self.CleanLoopingParticles then
			
			if self.MuzzleFlashCNP and IsValid(self.MuzzleFlashCNP) then
				self.MuzzleFlashCNP:StopEmission()
			end

			if self.MuzzleBubblesCNP and IsValid(self.MuzzleBubblesCNP) then
				self.MuzzleBubblesCNP:StopEmission()
			end
		end

		if self.DLight then
			self.DLight.dietime = -1
		end

		return false
	elseif self.DLight and IsValid(self.OwnerEnt) and !self.SpawnOnPlayer then
		self.DLight.pos = self.OwnerEnt:EyePos() + self.OwnerEnt:EyeAngles():Forward() * self.Dist
	end

	return true
end

function EFFECT:Render()
end

function EFFECT:CreateDLight()
	local dlight = DynamicLight( self.OwnerEnt:EntIndex() )
	local epos = self.OwnerEnt:EyePos()

	if (dlight) then
		dlight.pos = epos + self.OwnerEnt:EyeAngles():Forward() * self.vOffset:Distance(epos)
		dlight.dir = self.Forward
		dlight.r = self.Color.r
		dlight.g = self.Color.g
		dlight.b = self.Color.b
		dlight.brightness = self.Silenced and self.FlashSizeSilenced or self.FlashBrightness
		dlight.decay = self.FlashDecay
		dlight.size = self.FlashSize * math.Rand(self.FlashSizeRandomMin, self.FlashSizeRandomMax)
		dlight.dietime = CurTime() + self.FlashLife
	end

	self.DLight = dlight
end

function EFFECT:CreateCustomParticles()
	if self.SpawnOnPlayer then
		if self.BubblesEffect and self.IsUnderwater then
			if self.BubblesEffectThirdperson then
				ParticleEffect(self.IsViewModel and self.BubblesEffect or self.BubblesEffectThirdperson, self.OwnerEnt:GetPos(), self.SpawnAngle, self.WeaponEnt)
			else
				ParticleEffect(self.BubblesEffect, self.OwnerEnt:GetPos(), self.SpawnAngle, self.WeaponEnt)
			end
		end

		if self.MuzzleEffectThirdperson then
			ParticleEffect(self.IsViewModel and ((self.MuzzleEffectUnderwater and self.IsUnderwater) and self.MuzzleEffectUnderwater or self.MuzzleEffect) or ((self.MuzzleEffectThirdpersonUnderwater and self.IsUnderwater) and self.MuzzleEffectThirdpersonUnderwater or self.MuzzleEffectThirdperson), self.OwnerEnt:GetPos(), self.SpawnAngle, self.WeaponEnt)
		else
			ParticleEffect((self.MuzzleEffectUnderwater and self.IsUnderwater) and self.MuzzleEffectUnderwater or self.MuzzleEffect, self.OwnerEnt:GetPos(), self.SpawnAngle, self.WeaponEnt)
		end
	else
		if self.BubblesEffect and self.IsUnderwater then
			if self.BubblesEffectThirdperson then
				self.MuzzleBubblesCNP = CreateParticleSystem(self.WeaponEnt, self.IsViewModel and self.BubblesEffect or self.BubblesEffectThirdperson, PATTACH_POINT_FOLLOW, self.Attachment)
			else
				self.MuzzleBubblesCNP = CreateParticleSystem(self.WeaponEnt, self.BubblesEffect, PATTACH_POINT_FOLLOW, self.Attachment)
			end
		end

		if self.MuzzleEffectThirdperson then
			self.MuzzleFlashCNP = CreateParticleSystem(self.WeaponEnt, self.IsViewModel and ((self.MuzzleEffectUnderwater and self.IsUnderwater) and self.MuzzleEffectUnderwater or self.MuzzleEffect) or ((self.MuzzleEffectThirdpersonUnderwater and self.IsUnderwater) and self.MuzzleEffectThirdpersonUnderwater or self.MuzzleEffectThirdperson), PATTACH_POINT_FOLLOW, self.Attachment)
		else
			self.MuzzleFlashCNP = CreateParticleSystem(self.WeaponEnt, (self.MuzzleEffectUnderwater and self.IsUnderwater) and self.MuzzleEffectUnderwater or self.MuzzleEffect, PATTACH_POINT_FOLLOW, self.Attachment)
		end

		if IsValid(self.WeaponEnt) and self.MuzzleFlashCNP and IsValid(self.MuzzleFlashCNP) then
			if self.IsViewModel then
				self.MuzzleFlashCNP:SetIsViewModelEffect(true)
			end

			if IsValid( self.WeaponEntOG ) then
				self.WeaponEntOG.MuzzleFlashCNP = self.MuzzleFlashCNP

				if self.MuzzleBubblesCNP and IsValid(self.MuzzleBubblesCNP) then
					if self.IsViewModel then
						self.MuzzleBubblesCNP:SetIsViewModelEffect(true)
					end

					self.WeaponEntOG.MuzzleFlashBubblesCNP = self.MuzzleBubblesCNP
				end
			end
		end

		if self.UseCustomMuzzleColor and self.MuzzleFlashCNP and IsValid(self.MuzzleFlashCNP) then
			self.MuzzleFlashCNP:SetControlPoint(self.ColorControlPoint or 2, self.ColorVector)
		end

		if self.MuzzleBubblesCNP and IsValid(self.MuzzleBubblesCNP) then
			local trace = util.TraceLine({
				start = self.Position,
				endpos = self.Position + vector_up*300,
				mask = CONTENTS_LIQUID,
			})

			if trace.Hit then
				self.MuzzleBubblesCNP:SetControlPoint(self.WaterLevelControlPoint or 6, trace.HitPos)
			end
		end
	end
end