--[[
	╔══════════════════════════════════════════════════════╗
	║               NOZOMI HUB  –  main.lua               ║
	║           Bootstrap / Initializer only              ║
	╚══════════════════════════════════════════════════════╝

	Urutan:
	  1. Load services
	  2. Load Obsidian Library
	  3. Load semua module via loadstring(HttpGet)
	  4. Buat shared context (ctx)
	  5. Init semua module
	  6. Buat Window + Tabs + UI
	  7. Hubungkan UI ke module
]]

-- ── GitHub raw base URL ────────────────────────────────────────────────────────
local REPO_BASE    = "https://raw.githubusercontent.com/YOUR_USERNAME/BRM5/main/"
local obsidian_repo= "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"

-- ── Helper load module ────────────────────────────────────────────────────────
local function LoadModule(path)
	return loadstring(game:HttpGet(REPO_BASE .. path))()
end

--[[============== 1. SERVICES ==============]]
local Services = LoadModule("modules/services.lua")
local UIS      = Services.UIS
local RS       = Services.RS
local Lighting = Services.Lighting
local Players  = Services.Players

local Player    = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

--[[============== 2. OBSIDIAN LIBRARY ==============]]
local Library      = loadstring(game:HttpGet(obsidian_repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(obsidian_repo .. "addons/ThemeManager.lua"))()
local Options      = Library.Options
local Toggles      = Library.Toggles

--[[============== 3. LOAD MODULES ==============]]
local Config      = LoadModule("modules/config.lua")
local Variables   = LoadModule("modules/variable.lua")
local Character   = LoadModule("modules/character.lua")
local ESP         = LoadModule("modules/esp.lua")
local SpeedHack   = LoadModule("modules/speedhack.lua")
local Platform    = LoadModule("modules/platform.lua")
local RemoveWorld = LoadModule("modules/removeworld.lua")
local Checkpoint  = LoadModule("modules/checkpoint.lua")
local MovingPart  = LoadModule("modules/movingpart.lua")
local MapEditor   = LoadModule("modules/mapeditor.lua")

--[[============== 4. CONNECTION TRACKER ==============]]
local Connections = {}
local function Track(conn)
	table.insert(Connections, conn)
	return conn
end

--[[============== 5. DEBRIS FOLDER ==============]]
local nozomiDebris = workspace:FindFirstChild("_nozomiDebris")
if not nozomiDebris then
	nozomiDebris        = Instance.new("Folder")
	nozomiDebris.Name   = "_nozomiDebris"
	nozomiDebris.Parent = workspace
end

-- SafePart (invisible floor, anti-fall)
local function CreateSafePart()
	if nozomiDebris:FindFirstChild("_safePart") then return end
	local SIZE = 2048; local RANGE = 16384
	for x = -RANGE, RANGE, SIZE do
		for z = -RANGE, RANGE, SIZE do
			local p           = Instance.new("Part")
			p.Name            = "_safePart"
			p.Size            = Vector3.new(SIZE, 1, SIZE)
			p.Position        = Vector3.new(x, 8, z)
			p.Anchored        = true
			p.CanCollide      = false
			p.Transparency    = 1
			p.Parent          = nozomiDebris
		end
	end
end
CreateSafePart()

--[[============== 6. HELPER: GAME MODE ==============]]
local function GetGameMode()
	return Variables.GAME_MODES[game.PlaceId] or "Unknown"
end
local function IsZombieMode()
	return GetGameMode() == "Zombie Mode"
end

--[[============== 7. WINDOW ==============]]
local Window = Library:CreateWindow({
	Title      = "Nozomi HUB",
	Footer     = "version: 2.0 | Map: " .. GetGameMode(),
	NotifySide = "Right",
	Theme      = "Dark",
})

local Tabs = {
	Main     = Window:AddTab("Main",     "user"),
	Map      = Window:AddTab("Map",      "map-pin"),
	Settings = Window:AddTab("Settings", "settings"),
}

--[[============== 8. SHARED CONTEXT ==============]]
local ctx = {
	Services      = Services,
	Config        = Config,
	Variables     = Variables,
	Character     = Character,
	Window        = Window,
	Tabs          = Tabs,
	Library       = Library,
	ThemeManager  = ThemeManager,
	Options       = Options,
	Toggles       = Toggles,
	Track         = Track,
	Connections   = Connections,
	Player        = Player,
	PlayerGui     = PlayerGui,
	DebrisFolder  = nozomiDebris,
}

--[[============== 9. INIT MODULES ==============]]
Character:Init(ctx)
ESP:Init(ctx)
SpeedHack:Init(ctx)
Platform:Init(ctx)
RemoveWorld:Init(ctx)
Checkpoint:Init(ctx)
MovingPart:Init(ctx)
MapEditor:Init(ctx)

--[[============== 10. UI — MAIN TAB ==============]]

-- ── Information ──────────────────────────────────────────────────────────────
local INFO_BOX  = Tabs.Main:AddLeftGroupbox("INFORMATION", "info")
local timeLabel = INFO_BOX:AddLabel("Time: 00:00:00")
Track(Lighting:GetPropertyChangedSignal("TimeOfDay"):Connect(function()
	timeLabel:SetText("Time: " .. Lighting.TimeOfDay)
end))
if IsZombieMode() then INFO_BOX:AddLabel("Exfil: 18:00 - 06:00") end

-- ── ESP ───────────────────────────────────────────────────────────────────────
local ESP_BOX = Tabs.Main:AddLeftGroupbox("ESP", "user")

ESP_BOX:AddToggle("EspZombie", {
	Text     = "Toggle ESP Zombie",
	Tooltip  = "Highlight zombie (merah statis).",
	Default  = false,
	Visible  = IsZombieMode(),
	Callback = function(v) ESP:EnableZombie(v) end,
})

ESP_BOX:AddToggle("EspNpc", {
	Text     = "Toggle ESP NPC",
	Tooltip  = "Highlight NPC (biru).",
	Default  = false,
	Callback = function(v) ESP:EnableNPC(v) end,
})

ESP_BOX:AddToggle("EspPlayer", {
	Text     = "Toggle ESP Player",
	Tooltip  = "Hijau = terlihat | Merah = terhalang tembok.",
	Default  = false,
	Callback = function(v) ESP:EnablePlayer(v) end,
})

ESP_BOX:AddToggle("EspPlayerLabel", {
	Text     = "Show Label",
	Tooltip  = "Billboard label nama + jarak ke player.",
	Default  = false,
	Callback = function(v) ESP:SetPlayerMarker(v) end,
})

ESP_BOX:AddSlider("EspLabelDistance", {
	Text     = "Label Distance",
	Default  = 1000,
	Min      = 1,
	Max      = 9999,
	Rounding = 0,
	Callback = function(v) ESP:SetMaxDistance(v) end,
})

ESP_BOX:AddDivider()
ESP_BOX:AddLabel("Player Highlight Color")

ESP_BOX:AddColorPicker("EspPlayerFillColor", {
	Text    = "Fill Color",
	Default = Config.ESP_PLAYER_FILL_COLOR,
	Callback = function(v) ESP:SetPlayerFillColor(v) end,
})

ESP_BOX:AddColorPicker("EspPlayerOutlineColor", {
	Text    = "Outline Color",
	Default = Config.ESP_PLAYER_OUTLINE_COLOR,
	Callback = function(v) ESP:SetPlayerOutlineColor(v) end,
})

ESP_BOX:AddSlider("EspPlayerFillTrans", {
	Text     = "Fill Transparency",
	Default  = Config.ESP_PLAYER_FILL_TRANS,
	Min      = 0,
	Max      = 1,
	Rounding = 1,
	Callback = function(v) ESP:SetPlayerFillTransparency(v) end,
})

ESP_BOX:AddSlider("EspPlayerOutlineTrans", {
	Text     = "Outline Transparency",
	Default  = Config.ESP_PLAYER_OUTLINE_TRANS,
	Min      = 0,
	Max      = 1,
	Rounding = 1,
	Callback = function(v) ESP:SetPlayerOutlineTransparency(v) end,
})

ESP_BOX:AddColorPicker("EspLabelColor", {
	Text    = "Label Color",
	Default = Config.ESP_PLAYER_LABEL_COLOR,
	Callback = function(v) ESP:SetLabelColor(v) end,
})

ESP_BOX:AddSlider("EspLabelTrans", {
	Text     = "Label Transparency",
	Default  = Config.ESP_PLAYER_LABEL_TRANS,
	Min      = 0,
	Max      = 1,
	Rounding = 1,
	Callback = function(v) ESP:SetLabelTransparency(v) end,
})

-- ── Remove Object ─────────────────────────────────────────────────────────────
local REMOVE_BOX = Tabs.Main:AddLeftGroupbox("Remove Object", "trash")
REMOVE_BOX:AddToggle("RemoveObjectToggle", {
	Text     = "Remove Objects  [F6]",
	Tooltip  = "Sembunyikan First / Last / Light / FULL / Unloaded.",
	Default  = false,
	Callback = function(v)
		if v then RemoveWorld:Enable() else RemoveWorld:Disable() end
	end,
})

-- F6 keybind untuk Remove Object
Track(UIS.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.F6 then
		local newVal = not RemoveWorld:IsEnabled()
		if newVal then RemoveWorld:Enable() else RemoveWorld:Disable() end
		if Toggles.RemoveObjectToggle then
			Toggles.RemoveObjectToggle:SetValue(newVal)
		end
	end
end))

