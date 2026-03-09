-- ia_space/thresholds.lua

function ia_space.get_minimum_space_threshold()
    return (ia_space.thresholds.space - ia_space.thresholds.amplitude)
end

function ia_space.get_space_threshold() -- dynamic space threshold
    local tide_mod = ia_space.get_sealevel_threshold()
    return (ia_space.thresholds.space + tide_mod)
end

function ia_space.get_maximum_weather_height()
    local min_threshold = ia_space.get_minimum_space_threshold()
    if not minetest.get_modpath("regional_weather") then
        return min_threshold
    end
    return math.min(regional_weather.settings.max_height, min_threshold)
end

function ia_space.get_minimum_weather_height()
    if not minetest.get_modpath("regional_weather") then
        return ia_space.thresholds.mantle
    end
    return math.max(regional_weather.settings.min_height, ia_space.thresholds.mantle)
end



function ia_space.get_dynamic_meso_depth() -- Returns the current "thickness" of the mesosphere in nodes
    local R           = ia_space.get_planetary_radius()
    local space_h     = ia_space.thresholds.space

    -- We base the base depth on the space threshold,
    -- but you could factor in R if you want a "larger" planet to have a deeper fade.
    local base_depth  = (space_h * ia_space.thresholds.meso_ratio)

    -- Incorporate tidal offset (Atmospheric Bulge)
    -- As the tide goes up, the atmosphere "stretches"
    local tide_offset = ia_space.get_sealevel_offset()

    return (base_depth + tide_offset)
end

function ia_space.get_mesosphere_lower_threshold() -- Returns the actual Y coordinate where the fade begins
    local space_threshold = ia_space.get_space_threshold() -- Already handles tides
    local depth           = ia_space.get_dynamic_meso_depth()
    return (space_threshold - depth)
end



function ia_space.get_sealevel_threshold() -- dynamic sealevel threshold
    return (ia_space.thresholds.sealevel + ia_space.get_sealevel_offset())
end


-- Helper to get distance from planetary "center"
-- Assuming sealevel is the surface and we want gravity to hit 0 at the world bottom
function ia_space.get_planetary_radius() -- static
    local surface = ia_space.thresholds.sealevel
    local center  = ia_space.world_limits.min
    assert(surface > center)
    return math.abs(surface - center)
end
