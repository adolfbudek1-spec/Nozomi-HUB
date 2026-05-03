local EspService = {}

local ESP_PLAYER = false
local ESP_PLAYER_MARKER = false
local ESP_PLAYER_MAX_DISTANCE = 300

local ESP_NPC = false
local ESP_ZOMBIE = false

local descendantConn
local MarkerConnections = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- ================= ROOT POS =================
local function GetRootPos()
    local cam = workspace.CurrentCamera
    if not cam then return nil end

    local wm = cam:FindFirstChild("WorldModel")
    if wm and wm:FindFirstChild("Model") and wm.Model:FindFirstChild("Root") then
        return wm.Model.Root.Position
    end

    local lp = Players.LocalPlayer
    if lp and lp:FindFirstChild("WorldModel")
        and lp.WorldModel:FindFirstChild("WorldModel")
        and lp.WorldModel.WorldModel:FindFirstChild("Model")
        and lp.WorldModel.WorldModel.Model:FindFirstChild("Root") then
        return lp.WorldModel.WorldModel.Model.Root.Position
    end

    return nil
end

-- ================= COLOR =================
local function GetDistanceColor(dist)
    local maxDist = 500
    local t = math.clamp(dist / maxDist, 0, 1)

    if t < 0.5 then
        local tt = t * 2
        return 255 * tt, 255, 0
    else
        local tt = (t - 0.5) * 2
        return 255, 255 * (1 - tt), 0
    end
end

-- ================= CLEAN =================
local function ClearHighlights(tag)
    for _, v in ipairs(workspace:GetDescendants()) do
        local hl = v:FindFirstChild(tag)
        if hl then hl:Destroy() end
    end
end

local function ClearMarker(tag)
    for male, conn in pairs(MarkerConnections) do
        if conn then conn:Disconnect() end
        if male then
            local ui = male:FindFirstChild(tag)
            if ui then ui:Destroy() end
        end
    end
    table.clear(MarkerConnections)
end

-- ================= HIGHLIGHT =================
local function AddHighlight(target, tag, fillColor, outlineColor, fillTransparency)
    if target:FindFirstChild(tag) then return end

    local hl = Instance.new("Highlight")
    hl.Name = tag
    hl.Adornee = target
    hl.FillColor = fillColor
    hl.FillTransparency = fillTransparency or 0.5
    hl.OutlineColor = outlineColor
    hl.OutlineTransparency = 0
    hl.Parent = target
end

-- ================= MARKER =================
local function AddMarker(male, tag)
    if not male or not male:IsA("Model") then return end
    if male:FindFirstChild(tag) then return end

    local root = male:FindFirstChild("Root")
    if not root then return end

    local part = Instance.new("Part")
    part.Name = tag
    part.Size = Vector3.new(1, 1, 1)
    part.CFrame = root.CFrame
    part.Massless = true
    part.Anchored = true
    part.CanCollide = false
    part.CanTouch = false
    part.CanQuery = false
    part.Transparency = 1
    part.Parent = male

    -- Billboard ukuran FIXED (tidak scale dengan jarak)
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ObjectiveUI"
    billboard.Size = UDim2.new(0, 80, 0, 40)   -- pixel fixed, tidak ikut zoom
    billboard.StudsOffsetWorldSpace = Vector3.new(0, 2.5, 0)
    billboard.Adornee = part
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = ESP_PLAYER_MAX_DISTANCE
    billboard.ResetOnSpawn = false
    billboard.Parent = part

    -- Diamond icon ♦
    local diamond = Instance.new("TextLabel")
    diamond.Name = "DiamondIcon"
    diamond.Size = UDim2.new(1, 0, 0, 14)
    diamond.Position = UDim2.new(0, 0, 0, 0)
    diamond.AnchorPoint = Vector2.new(0, 0)
    diamond.BackgroundTransparency = 1
    diamond.TextColor3 = Color3.fromRGB(255, 255, 50)
    diamond.TextStrokeTransparency = 0
    diamond.TextStrokeColor3 = Color3.new(0, 0, 0)
    diamond.Font = Enum.Font.GothamBold
    diamond.TextSize = 12
    diamond.Text = "♦"
    diamond.TextXAlignment = Enum.TextXAlignment.Center
    diamond.Parent = billboard

    -- Label [PLAYER]
    local labelPlayer = Instance.new("TextLabel")
    labelPlayer.Name = "PlayerLabel"
    labelPlayer.Size = UDim2.new(1, 0, 0, 14)
    labelPlayer.Position = UDim2.new(0, 0, 0, 13)
    labelPlayer.AnchorPoint = Vector2.new(0, 0)
    labelPlayer.BackgroundTransparency = 1
    labelPlayer.TextColor3 = Color3.fromRGB(255, 255, 255)
    labelPlayer.TextStrokeTransparency = 0
    labelPlayer.TextStrokeColor3 = Color3.new(0, 0, 0)
    labelPlayer.Font = Enum.Font.GothamBold
    labelPlayer.TextSize = 11
    labelPlayer.Text = "[PLAYER]"
    labelPlayer.TextXAlignment = Enum.TextXAlignment.Center
    labelPlayer.Parent = billboard

    -- Label distance
    local labelDist = Instance.new("TextLabel")
    labelDist.Name = "DistanceLabel"
    labelDist.Size = UDim2.new(1, 0, 0, 14)
    labelDist.Position = UDim2.new(0, 0, 0, 26)
    labelDist.AnchorPoint = Vector2.new(0, 0)
    labelDist.BackgroundTransparency = 1
    labelDist.TextColor3 = Color3.fromRGB(255, 255, 255)
    labelDist.TextStrokeTransparency = 0
    labelDist.TextStrokeColor3 = Color3.new(0, 0, 0)
    labelDist.Font = Enum.Font.GothamBold
    labelDist.TextSize = 11
    labelDist.RichText = true
    labelDist.Text = "0m"
    labelDist.TextXAlignment = Enum.TextXAlignment.Center
    labelDist.Parent = billboard

    if MarkerConnections[male] then
        MarkerConnections[male]:Disconnect()
    end

    local conn
    conn = RunService.RenderStepped:Connect(function()
        if not male.Parent then
            part:Destroy()
            if MarkerConnections[male] then
                MarkerConnections[male]:Disconnect()
                MarkerConnections[male] = nil
            end
            return
        end

        part.CFrame = root.CFrame

        local myPos = GetRootPos()
        if not myPos then return end

        local dist = (root.Position - myPos).Magnitude

        -- Max distance check
        if dist > ESP_PLAYER_MAX_DISTANCE then
            billboard.Enabled = false
            return
        else
            billboard.Enabled = true
        end

        -- Warna berdasarkan jarak
        local r, g, b = GetDistanceColor(dist)
        local col = Color3.fromRGB(r, g, b)

        diamond.TextColor3 = col -- diamond tetap merah
        labelPlayer.TextColor3 = col
        labelDist.TextColor3 = col

        labelDist.Text = string.format("%dm", math.floor(dist))
    end)

    MarkerConnections[male] = conn
