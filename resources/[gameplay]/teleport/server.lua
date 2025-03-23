local duration = 10
local color = "{00AAFF}"
local request = {
    outgoing = {},
    incoming = {}
}

local function sendError(player, message)
    return Chat.sendToPlayer(player, "{FF0000}"..message)
end

local function cancelRequest(target, initiator, forced)
    local targetElement = Trilogy.getPlayerByID(target)
    local initiatorElement = Trilogy.getPlayerByID(initiator)
    local reason = forced and "declined." or "expired."

    request.incoming[target] = nil
    request.outgoing[initiator] = nil

    Chat.sendToPlayer(targetElement, color.."~ Teleport request "..reason)
    Chat.sendToPlayer(initiatorElement, color.."~ Teleport request "..reason)
end

local function sendRequest(player, message, command, args)
    local name = args[1]

    if (not name or name == " ") then
        return sendError(player, "Syntax: /"..command.." [partial target name]")
    end

    if request.outgoing[player.id] then
        return sendError(player, "~ You've already got a pending teleport request")
    end

    local target = _G.exports.playermanager:getFromPartialName(name)
    if (#target == 0 or #target > 1) then
        return sendError(player, "~ Your sequence matches "..#target.." names")
    end

    target = target[1]
    if (target == player) then
        return sendError(player, "~ You can't teleport to yourself")
    end

    if request.incoming[target.id] then
        return sendError(player, "~ Target already has a pending teleport request")
    end

    request.outgoing[player.id] = target.id
    request.incoming[target.id] = player.id

    local playerHex = _G.exports.cache:get(player.id, "colorhex")
    local targetHex = _G.exports.cache:get(target.id, "colorhex")

    Chat.sendToPlayer(target, color.."~ "..playerHex..player.nickname..color.." has requested to teleport to you")
    Chat.sendToPlayer(target, color.."Type '{FFFFFF}/accept"..color.."' to accept, '{FFFFFF}/decline"..color.."' to decline")
    Chat.sendToPlayer(target, color.."Expires in "..duration.." seconds.")
    
    Chat.sendToPlayer(player, color.."~ A teleport request has been sent to "..targetHex..target.nickname)
    Chat.sendToPlayer(player, color.."Expires in "..duration.." seconds.")
end

local function acceptRequest(player)
    local initiator = request.incoming[player.id]

    if (not initiator) then
        return sendError(player, "~ You don't have a pending teleport request")
    end

    local initiatorElement = Trilogy.getPlayerByID(initiator)
    local playerHex = _G.exports.cache:get(player.id, "colorhex")
    local initiatorHex = _G.exports.cache:get(initiator, "colorhex")

    local position = player:getPosition()
    local targetPosition = Vector3.new(position.x, position.y + 0.5, position.z + 0.5)

    request.incoming[player.id] = nil
    request.outgoing[initiator] = nil
    initiatorElement:setPosition(targetPosition)

    Chat.sendToPlayer(initiatorElement, color.."~ "..playerHex..player.nickname..color.." has accepted your teleport request")
    Chat.sendToPlayer(player, color.."~ You've accepted "..initiatorHex..initiatorElement.nickname.."'s "..color.." teleport request")
end

local function declineRequest(player)
    local initiator = request.incoming[player.id]

    if (not initiator) then
        return sendError(player, "~ You don't have a pending teleport request")
    end

    cancelRequest(player.id, initiator, true)
end

Event.on("onPlayerQuit", function(player)
    local incoming = request.incoming[player.id]
    local outgoing = request.outgoing[player.id]
    
    if incoming then
        request.outgoing[incoming] = nil
        request.incoming[player.id] = nil
    elseif outgoing then
        request.incoming[outgoing] = nil
        request.outgoing[player.id] = nil
    end
end)

Event.on("onResourceStart", function(resourceName)
    if (resourceName == thisResource) then
        _G.exports.chats:registerCommand("teleport", sendRequest)
        _G.exports.chats:registerCommand("tpa", sendRequest)
        _G.exports.chats:registerCommand("accept", acceptRequest)
        _G.exports.chats:registerCommand("decline", declineRequest)
    end
end)

Event.on("onResourceStop", function(resourceName)
    if (resourceName == thisResource) then
        _G.exports.chats:removeCommand("teleport", sendRequest)
        _G.exports.chats:removeCommand("tpa", sendRequest)
        _G.exports.chats:removeCommand("accept", acceptRequest)
        _G.exports.chats:removeCommand("decline", declineRequest)
    end
end)