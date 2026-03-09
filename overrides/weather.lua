-- ia_space/weather/overrides.lua

if minetest.get_modpath('regional_weather') then
    regional_weather.settings.max_height = ia_space.get_maximum_weather_height()
    regional_weather.settings.min_height = ia_space.get_minimum_weather_height()
end

-- TODO stub out our own if regional_weather/climate_api missing ?
