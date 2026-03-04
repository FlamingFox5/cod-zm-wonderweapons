
//ENT.WhizbySound = "NPC_CombineBall_Episodic.WhizFlyby" // sound or table of sounds for projectile whizby
ENT.WhizbySoundLevel = SNDLVL_80dB
ENT.WhizbySoundPitch = 100 // int or table, {97, 103}
ENT.WhizbyDistance = 200
ENT.WhizbyBoxMaxs = Vector( 100, 100, 100 )
ENT.WhizbyBoxMins = ENT.WhizbyBoxMaxs:GetNegated()
ENT.WhizbyCooldown = 0.5

local WHIZBY_DISTANCE = 200^2
local WHIZBY_BOX_MAXS = Vector( 100, 100, 100 )
local WHIZBY_BOX_MINS = WHIZBY_BOX_MAXS:GetNegated()

local PointOnSegmentNearestToPoint = TFA.WonderWeapon.PointOnSegmentNearestToPoint

function ENT:WhizSoundThink( start, endpos, direction )
	if self:GetCreationTime() + 0.2 > CurTime() then return end

	for _, ent in pairs( ents.FindInBox( self:LocalToWorld( self.WhizbyBoxMaxs or WHIZBY_BOX_MAXS ), self:LocalToWorld( self.WhizbyBoxMins or WHIZBY_BOX_MINS ) ) ) do
		if not ent:IsPlayer() then continue end
		if ent.EntityWhizbyTable and ent.EntityWhizbyTable[ self:EntIndex() ] and ent.EntityWhizbyTable[ self:EntIndex() ] > CurTime() then continue end

		local playerPos = ent:GetPos()

		local vecDelta = Vector()
		vecDelta:Set(start)
		vecDelta:Sub(playerPos)
		vecDelta:Normalize()

		if vecDelta:DotProduct( direction ) > 0.5 then
			local radial_origin = PointOnSegmentNearestToPoint( start, endpos, playerPos )
			if playerPos:DistToSqr( radial_origin ) < ( self.WhizbyDistance^2 or WHIZBY_DISTANCE ) then
				local filter = RecipientFilter()
				filter:AddPlayer(ent)

				if !ent.EntityWhizbyTable then
					ent.EntityWhizbyTable = {}
				end

				ent.EntityWhizbyTable[ self:EntIndex() ] = CurTime() + ( self.WhizbyCooldown or 0.5 )

				self:EmitSound( istable( self.WhizbySound ) and self.WhizbySound[ math.random( #self.WhizbySound ) ] or self.WhizbySound, self.WhizbySoundLevel or SNDLVL_80db, 100, 1, CHAN_ITEM, 0, 0, filter )
			end
		end
	end
end
