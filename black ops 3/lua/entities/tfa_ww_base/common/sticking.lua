
function ENT:LodgeProjectile( trace )
	self.BlockCollisionTrace = true

	self.BlockBubbleTrail = true

	self:AddEFlags( EFL_DONTWALKON )

	local hitEntity = trace.Entity
	if not trace.HitWorld and IsValid( hitEntity ) and hitEntity:GetInternalVariable( "m_lifeState" ) == 0 then
		//Entity(1):ChatPrint('LodgeProjectile ['..tostring(hitEntity)..'] at '..CurTime())
		self:SetParentFromTrace( trace )
	else
		if trace.HitSky then
			Entity( 1 ):ChatPrint( tostring(self) .. " was slain" )
			self:Remove()
			return
		end

		//Entity(1):ChatPrint('LodgeProjectile ['..tostring(Entity(0))..'] at '..CurTime())
		self:PhysicsStop()

		if trace.IsPhysicsCollide then
			local hitAngle = self:GetAngles()
			timer.Simple( 0, function()
				if not IsValid( self ) then return end

				self:SetCollisionGroup( COLLISION_GROUP_IN_VEHICLE )
				self:SetMoveType( MOVETYPE_NONE )

				self:SetPos( trace.HitPos - trace.HitNormal * self.ParentOffset )
				self:SetAngles( self.ParentAlign and ( self.ParentAlignOffset and ( trace.HitNormal:Angle() - self.ParentAlignOffset ) or trace.HitNormal:Angle() ) or hitAngle )
			end )
		else
			self:SetCollisionGroup( COLLISION_GROUP_IN_VEHICLE )
			self:SetMoveType( MOVETYPE_NONE )

			self:SetPos( trace.HitPos - trace.HitNormal * self.ParentOffset )
			if self.ParentAlign then
				self:SetAngles( ( self.ParentAlignOffset and ( trace.HitNormal:Angle() - self.ParentAlignOffset ) or trace.HitNormal:Angle() ) )
			end
		end
	end
end

function ENT:DropFromParent( flWait )
	self.BlockCollisionTrace = false

	self.BlockBubbleTrail = false

	self:RemoveEFlags( EFL_DONTWALKON )

	if IsValid( self:GetParent() ) then
		self.LastParent = self:GetParent()

		if flWait and isnumber( flWait ) and flWait ~= 0 then
			self:IgnoreEntityCollisions( self.LastParent, math.Clamp( flWait, -1, 2^31 - 1 ) )
		end

		if self.CallbackOnDrop then
			self:CallbackOnDrop( self.LastParent )
		end

		if IsValid( self.LastParent ) then
			if self.KillSelfString then
				self.LastParent:RemoveCallOnRemove( self.KillSelfString )
			end
			if self.LastParent:IsPlayer() and self.StopTransmitToParent then
				self:SetPreventTransmit( self.LastParent, false )
			end
		end
	end

	local storedPos = self:GetPos()
	local storedAng = self:GetAngles()

	self:SetParent( nil )

	self:SetCollisionGroup( nzombies and COLLISION_GROUP_DEBRIS or COLLISION_GROUP_PROJECTILE )
	self:SetMoveType( self.MoveTypeOverride or MOVETYPE_VPHYSICS )

	self:SetPos( storedPos ) // dont ask me why
	self:SetAngles( storedAng ) // i dont get it either

	local phys = self:GetPhysicsObject()
	if IsValid( phys ) then
		phys:ClearGameFlag( FVPHYSICS_NO_PLAYER_PICKUP )
		phys:ClearGameFlag( FVPHYSICS_CONSTRAINT_STATIC )

		phys:EnableGravity( true )
		phys:EnableDrag( true )

		phys:EnableMotion( true )
		phys:Wake()

		if self.ProjectileSpinOnDrop then
			phys:AddAngleVelocity( Vector( 0, math.random( -600, 600 ), math.random( -600, 600 ) ) )
			phys:SetVelocity( vector_up )
		end
	end

	if self.CallbackAfterDrop then
		self:CallbackAfterDrop( self.LastParent )
	end
end

function ENT:SetParentFromTrace( trace )
	if IsValid( self:GetParent() ) then
		return false
	end

	local origin = self.ParentOffset * trace.Normal
	origin:Add( trace.HitPos )

	local hitEntity = trace.Entity
	local bone = hitEntity:TranslatePhysBoneToBone( trace.PhysicsBone )

	if bone && bone >= 0 then
		local boneMatrix = hitEntity:GetBoneMatrix( bone )

		if !boneMatrix then
			self:Remove()
			return false
		end

		local position, angles = WorldToLocal( origin, trace.Normal:Angle(), boneMatrix:GetTranslation(), boneMatrix:GetAngles() )

		self:SetCollisionGroup( COLLISION_GROUP_WORLD )
		self:FollowBone( hitEntity, bone )
		self:SetLocalPos( position )
		self:SetLocalAngles( angles )

		if hitEntity:IsPlayer() and self.StopTransmitToParent then
			self:SetPreventTransmit( hitEntity, true )
		end
	else
		self:SetPos( origin )
		self:SetAngles( trace.Normal:Angle() )

		self:SetCollisionGroup( COLLISION_GROUP_WORLD )
		self:SetParent( hitEntity )
	end

	if self.DoTransmitWithParent then
		self:SetTransmitWithParent( true )
	end

	if self.ShouldDropProjectile then
		self.KillSelfString = "sticky_fixme"..self:EntIndex()
		hitEntity:CallOnRemove( self.KillSelfString, function(ent)
			if not IsValid(self) then return end
			local parent = self:GetParent()
			if IsValid(parent) and parent == ent then
				self:DropFromParent()
			end
		end )
	end

	if not trace.HitWorld and self.CallbackOnParent then
		self:CallbackOnParent( trace )
	end

	return true
end