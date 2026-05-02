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
	if not male or male:FindFirstChild(tag) then return end
	if not (ESP_PLAYER or ESP_NPC or ESP_ZOMBIE) then return end

	local root = male:FindFirstChild("Root") or male:FindFirstChild("HumanoidRootPart")
	if not root then return end

	local humanoid = male:FindFirstChild("Humanoid")
	if not humanoid then return end

	local part = Instance.new("Part")
	part.Name = tag
	part.Size = Vector3.new(1, 1, 1)
	part.CFrame = CFrame.new(root.Position)
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Massless = true
	part.Transparency = 1
	part.Parent = workspace

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "ObjectiveUI"
	billboard.Size = UDim2.new(0, 150, 0, 80)
	billboard.StudsOffset = Vector3.new(0, 3, 0)
	billboard.Adornee = part
	billboard.AlwaysOnTop = true
	billboard.MaxDistance = 500
	billboard.Parent = part

	local container = Instance.new("Frame")
	container.Parent = billboard
	container.BackgroundTransparency = 1
	container.Size = UDim2.new(1, 0, 1, 0)

	local layout = Instance.new("UIListLayout")
	layout.Parent = container
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.VerticalAlignment = Enum.VerticalAlignment.Center
	layout.SortOrder = Enum.SortOrder.LayoutOrder

	local distance = Instance.new("TextLabel")
	distance.Parent = container
	distance.BackgroundTransparency = 1
	distance.Size = UDim2.new(1, 0, 0, 25)
	distance.TextScaled = false
	distance.TextSize = 14
	distance.TextColor3 = Color3.fromRGB(0, 255, 255)
	distance.Font = Enum.Font.GothamBold
	distance.Text = "--m"

	local healthBg = Instance.new("Frame")
	healthBg.Parent = container
	healthBg.Size = UDim2.new(1, 0, 0, 10)
	healthBg.BackgroundColor3 = Color3.fromRGB(80, 80, 80)

	local healthBar = Instance.new("Frame")
	healthBar.Parent = healthBg
	healthBar.Size = UDim2.new(1, 0, 1, 0)
	healthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)

	-- disconnect old
	if MarkerConnections[male] then
		MarkerConnections[male]:Disconnect()
	end

	local conn
	conn = RunService.RenderStepped:Connect(function()

		-- ❗ HARD STOP IF ESP OFF
		if not ESP_PLAYER and not ESP_NPC and not ESP_ZOMBIE then
			part:Destroy()
			conn:Disconnect()
			MarkerConnections[male] = nil
			return
		end

		if not male or not male.Parent then
			part:Destroy()
			conn:Disconnect()
			MarkerConnections[male] = nil
			return
		end

		local rootNow = male:FindFirstChild("Root") or male:FindFirstChild("HumanoidRootPart")
		if not rootNow then return end

		part.CFrame = CFrame.new(rootNow.Position)

		local dist = (rootNow.Position - GetRootPos()).Magnitude
		distance.Text = math.floor(dist) .. "m"

		if humanoid and humanoid.MaxHealth > 0 then
			local hp = humanoid.Health / humanoid.MaxHealth
			healthBar.Size = UDim2.new(hp, 0, 1, 0)
			healthBar.BackgroundColor3 = Color3.fromRGB(255 * (1 - hp), 255 * hp, 0)
		end
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
