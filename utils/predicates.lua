-- ia_space/predicates.lua

--
-- static space threshold
--

function ia_space.is_strictly_below_space_threshold(pos)
    assert(pos   ~= nil, 'no pos')
    assert(pos.y ~= nil, 'missing y-value')
    return (pos.y <  ia_space.thresholds.space)
end

function ia_space.is_below_space_threshold(pos)
    assert(pos   ~= nil, 'no pos')
    assert(pos.y ~= nil, 'missing y-value')
    return (pos.y <= ia_space.thresholds.space)
end

function ia_space.is_at_space_threshold(pos)
    assert(pos   ~= nil, 'no pos')
    assert(pos.y ~= nil, 'missing y-value')
    return (pos.y == ia_space.thresholds.space)
end

function ia_space.is_above_space_threshold(pos)
    assert(pos   ~= nil, 'no pos')
    assert(pos.y ~= nil, 'missing y-value')
    return (pos.y >= ia_space.thresholds.space)
end

function ia_space.is_strictly_above_space_threshold(pos)
    assert(pos   ~= nil, 'no pos')
    assert(pos.y ~= nil, 'missing y-value')
    return (pos.y >  ia_space.thresholds.space)
end

--
-- static sealevel thresholdd
--

function ia_space.is_strictly_below_sealevel_threshold(pos)
    assert(pos   ~= nil, 'no pos')
    assert(pos.y ~= nil, 'missing y-value')
    local sealevel = ia_space.thresholds.sealevel
    return (pos.y <  sealevel)
end

function ia_space.is_below_sealevel_threshold(pos)
    assert(pos   ~= nil, 'no pos')
    assert(pos.y ~= nil, 'missing y-value')
    local sealevel = ia_space.thresholds.sealevel
    return (pos.y <= sealevel)
end

function ia_space.is_at_sealevel_threshold(pos)
    assert(pos   ~= nil, 'no pos')
    assert(pos.y ~= nil, 'missing y-value')
    local sealevel = ia_space.thresholds.sealevel
    return (pos.y == sealevel)
end

function ia_space.is_above_sealevel_threshold(pos)
    assert(pos   ~= nil, 'no pos')
    assert(pos.y ~= nil, 'missing y-value')
    local sealevel = ia_space.thresholds.sealevel
    return (pos.y >= sealevel)
end

function ia_space.is_strictly_above_sealevel_threshold(pos)
    assert(pos   ~= nil, 'no pos')
    assert(pos.y ~= nil, 'missing y-value')
    local sealevel = ia_space.thresholds.sealevel
    return (pos.y >  sealevel)
end

function ia_space.is_strictly_between_mantle_and_sealevel_thresholds(pos)
    assert(pos   ~= nil, 'no pos')
    assert(pos.y ~= nil, 'missing y-value')
    assert(ia_space.thresholds.mantle < ia_space.thresholds.sealevel)
    if ia_space.is_below_mantle_threshold  (pos) then return false end
    if ia_space.is_above_sealevel_threshold(pos) then return false end
    assert(ia_space.is_strictly_above_mantle_threshold  (pos))
    assert(ia_space.is_strictly_below_sealevel_threshold(pos))
    return true
end

function ia_space.is_strictly_between_sealevel_and_space_thresholds(pos)
    assert(pos   ~= nil, 'no pos')
    assert(pos.y ~= nil, 'missing y-value')
    assert(ia_space.thresholds.sealevel < ia_space.thresholds.space)
    if ia_space.is_below_sealevel_threshold(pos) then return false end
    if ia_space.is_above_space_threshold   (pos) then return false end
    assert(ia_space.is_strictly_above_sealevel_threshold(pos))
    assert(ia_space.is_strictly_below_space_threshold   (pos))
    return true
end

--
-- mantle threshold
--

function ia_space.is_strictly_below_mantle_threshold(pos)
    assert(pos   ~= nil, 'no pos')
    assert(pos.y ~= nil, 'missing y-value')
    return (pos.y <  ia_space.thresholds.mantle)
