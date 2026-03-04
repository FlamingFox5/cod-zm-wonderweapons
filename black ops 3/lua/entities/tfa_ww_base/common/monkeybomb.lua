
local nzombies = engine.ActiveGamemode() == "nzombies"

local sv_friendly_fire = GetConVar("sv_tfa_bo3ww_friendly_fire")
local sv_npc_friendly_fire = GetConVar("sv_tfa_bo3ww_npc_friendly_fire")
local sv_npc_require_los = GetConVar("sv_tfa_bo3ww_monkeybomb_use_los")

local SinglePlayer = game.SinglePlayer()

ENT.NPCAttractRange = 1024
ENT.NPCAttractTauntRange = 40
ENT.NPCAttractRequireLOS = false

ENT.NextBotAttractRange = 1024

function ENT:MonkeyBomb()
	if CLIENT then return end

	local ply = self:GetOwner()
	local numAlerts = 0
	local target = self:GetBullseye( Vector( 0, 0, 12 ) )
	if not IsValid( target ) then
		target = self
	end

	for _, ent in RandomPairs( ents.FindInSphere( self:GetPos(), ( self.NPCAttractRange or 2048 ) ) ) do
		if v == ply then continue end
		if IsValid( ent ) and ent:IsNPC() then
			if ent.StatusEffectFrozen then
				continue
			end

			if ( self.NPCAttractRequireLOS or ( sv_npc_require_los and sv_npc_require_los:GetBool() ) ) and not ent:IsInViewCone(self) then
				continue
			end

			if not sv_friendly_fire:GetBool() and IsValid(ply) and ent:Disposition(ply) == D_LI then
				continue
			end

			if not sv_npc_friendly_fire:GetBool() and IsValid(ply) and ply:IsNPC() and ply:Disposition(ent) == D_LI then
				continue
			end

			if ent:GetEnemy() ~= target then
				ent:ClearSchedule()
				ent:ClearEnemyMemory( ent:GetEnemy() )
				ent:SetEnemy( target )
				ent:SetArrivalActivity( ACT_COWER )

				if numAlerts < 3 then
					numAlerts = 1 + numAlerts
					ent:AlertSound()
				end
			end

			ent:UpdateEnemyMemory( target, target:GetPos() )

			ent:SetSaveValue( "m_vecLastPosition", target:GetPos() )

			local far = ent:GetPos():DistToSqr( target:GetPos() ) > 250000
			if ent.SetSchedule then
				if not far and SCHED_FORCED_GO_RUN then
					ent:SetSchedule( SCHED_FORCED_GO_RUN )
				elseif far then
					ent:SetSchedule( SCHED_CHASE_ENEMY )
				else
					ent:SetSchedule( SCHED_FORCED_GO )
				end
			end

			if ent.SetSaveValue then
				ent:SetSaveValue( "m_flGroundSpeed", 400 )
				ent:SetSaveValue( "m_iSpeedMod", 2 )
			end

			if ent:GetPos():DistToSqr( self:GetPos() ) < self.NPCAttractTauntRange^2 and ent:IsMoving() then
				ent:PointAtEntity( target )
				ent:SetSchedule( SCHED_DISARM_WEAPON )

				ent:StopMoving( true )
				ent:MoveStop()

				ent:SentenceStop()
				ent:FoundEnemySound()

				timer.Simple(math.Rand(0.8,1.4), function()
					if not IsValid(ent) then return end
					ent:ClearSchedule()
					ent:SetSchedule( SCHED_COWER )
				end)
			end
		end
	end
end

function ENT:MonkeyBombNXB()
	if CLIENT then return end

	local target = self:GetBullseye( Vector( 0, 0, 12 ) )
	if not IsValid( target ) then
		target = self
	end

	local ply = self:GetOwner()
	for _, ent in RandomPairs( ents.FindInSphere( self:GetPos(), ( self.NextBotAttractRange or 2048 ) ) ) do
		if ent == ply then continue end
		if IsValid( ent ) and ent:IsNextBot() and ( !nzombies or ( nzombies and !ent:IsValidZombie() ) ) then
			if ent.StatusEffectFrozen then
				continue
			end

			if ( self.NPCAttractRequireLOS or ( sv_npc_require_los and sv_npc_require_los:GetBool() ) ) and not ent:VisibleVec(self:GetPos() + vector_up*8) then
				continue
			end

			if not sv_npc_friendly_fire:GetBool() and IsValid( ply ) and ply:IsNPC() and ply:Disposition( ent ) == D_LI then
				continue
			end

			if not sv_friendly_fire:GetBool() and IsValid( ply ) and ent.Disposition and isfunction(ent.Disposition) then
				local nDisposition = ent:Disposition( ply )
				if isnumber( nDisposition ) and nDisposition == D_LI then
					continue
				end
			end

			ent.loco:FaceTowards( target:GetPos() )
			ent.loco:Approach( target:GetPos(), 99 )

			if ent.SetEnemy then
				ent:SetEnemy( target )
			end

			if ent.SetTarget and isfunction( ent.SetTarget ) then
				ent:SetTarget( target )
			end

			if ent.AddEntityRelationship then
				ent:AddEntityRelationship( target, D_HT, 99 )
			end

			if ent.UpdateEnemyMemory then
				ent:UpdateEnemyMemory( target, target:GetPos() )
			end

			if ent.SetGoalEntity and isfunction( ent.SetGoalEntity ) then
				ent:SetGoalEntity( target )
			end
		end
	end
end

function ENT:CleanupMonkeyBomb()
	if CLIENT then return end

	if self.pBullseye and IsValid( self.pBullseye ) then
		self.pBullseye:Remove()
		self.pBullseye = nil
	end

	for _, ent in pairs( ents.FindInSphere( self:GetPos(), self.NPCAttractRange or 2048 ) ) do
		if ent:IsNPC() and ent:GetEnemy() == self then
			ent:ClearSchedule()
			ent:ClearEnemyMemory( ent:GetEnemy() )

			if not ent.StatusEffectFrozen then
				ent:SetCondition( COND.NPC_UNFREEZE )
			end

			ent:SetSchedule( SCHED_ARM_WEAPON )
		end
	end
end
