-- ia_space/init.lua
-- Handles space physics and vacuum logic, integrated with tidesandfloods.

assert(minetest.get_modpath('ia_util'))
assert(ia_util ~= nil)
local modname                    = minetest.get_current_modname() or "ia_space"
local storage                    = minetest.get_mod_storage()
ia_space                         = {}
local modpath, S                 = ia_util.loadmod(modname)
local log                        = ia_util.get_logger(modname)
local assert                     = ia_util.get_assert(modname)

-- Dependencies
assert(player_monoids, "ia_space requires player_monoids")
assert(ia_names, "ia_space requires ia_names")

-- Configuration
local BASE_SPACE_THRESHOLD = 10000
local MANTLE_THRESHOLD = -20000
local VACUUM_NODE = "ia_space:vacuum"
local AIR_NODE = "air"
-- Note: tidesandfloods might change node names, using the variable for logic
local STINK_AIR = "tides:stink_air" 

local ATMOSPHERE_COLOR = {
    day_sky = "#8cbaff", day_horizon = "#b4bafa",
    dawn_sky = "#b4bafa", dawn_horizon = "#b4bafa",
    night_sky = "#006aff", night_horizon = "#4090ff",
    indoors = "#646464",
}

-- 1. NODES
minetest.register_node(VACUUM_NODE, {
    description = "Vacuum of Space",
    drawtype = "airlike",
    paramtype = "light",
    sunlight_propagates = true,
    walkable = false,
    pointable = false,
    diggable = false,
    buildable_to = true,
    groups = {vacuum = 1, not_in_creative_inventory = 1},
})

-- Helper: Get Tidal Offset from tidesandfloods
local function get_tide_offset()
    -- Instead of manual math, we check the delta from mapgen water level
    if tidesandfloods and tidesandfloods.sealevel then
        local base_level = tonumber(minetest.get_mapgen_setting("water_level")) or 1
        return tidesandfloods.sealevel - base_level
    end
    return 0
end

-- 2. DYNAMIC SPACE PHYSICS
local function handle_space_zone(player, pos)
    -- Space height fluctuates with the global sea level/tide
    local tide_mod = get_tide_offset()
    local dynamic_threshold = BASE_SPACE_THRESHOLD + tide_mod
    local in_space_zone = pos.y > dynamic_threshold

    if in_space_zone then
        player_monoids.gravity:add_change(player, 0.1, "ia_space:gravity")
        player_monoids.jump:add_change(player, 1.5, "ia_space:jump")
        player:set_sky({ type = "plain", base_color = "#000000", clouds = false })
    else
        player_monoids.gravity:del_change(player, "ia_space:gravity")
        player_monoids.jump:del_change(player, "ia_space:jump")
        player:set_sky({ type = "regular", clouds = true, sky_color = ATMOSPHERE_COLOR })
    end
end

-- 3. VACUUM LOGIC
local function handle_vacuum_zone(player, pos)
    -- Check head level for suffocation
    local head_pos = vector.add(pos, {x=0, y=1.5, z=0})
    local node_at_head = minetest.get_node(head_pos).name

    -- Vacuum causes oxygen depletion. Stink air (tidal air) is handled by ia_thermal.
    local in_vacuum = (node_at_head == VACUUM_NODE)

    if in_vacuum then
        local breath = player:get_breath()
        if breath > 0 then
            player:set_breath(math.max(0, breath - 2))
        else
            player:set_hp(player:get_hp() - 2)
            -- Visual feedback for hypoxia
            player:set_sky({base_color = "#220000", type = "plain"})
        end
    end
end

-- 4. GLOBALSTEP ENGINE
local timer = 0
minetest.register_globalstep(function(dtime)
    timer = timer + dtime
    if timer < 0.5 then return end
    timer = 0

    for _, player in ipairs(ia_names.get_all_actors()) do
        local pos = player:get_pos()
        if pos then
            handle_space_zone(player, pos)
            handle_vacuum_zone(player, pos)
        end
    end
end)

-- 5. MAPGEN INJECTION (Tide-Safe)
minetest.register_on_generated(function(minp, maxp, seed)
    local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
    local area = VoxelArea:new({MinEdge = emin, MaxEdge = emax})
    local data = vm:get_data()

    -- SPACE: Replace air with vacuum above the base threshold
    if maxp.y >= BASE_SPACE_THRESHOLD then
        local c_air = minetest.get_content_id(AIR_NODE)
        local c_vac = minetest.get_content_id(VACUUM_NODE)
        local itermin = math.max(minp.y, BASE_SPACE_THRESHOLD)
        
        for i in area:iter(minp.x, itermin, minp.z, maxp.x, maxp.y, maxp.z) do
            if data[i] == c_air then data[i] = c_vac end
        end
    end

    -- MANTLE: Replace everything with lava at deep levels
    if minp.y <= MANTLE_THRESHOLD then
        local c_lava = minetest.get_content_id("default:lava_source")
        local itermax = math.min(maxp.y, MANTLE_THRESHOLD)
        
        for i in area:iter(minp.x, minp.y, minp.z, maxp.x, itermax, maxp.z) do
            if data[i] ~= minetest.CONTENT_IGNORE then
                data[i] = c_lava
            end
        end
    end

    vm:set_data(data)
    vm:write_to_map()
end)
