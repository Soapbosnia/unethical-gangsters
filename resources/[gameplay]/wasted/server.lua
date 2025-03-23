Event.on("onPlayerJoin", function(player)
    _G.exports.playermanager:spawn(player)
end)

Event.on("onPlayerDied", function(player)
    _G.exports.playermanager:spawn(player)
end)