end

function ia_space.is_below_mantle_threshold(pos)
    assert(pos   ~= nil, 'no pos')
    assert(pos.y ~= nil, 'missing y-value')
    return (pos.y <= ia_space.thresholds.mantle)
end

function ia_space.is_at_mantle_threshold(pos)
    assert(pos   ~= nil, 'no pos')
    assert(pos.y ~= nil, 'missing y-value')
    return (pos.y == ia_space.thresholds.mantle)
end

function ia_space.is_above_mantle_threshold(pos)
    assert(pos   ~= nil, 'no pos')
    assert(pos.y ~= nil, 'missing y-value')
    return (pos.y >= ia_space.thresholds.mantle)
end

function ia_space.is_strictly_above_mantle_threshold(pos)
    assert(pos   ~= nil, 'no pos')
    assert(pos.y ~= nil, 'missing y-value')
    return (pos.y >  ia_space.thresholds.mantle)
end

function ia_space.is_strictly_between_mantle_and_space_thresholds(pos)
    assert(pos   ~= nil, 'no pos')
    assert(pos.y ~= nil, 'missing y-value')
    assert(ia_space.thresholds.mantle < ia_space.thresholds.space)
    if ia_space.is_below_mantle_threshold(pos) then return false end
    if ia_space.is_above_space_threshold (pos) then return false end
    assert(ia_space.is_strictly_above_mantle_threshold(pos))
    assert(ia_space.is_strictly_below_space_threshold (pos))
    return true
end

function ia_space.is_strictly_between_mantle_and_space_thresholds2(minp, maxp)
    assert(minp   ~= nil, 'no min pos')
    assert(minp.y ~= nil, 'missing min y-value')
    assert(maxp   ~= nil, 'no max pos')
    assert(maxp.y ~= nil, 'missing max y-value')
    assert(ia_space.thresholds.mantle < ia_space.thresholds.space)
    if ia_space.is_below_mantle_threshold(minp) then return false end
    if ia_space.is_above_space_threshold (maxp) then return false end
    assert(ia_space.is_strictly_above_mantle_threshold(minp))
    assert(ia_space.is_strictly_below_space_threshold (maxp))
    return true
end

--
-- dynamic space threshold
--

function ia_space.is_strictly_below_dynamic_space_threshold(pos)
    assert(pos   ~= nil, 'no pos')
    assert(pos.y ~= nil, 'missing y-value')
    return (pos.y <  ia_space.get_space_threshold())
end

function ia_space.is_below_dynamic_space_threshold(pos)
    assert(pos   ~= nil, 'no pos')
    assert(pos.y ~= nil, 'missing y-value')
    return (pos.y <= ia_space.get_space_threshold())
end

function ia_space.is_at_dynamic_space_threshold(pos)
    assert(pos   ~= nil, 'no pos')
    assert(pos.y ~= nil, 'missing y-value')
    return (pos.y == ia_space.get_space_threshold())
end

function ia_space.is_above_dynamic_space_threshold(pos)
    assert(pos   ~= nil, 'no pos')
    assert(pos.y ~= nil, 'missing y-value')
    return (pos.y >= ia_space.get_space_threshold())
end

function ia_space.is_strictly_above_dynamic_space_threshold(pos)
    assert(pos   ~= nil, 'no pos')
    assert(pos.y ~= nil, 'missing y-value')
    return (pos.y >  ia_space.get_space_threshold())
end

function ia_space.is_strictly_between_mantle_and_dynamic_space_thresholds(pos)
    assert(pos   ~= nil, 'no pos')
    assert(pos.y ~= nil, 'missing y-value')
    assert(ia_space.thresholds.mantle < ia_space.get_space_threshold())
    if ia_space.is_below_mantle_threshold        (pos) then return false end
    if ia_space.is_above_dynamic_space_threshold (pos) then return false end
    assert(ia_space.is_strictly_above_mantle_threshold        (pos))
    assert(ia_space.is_strictly_below_dynamic_space_threshold (pos))
    return true
