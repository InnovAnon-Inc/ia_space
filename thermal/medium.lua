-- ia_space/thermal/medium.lua

-- Helper to get the thermal property of a specific node
function ia_space.get_thermal_conductivity_at(pos)
    local node        = minetest.get_node_or_nil(pos)
    if ia_space.is_node_ignore(node) then return 0 end
   
    local emission    = ia_space.nodes.emitters[node.name]
    if emission then return emission end

    local attenuation = ia_space.nodes.attenuators[node.name] 
    if attenuation then return nil end

    -- 2. Check for Water (Standardizing conduction for liquids)
    if minetest.get_item_group(node.name, "water") > 0 then
        -- Water is a thermal stabilizer. In a cold environment, it feels warm; 
        -- in a hot one, it feels cool. 
        return 15 -- Typical groundwater temp in Celsius -- TODO move to settings (water stabilization temp)
    end
    
    -- 3. Check for fire group if not explicitly registered
    if minetest.get_item_group(node.name, "igniter") > 0 then
        return 50 -- Lower than lava, but still significant -- TODO move to settings (igniter conduction temp)
    end

    return nil
end

function ia_space.get_humidity_conductivity_factor_at(pos)
    local node         = minetest.get_node_or_nil(pos)
    if ia_space.is_node_vacuum(pos)          then return 0   end -- TODO move to settings (vacuum conductivity)

    if ia_space.is_node_air   (pos) ~= false then
	local humidity = (climate_api.environment.get_humidity(pos) or 50)
        local dry_air  = 0.1 -- TODO move to settings (dry air conductivity)
	return dry_air * (1 + (humidity / 100))
    end

    local emission     = ia_space.nodes.emitters[node.name]
    if emission then return 1.0 end -- Solid/Liquid contact is 100% transfer

    local attenuation  = ia_space.nodes.attenuators[node.name]
    if attenuation then return attenuation end

    if minetest.get_item_group(node.name, "water") > 0 then
        return 0.8 -- High but not perfect transfer
    end
    
    if minetest.get_item_group(node.name, "igniter") > 0 then
        return 1.0
    end

    return 0.05 -- Default solid block (e.g. Stone) is a poor conductor
end

function ia_space.calculate_medium_celsius_delta(player)
    assert(player ~= nil)
    local pos          = player:get_pos()
    local foot         = vector  .round         (pos)
    local head         = ia_space.get_head_round(pos)

    local total        = 0
    local count        = 0
    local weight       = 0
    local function accumulate(_pos, offset)
        local celsius  = ia_space.get_thermal_conductivity_at(_pos)
        local _weight  = ia_space.get_humidity_conductivity_factor_at(_pos)
	total          = (total  + celsius * weight)
	count          = (count  + 1)
	weight         = (weight + _weight)
    end

--    local result       = accumulate(foot)
--    assert(result == nil)
--    assert(count  ==  1)
--    accumulate(head)
--    assert(result == nil)
--    assert(count  ==  2)
    local result       = nil

    local radius       = 1
    result             = ia_space.iter_radius_positions(foot, radius, accumulate)
    assert(result == nil)
    assert(count  == 10)
    result             = ia_space.iter_radius_positions(head, radius, accumulate)
    assert(result == nil)
    assert(count  == (9 + 9)) 
    if (weight ~= 0) then
        return (total / weight)
    end
    return nil
end

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
