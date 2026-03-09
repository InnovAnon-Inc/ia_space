-- ia_space/thermal.lua

local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local subdir  = modpath..DIR_DELIM..'thermal'..DIR_DELIM
dofile(subdir..'base.lua')
dofile(subdir..'kinetic.lua')
dofile(subdir..'radiant_damage.lua')



--
--
--


--
--
--

function ia_space.get_ambient_engine_heat(pos)
    assert(pos ~= nil)
    if minetest.get_modpath("climate_api") then
--	return climate_api.environment.get_influence(pos, 'heat')
--	return climate_api.environment.get_influence(pos, 'base_heat')
        return climate_api.environment.get_heat(pos)
    end
    assert(not minetest.get_modpath('climate_api'))
    return minetest.get_heat(pos)
end

function ia_space.get_ambient_celsius(pos)
    assert(pos ~= nil)
    local heat = ia_space.get_ambient_engine_heat(pos)
    return ia_space.nil_engine_heat_to_celsius(heat)
end

--
--
--


-- TODO in abm loop, need to determine whether kinetic celsus delta is high & spawn reentry effect


function ia_space.calculate_effective_celsius_for_player(player)
    assert(player ~= nil)
    local pos = player:get_pos()
    local vel = player:get_velocity()
    assert(pos ~= nil)
    assert(vel ~= nil)

    local ambient    = ia_space.get_ambient_celsius             (pos)
    local kinetic    = ia_space.calculate_kinetic_celsius_delta (pos, vel)
    local vicinity   = ia_space.calculate_vicinity_celsius_delta(pos, player)
    local medium     = (ia_space.calculate_medium_celsius_delta (pos)    or 0)
    local personal   = (ia_space.temperature_monoid:value       (player) or 0)
    -- TODO wind chil ?
    local raw        = (ambient + kinetic + vicnity + medium + personal)
    local protection = ia_space.calculate_thermal_protection    (player)
    return ia_space.lerp(raw, ia_space.temperatures.default, protection)
end







---- Define the temperature monoid

-- climate_api/lib/influences.lua
--
--climate_api.register_influence("heat",
--	climate_api.environment.get_heat
--)
--
--climate_api.register_influence("base_heat",
--	minetest.get_heat
--)
--
--climate_api.register_influence("humidity",
--	climate_api.environment.get_humidity
--)
--
--climate_api.register_influence("biome_humidity",
--	minetest.get_humidity
--)
--
---- see https://en.wikipedia.org/wiki/Dew_point#Simple_approximation
--climate_api.register_influence("dewpoint", function(pos)
--	local heat = climate_api.environment.get_heat(pos)
--	local humidity = climate_api.environment.get_humidity(pos)
--	return heat - (9/25 * (100 - humidity))
--end)
--
--climate_api.register_influence("base_dewpoint", function(pos)
--	local heat = minetest.get_heat(pos)
--	local humidity = minetest.get_humidity(pos)
--	return heat - (9/25 * (100 - humidity))
--end)
--
--climate_api.register_influence("biome", function(pos)
--	local data = minetest.get_biome_data(pos)
--	local biome = minetest.get_biome_name(data.biome)
--	return biome
--end)
--
--climate_api.register_influence("windspeed", function(pos)
--	local wind = climate_api.environment.get_wind(pos)
--	return vector.length(wind)
--end)
--
--climate_api.register_global_influence("wind_yaw", function()
--	local wind = climate_api.environment.get_wind({x = 0, y = 0, z = 0})
--	if vector.length(wind) == 0 then return 0 end
--	return minetest.dir_to_yaw(wind)
--end)
--
--climate_api.register_influence("height", function(pos)
--	return pos.y
--end)
--
--climate_api.register_influence("light", function(pos)
--	pos = vector.add(pos, {x = 0, y = 1, z = 0})
--	return minetest.get_node_light(pos) or 0
--end)
--
--climate_api.register_influence("daylight", function(pos)
--	pos = vector.add(pos, {x = 0, y = 1, z = 0})
--	return minetest.get_natural_light(pos, 0.5) or 0
--end)
--
--climate_api.register_influence("indoors", function(pos)
--	pos = vector.add(pos, {x = 0, y = 1, z = 0})
--	local daylight = minetest.get_natural_light(pos, 0.5) or 0
--	-- max light is 15 but allow adjacent nodes to still be outdoors
--	-- to reduce effect switching on and off when walking underneath single nodes
--	if daylight < 14 then return true end
--
--	for i = 1, climate_mod.settings.ceiling_checks do
--		local lpos = vector.add(pos, {x = 0, y = i, z = 0})
--		local node = minetest.get_node_or_nil(lpos)
--		if node ~= nil and node.name ~= "air" and node.name ~= "ignore" then
--			return true
--		end
--	end
--	return false
--end)
--
--climate_api.register_global_influence("time",
--	minetest.get_timeofday
--)

