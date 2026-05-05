-- ============================================================
-- ESP MODULE (FIXED)
-- Perbaikan: 5 bug kritis ditemukan dan diperbaiki
-- ============================================================

local esp = {
    trackedRoots = {},
    connection = {}   -- BUG #1 FIX: tetap table, tapi startUpdater
                      -- sekarang tidak pakai guard yang salah
}

local function isValidModel(instance)
    return instance and instance:IsA("Model") and instance.Name == "Male"
end

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

local function GetDistance(a, b)
    if not a or not b then return 0 end
    return (a - b).Magnitude
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

-- ============================================================
--  DESTROY ALL MARKERS
-- ============================================================
function esp:destroyAllMarker()
    for root in pairs(self.trackedRoots) do
        if root and root.Parent then
            local box = root:FindFirstChild("ESP_BOX")
            if box then box:Destroy() end
        end
    end
    self.trackedRoots = {}
end

-- ============================================================
--  UNTRACK ROOT
-- ============================================================
function esp:untrackRoot(root)
    if not root then return end
    self.trackedRoots[root] = nil
    local box = root:FindFirstChild("ESP_BOX")
    if box then box:Destroy() end
end

-- ============================================================
--  CREATE MARKER
-- ============================================================
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

    -- highlight
    if config.espHighlight then
        local highlight = Instance.new("SelectionBox")
        highlight.Name = "ESP_HIGHLIGHT"
        highlight.Adornee = root.Parent  -- adornee ke Model
        highlight.Color3 = Color3.fromRGB(255, 0, 0)  -- default merah
        highlight.LineThickness = 0.03
        highlight.SurfaceTransparency = 0.7
        highlight.SurfaceColor3 = Color3.fromRGB(255, 0, 0)
        highlight.Parent = part
    end

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
        root      = root
    }
end


local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude

local COLOR_VISIBLE = Color3.fromRGB(0, 255, 0)    -- hijau = terlihat
local COLOR_HIDDEN  = Color3.fromRGB(255, 0, 0)    -- merah = di balik wall

local function isVisible(fromPos, targetPos, modelToExclude)
    -- exclude diri sendiri dan model target agar tidak kena hit sendiri
    raycastParams.FilterDescendantsInstances = {
        modelToExclude,
        workspace.CurrentCamera
    }

    local direction = targetPos - fromPos
    local result = workspace:Raycast(fromPos, direction, raycastParams)

    -- jika tidak ada hit, atau hit terjadi melewati jarak target
    -- berarti tidak ada halangan = terlihat
    if not result then
        return true
    end

    -- cek apakah yang kena hit adalah bagian dari model target sendiri
    local hitInstance = result.Instance
    if hitInstance and hitInstance:IsDescendantOf(modelToExclude) then
        return true
    end

    return false
end

-- ============================================================
--  REGISTER MODEL
-- ============================================================
function esp:registerModel(model, config)
    if not isValidModel(model) then return end

    local root = model:FindFirstChild("Root")
    if not root or not root:IsA("BasePart") then return end

    -- Jangan duplikat jika sudah di-track
    if self.trackedRoots[root] then return end

    -- BUG #2 FIX: dulu ditulis esp:CreateMarker (huruf kapital C)
    -- padahal nama fungsinya esp:createMarker (huruf kecil c)
    self:createMarker(root, config)
end

-- ============================================================
--  REFRESH TRACKED TARGET
-- ============================================================
function esp:refreshTrackedTarget(ws, config)
    for _, instance in pairs(ws:GetDescendants()) do
        if isValidModel(instance) then
            self:registerModel(instance, config)
        end
    end
end

-- ============================================================
--  SETUP LISTENER
-- ============================================================
function esp:setupListener(ws, config)
    -- BUG #3 FIX: dulu ditulis DescendantsAdded tanpa prefix ws.
    -- sehingga variabel undefined / error. Harus ws.DescendantAdded
    table.insert(self.connection, ws.DescendantAdded:Connect(function(instance)
        if not isValidModel(instance) then return end

        task.delay(0.5, function()
            if config.isUnloaded then return end
            self:registerModel(instance, config)
        end)
    end))
end

-- ============================================================
--  SET ESP ENABLED
-- ============================================================
function esp:setEspEnabled(enabled, config)
    config.espEnabled = enabled

    if not enabled then
        -- destroy semua part, tapi tetap simpan di trackedRoots
        -- supaya bisa di-recreate saat enable kembali
        for root, data in pairs(self.trackedRoots) do
            if data.part then
                data.part:Destroy()
                data.part = nil
                data.billboard = nil
            end
        end
    else
        -- recreate marker untuk root yang masih valid
        for root, data in pairs(self.trackedRoots) do
            if root and root.Parent and not data.part then
                self:createMarker(root, config)
            else
                self.trackedRoots[root] = nil
            end
        end
    end
end

-- ============================================================
--  START UPDATER
-- ============================================================
function esp:startUpdater(config)
    if self._updaterRunning then return end
    self._updaterRunning = true

    local conn = game:GetService("RunService").Heartbeat:Connect(function()
        local myPos = GetRootPos()
        if not myPos then return end

        -- deteksi perubahan warna & max distance
        local colorChanged     = config.espColor ~= self._lastEspColor
        local distChanged      = config.espMaxDistance ~= self._lastMaxDistance
        local highlightChanged = config.espHighlight ~= self._lastHighlight

        if colorChanged or distChanged then
            self._lastEspColor    = config.espColor
            self._lastMaxDistance = config.espMaxDistance

            for _, data in pairs(self.trackedRoots) do
                if colorChanged then
                    local label = data.billboard and data.billboard:FindFirstChild("PlayerLabel")
                    if label then
                        label.TextColor3 = config.espColor
                    end
                end

                if distChanged then
                    if data.billboard then
                        data.billboard.MaxDistance = config.espMaxDistance
                    end
                end
            end
        end

        -- highlight toggle berubah: recreate semua marker
        if highlightChanged then
            self._lastHighlight = config.espHighlight

            for root, data in pairs(self.trackedRoots) do
                if root and root.Parent and data.part then
                    data.part:Destroy()
                    data.part = nil
                    data.billboard = nil
                    self:createMarker(root, config)
                end
            end
        end

        -- update posisi, jarak, dan highlight color
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

            local distLabel = data.billboard:FindFirstChild("DistanceLabel")
            if distLabel then
                distLabel.Text = tostring(math.floor(dist)) .. "m"
            end

            -- update highlight color berdasarkan visibility raycast
            if config.espHighlight then
                local highlight = data.part:FindFirstChild("ESP_HIGHLIGHT")
                if highlight then
                    local model = root.Parent
                    local visible = isVisible(myPos, root.Position, model)
                    local color = visible and COLOR_VISIBLE or COLOR_HIDDEN

                    highlight.Color3 = color
                    highlight.SurfaceColor3 = color
                end
            end
        end
    end)

    table.insert(self.connection, conn)
end

-- ============================================================
--  CLEANUP
-- ============================================================
function esp:cleanup()
    for _, conn in ipairs(self.connection) do
        pcall(function()
            conn:Disconnect()
        end)
    end

    self.connection = {}
    self._updaterRunning = false
    self:destroyAllMarker()
end

return esp