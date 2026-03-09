-- ia_space/find.lua

function ia_space.find_ceiling_node(pos, height)
    assert(pos    ~= nil)
    assert(height == nil or height == tonumber(height))
    if ia_space.is_in_vacuum(pos)                 then return nil end
    height = (height or 15) -- TODO move to settings

    local lpos  = nil
    local found = ia_space.iter_direction_nodes(pos, 'y', height, function(node, _pos, offset)
	if ia_space.is_node_vacuum(node) then return nil  end
	if ia_space.is_node_air   (node) then
            lpos = _pos
            return true
	end
    end)
    if (found == false) then
        assert(lpos == nil)
	return nil
    end
    assert(found == true)
    assert(lpos  ~= nil)
    return lpos
--    for i = 1, height do
--        local lpos = vector.add(pos, {x = 0, y = i, z = 0})
--        local node = minetest.get_node_or_nil(lpos)
--	if ia_space.is_node_air   (node) then return lpos end
--	if ia_space.is_node_vacuum(node) then return nil  end
--    end
--    return nil
end

function ia_space.find_ceiling(pos, height, radius)
    assert(pos    ~= nil)
    assert(radius == nil or radius == tonumber(radius))
    assert(height == nil or height == tonumber(height))
    local ceiling = ia_space.find_ceiling_node(pos, height)
    if    (ceiling == nil)                                  then return nil     end
    assert(ceiling ~= nil)
    if ia_space.is_ceiling_valid(ceiling, radius)           then return ceiling end
    return nil
end
