Event.on("onResourceStart", function(resource)
    if (resource == thisResource) then
        _G.exports.maploader:load("maddoggs", ":maddoggs/mapfile.lua")
    end
end)

Event.on("onResourceStop", function(resource)
    if (resource == thisResource) then
        _G.exports.maploader:unload("maddoggs")
    end
end)