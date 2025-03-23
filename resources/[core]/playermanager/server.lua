local spawnpoints = {
	{1291.837890625, -790.33984375, 92.03125, 0, 0, 90.80615234375, "Madd Dogg's Mansion"},
	{22.157836914062, -2648.708984375, 40.475242614746, -0, 0, 89.941459655762, "Flint County"},
	{2514.81714, -1674.00195, 13.69270, -0, 0, 60.386539459229, "Groove Street"},
    {1937.6, -491.5, 30.71, 0, 0, 90, "Treehouse"},
    {-740.259765625, -2034.4716796875, 8.0078125, 0, 0, 4.88623046875, "Back o Beyond"}
}

---------------------
-- Player database --
---------------------
function getFromName(name)
    for _, player in ipairs(Trilogy.getAllPlayers()) do
        if (player.nickname == name) then
            return player
        end
    end
    return false
end

function getFromPartialName(playerName)
    local player = getFromName(playerName)
    local matches = {}
    
    if player then
        table.insert(matches, player)
        return matches
    end
    
    for _, player in ipairs(Trilogy.getAllPlayers()) do
        if string.find(string.gsub(player.nickname:lower(),"#%x%x%x%x%x%x", ""), playerName:lower(), 1, true) then
            table.insert(matches, player)
        end
    end

    return matches
end

---------------
-- Scripting --
---------------
function spawnPlayer(player, x, y, z, rx, ry, rz)
    local spawnpoint = spawnpoints[math.random(#spawnpoints)]
    local position = Vector3.new(x or spawnpoint[1], y or spawnpoint[2], z or spawnpoint[3])
    local rotation = Vector3.new(rx or spawnpoint[4], ry or spawnpoint[5], rz or spawnpoint[6])

    player:setPosition(position)
    player:setRotation(rotation)
end

Event.on("onPlayerConnected", function(player)
    local r, g, b = math.random(0, 255), math.random(0, 255), math.random(0, 255)
    local color = _G.exports.utils:toHex(r, g, b)

    _G.exports.cache:set(player.id, "color", {r, g, b})
    _G.exports.cache:set(player.id, "colorhex", "{"..color.."}")
    Event.emit("onPlayerJoin", player)
end)

Event.on("onPlayerDisconnected", function(player)
    Event.emit("onPlayerQuit", player, "Quit")
    _G.exports.cache:clear(player.id)
end)

exports = {
    getFromName = getFromName,
    getFromPartialName = getFromPartialName,
    spawn = spawnPlayer
}