end

--
-- lower mesosphere threshold
--

function ia_space.is_strictly_below_lower_mesosphere_threshold(pos)
    assert(pos   ~= nil, 'no pos')
    assert(pos.y ~= nil, 'missing y-value')
    return (pos.y <  ia_space.get_mesosphere_lower_threshold())
end

function ia_space.is_below_lower_mesosphere_threshold(pos)
    assert(pos   ~= nil, 'no pos')
    assert(pos.y ~= nil, 'missing y-value')
    return (pos.y <= ia_space.get_mesosphere_lower_threshold())
end

function ia_space.is_at_lower_mesosphere_threshold(pos)
    assert(pos   ~= nil, 'no pos')
    assert(pos.y ~= nil, 'missing y-value')
    return (pos.y == ia_space.get_mesosphere_lower_threshold())
end

function ia_space.is_above_lower_mesosphere_threshold(pos)
    assert(pos   ~= nil, 'no pos')
    assert(pos.y ~= nil, 'missing y-value')
    return (pos.y >= ia_space.get_mesosphere_lower_threshold())
end

function ia_space.is_strictly_above_lower_mesosphere_threshold(pos)
    assert(pos   ~= nil, 'no pos')
    assert(pos.y ~= nil, 'missing y-value')
    return (pos.y >  ia_space.get_mesosphere_lower_threshold())
end

function ia_space.is_strictly_between_dynamic_sealevel_and_lower_mesosphere_thresholds(pos)
    assert(pos   ~= nil, 'no pos')
    assert(pos.y ~= nil, 'missing y-value')
    assert(ia_space.get_sealevel_threshold() < ia_space.get_lower_mesosphere_threshold())
    if ia_space.is_below_dynamic_sealevel_threshold(pos) then return false end
    if ia_space.is_above_lower_mesosphere_threshold(pos) then return false end
    assert(ia_space.is_strictly_above_dynamic_sealevel_threshold(pos))
    assert(ia_space.is_strictly_below_lower_mesosphere_threshold(pos))
    return true
end

function ia_space.is_strictly_between_lower_mesosphere_and_dynamic_space_thresholds(pos)
    assert(pos   ~= nil, 'no pos')
    assert(pos.y ~= nil, 'missing y-value')
    assert(ia_space.get_mesosphere_lower_threshold() < ia_space.get_space_threshold())
    if ia_space.is_below_lower_mesosphere_threshold(pos) then return false end
    if ia_space.is_above_dynamic_space_threshold  (pos) then return false end
    assert(ia_space.is_strictly_above_lower_mesosphere_threshold(pos))
    assert(ia_space.is_strictly_below_dynamic_space_threshold   (pos))
    return true
end

--
-- dynamic sealevel threshold
--

function ia_space.is_strictly_below_dynamic_sealevel_threshold(pos)
    assert(pos   ~= nil, 'no pos')
    assert(pos.y ~= nil, 'missing y-value')
    local sealevel = ia_space.get_sealevel_threshold()
    return (pos.y <  sealevel)
end

function ia_space.is_below_dynamic_sealevel_threshold(pos)
    assert(pos   ~= nil, 'no pos')
    assert(pos.y ~= nil, 'missing y-value')
    local sealevel = ia_space.get_sealevel_threshold()
    return (pos.y <= sealevel)
end

function ia_space.is_at_dynamic_sealevel_threshold(pos)
    assert(pos   ~= nil, 'no pos')
    assert(pos.y ~= nil, 'missing y-value')
    local sealevel = ia_space.get_sealevel_threshold()
    return (pos.y == sealevel)
end

function ia_space.is_above_dynamic_sealevel_threshold(pos)
    assert(pos   ~= nil, 'no pos')
    assert(pos.y ~= nil, 'missing y-value')
    local sealevel = ia_space.get_sealevel_threshold()
    return (pos.y >= sealevel)
