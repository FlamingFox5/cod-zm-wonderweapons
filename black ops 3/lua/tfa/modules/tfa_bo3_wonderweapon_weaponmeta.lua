local nzombies = engine.ActiveGamemode() == "nzombies"
local pvp_cvar = GetConVar("sbox_playershurtplayers")
local SinglePlayer = game.SinglePlayer()

/*local ENTITY = FindMetaTable("Entity")

if ENTITY then
	local old_GetCollisionGroup = ENTITY.GetCollisionGroup

	function ENTITY:GetCollisionGroup( ... )
		if not self:IsPlayer() and self.CollisionGroupOverride and isnumber( self.CollisionGroupOverride ) then
			return self.CollisionGroupOverride
		else
			return old_GetCollisionGroup( self, ... )
		end
	end
end*/

//--------------------------------------------------------------
// Weapon Draw Particles System 
//--------------------------------------------------------------

local WonderWeapons = TFA.WonderWeapon

if CLIENT then
	//  please be gentle, i didnt want to have to make 4 different sub weapon bases for a couple features

	local WEAPON = FindMetaTable("Weapon")

	if WEAPON then
		function WEAPON:AddDrawCallViewModelParticle(effect, attachtype, attachment, active, name, offset, cpoints )
			if not effect or not isstring( effect ) or effect == "" then
				return
			end

			if not name or not isstring( name ) or name == "" then
				name = effect.."."..attachment
			end

			local viewmodel = self
			if self.OwnerViewModel and IsValid( self.OwnerViewModel ) then
				viewmodel = self.OwnerViewModel
			elseif IsValid(self:GetOwner()) and self:GetOwner().GetViewModel then
				viewmodel = self:GetOwner():GetViewModel()
			end

			if not self.CNewViewModelParticles or not istable( self.CNewViewModelParticles ) then
				self.CNewViewModelParticles = {}
			end

			if tobool( active ) then
				local CNPSystem = self.CNewViewModelParticles[ name ]

				if IsValid(CNPSystem) and CNPSystem:GetEffectName() ~= effect then
					self.CNewViewModelParticles[ name ]:StopEmissionAndDestroyImmediately()
					self.CNewViewModelParticles[ name ] = nil
					CNPSystem = nil
				end

				if not CNPSystem or not IsValid( CNPSystem ) then
					self.CNewViewModelParticles[ name ] = CreateParticleSystem( viewmodel, effect, attachtype or PATTACH_ABSORIGIN_FOLLOW, attachment or 1, offset or vector_origin )

					if self.CNewViewModelParticles[ name ] and IsValid( self.CNewViewModelParticles[ name ] ) then
						self.CNewViewModelParticles[ name ]:SetIsViewModelEffect( true )

						if cpoints and istable( cpoints ) and not table.IsEmpty( cpoints ) then
							for cpoint, vector in pairs( cpoints ) do
								if not vector or not isvector( vector ) then
									continue
								end

								self.CNewViewModelParticles[ name ]:SetControlPoint( tonumber( cpoint ), vector )
							end
						end
					end

					local removeHook = "WonderWeapon.ViewParticleClean." .. name

					self:RemoveCallOnRemove( removeHook )

					self:CallOnRemove( removeHook, function( removed, fullUpdate )
						if fullUpdate ~= nil and tobool( fullUpdate ) then return end

						if removed.CNewViewModelParticles and istable( removed.CNewViewModelParticles ) and IsValid(removed.CNewViewModelParticles[ name ]) then
							removed.CNewViewModelParticles[ name ]:StopEmission()
						end
					end )

					hook.Run( "TFA_WonderWeapon_ViewModelParticleCreated", self, viewmodel, self.CNewViewModelParticles[ name ], effect, attachtype, attachment, active, name, cpoints )
				end

				return self.CNewViewModelParticles[ name ]
			elseif self.CNewViewModelParticles[ name ] and IsValid( self.CNewViewModelParticles[ name ] ) then
				self.CNewViewModelParticles[ name ]:StopEmissionAndDestroyImmediately()
			end
		end

		// Supports argument overload of name being the particle effects name instead, and will return first instance of that effect attached to the entity

		function WEAPON:GetDrawCallViewModelParticle( name )
			if not self.CNewViewModelParticles then
				return
			end

			if not name or not isstring( name ) or name == "" then
				return
			end

			if self.CNewViewModelParticles and self.CNewViewModelParticles[ name ] then
				return self.CNewViewModelParticles[ name ]
			else
				for effectName, CNP in pairs( self.CNewViewModelParticles ) do
					if string.find( effectName, name ) then
						return self.CNewViewModelParticles[ effectName ]
					end
				end
			end
		end

		function WEAPON:AddDrawCallWorldModelParticle( effect, attachtype, attachment, active, name, offset, cpoints )
			if not effect or not isstring( effect ) or effect == "" then
				return
			end

			if not name or not isstring( name ) or name == "" then
				name = effect.."."..attachment
			end

			if not self.CNewWorldModelParticles or not istable( self.CNewWorldModelParticles ) then
				self.CNewWorldModelParticles = {}
			end

			if tobool( active ) then
				local CNPSystem = self.CNewWorldModelParticles[ name ]

				if IsValid(CNPSystem) and CNPSystem:GetEffectName() ~= effect then
					self.CNewWorldModelParticles[ name ]:StopEmissionAndDestroyImmediately()
					self.CNewWorldModelParticles[ name ] = nil
					CNPSystem = nil
				end

				if not CNPSystem or not IsValid( CNPSystem ) then
					self.CNewWorldModelParticles[ name ] = CreateParticleSystem( self, effect, attachtype or PATTACH_ABSORIGIN_FOLLOW, attachment or 1, offset or vector_origin )

					if self.CNewWorldModelParticles[ name ] and IsValid( self.CNewWorldModelParticles[ name ] ) then
						self.CNewWorldModelParticles[ name ]:SetIsViewModelEffect( false )

						if cpoints and istable( cpoints ) and not table.IsEmpty( cpoints ) then
							for cpoint, vector in pairs( cpoints ) do
								if not vector or not isvector( vector ) then
									continue
								end

								self.CNewWorldModelParticles[ name ]:SetControlPoint( tonumber( cpoint ), vector )
							end
						end
					end

					local removeHook = "WonderWeapon.WorldParticleClean." .. name

					self:RemoveCallOnRemove( removeHook )

					self:CallOnRemove( removeHook, function( removed, fullUpdate )
						if fullUpdate ~= nil and tobool( fullUpdate ) then return end

						if removed.CNewWorldModelParticles and istable( removed.CNewWorldModelParticles ) and IsValid(removed.CNewWorldModelParticles[ name ]) then
							removed.CNewWorldModelParticles[ name ]:StopEmission()
						end
					end )

					hook.Run( "TFA_WonderWeapon_WorldModelParticleCreated", self, viewmodel, self.CNewWorldModelParticles[ name ], effect, attachtype, attachment, active, name, cpoints )
				end

				return self.CNewWorldModelParticles[ name ]
			elseif self.CNewWorldModelParticles[ name ] and IsValid( self.CNewWorldModelParticles[ name ] ) then
				self.CNewWorldModelParticles[ name ]:StopEmissionAndDestroyImmediately()
			end
		end

		function WEAPON:AddDrawCallWorldModelElementParticle( element, effect, attachtype, attachment, active, name, offset, cpoints )
			if not self.IsTFAWeapon then return end

			if not element or not isstring( element ) or element == "" then
				return
			end

			if not effect or not isstring( effect ) or effect == "" then
				return
			end

			if not name or not isstring( name ) or name == "" then
				name = effect.."."..attachment
			end

			if not self.CNewWorldModelParticles or not istable( self.CNewWorldModelParticles ) then
				self.CNewWorldModelParticles = {}
			end

			local WorldModelElements = self:GetStatRaw("WorldModelElements", TFA.LatestDataVersion)
			if not WorldModelElements or not WorldModelElements[ element ] then return end

			local elementmodel = WorldModelElements[ element ].curmodel
			if not IsValid( elementmodel ) then return end

			if tobool( active ) then
				local CNPSystem = self.CNewWorldModelParticles[ name ]

				if IsValid(CNPSystem) and CNPSystem:GetEffectName() ~= effect then
					self.CNewWorldModelParticles[ name ]:StopEmissionAndDestroyImmediately()
					self.CNewWorldModelParticles[ name ] = nil
					CNPSystem = nil
				end

				if not CNPSystem or not IsValid( CNPSystem ) then
					self.CNewWorldModelParticles[ name ] = CreateParticleSystem( elementmodel, effect, attachtype or PATTACH_ABSORIGIN_FOLLOW, attachment or 1, offset or vector_origin )

					if self.CNewWorldModelParticles[ name ] and IsValid( self.CNewWorldModelParticles[ name ] ) then
						self.CNewWorldModelParticles[ name ]:SetIsViewModelEffect( false )

						if cpoints and istable( cpoints ) and not table.IsEmpty( cpoints ) then
							for cpoint, vector in pairs( cpoints ) do
								if not vector or not isvector( vector ) then
									continue
								end

								self.CNewWorldModelParticles[ name ]:SetControlPoint( tonumber( cpoint ), vector )
							end
						end
					end

					local removeHook = "WonderWeapon.WorldParticleClean." .. name

					self:RemoveCallOnRemove( removeHook )

					self:CallOnRemove( removeHook, function( removed, fullUpdate )
						if fullUpdate ~= nil and tobool( fullUpdate ) then return end

						if removed.CNewWorldModelParticles and istable( removed.CNewWorldModelParticles ) and IsValid(removed.CNewWorldModelParticles[ name ]) then
							removed.CNewWorldModelParticles[ name ]:StopEmission()
						end
					end )

					hook.Run( "TFA_WonderWeapon_WorldModelParticleCreated", self, viewmodel, self.CNewWorldModelParticles[ name ], effect, attachtype, attachment, active, name, cpoints )
				end

				return self.CNewWorldModelParticles[ name ]
			elseif self.CNewWorldModelParticles[ name ] and IsValid( self.CNewWorldModelParticles[ name ] ) then
				self.CNewWorldModelParticles[ name ]:StopEmissionAndDestroyImmediately()
			end
		end

		// Supports argument overload of name being the particle effects name instead, and will return first instance of that effect attached to the entity

		function WEAPON:GetDrawCallWorldModelParticle( name )
			if not self.CNewWorldModelParticles then
				return
			end

			if not name or not isstring( name ) or name == "" then
				return
			end

			if self.CNewWorldModelParticles and self.CNewWorldModelParticles[ name ] then
				return self.CNewWorldModelParticles[ name ]
			else
				for effectName, CNP in pairs( self.CNewWorldModelParticles ) do
					if string.find( effectName, name ) then
						return self.CNewWorldModelParticles[ effectName ]
					end
				end
			end
		end
	end

	local WeaponsList = WonderWeapons.WeaponList

	// functions as a "PostDrawAllViewModels" according to the wiki
	//  used to cleanup third person particles when the LocalPlayer swaps back to firstperson

	hook.Add( "PreDrawEffects", "TFA.BO3WW.FOX.WeaponParticles.Fix", function()
		local ply = LocalPlayer()
		if IsValid( ply:GetObserverTarget() ) then
			ply = ply:GetObserverTarget()
		end

		if IsValid( ply ) and ply.GetActiveWeapon then
			local wep = ply:GetActiveWeapon()

			if ( IsValid( wep ) and ( wep.IsTFAWeapon or wep.SDLP ) ) then
				local CNParticles = wep.CNewWorldModelParticles

				if ( wep:IsFirstPerson() or wep.SDLP ) and CNParticles and next( CNParticles ) then

					for _, CNPSystem in pairs( CNParticles ) do
						if IsValid( CNPSystem ) then
							CNPSystem:StopEmissionAndDestroyImmediately()
						end
					end

					wep.CNewWorldModelParticles = {}
				end
			end
		end

		// TODO: Figure out why this shit dont work
		/*if WeaponsList then
			for i, wep in ipairs( WeaponsList ) do
				if not IsValid( wep ) then continue end

				local owner = wep:GetOwner()
				if IsValid( owner ) and owner.GetActiveWeapon then
					local active = owner:GetActiveWeapon()

					if not IsValid( active ) or wep ~= active then
						local CNParticles = wep.CNewWorldModelParticles

						if CNParticles and next( CNParticles ) then
							for _, CNPSystem in pairs( CNParticles ) do
								if IsValid( CNPSystem ) then
									CNPSystem:StopEmissionAndDestroyImmediately()
								end
							end

							wep.CNewWorldModelParticles = {}
						end
					end
				end
			end
		end*/
	end )
