--[[============== SERVICES/MODULES/VARIABLES ==============]]
-- SERVICES
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

-- MODULE
local obsidian_repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local nozomi_repo = "https://raw.githubusercontent.com/theofitzgerald/Nozomi-HUB/refs/heads/main/BRM5/"
local Library = loadstring(game:HttpGet(obsidian_repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(obsidian_repo .. "addons/ThemeManager.lua"))()
local var = loadstring(game:HttpGet(nozomi_repo .. "Variable.lua"))()
local rObjectModule = loadstring(game:HttpGet(nozomi_repo .. "module/zombie_remove_object.lua"))()
local ESPModule = loadstring(game:HttpGet(nozomi_repo .. "module/esp_service.lua"))()
local KeyLocationModule = loadstring(game:HttpGet(nozomi_repo .. "module/zombie_key_location.lua"))()
local MoveablePartModule = loadstring(game:HttpGet(nozomi_repo .. "module/moveable_part.lua"))()
--local LogsUIModule = loadstring(game:HttpGet(nozomi_repo .. "module/logs_ui.lua"))()

-- SETTINGS OR VARIABLES
local Options = Library.Options; local Toggles = Library.Toggles
local Players = game.Players; local Player = game.Players.LocalPlayer
--[[============== SANITY CHECK ==============]]
local function GetGameMode()
	local modes = {
		[4747446334] = "Zombie Mode",
		[3701546109] = "Open World"
	}
	return modes[game.PlaceId] or "Unknown"
end

local function ToggleOnZombie()
	return GetGameMode() == "Zombie Mode"
end

local function GetRoot()
	local wm = player:FindFirstChild("WorldModel")
	if wm then
		local male = wm:FindFirstChild("Male")
		if male and male:FindFirstChild("Root") then
			return male.Root
		else
			return wm.WorldModel and wm.WorldModel.Model and wm.WorldModel.Model.Root
		end
	end
end

local function GetRootPos()
	local isFPS = workspace.Camera:FindFirstChild("WorldModel")
	if isFPS then
		return workspace.Camera.WorldModel.Model.Root.Position
	else
		return player.WorldModel.WorldModel.Model.Root.Position
	end
end

local Window = Library:CreateWindow({
	Title = "Nozomi HUB",
	Footer = "version: 1.3a | Map: " .. GetGameMode(),
	NotifySide = "Right",
	Theme = "Dark" -- Many libraries offer presets like "Dark", "Light", or "Midnight"
})

--[[============== CONFIGURATION ==============]]

local Config = {
	ESP_ZOMBIE = false,
	ESP_PLAYER = false,
	ESP_PLAYER_LABEL = false,
	ESP_PLAYER_LABEL_DISTANCE = 1000,
	ESP_NPC = false,

	-- PLATFORM
	PLATFORM_SHOW = false,
	PLATFORM_SPEED = 0.4,
	PLATFORM_TRANSPARENCY = 0.4,
	PLATFORM_MATERIAL = Enum.Material.Asphalt
}

--[[LogsUIModule:Set("ESP ZOMBIE", Config.ESP_ZOMBIE)
LogsUIModule:Set("ESP PLAYER", Config.ESP_PLAYER)
LogsUIModule:Set("ESP NPC", Config.ESP_NPC)
LogsUIModule:Set("PLATFORM", Config.PLATFORM_SHOW)]]


--[[============== ASIGN MODULE DATA ==============]]
MoveablePartModule:AssignAllConfig(Config)

--[[============== REGISTERED TABS ==============]]
local Tabs = {
	Main     = Window:AddTab("Main", "user"),
	Map      = Window:AddTab("Map", "map-pin"),
	Settings = Window:AddTab("Settings", "settings"),
}

--[[============== MAIN TAB ==============]]
local INFO_GROUP_BOX = Tabs.Main:AddLeftGroupbox("INFORMATION", "info")
	local timeLabel = INFO_GROUP_BOX:AddLabel("Time: 00:00:00")
	Lighting:GetPropertyChangedSignal("TimeOfDay"):Connect(function()
		timeLabel:SetText("Time: " .. Lighting.TimeOfDay)
	end)

	if GetGameMode() == "Zombie Mode" then
		INFO_GROUP_BOX:AddLabel("Exfil: 18:00 - 06:00")
	end
--
local ESP_GROUP_BOX = Tabs.Main:AddLeftGroupbox("ESP", "user")
	ESP_GROUP_BOX:AddToggle("EspZombie", {
		Text     = "Toggle ESP Zombie",
		Tooltip  = "Highlight all zombies.",
		Default  = Config.ESP_ZOMBIE,
		Visible  = ToggleOnZombie(),
		Callback = function(Value)
			Config.ESP_ZOMBIE = Value
			ESPModule:ToggleESP("zombie", Value)
			--LogsUIModule:Set("ESP ZOMBIE", Value)
		end,
	})

	ESP_GROUP_BOX:AddToggle("EspNpc", {
		Text     = "Toggle ESP NPC",
		Tooltip  = "Highlight all NPCs near the player.",
		Default  = Config.ESP_NPC,
		Callback = function(Value)
			--Config.ESP_NPC = Value
			ESPModule:ToggleESP("npc", Value)
			--LogsUIModule:Set("ESP NPC", Value)
		end,
	})
	ESP_GROUP_BOX:AddDivider()
	ESP_GROUP_BOX:AddToggle("EspPlayer", {
		Text     = "Toggle ESP Player",
		Tooltip  = "Highlight all players.",
		Default  = Config.ESP_PLAYER,
		Callback = function(Value)
			Config.ESP_PLAYER = Value
			ESPModule:ToggleESP("player", Value)
			--LogsUIModule:Set("ESP PLAYER", Value)
		end,
	})

	ESP_GROUP_BOX:AddToggle("EspPlayer2", {
		Text     = "Show Label",
		Tooltip  = "Show billboard label to all player.",
		Default  = Config.ESP_PLAYER_LABEL,
		Callback = function(Value)
			Config.ESP_PLAYER_LABEL = Value
			ESPModule:SetPlayerMarker(Value)
		end,
	})

	ESP_GROUP_BOX:AddSlider("PlatformSpeedSlider", {
		Text     = "Distance",
		Default  = Config.ESP_PLAYER_LABEL_DISTANCE,
		Min      = 100,
		Max      = 2000,
		Rounding = 0,
		Callback = function(Value)
			ESPModule:SetMaxDistance(Value)
		end,
	})	
--
local PLATFORM_BOX = Tabs.Main:AddRightGroupbox("Moveable Platform", "move-horizontal")
	PLATFORM_BOX:AddToggle("SpawnPlatform", {
		Text     = "Spawn Platform",
		Tooltip  = "Tekan J untuk naik, K untuk turun.",
		Default  = Config.PLATFORM_SHOW,
		Callback = function(Value)
			MoveablePartModule:setValue("spawn", Value)
			--LogsUIModule:Set("PLATFORM", Value)
		end,
	})

	PLATFORM_BOX:AddSlider("PlatformSpeedSlider", {
		Text     = "Platform Speed",
		Default  = Config.PLATFORM_SPEED,
		Min      = 0.1,
		Max      = 2.0,
		Rounding = 1,
		Callback = function(Value)
			MoveablePartModule:setValue("speed", Value)
		end,
	})

	PLATFORM_BOX:AddSlider("PlatformTransparencySlider", {
		Text     = "Platform Transparency",
		Default  = Config.PLATFORM_TRANSPARENCY,
		Min      = 0,
		Max      = 1.0,
		Rounding = 1,
		Callback = function(Value)
			MoveablePartModule:setValue("transparency", Value)
		end,
	})

	PLATFORM_BOX:AddDropdown("PlatformMaterial", {
		Text     = "Platform Material",
		Values   = var.MATERIAL_LIST,
		Default = Config.PLATFORM_MATERIAL.Name,
		Tooltip  = "Ganti material platform.",
		Callback = function(Value)
			local mat = Enum.Material[Value]
			if mat then
				MoveablePartModule:setValue("material", mat)
			end
		end,
	})
--

--[[============== MAP TAB ==============]]
local MAP_BOX = Tabs.Map:AddLeftGroupbox("Key Location", "map-pin")
	local keyLocationSelected = {}
	local function GetDropdownList()
		local list = KeyLocationModule:GetAllKeyName()
		table.insert(list, 1, "Select All") -- taruh paling atas
		return list
	end

	MAP_BOX:AddDropdown("KeyLocationDropdown", {
		Text = "Select Key Location",
		Values = GetDropdownList(),
		Multi = true,
		Callback = function(val)
			keyLocationSelected = {}

			if val["Select All"] then
				local allKeys = KeyLocationModule:GetAllKeyName()
				local newVal = { All = true }
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
				KeyLocationModule:ShowLocations(keyLocationSelected)
			else
				KeyLocationModule:ClearMarkers()
			end
		end
	})
	MAP_BOX:AddButton("Clear All Markers", function()
		KeyLocationModule:ClearMarkers()
		Options.KeyLocationDropdown:SetValue(nil)
	end)
--
--[[============== SETTINGS TAB ==============]]

local MENU_GROUP_BOX = Tabs.Settings:AddLeftGroupbox("Menu", "wrench")
	MENU_GROUP_BOX:AddToggle("KeybindMenuOpen", {
		Default  = Library.KeybindFrame.Visible,
		Text     = "Open Keybind Menu",
		Callback = function(value)
			Library.KeybindFrame.Visible = value
		end,
	})

	MENU_GROUP_BOX:AddToggle("ShowCustomCursor", {
		Text     = "Custom Cursor",
		Default  = true,
		Callback = function(Value)
			Library.ShowCustomCursor = Value
		end,
	})

	MENU_GROUP_BOX:AddDropdown("NotificationSide", {
		Values   = { "Left", "Right" },
		Default  = "Right",
		Text     = "Notification Side",
		Callback = function(Value)
			Library:SetNotifySide(Value)
		end,
	})

	MENU_GROUP_BOX:AddDropdown("DPIDropdown", {
		Values   = { "50%", "75%", "100%", "125%", "150%", "175%", "200%" },
		Default  = "100%",
		Text     = "DPI Scale",
		Callback = function(Value)
			Value = Value:gsub("%%", "")
			Library:SetDPIScale(tonumber(Value))
		end,
	})

	MENU_GROUP_BOX:AddSlider("UICornerSlider", {
		Text     = "Corner Radius",
		Default  = Library.CornerRadius,
		Min      = 0,
		Max      = 20,
		Rounding = 0,
		Callback = function(value)
			Window:SetCornerRadius(value)
		end,
	})

	MENU_GROUP_BOX:AddDivider()
	MENU_GROUP_BOX:AddLabel("Menu bind")
		:AddKeyPicker("MenuKeybind", { Default = "F3", NoUI = true, Text = "Menu keybind" })

	Library.ToggleKeybind = Options.MenuKeybind

	MENU_GROUP_BOX:AddButton("Unload", function()
		Library:Unload()
	end)
--
