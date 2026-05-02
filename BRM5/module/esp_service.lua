local EspService = {}

local ESP_PLAYER = false
local ESP_NPC = false
local ESP_ZOMBIE = false

local descendantConn
local worldmodelChildConn
local MarkerConnections = {}

local function GetRootPos()
	local isFPS = workspace.Camera:FindFirstChild("WorldModel")
	if isFPS then
		return workspace.Camera.WorldModel.Model.Root.Position
	else
		return game.Players.LocalPlayer.WorldModel.WorldModel.Model.Root.Position
	end
end

local function ClearHighlights(tag)
	for _, v in ipairs(workspace:GetDescendants()) do
		local hl = v:FindFirstChild(tag)
		if hl then hl:Destroy() end
	end
end

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

local function ClearMarker(tag)
	for male, conn in pairs(MarkerConnections) do
		if conn then
			conn:Disconnect()
		end

		if male and male:FindFirstChild(tag) then
			male[tag]:Destroy()
		end
	end
	
	MarkerConnections = {}
end

local function AddMarker(male, tag)
	if male:FindFirstChild(tag) then return end
	
	local root = male:FindFirstChild("Root")
	if not root then return end

	local part = Instance.new("Part")
	part.Name = tag
	part.Size = Vector3.new(1, 1, 1)
	part.CFrame = CFrame.new(root.Position) -- FIX
	part.Anchored = true
	part.CanCollide = false
    part.CanQuery = false
    part.CanTouch = false
    part.Massless = true
	part.Transparency = 1
	part.Parent = male

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "ObjectiveUI"
	billboard.Size = UDim2.new(0, 200, 0, 100)
	billboard.StudsOffset = Vector3.new(0, 2, 0)
	billboard.Adornee = part
	billboard.AlwaysOnTop = true
	billboard.MaxDistance = math.huge
	billboard.Parent = part

	local label = Instance.new("TextLabel")
	label.Name = "DistanceLabel"
	label.Size = UDim2.new(1, 0, 0, 40)
	label.Position = UDim2.new(0.5, 0, 0, 55)
	label.AnchorPoint = Vector2.new(0.5, 0.5)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextStrokeTransparency = 0
	label.Font = Enum.Font.GothamBold
	label.TextSize = 14
	label.RichText = true
	label.Text = string.format('<font color="#FFFF00">[PLAYER]</font>\n<font color="#FFFFFF">--m</font>')
	label.Parent = billboard

	-- 🔧 FIX overwrite connection
	if MarkerConnections[male] then
		MarkerConnections[male]:Disconnect()
	end

	local conn
	conn = game:GetService("RunService").RenderStepped:Connect(function()
		if not male or not male.Parent then
			if part then part:Destroy() end
			if conn then conn:Disconnect() end
			MarkerConnections[male] = nil
			return
		end

		local rootNow = male:FindFirstChild("Root")
		if not rootNow then return end

		part.CFrame = CFrame.new(rootNow.Position)

		local myPos = GetRootPos()
		local dist = (rootNow.Position - myPos).Magnitude

		label.Text = string.format('<font color="#FF00FF">[PLAYER]</font>\n<font color="#FFFFFF">%dm</font>', math.floor(dist))
	end)

	MarkerConnections[male] = conn
end

local function ScanExisting()
	for _, v in ipairs(workspace:GetDescendants()) do
		if ESP_ZOMBIE and v.Name == "Zombie" and v:FindFirstChild("Humanoid") then
			AddHighlight(v, "ESP_TAG_ZOMBIE", Color3.fromRGB(255, 0, 0), Color3.fromRGB(255, 0, 0), 1)
		end

		if ESP_NPC and v.Name == "Male" and not v:FindFirstChild("ObjectiveUI") and v:FindFirstChild("Humanoid") then
			AddHighlight(v, "ESP_TAG_NPC", Color3.new(1, 1, 1), Color3.new(1, 1, 1), 1)
		end

		if ESP_PLAYER and v.Name == "Male" and v:FindFirstChild("Root") and v:FindFirstChild("ObjectiveUI") and v:FindFirstChild("Humanoid") then
			AddHighlight(v, "ESP_TAG_PLAYER", Color3.new(1, 1, 1), Color3.new(1, 1, 1), 1)
		end
	end

    for _, p in game:GetService("Players").AtheoFitzgerald.WorldModel:GetChildren() do
        if p.Name == "Male" then
            AddMarker(p, "ESP_TAG_PLAYER")
        end
    end
end

local function StartDescendantWatcher()
	if descendantConn then return end
    if worldmodelChildConn then return end

	descendantConn = workspace.DescendantAdded:Connect(function(v)
		task.defer(function()
			if ESP_ZOMBIE and v.Name == "Zombie" and v:IsA("Model") and v:FindFirstChild("Humanoid") then
				AddHighlight(v, "ESP_TAG_ZOMBIE", Color3.fromRGB(255, 0, 0), Color3.fromRGB(255, 0, 0), 1)
			end

			if ESP_NPC and v.Name == "Male" and v:IsA("Model") and not v:FindFirstChild("ObjectiveUI") and v:FindFirstChild("Humanoid") then
				AddHighlight(v, "ESP_TAG_NPC", Color3.new(1, 1, 1), Color3.new(1, 1, 1), 1)
			end

			if ESP_PLAYER and v.Name == "Male" and v:IsA("Model") and v:FindFirstChild("Root") and v:FindFirstChild("ObjectiveUI") and v:FindFirstChild("Humanoid") then
				AddHighlight(v, "ESP_TAG_PLAYER", Color3.new(1, 1, 1), Color3.new(1, 1, 1), 1)
			end
		end)
	end)

    descendantConn = game.Players.LocalPlayer.WorldModel.ChildAdded:Connect(function(v)
        task.defer(function()
            if v.Name == "Male" then
                AddMarker(v, "ESP_TAG_PLAYER")
            end
        end)
    end)
end

local function StopDescendantWatcher()
	if not ESP_ZOMBIE and not ESP_NPC and not ESP_PLAYER then
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

function ToggleESP(nama, state)
	local tag = "ESP_TAG_" .. string.upper(nama)

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
		ClearHighlights(tag)
		ClearMarker(tag)
		StopDescendantWatcher()
	end
end

return EspService