end

//--------------------------------------------------------------
// Weapon Waterlevel
//--------------------------------------------------------------

if SERVER then
	util.AddNetworkString("TFA.BO3WW.FOX.WaterLevelChanged")

	hook.Add( "OnEntityWaterLevelChanged", "TFA.BO3WW.FOX.WaterLevelChanged", function( entity, old, new )
		if not entity.GetActiveWeapon or not isfunction( entity.GetActiveWeapon ) then return end

		local wep = entity:GetActiveWeapon()
		if IsValid( wep ) and wep.IsTFAWeapon and wep.OnWaterLevelChanged then
			hook.Run( "TFA_WonderWeapon_WaterLevelChanged", entity, wep, old, new )

			wep:OnWaterLevelChanged( entity, old, new )

			if entity:IsPlayer() then
				local viewers = { entity }
				if IsValid( entity:GetObserverTarget() ) then
					table.insert( viewers, entity:GetObserverTarget() )
				end

				net.Start( "TFA.BO3WW.FOX.WaterLevelChanged" )
					net.WriteInt( old, 4 )
					net.WriteInt( new, 4 )
				net.Send( viewers )
			end
		end
	end )
end

if CLIENT then
	net.Receive( "TFA.BO3WW.FOX.WaterLevelChanged", function( length, ply )
		local old = net.ReadInt(4)
		local new = net.ReadInt(4)

		local ply = LocalPlayer()
		if IsValid( ply:GetObserverTarget() ) then
			ply = ply:GetObserverTarget()
		end

		local wep = ply:GetActiveWeapon()
		if IsValid( wep ) and wep.IsTFAWeapon and wep.OnWaterLevelChanged then
			hook.Run( "TFA_WonderWeapon_WaterLevelChanged", entity, wep, old, new )

			wep:OnWaterLevelChanged( ply, old, new )
		end
	end )
end
