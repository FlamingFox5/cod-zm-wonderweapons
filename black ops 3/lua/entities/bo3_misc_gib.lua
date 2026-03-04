
AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Zombie Gib"
ENT.Purpose = "Spawns a random bloody zombie gib."
ENT.Spawnable = true
ENT.AdminOnly = false
ENT.Category = "TFA Other"

ENT.Life = 4

local SinglePlayer = game.SinglePlayer()

function ENT:SpawnFunction( ply, tr, ClassName )
	if ( !tr.Hit ) then return end

	local size = 6
	local SpawnPos = tr.HitPos + tr.HitNormal * size

	-- Make sure the spawn position is not out of bounds
	local oobTr = util.TraceLine( {
		start = tr.HitPos,
		endpos = SpawnPos,
		mask = MASK_SOLID_BRUSHONLY
	} )

	if ( oobTr.Hit ) then
		SpawnPos = oobTr.HitPos + oobTr.HitNormal * ( tr.HitPos:Distance( oobTr.HitPos ) / 2 )
	end

	local aimangle = ply:GetAimVector():Angle()

	local ent = ents.Create( ClassName )
	ent:SetPos(SpawnPos)
	ent:SetAngles(Angle( 0, aimangle[2], 0 ) )

	ent.SpawnMenuCreated = true

	ent:Spawn()
	ent:Activate()

	local phys = ent:GetPhysicsObject()
	if IsValid(phys) then
		phys:SetMass( 5 )
		phys:SetBuoyancyRatio( 0 )

		local angvel = Vector( 0, math.random( -20, 20 ) * 10, math.random( -20, 20 ) * 10 )
		angvel:Rotate( -1 * ply:EyeAngles() )
		angvel:Rotate( Angle( 0, ply:EyeAngles().y, 0 ) )

		phys:AddAngleVelocity( angvel )

		local fuck1 = math.random(2) == 2 and 10 or -10
		local fuck2 = math.random(2) == 1 and -10 or 10
		phys:SetVelocity( Vector( 0, 0, math.random( 400, 660 ) ) + Vector( math.random( 0, 4 ) * fuck1, math.random( 0, 4 ) * fuck2, 0 ) )
	end

	return ent
end

function ENT:Draw()
end

function ENT:Initialize()
	if SERVER then
		self:PhysicsInit( SOLID_NONE )
		self:SetMoveType( MOVETYPE_NONE )
		self:SetSolid( SOLID_NONE )

		self:SetNotSolid( true )
		self:SetNoDraw( true )

		self:SetCollisionGroup( COLLISION_GROUP_IN_VEHICLE )

		local phys = self:GetPhysicsObject()
		if IsValid( phys ) and phys:GetVelocity():Length() > 0 then
			TFA.WonderWeapon.CreateHorrorGib( self:GetPos(), self:GetAngles(), phys:GetVelocity(), phys:GetAngleVelocity(), self.Life, self.BloodColor )
		else
			TFA.WonderWeapon.CreateHorrorGib( self:GetPos(), self:GetAngles(), nil, nil, self.Life, self.BloodColor)
		end

		SafeRemoveEntityDelayed( self, 0 )
	end
end

function ENT:Think()
	return false
end