-- climate_api/lib/environment.lua
--local environment = {}
--
--function environment.get_heat(pos)
--	if climate_mod.forced_enviroment.heat ~= nil then
--		return climate_mod.forced_enviroment.heat
--	end
--	local base = climate_mod.settings.heat
--	local biome = minetest.get_heat(pos)
--	local height = climate_api.utility.rangelim((-pos.y + 10) / 15, -10, 10)
--	local time = climate_api.utility.normalized_cycle(minetest.get_timeofday()) * 0.6 + 0.7
--	local random = climate_mod.state:get_float("heat_random");
--	return base + ((biome + height) * time * random)
--end
--
--function environment.get_humidity(pos)
--	if climate_mod.forced_enviroment.humidity ~= nil then
--		return climate_mod.forced_enviroment.humidity
--	end
--	local base = climate_mod.settings.humidity
--	local biome = minetest.get_humidity(pos)
--	local random = climate_mod.state:get_float("humidity_random");
--	return base + ((biome * 0.7 + 40 * 0.3) * random)
--end
--
--function environment.get_wind(pos)
--	if climate_mod.forced_enviroment.wind ~= nil then
--		return climate_mod.forced_enviroment.wind
--	end
--	local wind_x = climate_mod.state:get_float("wind_x")
--	local wind_z = climate_mod.state:get_float("wind_z")
--	local base_wind = vector.new({ x = wind_x, y = 0, z = wind_z })
--	local height_modifier = climate_api.utility.sigmoid(pos.y, 2, 0.02, 1)
--	return vector.multiply(base_wind, height_modifier)
--end
--
--function environment.get_weather_presets(player)
--	local pname = player:get_player_name()
--	local weathers = climate_mod.current_weather[pname]
--	if type(weathers) == "nil" then weathers = {} end
--	return weathers
--end
--
--function environment.get_effects(player)
--	local pname = player:get_player_name()
--	local effects = {}
--	for effect, players in pairs(climate_mod.current_effects) do
--		if type(players[pname]) ~= "nil" then
--			table.insert(effects, effect)
--		end
--	end
--	return effects
--end
--
--return environment

-- radiant_damage/README.md
--```
--{
--	interval = 1, -- number of seconds between each damage check. Defaults to 1 when undefined.
--	range = 3, -- range of the damage. Can be omitted if inverse_square_falloff is true,
--		-- in that case it defaults to the range at which 0.125 points of damage is done
--		-- by the most damaging emitter node type.
--	emitted_by = {}, -- nodes that emit this damage. At least one emission node type
--		-- and damage value pair is required.
--	attenuated_by = {} -- This allows certain intervening node types to modify the damage
--		-- that radiates through it. This parameter is optional.
--		-- Note: Only works in Minetest version 0.5 and above.
--	default_attenuation = 1, -- the amount the damage is multiplied by when passing 
--		-- through any other non-air nodes. Defaults to 0 when undefined. Note that
--		-- in versions before Minetest 0.5 any value other than 1 will result in total
--		-- occlusion (ie, any non-air node will block all damage)
--	inverse_square_falloff = true, -- if true, damage falls off with the inverse square
--		-- of the distance. If false, damage is constant within the range. Defaults to
--		-- true when undefined.
--	above_only = false, -- if true, damage only propagates directly upward. Useful for
--		-- when you want to damage players only when they stand on the node.
--		-- Defaults to false when undefined.
--	on_damage = function(player_object, damage_value, pos), -- An optional callback to allow mods
--		-- to do custom behaviour. If this is set to non-nil then the default damage will
--		-- *not* be done to the player, it's up to the callback to handle that. If it's left
--		-- undefined then damage_value is dealt to the player.
--}
--```
