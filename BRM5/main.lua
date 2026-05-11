--[[============== LIBRARY (Obsidian) ==============]]
local obsidian_repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library       = loadstring(game:HttpGet(obsidian_repo .. "Library.lua"))()
local ThemeManager  = loadstring(game:HttpGet(obsidian_repo .. "addons/ThemeManager.lua"))()

local Options = Library.Options
local Toggles = Library.Toggles
--[[local Window = Library:CreateWindow({
	Title      = "Nozomi HUB",
	Footer     = "version: 1.5 | Map: " .. GetGameMode(),
	NotifySide = "Right",
	Theme      = "Dark"
})]]

--[[============== MODULAR ==============]]
local GITHUB_BASE = "https://raw.githubusercontent.com/theofitzgerald/Nozomi-HUB/main/BRM5/modules/" 
local VERSION = "v1"
local CACHE_BUSTER = VERSION .. "-" .. tostring(os.time())

local function loadModule(name)
    local url = GITHUB_BASE .. name .. ".lua?v=" .. CACHE_BUSTER

    print("[LOADING]", name)
    print(url)

    local success, response = pcall(function()
        return game:HttpGet(url)
    end)

    if not success then
        error("Failed download module: " .. name)
    end

    local compiled, compileError = loadstring(response)

    if not compiled then
        error("Compile error in " .. name .. ": " .. tostring(compileError))
    end

    local ok, result = pcall(compiled)

    if not ok then
        error("Runtime error in " .. name .. ": " .. tostring(result))
    end

    return result
end

local Services     = loadModule("services")
local Config       = loadModule("config")
local ESP          = loadModule("esp")
local MovingPart   = loadModule("movingpart")
local SpeedHack    = loadModule("speedhack")
local Checkpoint   = loadModule("checkpoint")
local Variable     = loadModule("variable")
local MapEditor    = loadModule("mapeditor")

print("All modules loaded!")
--[[============== CONNECTION TRACKER ==============]]
local Connections = {}
local function Track(conn)
	table.insert(Connections, conn)
	return conn
end

