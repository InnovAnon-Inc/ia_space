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
--
--

function ia_space.is_in_vacuum(pos)
    local node = minetest.get_node(pos).name
    return (node == ia_space.nodes.vacuum)
end

function ia_space.is_head_in_vacuum(pos)
    local head = vector.add(pos, {x=0, y=1.5, z=0})
    return ia_space.is_in_vacuum(head)
end

