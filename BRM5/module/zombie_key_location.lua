local KeyLocationService = {}

local RS = game:GetService("RunService")

local activeMarkers = {}
local markerUpdateConn

local nozomi_repo = "https://raw.githubusercontent.com/adolfbudek1-spec/Nozomi-HUB/refs/heads/main/BRM5/"
local var = loadstring(game:HttpGet(nozomi_repo .. "Variable.lua"))()

-- GET ROOT
local function GetRootPos()
	local isFPS = workspace.Camera:FindFirstChild("WorldModel")
	if isFPS then
		return workspace.Camera.WorldModel.Model.Root.Position
	else
		return game.Players.LocalPlayer.WorldModel.WorldModel.Model.Root.Position
	end
end

-- GET ALL KEY NAMES
function KeyLocationService:GetAllKeyName()
	local list = {}

	local lockedRoom = var.MAP["Locked Room"]
	if not lockedRoom then return list end

	for name, _ in pairs(lockedRoom.Location) do
		table.insert(list, name)
	end

	return list
end

-- MARKER SYSTEM
local function AddMarker(name, pos, category, color)
	local part = Instance.new("Part")
	part.Name = "ObjectiveMarkerPart"
	part.Size = Vector3.new(1, 1, 1)
	part.CFrame = CFrame.new(pos)
	part.Anchored = true
	part.CanCollide = false
	part.Transparency = 1
	part.Parent = workspace

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "ObjectiveUI"
	billboard.Size = UDim2.new(0, 80, 0, 40)
	billboard.StudsOffsetWorldSpace = Vector3.new(0, 2.5, 0)
	billboard.Adornee = part
	billboard.AlwaysOnTop = true
	billboard.Parent = part

	-- Diamond icon
	local icon = Instance.new("Frame")
	icon.Name = "Icon"
	diamond.Size = UDim2.new(1, 0, 0, 14)
	diamond.Position = UDim2.new(0, 0, 0, 0)
	diamond.AnchorPoint = Vector2.new(0, 0)
	icon.BackgroundColor3 = color or Color3.fromRGB(255, 140, 0)
	icon.Rotation = 45
	icon.BorderSizePixel = 2
	icon.BorderColor3 = Color3.new(0, 0, 0)
	icon.Parent = billboard

	-- Label (category + name + distance placeholder)
	local label = Instance.new("TextLabel")
	label.Name = "DistanceLabel"
	label.Size = UDim2.new(1, 0, 0, 14)
	label.Position = UDim2.new(0, 0, 0, 13)
	label.AnchorPoint = Vector2.new(0, 0)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextStrokeTransparency = 0
	label.Font = Enum.Font.GothamBold
	label.TextSize = 14
	label.RichText = true
	label.Text = string.format(
		'<font color="#FF8C00">[%s]</font>\n<b>%s</b>\n<font color="#FFFFFF">--m</font>',
		category, name
	)
	label.Parent = billboard

	activeMarkers[name] = {
		part = part,
		label = label,
		pos = pos,
		category = category,
		name = name
	}
end

function KeyLocationService:ClearMarkers()
	for _, data in pairs(activeMarkers) do
		if data.part then
			data.part:Destroy()
		end
	end
	activeMarkers = {}

	if markerUpdateConn then
		markerUpdateConn:Disconnect()
		markerUpdateConn = nil
	end
end

function KeyLocationService:ShowLocations(selectedList)
	self:ClearMarkers()

	for categoryName, categoryData in pairs(var.MAP) do
		for name, pos in pairs(categoryData.Location) do
			if #selectedList == 0 or table.find(selectedList, name) then
				AddMarker(name, pos, categoryName, categoryData.Color)
			end
		end
	end

	markerUpdateConn = RS.Heartbeat:Connect(function()
		local ok, rootPos = pcall(GetRootPos)
		if not ok then return end

		for _, data in pairs(activeMarkers) do
			if data.part and data.label then
				local dist = math.floor((rootPos - data.pos).Magnitude)
				data.label.Text = string.format(
				'<font color="#FF8C00">[%s]</font>\n<b>%s</b>\n<font color="#FFFFFF">%dm</font>',
				data.category,
				data.name,
				dist
			)
			end
		end
	end)
end

return KeyLocationService
