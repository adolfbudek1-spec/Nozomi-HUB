local gameIds = {
    ["Blackhawk rescue mission 5"] = {
        url = "https://raw.githubusercontent.com/theofitzgerald/Nozomi-HUB/main/Script/brm5.lua",
        placeId = {5289429734, 5480112241, 4524359706, 5468388011, 3701546109}
    },
    ["Mount Kicau Mania"] = {
        url = "https://raw.githubusercontent.com/theofitzgerald/Nozomi-HUB/main/Script/mount_kicau_mania.lua",
        placeId = {125698178385948}
    }
}

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local TweenService = game:GetService("TweenService")

local function createLoadingUI()

    local gui = Instance.new("ScreenGui")
    gui.Name = "NozomiLoaderUI"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 999999
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    pcall(function()
        gui.Parent = game:GetService("CoreGui")
    end)

    if not gui.Parent then
        gui.Parent = PlayerGui
    end

    -- MAIN FRAME
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 420, 0, 145)
    frame.Position = UDim2.new(0.5, -210, 0.5, -72)
    frame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    frame.BorderSizePixel = 0
    frame.ZIndex = 10
    frame.Parent = gui

    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = UDim.new(0, 16)
    frameCorner.Parent = frame

    -- ORANGE OUTLINE
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 140, 40)
    stroke.Thickness = 2
    stroke.Transparency = 0
    stroke.Parent = frame

    -- GLOW
    local glow = Instance.new("ImageLabel")
    glow.Name = "Glow"
    glow.AnchorPoint = Vector2.new(0.5, 0.5)
    glow.Position = UDim2.new(0.5, 0, 0.5, 0)
    glow.Size = UDim2.new(1, 60, 1, 60)
    glow.BackgroundTransparency = 1
    glow.Image = "rbxassetid://5028857084"
    glow.ImageTransparency = 0.25
    glow.ImageColor3 = Color3.fromRGB(255, 120, 35)
    glow.ScaleType = Enum.ScaleType.Slice
    glow.SliceCenter = Rect.new(24, 24, 276, 276)
    glow.ZIndex = 1
    glow.Parent = frame

    -- TITLE
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -30, 0, 35)
    title.Position = UDim2.new(0, 15, 0, 12)
    title.BackgroundTransparency = 1
    title.Text = "NOZOMI HUB"
    title.TextColor3 = Color3.fromRGB(255, 170, 70)
    title.TextSize = 24
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 15
    title.Parent = frame

    -- SUBTITLE
    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(1, -30, 0, 18)
    subtitle.Position = UDim2.new(0, 15, 0, 42)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "Universal Script Loader"
    subtitle.TextColor3 = Color3.fromRGB(170, 170, 170)
    subtitle.TextSize = 13
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextXAlignment = Enum.TextXAlignment.Left
    subtitle.ZIndex = 15
    subtitle.Parent = frame

    -- STATUS
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, -30, 0, 24)
    status.Position = UDim2.new(0, 15, 0, 78)
    status.BackgroundTransparency = 1
    status.Text = "Starting..."
    status.TextColor3 = Color3.fromRGB(230, 230, 230)
    status.TextSize = 16
    status.Font = Enum.Font.GothamMedium
    status.TextXAlignment = Enum.TextXAlignment.Left
    status.ZIndex = 15
    status.Parent = frame

    -- PROGRESS BACKGROUND
    local barBg = Instance.new("Frame")
    barBg.Size = UDim2.new(1, -30, 0, 10)
    barBg.Position = UDim2.new(0, 15, 1, -28)
    barBg.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    barBg.BorderSizePixel = 0
    barBg.ZIndex = 12
    barBg.Parent = frame

    local barBgCorner = Instance.new("UICorner")
    barBgCorner.CornerRadius = UDim.new(1, 0)
    barBgCorner.Parent = barBg

    -- PROGRESS BAR
    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0, 0, 1, 0)
    bar.BackgroundColor3 = Color3.fromRGB(255, 140, 40)
    bar.BorderSizePixel = 0
    bar.ZIndex = 13
    bar.Parent = barBg

    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(1, 0)
    barCorner.Parent = bar

    -- BAR OUTLINE
    local barStroke = Instance.new("UIStroke")
    barStroke.Color = Color3.fromRGB(255, 180, 90)
    barStroke.Thickness = 1
    barStroke.Parent = bar

    -- ANIMASI GLOW
    task.spawn(function()
        while gui.Parent do
            TweenService:Create(
                glow,
                TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                {
                    ImageTransparency = 0.45
                }
            ):Play()

            task.wait(1.2)

            TweenService:Create(
                glow,
                TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                {
                    ImageTransparency = 0.25
                }
            ):Play()

            task.wait(1.2)
        end
    end)

    return gui, status, bar
end
local function setStatus(status, bar, text, progress)
    status.Text = text
    bar:TweenSize(
        UDim2.new(progress, 0, 1, 0),
        Enum.EasingDirection.Out,
        Enum.EasingStyle.Quad,
        0.25,
        true
    )
    task.wait(0.4)
end

local function isPlaceSupported(placeList, currentPlaceId)
    for _, id in ipairs(placeList) do
        if id == currentPlaceId then
            return true
        end
    end
    return false
end

local gui, status, bar = createLoadingUI()

setStatus(status, bar, "Checking game id...", 0.25)

local foundGameName = nil
local foundData = nil

for gameName, data in pairs(gameIds) do
    if isPlaceSupported(data.placeId, game.PlaceId) then
        foundGameName = gameName
        foundData = data
        break
    end
end

if not foundData then
    setStatus(status, bar, "Game not supported.", 1)
    task.wait(2)
    gui:Destroy()
    return
end

setStatus(status, bar, "Load " .. foundGameName .. "...", 0.65)

local success, err = pcall(function()
    local source = game:HttpGet(foundData.url)
    loadstring(source)()
end)

if success then
    setStatus(status, bar, "Load successfully.", 1)
    task.wait(1)
    gui:Destroy()
else
    status.TextColor3 = Color3.fromRGB(255, 90, 90)
    setStatus(status, bar, "Load failed: " .. tostring(err), 1)
    warn("[Nozomi Loader Error]:", err)
    task.wait(3)
    gui:Destroy()
end