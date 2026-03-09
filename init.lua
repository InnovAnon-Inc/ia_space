-- ia_space/init.lua
-- TODO absorb ia_thermal functionality
-- TODO revisit mapgen: mantle, ocean, etc
-- TODO handle world limits: ocean
--
-- TODO nodes.lua
-- TODO tides.lua
-- TODO weather.lua / space.lua (skybox sun/earth problem)
--
-- TODO technic / radiation
-- TODO 3d armor
--
-- TODO re-entry: temperature & damage
-- TODO temperature & damage
--
-- TODO vacuum node abm
-- TODO tides
-- TODO temperature abm

assert(minetest.get_modpath('ia_util'))
assert(ia_util ~= nil)
local modname                    = minetest.get_current_modname() or "ia_space"
local storage                    = minetest.get_mod_storage()
ia_space                         = {}

function ia_space.get_mapgen_setting_number(key, default)
    local value = minetest.get_mapgen_setting(key)
    return (tonumber(value) or default)
end

function ia_space.get_minetest_setting_number(key, default)
    local value = minetest.settings:get(key)
    return (tonumber(value) or default)
end

function ia_space.get_world_limits()
    local limit  = ia_space.get_mapgen_setting_number('mapgen_limit', 31000)
    local buffer = ia_space.thresholds.buffer
    return {
	buffer =          buffer,
        max    =  limit - buffer,
        min    = -limit + buffer,
	origin = {x=0, y=0, z=0,},
    }
end

ia_space.colors                  = {
    sky_blue      = "#8cbaff",
    horizon_pale  = "#b4bafa",
    space_black   = "#000000",
    night_deep    = "#006aff",
    night_horizon = "#4090ff",
    indoor_grey   = "#646464",
    suffocate_red = "#220000",
    mantle_glow   = "#330000", -- Deep magma glow
}
ia_space.atmosphere_colors       = {
    day_sky   = ia_space.colors.sky_blue,     day_horizon   = ia_space.colors.horizon_pale,
    dawn_sky  = ia_space.colors.horizon_pale, dawn_horizon  = ia_space.colors.horizon_pale,
    night_sky = ia_space.colors.night_deep,   night_horizon = ia_space.colors.night_horizon,
    indoors   = ia_space.colors.indoors_grey,
}
ia_space.cycles                  = {
    m2_period         = 12.4206, -- Principal lunar semidiurnal constituent
    s2_period         = 12.0000, -- Principal solar semidiurnal constituent
    spring_neap_cycle = 354.36,  -- ~14.7 days (beats between M2 and S2)
    -- TODO solar cycles ?
    -- TODO more cycles
}
ia_space.effects                 = {
    gravity = modname..':gravity',
    jump    = modname..':jump',
}
ia_space.nodes                   = {
    air         = 'air',
    ignore      = 'ignore',
    lava_source = 'default:lava_source',
    vacuum      = modname..':vacuum'
}
ia_space.nodes.emitters          = {
    ["default:lava_source"]  =  80,
    ["default:lava_flowing"] =  40,
    ["default:fire"]         =  30, -- ?
    ["fire:basic_flame"]     =  30,
    ["default:ice"]          = -10,
    ["default:snow"]         =  -2,
    ["default:snowblock"]    =  -5,
    -- TODO more
}
ia_space.nodes.attenuators       = {
    ["group:stone"]          = 0.1,
    ["group:wood"]           = 0.4,
}

ia_space.original_get_heat       = minetest.get_heat

ia_space.physics                 = {
    gravity          = ia_space.get_minetest_setting_number('movement_gravity', 9.81), -- not used
    friction_delta   =  0.5,
    mach_threshold   = 20, -- Speed at which heating begins (nodes per second)
}

ia_space.temperatures            = {
    space_shadow   = -150, -- Celsius in shadow
    space_sunlight =  120, -- Celsius in direct sunlight (ISS levels)
    mantle_max     = 1000, -- Deep core temperature
    --sun_max        = -- TODO
    min_safe       =    0,
    max_safe       =   45,
    default        =   20,
    lapse_rate     =    6.5,
    geo_gradient   =   15,
--    room           =   20,
}

ia_space.thresholds              = {
    mantle     = -20000,
    sealevel   = ia_space.get_mapgen_setting_number('water_level', 1),
    amplitude  =      2.5, -- Max height in nodes (sealevel)
    space      =  10000,
    -- Artistic/Realism tuning:
    -- 0.1 means the top 10% of the atmosphere is the fade zone.
    meso_ratio =      0.15,
    buffer     =    500,
}

ia_space.weathers                = {
    mantle     = modname..':mantle',
    -- TODO ocean ?
    mesosphere = modname..':mesosphere',
    space      = modname..':space',
}

ia_space.world_limits            = ia_space.get_world_limits()

-- FIXME see mapgen (i.e., refactor functions that need them and use partial functions)
--local modpath, S                 = ia_util.loadmod(modname) -- NOTE finds & loads lua files; load order is not guaranteed by the API (undefined, but not necessarily non-deterministic)
local modpath = minetest.get_modpath(modname)
dofile(modpath..DIR_DELIM..'nodes.lua')
dofile(modpath..DIR_DELIM..'mapgen.lua')
dofile(modpath..DIR_DELIM..'gravity.lua')
--dofile(modpath..DIR_DELIM..'melting.lua')
dofile(modpath..DIR_DELIM..'monoids.lua')
dofile(modpath..DIR_DELIM..'physics.lua')
dofile(modpath..DIR_DELIM..'thermal.lua')
dofile(modpath..DIR_DELIM..'thresholds.lua')
dofile(modpath..DIR_DELIM..'tides.lua')
dofile(modpath..DIR_DELIM..'utils.lua')
dofile(modpath..DIR_DELIM..'weather.lua')
dofile(modpath..DIR_DELIM..'overrides.lua') -- FIXME
local log                        = ia_util.get_logger(modname)
local assert                     = ia_util.get_assert(modname)

