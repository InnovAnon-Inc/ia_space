-- ia_space/thermal/overrides.lua

if minetest.get_modpath('climate_api') then
    assert(                                     ia_space.calculate_cosmologically_aware_engine_heat ~= nil)
--    assert(                                     ia_space.nil_original_get_heat                      ~= nil)
    climate_api.register_influence("heat",      ia_space.calculate_cosmologically_aware_engine_heat)
--    climate_api.register_influence("base_heat", ia_space.nil_original_get_heat) -- noop ?
--    climate_api.register_influence("base_heat", ia_space.calculate_cosmologically_aware_engine_heat)
--    climate_api.register_influence("heat",      ia_space.nil_original_get_engine_heat)
    assert(climate_api.environment          ~= nil)
    assert(climate_api.environment.get_heat ~= nil)
    assert(ia_space.world_limits.origin     ~= nil)
    assert(ia_space.world_limits.origin.x   ~= nil)
    assert(ia_space.world_limits.origin.y   ~= nil)
    assert(ia_space.world_limits.origin.z   ~= nil)
--    assert(climate_api.environment.influences ~= nil)
    assert(minetest.get_timeofday ~= nil)
--    assert(minetest.get_timeofday() ~= nil) -- ???
--    assert(climate_api.environment.get_heat(ia_space.world_limits.origin) ~= nil) -- ???
--    TODO need an assertion to verify that we actually registered the correct functions to the correct influences
else
    assert(not minetest.get_modpath('climate_api'))
    assert(ia_space.original_get_heat ~= nil)
    assert(ia_space.original_get_heat == minetest.get_heat)
    assert(                                     ia_space.calculate_cosmologically_aware_engine_heat ~= nil)
    assert(ia_space.original_get_heat ~=        ia_space.calculate_cosmologically_aware_engine_heat)
    minetest.get_heat =                         ia_space.calculate_cosmologically_aware_engine_heat
    assert(minetest.get_heat ~= nil)
end

