Event.on("onResourceStart", function(resource)
    if (resource == thisResource) then
        _G.exports.maploader:load("beyond", ":beyond/mapfile.lua")
    end
end)

Event.on("onResourceStop", function(resource)
    if (resource == thisResource) then
        _G.exports.maploader:unload("beyond")
    end
end)