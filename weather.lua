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

if minetest.get_modpath('regional_weather') then
    regional_weather.settings.max_height = ia_space.get_maximum_weather_height()
    regional_weather.settings.min_height = ia_space.get_minimum_weather_height()
end

function ia_space.generate_climate_api_effects_space(params) -- VOID WEATHER (Space)
    assert(minetest.get_modpath('climate_api'))
    local pos   = {x = 0, y = params.height, z = 0}
    if ia_space.is_below_dynamic_space_threshold(pos) then return {} end
    local black = ia_space.colors.space_black
    return {
        ["climate_api:skybox"] = {
	    cloud_data = {
		density = 0,
		height  = ia_space.world_limits.max,
            },
	    light_data = {
                shadow_intensity = 0.1,
		saturation       = 1.1,
  	    },
            priority   = 100,
	    sky_data   = {
		base_color = ia_space.colors.space_black,
		clouds     = false,
		sky_color  = {
                    day_sky       = black,
                    day_horizon   = black,
                    dawn_sky      = black,
                    dawn_horizon  = black,
                    night_sky     = black,
                    night_horizon = black,
                    fog_sun_tint  = black,
                    fog_moon_tint = black,
                },
                type       = "plain",
	    },
        }
    }
end

function ia_space.generate_climate_api_effects_mantle(params) -- MANTLE WEATHER (The Core)
    assert(minetest.get_modpath('climate_api'))
    local pos  = {x = 0, y = params.height, z = 0}
    if ia_space.is_strictly_above_mantle_threshold(pos) then return {} end
    local glow = ia_space.colors.mantle_glow
    return {
        ["climate_api:skybox"] = {
	    cloud_data = {
		density = 0,
		height  = ia_space.world_limits.min,
            },
            light_data = {
                shadow_intensity = 0.8,
                saturation       = 1.5 -- Intense, oversaturated heat
            },
            priority   = 100,
            sky_data   = {
		base_color = ia_space.colors.mantle_glow,
		clouds     = false,
		sky_color  = {
                    day_sky       = glow,
                    day_horizon   = glow,
                    dawn_sky      = glow,
                    dawn_horizon  = glow,
                    night_sky     = glow,
                    night_horizon = glow,
                },
                type       = "plain",
            },
        }
    }
end

if minetest.get_modpath("climate_api") then
    climate_api.register_weather(ia_space.weathers.mantle, {}, ia_space.generate_climate_api_effects_mantle)
    climate_api.register_weather(ia_space.weathers.space,  {}, ia_space.generate_climate_api_effects_space)
end

-- TODO: Hook into regional_weather:deep_cave to ensure it stops before Mantle weather begins?
