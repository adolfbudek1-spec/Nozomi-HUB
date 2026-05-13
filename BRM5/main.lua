if typeof(clear) == "function" then
    clear()
end

local function geturl(path)
    print("[geturl]", path)

    path = tostring(path):gsub("\\", "/"):gsub("^/", "")
    local url = "https://raw.githubusercontent.com/theofitzgerald/Nozomi-HUB/main/" .. path

    print("[url]", url)
    return url
end

local function loadModule(path)
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

local services = loadModule("services.lua")
local ui = loadModule("ui.lua")
local library = ui.library
local window = ui.window


--======================= [[ MAIN TAB ]] =======================--
local mainTab = ui:addTab("Main", "house")
mainTab:AddLabel("Kontol Kau Pecah")
