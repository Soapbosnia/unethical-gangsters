local function sendError(player, message)
    return Chat.sendToPlayer(player, "{FF0000}"..message)
end

local function sendMessage(player, message, command, args)
    local name = args[1]
    local content = table.concat(args, " ", 2)

    if (not name or name == " ") then
        return sendError(player, "Syntax: /"..command.." [partial target name] [message]")
    end

    local target = _G.exports.playermanager:getFromPartialName(name)
    if (#target == 0 or #target > 1) then
        return sendError(player, "~ Your sequence matches "..#target.." names")
    end

    target = target[1]
    if (target == player) then
        return sendError(player, "~ You can't message yourself")
    end

    local playerHex = _G.exports.cache:get(player.id, "colorhex")
    local targetHex = _G.exports.cache:get(target.id, "colorhex")
    content = _G.exports.utils:filterHex(content)

    Chat.sendToPlayer(player, "{FF99FF}Whisper to {FFFFFF}| "..targetHex..target.nickname..":{FFFFFF} "..content)
    Chat.sendToPlayer(target, "{FF99FF}Whisper from {FFFFFF}| "..playerHex..player.nickname..":{FFFFFF} "..content)
end

Event.on("onResourceStart", function(resourceName)
    if (resourceName == thisResource) then
        _G.exports.chats:registerCommand("whisper", sendMessage)
        _G.exports.chats:registerCommand("w", sendMessage)
        _G.exports.chats:registerCommand("pm", sendMessage)
        _G.exports.chats:registerCommand("dm", sendMessage)
    end
end)

Event.on("onResourceStop", function(resourceName)
    if (resourceName == thisResource) then
        _G.exports.chats:removeCommand("whisper", sendMessage)
        _G.exports.chats:removeCommand("w", sendMessage)
        _G.exports.chats:removeCommand("pm", sendMessage)
        _G.exports.chats:removeCommand("dm", sendMessage)
    end
end)