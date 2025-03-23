Event.on("onResourceStart", function(resource)
    if (resource == thisResource) then
        _G.exports.maploader:load("mansion", ":mansion/mapfile.lua")
    end
end)

Event.on("onResourceStop", function(resource)
    if (resource == thisResource) then
        _G.exports.maploader:unload("mansion")
    end
end)