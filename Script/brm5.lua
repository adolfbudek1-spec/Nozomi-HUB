--[[============== SERVICES ==============]]
local UIS               = game:GetService("UserInputService")
local RS                = game:GetService("RunService")
local Lighting          = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players           = game:GetService("Players")

--[[============== CONNECTION TRACKER ==============]]
local Connections = {}
local function Track(conn)
	table.insert(Connections, conn)
	return conn
end

--[[============== PLAYER ==============]]
local Player    = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

--[[============== LIBRARY (Obsidian) ==============]]
local obsidian_repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library       = loadstring(game:HttpGet(obsidian_repo .. "Library.lua"))()
local ThemeManager  = loadstring(game:HttpGet(obsidian_repo .. "addons/ThemeManager.lua"))()
local SaveManager   = loadstring(game:HttpGet(obsidian_repo .. "addons/SaveManager.lua"))()

local Options = Library.Options
local Toggles = Library.Toggles

--[[============== VAR ==============]]
local var = {}
var.MATERIAL_LIST = {
	"Asphalt","SmoothPlastic","Plastic","Wood","WoodPlanks","Marble",
	"Granite","Cobblestone","Brick","Concrete","Metal",
	"DiamondPlate","Foil","Glass","Neon","Ice",
}
var.MAP = {
	["Locked Room"] = {
		Color = Color3.fromRGB(255, 140, 0),
		Location = {
			["Jewel Vault Key"]        = Vector3.new(225.921173, 61.490303, -419.975952),
			["Locker Room"]            = Vector3.new(106.772880, 29.601280, -200.412780),
			["Plant Office Key"]       = Vector3.new(930.580322, 70.271827, 1214.350708),
			["Bank Security Keycard"]  = Vector3.new(-26.267191, 61.876308, 727.933655),
			["Research Gate Key"]      = Vector3.new(-272.119323, 52.625701, -40.890029),
			["Armory Gate Key"]        = Vector3.new(635.605285, 30.002111, 366.844177),
			["Conference Room Key"]    = Vector3.new(771.127929, 50.724399, -599.473205),
			["Apartment 8 stone Key"]  = Vector3.new(-15.152880, 89.405487, 701.545898),
			["Apartment 16 stone Key"] = Vector3.new(181.852005, 87.844696, 933.168212),
			["Utility Gate Key"]       = Vector3.new(-292.013153, 58.080730, 361.684539),
			["Gate Key"]               = Vector3.new(591.852050, 64.106178, -401.657165),
			["Meeting Room Key"]       = Vector3.new(-193.502487, 109.679810, 828.702454),
			["Room 05 Key"]            = Vector3.new(119.566993, 129.850967, 245.613555),
			["Emergency Exit Key"]     = Vector3.new(532.496948, 159.353073, 518.654479),
			["Safe Key"]               = Vector3.new(-176.867614, 137.181350, 478.295074),
		}
	},
	["Exfiltration Point"] = {
		Color = Color3.fromRGB(255, 50, 50),
		Location = {
			["Whitehall Exfil"]     = Vector3.new(-480.913757, 119.326133, 412.614044),
			["Raised Park Exfil"]   = Vector3.new(438.363433, 128.790588, 1422.658203),
			["Pier Mall Exfil"]     = Vector3.new(1978.230957, 140.720733, 662.592712),
			["Helicopter Position"] = Vector3.new(1978.230957, 140.720733, 662.592712),
		}
	}
}

--[[============== HELPER: GET ROOT POS ==============]]
local function GetRootPos()
	local cam = workspace.CurrentCamera
	if cam then
		local wm = cam:FindFirstChild("WorldModel")
		if wm and wm:FindFirstChild("Model") and wm.Model:FindFirstChild("Root") then
			return wm.Model.Root.Position
		end
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

--[[============== HELPER: GET GAME MODE ==============]]
local function GetGameMode()
	local modes = { [4747446334] = "Zombie Mode", [3701546109] = "Open World" }
	return modes[game.PlaceId] or "Unknown"
end
local function IsZombieMode() return GetGameMode() == "Zombie Mode" end

--[[============== NOZOMI DEBRIS FOLDER ==============]]
local nozomiDebris = workspace:FindFirstChild("_nozomiDebris")
if not nozomiDebris then
	nozomiDebris        = Instance.new("Folder")
	nozomiDebris.Name   = "_nozomiDebris"
	nozomiDebris.Parent = workspace
end

--[[============== SAFE FLOOR PART ==============]]
local function CreateSafePart()
	if nozomiDebris:FindFirstChild("_safePart") then return end
	local SIZE = 2048; local RANGE = 16384
	for x = -RANGE, RANGE, SIZE do
		for z = -RANGE, RANGE, SIZE do
			local p        = Instance.new("Part")
			p.Name         = "_safePart"
			p.Size         = Vector3.new(SIZE, 1, SIZE)
			p.Position     = Vector3.new(x, 8, z)
			p.Anchored     = true
			p.CanCollide   = false
			p.Transparency = 1
			p.Parent       = nozomiDebris
		end
	end
end
CreateSafePart()

--[[============== REMOVE OBJECT ==============]]
local RemoveObject    = {}
local CacheFolder     = ReplicatedStorage:FindFirstChild("CacheFolder") or Instance.new("Folder")
CacheFolder.Name      = "CacheFolder"
CacheFolder.Parent    = ReplicatedStorage
local removeTargets   = { First=true, Last=true, Light=true, FULL=true, Unloaded=true }
local REMOVE_ENABLED  = false
local REMOVE_DELAY    = 0.2
local OriginalParents = {}

local function moveDescendants(obj)
	task.delay(REMOVE_DELAY, function()
		if not REMOVE_ENABLED then return end
		pcall(function()
			for _, desc in pairs(obj:GetDescendants()) do
				if desc and desc.Parent and desc.Parent ~= CacheFolder then
					if not OriginalParents[desc] then OriginalParents[desc] = desc.Parent end
					desc.Parent = CacheFolder
				end
			end
		end)
		obj.DescendantAdded:Connect(function(desc)
			if not REMOVE_ENABLED then return end
			task.delay(REMOVE_DELAY, function()
				pcall(function()
					if desc and desc.Parent and desc.Parent ~= CacheFolder then
						if not OriginalParents[desc] then OriginalParents[desc] = desc.Parent end
						desc.Parent = CacheFolder
					end
				end)
			end)
		end)
	end)
end

function RemoveObject:Enable()
	REMOVE_ENABLED = true
	for _, obj in pairs(workspace:GetChildren()) do
		if removeTargets[obj.Name] then moveDescendants(obj) end
	end
end
function RemoveObject:Disable()
	REMOVE_ENABLED = false
	self:Restore()
end
function RemoveObject:Restore()
	pcall(function()
		for obj, parent in pairs(OriginalParents) do
			if obj and obj.Parent == CacheFolder then
				obj.Parent = (parent and parent.Parent) and parent or workspace
			end
		end
		table.clear(OriginalParents)
	end)
end

Track(workspace.ChildAdded:Connect(function(obj)
	if REMOVE_ENABLED and removeTargets[obj.Name] then moveDescendants(obj) end
end))

--[[============== ESP SERVICE ==============]]
local EspService          = {}
local ESP_PLAYER          = false
local ESP_PLAYER_MARKER   = false
local ESP_PLAYER_MAX_DIST = 300
local ESP_NPC             = false
local ESP_ZOMBIE          = false
local espDescConn         = nil
local MarkerConnections   = {}
local AllHighlights       = {}

local function TrackHL(hl)
	table.insert(AllHighlights, hl)
	return hl
end

local function ClearHighlights(tag)
	for _, v in ipairs(workspace:GetDescendants()) do
		local hl = v:FindFirstChild(tag)
		if hl then hl:Destroy() end
	end
	for i = #AllHighlights, 1, -1 do
		local h = AllHighlights[i]
		if not h or not h.Parent then table.remove(AllHighlights, i) end
	end
end

local function ClearAllESPHighlights()
	for i = #AllHighlights, 1, -1 do
		local h = AllHighlights[i]
		if h and h.Parent then pcall(function() h:Destroy() end) end
		AllHighlights[i] = nil
	end
	AllHighlights = {}
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

