-- ia_space/physics.lua
local BASE_SPACE_THRESHOLD = 10000
local VACUUM_NODE = "ia_space:vacuum"
local ATMOSPHERE_COLOR = {
    day_sky = "#8cbaff", day_horizon = "#b4bafa",
    dawn_sky = "#b4bafa", dawn_horizon = "#b4bafa",
    night_sky = "#006aff", night_horizon = "#4090ff",
    indoors = "#646464",
}

-- Helper: Get Tidal Offset from tidesandfloods
local function get_tide_offset()
    if tidesandfloods and tidesandfloods.sealevel then
        local base_level = tonumber(minetest.get_mapgen_setting("water_level")) or 1
        return tidesandfloods.sealevel - base_level
    end
    return 0
end

local function handle_space_zone(player, pos)
    local tide_mod = get_tide_offset()
    local dynamic_threshold = BASE_SPACE_THRESHOLD + tide_mod
    
    if pos.y > dynamic_threshold then
        player_monoids.gravity:add_change(player, 0.1, "ia_space:gravity")
        player_monoids.jump:add_change(player, 1.5, "ia_space:jump")
        player:set_sky({ type = "plain", base_color = "#000000", clouds = false })
    else
        player_monoids.gravity:del_change(player, "ia_space:gravity")
        player_monoids.jump:del_change(player, "ia_space:jump")
        player:set_sky({ type = "regular", clouds = true, sky_color = ATMOSPHERE_COLOR })
    end
end

local function handle_vacuum_zone(player, pos)
    local head_pos = vector.add(pos, {x=0, y=1.5, z=0})
    local node_at_head = minetest.get_node(head_pos).name

    if node_at_head == VACUUM_NODE then
        local breath = player:get_breath()
        if breath > 0 then
            player:set_breath(math.max(0, breath - 2))
        else
            player:set_hp(player:get_hp() - 2)
            player:set_sky({base_color = "#220000", type = "plain"})
        end
    end
end

local timer = 0
minetest.register_globalstep(function(dtime)
    timer = timer + dtime
    if timer < 0.5 then return end
    timer = 0

    --for _, player in ipairs(ia_names.get_all_actors()) do
    for _, player in ipairs(minetest.get_connected_players()) do
        local pos = player:get_pos()
        if pos then
            handle_space_zone(player, pos)
            handle_vacuum_zone(player, pos)
        end
    end
end)
