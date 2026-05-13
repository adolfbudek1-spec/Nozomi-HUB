if typeof(clear) == "function" then
    clear()
end

local MAIN_VERSION = "cache-bust-2026-03-18-03"

local GITHUB_BASE = "https://raw.githubusercontent.com/theofitzgerald/Nozomi-HUB/main/"
local GITHUB_MODULE = GITHUB_BASE .. "BRM5/modules/"
local CACHE_BUSTER = MAIN_VERSION .. "-" .. tostring(os.time())

local function get(url)
    return game:HttpGet(url .. "?v=" .. CACHE_BUSTER)
end

local function loadRemote(path)
    local success, result = pcall(function()
        return loadstring(get(GITHUB_BASE .. path))()
    end)

    if not success then
        warn("[NOZOMI HUB] Failed loading:", path)
        warn(result)

        return nil
    end

    return result
end

local services = loadRemote("services.lua")
local ui = loadRemote("ui.lua")

if not ui then
    return warn("[NOZOMI HUB] UI failed to load")
end

local library = ui.library
local window = ui.window

--======================= [[ MAIN TAB ]] =======================--

local mainTab = ui:addTab("Main", "house")

mainTab:AddLabel("Nozomi HUB Loaded")