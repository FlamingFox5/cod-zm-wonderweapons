//-------------------------------------------------------------
// TFA Status Enumerations
//-------------------------------------------------------------

if not TFA.Enum.ChargeStatus then
	TFA.Enum.ChargeStatus = {}
end

if not TFA.Enum.STATUS_CHARGE_UP then
	TFA.AddStatus("CHARGE_UP")

	TFA.Enum.ReadyStatus[TFA.Enum.STATUS_CHARGE_UP] = true
	TFA.Enum.IronStatus[TFA.Enum.STATUS_CHARGE_UP] = true
end

TFA.Enum.ChargeStatus[TFA.Enum.STATUS_CHARGE_UP] = true

if not TFA.Enum.STATUS_CHARGE_DOWN then
	TFA.AddStatus("CHARGE_DOWN")

	TFA.Enum.IronStatus[TFA.Enum.STATUS_CHARGE_DOWN] = true
end

TFA.Enum.ChargeStatus[TFA.Enum.STATUS_CHARGE_DOWN] = true

if not TFA.Enum.STATUS_RAGNAROK_DEPLOY then
	TFA.AddStatus("RAGNAROK_DEPLOY")

	TFA.Enum.HUDDisabledStatus[TFA.Enum.STATUS_RAGNAROK_DEPLOY] = true
	TFA.Enum.IronStatus[TFA.Enum.STATUS_RAGNAROK_DEPLOY] = true
end

if not TFA.Enum.STATUS_HACKING then
	TFA.AddStatus("HACKING")

	TFA.Enum.HUDDisabledStatus[TFA.Enum.STATUS_HACKING] = true
	TFA.Enum.ReadyStatus[TFA.Enum.STATUS_HACKING] = true
	TFA.Enum.IronStatus[TFA.Enum.STATUS_HACKING] = true
end

if not TFA.Enum.STATUS_HACKING_END then
	TFA.AddStatus("HACKING_END")

	TFA.Enum.HUDDisabledStatus[TFA.Enum.STATUS_HACKING_END] = true
	TFA.Enum.IronStatus[TFA.Enum.STATUS_HACKING_END] = true
end
