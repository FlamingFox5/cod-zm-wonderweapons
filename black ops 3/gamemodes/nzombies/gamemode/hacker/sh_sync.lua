if SERVER then
	util.AddNetworkString("nzHackerDevice.SyncSettings")
	util.AddNetworkString("nzHackerDevice.SyncToServer")

	function nzHackerDevice:SyncUtilityList(data, reciever)
		net.Start("nzHackerDevice.SyncSettings")
			net.WriteTable(data)
		return reciever and net.Send(reciever) or net.Broadcast()
	end

	FullSyncModules["nzHackerDevice"] = function(ply)
		if nzHackerDevice.UtilityList and not table.Empty(nzHackerDevice.UtilityList) then
			nzHackerDevice:SyncUtilityList(nzHackerDevice.UtilityList, ply)
		end
	end

	function nzHackerDevice:UpdateSettings(data)
		if not data then return end

		if data.utilitylist then
			nzHackerDevice.UtilityList = data.utilitylist

			nzHackerDevice:SyncUtilityList(nzHackerDevice.UtilityList)
		end
	end

	local function receivedigdata(len, ply)
		local data = net.ReadTable()
		nzHackerDevice:UpdateSettings(data)
	end

	net.Receive("nzHackerDevice.SyncToServer", receivedigdata)
end

if CLIENT then
	function nzHackerDevice:UpdateSettings(data)
		if data then
			net.Start("nzDigs.SyncToServer")
				net.WriteTable(data)
			net.SendToServer()
		end
	end

	local function ReceiveUtilityListUpdate( length )
		local data = net.ReadTable()
		if not data then return end

		nzHackerDevice.UtilityList = data
	end

	net.Receive("nzHackerDevice.SyncSettings", ReceiveUtilityListUpdate)
end