-- ── Moveable Platform ─────────────────────────────────────────────────────────
local PLATFORM_BOX = Tabs.Main:AddRightGroupbox("Moveable Platform  [F1]", "move-horizontal")

PLATFORM_BOX:AddToggle("SpawnPlatform", {
	Text    = "Spawn Platform",
	Tooltip = "2 platform besar. J=naik  K=turun  F1=toggle.",
	Default = false,
	Callback = function(v) Platform:SetEnabled(v) end,
})

PLATFORM_BOX:AddSlider("PlatformSpeedSlider", {
	Text     = "Platform Speed",
	Default  = Config.PLATFORM_SPEED,
	Min      = 0.1,
	Max      = 2.0,
	Rounding = 1,
	Callback = function(v) Platform:SetSpeed(v) end,
})

PLATFORM_BOX:AddSlider("PlatformTransparencySlider", {
	Text     = "Platform Transparency",
	Default  = Config.PLATFORM_TRANSPARENCY,
	Min      = 0,
	Max      = 1.0,
	Rounding = 1,
	Callback = function(v) Platform:SetTransparency(v) end,
})

PLATFORM_BOX:AddDropdown("PlatformMaterial", {
	Text     = "Platform Material",
	Values   = Variables.MATERIAL_LIST,
	Default  = "Asphalt",
	Tooltip  = "Ganti material platform.",
	Callback = function(v)
		local mat = Enum.Material[v]
		if mat then Platform:SetMaterial(mat) end
	end,
})

