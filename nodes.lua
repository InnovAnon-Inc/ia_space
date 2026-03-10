-- ia_space/nodes.lua

minetest.register_node(ia_space.nodes.vacuum, {
    description         = "Vacuum of Space",
    drawtype            = "airlike",
    paramtype           = "light",
    sunlight_propagates = true,
    post_effect_color   = {r = 0, g = 0, b = 0, a = 20,},
    walkable            = false,
    pointable           = false,
    diggable            = false,
    buildable_to        = true,
    groups              = {
        vacuum                    = 1,
	not_in_creative_inventory = 1,
        is_air_like               = 1, -- Terrestrial vacuums might eventually use this to interact with air-tightness mods
    },
    drop                = "",
})

-- TODO probably need an abm to handle hull breaches (vacuum of space should eat air nodes... but not naively... probably y-value aware, air/vacuum "density" aware, etc)

-- TODO maybe create a terrestrial vacuum node, too (for vacuums in the lab down on earth)... should probably cancel out with enough air surrounding it... that mechanic might also work for patching air leaks in space


-- TODO vacuum nodes need to replace nearby air nodes ... use similar density metrics

-- TODO abm for tides
-- TODO abm for vacuums





-- ia_space/abm/vacuum.lua


local REPLACEMENT_CHANCE = 2 -- 1 in X chance to trigger per ABM cycle

minetest.register_abm({
    label     = "Vacuum-Air Interaction (Pressure Engine)",
    nodenames = {ia_space.nodes.vacuum, ia_space.nodes.air,},
    interval  = 1.0,
    chance    = REPLACEMENT_CHANCE,
    catch_up  = false,
    
--    action    = function(pos, node)
--        local is_space = (pos.y > ia_space.get_s
--        
--        -- Neighborhood analysis (3x3x3 check)
--        local neighbors = minetest.find_nodes_in_area(
--            vector.subtract(pos, 1), 
--            vector.add(pos, 1), 
--            {VACUUM_NAME, AIR_NAME}
--        )
--        
--        local air_count = 0
--        local vac_count = 0
--        for _, npos in ipairs(neighbors) do
--            local name = minetest.get_node(npos).name
--            if name == AIR_NAME then air_count = air_count + 1 end
--            if name == VACUUM_NAME then vac_count = vac_count + 1 end
--        end
--
--        -- Total relevant neighbors (max 26 excluding self)
--        local total = air_count + vac_count
--        if total == 0 then return end
--        
--        local air_density = air_count / total
--
--        -- CASE A: We are a VACUUM node
--        if node.name == VACUUM_NAME then
--            -- On Earth, if we are surrounded by air, we get crushed.
--            if not is_space and air_density > 0.4 then
--                minetest.set_node(pos, {name = AIR_NAME})
--            end
--            
--            -- In Space, if we find air nearby, we "suck" it (replaces air with us)
--            -- This simulates the breach expansion
--            if is_space then
--                -- This is handled by CASE B for performance, but we could 
--                -- trigger sound/particle effects here.
--            end
--
--        -- CASE B: We are an AIR node
--        elseif node.name == AIR_NAME then
--            -- In Space, if even ONE vacuum node is adjacent, air is vulnerable
--            if is_space and vac_count > 0 then
--                -- The "Expanse" always wins. Air is pulled into the void.
--                minetest.set_node(pos, {name = VACUUM_NAME})
--                
--                -- Sound effect for the breach (only if near player)
--                if vac_count == 1 then -- Just started leaking
--                     minetest.sound_play("ia_space_hiss", {pos = pos, gain = 0.5, max_hear_distance = 16})
--                end
--            end
--            
--            -- On Earth, air is stable unless an active vacuum pump (TODO) is nearby.
--        end
--    end,
    action = function(pos, node)
        local is_void        = ia_space.is_above_dynamic_space_threshold   (pos)
        local is_meso        = ia_space.is_above_lower_mesosphere_threshold(pos)
	local is_sealevel    = ia_space.is_above_dynamic_sealevel_threshold(pos)
	local is_mantle      = ia_space.is_above_mantle_threshold          (pos)

	local in_meso        = (is_meso     and not is_void)
	local on_earth       = (is_sealevel and not is_meso)
	local in_crust       = (is_mantle   and not is_sealevel)
	local in_mantle      = (                not is_mantle)


        -- BEHAVIOR LOGIC
        if node.name == "air" then
            if is_void and vac_count > 0 then
                -- In the Void, any contact with vacuum deletes air instantly.
                minetest.set_node(pos, {name = ia_space.nodes.vacuum})
            elseif in_meso and vac_count > 4 then
                -- In the Mesosphere, air is thin; it needs more support to stay.
                minetest.set_node(pos, {name = ia_space.nodes.vacuum})
            end
        else -- node is vacuum
            if not in_meso and not is_void and air_density > 0.3 then
                -- On Earth (Crust), air pressure crushes vacuum pockets.
                minetest.set_node(pos, {name = ia_space.nodes.air})
            end
        end
    end,
})

function ia_space.calculate_air_pressure(pos)
    assert(pos    ~= nil)
    local radius         = 1
    local ratio = ia_space.calculate_air_to_vacuum_ratio(pos, radius)
    -- TODO
end

function ia_space.calculate_air_to_vacuum_ratio(pos, radius)
    assert(pos    ~= nil)
    assert(radius ~= nil)
    local air            = 0
    local vacuum         = 0
    local total          = 0
    local result         = ia_space.iter_radius_nodes(pos, radius, function(node)
        total            = (total  + 1)
        if ia_space.is_node_air(node) then
            air          = (air    + 1)
            return
        end
        if ia_space.is_node_vacuum(node) then
            vacuum       = (vacuum + 1)
            return
        end
    end)
    assert(result == nil)
    assert(air + vacuum <= total)
    assert(total == radius * radius * radius)
    return (air / total), (vacuum / total)
end
