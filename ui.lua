local MarketPlaceService = game:GetService("MarketPlaceService")
local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"

local ui = {
    library = loadstring(game:HttpGet(repo .. "self.library.lua"))(),
    saveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))(),
    window = self.library:CreateWindow({
        Title = "Nozomi HUB",
        Footer = ""..MarketPlaceService:GetProductInfo(game.PlaceId).Name,
        Icon = "",
        NotifySide = "Left"
    }),

    tabs = {}
}

function ui:addTab(name:string, icon:string)
    local newTab = self.window:AddTab(name, user)
    table.insert(self.tabs, newTab)
    self.tabs[name] = newTab

    return newTab
end 


--// Default Tabs : Settings
local UI_SETTINGS_BOX = self:addTab("Settings", "wrench")
	UI_SETTINGS_BOX:AddToggle("KeybindMenuOpen", {
		Default  = self.library.KeybindFrame.Visible,
		Text     = "Open Keybind Menu",
		Callback = function(v) self.library.KeybindFrame.Visible = v end,
	})
	UI_SETTINGS_BOX:AddToggle("ShowCustomCursor", {
		Text     = "Custom Cursor",
		Default  = true,
		Callback = function(v) self.library.ShowCustomCursor = v end,
	})
	UI_SETTINGS_BOX:AddDropdown("NotificationSide", {
		Values   = { "Left", "Right" },
		Default  = "Right",
		Text     = "Notification Side",
		Callback = function(v) self.library:SetNotifySide(v) end,
	})
	UI_SETTINGS_BOX:AddDropdown("DPIDropdown", {
		Values   = { "50%","75%","100%","125%","150%","175%","200%" },
		Default  = "100%",
		Text     = "DPI Scale",
		Callback = function(v)
			v = v:gsub("%%","")
			self.library:SetDPIScale(tonumber(v))
		end,
	})
	UI_SETTINGS_BOX:AddSlider("UICornerSlider", {
		Text     = "Corner Radius",
		Default  = self.library.CornerRadius,
		Min      = 0,
		Max      = 20,
		Rounding = 0,
		Callback = function(v) Window:SetCornerRadius(v) end,
	})
	UI_SETTINGS_BOX:AddDivider()
	UI_SETTINGS_BOX:AddLabel("Menu bind")
		:AddKeyPicker("MenuKeybind", { Default="F3", NoUI=true, Text="Menu keybind" })
	self.library.ToggleKeybind = Options.MenuKeybind

	UI_SETTINGS_BOX:AddButton("Unload", function()

		self.library:Unload()
	end)

