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
local config = load(Nozomirepo .. "BRM5/pvp/module/config.lua")
local services = load(Nozomirepo .. "BRM5/pvp/module/services.lua")


--======================== [[ CREATE WINDOW ]] ========================
local Window = Velvet:CreateWindow({
    Title = "Velvet",
    SubTitle = "v3.2 showcase",
    ToggleKey = Enum.KeyCode.RightShift,
    ToggleIcon = "sparkles",
})

--======================== [[ BIND ADDON ]] ========================
Velvet:SetIcons(Icons)
NotifHistory:Bind(Velvet, Window)

--========= [[ VISUAL TAB ]] =========
local visualTab = Window:AddTab("Visual", "eye")
local ESPSection_1 = visualTab:AddSection("Esp Player")
ESPSection_1:AddToggle("ESPEnable_1", {
    Text = "Enable ESP",
    Default = config.espPlayerEnabled,
    Callback = function(v) 
        print("ESP ACTIVATED")
    end
})

ESPSection_1:AddToggle("ESPHighlight_1", {
    Text = "Show Highlight",
    Default = config.espPlayerHighlight,
    VisibleWhen = "ESPEnable_1",
    Callback = function(v) 
        print("ESP ACTIVATED")
    end
})

ESPSection_1:AddColorPicker("ESPColor_1", {
    Text = "ESP Color",
    Default = config.espPlayerColor,
    VisibleWhen = "ESPEnable_1",
})

ESPSection_1:AddSlider("ESPDistance", {
    Text = "Max Distance",
    Min = 100, Max = 5000, Default = config.espPlayerDistance, Increment = 50,
    Suffix = " studs",
    VisibleWhen = "ESPEnable_1",
})