local function AddHighlight(target, tag, fillColor, outlineColor, fillTransparency)
	if target:FindFirstChild(tag) then return end
	local hl               = Instance.new("Highlight")
	hl.Name                = tag
	hl.Adornee             = target
	hl.FillColor           = fillColor
	hl.FillTransparency    = fillTransparency or 0.5
	hl.OutlineColor        = outlineColor
	hl.OutlineTransparency = 0
	hl.Parent              = target
	TrackHL(hl)
end

local function AddMarker(male, tag)
	if not male or not male:IsA("Model") then return end
	if male:FindFirstChild(tag) then return end
	local root = male:FindFirstChild("Root")
	if not root then return end

	local part          = Instance.new("Part")
	part.Name           = tag
	part.Size           = Vector3.new(1, 1, 1)
	part.CFrame         = root.CFrame
	part.Massless       = true
	part.Anchored       = true
	part.CanCollide     = false
	part.CanTouch       = false
	part.CanQuery       = false
	part.Transparency   = 1
	part.Parent         = male

	local bb                       = Instance.new("BillboardGui")
	bb.Name                        = "ObjectiveUI"
	bb.Size                        = UDim2.new(0, 80, 0, 40)
	bb.StudsOffsetWorldSpace       = Vector3.new(0, 2.5, 0)
	bb.Adornee                     = part
	bb.AlwaysOnTop                 = true
	bb.MaxDistance                 = ESP_PLAYER_MAX_DIST
	bb.ResetOnSpawn                = false
	bb.Parent                      = part

	local diamond                  = Instance.new("TextLabel")
	diamond.Size                   = UDim2.new(1, 0, 0, 14)
	diamond.BackgroundTransparency = 1
	diamond.TextColor3             = Color3.fromRGB(255, 255, 50)
	diamond.TextStrokeTransparency = 0
	diamond.TextStrokeColor3       = Color3.new(0, 0, 0)
	diamond.Font                   = Enum.Font.GothamBold
	diamond.TextSize               = 12
	diamond.Text                   = "♦"
	diamond.TextXAlignment         = Enum.TextXAlignment.Center
	diamond.Parent                 = bb

	local lblPlayer                    = Instance.new("TextLabel")
	lblPlayer.Size                     = UDim2.new(1, 0, 0, 14)
	lblPlayer.Position                 = UDim2.new(0, 0, 0, 13)
	lblPlayer.BackgroundTransparency   = 1
	lblPlayer.TextColor3               = Color3.fromRGB(255, 255, 255)
	lblPlayer.TextStrokeTransparency   = 0
	lblPlayer.TextStrokeColor3         = Color3.new(0, 0, 0)
	lblPlayer.Font                     = Enum.Font.GothamBold
	lblPlayer.TextSize                 = 11
	lblPlayer.Text                     = "[PLAYER]"
	lblPlayer.TextXAlignment           = Enum.TextXAlignment.Center
	lblPlayer.Parent                   = bb

	local lblDist                  = Instance.new("TextLabel")
	lblDist.Name                   = "Distance"
	lblDist.Size                   = UDim2.new(1, 0, 0, 14)
	lblDist.Position               = UDim2.new(0, 0, 0, 26)
	lblDist.BackgroundTransparency = 1
	lblDist.TextColor3             = Color3.fromRGB(255, 255, 255)
	lblDist.TextStrokeTransparency = 0
	lblDist.TextStrokeColor3       = Color3.new(0, 0, 0)
	lblDist.Font                   = Enum.Font.GothamBold
	lblDist.TextSize               = 11
	lblDist.RichText               = true
	lblDist.Text                   = "0m"
	lblDist.TextXAlignment         = Enum.TextXAlignment.Center
	lblDist.Parent                 = bb

	if MarkerConnections[male] then MarkerConnections[male]:Disconnect() end
	MarkerConnections[male] = RS.RenderStepped:Connect(function()
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
		local dist  = (root.Position - myPos).Magnitude
		if dist > ESP_PLAYER_MAX_DIST then bb.Enabled = false return end
		bb.Enabled = true
		local r, g, b = GetDistanceColor(dist)
		local col     = Color3.fromRGB(r, g, b)
		diamond.TextColor3   = col
		lblPlayer.TextColor3 = col
		lblDist.TextColor3   = col
		lblDist.Text         = string.format("%dm", math.floor(dist))
	end)
end

local function ESPScanExisting()
	for _, v in ipairs(workspace:GetDescendants()) do
		if ESP_ZOMBIE and v.Name == "Zombie" and v:FindFirstChild("Humanoid") then
			AddHighlight(v, "ESP_ZOMBIE", Color3.fromRGB(255, 0, 0), Color3.fromRGB(255, 0, 0), 0.5)
		end
		if ESP_NPC and v.Name == "Male" and v:FindFirstChild("Humanoid") then
			AddHighlight(v, "ESP_NPC", Color3.new(1, 1, 1), Color3.new(1, 1, 1), 0.5)
		end
		if ESP_PLAYER and v.Name == "Male" and v:FindFirstChild("Humanoid") then
			if ESP_PLAYER_MARKER then AddMarker(v, "ESP_PLAYER_MARKER") end
		end
	end
end

local function StartESPWatcher()
	if espDescConn then return end
	if not (ESP_PLAYER or ESP_NPC or ESP_ZOMBIE) then return end
	espDescConn = workspace.DescendantAdded:Connect(function(v)
		task.defer(function()
			if ESP_ZOMBIE and v.Name == "Zombie" and v:IsA("Model") then
				AddHighlight(v, "ESP_ZOMBIE", Color3.fromRGB(255, 0, 0), Color3.fromRGB(255, 0, 0), 0.5)
			end
			if ESP_NPC and v.Name == "Male" then
				AddHighlight(v, "ESP_NPC", Color3.new(1, 1, 1), Color3.new(1, 1, 1), 0.5)
			end
			if ESP_PLAYER and v.Name == "Male" and v:FindFirstChild("Humanoid") then
				if ESP_PLAYER_MARKER then AddMarker(v, "ESP_PLAYER_MARKER") end
			end
		end)
	end)
end

local function StopESPWatcher()
	if not ESP_PLAYER and not ESP_NPC and not ESP_ZOMBIE then
		if espDescConn then espDescConn:Disconnect() espDescConn = nil end
	end
end

function EspService:SetPlayerMarker(state)
	ESP_PLAYER_MARKER = state
	ClearMarker("ESP_PLAYER_MARKER")
	if ESP_PLAYER then ESPScanExisting() end
end
function EspService:SetMaxDistance(dist)
	ESP_PLAYER_MAX_DIST = dist
end
function EspService:ToggleESP(nama, state)
	if     nama == "player" then ESP_PLAYER = state
	elseif nama == "npc"    then ESP_NPC    = state
	elseif nama == "zombie" then ESP_ZOMBIE = state end

	if state then
		StartESPWatcher()
		ESPScanExisting()
	else
		local tag = "ESP_" .. string.upper(nama)
		ClearHighlights(tag)
		if nama == "player" then ClearMarker("ESP_PLAYER_MARKER") end
		StopESPWatcher()
	end
end

--[[============== PLAYER HIGHLIGHT ==============]]
--[[
	FIX root cause raycast tidak jalan:
	Sebelumnya loop di Heartbeat menggunakan Players:GetPlayers() dan
	cari Male via plr.Character. Tapi di game ini Male object ada di
	workspace/WorldModel, bukan di Character Roblox biasa.
	Solusi: scan workspace:GetDescendants() langsung, sama seperti
	RefreshPlayerHL yang sudah benar.
]]
local ESP_PLAYER_HL         = false
local ESP_PLAYER_HL_RAYCAST = false
local ESP_PLAYER_HL_TARGET  = "Model"

local function IsMyMale(male)
	local myPos = GetRootPos()
	if not myPos then return false end
	local root = male:FindFirstChild("Root")
	if not root then return false end
	return (root.Position - myPos).Magnitude < 5
end

local function GetHLAdornee(male)
	if ESP_PLAYER_HL_TARGET == "Head" then
		return male:FindFirstChild("Head")
	else
		return male
	end
end

