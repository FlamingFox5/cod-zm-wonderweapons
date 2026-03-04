local nzombies = engine.ActiveGamemode() == "nzombies"

if nzombies then
	hook.Add("InitPostEntity", "NZ.BO4WW.FOX.RegisterSpecials", function()
		nzSpecialWeapons:AddSpecialGrenade( "tfa_bo4_monkeybomb", 3, false, 2.8, false, 0.4 )
		nzSpecialWeapons:AddSpecialGrenade( "tfa_bo4_matryoshka", 3, false, 2.6, false, 0.4 )
	end)
end