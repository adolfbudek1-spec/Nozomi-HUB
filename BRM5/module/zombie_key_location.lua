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
	billboard.Size = UDim2.new(0, 200, 0, 100)
	billboard.StudsOffset = Vector3.new(0, 2, 0)
	billboard.Adornee = part
	billboard.AlwaysOnTop = true
	billboard.Parent = part

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.new(1,1,1)
	label.Font = Enum.Font.GothamBold
	label.TextSize = 14
	label.RichText = true
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
					"[%s]\n%s\n%dm",
					data.category,
					data.name,
					dist
				)
			end
		end
	end)
end

return KeyLocationService
