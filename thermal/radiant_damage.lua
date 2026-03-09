-- ia_space/thermal/radiant_damage.lua

ia_space.player_radiant_flux = {}

-- [Helper: Registry API]
-- Allows other modules to add heat/cold sources easily
function ia_space.register_emitter_radiant_damage(nodename, value)
    assert(minetest.get_modpath('radiant_damage'))
    radiant_damage.override_radiant_damage("thermal_flux", {
        emitted_by = { [nodename] = value }
    })
end

function ia_space.register_attenuator_radiant_damage(nodename, multiplier)
    assert(minetest.get_modpath('radiant_damage'))
    radiant_damage.override_radiant_damage("thermal_flux", {
        attenuated_by = { [nodename] = multiplier }
    })
end

function ia_space.register_emitter(nodename, value)
    ia_space.nodes.emitters[nodename] = value
    if not minetest.get_modpath('radiant_damage') then return end
    ia_space.register_emitter_radiant_damage(nodename, value)
end

function ia_space.register_attenuator(nodename, multiplier)
    ia_space.nodes.attenuators[nodename] = multiplier
    if not minetest.get_modpath('radiant_damage') then return end
    ia_space.register_attenuator_radiant_damage(nodename, value)
end

-- [The Core Thermal Flux Definition]
if minetest.get_modpath('radiant_damage') then
    radiant_damage.register_radiant_damage("thermal_flux", {
        interval               = 1,
        inverse_square_falloff = true,

        -- Heat generally doesn't pass through solid walls (unlike Mese radiation)
        default_attenuation    = 0,
	-- TODO radiant_damage api handles convection & radiation

        -- Negative values in radiant_damage act as "healing,"
        -- but for us, they act as "cooling" (Endothermic).
        emitted_by             = ia_space.nodes.emitters,
        attenuated_by          = ia_space.nodes.attenuators,

        on_damage              = function(player, flux_value, pos)
            local name = player:get_player_name()
            -- We store the raw value.
            -- radiant_damage calculates sum of (emitted / dist^2 * attenuation)
            ia_space.player_radiant_flux[name] = flux_value
        end,
    })
end

function ia_space.calculate_vicinity_celsius_delta_radiant_damage(player)
    assert(minetest.get_modpath('radiant_damage'))
    assert(player ~= nil)
    return (ia_space.player_radiant_flux[name] or 0)
end

function ia_space.calculate_vicinity_celsius_delta_vanilla(pos, radius) -- FIXME algo was designed to work with celsius; needs review
    local mod                 = 0
    local radius              = (radius or 8)
    local minp                = vector.subtract(pos, radius)
    local maxp                = vector.add(pos, radius)

    local thermal_list        = {}
    for name, _ in pairs(ia_space.nodes.emitters) do
        table.insert(thermal_list, name)
    end

    local found_nodes         = minetest.find_nodes_in_area(minp, maxp, {"group:igniter"})
    local specific_nodes      = minetest.find_nodes_in_area(minp, maxp, thermal_list)

    local all_found           = found_nodes
    for _, p in ipairs(specific_nodes) do table.insert(all_found, p) end

    for _, npos in ipairs(all_found) do
        local node            = minetest.get_node(npos)
        local dist            = vector.distance(pos, npos)
        local distance_factor = 1 / math.max(1, dist)

        local node_heat       = (ia_space.nodes.emitters[node.name] or 0)
        if (node_heat == 0) and (minetest.get_item_group(node.name, "igniter") > 0) then
            node_heat         = 5
        end

        mod                   = mod + (node_heat * distance_factor)
    end
    mod                       = mod / 5.0 -- FIXME magic number
    return math.max(-50, math.min(mod, 80))
end

function ia_space.calculate_vicinity_celsius_delta(pos, player)
    assert((pos == nil and player ~= nil)
    or     (pos ~= nil and player == nil)
    or     (player:get_pos() == pos))
    if minetest.get_modpath('radiant_damage') then
        return ia_space.calculate_vicinity_celsius_delta_radiant_damage(player)
    end
    return ia_space.calculate_vicinity_celsius_delta_vanilla(pos)
end





