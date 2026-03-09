-- ia_space/utils.lua

local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local subdir  = modpath..DIR_DELIM..'utils'..DIR_DELIM
dofile(subdir..'find.lua')
dofile(subdir..'iters.lua')
dofile(subdir..'lerp.lua')
dofile(subdir..'predicates.lua')
dofile(subdir..'times.lua')

function ia_space.get_speed(velocity) -- TODO move to ia_util
    assert(velocity   ~= nil)
    assert(velocity.x ~= nil)
    assert(velocity.y ~= nil)
    assert(velocity.z ~= nil)
    return math.sqrt(velocity.x^2 + velocity.y^2 + velocity.z^2)
end

function ia_space.get_head(foot)
    assert(foot   ~= nil, 'no pos')
    assert(foot.x ~= nil, 'missing x-value')
    assert(foot.y ~= nil, 'missing y-value')
    assert(foot.z ~= nil, 'missing z-value')
    return vector.add(foot, {x=0, y=1.5, z=0})
end

function ia_space.get_head_round(foot)
    assert(foot   ~= nil, 'no pos')
    local head = ia_space.get_head(foot)
    assert(head ~= nil)
    return vector.round(head)
end
