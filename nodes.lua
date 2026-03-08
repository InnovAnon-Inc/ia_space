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
