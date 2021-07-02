hook.Add("playerBoughtAmmo", "AmmoToHolster", function(pPlayer, tAmmo, eEnt, nPrice)
    eEnt:Remove()
    pPlayer:GiveAmmo(tAmmo.amountGiven, tAmmo.ammoType)
end)