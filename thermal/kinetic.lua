-- ia_space/reentry.lua

function ia_space.get_mesosphere_density_factor(pos)
    assert(pos ~= nil)
    assert(ia_space.is_strictly_between_lower_mesosphere_and_dynamic_space_thresholds(pos))
    local space_start    = ia_space.get_space_threshold()
    local meso_start     = ia_space.get_mesosphere_lower_threshold()
    assert(pos.y       > meso_start)
    assert(space_start > meso_start)
    local dist_to_meso   = (pos.y       - meso_start)
    local meso_height    = (space_start - meso_start)
    return (1.0 - (dist_to_meso / meso_height)) -- TODO lerp ?
end

function ia_space.get_atmosphere_density_factor(pos)
    assert(pos ~= nil)
    if     ia_space.is_strictly_between_lower_mesosphere_and_dynamic_space_thresholds(pos) then
        return ia_space.get_mesosphere_density_factor(pos)
    end
    if     ia_space.is_below_lower_mesophere_threshold                               (pos) then
	return 1.0 -- TODO sealevel & mantle ?
    end
    assert(ia_space.is_above_dynamic_space_threshold                                 (pos))
    return     0.0
end

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

function ia_space.calculate_kinetic_celsius_delta(pos, velocity)
    assert(pos      ~= nil)
    assert(velocity ~= nil)
    assert(not ia_space.is_body_or_head_in_vacuum       (pos))
    assert(    ia_space.is_strictly_above_mach_threshold(velocity))
    local speed          = ia_space.get_speed(velocity)
    assert(speed    > ia_space.physics.mach_threshold)
    local dist_to_mach   = (speed - ia_space.physics.mach_threshold)
    local density_factor = ia_space.get_atmosphere_density_factor(pos)
    return (dist_to_mach * density_factor * ia_space.physics.friction_delta)
end

function ia_space.calculate_kinetic_celsius_delta_for_player(player)
    assert(player   ~= nil)
    local pos      = player:get_pos()
    assert(pos      ~= nil)
    local velocity = player:get_velocity()
    assert(velocity ~= nil)
    if ia_space.is_body_and_head_in_vacuum(pos)      then return 0 end
    if ia_space.is_below_mach_threshold   (velocity) then return 0 end
    return ia_space.calculate_kinetic_celsius_delta(pos, velocity)
end

-- TODO in abm loop, need to determine whether kinetic celsus delta is high & spawn reentry effect


