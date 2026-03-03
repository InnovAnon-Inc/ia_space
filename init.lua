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





-- ia_space/init.lua

-- Configuration
local SPACE_THRESHOLD = 10000
local VACUUM_NODE = "ia_space:vacuum"
local AIR_NODE = "air"
local ATMOSPHERE_COLOR = {
    day_sky = "#8cbaff", day_horizon = "#b4bafa",
    dawn_sky = "#b4bafa", dawn_horizon = "#b4bafa",
    night_sky = "#006aff", night_horizon = "#4090ff",
    indoors = "#646464",
}

-- Use assertions to ensure dependencies are present
assert(player_monoids, "ia_space requires player_monoids")

local function update_space_physics(player, is_in_space)
    if is_in_space then
        -- Low gravity, high jump
        player_monoids.gravity:add_change(player, 0.1, "ia_space:gravity")
        player_monoids.jump:add_change(player, 1.5, "ia_space:jump")
    else
        -- Remove changes to let other mods (or default) take over
        player_monoids.gravity:del_change(player, "ia_space:gravity")
        player_monoids.jump:del_change(player, "ia_space:jump")
    end
end

--
-- NOTE
--

--ia_space.registered_suits = {}
--
--function ia_space.register_suit(name)
--    ia_space.registered_suits[name] = true
--end
--
---- FIXME use airtanks
--local function is_protected(player)
--    -- Check armor for protection
--    if minetest.get_modpath("3d_armor") and armor and armor.def then
--        local name = player:get_player_name()
--        if armor.def[name] and armor.def[name].groups.space_suit then
--            return true
--        end
--    end
--    return false
--end

--
--
--

--local function handle_space_effects(player, pos)
--    local name = player:get_player_name()
--    local head_pos = vector.add(pos, {x=0, y=1.5, z=0})
--    local node_at_head = minetest.get_node(head_pos).name
--    
--    local in_space_zone = pos.y > SPACE_THRESHOLD
--    local in_vacuum = (node_at_head == VACUUM_NODE)
--
--    -- 1. Physics & Sky
--    if in_space_zone then
--        update_space_physics(player, true)
--        
--        -- Set Space Sky
--        player:set_sky({
--            type = "plain",
--            base_color = "#000000",
--            clouds = false,
--        })
--    else
--        update_space_physics(player, false)
--        
--        -- Restore Sky (Only if we were the ones who changed it)
--        -- Note: A more advanced version would use a Sky Monoid if available
--        player:set_sky({
--            type = "regular",
--            clouds = true,
--            sky_color = ATMOSPHERE_COLOR,
--        })
--    end
--
--    -- 2. Survival Logic
--    if in_vacuum and not is_protected(player) then
--        local breath = player:get_breath()
--        if breath > 0 then
--            player:set_breath(math.max(0, breath - 2))
--        else
--            player:set_hp(player:get_hp() - 2)
--            -- Visual feedback for hypoxia
--            player:set_sky({base_color = "#220000", type = "plain"})
--        end
--    end
--end

local timer = 0
minetest.register_globalstep(function(dtime)
    timer = timer + dtime
    if timer < 0.5 then return end -- Space needs slightly faster updates than thermal
    timer = 0

    for _, player in ipairs(ia_names.get_all_actors()) do
        local pos = player:get_pos()
        if pos then
            handle_space_effects(player, pos)
        end
    end
end)

local MANTLE_THRESHOLD = -20000

minetest.register_on_generated(function(minp, maxp, seed)
    -- Handle Space (Existing)
    if maxp.y > SPACE_THRESHOLD then
        -- [Existing Vacuum Mapgen Logic]
    end

    -- Handle Mantle (New)
    if minp.y < MANTLE_THRESHOLD then
        local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
        local area = VoxelArea:new({MinEdge = emin, MaxEdge = emax})
        local data = vm:get_data()
        local c_lava = minetest.get_content_id("default:lava_source")
        local c_stone = minetest.get_content_id("default:stone")

        for i in area:iter(minp.x, minp.y, minp.z, maxp.x, math.min(maxp.y, MANTLE_THRESHOLD), maxp.z) do
            -- Replace air/stone with lava to simulate the core
            if data[i] ~= minetest.CONTENT_IGNORE then
                data[i] = c_lava
            end
        end
        vm:set_data(data)
        vm:write_to_map()
    end
end)

-- ia_space/init.lua

-- Helper to check if the player has a breathing tube in their hotbar
local function has_breathing_tube(player)
    local inv = player:get_inventory()
    local hotbar_size = player:hud_get_hotbar_itemcount()
    for i = 1, hotbar_size do
        if inv:get_stack("main", i):get_name() == "airtanks:breathing_tube" then
            return true
        end
    end
    return false
end

-- Helper to check for any charged air tank in the hotbar
local function has_charged_tank(player)
    local inv = player:get_inventory()
    local hotbar_size = player:hud_get_hotbar_itemcount()
    for i = 1, hotbar_size do
        local stack = inv:get_stack("main", i)
        -- airtanks uses group 'airtank' > 1 for full/partially full tanks
        if minetest.get_item_group(stack:get_name(), "airtank") > 1 then
            return true
        end
    end
    return false
end

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

        -- If player has gear, we just let them "breathe" normally
        -- (Airtanks mod will handle the replenishment automatically when breath < 5)
        if has_breathing_tube(player) and has_charged_tank(player) then
            -- We slowly drain breath to force the Breathing Tube to activate
            if breath > 6 then
                player:set_breath(breath - 1)
            end
        else
            -- No gear: Rapid suffocation
            if breath > 0 then
                player:set_breath(math.max(0, breath - 2))
            else
                player:set_hp(player:get_hp() - 2)
                -- Hypoxia Visual
                player:set_sky({base_color = "#220000", type = "plain"})
            end
        end
    end
end

local function handle_space_effects(player, pos)
	handle_space_zone(player, pos)
	handle_vacuum_zone(player, pos)
end
