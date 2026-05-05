--======================== [[ LOADER ]] ========================--
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
local Nozomirepo = "https://raw.githubusercontent.com/theofitzgerald/Nozomi-HUB/main/"
local obsidian = loadstring(game:HttpGet(Obsidianrepo .. "Library.lua"))()

local esp = load(Nozomirepo .. "BRM5/pvp/module/esp.lua")
local config = load(Nozomirepo .. "BRM5/pvp/module/config.lua")
local services = load(Nozomirepo .. "BRM5/pvp/module/services.lua")

--======================== [[ CREATE WINDOW ]] ========================--
local Window = obsidian:CreateWindow({
	Title = "mspaint",
	Footer = "version: example",
	Icon = 95816097006870,
	NotifySide = "Right",
	ShowCustomCursor = true,
})

--======================== [[ SETUP ADDONS ]] ========================--

esp:refreshTrackedTarget(workspace, config)
esp:setupListener(workspace, config)
esp:startUpdater(config)    

--======================== [[ VISUAL TAB ]] ========================--
local visualTab = Window:AddTab("Visual", "eye")
local ESPGroupBox = visualTab:AddLeftGroupbox("ESP Player")
ESPGroupBox:AddToggle("espEnabled", {
    Text = "Enable ESP",
    Default = config.espEnabled,
    Callback = function(v)
        config.espEnabled = v
        setEspEnabled(v, config)
    end,
})

ESPGroupBox:AddToggle("espHiglight", {
    Text = "Show Highlight",
    Default = config.espHighlight,
    Callback = function(v)
        config.espHiglight = v
    end,
})

ESPGroupBox:AddSlider("espMaxDistance", {
    Text     = "Max Distance",
    Default  = config.espMaxDistance,
    Min      = 100,
    Max      = 5000,
    Rounding = 0,
    Callback = function(v)
        config.MaxDistance = v
    end,
})	