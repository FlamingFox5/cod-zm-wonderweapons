
ENT.AugerDeathSpiral = false
ENT.AugerTime = 1.5
ENT.AugerMarkDeadTime = 0.75
ENT.AugerSpeed = ENT.MaxSpeed and math.min( ENT.MaxSpeed, 1000 ) or 1000
ENT.AugerHealth = ENT.MaxHealth and math.min( ENT.MaxHealth, 75 ) or 75

local AUGER_THINK_INTERVAL = 0.05
local AUGER_YDEVIANCE = 20
local AUGER_XDEVIANCEUP = 8
local AUGER_XDEVIANCEDOWN = 1

// called from main ENT:Think()
function ENT:AugerThink()
	if self.NextAugerThink and self.NextAugerThink > CurTime() then
		return
	end

	if self.fl_AugerTime < CurTime() then
		self.killtime = -1
	end

	if self.fl_MarkedDeadTime < CurTime() then
		self:SetKeyValue("m_lifeState", "1")
	end

	local angles = self:GetLocalAngles()

	angles.y = math.Rand( -AUGER_YDEVIANCE, AUGER_YDEVIANCE )
	angles.x = math.Rand( -AUGER_XDEVIANCEDOWN, AUGER_XDEVIANCEUP )

	self:SetLocalAngles( angles )

	local vecForward = self:GetLocalAngles():Forward()

	self.Direction = vecForward

	local pPhysObject = self:GetPhysicsObject()
	if IsValid( pPhysObject ) then
		local flRatio = math.Clamp( ( self.fl_AugerTime - CurTime() ) / 1.5, 0, 1 )
		pPhysObject:SetVelocity( vecForward * ( math.Remap( flRatio, 0, 1, self.AugerSpeed, self.Speed or pPhysObject:GetVelocity():Length() ) ) )
	end

	self.NextAugerThink = CurTime() + AUGER_THINK_INTERVAL
end

function ENT:OnTakeDamage( damageinfo )
	if self.AugerDeathSpiral and !self.HasShotDown then
		local bIsDamaged
		if ( self:GetInternalVariable("m_iHealth") <= self.AugerHealth ) then
			// This missile is already damaged (i.e., already running AugerThink)
			bIsDamaged = true;
		else
			// This missile isn't damaged enough to wobble in flight yet
			bIsDamaged = false;
		end

		local nRetVal
		if BaseClass.OnTakeDamage then
			nRetVal = BaseClass.OnTakeDamage( self, damageinfo )
		end

		if ( !bIsDamaged ) and ( self:GetInternalVariable("m_iHealth") <= self.AugerHealth ) then
			self:ShotDown( damageinfo )
		end

		if nRetVal then
			return nRetVal
		end
	end
end

function ENT:ShotDown( damageinfo )
	local vecSrc = damageinfo and damageinfo:GetReportedPosition() or vector_origin
	local vecHit = damageinfo and damageinfo:GetDamagePosition() or vector_origin

	local vecSpot = self:GetPos()

	if not isvector( vecSrc ) or vecSrc == vector_origin then
		vecSrc = vecSpot
	end
	if not isvector( vecHit ) or vecHit == vector_origin then
		vecHit = vecSrc + vector_up
	end

	local vecDir = ( vecSrc - vecHit ):GetNormalized()

	local data = EffectData()
	data:SetOrigin( vecSpot )
	data:SetNormal( self:GetLocalAngles():Forward() )
	data:SetEntity( self )
	data:SetAngles( vecDir:Angle() )

	DispatchEffect( "RPGShotDown", data )

	self.HasShotDown = true
	self.NextAugerThink = CurTime()

	self.fl_AugerStartTime = CurTime()
	self.fl_AugerTime = CurTime() + (self.AugerTime or 1.5)
	self.fl_MarkedDeadTime = CurTime() + (self.AugerMarkDeadTime or 0.75)

	local weapon = self.Inflictor
	if IsValid( weapon ) and weapon.NotifyRocketDied then
		weapon:NotifyRocketDied( self, damageinfo )
	end
end
