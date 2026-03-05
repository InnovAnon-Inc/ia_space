-- ia_space/nodes.lua
local VACUUM_NODE = "ia_space:vacuum"

minetest.register_node(VACUUM_NODE, {
    description = "Vacuum of Space",
    drawtype = "airlike",
    paramtype = "light",
    sunlight_propagates = true,
    walkable = false,
    pointable = false,
    diggable = false,
    buildable_to = true,
    groups = {vacuum = 1, not_in_creative_inventory = 1},
})
