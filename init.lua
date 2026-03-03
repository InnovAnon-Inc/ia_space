-- ia_space/init.lua

-- Dependencies
assert(player_monoids, "ia_space requires player_monoids")
assert(ia_names, "ia_space requires ia_names")

-- Configuration
local SPACE_THRESHOLD = 10000
local MANTLE_THRESHOLD = -20000
local VACUUM_NODE = "ia_space:vacuum"
local AIR_NODE = "air"

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

-- 2. ABM: VACUUM ENCROACHMENT
minetest.register_abm({
    label = "Vacuum Encroachment",
    nodenames = {VACUUM_NODE},
    neighbors = {AIR_NODE},
    interval = 1.0, 
    chance = 1,
    action = function(pos)
        local neighbors = {
            {x=pos.x+1, y=pos.y, z=pos.z}, {x=pos.x-1, y=pos.y, z=pos.z},
            {x=pos.x, y=pos.y+1, z=pos.z}, {x=pos.x, y=pos.y-1, z=pos.z},
            {x=pos.x, y=pos.y, z=pos.z+1}, {x=pos.x, y=pos.y, z=pos.z-1},
        }
        for _, npos in ipairs(neighbors) do
            if npos.y >= SPACE_THRESHOLD then
                if minetest.get_node(npos).name == AIR_NODE then
                    minetest.set_node(npos, {name = VACUUM_NODE})
                end
            end
        end
    end,
})

-- 3. HELPER FUNCTIONS
local function update_space_physics(player, is_in_space)
    if is_in_space then
        player_monoids.gravity:add_change(player, 0.1, "ia_space:gravity")
        player_monoids.jump:add_change(player, 1.5, "ia_space:jump")
    else
        player_monoids.gravity:del_change(player, "ia_space:gravity")
        player_monoids.jump:del_change(player, "ia_space:jump")
    end
end

-- Airtanks Integration Helpers
local function has_breathing_tube(player)
    if not minetest.get_modpath("airtanks") then return false end
    local inv = player:get_inventory()
    local hotbar_size = player:hud_get_hotbar_itemcount()
    for i = 1, hotbar_size do
        if inv:get_stack("main", i):get_name() == "airtanks:breathing_tube" then
            return true
        end
    end
    return false
end

local function has_charged_tank(player)
    if not minetest.get_modpath("airtanks") then return false end
    local inv = player:get_inventory()
    local hotbar_size = player:hud_get_hotbar_itemcount()
    for i = 1, hotbar_size do
        local stack = inv:get_stack("main", i)
        if minetest.get_item_group(stack:get_name(), "airtank") > 1 then
            return true
        end
    end
    return false
end

-- 4. ENVIRONMENT HANDLERS
local function handle_space_zone(player, pos)
    local in_space_zone = pos.y > SPACE_THRESHOLD
    if in_space_zone then
        update_space_physics(player, true)
        player:set_sky({ type = "plain", base_color = "#000000", clouds = false })
    else
        update_space_physics(player, false)
        player:set_sky({ type = "regular", clouds = true, sky_color = ATMOSPHERE_COLOR })
    end
end

local function handle_vacuum_zone(player, pos)
    local head_pos = vector.add(pos, {x=0, y=1.5, z=0})
    local node_at_head = minetest.get_node(head_pos).name
    local in_vacuum = (node_at_head == VACUUM_NODE)

    if in_vacuum then
        local breath = player:get_breath()

        -- Check for Airtanks support or default to death
--        if has_breathing_tube(player) and has_charged_tank(player) then
--            -- Slowly drain breath to trigger airtanks mod replenishment
--            if breath > 6 then
--                player:set_breath(breath - 1)
--            end
--        else
            -- No gear: Rapid suffocation
            if breath > 0 then
                player:set_breath(math.max(0, breath - 2))
            else
                player:set_hp(player:get_hp() - 2)
                player:set_sky({base_color = "#220000", type = "plain"})
            end
--        end
    end
end

-- 5. GLOBALSTEP ENGINE
local timer = 0
minetest.register_globalstep(function(dtime)
    timer = timer + dtime
    if timer < 0.5 then return end -- TODO maybe slow timer ; check engine timer for suffocation
    timer = 0

    for _, player in ipairs(ia_names.get_all_actors()) do
        local pos = player:get_pos()
        if pos then
            handle_space_zone(player, pos)
            handle_vacuum_zone(player, pos)
        end
    end
end)

-- 6. MAPGEN INJECTION (Space + Mantle)
minetest.register_on_generated(function(minp, maxp, seed)
    local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
    local area = VoxelArea:new({MinEdge = emin, MaxEdge = emax})
    local data = vm:get_data()
    
    -- SPACE: Replace air with vacuum
    if maxp.y >= SPACE_THRESHOLD then
        local c_air = minetest.get_content_id(AIR_NODE)
        local c_vac = minetest.get_content_id(VACUUM_NODE)
        for i in area:iter(minp.x, math.max(minp.y, SPACE_THRESHOLD), minp.z, maxp.x, maxp.y, maxp.z) do
            if data[i] == c_air then data[i] = c_vac end
        end
    end

    -- MANTLE: Replace stone/air with lava
    if minp.y <= MANTLE_THRESHOLD then
        local c_lava = minetest.get_content_id("default:lava_source")
        for i in area:iter(minp.x, minp.y, minp.z, maxp.x, math.min(maxp.y, MANTLE_THRESHOLD), maxp.z) do
            if data[i] ~= minetest.CONTENT_IGNORE then
                data[i] = c_lava
            end
        end
    end

    vm:set_data(data)
    vm:write_to_map()
end)
