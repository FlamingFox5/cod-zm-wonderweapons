
local dlight_cvar = GetConVar("cl_tfa_fx_wonderweapon_dlights")

ENT.SpriteTrailMaterial = nil // for sprite based trail, like the trail tool
ENT.SpriteTrailResolution = 1 // trail texture resolution
ENT.SpriteTrailLifetime = 0.5 // duration that each trail segment exists for
ENT.SpriteTrailStartWidth = 4 // starting radius of trail in hammer units
ENT.SpriteTrailEndWidth = 0 // end radius of trail in hammer units
ENT.SpriteTrailAdditive = true // should the trail be additive (darker = more transparent)
ENT.SpriteTrailColor = Color(200, 200, 200, 200) // trail color
ENT.SpriteTrailAttachment = 1 // attachment point for trail

ENT.GlowSpriteTrail = nil // for attaching an 'env_sprite' to the projectile
ENT.GlowSpriteTrailSize = 0.15
ENT.GlowSpriteTrailLife = ENT.Delay
ENT.GlowSpriteTrailColor = ENT.Color
ENT.GlowSpriteTrailColorPaP = ENT.ColorPaP
ENT.GlowSpriteTrailAlpha = 255
ENT.GlowSpriteOffset = Vector()

ENT.ScreenShakeAmplitude = 5
ENT.ScreenShakeFrequency = 255
ENT.ScreenShakeDuration = 0.8
ENT.ScreenShakeRange = ENT.Range * 2

local bit_AND = bit.band

local util_PointContents = util.PointContents

local CONTENTS_SLIME = CONTENTS_SLIME
local CONTENTS_LIQUID = bit.bor( CONTENTS_WATER, CONTENTS_SLIME )

local EffectData = EffectData
local DispatchEffect = util.Effect

function ENT:DoImpactEffect( trace, isexplosion )
	if self.BlockImpactEffect then return end

	local hitEntity = trace.Entity

	local data = EffectData()
	data:SetStart( trace.StartPos )
	data:SetOrigin( trace.HitPos )
	data:SetEntity( hitEntity )
	data:SetSurfaceProp( trace.SurfaceProps )
	data:SetHitBox( trace.HitBox )
	data:SetDamageType( isexplosion and self.ExplosionDamageType or DMG_BULLET )

	local effect = "Impact"
	if self.BigImpactEffect and !isexplosion then
		effect = "ImpactJeep"
	end
	if self.BiggerImpactEffect and !isexplosion then
		effect = "ImpactGunship"
	end

	DispatchEffect( effect, data, false, true )

	if self.ImpactDecal or ( isexplosion and self.ExplosionTraceDecal and self.ExplosionImpactDecal ) then
		if not ( hitEntity:IsNPC() or hitEntity:IsPlayer() or hitEntity:IsNextBot() ) then
			local direction = trace.Normal
		
			local phys = self:GetPhysicsObject()
			if IsValid( phys ) then
				direciton = phys:GetVelocity():GetNormalized()
			end

			util.Decal( isexplosion and self.ExplosionImpactDecal or self.ImpactDecal, trace.HitPos, trace.HitPos + direction*4 )
		end
	end

	if self.ImpactBubbles and not isexplosion and bit_AND( util_PointContents( trace.HitPos ), CONTENTS_LIQUID ) != 0 then
		local data = EffectData()
		data:SetOrigin( trace.HitPos )
		data:SetNormal( trace.HitNormal )
		data:SetMagnitude( self.ImpactBubblesMagnitude or math.Clamp( ( self.Damage / 100 ) + ( self.Range / 100 ), 0.5, 12 ) )
		data:SetRadius( self.ImpactBubblesSize or math.Clamp( ( math.pow( self.Damage / 100, 0.2 ) * self.Range ) / 2, 16, 64 ) )

		DispatchEffect( "tfa_bo3_bubble_explosion", data )
	end
end

function ENT:DoWaterSplashEffect( trace, size )
	if self.BlockWaterSplash then return end

	local data = EffectData()
	data:SetOrigin( trace.HitPos )
	data:SetNormal( trace.Normal )
	data:SetScale( size or self.WaterSplashSize or 6 )
	data:SetFlags( bit_AND( trace.Contents, CONTENTS_SLIME ) != 0 && 1 || 0 ) // FX_WATER_IN_SLIME = 1

	DispatchEffect( "gunshotsplash", data, false, true )
end

