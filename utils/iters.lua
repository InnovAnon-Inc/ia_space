-- ia_space/iters.lua

function ia_space.iter_direction_offsets(pos, direction, height, cb)
    assert(pos        ~= nil)
    assert(direction  ~= nil)
    assert(height     ~= nil)
    assert(cb         ~= nil)
    for d = 1, height do
        local offset      = table.copy(ia_space.world_limits.origin)
	offset[direction] = d
        local val         = cb(offset)
        if (val ~= nil) then return val end
    end
    return nil
end

function ia_space.iter_direction_positions(pos, direction, height, cb)
    assert(pos        ~= nil)
    assert(direction  ~= nil)
    assert(height     ~= nil)
    assert(cb         ~= nil)
    _cb = function(offset)
	assert(offset ~= nil)
        local _pos = vector.add(pos, offset)
	return cb(_pos, offset)
    end
    return ia_space.iter_direction_offsets(pos, direction, height, _cb)
end

function ia_space.iter_direction_nodes(pos, direction, height, cb)
    assert(pos        ~= nil)
    assert(direction  ~= nil)
    assert(height     ~= nil)
    assert(cb         ~= nil)
    _cb = function(_pos, offset)
	assert(_pos   ~= nil)
	assert(offset ~= nil)
        local node = minetest.get_node_or_nil(_pos)
	return cb(node, _pos, offset)
    end
    return ia_space.iter_direction_positions(pos, direction, height, _cb)
end

function ia_space.iter_radius_offsets(pos, radius, cb)
    assert(pos        ~= nil)
    assert(radius     ~= nil)
    assert(cb         ~= nil)
    for dx = -radius, radius do
        for dy = -radius, radius do
	    for dz = -radius, radius do
		local offset = {x=dx, y=dy, z=dz}
		local val    = cb(offset)
		if (val ~= nil) then return val end
            end
        end
    end
    return nil
end

function ia_space.iter_radius_positions(pos, radius, cb)
    assert(pos        ~= nil)
    assert(radius     ~= nil)
    assert(cb         ~= nil)
    _cb = function(offset)
	assert(offset ~= nil)
        local _pos = vector.add(pos, offset)
	return cb(_pos, offset)
    end
    return ia_space.iter_radius_offsets(pos, radius, _cb)
end

function ia_space.iter_radius_nodes(pos, radius, cb)
    assert(pos        ~= nil)
    assert(radius     ~= nil)
    assert(cb         ~= nil)
    _cb = function(_pos, offset)
	assert(_pos   ~= nil)
	assert(offset ~= nil)
        local node = minetest.get_node_or_nil(_pos)
	return cb(node, _pos, offset)
    end
    return ia_space.iter_radius_positions(pos, radius, _cb)
end


