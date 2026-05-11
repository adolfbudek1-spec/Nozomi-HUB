local function getExecutorName()
	if identifyexecutor then
    	return identifyexecutor()
	elseif getexecutorname then
		return getexecutorname()
	end
	
	return "Unknown"
end

local function GetGameMode()
	local modes = { [4747446334]="Zombie Mode", [3701546109]="Open World" }
	return modes[game.PlaceId] or "Unknown"
end

local function IsZombieMode() 
	return GetGameMode() == "Zombie Mode" 
end

--[[============== LIBRARY (Obsidian) ==============]]
local obsidian_repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library       = loadstring(game:HttpGet(obsidian_repo .. "Library.lua"))()
local ThemeManager  = loadstring(game:HttpGet(obsidian_repo .. "addons/ThemeManager.lua"))()

local Options = Library.Options
local Toggles = Library.Toggles
local Window = Library:CreateWindow({
	Title      = "Nozomi HUB",
	Footer     = "version: 1.5 | Map: " .. GetGameMode().." | Executor: "..getExecutorName(),
	NotifySide = "Right",
	Theme      = "Dark"
})

--[[============== MODULAR ==============]]
local GITHUB_BASE = "https://raw.githubusercontent.com/theofitzgerald/Nozomi-HUB/main/BRM5/modules/" 
local CACHE_BUSTER = "chace_bust-" .. tostring(os.time())

local function loadModule(name)
    local ok, res = pcall(game.HttpGet, game, GITHUB_BASE .. name .. ".lua?v=" .. CACHE_BUSTER)
    if not ok then error("Download failed: "..name) end

    local func, err = loadstring(res)
    if not func then error("Compile failed: "..name.." | "..err) end

    local s, r = pcall(func)
    if not s then error("Runtime failed: "..name.." | "..r) end

    return r
end

local services     = loadModule("services")
local config       = loadModule("config")
local esp          = loadModule("esp")
local movingpart   = loadModule("movingpart")
local speedhack    = loadModule("speedhack")
local checkpoint   = loadModule("checkpoint")
local var     	   = loadModule("variable")
local mapeditor    = loadModule("mapeditor")

--[[============== CONNECTION TRACKER ==============]]
local Connections = {}
local function Track(conn)
	table.insert(Connections, conn)
	return conn
end

--[[========================= [ TABLIST ] =========================]]
local tabs = {}
tabs.main = Window:AddTab("Main", "user")
tabs.settings = Window:AddTab("Settings", "wrench")

--[[ MAIN TAB ]]
local ESP_BOX = tabs.main:AddLeftGroupbox("esp", "eye")
	ESP_BOX:AddToggle("EspZombie", {
		Text     = "Toggle ESP Zombie",
		Default  = config.espZombieEnabled,
		Callback = function(v)
			config.espZombieEnabled = v
		end,
	})

	ESP_BOX:AddToggle("EspNpc", {
		Text     = "Toggle ESP NPC",
		Default  = config.espNpcEnabled,
		Callback = function(v)
			config.espNpcEnabled = v
		end,
	})

	ESP_BOX:AddToggle("EspPlayer", {
		Text     = "Toggle ESP Player",
		Default  = config.espPlayerEnabled,
		Callback = function(v)
			config.espPlayerEnabled = v
		end,
	})
	ESP_BOX:AddToggle("EspPlayer2", {
		Text     = "Show Label",
		Default  = config.espLabelEnabled,
		Callback = function(v)
			config.espLabelEnabled = v
		end,
	})
	ESP_BOX:AddSlider("EspLabelDistance", {
		Text     = "Label Distance",
		Default  = config.espLabelDistance,
		Min      = 100,
		Max      = 10000,
		Rounding = 0,
		Callback = function(v)
			config.espLabelDistance = v
		end,
	})

--[[ SETTINGS TAB ]]
local MENU_BOX = tabs.settings:AddLeftGroupbox("Menu", "wrench")
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
			v = v:gsub("%%","")
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
		:AddKeyPicker("MenuKeybind", { Default="F3", NoUI=true, Text="Menu keybind" })
	Library.ToggleKeybind = Options.MenuKeybind

	MENU_BOX:AddButton("Unload", function()
		print("All Nozomi environments have been reset.")
		Library:Unload()
	end)

