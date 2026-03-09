-- ia_space/base.lua

function ia_space.engine_heat_to_celsius(heat)
    assert(heat ~= nil)
    return (heat * 0.5) - 10
end

function ia_space.celsius_to_engine_heat(celsius)
    assert(celsius ~= nil)
    return (celsius + 10) * 2
end

function ia_space.nil_engine_heat_to_celsius(heat)
    if heat == nil then return ia_space.temperatures.default end
    assert(heat ~= nil)
    return ia_space.engine_heat_to_celsius(heat)
end

function ia_space.get_default_engine_heat()
    return ia_space.celsius_to_engine_heat(ia_space.temperature.default)
end

function ia_space.nil_engine_heat(heat)
    if heat == nil then ia_space.get_default_engine_heat() end
    assert(heat ~= nil)
    return heat
end

function ia_space.get_base_engine_heat(pos)
    assert(pos ~= nil)
    return ia_space.original_get_heat(pos)
end

function ia_space.get_base_celsius(pos)
    assert(pos ~= nil)
    local heat = ia_space.get_base_engine_heat(pos)
    return ia_space.nil_engine_heat_to_celsius(heat)
end

function ia_space.original_get_celsius(pos)
    assert(pos ~= nil)
    local heat = ia_space.original_get_engine_heat(pos)
    return ia_space.nil_engine_heat_to_celsius(heat)
end

function ia_space.nil_original_get_engine_heat(pos)
    assert(pos ~= nil)
    local heat = ia_space.original_get_engine_heat(pos)
    return ia_space.nil_engine_heat(heat)
end


--function ia_space.get_daylight_vanilla(pos) -- TODO get light at that position ?

function ia_space.climate_api_influence_light(pos)
    assert(pos ~= nil)
    pos = vector.add(pos, {x = 0, y = 1, z = 0})
    return (minetest.get_node_light(pos) or 0)
end

function ia_space.climate_api_influence_daylight(pos, time)
    assert(pos  ~= nil)
    assert(time == nil or time == tonumber(time))
    pos  = vector.add(pos, {x = 0, y = 1, z = 0})
    time = (time or 0.5) -- noon
    return (minetest.get_natural_light(pos, time) or 0)
end

function ia_space.climate_api_influence_daylight_now(pos)
    assert(pos  ~= nil)
    local time = minetest.get_timeofday()
    return ia_space.climate_api_influence_daylight(pos, time)
end






function ia_space.calculate_local_atmosphere_density(pos, radius)
    assert(pos ~= nil)
    radius         = (radius or 4) -- A 9x9x9 cube check is usually enough
    local air      = 0
    local vacuum   = 0
    local total    = 0
    local result   = ia_space.iter_radius_nodes(pos, radius, function(node, _pos, offset)
        if ia_space.is_node_ignore(node) then return nil end
	total      = (total  + 1)
	if ia_space.is_node_air   (node) then
            air    = (air    + 1)
	    return nil
	end
	if ia_space.is_node_vacuum(node) then
            vacuum = (vacuum + 1)
	    return nil
	end
	return nil
    end)
    assert(result == nil)
    if (total == 0) then return nil end
    assert(total ~= 0)
    local space    = (air + vacuum)
    if (space == 0) then return nil end
    assert(space ~= nil)
    local filled   = (total - space)
    -- TODO what about the filled nodes ?
    return (air / space)
end

function ia_space.calculate_space_celsius_with_atmosphere(pos, delta, height, radius)
    assert(pos    ~= nil)
    assert(delta  == nil or delta  == tonumber(delta))
    assert(radius == nil or radius == tonumber(radius))
    assert(height == nil or height == tonumber(height))
    if ia_space.is_indoors(pos, delta, height, radius) then return ia_space.temperatures.default end
    local vacuum  = ia_space.calculate_space_celsius_without_atmosphere(pos, delta)
    local density = ia_space.calculate_local_atmosphere_density(pos, radius)
    density       = (density or 0)
    return ia_space.lerp(vacuum, ia_space.temperatures.default, density)
end

function ia_space.calculate_space_celsius_without_atmosphere_with_exposure(pos, delta)
    assert(not ia_space.is_daylight_obscured_by_ceiling(pos, delta))
    local light  = ia_space.climate_api_influence_daylight_now(pos)
    assert(0      <= light)
    assert(light  <= 15)
    --local weight = math.max(0, math.min(1, light_level / 15))
    local weight = light / 15
    assert(0      <= weight)
    assert(weight <= 1)
    return ia_space.lerp(ia_space.temperatures.space_shadow, ia_space.temperatures.space_sunlight, weight)
