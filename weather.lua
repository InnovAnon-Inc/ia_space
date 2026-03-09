-- ia_space/weather.lua

local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local subdir  = modpath..DIR_DELIM..'weather'..DIR_DELIM
dofile(subdir..'mantle.lua')
dofile(subdir..'mesosphere.lua')
dofile(subdir..'space.lua')

