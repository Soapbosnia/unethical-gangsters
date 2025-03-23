local map = {}

function loadMap(name, path)
    local path = _G.exports.utils:resolveFilePath(path)

    if (not fileExists(path)) then
        return Console.log("[MAPLOADER]: Unable to load map '"..name.."' from "..path)
    end

    if (not map[name]) then
        map[name] = {}
    end

    local objects = dofile(path)
    for i=1, #objects do
        local entry = objects[i]
        local model = tonumber(entry.model)
        local x = tonumber(entry.posX)
        local y = tonumber(entry.posY)
        local z = tonumber(entry.posZ)
        local rx = tonumber(entry.rotX)
        local ry = tonumber(entry.rotY)
        local rz = tonumber(entry.rotZ)

        map[name][i] = WorldObject.create(model, x, y, z, rx, ry, rz)
    end
end

function unloadMap(name)
    if (not map[name]) then
        return Console.log("[MAPLOADER]: Unable to unload map '"..name.."'")
    end

    for i=1, #map[name] do
        map[name][i]:destroy()
    end
end

Event.on("onResourceStop", function(resource)
    if (resource == thisResource) then
        for name, _ in pairs(map) do
            unloadMap(name)
        end
    end
end)

exports = {
    load = loadMap,
    unload = unloadMap
}