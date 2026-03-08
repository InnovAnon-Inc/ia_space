-- ia_space/tides.lua

function ia_space.get_tidesandfloods_threshold()
    assert(minetest.get_modpath('tidesandfloods'))
    return (tidesandfloods.sealevel - ia_space.thresholds.sealevel)
end

function ia_space.get_tides_threshold()
    assert(minetest.get_modpath('tides'))
    local tod        = minetest.get_timeofday()
    return 2*math.sin(2*math.pi*tod)
end

-- Helper: Get Tidal Offset from tidesandfloods
function ia_space.get_sealevel_threshold()
    if minetest.get_modpath('tidesandfloods') then
	return ia_space.get_tidesandfloods_threshold()
    end
    if minetest.get_modpath('tides') then
	return ia_space.get_tides_threshold()
    end
    -- TODO 
    return ia_space.thresholds.sealevel
end

function ia_space.get_space_threshold()
    local tide_mod = ia_space.get_sealevel_threshold()
    return (ia_space.thresholds.space + tide_mod)
end

--- Realistic Tidal Simulator
-- Uses harmonic constituents to create a varied tide that changes
-- amplitude based on the "Moon Phase" (simulated by time beats).

function ia_space.get_gametime_minutes()
    return minetest.get_gametime() / 60
end

function ia_space.get_gametime_hours()
    return ia_space.get_gametime_minutes() / 60
end

function ia_space.get_m2_tide(time_hours)
    time_hours  = (time_hours or ia_space.get_gametime_hours())
    assert(time_hours ~= nil)
    local theta = (time_hours / ia_space.cycles.m2_period)
    return math.sin(2 * math.pi * theta)
end

function ia_space.get_s2_tide(time_hours)
    time_hours  = (time_hours or ia_space.get_gametime_hours())
    assert(time_hours ~= nil)
    local theta = (time_hours / ia_space.cycles.s2_period)
    return math.sin(2 * math.pi * theta)
end

-- TODO solar times ?

function ia_space.get_simulated_tide()
    local time_hours = ia_space.get_gametime_hours()
    local m2         = ia_space.get_m2_tide(time_hours)
    local s2         = ia_space.get_s2_tide(time_hours)
    -- When in     phase: Spring Tide (High Highs, Low Lows)
    -- When out of phase: Neap   Tide (Muted variations)
    return (m2 + s2) * (ia_space.thresholds.amplitude / 2)
end



-- TODO possible to hook into map gen, etc., and handle the sealevel in a more reasonable way than other mods?
-- i.e., I think other mods use a simple abm that doesn't check the amount of water surrounding a water node,
--       causing weird behaviors, like water-filled rooms emptying, or mining pits becoming filled (which in itself isn't unreasonable, but it would take wayyy longer)
-- TODO consider using metadata? most mods try adding other water nodes, and then sooo many other mods would need to be made aware of these stupid water nodes
