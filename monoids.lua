-- ia_space/monoids.lua

function ia_space.set_sky(player, sky) -- TODO better monoid
    assert(player ~= nil)
    if minetest.get_modpath("climate_api") then return end -- TODO delegate to climate_api ?
    player:set_sky(sky)
end

ia_space.temperature_monoid = player_monoids.make_monoid({ -- NOTE might move this is to ia_hunger_ng
    identity = 0,
    combine = function(a, b) return a + b end,
    fold = function(t)
        local sum = 0
        for _, v in pairs(t) do sum = sum + v end
        return sum
    end,
    apply = function(value, player)
        player:get_meta():set_float("ia_space:modifier", value)
    end,
})