local function ApplyPlayerHL(male)
	if not male or not male.Parent then return end
	if IsMyMale(male) then return end
	local adornee = GetHLAdornee(male)
	if not adornee then return end

	local existing = male:FindFirstChild("ESP_PLAYER_HL")
	if existing then
		if existing.Adornee ~= adornee then
			existing:Destroy()
		else
			return
		end
	end

	local hl               = Instance.new("Highlight")
	hl.Name                = "ESP_PLAYER_HL"
	hl.Adornee             = adornee
	hl.FillColor           = Color3.fromRGB(255, 255, 255)
	hl.OutlineColor        = Color3.fromRGB(255, 255, 255)
	hl.FillTransparency    = 0.5
	hl.OutlineTransparency = 0
	hl.Parent              = male
	TrackHL(hl)
end

local function RefreshPlayerHL()
	ClearHighlights("ESP_PLAYER_HL")
	if not ESP_PLAYER_HL then return end
	if not ESP_PLAYER then return end
	for _, v in ipairs(workspace:GetDescendants()) do
		if v:IsA("Model") and v.Name == "Male" and v:FindFirstChild("Humanoid") then
			ApplyPlayerHL(v)
		end
	end
end

--[[============== RAYCAST HELPER ==============]]
local function GetMyMale()
	local ok, pos = pcall(GetRootPos)
	if not ok or not pos then return nil end
	for _, m in workspace:GetDescendants() do
		if m.Name == "Male" and m:FindFirstChild("Root") then
			if (m.Root.Position - pos).Magnitude < 5 then return m end
		end
	end
	return nil
end

local function IsVisibleFromCamera(targetRoot)
	local camPos = workspace.Camera.CFrame.Position
	local dir    = targetRoot.Position - camPos

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude

	local exclude = { workspace.Camera }
	local myMale  = GetMyMale()
	if myMale then table.insert(exclude, myMale) end
	params.FilterDescendantsInstances = exclude

	local result = workspace:Raycast(camPos, dir, params)
	if not result then return true end

	local hit = result.Instance
	while hit do
		if hit == targetRoot.Parent then return true end
		hit = hit.Parent
	end
	return false
end

--[[============== PLAYER SELBOX ==============]]
local PlayerSelBoxes = {}

local function GetOrMakeSelBox(model, key)
	local sb = PlayerSelBoxes[key]
	if sb and sb.Parent then return sb end
	for _, c in pairs(model:GetChildren()) do
		if c:IsA("SelectionBox") and c.Name == "_nHL_plr" then
			PlayerSelBoxes[key] = c; return c
		end
	end
	sb                     = Instance.new("SelectionBox")
	sb.Name                = "_nHL_plr"
	sb.LineThickness       = 0.05
	sb.SurfaceTransparency = 0.8
	sb.Adornee             = model
	sb.Parent              = model
	PlayerSelBoxes[key]    = sb
	return sb
end

local function CleanPlayerSelBoxes()
	for k, sb in pairs(PlayerSelBoxes) do
		if sb and sb.Parent then pcall(function() sb:Destroy() end) end
		PlayerSelBoxes[k] = nil
	end
end

--[[============== KEY LOCATION SERVICE ==============]]
local KeyLocationService = {}
local activeMarkers      = {}
local markerUpdateConn   = nil

function KeyLocationService:GetAllKeyName()
	local list = {}
	local lr   = var.MAP["Locked Room"]
	if not lr then return list end
	for name in pairs(lr.Location) do table.insert(list, name) end
	return list
end

local function AddKeyMarker(name, pos, category, color)
	local part        = Instance.new("Part")
	part.Name         = "ObjectiveMarkerPart"
	part.Size         = Vector3.new(1, 1, 1)
	part.CFrame       = CFrame.new(pos)
	part.Anchored     = true
	part.CanCollide   = false
	part.Transparency = 1
	part.Parent       = workspace

	local bb       = Instance.new("BillboardGui")
	bb.Name        = "ObjectiveUI"
	bb.Size        = UDim2.new(0, 58, 0, 60)
	bb.StudsOffset = Vector3.new(0, 2.2, 0)
	bb.Adornee     = part
	bb.AlwaysOnTop = true
	bb.Parent      = part

	local icon            = Instance.new("Frame")
	icon.Size             = UDim2.new(0, 10, 0, 10)
	icon.Position         = UDim2.new(0.5, 0, 0, 4)
	icon.AnchorPoint      = Vector2.new(0.5, 0)
	icon.BackgroundColor3 = color or Color3.fromRGB(255, 140, 0)
	icon.Rotation         = 45
	icon.BorderSizePixel  = 1
	icon.BorderColor3     = Color3.new(0, 0, 0)
	icon.Parent           = bb

	local lbl                   = Instance.new("TextLabel")
	lbl.Name                    = "DistanceLabel"
	lbl.Size                    = UDim2.new(1, 0, 0, 44)
	lbl.Position                = UDim2.new(0, 0, 0, 16)
	lbl.BackgroundTransparency  = 1
	lbl.TextColor3              = Color3.new(1, 1, 1)
	lbl.TextStrokeTransparency  = 0
	lbl.Font                    = Enum.Font.GothamBold
	lbl.TextSize                = 9
	lbl.RichText                = true
	lbl.Text                    = string.format('<font color="#FF8C00">[%s]</font>\n<b>%s</b>\n--m', category, name)
	lbl.TextXAlignment          = Enum.TextXAlignment.Center
	lbl.Parent                  = bb

	activeMarkers[name] = { part=part, label=lbl, pos=pos, category=category, name=name }
end

function KeyLocationService:ClearMarkers()
	for _, data in pairs(activeMarkers) do
		if data.part then data.part:Destroy() end
	end
	activeMarkers = {}
	if markerUpdateConn then markerUpdateConn:Disconnect() markerUpdateConn = nil end
end

