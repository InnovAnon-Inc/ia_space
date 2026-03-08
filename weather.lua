-- ia_space/weather.lua
-- FIXME in space, there's a half-horizon around the sun. it either needs to be mirrored below the horizon or completely gone
-- FIXME two moons ? -- NOTE maybe fixed

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
		ambient   = '#000000', -- TODO
		color     = '#00000000', -- TODO
		density   = 0,
		height    = ia_space.world_limits.max,
		thickness = 0,
            },
	    light_data = {
		saturation       = 1.1,
                shadow_intensity = 0.1,
  	    },
            moon_data  = {
		scale   = 1,
                texture = "moon.png",
--		tonemap = "moon_tonemap.png",
                visible = true,
		tonemap = "moon_tonemap.png^[colorize:#000000:255",
            },
            priority   = 100,
	    sky_data   = {
		base_color = ia_space.colors.space_black,
		clouds     = false,
		fog        = {
		    fog_color    = {r=0, g=0, b=0},
                    fog_distance = -1, -- Disable engine-default atmospheric fog
                    fog_start    = -1,
		},
		sky_color  = {
                    dawn_horizon  = black,
                    dawn_sky      = black,
                    day_horizon   = black,
                    day_sky       = black,
                    fog_moon_tint = black,
                    fog_sun_tint  = black,
		    fog_tint_type = "none",
		    indoors       = black,
                    night_horizon = black,
                    night_sky     = black,
                },
                type       = "plain",
	    },
            star_data  = {
                count   = 1500,
                color   = "#ffffff", -- TODO
                scale   = 1,
                visible = true,
            },
	    sun_data   = {
                visible         = true,
		scale           = 1,
--		sunrise         = "",
                sunrise_visible = false,
                texture         = "sun.png",
--		tonemap         = "sun_tonemap.png",
		tonemap         = "sun_tonemap.png^[colorize:#000000:255", -- TODO
                sunrise         = "sunrisebg.png^[colorize:#000000:255", -- TODO
            },
        },
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
		ambient   = '#330000', -- TODO
		color     = "#33000000", -- TODO
		density   = 0,
		height    = ia_space.world_limits.min,
		thickness = 0,
            },
            light_data = {
                saturation       = 1.5, -- Intense, oversaturated heat
                shadow_intensity = 0.8,
            },
            moon_data  = {
		scale   = 0,
		--texture =
		--tonemap =
		visible = false,
	    },
            priority   = 100,
            sky_data   = {
		base_color = ia_space.colors.mantle_glow,
		clouds     = false,
		fog        = {
                    fog_color = {r=51, g=0, b=0}, -- Matching mantle_glow
		    --fog_distance
		    --fog_start
                },
		sky_color  = {
                    dawn_horizon  = glow,
                    dawn_sky      = glow,
                    day_horizon   = glow,
                    day_sky       = glow,
		    --fog_moon_tint
		    --fog_sun_tint
                    fog_tint_type = 'none',
		    indoors       = glow,
                    night_horizon = glow,
                    night_sky     = glow,
                },
                type       = "plain",
            },
            star_data  = {
                count   = 0,
                color   = "#33000000", -- TODO
		scale   = 0,
		visible = false,
	    },
	    sun_data   = {
		sunrise_visible = false,
		visible         = false,
		sunrise         = "sunrisebg.png^[colorize:#330000:255", -- Mantle glow color -- TODO
		scale           = 0,
		--texture
		--tonemap
	    },
        }
    }
end

if minetest.get_modpath("climate_api") then
    climate_api.register_weather(ia_space.weathers.mantle, {}, ia_space.generate_climate_api_effects_mantle)
    climate_api.register_weather(ia_space.weathers.space,  {}, ia_space.generate_climate_api_effects_space)
end

-- TODO: Hook into regional_weather:deep_cave to ensure it stops before Mantle weather begins?