end

function ia_space.is_strictly_above_dynamic_sealevel_threshold(pos)
    assert(pos   ~= nil, 'no pos')
    assert(pos.y ~= nil, 'missing y-value')
    local sealevel = ia_space.get_sealevel_threshold()
    return (pos.y >  sealevel)
end

function ia_space.is_strictly_between_mantle_and_dynamic_sealevel_thresholds(pos)
    assert(pos   ~= nil, 'no pos')
    assert(pos.y ~= nil, 'missing y-value')
    assert(ia_space.thresholds.mantle < ia_space.get_sealevel_threshold())
    if ia_space.is_below_mantle_threshold          (pos) then return false end
    if ia_space.is_above_dynamic_sealevel_threshold(pos) then return false end
    assert(ia_space.is_strictly_above_mantle_threshold          (pos))
    assert(ia_space.is_strictly_below_dynamic_sealevel_threshold(pos))
    return true
end

function ia_space.is_strictly_between_dynamic_sealevel_and_dynamic_space_thresholds(pos)
    assert(pos   ~= nil, 'no pos')
    assert(pos.y ~= nil, 'missing y-value')
    assert(ia_space.get_sealevel_threshold() < ia_space.get_space_threshold())
    if ia_space.is_below_dynamic_sealevel_threshold(pos) then return false end
    if ia_space.is_above_dynamic_space_threshold   (pos) then return false end
    assert(ia_space.is_strictly_above_dynamic_sealevel_threshold(pos))
    assert(ia_space.is_strictly_below_dynamic_space_threshold   (pos))
    return true
end

--
--
--

function ia_space.is_in_vacuum(pos)
    assert(pos   ~= nil, 'no pos')
    local node = minetest.get_node(pos).name
    return (node == ia_space.nodes.vacuum)
end

function ia_space.is_head_in_vacuum(pos)
    assert(pos   ~= nil, 'no pos')
    assert(pos.x ~= nil, 'missing x-value')
    assert(pos.y ~= nil, 'missing y-value')
    assert(pos.z ~= nil, 'missing z-value')
    local head = ia_space.get_head(pos) -- TODO round ?
    return ia_space.is_in_vacuum(head)
end

function ia_space.is_body_or_head_in_vacuum(pos)
    assert(pos   ~= nil, 'no pos')
    if ia_space.is_in_vacuum     (pos) then return true end
    if ia_space.is_head_in_vacuum(pos) then return true end
    return false
end

function ia_space.is_body_and_head_in_vacuum(pos)
    assert(pos   ~= nil, 'no pos')
    if not ia_space.is_in_vacuum     (pos) then return false end
    if not ia_space.is_head_in_vacuum(pos) then return false end
    return true
end

--
--
--

function ia_space.is_node_ignore(node)
    if (node == nil)                 then return true end
    return (node.name == ia_space.nodes.ignore)
end
function ia_space.is_node_air(node)
    if ia_space.is_node_ignore(node) then return nil end
    return (node.name == ia_space.nodes.air)
end
function ia_space.is_node_vacuum(node)
    if ia_space.is_node_ignore(node) then return nil end
    return (node.name == ia_space.nodes.vacuum)
end
function ia_space.is_node_air_or_vacuum(node)
    local is_air = ia_space.is_node_air(node)
    if (is_air ~= false)             then return is_air end
    return (node.name == ia_space.nodes.vacuum)
end

--
--
--

function ia_space.is_ceiling_valid(pos, radius)
    assert(pos    ~= nil)
    assert(radius == nil or radius == tonumber(radius))
    radius        = (radius or 15) -- TODO move to settings
    ia_space.iter_radius_nodes(pos, radius, function(node, v, dv)
        if ia_space.is_node_air_or_vacuum(node) then return false end
	return nil
    end)
end

