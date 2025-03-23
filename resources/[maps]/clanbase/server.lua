Event.on("onResourceStart", function(resource)
    if (resource == thisResource) then
        _G.exports.maploader:load("clan|rs", ":clanbase/mapfile.lua")
    end
end)

Event.on("onResourceStop", function(resource)
    if (resource == thisResource) then
        _G.exports.maploader:unload("clan|rs")
    end
end)