-- ia_space/mapgen.lua
local BASE_SPACE_THRESHOLD = 10000
local MANTLE_THRESHOLD = -20000
local VACUUM_NODE = "ia_space:vacuum"
local AIR_NODE = "air"

minetest.register_on_generated(function(minp, maxp, seed)
    local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
    local area = VoxelArea:new({MinEdge = emin, MaxEdge = emax})
    local data = vm:get_data()

    -- 1. SPACE GENERATION
    if maxp.y >= BASE_SPACE_THRESHOLD then
        local c_air = minetest.get_content_id(AIR_NODE)
        local c_vac = minetest.get_content_id(VACUUM_NODE)
        local itermin = math.max(minp.y, BASE_SPACE_THRESHOLD)
        
        for i in area:iter(minp.x, itermin, minp.z, maxp.x, maxp.y, maxp.z) do
            if data[i] == c_air then data[i] = c_vac end
        end
    end

    -- 2. MANTLE GENERATION
    if minp.y <= MANTLE_THRESHOLD then
        local c_lava = minetest.get_content_id("default:lava_source")
        local itermax = math.min(maxp.y, MANTLE_THRESHOLD)
        
        for i in area:iter(minp.x, minp.y, minp.z, maxp.x, itermax, maxp.z) do
            if data[i] ~= minetest.CONTENT_IGNORE then
                data[i] = c_lava
            end
        end
    end

    vm:set_data(data)
    vm:write_to_map()
end)
