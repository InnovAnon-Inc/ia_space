-- ia_space/gravity.lua

-- Helper to get distance from planetary "center"
-- Assuming sealevel is the surface and we want gravity to hit 0 at the world bottom
function ia_space.get_planetary_radius()
    local surface = ia_space.thresholds.sealevel
    local center  = ia_space.world_limits.min
    assert(surface > center)
    return math.abs(surface - center)
end

function ia_space.calculate_gravity_multiplier_crust(pos)
    -- If we are in the "Crust" (between sealevel and mantle threshold)
    -- Gravity actually increases slightly as we get closer to the heavy core
    assert(ia_space.is_strictly_between_mantle_and_sealevel_thresholds(pos))
    local y                  = pos.y
    local sealevel           = ia_space.thresholds.sealevel
    local mantle             = ia_space.thresholds.mantle
    assert(sealevel > y)
    assert(sealevel > mantle)
    local dist_from_sealevel = (sealevel - y)
    local crust_thickness    = (sealevel - mantle)
    assert(dist_from_sealevel > 0)
    assert(crust_thickness    > 0)
    local depth_pct          = dist_from_sealevel / math.abs(crust_thickness)
    return 1.0 + (depth_pct * 0.08) -- 8% gravity increase at the mantle edge
end

function ia_space.calculate_gravity_multiplier_mantle(pos)
    -- If we are in the "Core/Mantle" (below mantle threshold)
    -- Gravity drops off linearly toward the center from its peak
    assert(ia_space.is_below_mantle_threshold(pos))
    local y                = pos.y
    local mantle           = ia_space.thresholds.mantle
    local center           = ia_space.world_limits.min
    local peak_grav        = 1.08
    assert(y      > center)
    assert(mantle > center)
    local dist_from_center = (y - center)
    local core_radius      = (mantle - center)
    assert(core_radius > 0)
    --if dist_from_center <= 0 then return 0.05 end
    local grav             = (dist_from_center / math.abs(core_radius)) * peak_grav
    return math.max(0.05, grav)
end

function ia_space.calculate_gravity_multiplier_normal(pos)
    -- 2. EXTERNAL GRAVITY (Inverse Square Law)
    -- g = (R / (R + h))^2
    assert(ia_space.is_above_sealevel_threshold(pos))
    local y                  = pos.y
    local sealevel           = ia_space.thresholds.sealevel
    local R                  = ia_space.get_planetary_radius()
    assert(y      > sealevel)
    assert(R      > sealevel)
    assert(R      > y)
    local dist_from_sealevel = (y - sealevel)
    local grav               = (R / (R + dist_from_sealevel)) ^ 2
    return math.max(0.05, grav)
end

function ia_space.calculate_gravity_multiplier(pos)
    if ia_space.is_strictly_between_mantle_and_sealevel_thresholds(pos) then
	return ia_space.calculate_gravity_multiplier_crust (pos)
    end
    if ia_space.is_below_mantle_threshold(pos) then
	return ia_space.calculate_gravity_multiplier_mantle(pos)
    end
    assert(ia_space.is_above_sealevel_threshold(pos))
    return     ia_space.calculate_gravity_multiplier_normal(pos)
end

function ia_space.calculate_jump_multiplier(grav_mult, pos)
    --assert(grav_mult ~= nil or pos ~= nil)
    --assert(grav_mult ~= nil or pos ~= nil and pos.y ~= nil)
    local grav_mult = grav_mult or ia_space.calculate_gravity_multiplier(pos)
    return (1.0 / math.sqrt(grav_mult)) -- TODO optional 1/g ?
end

function ia_space.handle_gravity(player)
    assert(player ~= nil)
    assert(player:is_player())
    local pos       = player:get_pos()
    assert(pos    ~= nil)
    local grav_mult = ia_space.calculate_gravity_multiplier(pos)
    player_monoids.gravity:add_change(player, grav_mult, ia_space.effects.gravity)
    return grav_mult
end

function ia_space.handle_jump(player, grav_mult)
    assert(player    ~= nil)
    assert(player:is_player())
    --assert(grav_mult ~= nil or  pos ~= nil)
    --assert(grav_mult ~= nil or  pos ~= nil and pos.y ~= nil)
    local pos       = player:get_pos()
    assert(pos ~= nil)
    local jump_mult = ia_space.calculate_jump_multiplier(grav_mult, pos)
    player_monoids.jump:add_change(player, jump_mult, ia_space.effects.jump)
    return jump_mult
end

function ia_space.handle_gravity_and_jump(player)
    assert(player    ~= nil)
    assert(player:is_player())
    --local pos = player:get_pos()
    --assert(pos       ~= nil)
    local grav_mult = ia_space.handle_gravity(player)
    assert(grav_mult ~= nil)
    local jump_mult = ia_space.handle_jump   (player, grav_mult, nil)

    --minetest.log("action", string.format("[ia_space] Crust Depth Y: %d, Grav: %.3f, Jump: %.3f", pos.y, grav_mult, jump_mult))
    --minetest.log("action", string.format("[ia_space] Grav: %.3f, Jump: %.3f", grav_mult, jump_mult))
end
