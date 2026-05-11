--[[============== PLATFORM MODULE ==============]]
local Platform = {}

local _services   = nil
local _config     = nil
local _character  = nil
local _playerGui  = nil
local _debris     = nil
local _track      = nil

-- Internal state
local platformParts  = {}
local platformMoving = { up = false, down = false }
local isEnabled      = false

local PLAT_TILE_SIZE  = 2048
local PLAT_TILE_RANGE = 8

local internalConns = {}
local function addConn(c) table.insert(internalConns, c) end

-- ── GUI ───────────────────────────────────────────────────────────────────────
local PlatGui   = nil
local PlatFrame = nil
local PlatLine1 = nil
local PlatLine2 = nil
local PlatYLbl  = nil

local BAR_RANGE_Y = 40

local function BuildGui(playerGui)
	PlatGui              = Instance.new("ScreenGui")
	PlatGui.Name         = "PlatformUI"
	PlatGui.ResetOnSpawn = false
	PlatGui.Parent       = playerGui

	PlatFrame                        = Instance.new("Frame")
	PlatFrame.Name                   = "PlatBar"
	PlatFrame.Size                   = UDim2.new(0, 14, 0, 120)
	PlatFrame.Position               = UDim2.new(1, -28, 0.5, -60)
	PlatFrame.BackgroundColor3       = Color3.fromRGB(15, 15, 15)
	PlatFrame.BackgroundTransparency = 0.2
	PlatFrame.BorderSizePixel        = 0
	PlatFrame.Visible                = false
	PlatFrame.Parent                 = PlatGui
	Instance.new("UICorner", PlatFrame).CornerRadius = UDim.new(0, 4)

	-- Player dot (selalu tengah)
	local PlayerDot                 = Instance.new("Frame")
	PlayerDot.Name                  = "PlayerDot"
	PlayerDot.Size                  = UDim2.new(1, 0, 0, 2)
	PlayerDot.Position              = UDim2.new(0, 0, 0.5, -1)
	PlayerDot.BackgroundColor3      = Color3.fromRGB(255, 255, 100)
	PlayerDot.BorderSizePixel       = 0
	PlayerDot.ZIndex                = 3
	PlayerDot.Parent                = PlatFrame

	-- Garis platform bawah
	PlatLine1                       = Instance.new("Frame")
	PlatLine1.Name                  = "PlatLine1"
	PlatLine1.Size                  = UDim2.new(1, 0, 0, 2)
	PlatLine1.Position              = UDim2.new(0, 0, 0.5, -1)
	PlatLine1.BackgroundColor3      = Color3.fromRGB(70, 185, 255)
	PlatLine1.BorderSizePixel       = 0
	PlatLine1.ZIndex                = 2
	PlatLine1.Parent                = PlatFrame

	-- Garis platform atas
	PlatLine2                       = Instance.new("Frame")
	PlatLine2.Name                  = "PlatLine2"
	PlatLine2.Size                  = UDim2.new(1, 0, 0, 2)
	PlatLine2.Position              = UDim2.new(0, 0, 0.5, -1)
	PlatLine2.BackgroundColor3      = Color3.fromRGB(100, 210, 255)
	PlatLine2.BorderSizePixel       = 0
	PlatLine2.ZIndex                = 2
	PlatLine2.Parent                = PlatFrame

	-- Label Y
	PlatYLbl                        = Instance.new("TextLabel")
	PlatYLbl.Size                   = UDim2.new(0, 38, 0, 11)
	PlatYLbl.Position               = UDim2.new(0.5, -19, 1, 3)
	PlatYLbl.BackgroundTransparency = 1
	PlatYLbl.TextColor3             = Color3.fromRGB(200, 200, 200)
	PlatYLbl.TextScaled             = true
	PlatYLbl.Font                   = Enum.Font.GothamBold
	PlatYLbl.Text                   = "Y:0"
	PlatYLbl.Parent                 = PlatFrame
end

-- ── Progress bar update ───────────────────────────────────────────────────────
local function UpdateProgressBar()
	if #platformParts < 2 then return end
	local p1 = platformParts[1]
	local p2 = platformParts[2]
	if not p1 or not p1.Parent then return end

	local ok, rootPos = pcall(function() return _character:GetRootPos() end)
	if not ok or not rootPos then return end

	local platY1  = p1.Position.Y
	local platY2  = p2.Position.Y
	local playerY = rootPos.Y

	local function YToBarT(y)
		local offset = y - playerY
		return 0.5 + (offset / BAR_RANGE_Y)
	end

	local t1 = math.clamp(YToBarT(platY1), 0, 1)
	local t2 = math.clamp(YToBarT(platY2), 0, 1)

	if PlatLine1 then PlatLine1.Position = UDim2.new(0, 0, 1 - t1, -1) end
	if PlatLine2 then PlatLine2.Position = UDim2.new(0, 0, 1 - t2, -1) end
	if PlatYLbl  then PlatYLbl.Text = "Y:" .. math.floor(platY1) end
