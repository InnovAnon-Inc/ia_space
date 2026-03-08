-- ia_space/mapgen.lua

-- FIXME need to bind these (i.e., refactor functions that need them and use partial functions)
-- Cache content IDs for performance
local c_air  = minetest.get_content_id(ia_space.nodes.air)
local c_lava = minetest.get_content_id(ia_space.nodes.lava_source)
local c_vac  = minetest.get_content_id(ia_space.nodes.vacuum)

local function generate_space(minp, maxp, area, data)
    if ia_space.is_strictly_below_space_threshold(maxp) then return false end
    assert(ia_space.is_above_space_threshold(maxp))

    local itermin = math.max(minp.y, ia_space.thresholds.space)
    local changed = false
        
    for i in area:iter(minp.x, itermin, minp.z, maxp.x, maxp.y, maxp.z) do
        if data[i] == c_air then -- data[i] ~= minetest.CONTENT_IGNORE ?
            data[i] = c_vac 
            changed = true
        end
    end
    return changed
end

local function generate_mantle(minp, maxp, area, data)
    if ia_space.is_strictly_above_mantle_threshold(minp) then return false end
    assert(ia_space.is_below_mantle_threshold(minp))

    local itermax = math.min(maxp.y, ia_space.thresholds.mantle)
    local changed = false
        
    for i in area:iter(minp.x, minp.y, minp.z, maxp.x, itermax, maxp.z) do
        -- Only replace actual nodes (ignore CONTENT_IGNORE/unloaded)
        if data[i] ~= minetest.CONTENT_IGNORE then
		data[i] = c_lava
		changed = true
	end
    end
    return changed
end

local function writeback(vm, data, changed)
    if not changed then return false end
    vm:set_data(data)
    vm:set_lighting({day = 0, night = 0}) -- Optional: force recalculation
    vm:calc_lighting()
    vm:write_to_map()
    return true
end

function ia_space.on_generated(minp, maxp, seed)
    -- Early exit if the chunk is in the "Goldilocks" zone (between Space and Mantle)
    if ia_space.is_strictly_between_mantle_and_space_thresholds2(minp, maxp) then return end
    local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
    local area           = VoxelArea:new({MinEdge = emin, MaxEdge = emax})
    local data           = vm:get_data()
    local changed        = generate_space (minp, maxp, area, data)
    changed              = generate_mantle(minp, maxp, area, data) or changed
    changed              = writeback(vm, data, changed)
end
minetest.register_on_generated(ia_space.on_generated)
