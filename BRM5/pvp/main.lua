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

local config = load(Nozomirepo .. "BRM5/pvp/module/config.lua")
local services = load(Nozomirepo .. "BRM5/pvp/module/services.lua")
local Walls = load(Nozomirepo .. "BRM5/pvp/module/wall.lua")

--======================== [[ SERVICES ]] ========================--
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local workspace = game:GetService("Workspace")

local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera


--======================== [[ INIT WALL SYSTEM ]] ========================--
Walls:refreshTrackedTargets(workspace, wallConfig)
Walls:setupListener(workspace, wallConfig)

RunService.RenderStepped:Connect(function()
    Walls:updateColors(camera, workspace, localPlayer, wallConfig)
end)

--======================== [[ CREATE WINDOW ]] ========================--
local Window = Velvet:CreateWindow({
    Title = "Velvet",
    SubTitle = "v3.2 showcase",
    ToggleKey = Enum.KeyCode.RightShift,
    ToggleIcon = "sparkles",
})

Velvet:SetIcons(Icons)
NotifHistory:Bind(Velvet, Window)

--======================== [[ VISUAL TAB ]] ========================--
local visualTab = Window:AddTab("Visual", "eye")

--========= PLAYER ESP =========--
local ESPSection_1 = visualTab:AddSection("ESP Player")

ESPSection_1:AddToggle("ESPEnable_1", {
    Text = "Enable Player ESP",
    Default = config.espPlayerEnabled,
    Callback = function(v)
        config.espPlayerEnabled = v
        print("Player ESP:", v)
    end
})

ESPSection_1:AddColorPicker("ESPColor_1", {
    Text = "ESP Color",
    Default = config.espPlayerColor,
    VisibleWhen = "ESPEnable_1",
    Callback = function(color)
        config.espPlayerColor = color
    end
})

ESPSection_1:AddSlider("ESPDistance", {
    Text = "Max Distance",
    Min = 100, Max = 5000,
    Default = config.espPlayerDistance,
    Increment = 50,
    Suffix = " studs",
    VisibleWhen = "ESPEnable_1",
    Callback = function(v)
        config.espPlayerDistance = v
    end
})

--========= WALL ESP (ZOMBIE) =========--
local WallSection = visualTab:AddSection("Wall ESP (Zombie)")
WallSection:AddToggle("WallEnable", {
    Text = "Enable Wall ESP",
    Default = wallConfig.wallEnabled,
    Callback = function(v)
        wallConfig.wallEnabled = v
        Walls:setWallEnabled(v, wallConfig)
    end
})

WallSection:AddColorPicker("WallVisibleColor", {
    Text = "Visible Color",
    Default = wallConfig.visibleColor,
    Callback = function(c)
        wallConfig.visibleColor = c
    end
})

WallSection:AddColorPicker("WallHiddenColor", {
    Text = "Hidden Color",
    Default = wallConfig.hiddenColor,
    Callback = function(c)
        wallConfig.hiddenColor = c
    end
})

WallSection:AddSlider("WallTransparency", {
    Text = "Transparency",
    Min = 0, Max = 1,
    Default = wallConfig.BOX_TRANSPARENCY,
    Increment = 0.05,
    Callback = function(v)
        wallConfig.BOX_TRANSPARENCY = v
    end
})