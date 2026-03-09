-- ia_space/overrides.lua

local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local subdir  = modpath..DIR_DELIM..'overrides'..DIR_DELIM
dofile(subdir..'thermal.lua')
dofile(subdir..'weather.lua')
