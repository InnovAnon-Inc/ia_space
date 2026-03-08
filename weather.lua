-- ia_space/weather.lua

function ia_space.get_minimum_space_threshold()
    return (ia_space.thresholds.space - ia_space.thresholds.amplitude)
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

function ia_space.set_sky(player, sky) -- TODO better monoid
    assert(player ~= nil)
    if minetest.get_modpath("climate_api") then return end -- TODO delegate to climate_api ?
    player:set_sky(sky)
end

if minetest.get_modpath('regional_weather') then
    regional_weather.settings.max_height = ia_space.get_maximum_weather_height()
    regional_weather.settings.min_height = ia_space.get_minimum_weather_height()
end

-- TODO stub out our own if regional_weather/climate_api missing ?