function ia_space.is_indoors(pos, delta, height, radius)
    assert(pos    ~= nil)
    assert(delta  == nil or delta  == tonumber(delta))
    assert(height == nil or height == tonumber(height))
    if ia_space.is_in_vacuum(pos)                           then return false end
    if ia_space.is_daylight_obscured_by_ceiling(pos, delta) then return false end
    -- TODO use head pos ?
    local ceiling = ia_space.find_ceiling(pos, height, radius)
    return (ceiling ~= nil)
end

--
--
--

function ia_space.is_daylight_vanilla(pos)
--    assert(not minetest.get_modpath('climate_api'))
    assert(pos ~= nil)
    local time        = minetest.get_timeofday()
    assert(time ~= nil)
    -- Minetest TimeofDay: 0.5 is Noon, 0.0/1.0 is Midnight.
    -- The sun is generally "up" between 0.21 and 0.79.
    return (time > 0.21 and time < 0.79)
end

function ia_space.is_light_lt_daylight(pos, time, delta) -- TODO is it useful ?
    assert(pos   ~= nil)
    assert(time  == nil or time  == tonumber(time))
    assert(delta == nil or delta == tonumber(delta))
    local light    = ia_space.climate_api_influence_light(pos)
    local daylight = ia_space.climate_api_influence_daylight(pos, time)
    delta          = (delta or 0)
    daylight       = (daylight - delta)
    return (light < daylight)
end

function ia_space.is_daylight_lt(pos, value, time)
    assert(pos   ~= nil)
    assert(value == nil or value == tonumber(value))
    assert(time  == nil or time  == tonumber(time))
    local daylight = ia_space.climate_api_influence_daylight(pos, time)
    return (daylight < value)
end

function ia_space.is_daylight_obscured_by_ceiling(pos, delta)
    assert(pos   ~= nil)
    assert(delta == nil or delta == tonumber(delta))
    delta      = (delta or 1)
    return ia_space.is_daylight_lt(pos, 15 - delta, nil)
end

--
--
--

function ia_space.is_strictly_above_mach_threshold(velocity)
    assert(velocity   ~= nil)
    assert(velocity.x ~= nil, 'missing x-value')
    assert(velocity.y ~= nil, 'missing y-value')
    assert(velocity.z ~= nil, 'missing z-value')
    local speed = ia_space.get_speed(velocity)
    return (speed >  ia_space.physics.mach_threshold)
end

function ia_space.is_above_mach_threshold(velocity)
    assert(velocity   ~= nil)
    assert(velocity.x ~= nil, 'missing x-value')
    assert(velocity.y ~= nil, 'missing y-value')
    assert(velocity.z ~= nil, 'missing z-value')
    local speed = ia_space.get_speed(velocity)
    return (speed >= ia_space.physics.mach_threshold)
end

function ia_space.is_at_mach_threshold(velocity)
    assert(velocity   ~= nil)
    assert(velocity.x ~= nil, 'missing x-value')
    assert(velocity.y ~= nil, 'missing y-value')
    assert(velocity.z ~= nil, 'missing z-value')
    local speed = ia_space.get_speed(velocity)
    return (speed == ia_space.physics.mach_threshold)
end

function ia_space.is_below_mach_threshold(velocity)
    assert(velocity   ~= nil)
    assert(velocity.x ~= nil, 'missing x-value')
    assert(velocity.y ~= nil, 'missing y-value')
    assert(velocity.z ~= nil, 'missing z-value')
    local speed = ia_space.get_speed(velocity)
    return (speed <= ia_space.physics.mach_threshold)
end

function ia_space.is_strictly_below_mach_threshold(velocity)
    assert(velocity   ~= nil)
    assert(velocity.x ~= nil, 'missing x-value')
    assert(velocity.y ~= nil, 'missing y-value')
    assert(velocity.z ~= nil, 'missing z-value')
    local speed = ia_space.get_speed(velocity)
    return (speed <  ia_space.physics.mach_threshold)
end