function KeyLocationService:ShowLocations(selectedList)
	self:ClearMarkers()
	for catName, catData in pairs(var.MAP) do
		for name, pos in pairs(catData.Location) do
			if #selectedList == 0 or table.find(selectedList, name) then
				AddKeyMarker(name, pos, catName, catData.Color)
			end
		end
	end
	markerUpdateConn = RS.Heartbeat:Connect(function()
		local ok, rootPos = pcall(GetRootPos)
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
end

--[[============== SPEED SYSTEM ==============]]
local SpeedConfig = { IsActivated=false, IsHolding=false, Part=nil, Root=nil }

local function CreateSpeedPart()
	local p        = Instance.new("Part")
	p.Name         = "SpeedingPart"
	p.Size         = Vector3.new(1, 1, 1)
	p.Anchored     = true
	p.CanCollide   = false
	p.Transparency = 0
	p.Parent       = workspace
	return p
end

-- Speed UI
local SpeedGui        = Instance.new("ScreenGui")
SpeedGui.Name         = "SpeedUI"
SpeedGui.ResetOnSpawn = false
SpeedGui.Parent       = PlayerGui

local SpeedLabel                  = Instance.new("TextLabel")
SpeedLabel.Size                   = UDim2.new(0, 110, 0, 26)
SpeedLabel.Position               = UDim2.new(0, 10, 0, 10)
SpeedLabel.BackgroundTransparency = 0.3
SpeedLabel.BackgroundColor3       = Color3.fromRGB(0, 0, 0)
SpeedLabel.TextColor3             = Color3.fromRGB(255, 255, 255)
SpeedLabel.TextScaled             = true
SpeedLabel.Font                   = Enum.Font.GothamBold
SpeedLabel.Text                   = "Speed: OFF"
SpeedLabel.Parent                 = SpeedGui
Instance.new("UICorner", SpeedLabel).CornerRadius = UDim.new(0, 5)

local function UpdateSpeedUI()
	if SpeedConfig.IsActivated then
		SpeedLabel.Text             = "Speed: ON"
		SpeedLabel.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
	else
		SpeedLabel.Text             = "Speed: OFF"
		SpeedLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	end
end
UpdateSpeedUI()

local function RefreshSpeedRoot()
	if not SpeedConfig.IsActivated then return end
	local male       = GetMyMale()
	SpeedConfig.Root = male and male:FindFirstChild("Root")
end

Track(Players.LocalPlayer.CharacterAdded:Connect(function()
	task.wait(1)
	RefreshSpeedRoot()
end))

Track(RS.Heartbeat:Connect(function()
	if SpeedConfig.IsActivated and (not SpeedConfig.Root or not SpeedConfig.Root.Parent) then
		RefreshSpeedRoot()
	end
end))

--[[============== PLATFORM ==============]]
local platformParts  = {}
local PLAT_Y_SPAWN   = 0
local platformMoving = { up=false, down=false }

--[[
	PLATFORM UI REDESIGN
	Panel horizontal 130x100 di kanan tengah layar.
	Elemen:
	  - Header accent bar (oranye)
	  - Label "▣  PLATFORM"
	  - Divider
	  - Bar vertikal altitude (kiri) dengan dua marker platform (biru muda) + dot player (kuning)
	  - Label Y (kanan atas bar)
	  - Arrow direction indicator berkedip saat bergerak
	  - Key hint di bawah
]]
local PlatGui         = Instance.new("ScreenGui")
PlatGui.Name          = "PlatformUI"
PlatGui.ResetOnSpawn  = false
PlatGui.Parent        = PlayerGui

local PlatPanel                  = Instance.new("Frame")
PlatPanel.Name                   = "PlatPanel"
PlatPanel.Size                   = UDim2.new(0, 130, 0, 100)
PlatPanel.Position               = UDim2.new(1, -142, 0.5, -50)
PlatPanel.BackgroundColor3       = Color3.fromRGB(12, 12, 14)
PlatPanel.BackgroundTransparency = 0.08
PlatPanel.BorderSizePixel        = 0
PlatPanel.Visible                = false
PlatPanel.Parent                 = PlatGui
Instance.new("UICorner", PlatPanel).CornerRadius = UDim.new(0, 8)

local AccentLine            = Instance.new("Frame")
AccentLine.Size             = UDim2.new(1, 0, 0, 2)
AccentLine.Position         = UDim2.new(0, 0, 0, 0)
AccentLine.BackgroundColor3 = Color3.fromRGB(255, 128, 0)
AccentLine.BorderSizePixel  = 0
AccentLine.ZIndex           = 2
AccentLine.Parent           = PlatPanel
Instance.new("UICorner", AccentLine).CornerRadius = UDim.new(0, 8)

local PlatStroke             = Instance.new("UIStroke")
PlatStroke.Thickness         = 1
PlatStroke.Color             = Color3.fromRGB(60, 60, 60)
PlatStroke.Transparency      = 0.4
PlatStroke.Parent            = PlatPanel

local PlatHeader                  = Instance.new("TextLabel")
PlatHeader.Size                   = UDim2.new(1, -8, 0, 18)
PlatHeader.Position               = UDim2.new(0, 4, 0, 6)
PlatHeader.BackgroundTransparency = 1
PlatHeader.TextColor3             = Color3.fromRGB(255, 128, 0)
PlatHeader.Font                   = Enum.Font.GothamBold
PlatHeader.TextSize               = 11
PlatHeader.Text                   = "▣  PLATFORM"
PlatHeader.TextXAlignment         = Enum.TextXAlignment.Left
PlatHeader.ZIndex                 = 3
PlatHeader.Parent                 = PlatPanel

local PlatDivider            = Instance.new("Frame")
PlatDivider.Size             = UDim2.new(1, -8, 0, 1)
PlatDivider.Position         = UDim2.new(0, 4, 0, 26)
PlatDivider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
PlatDivider.BorderSizePixel  = 0
PlatDivider.ZIndex           = 3
PlatDivider.Parent           = PlatPanel

-- Altitude bar (left column)
local BarTrack                  = Instance.new("Frame")
BarTrack.Name                   = "BarTrack"
BarTrack.Size                   = UDim2.new(0, 10, 0, 52)
BarTrack.Position               = UDim2.new(0, 8, 0, 33)
BarTrack.BackgroundColor3       = Color3.fromRGB(30, 30, 35)
BarTrack.BorderSizePixel        = 0
BarTrack.ZIndex                 = 3
BarTrack.Parent                 = PlatPanel
Instance.new("UICorner", BarTrack).CornerRadius = UDim.new(0, 3)
local BarStroke        = Instance.new("UIStroke")
BarStroke.Thickness    = 1
BarStroke.Color        = Color3.fromRGB(70, 70, 80)
BarStroke.Transparency = 0.3
BarStroke.Parent       = BarTrack

local PlatLine1            = Instance.new("Frame")
PlatLine1.Name             = "PlatLine1"
PlatLine1.Size             = UDim2.new(1, 0, 0, 2)
PlatLine1.Position         = UDim2.new(0, 0, 0.5, -1)
PlatLine1.BackgroundColor3 = Color3.fromRGB(70, 185, 255)
PlatLine1.BorderSizePixel  = 0
PlatLine1.ZIndex           = 4
PlatLine1.Parent           = BarTrack
Instance.new("UICorner", PlatLine1).CornerRadius = UDim.new(0, 1)

local PlatLine2            = Instance.new("Frame")
PlatLine2.Name             = "PlatLine2"
PlatLine2.Size             = UDim2.new(1, 0, 0, 2)
PlatLine2.Position         = UDim2.new(0, 0, 0.5, -1)
PlatLine2.BackgroundColor3 = Color3.fromRGB(130, 220, 255)
PlatLine2.BorderSizePixel  = 0
PlatLine2.ZIndex           = 4
PlatLine2.Parent           = BarTrack
Instance.new("UICorner", PlatLine2).CornerRadius = UDim.new(0, 1)

local PlayerDot            = Instance.new("Frame")
PlayerDot.Name             = "PlayerDot"
PlayerDot.Size             = UDim2.new(1, 2, 0, 3)
PlayerDot.Position         = UDim2.new(0, -1, 0.5, -1)
PlayerDot.BackgroundColor3 = Color3.fromRGB(255, 220, 60)
PlayerDot.BorderSizePixel  = 0
PlayerDot.ZIndex           = 5
PlayerDot.Parent           = BarTrack
Instance.new("UICorner", PlayerDot).CornerRadius = UDim.new(0, 1)

-- Info block (right of bar)
local InfoBlock                  = Instance.new("Frame")
InfoBlock.Size                   = UDim2.new(1, -30, 0, 52)
InfoBlock.Position               = UDim2.new(0, 24, 0, 33)
InfoBlock.BackgroundTransparency = 1
InfoBlock.ZIndex                 = 3
InfoBlock.Parent                 = PlatPanel

local PlatYLbl                  = Instance.new("TextLabel")
PlatYLbl.Name                   = "YLabel"
PlatYLbl.Size                   = UDim2.new(1, 0, 0, 16)
PlatYLbl.Position               = UDim2.new(0, 0, 0, 0)
PlatYLbl.BackgroundTransparency = 1
PlatYLbl.TextColor3             = Color3.fromRGB(200, 200, 220)
PlatYLbl.Font                   = Enum.Font.GothamBold
PlatYLbl.TextSize               = 12
PlatYLbl.RichText               = true
PlatYLbl.Text                   = '<font color="rgb(100,200,255)">Y</font> —'
PlatYLbl.TextXAlignment         = Enum.TextXAlignment.Left
PlatYLbl.ZIndex                 = 4
PlatYLbl.Parent                 = InfoBlock

local DirLbl                    = Instance.new("TextLabel")
DirLbl.Name                     = "DirLabel"
DirLbl.Size                     = UDim2.new(1, 0, 0, 20)
DirLbl.Position                 = UDim2.new(0, 0, 0, 18)
DirLbl.BackgroundTransparency   = 1
DirLbl.TextColor3               = Color3.fromRGB(90, 90, 100)
DirLbl.Font                     = Enum.Font.GothamBold
DirLbl.TextSize                 = 20
DirLbl.Text                     = "■"
DirLbl.TextXAlignment           = Enum.TextXAlignment.Left
DirLbl.ZIndex                   = 4
DirLbl.Parent                   = InfoBlock

local KeyHint                   = Instance.new("TextLabel")
KeyHint.Size                    = UDim2.new(1, -8, 0, 14)
KeyHint.Position                = UDim2.new(0, 4, 1, -16)
KeyHint.BackgroundTransparency  = 1
KeyHint.TextColor3              = Color3.fromRGB(75, 75, 90)
KeyHint.Font                    = Enum.Font.Gotham
KeyHint.TextSize                = 9
KeyHint.Text                    = "[J] UP  •  [K] DOWN"
KeyHint.TextXAlignment          = Enum.TextXAlignment.Center
KeyHint.ZIndex                  = 3
KeyHint.Parent                  = PlatPanel

local PLAT_TILE_SIZE  = 2048
local PLAT_TILE_RANGE = 8
local BAR_RANGE_Y     = 40
local _platBlinkT     = 0

local function MakePlatTile(xTile, zTile, yPos)
	local p       = Instance.new("Part")
	p.Name        = "_nozomiPlatform"
	p.Size        = Vector3.new(PLAT_TILE_SIZE, 1, PLAT_TILE_SIZE)
	p.Position    = Vector3.new(xTile * PLAT_TILE_SIZE, yPos, zTile * PLAT_TILE_SIZE)
	p.Anchored    = true
	p.CanCollide  = true
	p.Parent      = nozomiDebris
	return p
end

local function SpawnDualPlatform(transparency, material)
	for _, p in pairs(platformParts) do
		if p and p.Parent then p:Destroy() end
	end
	platformParts = {}

	local ok, rootPos = pcall(GetRootPos)
	if not ok or not rootPos then rootPos = Vector3.new(0, 12, 0) end

	local spawnY = rootPos.Y + 2
	PLAT_Y_SPAWN = spawnY

	for x = -PLAT_TILE_RANGE, PLAT_TILE_RANGE do
		for z = -PLAT_TILE_RANGE, PLAT_TILE_RANGE do
			local p1 = MakePlatTile(x, z, spawnY)
			local p2 = MakePlatTile(x, z, spawnY + 5)
			p1.Transparency = transparency or 0.4
			p2.Transparency = transparency or 0.4
			if material then p1.Material = material; p2.Material = material end
			table.insert(platformParts, p1)
			table.insert(platformParts, p2)
		end
	end

	PlatPanel.Visible = true
end

local function DestroyDualPlatform()
	for _, p in pairs(platformParts) do
		if p and p.Parent then p:Destroy() end
	end
	platformParts     = {}
	PlatPanel.Visible = false
end

local function UpdatePlatProgressBar(dt)
	local ok, rootPos = pcall(GetRootPos)
	if not ok or not rootPos then return end
	if #platformParts < 2 then return end

	local p1 = platformParts[1]
	local p2 = platformParts[2]
	if not p1 or not p1.Parent then return end

	local playerY = rootPos.Y
	local function YToBarT(y)
		return 0.5 + ((y - playerY) / BAR_RANGE_Y)
	end

	local t1 = math.clamp(YToBarT(p1.Position.Y), 0, 1)
	local t2 = math.clamp(YToBarT(p2.Position.Y), 0, 1)
	PlatLine1.Position = UDim2.new(0, 0, 1 - t1, -1)
	PlatLine2.Position = UDim2.new(0, 0, 1 - t2, -1)
	PlatYLbl.Text      = string.format('<font color="rgb(100,200,255)">Y</font> %d', math.floor(p1.Position.Y))

	-- Blinking direction arrow
	if platformMoving.up or platformMoving.down then
		_platBlinkT = _platBlinkT + (dt or 0.016)
		local blink = math.floor(_platBlinkT * 5) % 2 == 0
		if platformMoving.up then
			DirLbl.Text       = blink and "▲" or "△"
			DirLbl.TextColor3 = Color3.fromRGB(80, 220, 80)
		else
			DirLbl.Text       = blink and "▼" or "▽"
			DirLbl.TextColor3 = Color3.fromRGB(220, 80, 80)
		end
	else
		_platBlinkT       = 0
		DirLbl.Text       = "■"
		DirLbl.TextColor3 = Color3.fromRGB(90, 90, 100)
	end
end

--[[============== UTILITY: FIND NEAREST ITEMS ==============]]
local ItemESPEnabled  = false
local itemESPDescConn = nil
local itemESPParts    = {}

local function CreateItemESP(p)
	if p.Name ~= "PivotAnchor" then return end
	if not p.Parent or not p.Parent:IsA("BasePart") then return end
	if p.Parent:FindFirstChild("NameTag") then return end

	local target = p.Parent

	local hg               = Instance.new("Highlight")
	hg.FillTransparency    = 0.75
	hg.OutlineTransparency = 0
	hg.OutlineColor        = Color3.fromRGB(255, 255, 255)
	hg.FillColor           = Color3.fromRGB(255, 200, 50)
	hg.Adornee             = target
	hg.Parent              = target

	local bb               = Instance.new("BillboardGui")
	bb.Name                = "NameTag"
	bb.Size                = UDim2.new(0, 120, 0, 28)
	bb.StudsOffset         = Vector3.new(0, 2.5, 0)
	bb.AlwaysOnTop         = true
	bb.MaxDistance         = 250
	bb.Adornee             = target
	bb.Parent              = target

	local bg               = Instance.new("Frame")
	bg.Size                = UDim2.new(1, 0, 1, 0)
	bg.BackgroundColor3    = Color3.fromRGB(15, 15, 15)
	bg.BackgroundTransparency = 0.25
	bg.BorderSizePixel     = 0
	bg.Parent              = bb
	Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 6)

	local stroke           = Instance.new("UIStroke")
	stroke.Thickness       = 1
	stroke.Transparency    = 0.3
	stroke.Color           = Color3.fromRGB(255, 255, 255)
	stroke.Parent          = bg

	local txt              = Instance.new("TextLabel")
	txt.Size               = UDim2.new(1, -8, 1, 0)
	txt.Position           = UDim2.new(0, 4, 0, 0)
	txt.BackgroundTransparency = 1
	txt.Font               = Enum.Font.GothamBold
	txt.TextSize           = 14
	txt.TextColor3         = Color3.fromRGB(255, 255, 255)
	txt.TextStrokeTransparency = 0.7
	txt.Text               = target.Name
	txt.Parent             = bg

	table.insert(itemESPParts, target)
