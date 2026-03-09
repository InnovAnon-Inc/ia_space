-- ia_space/lerp.lua

local function hex_to_rgb_helper(x)
    x = '0x'..x
    return tonumber(x)
end

function ia_space.hex_to_rgb(hex) -- TODO move to ia_util
    hex     = hex:gsub("#", "")
    local r = hex:sub(1, 2)
    local g = hex:sub(3, 4)
    local b = hex:sub(5, 6)
    r       = hex_to_rgb_helper(r)
    g       = hex_to_rgb_helper(g)
    b       = hex_to_rgb_helper(b)
    return r, g, b
end

function ia_space.lerp_color(c1, c2, ratio)
    local r1, g1, b1 = ia_space.hex_to_rgb(c1)
    local r2, g2, b2 = ia_space.hex_to_rgb(c2)
    local r          = math.floor(r1 + (r2 - r1) * ratio)
    local g          = math.floor(g1 + (g2 - g1) * ratio)
    local b          = math.floor(b1 + (b2 - b1) * ratio)
    return string.format("#%02x%02x%02x", r, g, b)
end

function ia_space.lerp(a, b, weight)
    assert(a      ~= nil)
    assert(b      ~= nil)
    assert(weight ~= nil)
    return (a * (1 - weight)) + (b * weight)
end
