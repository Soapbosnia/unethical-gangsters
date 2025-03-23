local cwd = io.popen("cd"):read("*l").."/gamemode/server"
local autostart = dofile(cwd.."/autostart.lua")
local timers = {}
local resources = {}
local globals = {}
local exports = {}
_G.exports = exports

function fileExists(path)
    local file = io.open(path, "r")
    if file then
        file:close()
        return true
    end
    return false
end

local function scanResources(directory, foundResources)
    local handle = io.popen('dir "'..directory..'" /b /ad')
    if not handle then return end

    for folderName in handle:lines() do
        local fullPath = directory.."/"..folderName
        local manifestPath = fullPath.."/manifest.lua"

        if fileExists(manifestPath) then
            table.insert(foundResources, fullPath)
        else
            scanResources(fullPath, foundResources)
        end
    end

    handle:close()
end

function getResources()
    return resources
end

function refreshResources()
    local loadedCount = 0
    local found = {}

    scanResources(cwd.."/resources", found)

    for _, resourcePath in ipairs(found) do
        local resourceName = resourcePath:match("([^/]+)$")
        local manifestPath = resourcePath.."/manifest.lua"
        local manifest = dofile(manifestPath)

        if manifest then
            local isValid = true

            for _, entry in ipairs(manifest.files) do
                local filePath = resourcePath.."/"..entry.path
                
                if (not fileExists(filePath)) then
                    isValid = false
                    break
                end
            end

            if isValid then
                resources[resourceName] = {name = resourceName, path = resourcePath, manifest = manifest, environment = {}, state = 0}
                loadedCount = loadedCount + 1
            end
        else
            Console.log("Warning: Skipping resource '"..resourceName.."' due to invalid or missing manifest.lua")
        end
    end

    Console.log("Loaded "..loadedCount.." resources.")
end

function startResource(resourceName)
    local resource = resources[resourceName]

    if (not resource) then
        Console.log("Resource '"..resourceName.."' not found.")
        return false
    end

    if (resource.state == 1) then
        Console.log("Failed to start '"..resourceName.."' since it's already running.")
        return false
    end

    resource.state = 1
    exports[resourceName] = {}
    resource.environment.exports = exports[resourceName]
    resource.environment.thisResource = resourceName
    setmetatable(resource.environment, {__index = function(_, key)
        return globals[key] or _G[key]
    end})

    local function wrapFunction(fn)
        return function(self, ...)
            return fn(...)
        end
    end

    for _, entry in ipairs(resource.manifest.files) do
        if (entry.type == "script") then
            local scriptPath = resource.path.."/"..entry.path
            
            if (not fileExists(scriptPath)) then
                Console.log("Error: Missing script file '"..scriptPath.."' in resource '"..resourceName.."'")
                return false
            end

            local chunk, err = loadfile(scriptPath, "bt", resource.environment)
            if (not chunk) then
                Console.log("Error: Failed to load script '" .. scriptPath .. "' - " .. err)
                return false
            end

            local success, runtimeError = pcall(chunk)
            if (not success) then
                Console.log("Error: Runtime error in '"..scriptPath.."' - "..runtimeError)
                return false
            end
        end
    end

    for key, value in pairs(resource.environment.exports) do
        if (type(value) == "function") then
            resource.environment.exports[key] = wrapFunction(value)
        end
    end

    exports[resourceName] = resource.environment.exports
    Event.emit("onResourceStart", resourceName)
    Console.log("Started resource: "..resourceName)
    return true
end

function stopResource(resourceName)
    local resource = resources[resourceName]

    if (not resource) then
        Console.log("Resource '"..resourceName.."' not found.")
        return false
    end

    if (resource.state == 0) then
        Console.log("Resource '"..resourceName.."' is already stopped.")
        return false
    end

    Event.emit("onResourceStop", resourceName)
    exports[resourceName] = nil
    resource.environment = {}
    resource.state = 0

    Console.log("Stopped resource: "..resourceName)
    return true
end

function restartResource(resourceName)
    if stopResource(resourceName) then
        return startResource(resourceName)
    end
    return false
end

function getResourceFromName(resourceName)
    return resources[resourceName]
end

function getResourceState(resourceName)
    local resource = resources[resourceName]
    return resource and resource.state
end

function getResourcePath(resourceName)
    local resource = resources[resourceName]
    return resource and resource.path
end

----------------------
-- Exported globals --
----------------------
-- Resources
globals.getResources = getResources
globals.refreshResources = refreshResources
globals.startResource = startResource
globals.stopResource = stopResource
globals.restartResource = restartResource
globals.getResourceFromName = getResourceFromName
globals.getResourceState = getResourceState
globals.getResourcePath = getResourcePath

-- Files
globals.cwd = cwd
globals.fileExists = fileExists

-- Timer
globals.setTimer = function(handler, duration, executions, ...)
    local args = {...}
    local count = 0
    local timerHandle

    timerHandle = Timer.create(function()
        handler(table.unpack(args))
        count = count + 1

        if (executions > 0 and count >= executions) then
            globals.killTimer(timerHandle)
            return
        end
    end, duration)

    timers[timerHandle] = timerHandle
    return timerHandle
end

globals.killTimer = function(timerHandle)
    if timers[timerHandle] then
        timerHandle:destroy()
        timers[timerHandle] = nil
    end
end

----------------
-- Main event --
----------------
Event.on("onGamemodeLoaded", function()
    refreshResources()
    for i=1, #autostart do
        startResource(autostart[i])
    end
end)