end

local function EnableItemESP()
	for _, v in pairs(workspace:GetDescendants()) do
		CreateItemESP(v)
	end
	itemESPDescConn = workspace.DescendantAdded:Connect(function(v)
		task.defer(function() CreateItemESP(v) end)
	end)
end

local function DisableItemESP()
	if itemESPDescConn then itemESPDescConn:Disconnect() itemESPDescConn = nil end
	for _, target in pairs(itemESPParts) do
		if target and target.Parent then
			local tag = target:FindFirstChild("NameTag")
			if tag then tag:Destroy() end
			for _, ch in pairs(target:GetChildren()) do
				if ch:IsA("Highlight") then ch:Destroy() end
			end
		end
	end
	itemESPParts = {}
	-- Fallback sweep
	for _, v in pairs(workspace:GetDescendants()) do
		if v:IsA("BillboardGui") and v.Name == "NameTag" then v:Destroy() end
	end
end

--[[============== UTILITY: DETECT HELICOPTER ==============]]
local heliMarkerParts    = {}
local heliUpdateConns    = {}

local function ClearHeliMarkers()
	for _, p in pairs(heliMarkerParts) do
		if p and p.Parent then p:Destroy() end
	end
	heliMarkerParts = {}
	for _, c in pairs(heliUpdateConns) do
		pcall(function() c:Disconnect() end)
	end
	heliUpdateConns = {}
end

