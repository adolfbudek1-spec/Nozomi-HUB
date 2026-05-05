local esp = {
    trackedRoots = {},
    connection = {}
}

local function isValidModel(instance)
    return instance and instance:IsA("Model") and instance.Name == "Male"
end

local function GetRootPos()
    local cam = workspace.CurrentCamera
    if not cam then return nil end

    local wm = cam:FindFirstChild("WorldModel")
    if wm and wm:FindFirstChild("Model") and wm.Model:FindFirstChild("Root") then
        return wm.Model.Root.Position
    end

    local lp = game.Players.LocalPlayer
    if lp and lp:FindFirstChild("WorldModel")
        and lp.WorldModel:FindFirstChild("WorldModel")
        and lp.WorldModel.WorldModel:FindFirstChild("Model")
        and lp.WorldModel.WorldModel.Model:FindFirstChild("Root") then
        return lp.WorldModel.WorldModel.Model.Root.Position
    end

    return nil
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude

local COLOR_VISIBLE = Color3.fromRGB(0, 255, 0)
local COLOR_HIDDEN  = Color3.fromRGB(255, 0, 0)

local function isVisible(fromPos, targetPos, modelToExclude)
    raycastParams.FilterDescendantsInstances = {
        modelToExclude,
        workspace.CurrentCamera
    }

    local direction = targetPos - fromPos
    local result = workspace:Raycast(fromPos, direction, raycastParams)

    if not result then return true end

    if result.Instance and result.Instance:IsDescendantOf(modelToExclude) then
        return true
    end

    return false
end

function esp:destroyAllMarker()
    for root in pairs(self.trackedRoots) do
        if root and root.Parent then
            local box = root:FindFirstChild("ESP_BOX")
            if box then box:Destroy() end
        end
    end
    self.trackedRoots = {}
end

function esp:untrackRoot(root)
    if not root then return end
    self.trackedRoots[root] = nil
    local box = root:FindFirstChild("ESP_BOX")
    if box then box:Destroy() end
end

function esp:createMarker(root, config)
    local part = Instance.new("Part")
    part.Name = "ESP_BOX"
    part.Size = Vector3.new(1, 1, 1)
    part.CFrame = root.CFrame
    part.Massless = true
    part.Anchored = true
    part.CanCollide = false
    part.CanTouch = false
    part.CanQuery = false
    part.Transparency = 1
    part.Parent = root

    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP_HIGHLIGHT"
    highlight.Adornee = root.Parent
    highlight.FillColor = Color3.fromRGB(255, 0, 0)
    highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
    highlight.FillTransparency = 0.7
    highlight.OutlineTransparency = 0
    highlight.Enabled = config.espHighlight
    highlight.Parent = part

    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 80, 0, 40)
    billboard.StudsOffsetWorldSpace = Vector3.new(0, 2.5, 0)
    billboard.Adornee = part
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = config.espMaxDistance
    billboard.ResetOnSpawn = false
    billboard.Parent = part

    local diamond = Instance.new("TextLabel")
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

    local labelPlayer = Instance.new("TextLabel")
    labelPlayer.Name = "PlayerLabel"
    labelPlayer.Size = UDim2.new(1, 0, 0, 14)
    labelPlayer.Position = UDim2.new(0, 0, 0, 13)
    labelPlayer.AnchorPoint = Vector2.new(0, 0)
    labelPlayer.BackgroundTransparency = 1
    labelPlayer.TextColor3 = config.espColor
    labelPlayer.TextStrokeTransparency = 0
    labelPlayer.TextStrokeColor3 = Color3.new(0, 0, 0)
    labelPlayer.Font = Enum.Font.GothamBold
    labelPlayer.TextSize = 11
    labelPlayer.Text = "[PLAYER]"
    labelPlayer.TextXAlignment = Enum.TextXAlignment.Center
    labelPlayer.Parent = billboard

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

    self.trackedRoots[root] = {
        part      = part,
        billboard = billboard,
        highlight = highlight,
        root      = root
    }
end

function esp:registerModel(model, config)
    if not isValidModel(model) then return end
    local root = model:FindFirstChild("Root")
    if not root or not root:IsA("BasePart") then return end
    if self.trackedRoots[root] then return end
    if not config.espEnabled then return end
    self:createMarker(root, config)
end

function esp:refreshTrackedTarget(ws, config)
    for _, instance in pairs(ws:GetDescendants()) do
        if isValidModel(instance) then
            self:registerModel(instance, config)
        end
    end
end

function esp:setupListener(ws, config)
    table.insert(self.connection, ws.DescendantAdded:Connect(function(instance)
        if not isValidModel(instance) then return end
        task.delay(0.5, function()
            if config.isUnloaded then return end
            self:registerModel(instance, config)
        end)
    end))
end

function esp:setEspEnabled(enabled, config)
    config.espEnabled = enabled

    if not enabled then
        self:destroyAllMarker()
    else
        self:refreshTrackedTarget(workspace, config)
    end
end

function esp:startUpdater(config)
    if self._updaterRunning then return end
    self._updaterRunning = true

    local conn = game:GetService("RunService").Heartbeat:Connect(function()
        local myPos = GetRootPos()
        if not myPos then return end

        local colorChanged     = config.espColor ~= self._lastEspColor
        local distChanged      = config.espMaxDistance ~= self._lastMaxDistance
        local highlightChanged = config.espHighlight ~= self._lastHighlight

        if colorChanged then
            self._lastEspColor = config.espColor
        end
        if distChanged then
            self._lastMaxDistance = config.espMaxDistance
        end
        if highlightChanged then
            self._lastHighlight = config.espHighlight
        end

        for root, data in pairs(self.trackedRoots) do
            if not root or not root.Parent then
                if data.part then data.part:Destroy() end
                self.trackedRoots[root] = nil
                continue
            end

            if not data.part then continue end

            data.part.CFrame = root.CFrame

            local dist = (root.Position - myPos).Magnitude
            data.billboard.Enabled = dist <= (config.espMaxDistance or 300)

            if colorChanged then
                local label = data.billboard:FindFirstChild("PlayerLabel")
                if label then label.TextColor3 = config.espColor end
            end

            if distChanged then
                data.billboard.MaxDistance = config.espMaxDistance
            end

            if highlightChanged then
                data.highlight.Enabled = config.espHighlight
            end

            if config.espHighlight then
                local visible = isVisible(myPos, root.Position, root.Parent)
                local color = visible and COLOR_VISIBLE or COLOR_HIDDEN
                data.highlight.FillColor = color
                data.highlight.OutlineColor = color
            end
        end
    end)

    table.insert(self.connection, conn)
end

function esp:cleanup()
    for _, conn in ipairs(self.connection) do
        pcall(function() conn:Disconnect() end)
    end
    self.connection = {}
    self._updaterRunning = false
    self:destroyAllMarker()
end

return esp