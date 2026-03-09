-- ia_space/mesosphere.lua

function ia_space.generate_climate_api_effects_mesosphere(params)
    assert(minetest.get_modpath('climate_api'))
    local pos         = {x = 0, y = params.height, z = 0}
    local height      = params.height
    local meso_start  = ia_space.get_mesosphere_lower_threshold()
    local space_start = ia_space.get_space_threshold()
    local black       = ia_space.colors.space_black
   
    if ia_space.is_strictly_below_lower_mesosphere_threshold(pos) then return {} end
    if ia_space.is_strictly_above_dynamic_space_threshold   (pos) then return {} end -- Handled by weather.lua space logic

    -- Calculate transition ratio (0.0 at meso_start, 1.0 at space_start)
    assert(height      >= meso_start)
    assert(space_start >  meso_start)
    local ratio       = (height - meso_start) / (space_start - meso_start)
    -- TODO ia_space.get_mesosphere_density_factory ??? (1.0 - (dist_to_meso / meso_height))

    -- Interpolate sky colors
    local day_sky     = ia_space.lerp_color(ia_space.colors.sky_blue,     black, ratio)
    local day_horiz   = ia_space.lerp_color(ia_space.colors.horizon_pale, black, ratio)
    local night_sky   = ia_space.lerp_color(ia_space.colors.night_deep,   black, ratio)

    return {
        ["climate_api:skybox"] = {
            cloud_data = {
		--ambient   = 
		--color     =
		--height    = 
		--thickness =
                --density = 0.2 * (1 - ratio), -- Clouds dissipate
		density = 0.2 * math.max(0, 1 - (ratio * 1.5)), -- Clouds shouldn't exist in the upper mesosphere
            },
	    --light_data = {
            --    saturation       = 
            --    shadow_intensity = 
  	    --},
            --moon_data  = {
            --    scale   = 
            --    texture = 
            --    visible = 
            --    tonemap = 
            --},
            priority   = 50, -- Lower than void space (100) but higher than default
            sky_data   = {
		--base_color = 
		--clouds     = 
		--fog        = {
		--    fog_color    = 
                --    fog_distance = 
                --    fog_start    = 
		--},
                sky_color = {
                    dawn_horizon  = day_horiz,
                    dawn_sky      = day_horiz,
                    day_horizon   = day_horiz,
                    day_sky       = day_sky,
                    --fog_moon_tint = 
                    --fog_sun_tint  = 
		    --fog_tint_type = 
                    indoors       = ia_space.colors.indoor_grey,
                    night_horizon = night_sky,
                    night_sky     = night_sky,
                },
                type      = "regular",
            },
            star_data  = {
                --count   = math.floor(2000 * ratio), -- Stars fade in as air thins
		count   = math.floor(2000 * (ratio ^ 2)), -- Exponential fade-in looks better
		--scale =
                visible = true,
            },
	    --sun_data   = {
            --    visible         = 
            --    scale           = 
            --    sunrise_visible = 
            --    texture         = 
            --    tonemap         = 
            --    sunrise         = 
            --},
        },
    }
end

-- Register the mesosphere as a dynamic climate override
if minetest.get_modpath("climate_api") then
    climate_api.register_weather(ia_space.weathers.mesosphere, {}, ia_space.generate_climate_api_effects_mesosphere)
end