local function CreateHeliMarker(heliPart)
	local part        = Instance.new("Part")
	part.Name         = "HeliMarker"
	part.Size         = Vector3.new(1, 1, 1)
	part.CFrame       = CFrame.new(heliPart.Position)
	part.Anchored     = true
	part.CanCollide   = false
	part.Transparency = 1
	part.Parent       = workspace
	table.insert(heliMarkerParts, part)

	-- Same style as key marker
	local bb       = Instance.new("BillboardGui")
	bb.Name        = "HeliUI"
	bb.Size        = UDim2.new(0, 58, 0, 60)
	bb.StudsOffset = Vector3.new(0, 2.2, 0)
	bb.Adornee     = part
	bb.AlwaysOnTop = true
	bb.MaxDistance = math.huge
	bb.Parent      = part

	local icon            = Instance.new("Frame")
	icon.Size             = UDim2.new(0, 10, 0, 10)
	icon.Position         = UDim2.new(0.5, 0, 0, 4)
	icon.AnchorPoint      = Vector2.new(0.5, 0)
	icon.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
	icon.Rotation         = 45
	icon.BorderSizePixel  = 1
	icon.BorderColor3     = Color3.new(0, 0, 0)
	icon.Parent           = bb

	local lbl                   = Instance.new("TextLabel")
	lbl.Name                    = "DistanceLabel"
	lbl.Size                    = UDim2.new(1, 0, 0, 44)
	lbl.Position                = UDim2.new(0, 0, 0, 16)
	lbl.BackgroundTransparency  = 1
	lbl.TextColor3              = Color3.new(1, 1, 1)
	lbl.TextStrokeTransparency  = 0
	lbl.Font                    = Enum.Font.GothamBold
	lbl.TextSize                = 9
	lbl.RichText                = true
	lbl.Text                    = '<font color="rgb(255,50,50)">[Helicopter]</font>\n<b>Exfil</b>\n--m'
	lbl.TextXAlignment          = Enum.TextXAlignment.Center
	lbl.Parent                  = bb

	local conn = RS.Heartbeat:Connect(function()
		if not heliPart or not heliPart.Parent then
			part:Destroy()
			return
		end
		part.CFrame = CFrame.new(heliPart.Position)
		local ok, rootPos = pcall(GetRootPos)
		if not ok or not rootPos then return end
		local dist = math.floor((heliPart.Position - rootPos).Magnitude)
		lbl.Text = string.format(
			'<font color="rgb(255,50,50)">[Helicopter]</font>\n<b>Exfil</b>\n%dm', dist
		)
	end)
	table.insert(heliUpdateConns, conn)
end

local function DetectHelicopter()
	ClearHeliMarkers()
	local found = 0
	for _, heli in pairs(workspace:GetDescendants()) do
		if heli.Name == "Emitter_Helicopter"
			and heli.Parent
			and heli.Parent:IsA("BasePart")
			and heli.Parent.Parent
			and heli.Parent.Parent:IsA("Model") then
			CreateHeliMarker(heli.Parent)
			found = found + 1
		end
	end
	if found == 0 then
		Library:Notify({
			Title    = "Helicopter",
			Content  = "Helicopter has not spawned yet.",
			Duration = 4,
		})
	else
		Library:Notify({
			Title    = "Helicopter",
			Content  = string.format("Found %d helicopter exfil marker(s)!", found),
			Duration = 4,
		})
	end
end

--[[============== WINDOW ==============]]
local GAME_NAME = game.MarketplaceService:GetProductInfo(game.PlaceId).Name
local EXECUTOR  = identifyexecutor and identifyexecutor() or "Unknown"

local Window = Library:CreateWindow({
	Footer     = "Game: "..GAME_NAME.." | Map: "..GetGameMode().." | Executor: "..EXECUTOR,
	Icon       = 88863555863606,
	NotifySide = "Right",
	Size       = UDim2.fromOffset(670, 550),
	IconSize   = UDim2.fromOffset(40, 40)
})

--[[============== CONFIG ==============]]
local Config = {
	ESP_ZOMBIE                = false,
	ESP_PLAYER                = false,
	ESP_PLAYER_LABEL          = false,
	ESP_PLAYER_LABEL_DIST     = 1000,
	ESP_NPC                   = false,
	ESP_PLAYER_HIGHLIGHT      = false,
	ESP_PLAYER_HL_RAYCAST     = false,
	ESP_PLAYER_HL_TARGET      = "Model",
	PLATFORM_SHOW             = false,
	PLATFORM_SPEED            = 0.4,
	PLATFORM_TRANSPARENCY     = 0.4,
	PLATFORM_MATERIAL         = Enum.Material.Asphalt,
	REMOVE_OBJECT             = false,
	ITEM_ESP                  = false,
}

--[[============== THEME ==============]]
Window:SetCompact(true)
Window:SetCornerRadius(0)
SaveManager:SetLibrary(Library)
ThemeManager:SetFolder("NozomiHUB")
SaveManager:SetFolder("NozomiHUB/saves")
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
SaveManager:IgnoreThemeSettings()
ThemeManager:SetLibrary(Library)
ThemeManager:SetDefaultTheme({
	FontColor       = Color3.fromRGB(240, 240, 240),
	MainColor       = Color3.fromRGB(32,  32,  32),
	AccentColor     = Color3.fromRGB(255, 128,   0),
	BackgroundColor = Color3.fromRGB(20,  20,  20),
	OutlineColor    = Color3.fromRGB(60,  60,  60),
})

--[[============== TABS ==============]]
local Tabs = {
	Main     = Window:AddTab("Main",     "house"),
	Map      = Window:AddTab("Map",      "map-pin"),
	Settings = Window:AddTab("Settings", "settings"),
}

--[[============== HEARTBEAT LOOP ==============]]
Track(RS.Heartbeat:Connect(function(dt)
	-- Speed
	if SpeedConfig.IsActivated and SpeedConfig.IsHolding
		and SpeedConfig.Root and SpeedConfig.Part then
		SpeedConfig.Part.CFrame = SpeedConfig.Root.CFrame
	end

	-- Platform movement
	if #platformParts > 0 then
		local delta = 0
		if platformMoving.up   then delta =  Config.PLATFORM_SPEED end
		if platformMoving.down then delta = -Config.PLATFORM_SPEED end
		if delta ~= 0 then
			for _, p in pairs(platformParts) do
				if p and p.Parent then
					p.Position = Vector3.new(p.Position.X, p.Position.Y + delta, p.Position.Z)
				end
			end
		end
		UpdatePlatProgressBar(dt)
	end

	-- Player ESP SelectionBox raycast coloring
	if Config.ESP_PLAYER then
		for _, plr in pairs(Players:GetPlayers()) do
			if plr == Player then continue end
			local male = nil
			local wm   = plr:FindFirstChild("WorldModel")
			if wm then male = wm:FindFirstChild("Male") end
			if not male and plr.Character then
				male = plr.Character:FindFirstChild("Male") or plr.Character
			end
			if not male then continue end

			local root = male:FindFirstChild("Root")
				or male:FindFirstChild("HumanoidRootPart")
				or male.PrimaryPart
			if not root then continue end

			local sb      = GetOrMakeSelBox(male, plr)
			local visible = IsVisibleFromCamera(root)
			local color   = visible
				and Color3.fromRGB(0, 255, 0)
				or  Color3.fromRGB(255, 0, 0)
			sb.Color3        = color
			sb.SurfaceColor3 = color
		end
	else
		CleanPlayerSelBoxes()
	end

	--[[
		FIX RAYCAST HIGHLIGHT:
		Sebelumnya loop menggunakan Players:GetPlayers() dan cari Male
		via plr.Character — ini TIDAK BEKERJA di game ini karena Male
		object ada di workspace bukan di character standar Roblox.
		Sekarang kita scan workspace:GetDescendants() langsung,
		sama seperti yang dilakukan RefreshPlayerHL().
	]]
	if Config.ESP_PLAYER_HIGHLIGHT and Config.ESP_PLAYER_HL_RAYCAST and Config.ESP_PLAYER then
		for _, v in ipairs(workspace:GetDescendants()) do
			if not (v:IsA("Model") and v.Name == "Male" and v:FindFirstChild("Humanoid")) then
				continue
			end
			if IsMyMale(v) then continue end

			local root = v:FindFirstChild("Root")
				or v:FindFirstChild("HumanoidRootPart")
				or v.PrimaryPart
			if not root then continue end

			-- Apply jika belum ada (misal player baru masuk)
			local hl = v:FindFirstChild("ESP_PLAYER_HL")
			if not hl then
				ApplyPlayerHL(v)
				hl = v:FindFirstChild("ESP_PLAYER_HL")
			end
			if not hl then continue end

			local visible   = IsVisibleFromCamera(root)
			local color     = visible
				and Color3.fromRGB(0, 255, 0)
				or  Color3.fromRGB(255, 0, 0)
			hl.FillColor    = color
			hl.OutlineColor = color
		end
	end
end))

