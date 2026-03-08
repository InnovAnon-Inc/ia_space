-- ia_space/physics.lua

function ia_space.set_sky(player, sky) -- TODO better monoid
    assert(player ~= nil)
    if minetest.get_modpath("climate_api") then return end
    player:set_sky(sky)
end

local function handle_in_space(player, pos)
    assert(player ~= nil)
    assert(ia_space.is_strictly_above_dynamic_space_threshold(pos))
--    player_monoids.gravity:add_change(player, 0.1, ia_space.effects.gravity)
--    player_monoids.jump   :add_change(player, 1.5, ia_space.effects.jump)
    ia_space.handle_gravity_and_jump(player, pos)
    ia_space              .set_sky   (player, {
	base_color = ia_space.colors.space_black,
	clouds     = false,
	type       = "plain",
    })
end

local function handle_not_in_space(player, pos)
    assert(player ~= nil)
    assert(ia_space.is_below_dynamic_space_threshold(pos))
    player_monoids.gravity:del_change(player,      ia_space.effects.gravity)
    player_monoids.jump   :del_change(player,      ia_space.effects.jump)
    ia_space              .set_sky   (player, {
	clouds     = true, 
	sky_color  = ia_space.atmosphere_colors,
	type       = "regular",
    })
end

function ia_space.handle_space_zone(player, pos) -- exposed in case ... idk man... terrestrial labs and stuff
    assert(player ~= nil)
    if ia_space.is_strictly_above_dynamic_space_threshold(pos) then
        handle_in_space(player, pos)
	return
    end
    handle_not_in_space(player, pos)
end

function ia_space.handle_vacuum_zone(player, pos)
    assert(player ~= nil)
    if not ia_space.is_head_in_vacuum(pos) then return end

    local breath = player :get_breath()
    if breath > 0 then
        player            :set_breath(math.max(0, breath - 2)) -- Rapid breath loss in vacuum
    else
        player            :set_hp(player:get_hp() - 2) -- Damage and visual feedback for suffocation
        ia_space          .set_sky(player, { -- Red flash/tint for suffocation
            base_color = ia_space.colors.suffocate_red,
            type       = "plain",
        })
    end
end

local timer      = 0
local sleep_time = 0.5

local function is_globalstep_sleeping(dtime)
    return (timer < sleep_time)
end

local function handle_globalstep_sleep(dtime)
    timer        = (timer + dtime)
    if is_globalstep_sleeping(dtime) then return false end
    timer        = 0
    return true
end

minetest.register_globalstep(function(dtime)
    if not handle_globalstep_sleep(dtime) then return end

    --for _, player in ipairs(ia_names.get_all_actors()) do
    for _, player in ipairs(minetest.get_connected_players()) do
        local pos = player:get_pos()
        if pos then
            ia_space.handle_space_zone (player, pos)
            ia_space.handle_vacuum_zone(player, pos)
        end
    end
end)
