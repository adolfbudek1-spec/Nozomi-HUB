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

local Velvetrepo = "https://raw.githubusercontent.com/DexCodeSX/Velvet/main/"
local Nozomirepo = "https://raw.githubusercontent.com/theofitzgerald/Nozomi-HUB/main/"
local Velvet = load(Velvetrepo .. "Library.lua")
local Icons = load(Velvetrepo .. "addons/Icons.lua")
local QuickBar = load(Velvetrepo .. "addons/QuickBar.lua")
local NotifHistory = load(Velvetrepo .. "addons/NotificationHistory.lua")

local esp = load(Nozomirepo .. "BRM5/pvp/module/esp.lua")
local config = load(Nozomirepo .. "BRM5/pvp/module/config.lua")
local services = load(Nozomirepo .. "BRM5/pvp/module/services.lua")

--======================== [[ CREATE WINDOW ]] ========================--
local Window = Velvet:CreateWindow({
    Title = "Velvet",
    SubTitle = "v3.2 showcase",
    ToggleKey = Enum.KeyCode.RightShift,
    ToggleIcon = "sparkles",
})

Velvet:SetIcons(Icons)
NotifHistory:Bind(Velvet, Window)

esp:refreshTrackedTarget(workspace, config)
esp:setupListener(workspace, config)
esp:startUpdater()    

--======================== [[ VISUAL TAB ]] ========================--
local visualTab = Window:AddTab("Visual", "eye")
local ESPSection_1 = visualTab:AddSection("ESP Player")
ESPSection_1:AddToggle("ESPEnable_1", {
    Text = "Enable Player ESP",
    Default = config.espEnabled,
    Callback = function(v)
        esp:setEspEnabled(v, config)
    end
})

ESPSection_1:AddColorPicker("ESPColor_1", {
    Text = "ESP Color",
    Default = config.espColor,
    VisibleWhen = "ESPEnable_1",
    Callback = function(color)
        config.espColor = v
    end
})

ESPSection_1:AddSlider("ESPDistance", {
    Text = "Max Distance",
    Min = 100, Max = 5000,
    Default = config.espMaxDistance,
    Increment = 50,
    Suffix = " studs",
    VisibleWhen = "ESPEnable_1",
    Callback = function(v)
        config.espMaxDistance = v
    end
})
