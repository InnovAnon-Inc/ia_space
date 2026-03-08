-- ia_space/init.lua
-- TODO absorb ia_thermal functionality
-- TODO revisit mapgen: mantle, ocean, etc
-- TODO mesosphere
-- TODO re-entry
-- TODO handle world limits
--
-- TODO nodes.lua
-- TODO tides.lua
-- TODO weather.lua / space.lua (skybox sun problem)
--
-- TODO technic / radiation
-- TODO 3d armor

assert(minetest.get_modpath('ia_util'))
assert(ia_util ~= nil)
local modname                    = minetest.get_current_modname() or "ia_space"
local storage                    = minetest.get_mod_storage()
ia_space                         = {}
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
    lava_source = 'default:lava_source',
    vacuum      = modname..':vacuum'
}
ia_space.thresholds              = {
    mantle     = -20000,
    sealevel   = tonumber(minetest.get_mapgen_setting('water_level')) or 1,
    amplitude  =      2.5, -- Max height in nodes (sealevel)
    space      =  10000,
    -- Artistic/Realism tuning:
    -- 0.1 means the top 10% of the atmosphere is the fade zone.
    meso_ratio =      0.15,
}
ia_space.physics                 = {
    gravity          = tonumber(minetest.settings:get('movement_gravity')) or 9.81, -- not used
    heat_damage_mult =  0.5,
    mach_threshold   = 20, -- Speed at which heating begins (nodes per second)
}
ia_space.weathers                = {
    mantle     = modname..':mantle',
    -- TODO ocean ?
    mesosphere = modname..':mesosphere',
    space      = modname..':space',
}

function ia_space.get_world_limits()
    -- Default to standard engine limits if settings aren't found
    local limit  = minetest.get_mapgen_setting('mapgen_limit')
    assert(limit ~= nil)
    limit        = tonumber(limit)
    assert(limit ~= nil)
    --limit       = limit or 31000
    local buffer = 500
    return {
	buffer =          buffer,
        max    =  limit - buffer,
        min    = -limit + buffer,
    }
end
ia_space.world_limits            = ia_space.get_world_limits()

-- FIXME see mapgen (i.e., refactor functions that need them and use partial functions)
--local modpath, S                 = ia_util.loadmod(modname) -- NOTE finds & loads lua files; load order is not guaranteed by the API (undefined, but not necessarily non-deterministic)
local modpath = minetest.get_modpath(modname)
dofile(modpath..DIR_DELIM..'nodes.lua')
dofile(modpath..DIR_DELIM..'mapgen.lua')
dofile(modpath..DIR_DELIM..'gravity.lua')
dofile(modpath..DIR_DELIM..'mantle.lua')
dofile(modpath..DIR_DELIM..'mesosphere.lua')
dofile(modpath..DIR_DELIM..'physics.lua')
dofile(modpath..DIR_DELIM..'predicates.lua')
dofile(modpath..DIR_DELIM..'reentry.lua')
dofile(modpath..DIR_DELIM..'space.lua')
dofile(modpath..DIR_DELIM..'tides.lua')
dofile(modpath..DIR_DELIM..'weather.lua')
local log                        = ia_util.get_logger(modname)
local assert                     = ia_util.get_assert(modname)

