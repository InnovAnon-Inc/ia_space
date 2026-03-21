-- ia_space/thermal/armor.lua

function ia_space.calculate_thermal_protection(player)
    local name = player:get_player_name()
    local armor_groups = player:get_armor_groups()
    local protection = 0 -- 0.0 to 1.0

    -- Standard "fire" armor group provides 0.5 protection per 100 points
    if armor_groups.fire then
        protection = math.max(protection, (armor_groups.fire / 200))
    end

    -- Technic Radiation Suit (Near-perfect thermal insulation)
    --if armor_groups.radiation_suit then -- doesn't exist ?
    --    protection = math.max(protection, 0.95)
    --end

    -- TODO: Check Technic Battery level? If suit is out of power, protection drops.
    -- if technic.get_RE_charge(itemstack) == 0 then protection = 0.1 end

    return math.min(0.99, protection) -- Never 100% to allow for extreme edge cases
end

