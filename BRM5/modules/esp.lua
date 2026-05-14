local esp = {
	models = nil,
	enabled = false,
	connections = {}
}

function esp:init()
	self.models = nil

	for _, obj in ipairs(workspace:GetChildren()) do
		if obj:IsA("Model") and obj.Name == "Models" and obj:FindFirstChild("Male") then
			self.models = obj
			break
		end
	end

	return self.models ~= nil
end

local function isValidModel(male)
	return male
		and male:IsA("Model")
		and male.Name == "Male"
		and male:FindFirstChild("Head")
end

local function getEspFolder(parent)
	local folder = parent:FindFirstChild("espFolder")

	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "espFolder"
		folder.Parent = parent
	end

	return folder
end

local function addNametag(male)
	if not isValidModel(male) then return end

	local folder = getEspFolder(male)

	if folder:FindFirstChild("ObjectiveUI") then
		return
	end

	local v1 = Instance.new("BillboardGui")
	v1.Name = "ObjectiveUI"
	v1.Size = UDim2.new(0, 80, 0, 40)
	v1.StudsOffsetWorldSpace = Vector3.new(0, 2.5, 0)
	v1.Adornee = male.Head
	v1.AlwaysOnTop = true
	v1.MaxDistance = 9999
	v1.ResetOnSpawn = false
	v1.Parent = folder

	local v2 = Instance.new("TextLabel")
	v2.Size = UDim2.new(1, 0, 0, 14)
	v2.BackgroundTransparency = 1
	v2.TextColor3 = Color3.fromRGB(255, 255, 50)
	v2.TextStrokeTransparency = 0
	v2.TextStrokeColor3 = Color3.new(0, 0, 0)
	v2.Font = Enum.Font.GothamBold
	v2.TextSize = 12
	v2.Text = "♦"
	v2.TextXAlignment = Enum.TextXAlignment.Center
	v2.Parent = v1

	local v3 = Instance.new("TextLabel")
	v3.Size = UDim2.new(1, 0, 0, 14)
	v3.Position = UDim2.new(0, 0, 0, 13)
	v3.BackgroundTransparency = 1
	v3.TextColor3 = Color3.fromRGB(255, 255, 255)
	v3.TextStrokeTransparency = 0
	v3.TextStrokeColor3 = Color3.new(0, 0, 0)
	v3.Font = Enum.Font.GothamBold
	v3.TextSize = 11
	v3.Text = "[PLAYER]"
	v3.TextXAlignment = Enum.TextXAlignment.Center
	v3.Parent = v1

	local v4 = Instance.new("TextLabel")
	v4.Name = "Distance"
	v4.Size = UDim2.new(1, 0, 0, 14)
	v4.Position = UDim2.new(0, 0, 0, 26)
	v4.BackgroundTransparency = 1
	v4.TextColor3 = Color3.fromRGB(255, 255, 255)
	v4.TextStrokeTransparency = 0
	v4.TextStrokeColor3 = Color3.new(0, 0, 0)
	v4.Font = Enum.Font.GothamBold
	v4.TextSize = 11
	v4.RichText = true
	v4.Text = "0m"
	v4.TextXAlignment = Enum.TextXAlignment.Center
	v4.Parent = v1
end

local function addHighlight(male)
	if not isValidModel(male) then return end

	local folder = getEspFolder(male)

	if folder:FindFirstChild("ESPHighlight") then
		return
	end

	local v1 = Instance.new("Highlight")
	v1.Name = "ESPHighlight"
	v1.FillTransparency = 1
	v1.OutlineColor = Color3.fromRGB(255, 255, 255)
	v1.OutlineTransparency = 0
	v1.Enabled = true
	v1.Adornee = male
	v1.Parent = folder
end

function esp:destroyAllESP()
	if not self.models then return end

	for _, male in ipairs(self.models:GetChildren()) do
		if isValidModel(male) then
			local espFolder = male:FindFirstChild("espFolder")
			if espFolder then
				espFolder:Destroy()
			end
		end
	end
end

function esp:cleanup()
	for _, connection in ipairs(self.connections) do
		pcall(function()
			connection:Disconnect()
		end)
	end

	self.connections = {}
	self:destroyAllESP()
end

function esp:refreshESP()
	if not self.models then
		self:init()
	end

	if not self.models then
		return
	end

	for _, male in ipairs(self.models:GetChildren()) do
		if isValidModel(male) then
			addNametag(male)
			addHighlight(male)
		end
	end
end

function esp:setupListener()
	if not self.models then
		self:init()
	end

	if not self.models then return end

	table.insert(self.connections, self.models.ChildAdded:Connect(function(child)
		if self.enabled and isValidModel(child) then
			addNametag(child)
			addHighlight(child)
		end
	end))

	table.insert(self.connections, self.models.ChildRemoved:Connect(function()
		if self.enabled then
			task.wait(0.2)
			self:refreshESP()
		end
	end))
end

function esp:setEspEnabled(state)
	self.enabled = state

	if state then
		self:init()
		self:refreshESP()
	else
		self:destroyAllESP()
	end
end

esp:init()
esp:setupListener()

return esp