-- ── Speed System ──────────────────────────────────────────────────────────────
local SPEED_BOX = Tabs.Main:AddRightGroupbox("Speed System", "zap")

SPEED_BOX:AddToggle("SpeedToggle", {
	Text     = "Enable Speed  [F5]",
	Tooltip  = "Toggle F5. Tahan Shift saat aktif.",
	Default  = false,
	Callback = function(v) SpeedHack:Toggle(v) end,
})

--[[============== 11. UI — MAP TAB ==============]]
local MAP_BOX = Tabs.Map:AddLeftGroupbox("Key Location", "map-pin")

local keyLocationSelected = {}

local function GetDropdownList()
	local list = Checkpoint:GetAllKeyNames()
	table.insert(list, 1, "Select All")
	return list
end

MAP_BOX:AddDropdown("KeyLocationDropdown", {
	Text     = "Select Key Location",
	Values   = GetDropdownList(),
	Multi    = true,
	Callback = function(val)
		keyLocationSelected = {}
		if val["Select All"] then
			local allKeys = Checkpoint:GetAllKeyNames()
			local newVal  = {}
			for _, name in ipairs(allKeys) do
				newVal[name] = true
				table.insert(keyLocationSelected, name)
			end
			Options.KeyLocationDropdown:SetValue(newVal)
			return
		end
		for name, state in pairs(val) do
			if state and name ~= "Select All" then
				table.insert(keyLocationSelected, name)
			end
		end
	end
})

MAP_BOX:AddToggle("ShowMarker", {
	Text = "Show Marker",
	Callback = function(v)
		if v then
			Checkpoint:ShowLocations(keyLocationSelected)
		else
			Checkpoint:ClearMarkers()
		end
	end
})

MAP_BOX:AddButton("Clear All Markers", function()
	Checkpoint:ClearMarkers()
	Options.KeyLocationDropdown:SetValue(nil)
end)

--[[============== 12. UI — SETTINGS TAB ==============]]
local MENU_BOX = Tabs.Settings:AddLeftGroupbox("Menu", "wrench")

MENU_BOX:AddToggle("KeybindMenuOpen", {
	Default  = Library.KeybindFrame.Visible,
	Text     = "Open Keybind Menu",
	Callback = function(v) Library.KeybindFrame.Visible = v end,
})

MENU_BOX:AddToggle("ShowCustomCursor", {
	Text     = "Custom Cursor",
	Default  = true,
	Callback = function(v) Library.ShowCustomCursor = v end,
})

MENU_BOX:AddDropdown("NotificationSide", {
	Values   = { "Left", "Right" },
	Default  = "Right",
	Text     = "Notification Side",
	Callback = function(v) Library:SetNotifySide(v) end,
})

MENU_BOX:AddDropdown("DPIDropdown", {
	Values   = { "50%","75%","100%","125%","150%","175%","200%" },
	Default  = "100%",
	Text     = "DPI Scale",
	Callback = function(v)
		v = v:gsub("%%", "")
		Library:SetDPIScale(tonumber(v))
	end,
})

MENU_BOX:AddSlider("UICornerSlider", {
	Text     = "Corner Radius",
	Default  = Library.CornerRadius,
	Min      = 0,
	Max      = 20,
	Rounding = 0,
	Callback = function(v) Window:SetCornerRadius(v) end,
})

MENU_BOX:AddDivider()
MENU_BOX:AddLabel("Menu bind")
	:AddKeyPicker("MenuKeybind", { Default = "F3", NoUI = true, Text = "Menu keybind" })
Library.ToggleKeybind = Options.MenuKeybind

--[[============== 13. UNLOAD ==============]]
MENU_BOX:AddButton("Unload", function()
	-- 1. Disconnect semua connection di main.lua
	for _, conn in pairs(Connections) do
		pcall(function() conn:Disconnect() end)
	end
	Connections = {}

	-- 2. Destroy semua module (urutan penting: ESP dulu, lalu yang lain)
	ESP:Destroy()
	SpeedHack:Destroy()
	Platform:Destroy()
	RemoveWorld:Destroy()
	Checkpoint:Destroy()
	MovingPart:Destroy()
	MapEditor:Destroy()

	-- 3. Reset local state
	keyLocationSelected = {}

	-- 4. Unload library
	Library:Unload()
end)