end

-- ── Tile spawn ────────────────────────────────────────────────────────────────
local function MakePlatTile(xTile, zTile, yPos, transparency, material)
	local p      = Instance.new("Part")
	p.Name       = "_nozomiPlatform"
	p.Size       = Vector3.new(PLAT_TILE_SIZE, 1, PLAT_TILE_SIZE)
	p.Position   = Vector3.new(xTile * PLAT_TILE_SIZE, yPos, zTile * PLAT_TILE_SIZE)
	p.Anchored   = true
	p.CanCollide = true
	p.Transparency = transparency or 0.4
	if material then p.Material = material end
	p.Parent     = _debris
	return p
end

local function SpawnPlatform()
	-- Bersihkan lama
	for _, p in pairs(platformParts) do
		if p and p.Parent then p:Destroy() end
	end
	platformParts = {}

	local ok, rootPos = pcall(function() return _character:GetRootPos() end)
	if not ok or not rootPos then rootPos = Vector3.new(0, 12, 0) end

	local spawnY = rootPos.Y + 2

	for x = -PLAT_TILE_RANGE, PLAT_TILE_RANGE do
		for z = -PLAT_TILE_RANGE, PLAT_TILE_RANGE do
			local p1 = MakePlatTile(x, z, spawnY,     _config.PLATFORM_TRANSPARENCY, _config.PLATFORM_MATERIAL)
			local p2 = MakePlatTile(x, z, spawnY + 5, _config.PLATFORM_TRANSPARENCY, _config.PLATFORM_MATERIAL)
			table.insert(platformParts, p1)
			table.insert(platformParts, p2)
		end
	end

	if PlatFrame then PlatFrame.Visible = true end
	isEnabled = true
end

local function DestroyPlatform()
	for _, p in pairs(platformParts) do
		if p and p.Parent then p:Destroy() end
	end
	platformParts = {}
	isEnabled = false
	if PlatFrame then PlatFrame.Visible = false end
end

-- ── Public API ────────────────────────────────────────────────────────────────
function Platform:Init(ctx)
	_services  = ctx.Services
	_config    = ctx.Config
	_character = ctx.Character
	_playerGui = ctx.PlayerGui
	_debris    = ctx.DebrisFolder
	_track     = ctx.Track

	BuildGui(_playerGui)

	-- Heartbeat: movement + progress bar
	addConn(_services.RS.Heartbeat:Connect(function()
		if #platformParts > 0 then
			local delta = 0
			if platformMoving.up   then delta =  _config.PLATFORM_SPEED end
			if platformMoving.down then delta = -_config.PLATFORM_SPEED end

			if delta ~= 0 then
				for _, p in pairs(platformParts) do
					if p and p.Parent then
						p.Position = Vector3.new(p.Position.X, p.Position.Y + delta, p.Position.Z)
					end
				end
			end
			UpdateProgressBar()
		end
	end))

	-- F1: toggle platform
	addConn(_services.UIS.InputBegan:Connect(function(input, gp)
		if gp then return end
		if input.KeyCode == Enum.KeyCode.F1 then
			self:SetEnabled(not isEnabled)
			if ctx.Toggles and ctx.Toggles.SpawnPlatform then
				ctx.Toggles.SpawnPlatform:SetValue(isEnabled)
			end
		end
		if input.KeyCode == Enum.KeyCode.J then platformMoving.up   = true end
		if input.KeyCode == Enum.KeyCode.K then platformMoving.down = true end
	end))

	addConn(_services.UIS.InputEnded:Connect(function(input)
		if input.KeyCode == Enum.KeyCode.J then platformMoving.up   = false end
		if input.KeyCode == Enum.KeyCode.K then platformMoving.down = false end
	end))
end

function Platform:SetEnabled(v)
	isEnabled = v
	if v then SpawnPlatform() else DestroyPlatform() end
end

function Platform:SetSpeed(v)
	_config.PLATFORM_SPEED = v
end

function Platform:SetTransparency(v)
	_config.PLATFORM_TRANSPARENCY = v
	for _, p in pairs(platformParts) do
		if p and p.Parent then p.Transparency = v end
	end
end

function Platform:SetMaterial(v)
	_config.PLATFORM_MATERIAL = v
	for _, p in pairs(platformParts) do
		if p and p.Parent then p.Material = v end
	end
end

function Platform:Destroy()
	DestroyPlatform()
	platformMoving = { up = false, down = false }

	if PlatGui and PlatGui.Parent then
		pcall(function() PlatGui:Destroy() end)
	end
	PlatGui = nil; PlatFrame = nil; PlatLine1 = nil; PlatLine2 = nil; PlatYLbl = nil

	for _, c in pairs(internalConns) do
		pcall(function() c:Disconnect() end)
	end
	internalConns = {}
end

return Platform
