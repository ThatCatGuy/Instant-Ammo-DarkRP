local function universal_ammo(ply, ent, cost)

    if IsValid(ply) and ply:IsPlayer() and ply.UniversalAmmoCooldown == nil or ply.UniversalAmmoCooldown + UNIVERSAL_AMMO_COOLDOWN < CurTime() then

        ply.UniversalAmmoCooldown = CurTime()
        local swep = ply:GetActiveWeapon()

        if swep and IsValid(swep) then
            local ammoType = swep:GetPrimaryAmmoType()

            if ammoType and ammoType ~= -1 then
                local ammo = game.GetAmmoName(ammoType)
                local amount = UniversalAmmo.GetBullets(ammo) * (ent.amountGiven or 1) -- allow ammo stacking
                if amount == 0 then
                    ply:ChatPrint("Sorry, this weapon cannot use universal ammo!")
                    ply:addMoney(cost)
                    return
                else
                    ply:GiveAmmo(amount, ammo)
                end
            else
                ply:ChatPrint("Please equip the weapon you wish to refill!")
                ply:addMoney(cost)
                ply.UniversalAmmoCooldown = CurTime()
                return
            end
        end
    end

end

local function universal_ammo_secondary(ply, ent, cost)

    if IsValid(ply) and ply:IsPlayer() and ply.UniversalAmmoCooldown == nil or ply.UniversalAmmoCooldown + UNIVERSAL_AMMO_COOLDOWN < CurTime() then

        ply.UniversalAmmoCooldown = CurTime()
        local swep = ply:GetActiveWeapon()

        if swep and IsValid(swep) then
            local ammoType = swep:GetSecondaryAmmoType()

            if ammoType and ammoType ~= -1 then
                local ammo = game.GetAmmoName(ammoType)
                print(ammo)
                local amount = UniversalAmmo.GetBullets(ammo) * (ent.amountGiven or 1) -- allow ammo stacking
                if amount == 0 then
                    ply:ChatPrint("Sorry, this weapon cannot use universal ammo!")
                    ply:addMoney(cost)
                else
                    ply:GiveAmmo(amount, ammo)
                end
            else
                ply:ChatPrint("Held weapon doesn't take secondary ammo!")
                ply:addMoney(cost)
                ply.UniversalAmmoCooldown = CurTime()
            end
        end
    end

end

local function makeSWEPPrimaryAmmoInfinite(ply, swep, ammoType)
        local ammo = game.GetAmmoName(ammoType)

        -- Fill the clip
        swep:SetClip1(swep:GetMaxClip1())

        -- Watch weapon to return used ammo
        swep.IsUniversalAmmoInfinite = true

        local originalTake = swep.TakePrimaryAmmo
        swep.TakePrimaryAmmo = function(self, amount, ...)
            swep.UniversalAmmoGiveBack = swep.UniversalAmmoGiveBack and swep.UniversalAmmoGiveBack + amount or 1
            return originalTake(self, amount, ...)
        end

        local originalReload = swep.Reload

        swep.Reload = function(...)
            local usedAmmo = swep.UniversalAmmoGiveBack
            if usedAmmo then
                ply:GiveAmmo(usedAmmo, ammo)
                swep.UniversalAmmoGiveBack = 0
            end
            return originalReload(...)
        end
    end

local function universal_ammo_infinite(ply, ent, cost)

    local equipSounds = {
        "ambient/levels/labs/electric_explosion1.wav",
        "ambient/levels/labs/electric_explosion2.wav",
        "ambient/levels/labs/electric_explosion3.wav",
        "ambient/levels/labs/electric_explosion4.wav",
        "ambient/levels/labs/electric_explosion5.wav"
    }
    if IsValid(ply) and ply:IsPlayer() and ply.UniversalAmmoCooldown == nil or ply.UniversalAmmoCooldown + UNIVERSAL_AMMO_COOLDOWN < CurTime() then

        ply.UniversalAmmoCooldown = CurTime()
        local swep = ply:GetActiveWeapon()

        if swep and IsValid(swep) then
            local ammoType = swep:GetPrimaryAmmoType()

            if ammoType and ammoType ~= -1 then
                -- Prevent pickup if not allowed for swep
                local ammo = game.GetAmmoName(ammoType)
                local amount = UniversalAmmo.GetBullets(ammo) * (ent.amountGiven or 1) -- allow ammo stacking
                if amount == 0 then
                    ply:ChatPrint("Sorry, this weapon cannot use universal ammo!")
                    ply:addMoney(cost)
                    return
                end

                if not swep.IsUniversalAmmoInfinite then
                    -- Don't want something to be infinite?
                    local pleaseNo = hook.Run("UniversalAmmo_PreventInfinite", ply, swep, ammoType)

                    if pleaseNo then
                        ply:ChatPrint("Sorry, this weapon cannot use infinite ammo!")
                        ply:addMoney(cost)
                        return
                    end

                    -- Sound and effect
                    ply:EmitSound(table.Random(equipSounds), 100, 100, 1, CHAN_AUTO)
                    local effectdata = EffectData()
                    effectdata:SetOrigin(ply:GetPos())
                    effectdata:SetScale(0.2)
                    util.Effect("HelicopterMegaBomb", effectdata)

                    -- Actual logic
                    makeSWEPPrimaryAmmoInfinite(ply, swep, ammoType)
                else
                    ply:ChatPrint("Weapon already equiped with infinite ammo!")
                    ply:addMoney(cost)
                end
            else
                ply:ChatPrint("Held weapon doesn't take primary ammo!")
                ply:addMoney(cost)
                ply.UniversalAmmoCooldown = CurTime()
            end
        end
    end

end


local universalammo = {
    ["universal_ammo"] = true,
    ["universal_ammo_secondary"] = true,
    ["universal_ammo_infinite"] = true
}

hook.Add("playerBoughtAmmo", "AmmoToHolster", function(pPlayer, tAmmo, eEnt, nPrice)
    eEnt:Remove()
    if universalammo[tAmmo.ammoType] then
        local ammotype = tAmmo.ammoType
        if ammotype == "universal_ammo" then
            universal_ammo(pPlayer, eEnt, nPrice)
        elseif ammotype == "universal_ammo_secondary" then
            universal_ammo_secondary(pPlayer, eEnt, nPrice)
        elseif ammotype == "universal_ammo_infinite" then
            universal_ammo_infinite(pPlayer, eEnt, nPrice)
        end
    else
        pPlayer:GiveAmmo(tAmmo.amountGiven, tAmmo.ammoType)
    end    
end)