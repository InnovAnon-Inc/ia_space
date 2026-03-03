-- Axis Configuration
local SPACE_THRESHOLD = 10000
local VACUUM_NODE = "ia_space:vacuum"
local AIR_NODE = "air"

-- 1. THE NODES
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

-- 2. ATMOSPHERIC PHYSICS (ABM)
-- Handles the "Leak" logic: Vacuum eats Air above the threshold
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

-- Add this to your configuration section
local ATMOSPHERE_COLOR = {
    day_sky = "#8cbaff", day_horizon = "#b4bafa",
    dawn_sky = "#b4bafa", dawn_horizon = "#bacad9",
    night_sky = "#006aff", night_horizon = "#4090ff", -- Default MT night
    indoors = "#646464",
}

local function handle_player_environment(player, pos)
    local head_pos = {x=pos.x, y=pos.y + 1.5, z=pos.z}
    local node_at_head = minetest.get_node(head_pos).name

    -- SPACE STATE (Above Threshold)
    if pos.y > SPACE_THRESHOLD + 50 then -- Buffer added
        player:set_sky({
            type = "plain",
            base_color = "#000000",
            clouds = false,
            sky_color = {
                day_sky = "#000000", day_horizon = "#000000",
                dawn_sky = "#000000", dawn_horizon = "#000000",
                night_sky = "#000000", night_horizon = "#000000",
                indoors = "#000000",
            },
        })
        player:set_physics_override({ gravity = 0.1, jump = 1.5 })

        -- Suffocation Check
        if node_at_head == VACUUM_NODE then
            local breath = player:get_breath()
            if breath > 0 then
                player:set_breath(breath - 1)
            else
                player:set_hp(player:get_hp() - 2)
            end
            -- Hypoxia Visual (Darker tint)
            player:set_sky({base_color = "#110000", type = "plain"})
        end

    -- TERRESTRIAL STATE (Below Threshold)
    elseif pos.y < SPACE_THRESHOLD - 50 then
        -- We must explicitly RESTORE the colors and type
        player:set_sky({
            type = "regular",
            clouds = true,
            sky_color = ATMOSPHERE_COLOR, -- Restore blue sky
        })
        -- Reset Sun/Moon/Stars to default visibility logic
        player:set_sun({visible = true, texture = "sun.png"})
        player:set_moon({visible = true, texture = "moon.png"})
        player:set_stars({visible = true})

        player:set_physics_override({ gravity = 1.0, jump = 1.0 })
    end
end

---- 3. PLAYER STATE ENGINE (Unified Globalstep)
---- Handles Sky, Gravity, and Suffocation in one pass
--local function handle_player_environment(player, pos)
--    local name = player:get_player_name()
--    local head_pos = {x=pos.x, y=pos.y + 1.5, z=pos.z}
--    local node_at_head = minetest.get_node(head_pos).name
--
--    -- SPACE STATE (Above Threshold)
--    if pos.y > SPACE_THRESHOLD then
--        -- Sky Logic
--        player:set_sky({
--            type = "plain",
--            base_color = "#000000",
--            clouds = false,
--            sky_color = {
--                day_sky = "#000000", day_horizon = "#000000",
--                dawn_sky = "#000000", dawn_horizon = "#000000",
--                night_sky = "#000000", night_horizon = "#000000",
--                indoors = "#000000",
--            },
--        })
--        -- Physics (Low Gravity)
--        player:set_physics_override({ gravity = 0.1, jump = 1.5 })
--        
--        -- Suffocation Logic
--        if node_at_head == VACUUM_NODE then
--            local breath = player:get_breath()
--            if breath > 0 then
--                player:set_breath(breath - 1)
--            else
--                player:set_hp(player:get_hp() - 2)
--            end
--            -- Red tint for hypoxia
--            player:set_sky({base_color = "#110000", type = "plain"})
--        end
--    else
--        -- TERRESTRIAL STATE (Below Threshold)
--        player:set_sky({ type = "regular", clouds = true })
--        player:set_physics_override({ gravity = 1.0, jump = 1.0 })
--    end
--end

minetest.register_globalstep(function(dtime)
    for _, player in ipairs(minetest.get_connected_players()) do
        -- Throttled check for performance
        if math.floor(minetest.get_gametime() * 2) % 2 == 0 then
            handle_player_environment(player, player:get_pos())
        end
    end
end)

-- 4. MAPGEN INJECTION
-- Fills the void with Vacuum during chunk generation
minetest.register_on_generated(function(minp, maxp, seed)
    if maxp.y < SPACE_THRESHOLD then return end

    local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
    local area = VoxelArea:new({MinEdge = emin, MaxEdge = emax})
    local data = vm:get_data()
    local c_air = minetest.get_content_id(AIR_NODE)
    local c_vac = minetest.get_content_id(VACUUM_NODE)

    local changed = false
    for i in area:iter(minp.x, math.max(minp.y, SPACE_THRESHOLD), minp.z, maxp.x, maxp.y, maxp.z) do
        if data[i] == c_air then
            data[i] = c_vac
            changed = true
        end
    end

    if changed then
        vm:set_data(data)
        vm:set_lighting({day = 0, night = 0})
        vm:write_to_map()
    end
end)

-- TODO we do need a mechanism for this
---- 5. UTILITY: THE AIR SCRUBBER
---- Use this inside the skyscraper to reclaim rooms from the vacuum
--minetest.register_node("void:air_scrubber", {
--    description = "Atmospheric Stabilizer",
--    tiles = {"default_steel_block.png^[colorize:#00ffff:30"},
--    groups = {cracky = 1},
--    on_construct = function(pos)
--        minetest.get_node_timer(pos):start(2.0)
--    end,
--    on_timer = function(pos, elapsed)
--        local p1 = vector.subtract(pos, 15)
--        local p2 = vector.add(pos, 15)
--        local vm = minetest.get_voxel_manip()
--        vm:read_from_map(p1, p2)
--        local area = VoxelArea:new(vm:get_emerged_data())
--        local data = vm:get_data()
--        local c_vac = minetest.get_content_id(VACUUM_NODE)
--        local c_air = minetest.get_content_id(AIR_NODE)
--        
--        local changed = false
--        for i in area:iterp(p1, p2) do
--            if data[i] == c_vac then data[i] = c_air; changed = true end
--        end
--        if changed then vm:set_data(data); vm:write_to_map() end
--        return true
--    end,
--})
