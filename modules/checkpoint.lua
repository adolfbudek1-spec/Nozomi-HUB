--[[============== CHECKPOINT (Key Location) MODULE ==============]]
local Checkpoint = {}

local _services  = nil
local _config    = nil
local _variables = nil
local _character = nil
local _track     = nil

local activeMarkers  = {}  -- [name] = { part, label, pos, category, name }
local markerUpdateConn = nil

local internalConns = {}
local function addConn(c) table.insert(internalConns, c) end

-- ── Add single marker ─────────────────────────────────────────────────────────
local function AddKeyMarker(name, pos, category, color)
	local part             = Instance.new("Part")
	part.Name              = "ObjectiveMarkerPart"
	part.Size              = Vector3.new(1, 1, 1)
	part.CFrame            = CFrame.new(pos)
	part.Anchored          = true
	part.CanCollide        = false
	part.Transparency      = 1
	part.Parent            = workspace

	local bb           = Instance.new("BillboardGui")
	bb.Name            = "ObjectiveUI"
	bb.Size            = UDim2.new(0, 58, 0, 60)
	bb.StudsOffset     = Vector3.new(0, 2.2, 0)
	bb.Adornee         = part
	bb.AlwaysOnTop     = true
	bb.Parent          = part

	local icon                    = Instance.new("Frame")
	icon.Size                     = UDim2.new(0, 10, 0, 10)
	icon.Position                 = UDim2.new(0.5, 0, 0, 4)
	icon.AnchorPoint              = Vector2.new(0.5, 0)
	icon.BackgroundColor3         = color or Color3.fromRGB(255, 140, 0)
	icon.Rotation                 = 45
	icon.BorderSizePixel          = 1
	icon.BorderColor3             = Color3.new(0, 0, 0)
	icon.Parent                   = bb

	local lbl                         = Instance.new("TextLabel")
	lbl.Name                          = "DistanceLabel"
	lbl.Size                          = UDim2.new(1, 0, 0, 44)
	lbl.Position                      = UDim2.new(0, 0, 0, 16)
	lbl.BackgroundTransparency        = 1
	lbl.TextColor3                    = Color3.new(1, 1, 1)
	lbl.TextStrokeTransparency        = 0
	lbl.Font                          = Enum.Font.GothamBold
	lbl.TextSize                      = 9
	lbl.RichText                      = true
	lbl.Text                          = string.format(
		'<font color="#FF8C00">[%s]</font>\n<b>%s</b>\n--m',
		category, name
	)
	lbl.TextXAlignment                = Enum.TextXAlignment.Center
	lbl.Parent                        = bb

	activeMarkers[name] = {
		part     = part,
		label    = lbl,
		pos      = pos,
		category = category,
		name     = name,
	}
end

-- ── Start heartbeat distance updater ─────────────────────────────────────────
local function StartMarkerUpdate()
	if markerUpdateConn then
		markerUpdateConn:Disconnect()
		markerUpdateConn = nil
	end
	markerUpdateConn = _services.RS.Heartbeat:Connect(function()
		local ok, rootPos = pcall(function() return _character:GetRootPos() end)
		if not ok or not rootPos then return end
		for _, data in pairs(activeMarkers) do
			if data.part and data.label then
				local dist = math.floor((rootPos - data.pos).Magnitude)
				data.label.Text = string.format(
					'<font color="#FF8C00">[%s]</font>\n<b>%s</b>\n%dm',
					data.category, data.name, dist
				)
			end
		end
	end)
	addConn(markerUpdateConn)
end

-- ── Public API ────────────────────────────────────────────────────────────────
function Checkpoint:Init(ctx)
	_services  = ctx.Services
	_config    = ctx.Config
	_variables = ctx.Variables
	_character = ctx.Character
	_track     = ctx.Track
end

function Checkpoint:GetAllKeyNames()
	local list = {}
	local lr   = _variables.MAP["Locked Room"]
	if not lr then return list end
	for name in pairs(lr.Location) do
		table.insert(list, name)
	end
	return list
end

function Checkpoint:ShowLocations(selectedList)
	self:ClearMarkers()
	for catName, catData in pairs(_variables.MAP) do
		for name, pos in pairs(catData.Location) do
			if #selectedList == 0 or table.find(selectedList, name) then
				AddKeyMarker(name, pos, catName, catData.Color)
			end
		end
	end
	StartMarkerUpdate()
end

function Checkpoint:ClearMarkers()
	for _, data in pairs(activeMarkers) do
		if data.part then pcall(function() data.part:Destroy() end) end
	end
	activeMarkers = {}
	if markerUpdateConn then
		markerUpdateConn:Disconnect()
		markerUpdateConn = nil
	end
end

function Checkpoint:Destroy()
	self:ClearMarkers()
	for _, c in pairs(internalConns) do
		pcall(function() c:Disconnect() end)
	end
	internalConns = {}
end

return Checkpoint
