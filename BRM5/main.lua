if typeof(clear) == "function" then
    clear()
end

local obsidian_repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local ObsidianLibs       = loadstring(game:HttpGet(obsidian_repo .. "Library.lua"))()
local ThemeManager  = loadstring(game:HttpGet(obsidian_repo .. "addons/ThemeManager.lua"))()
local Window = ObsidianLibs:CreateWindow({
    Title = "Nozomi HUB",
    Footer = "",
    Icon = 95816097006870,
    NotifySide = "Right",
})
local function loadModule(path)
    local function geturl(path)
        path = tostring(path):gsub("\\", "/"):gsub("^/", "")
        local url = "https://raw.githubusercontent.com/theofitzgerald/Nozomi-HUB/main/" .. path
        return url
    end


    local url = geturl(path)

    local ok, src = pcall(game.HttpGet, game, url)
    if not ok then
        warn("[http error]", src, url)
        return
    end

    local fn, err = loadstring(src)
    if not fn then
        warn("[compile error]", err)
        print(src:sub(1, 300))
        return
    end

    local ok2, res = pcall(fn)
    if not ok2 then
        warn("[runtime error]", res)
    end

    print("[loaded]", path)
    return res
end

local options = ObsidianLibs.Options
local toggles = ObsidianLibs.Toggles
local services = loadModule("services.lua")

local TABS = {}
TABS.MAIN = Window:AddTab("main", "house")
TABS.SETTINGS = Window:AddTab("settings", "wrench")

local settingsMenu = TABS.SETTINGS:AddLeftGroupbox("Menu", "wrench")
	settingsMenu:AddToggle("KeybindMenuOpen", {
		Default  = ObsidianLibs.KeybindFrame.Visible,
		Text     = "Open Keybind Menu",
		Callback = function(v) ObsidianLibs.KeybindFrame.Visible = v end,
	})
	settingsMenu:AddToggle("ShowCustomCursor", {
		Text     = "Custom Cursor",
		Default  = true,
		Callback = function(v) ObsidianLibs.ShowCustomCursor = v end,
	})
	settingsMenu:AddDropdown("NotificationSide", {
		Values   = { "Left", "Right" },
		Default  = "Right",
		Text     = "Notification Side",
		Callback = function(v) ObsidianLibs:SetNotifySide(v) end,
	})
	settingsMenu:AddDropdown("DPIDropdown", {
		Values   = { "50%","75%","100%","125%","150%","175%","200%" },
		Default  = "100%",
		Text     = "DPI Scale",
		Callback = function(v)
			v = v:gsub("%%","")
			ObsidianLibs:SetDPIScale(tonumber(v))
		end,
	})
	settingsMenu:AddSlider("UICornerSlider", {
		Text     = "Corner Radius",
		Default  = ObsidianLibs.CornerRadius,
		Min      = 0,
		Max      = 20,
		Rounding = 0,
		Callback = function(v) Window:SetCornerRadius(v) end,
	})
	settingsMenu:AddDivider()
	settingsMenu:AddLabel("Menu bind")
		:AddKeyPicker("MenuKeybind", { Default="F3", NoUI=true, Text="Menu keybind" })
	ObsidianLibs.ToggleKeybind = options.MenuKeybind

	settingsMenu:AddButton("Unload", function()
		ObsidianLibs:Unload()
	end)
