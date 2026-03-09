-- ia_space/mantle.lua

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
end

-- TODO: Hook into regional_weather:deep_cave to ensure it stops before Mantle weather begins?

