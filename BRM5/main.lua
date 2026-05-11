--[[============== LIBRARY (Obsidian) ==============]]
local obsidian_repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library       = loadstring(game:HttpGet(obsidian_repo .. "Library.lua"))()
local ThemeManager  = loadstring(game:HttpGet(obsidian_repo .. "addons/ThemeManager.lua"))()

local Options = Library.Options
local Toggles = Library.Toggles
local Window = Library:CreateWindow({
	Title      = "Nozomi HUB",
	Footer     = "version: 1.5 | Map: " .. GetGameMode(),
	NotifySide = "Right",
	Theme      = "Dark"
})

--[[============== MODULAR ==============]]
local GITHUB_BASE = "https://raw.githubusercontent.com/theofitzgerald/Nozomi-HUB/main/BRM5/modules/" 
--[[============== CONNECTION TRACKER ==============]]
local Connections = {}
local function Track(conn)
	table.insert(Connections, conn)
	return conn
end