end

-- ================= SCAN =================
local function ScanExisting()
    for _, v in ipairs(workspace:GetDescendants()) do

        if ESP_ZOMBIE and v.Name == "Zombie" and v:FindFirstChild("Humanoid") then
            AddHighlight(v, "ESP_ZOMBIE", Color3.fromRGB(255, 0, 0), Color3.fromRGB(255, 0, 0), 1)
        end

        if ESP_NPC and v.Name == "Male" and v:FindFirstChild("Humanoid") then
            AddHighlight(v, "ESP_NPC", Color3.new(1, 1, 1), Color3.new(1, 1, 1), 1)
        end

        if ESP_PLAYER and v.Name == "Male" and v:FindFirstChild("Humanoid") then
            if ESP_PLAYER_MARKER then
                AddMarker(v, "ESP_PLAYER")
            end
            AddHighlight(v, "ESP_PLAYER", Color3.new(1, 1, 1), Color3.new(1, 1, 1), 1)
        end
    end
end

-- ================= WATCHER =================
local function StartDescendantWatcher()
    if descendantConn then return end
    if not (ESP_PLAYER or ESP_NPC or ESP_ZOMBIE) then return end

    descendantConn = workspace.DescendantAdded:Connect(function(v)
        task.defer(function()

            if ESP_ZOMBIE and v.Name == "Zombie" and v:IsA("Model") then
                AddHighlight(v, "ESP_ZOMBIE", Color3.fromRGB(255, 0, 0), Color3.fromRGB(255, 0, 0), 1)
            end

            if ESP_NPC and v.Name == "Male" then
                AddHighlight(v, "ESP_NPC", Color3.new(1, 1, 1), Color3.new(1, 1, 1), 1)
            end

            if ESP_PLAYER and v.Name == "Male" and v:FindFirstChild("Humanoid") then
                if ESP_PLAYER_MARKER then
                    AddMarker(v, "ESP_PLAYER")
                end
                AddHighlight(v, "ESP_PLAYER", Color3.new(1, 1, 1), Color3.new(1, 1, 1), 1)
            end
        end)
    end)
end

local function StopWatcher()
    if not ESP_PLAYER and not ESP_NPC and not ESP_ZOMBIE then
        if descendantConn then
            descendantConn:Disconnect()
            descendantConn = nil
        end
    end
end

-- ================= SETTINGS =================
function EspService:SetPlayerMarker(state)
    ESP_PLAYER_MARKER = state
    ClearMarker("ESP_PLAYER")
    if ESP_PLAYER then
        ScanExisting()
    end
end

function EspService:SetMaxDistance(dist)
    ESP_PLAYER_MAX_DISTANCE = dist
end

-- ================= TOGGLE =================
function EspService:ToggleESP(nama, state)
    if nama == "player" then
        ESP_PLAYER = state
    elseif nama == "npc" then
        ESP_NPC = state
    elseif nama == "zombie" then
        ESP_ZOMBIE = state
    end

    if state then
        StartDescendantWatcher()
        ScanExisting()
    else
        local tag = "ESP_" .. string.upper(nama)
        ClearHighlights(tag)
        ClearMarker(tag)
        StopWatcher()
    end
end

return EspService