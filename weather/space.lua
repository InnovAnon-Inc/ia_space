-- ia_space/space.lua
-- FIXME in space, there's a half-horizon around the sun. it either needs to be mirrored below the horizon or completely gone
-- FIXME two moons ? -- NOTE maybe fixed

-- TODO need an earth 

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

if minetest.get_modpath("climate_api") then
    climate_api.register_weather(ia_space.weathers.space,  {}, ia_space.generate_climate_api_effects_space)
end

