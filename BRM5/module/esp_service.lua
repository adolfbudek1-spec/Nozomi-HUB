local EspService = {}

local ESP_PLAYER = false
local ESP_NPC = false
local ESP_ZOMBIE = false

local descendantConn
local worldmodelChildConn
local MarkerConnections = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local function GetRootPos()
	local plr = Players.LocalPlayer
	local char = plr.Character
	if char and char:FindFirstChild("HumanoidRootPart") then
		return char.HumanoidRootPart.Position
	end
	return Vector3.zero
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
		if conn then
			conn:Disconnect()
		end

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
    part.Size = Vector3.new(1,1,1)
    part.CFrame = CFrame.new(root.Position)
    part.Anchored = true
    part.CanCollide = false
    part.Transparency = 1
    part.Parent = male

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ObjectiveUI"
    billboard.Size = UDim2.new(0,200,0,100)
    billboard.StudsOffset = Vector3.new(0,2,0)
    billboard.Adornee = part
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = math.huge
    billboard.Parent = part

    local label = Instance.new("TextLabel")
    label.Name = "DistanceLabel"
    label.Size = UDim2.new(1,0,0,40)
    label.Position = UDim2.new(0.5,0,0,55)
    label.AnchorPoint = Vector2.new(0.5,0.5)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1,1,1)
    label.TextStrokeTransparency = 0
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.RichText = true
    label.Text = '<font color="#FFFF00">[PLAYER]</font>\n<font color="#FFFFFF">--m</font>'
    label.Parent = billboard

    -- Disconnect lama kalau ada
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

        local root = male:FindFirstChild("Root")
        if not root then return end

        part.CFrame = root.CFrame

        local dist = (root.Position - GetRootPos()).Magnitude
        label.Text = string.format(
            '<font color="#FF00FF">[PLAYER]</font>\n<font color="#FFFFFF">%dm</font>',
            math.floor(dist)
        )
    end)

    MarkerConnections[male] = conn
end


-- ================= SCAN =================
local function ScanExisting()
	for _, v in ipairs(workspace:GetDescendants()) do

		if ESP_ZOMBIE and v.Name == "Zombie" and v:FindFirstChild("Humanoid") then
			AddHighlight(v, "ESP_ZOMBIE", Color3.fromRGB(255,0,0), Color3.fromRGB(255,0,0), 1)
		end

		if ESP_NPC and v.Name == "Male" and v:FindFirstChild("Humanoid") then
			AddHighlight(v, "ESP_NPC", Color3.new(1,1,1), Color3.new(1,1,1), 1)
		end

		if ESP_PLAYER and v.Name == "Male" and v:FindFirstChild("Humanoid") then
			AddMarker(v, "ESP_PLAYER")
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
				AddHighlight(v, "ESP_ZOMBIE", Color3.fromRGB(255,0,0), Color3.fromRGB(255,0,0), 1)
			end

			if ESP_NPC and v.Name == "Male" then
				AddHighlight(v, "ESP_NPC", Color3.new(1,1,1), Color3.new(1,1,1), 1)
			end

			if ESP_PLAYER and v.Name == "Male" then
				AddMarker(v, "ESP_PLAYER")
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

		if worldmodelChildConn then
			worldmodelChildConn:Disconnect()
			worldmodelChildConn = nil
		end
	end
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
