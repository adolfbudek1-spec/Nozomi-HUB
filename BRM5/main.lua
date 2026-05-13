if typeof(clear) == "function" then
    clear()
end

local MAIN_VERSION = "cache-bust-2026-03-18-03"
local GITHUB_BASE = "https://raw.githubusercontent.com/theofitzgerald/NOZOMI-HUB/main/"
local GITHUB_MODULE = ""..GITHUB_BASE.."BRM5/modules/"
local CACHE_BUSTER = MAIN_VERSION .. "-" .. tostring(os.time())

local function loadModule(moduleName)
end

local services = loadstring(game:HttpGet(GITHUB_BASE .. "services.lua"))()
local ui = loadstring(game:HttpGet(GITHUB_BASE .. "ui.lua"))()
local library = ui.library
local window = ui.window


--======================= [[ MAIN TAB ]] =======================--
local mainTab = ui:addTab("Main", "house")
mainTab:AddLabel("Kontol Kau Pecah")