--[[============== INPUT ==============]]
Track(UIS.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.J then platformMoving.up   = true end
	if input.KeyCode == Enum.KeyCode.K then platformMoving.down = true end

	if input.KeyCode == Enum.KeyCode.F5 then
		SpeedConfig.IsActivated = not SpeedConfig.IsActivated
		if SpeedConfig.IsActivated then
			if not SpeedConfig.Part then SpeedConfig.Part = CreateSpeedPart() end
			RefreshSpeedRoot()
		end
		UpdateSpeedUI()
		if Toggles.SpeedToggle then Toggles.SpeedToggle:SetValue(SpeedConfig.IsActivated) end
	end

	if input.KeyCode == Enum.KeyCode.LeftShift
		or input.KeyCode == Enum.KeyCode.RightShift then
		SpeedConfig.IsHolding = true
	end

	if input.KeyCode == Enum.KeyCode.F6 then
		local newVal = not REMOVE_ENABLED
		if newVal then RemoveObject:Enable() else RemoveObject:Disable() end
		if Toggles.RemoveObjectToggle then Toggles.RemoveObjectToggle:SetValue(newVal) end
	end
end))

Track(UIS.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.J then platformMoving.up   = false end
	if input.KeyCode == Enum.KeyCode.K then platformMoving.down = false end
	if input.KeyCode == Enum.KeyCode.LeftShift
		or input.KeyCode == Enum.KeyCode.RightShift then
		SpeedConfig.IsHolding = false
	end
end))

--[[============== MAIN TAB ==============]]
local INFO_BOX = Tabs.Main:AddLeftGroupbox("INFORMATION", "info")
	local timeLabel = INFO_BOX:AddLabel("Time: 00:00:00")
	Track(Lighting:GetPropertyChangedSignal("TimeOfDay"):Connect(function()
		timeLabel:SetText("Time: " .. Lighting.TimeOfDay)
	end))
	if IsZombieMode() then INFO_BOX:AddLabel("Exfil: 18:00 - 06:00") end

local ESP_BOX = Tabs.Main:AddLeftGroupbox("ESP", "user")
	ESP_BOX:AddToggle("EspZombie", {
		Text     = "Toggle ESP Zombie",
		Tooltip  = "Highlight zombie (merah statis).",
		Default  = false,
		Visible  = IsZombieMode(),
		Callback = function(v)
			Config.ESP_ZOMBIE = v
			EspService:ToggleESP("zombie", v)
		end,
	})
	ESP_BOX:AddToggle("EspNpc", {
		Text     = "Toggle ESP NPC",
		Tooltip  = "Highlight NPC di map.",
		Default  = false,
		Callback = function(v)
			Config.ESP_NPC = v
			EspService:ToggleESP("npc", v)
		end,
	})
	ESP_BOX:AddToggle("EspPlayer", {
		Text     = "Toggle ESP Player",
		Tooltip  = "Hijau = kelihatan | Merah = di balik tembok.",
		Default  = false,
		Callback = function(v)
			Config.ESP_PLAYER = v
			if not v then
				CleanPlayerSelBoxes()
				if Config.ESP_PLAYER_HIGHLIGHT then
					ClearHighlights("ESP_PLAYER_HL")
				end
			else
				if Config.ESP_PLAYER_HIGHLIGHT then
					RefreshPlayerHL()
				end
			end
			EspService:ToggleESP("player", v)
		end,
	})
	ESP_BOX:AddToggle("EspPlayerLabel", {
		Text     = "Show Label",
		Tooltip  = "Billboard label jarak ke player.",
		Default  = false,
		Callback = function(v)
			Config.ESP_PLAYER_LABEL = v
			EspService:SetPlayerMarker(v)
		end,
	})
	ESP_BOX:AddSlider("EspLabelDistance", {
		Text     = "Label Distance",
		Default  = 1000,
		Min      = 1,
		Max      = 9999,
		Rounding = 0,
		Suffix   = " studs",
		Callback = function(v)
			Config.ESP_PLAYER_LABEL_DIST = v
			EspService:SetMaxDistance(v)
		end,
	})

	ESP_BOX:AddDivider()

	ESP_BOX:AddDropdown("EspPlayerHLTarget", {
		Text    = "Highlight Target",
		Values  = { "Model", "Head" },
		Default = "Model",
		Tooltip = "Model = highlight seluruh model | Head = highlight kepala saja.",
		Callback = function(v)
			Config.ESP_PLAYER_HL_TARGET = v
			ESP_PLAYER_HL_TARGET        = v
			if Config.ESP_PLAYER_HIGHLIGHT and Config.ESP_PLAYER then
				RefreshPlayerHL()
			end
		end,
	})
	ESP_BOX:AddToggle("EspPlayerHighlight", {
		Text    = "Toggle Highlight",
		Tooltip = "Highlight putih pada semua player. Aktifkan ESP Player dulu.",
		Default = false,
		Callback = function(v)
			Config.ESP_PLAYER_HIGHLIGHT = v
			ESP_PLAYER_HL               = v
			if v and Config.ESP_PLAYER then
				RefreshPlayerHL()
			else
				ClearHighlights("ESP_PLAYER_HL")
				if Toggles.EspPlayerHLRaycast then
					Toggles.EspPlayerHLRaycast:SetValue(false)
				end
				Config.ESP_PLAYER_HL_RAYCAST = false
				ESP_PLAYER_HL_RAYCAST        = false
			end
		end,
	})
	ESP_BOX:AddToggle("EspPlayerHLRaycast", {
		Text    = "Toggle Highlight Raycast",
		Tooltip = "Hijau = terlihat kamera | Merah = di balik tembok.\nOtomatis aktifkan Highlight jika belum.",
		Default = false,
		Callback = function(v)
			Config.ESP_PLAYER_HL_RAYCAST = v
			ESP_PLAYER_HL_RAYCAST        = v
			if v then
				if not Config.ESP_PLAYER_HIGHLIGHT then
					Config.ESP_PLAYER_HIGHLIGHT = true
					ESP_PLAYER_HL               = true
					if Toggles.EspPlayerHighlight then
						Toggles.EspPlayerHighlight:SetValue(true)
					end
				end
				if Config.ESP_PLAYER then RefreshPlayerHL() end
			else
				-- Reset semua highlight ke putih
				for _, hl in ipairs(AllHighlights) do
					if hl and hl.Parent and hl.Name == "ESP_PLAYER_HL" then
						hl.FillColor    = Color3.fromRGB(255, 255, 255)
						hl.OutlineColor = Color3.fromRGB(255, 255, 255)
					end
				end
			end
		end,
	})

local REMOVE_BOX = Tabs.Main:AddLeftGroupbox("Remove Object", "trash")
	REMOVE_BOX:AddToggle("RemoveObjectToggle", {
		Text     = "Remove Objects  [F6]",
		Tooltip  = "Sembunyikan First / Last / Light / FULL / Unloaded.",
		Default  = false,
		Callback = function(v)
			Config.REMOVE_OBJECT = v
			REMOVE_ENABLED = v
			if v then RemoveObject:Enable() else RemoveObject:Disable() end
		end,
	})

--[[============== UTILITY GROUPBOX ==============]]
local UTIL_BOX = Tabs.Main:AddLeftGroupbox("Utility", "tool")
	UTIL_BOX:AddToggle("FindNearestItems", {
		Text    = "Find Nearest Items",
		Tooltip = "Highlight + label nama semua item yang punya PivotAnchor di workspace.",
		Default = false,
		Callback = function(v)
			Config.ITEM_ESP = v
			ItemESPEnabled  = v
			if v then EnableItemESP() else DisableItemESP() end
		end,
	})
	UTIL_BOX:AddButton("Detect Helicopter", function()
		DetectHelicopter()
	end)

