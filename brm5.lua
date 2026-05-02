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
local espServiceModule = loadstring(game:HttpGet(nozomi_repo .. "module/esp_service.lua"))()
KeyLocationService = loadstring(game:HttpGet(nozomi_repo .. "module/zombie_key_location.lua"))()

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
	ESP_NPC = false,

	PLATFORM = {},
	PLATFORM_SPAWNED = false,
	PLATFORM_SPEED = 0.4,
	PLATFORM_TRANSPARENCY = 0.5,
	PLATFORM_MATERIAL = Enum.Material.Plastic,
}


--[[============== PLATFORM FUNCTIONS ==============]]

local moveDir = 0
local moveConn, inputBeganConn, inputEndedConn

local function ToggleMoveablePlatform()
	if moveConn then return end

	inputBeganConn = UIS.InputBegan:Connect(function(i, g)
		if g then return end
		if i.KeyCode == Enum.KeyCode.J then
			moveDir = 1
		elseif i.KeyCode == Enum.KeyCode.K then
			moveDir = -1
		end
	end)

	inputEndedConn = UIS.InputEnded:Connect(function(i)
		if i.KeyCode == Enum.KeyCode.J or i.KeyCode == Enum.KeyCode.K then
			moveDir = 0
		end
	end)

	moveConn = RS.RenderStepped:Connect(function()
		if moveDir ~= 0 then
			for _, part in ipairs(Config.PLATFORM) do
				if part and part.Parent then
					part.Position += Vector3.new(0, Config.PLATFORM_SPEED * moveDir, 0)
				end
			end
		end
	end)
end

local function togglePlatform()
	local hrp = GetRoot()
	if not hrp then
		Library:Notify("Root / HRP tidak ditemukan!", 3)
		return
	end

	local function removePlatform()
		for _, part in ipairs(Config.PLATFORM) do
			if part and part.Parent then part:Destroy() end
		end
		Config.PLATFORM = {}
	end

	local function spawnPlatform()
		for x = 1, 5 do
			for z = 1, 5 do
				local part = Instance.new("Part")
				part.Name = "platform"
				part.Size = Vector3.new(2048, 1, 2048)
				part.Anchored = true
				part.Transparency = Config.PLATFORM_TRANSPARENCY
				part.Material = Config.PLATFORM_MATERIAL
				part.Position = Vector3.new(
					hrp.Position.X + (x - 1) * 2048,
					hrp.Position.Y - 10,
					hrp.Position.Z + (z - 1) * 2048
				)
				part.Parent = workspace
				table.insert(Config.PLATFORM, part)
			end
		end
	end

	if Config.PLATFORM_SPAWNED then
		removePlatform()
		Config.PLATFORM_SPAWNED = false
	else
		spawnPlatform()
		Config.PLATFORM_SPAWNED = true
		ToggleMoveablePlatform()
	end
end



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
			espServiceModule:ToggleESP("zombie", Value)
		end,
	})

	ESP_GROUP_BOX:AddToggle("EspNpc", {
		Text     = "Toggle ESP NPC",
		Tooltip  = "Highlight all NPCs near the player.",
		Default  = Config.ESP_NPC,
		Callback = function(Value)
			Config.ESP_NPC = Value
			espServiceModule:ToggleESP("npc", Value)
		end,
	})

	ESP_GROUP_BOX:AddToggle("EspPlayer", {
		Text     = "Toggle ESP Player",
		Tooltip  = "Highlight all players.",
		Default  = Config.ESP_PLAYER,
		Callback = function(Value)
			Config.ESP_PLAYER = Value
			espServiceModule:ToggleESP("player", Value)
		end,
	})
--
local PLATFORM_BOX = Tabs.Main:AddRightGroupbox("Moveable Platform", "move-horizontal")
	PLATFORM_BOX:AddToggle("SpawnPlatform", {
		Text     = "Spawn Platform",
		Tooltip  = "Tekan J untuk naik, K untuk turun.",
		Default  = Config.PLATFORM_SPAWNED,
		Callback = function(Value)
			togglePlatform()
		end,
	})

	PLATFORM_BOX:AddSlider("PlatformSpeedSlider", {
		Text     = "Platform Speed",
		Default  = Config.PLATFORM_SPEED,
		Min      = 0.1,
		Max      = 2.0,
		Rounding = 1,
		Callback = function(Value)
			Config.PLATFORM_SPEED = Value
		end,
	})

	PLATFORM_BOX:AddSlider("PlatformTransparencySlider", {
		Text     = "Platform Transparency",
		Default  = Config.PLATFORM_TRANSPARENCY,
		Min      = 0,
		Max      = 1.0,
		Rounding = 1,
		Callback = function(Value)
			Config.PLATFORM_TRANSPARENCY = Value
			for _, part in ipairs(Config.PLATFORM) do
				if part and part.Parent then
					part.Transparency = Value
				end
			end
		end,
	})

	PLATFORM_BOX:AddDropdown("PlatformMaterial", {
		Text     = "Platform Material",
		Values   = var.MATERIAL_LIST,
		Default  = "SmoothPlastic",
		Tooltip  = "Ganti material platform.",
		Callback = function(Value)
			local mat = Enum.Material[Value]
			if mat then
				Config.PLATFORM_MATERIAL = mat
				for _, part in ipairs(Config.PLATFORM) do
					if part and part.Parent then
						part.Material = mat
					end
				end
			end
		end,
	})
--

--[[============== MAP TAB ==============]]
local MAP_BOX = Tabs.Map:AddLeftGroupbox("Key Location", "map-pin")
	local keyLocationSelected = {}
	local function GetDropdownList()
		local list = KeyLocationService:GetAllKeyName()
		table.insert(list, 1, "All") -- taruh paling atas
		return list
	end

	MAP_BOX:AddDropdown("KeyLocationDropdown", {
		Text = "Select Key Location",
		Values = GetDropdownList(),
		Multi = true,
		Callback = function(val)
			keyLocationSelected = {}

			if val["Select All"] then
				local allKeys = KeyLocationService:GetAllKeyName()
				local newVal = { All = true }
				for _, name in ipairs(allKeys) do
					newVal[name] = true
					table.insert(keyLocationSelected, name)
				end
				Options.KeyLocationDropdown:SetValue(newVal)
				return
			end

			for name, state in pairs(val) do
				if state and name ~= "All" then
					table.insert(keyLocationSelected, name)
				end
			end
		end
	})
	MAP_BOX:AddToggle("ShowMarker", {
		Text = "Show Marker",
		Callback = function(v)
			if v then
				KeyLocationService:ShowLocations(keyLocationSelected)
			else
				KeyLocationService:ClearMarkers()
			end
		end
	})
	MAP_BOX:AddButton("Clear All Markers", function()
		KeyLocationService:ClearMarkers()
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
