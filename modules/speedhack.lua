--[[============== SPEEDHACK MODULE ==============]]
local SpeedHack = {}

local _services   = nil
local _config     = nil
local _character  = nil
local _player     = nil
local _playerGui  = nil
local _track      = nil

-- Internal state
local IsActivated = false
local IsHolding   = false
local SpeedPart   = nil
local SpeedRoot   = nil

local internalConns = {}
local function addConn(c) table.insert(internalConns, c) end

-- GUI
local SpeedGui   = nil
local SpeedLabel = nil

-- ── GUI setup ────────────────────────────────────────────────────────────────
local function BuildGui(playerGui)
	SpeedGui               = Instance.new("ScreenGui")
	SpeedGui.Name          = "SpeedUI"
	SpeedGui.ResetOnSpawn  = false
	SpeedGui.Parent        = playerGui

	SpeedLabel                        = Instance.new("TextLabel")
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
end

local function UpdateUI()
	if not SpeedLabel then return end
	if IsActivated then
		SpeedLabel.Text             = "Speed: ON"
		SpeedLabel.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
	else
		SpeedLabel.Text             = "Speed: OFF"
		SpeedLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	end
end

-- ── Speed Part ───────────────────────────────────────────────────────────────
local function CreateSpeedPart()
	local p       = Instance.new("Part")
	p.Name        = "SpeedingPart"
	p.Size        = Vector3.new(1, 1, 1)
	p.Anchored    = true
	p.CanCollide  = false
	p.Transparency= 0
	p.Parent      = workspace
	return p
end

local function RefreshRoot()
	if not IsActivated then return end
	local male = _character:GetMyMale()
	SpeedRoot  = male and male:FindFirstChild("Root") or nil
end

-- ── Toggle logic ─────────────────────────────────────────────────────────────
function SpeedHack:Toggle(v, toggleRef)
	IsActivated = v
	if v then
		if not SpeedPart then SpeedPart = CreateSpeedPart() end
		RefreshRoot()
	end
	UpdateUI()
	if toggleRef then toggleRef:SetValue(IsActivated) end
end

function SpeedHack:IsEnabled()
	return IsActivated
end

-- ── Init ─────────────────────────────────────────────────────────────────────
function SpeedHack:Init(ctx)
	_services  = ctx.Services
	_config    = ctx.Config
	_character = ctx.Character
	_player    = ctx.Player
	_playerGui = ctx.PlayerGui
	_track     = ctx.Track

	BuildGui(_playerGui)
	UpdateUI()

	-- Heartbeat: move speed part sesuai root
	addConn(_services.RS.Heartbeat:Connect(function()
		if IsActivated and IsHolding and SpeedRoot and SpeedPart then
			SpeedPart.CFrame = SpeedRoot.CFrame
		end
		-- Auto-refresh root kalau hilang
		if IsActivated and (not SpeedRoot or not SpeedRoot.Parent) then
			RefreshRoot()
		end
	end))

	-- Refresh saat respawn
	addConn(_player.CharacterAdded:Connect(function()
		task.wait(1)
		RefreshRoot()
	end))

	-- Input: F5 toggle, Shift hold
	addConn(_services.UIS.InputBegan:Connect(function(input, gp)
		if gp then return end
		if input.KeyCode == Enum.KeyCode.F5 then
			self:Toggle(not IsActivated)
			if ctx.Toggles and ctx.Toggles.SpeedToggle then
				ctx.Toggles.SpeedToggle:SetValue(IsActivated)
			end
		end
		if input.KeyCode == Enum.KeyCode.LeftShift
			or input.KeyCode == Enum.KeyCode.RightShift then
			IsHolding = true
		end
	end))

	addConn(_services.UIS.InputEnded:Connect(function(input)
		if input.KeyCode == Enum.KeyCode.LeftShift
			or input.KeyCode == Enum.KeyCode.RightShift then
			IsHolding = false
		end
	end))
end

-- ── Destroy ──────────────────────────────────────────────────────────────────
function SpeedHack:Destroy()
	IsActivated = false
	IsHolding   = false

	if SpeedPart and SpeedPart.Parent then
		pcall(function() SpeedPart:Destroy() end)
	end
	SpeedPart = nil
	SpeedRoot = nil

	if SpeedGui and SpeedGui.Parent then
		pcall(function() SpeedGui:Destroy() end)
	end
	SpeedGui   = nil
	SpeedLabel = nil

	for _, c in pairs(internalConns) do
		pcall(function() c:Disconnect() end)
	end
	internalConns = {}
end

return SpeedHack
