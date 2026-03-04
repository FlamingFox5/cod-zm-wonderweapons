//-------------------------------------------------------------
// Hacker Device
//-------------------------------------------------------------

nzHackerDevice = nzHackerDevice or AddNZModule("HackerDevice")

nzHackerDevice.Utilities = nzHackerDevice.Utilities or {}

nzHackerDevice.UtilityList = nzHackerDevice.UtilityList or {}

local HackerUtilities = nzHackerDevice.Utilities

function nzHackerDevice:AddUtility( class, data )
	HackerUtilities[ class ] = data

	if data.LinkedClasses and istable( data.LinkedClasses ) then
		for _, linkedclass in pairs( data.LinkedClasses ) do
			HackerUtilities[ linkedclass ] = data
		end
	end
end

function nzHackerDevice:GetUtility( class )
	return HackerUtilities[ class ] or nil
end
