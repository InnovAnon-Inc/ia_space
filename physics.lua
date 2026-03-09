-- ia_space/physics.lua

local function handle_in_space(player)
    assert(player ~= nil)
    local pos = player:get_pos()
    assert(pos    ~= nil)
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

local function handle_not_in_space(player)
    -- TODO refactor: mesosphere-aware
    -- TODO refactor: mantle-aware
    assert(player ~= nil)
    local pos = player:get_pos()
    assert(pos    ~= nil)
    assert(ia_space.is_below_dynamic_space_threshold(pos))
    player_monoids.gravity:del_change(player,      ia_space.effects.gravity)
    player_monoids.jump   :del_change(player,      ia_space.effects.jump)
    ia_space              .set_sky   (player, {
	clouds     = true, 
	sky_color  = ia_space.atmosphere_colors,
	type       = "regular",
    })
end

function ia_space.handle_space_zone(player) -- exposed in case ... idk man... terrestrial labs and stuff
    assert(player ~= nil)
    local pos = player:get_pos()
    assert(pos    ~= nil)
    if ia_space.is_strictly_above_dynamic_space_threshold(pos) then
        handle_in_space(player)
	return
    end
    assert(ia_space.is_below_dynamic_space_threshold(pos))
    handle_not_in_space(player)
end

function ia_space.handle_vacuum_zone(player)
    assert(player ~= nil)
    local pos = player:get_pos()
    assert(pos    ~= nil)
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
            ia_space.handle_space_zone     (player)
            ia_space.handle_vacuum_zone    (player)
	    --ia_space.handle_reentry_physics(player)
        end
    end
end)

--function ia_space.spawn_reentry_effect(player)
--    assert(player ~= nil)
--    local pos = player:get_pos()
--    -- Visual feedback: Orange "plasma" tint
--    ia_space.set_sky(player, {
--	base_color = "#ff4500", -- OrangeRed plasma glow -- TODO
--	type       = "plain",
--    })
--
--    -- Add particles to simulate the fireball
--    minetest.add_particlespawner({
--	amount     = 10,
--	time       =  0.5,
--	minpos     = {x=pos.x-1, y=pos.y-1, z=pos.z-1},
--	maxpos     = {x=pos.x+1, y=pos.y+1, z=pos.z+1},
--	minvel     = {x=-2,      y=2,       z=-2},
--	maxvel     = {x= 2,      y=5,       z= 2},
--	minexptime =  1,
--	maxexptime =  2,
--	minsize    =  5,
--	maxsize    = 10,
--	texture    = "heart.png^[colorize:#ff4500:200", -- Placeholder for fire -- TODO
--	glow       = 14,
--    })
--end


--function ia_space.handle_reentry_physics(player)
--    assert(player   ~= nil)
--    local pos      = player:get_pos()
--    assert(pos      ~= nil)
--    local velocity = player:get_velocity()
--    assert(velocity ~= nil)
--    -- 1. Detect if we are in a medium that provides drag/friction
--    -- We use the head position to check for vacuum vs atmosphere
--    if ia_space.is_body_and_head_in_vacuum(pos)      then return end
--    if ia_space.is_below_mach_threshold   (velocity) then return end
--    -- TODO thermal-aware
--    -- FIXME is damage is handled elsewhere ??? maybe we should not handle temperature damage here
--    local damage = ia_space.calculate_reentry_damage(pos, velocity) -- TODO ia_thermal-aware
--    if (damage == 0)                                 then return end
--    assert(damage > 0)
--    player:set_hp(player:get_hp() - damage)
--
--    ia_space.spawn_reentry_effect(player)
--end