local PLATFORM_BOX = Tabs.Main:AddRightGroupbox("Moveable Platform", "move-horizontal")
	PLATFORM_BOX:AddToggle("SpawnPlatform", {
		Text     = "Spawn Platform",
		Tooltip  = "2 platform besar cover semua map. J = naik | K = turun.",
		Default  = false,
		Callback = function(v)
			Config.PLATFORM_SHOW = v
			if v then
				SpawnDualPlatform(Config.PLATFORM_TRANSPARENCY, Config.PLATFORM_MATERIAL)
			else
				DestroyDualPlatform()
			end
		end,
	})
	PLATFORM_BOX:AddSlider("PlatformSpeedSlider", {
		Text     = "Platform Speed",
		Default  = Config.PLATFORM_SPEED,
		Min      = 0.1,
		Max      = 2.0,
		Rounding = 1,
		Callback = function(v) Config.PLATFORM_SPEED = v end,
	})
	PLATFORM_BOX:AddSlider("PlatformTransparencySlider", {
		Text     = "Platform Transparency",
		Default  = Config.PLATFORM_TRANSPARENCY,
		Min      = 0,
		Max      = 1.0,
		Rounding = 1,
		Callback = function(v)
			Config.PLATFORM_TRANSPARENCY = v
			for _, p in pairs(platformParts) do
				if p and p.Parent then p.Transparency = v end
			end
		end,
	})
	PLATFORM_BOX:AddDropdown("PlatformMaterial", {
		Text     = "Platform Material",
		Values   = var.MATERIAL_LIST,
		Default  = "Asphalt",
		Tooltip  = "Ganti material platform.",
		Callback = function(v)
			local mat = Enum.Material[v]
			if mat then
				Config.PLATFORM_MATERIAL = mat
				for _, p in pairs(platformParts) do
					if p and p.Parent then p.Material = mat end
				end
			end
		end,
	})

local SPEED_BOX = Tabs.Main:AddRightGroupbox("Speed System", "zap")
	SPEED_BOX:AddToggle("SpeedToggle", {
		Text     = "Enable Speed  [F5]",
		Tooltip  = "Toggle F5. Tahan Shift saat aktif.",
		Default  = false,
		Callback = function(v)
			SpeedConfig.IsActivated = v
			if v then
				if not SpeedConfig.Part then SpeedConfig.Part = CreateSpeedPart() end
				RefreshSpeedRoot()
			end
			UpdateSpeedUI()
		end,
	})

--[[============== MAP TAB ==============]]
local MAP_BOX = Tabs.Map:AddLeftGroupbox("Key Location", "map-pin")
	local keyLocationSelected = {}

	local function GetDropdownList()
		local list = KeyLocationService:GetAllKeyName()
		table.insert(list, 1, "Select All")
		return list
	end

	MAP_BOX:AddDropdown("KeyLocationDropdown", {
		Text     = "Select Key Location",
		Values   = GetDropdownList(),
		Multi    = true,
		Callback = function(val)
			keyLocationSelected = {}
			if val["Select All"] then
				local allKeys = KeyLocationService:GetAllKeyName()
				local newVal  = {}
				for _, name in ipairs(allKeys) do
					newVal[name] = true
					table.insert(keyLocationSelected, name)
				end
				Options.KeyLocationDropdown:SetValue(newVal)
				return
			end
			for name, state in pairs(val) do
				if state and name ~= "Select All" then
					table.insert(keyLocationSelected, name)
				end
			end
		end
	})
	MAP_BOX:AddToggle("ShowMarker", {
		Text    = "Show Marker",
		Tooltip = "Tampilkan marker di map. Pilih key dari dropdown dulu.",
		Callback = function(v)
			if v then
				-- Guard: belum pilih key
				if #keyLocationSelected == 0 then
					Library:Notify({
						Title    = "Show Marker",
						Content  = "Select a key location from the dropdown first!",
						Duration = 3,
					})
					task.defer(function()
						if Toggles.ShowMarker then
							Toggles.ShowMarker:SetValue(false)
						end
					end)
					return
				end
				KeyLocationService:ShowLocations(keyLocationSelected)
			else
				KeyLocationService:ClearMarkers()
			end
		end
	})
	MAP_BOX:AddButton("Clear All Markers", function()
		KeyLocationService:ClearMarkers()
		Options.KeyLocationDropdown:SetValue(nil)
		keyLocationSelected = {}
	end)

--[[============== SETTINGS TAB ==============]]
local MENU_BOX = Tabs.Settings:AddLeftGroupbox("UI Settings", "wrench")
	MENU_BOX:AddToggle("KeybindMenuOpen", {
		Default  = Library.KeybindFrame.Visible,
		Text     = "Open Keybind Menu",
		Callback = function(v) Library.KeybindFrame.Visible = v end,
	})
	MENU_BOX:AddToggle("ShowCustomCursor", {
		Text     = "Custom Cursor",
		Default  = true,
		Callback = function(v) Library.ShowCustomCursor = v end,
	})
	MENU_BOX:AddDropdown("NotificationSide", {
		Values   = { "Left", "Right" },
		Default  = "Right",
		Text     = "Notification Side",
		Callback = function(v) Library:SetNotifySide(v) end,
	})
	MENU_BOX:AddSlider("DPISlider", {
		Default  = 100,
		Min      = 50,
		Max      = 200,
		Rounding = 0,
		Text     = "DPI Scale (Default = 100%)",
		Suffix   = "%",
		Callback = function(v) Library:SetDPIScale(v) end,
	})
	MENU_BOX:AddSlider("UICornerSlider", {
		Text     = "Corner Radius",
		Default  = Library.CornerRadius,
		Min      = 0,
		Max      = 20,
		Rounding = 0,
		Callback = function(v) Window:SetCornerRadius(v) end,
	})
	MENU_BOX:AddLabel("Menu Keybind"):AddKeyPicker("MenuKeybind", { Default="F3", NoUI=true, Text="Menu keybind" })
	Library.ToggleKeybind = Options.MenuKeybind
	MENU_BOX:AddDivider()

	MENU_BOX:AddButton({
		Text = '<font color="rgb(255, 0, 0)"><b>Unload</b></font>',
		Func = function()
			Window:AddDialog("unloadDialog", {
				Title               = "Unload",
				Description         = "Yakin mau unload? UI akan dihapus dan script dihentikan, tapi data kamu tetap tersimpan.",
				AutoDismiss         = true,
				OutsideClickDismiss = true,
				FooterButtons = {
					Cancel = {
						Title    = "Cancel",
						Variant  = "Ghost",
						Order    = 1,
						Callback = function() end
					},
					Confirm = {
						Title    = "Confirm",
						Variant  = "Primary",
						Order    = 2,
						Callback = function()
							for _, conn in pairs(Connections) do
								pcall(function() conn:Disconnect() end)
							end
							Connections = {}

							if espDescConn    then espDescConn:Disconnect()    espDescConn    = nil end
							if itemESPDescConn then itemESPDescConn:Disconnect() itemESPDescConn = nil end

							ClearAllESPHighlights()
							ClearHighlights("ESP_ZOMBIE")
							ClearHighlights("ESP_NPC")
							ClearHighlights("ESP_PLAYER")
							ClearHighlights("ESP_PLAYER_HL")
							CleanPlayerSelBoxes()
							ClearMarker("ESP_PLAYER_MARKER")

							DisableItemESP()
							ClearHeliMarkers()

							SpeedConfig.IsActivated = false
							SpeedConfig.IsHolding   = false
							if SpeedConfig.Part and SpeedConfig.Part.Parent then
								pcall(function() SpeedConfig.Part:Destroy() end)
							end
							SpeedConfig.Part = nil
							SpeedConfig.Root = nil
							pcall(function() SpeedGui:Destroy() end)

							DestroyDualPlatform()
							pcall(function() PlatGui:Destroy() end)
							platformMoving = { up=false, down=false }

							REMOVE_ENABLED = false
							RemoveObject:Restore()
							table.clear(OriginalParents)

							KeyLocationService:ClearMarkers()

							for k in pairs(Config) do
								if type(Config[k]) == "boolean" then Config[k] = false end
							end

							ESP_PLAYER_HL         = false
							ESP_PLAYER_HL_RAYCAST = false
							ESP_PLAYER_HL_TARGET  = "Model"
							ItemESPEnabled        = false
							keyLocationSelected   = {}
							platformParts         = {}
							heliMarkerParts       = {}
							heliUpdateConns       = {}
							itemESPParts          = {}

							Library:Unload()
						end
					}
				}
			})
		end
	})

-- End of script
SaveManager:BuildConfigSection(Tabs.Settings)
SaveManager:LoadAutoloadConfig()