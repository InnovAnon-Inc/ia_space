-- ia_space/times.lua

function ia_space.get_gametime_minutes()
    return minetest.get_gametime() / 60
end

function ia_space.get_gametime_hours()
    return ia_space.get_gametime_minutes() / 60
end