function ENT:DoDynamicLightFlash()
	if CLIENT and dlight_cvar:GetBool() and DynamicLight and self.Color and IsColor( self.Color ) then
		self.DLight = self.DLight or DynamicLight( self:EntIndex() )
		if ( self.DLight ) then
			local position = self:GetPos()
			if self.GetHitPos and !self:GetHitPos():IsZero() then
				position = self:GetHitPos()
			end

			self.DLight.pos = position
			self.DLight.r = self.Color.r
			self.DLight.g = self.Color.g
			self.DLight.b = self.Color.b
			self.DLight.brightness = self.DLightFlashBrightness or 1
			self.DLight.Decay = self.DLightFlashDecay or 2000
			self.DLight.Size = self.DLightFlashSize or 250
			self.DLight.DieTime = CurTime() + (1000 / (self.DLightFlashDecay or 2000))
		end
	end
end

function ENT:CreateBubbleTrail()
	if self.BlockBubbleTrail then return end

	local fx = EffectData()
	fx:SetEntity( self )
	fx:SetRadius( math.Clamp( self.Size, 0, 32 ) )
	fx:SetMagnitude( 1 )
	fx:SetScale( ( self.Size >= 8 ) and 2 or 1 )

	DispatchEffect( "tfa_bo3_bubble_trail", fx )
end

if CLIENT then return end

function ENT:CreateGlowSprite( dietime, color, alpha, scale, model, rendermode, renderfx, position )
	dietime = ( dietime ~= nil ) and ( dietime ) or ( 3 )
	model = ( model ~= nil ) and ( model ) or ( "sprites/light_glow02_noz.vmt" )
	rendermode = ( rendermode ~= nil ) and ( rendermode ) or ( 3 ) // glow
	renderfx = ( renderfx ~= nil ) and ( renderfx ) or ( 14 ) // constant glow
	color = ( color ~= nil ) and ( ""..color.r.." "..color.g.." "..color.b.."" ) or ( "255 255 255" )
	alpha = ( alpha ~= nil ) and ( alpha ) or ( 128 )
	scale = ( scale ~= nil ) and ( scale ) or ( 0.1 )

	if self.pGlowSprite and IsValid(self.pGlowSprite) then
		timer.Remove( "ww_sprite_fade"..self.pGlowSprite:EntIndex() )
		self.pGlowSprite:Remove()
		self.pGlowSprite = nil
	end

	local sprite = ents.Create( "env_sprite" )

	if !sprite:IsValid() then return false end

	sprite:SetKeyValue( "spawnflags", 1 ) // start on
	sprite:SetKeyValue( "model", model )

	sprite:SetKeyValue( "rendermode", rendermode )
	sprite:SetKeyValue( "renderfx", renderfx )
	sprite:SetKeyValue( "rendercolor", color )
	sprite:SetKeyValue( "renderamt", alpha )
	sprite:SetKeyValue( "scale", scale )

	sprite:Spawn()

	if position and isvector(position) and not position:IsZero() then
		sprite:SetPos(position)
	end

	SafeRemoveEntityDelayed( sprite, dietime + 1 )

	self.pGlowSprite = sprite

	// Fade the sprite in the next X seconds
	local SpriteFadeTime = CurTime() + ( dietime + 1 )
	local SpriteFade = "ww_sprite_fade" .. sprite:EntIndex()

	timer.Simple( dietime, function()
		timer.Create( SpriteFade, 0, 0, function()
			if not IsValid( sprite ) then timer.Remove( SpriteFade ) return end

			local deltaTime = SpriteFadeTime - CurTime()
			if deltaTime > 0 then
				sprite:SetKeyValue( "renderamt", alpha * deltaTime )
			else
				sprite:Remove()
				if IsValid( self ) and self.pGlowSprite then
					self.pGlowSprite = nil
				end
				timer.Remove( SpriteFade )
			end
		end )
	end )

	return sprite
end

function ENT:CreateSpriteTrail()
	if not self:IsMarkedForDeletion() and self.SpriteTrailMaterial and not self.SpriteTrail then
		self.SpriteTrail = util.SpriteTrail( self, self.SpriteTrailAttachment or 1, self.SpriteTrailColor or color_white, tobool(self.SpriteTrailAdditive), self.SpriteTrailStartWidth or 4, self.SpriteTrailEndWidth or 0, self.SpriteTrailLifetime or 0.5, self.SpriteTrailResolution or 0.1, self.SpriteTrailMaterial)
	end
end