end

function ia_space.calculate_space_celsius_without_atmosphere(pos, delta)
    assert(pos ~= nil)
    assert(delta == nil or delta == tonumber(delta))
    if ia_space.is_daylight_obscured_by_ceiling(pos, delta) then
        return ia_space.temperatures.space_shadow
    end
    return ia_space.calculate_space_celsius_without_atmosphere_with_exposure(pos, delta)
end

function ia_space.calculate_space_celsius(pos)
    assert(pos ~= nil)
    assert(ia_space.is_above_dynamic_space_threshold(pos))
--    if minetest.get_modpath('climate_api') then
--        return ia_space.calculate_space_celsius_climate_api(pos)
--    end
--    assert(not minetest.get_modpath('climate_api'))
--    return ia_space.calculate_space_celsius_vanilla(pos)
    if not ia_space.is_body_or_head_in_vacuum(pos) then
        return ia_space.calculate_space_celsius_with_atmosphere(pos)
    end
    assert(ia_space.is_body_or_head_in_vacuum(pos))
    return ia_space.calculate_space_celsius_without_atmosphere(pos)
end

function ia_space.calculate_lapse_rate_cooling(pos) -- Apply Lapse Rate (Cooling with altitude)
    assert(pos   ~= nil)
    assert(pos.y ~= nil)
    assert(ia_space.is_strictly_above_sealevel_threshold(pos))
    local sealevel = ia_space.thresholds.sealevel
    assert(pos.y > sealevel, 'y='..tostring(pos.y)..', sealevel='..tostring(sealevel))
    local altitude  = (pos.y - sealevel)
    assert(altitude > 0)
    return (altitude / 1000 * ia_space.temperatures.lapse_rate)
end

function ia_space.calculate_celsius_lapse_rate_cooling(pos)
    assert(pos   ~= nil)
    local base_temp = ia_space.get_base_celsius(pos)
    assert(base_temp ~= nil)
    local lapse     = ia_space.calculate_lapse_rate_cooling(pos)
    assert(lapse ~= nil)
    assert(lapse > 0)
    return (base_temp - lapse)
end

function ia_space.calculate_lapse_rate_warming(pos)
    assert(pos   ~= nil)
    assert(pos.y ~= nil)
    assert(ia_space.is_below_mantle_threshold(pos))
    assert(pos.y <= ia_space.thresholds.mantle)
    local depth     = ia_space.thresholds.mantle - pos.y
    assert(depth > 0)
    return (depth / 1000 * ia_space.temperatures.geo_gradient)
end

function ia_space.calculate_celsius_lapse_rate_warming(pos)
    assert(pos   ~= nil)
    local base_temp = ia_space.get_base_celsius(pos)
    assert(base_temp ~= nil)
    local lapse     = ia_space.calculate_lapse_rate_warming(pos)
    assert(lapse ~= nil)
    assert(lapse > 0)
    return (base_temp + lapse)
end

function ia_space.calculate_cosmologically_aware_celsius(pos)
    assert(pos ~= nil)
    if ia_space.is_above_dynamic_space_threshold(pos) then
	return ia_space.calculate_space_celsius(pos)
    end
    assert(ia_space.is_strictly_below_dynamic_space_threshold(pos))

    --if ia_space.is_above_lower_mesophere_threshold(pos) then ... end
    --assert(ia_space.is_strictly_below_lower_mesosphere_threshold(pos))

    if ia_space.is_strictly_above_sealevel_threshold(pos) then
        return ia_space.calculate_celsius_lapse_rate_cooling(pos)
    end
    assert(ia_space.is_below_sealevel_threshold(pos))

    if ia_space.is_above_mantle_threshold(pos) then
        return ia_space.get_base_celsius(pos)
    end
    assert(ia_space.is_strictly_below_mantle_threshold(pos))

    return ia_space.calculate_celsius_lapse_rate_warming(pos)
end

function ia_space.calculate_cosmologically_aware_engine_heat(pos)
    assert(pos ~= nil)
    local celsius = ia_space.calculate_cosmologically_aware_celsius(pos)
    assert(celsius ~= nil)
    return ia_space.celsius_to_engine_heat(celsius)
end

