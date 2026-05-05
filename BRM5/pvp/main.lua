local Velvetrepo = "https://raw.githubusercontent.com/DexCodeSX/Velvet/main/"
local Velvet = loadstring(game:HttpGet(Velvetrepo .. "Library.lua"))()
local Icons = loadstring(game:HttpGet(Velvetrepo .. "addons/Icons.lua"))()
local QuickBar = loadstring(game:HttpGet(Velvetrepo .. "addons/QuickBar.lua"))()
local NotifHistory = loadstring(game:HttpGet(Velvetrepo .. "addons/NotificationHistory.lua"))()
local Nozomirepo = "https://raw.githubusercontent.com/theofitzgerald/BRM5/main/"
local config = loadstring(game:HttpGet(Nozomirepo.. "BRM5/pvp/module/config.lua"))
local services = loadstring(game:HttpGet(Nozomirepo.. "BRM5/pvp/module/services.lua"))


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
