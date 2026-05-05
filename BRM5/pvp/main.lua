local function load(url)
    local success, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    if not success then
        warn("FAILED URL:", url)
        warn("ERROR:", result)
        return {}
    end
    return result
end

local Obsidianrepo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Nozomirepo   = "https://raw.githubusercontent.com/theofitzgerald/Nozomi-HUB/main/"
local obsidian     = loadstring(game:HttpGet(Obsidianrepo .. "Library.lua"))()

local esp      = load(Nozomirepo .. "BRM5/pvp/module/esp.lua")
local config   = load(Nozomirepo .. "BRM5/pvp/module/config.lua")
local services = load(Nozomirepo .. "BRM5/pvp/module/services.lua")

local Window = obsidian:CreateWindow({
    Title           = "mspaint",
    Footer          = "version: example",
    Icon            = 95816097006870,
    NotifySide      = "Right",
    ShowCustomCursor = true,
})

esp:setupListener(workspace, config)
esp:startUpdater(config)

-- FIX: jangan refresh dulu sebelum enabled
-- marker akan dibuat saat toggle dinyalakan

local visualTab  = Window:AddTab("Visual", "eye")
local ESPGroupBox = visualTab:AddLeftGroupbox("ESP Player")

ESPGroupBox:AddToggle("espEnabled", {
    Text    = "Enable ESP",
    Default = config.espEnabled,
    Callback = function(v)
        -- FIX: dulu panggil setEspEnabled tanpa prefix esp:
        esp:setEspEnabled(v, config)
    end,
})

ESPGroupBox:AddToggle("espHighlight", {
    Text    = "Show Highlight",
    Default = config.espHighlight,
    Callback = function(v)
        -- FIX: typo espHiglight → espHighlight
        config.espHighlight = v
    end,
})

ESPGroupBox:AddColorPicker("espColor", {
    Text    = "ESP Color",
    Default = config.espColor,
    Callback = function(v)
        config.espColor = v
    end,
})

ESPGroupBox:AddSlider("espMaxDistance", {
    Text     = "Max Distance",
    Default  = config.espMaxDistance,
    Min      = 100,
    Max      = 5000,
    Rounding = 0,
    Callback = function(v)
        -- FIX: dulu config.MaxDistance, harusnya config.espMaxDistance
        config.espMaxDistance = v
    end,
})