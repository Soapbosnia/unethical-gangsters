Event.on("onResourceStart", function(resource)
    if (resource == thisResource) then
        _G.exports.maploader:load("treehouse", ":treehouse/mapfile.lua")
    end
end)

Event.on("onResourceStop", function(resource)
    if (resource == thisResource) then
        _G.exports.maploader:unload("treehouse")
    end
end)