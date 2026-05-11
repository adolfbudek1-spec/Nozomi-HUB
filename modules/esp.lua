--[[============== ESP MODULE ==============]]
local ESP = {}

local _ctx       = nil
local _services  = nil
local _config    = nil
local _character = nil
local _player    = nil
local _track     = nil

-- Internal state
local playerHighlights  = {}  -- [player] = { highlight, billboard }
local zombieHighlights  = {}  -- [instance] = highlight
local npcHighlights     = {}  -- [instance] = highlight
local internalConns     = {}

local function addConn(c)
	table.insert(internalConns, c)
end

-- ── Raycast visibility check ────────────────────────────────────────────────
local function IsVisibleFromCamera(targetRoot)
	local camPos = workspace.Camera.CFrame.Position
	local dir    = targetRoot.Position - camPos

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude

	local exclude = { workspace.Camera }
	local myMale  = _character:GetMyMale()
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

-- ── Highlight factory ────────────────────────────────────────────────────────
local function MakeHighlight(adornee, fillColor, outlineColor, fillTrans, outlineTrans)
	local h                  = Instance.new("Highlight")
	h.Adornee                = adornee
	h.FillColor              = fillColor    or Color3.fromRGB(255, 255, 255)
	h.OutlineColor           = outlineColor or Color3.fromRGB(255,   0,   0)
	h.FillTransparency       = fillTrans    or 0.5
	h.OutlineTransparency    = outlineTrans or 0
	h.DepthMode              = Enum.HighlightDepthMode.AlwaysOnTop
	h.Parent                 = adornee
	return h
end

-- ── Billboard factory (player label) ────────────────────────────────────────
local function MakeBillboard(adornee, playerName)
	local bb           = Instance.new("BillboardGui")
	bb.Name            = "_espBB"
	bb.Size            = UDim2.new(0, 80, 0, 24)
	bb.StudsOffset     = Vector3.new(0, 3, 0)
	bb.Adornee         = adornee
	bb.AlwaysOnTop     = true
	bb.Parent          = adornee

	local lbl                   = Instance.new("TextLabel")
	lbl.Name                    = "NameLabel"
	lbl.Size                    = UDim2.new(1, 0, 1, 0)
	lbl.BackgroundTransparency  = 1
	lbl.TextColor3              = _config.ESP_PLAYER_LABEL_COLOR
	lbl.TextTransparency        = _config.ESP_PLAYER_LABEL_TRANS
	lbl.Font                    = Enum.Font.GothamBold
	lbl.TextScaled              = true
	lbl.Text                    = playerName .. "\n--m"
	lbl.RichText                = true
	lbl.Parent                  = bb

	return bb, lbl
end

-- ── Apply config to existing player highlight ────────────────────────────────
local function ApplyPlayerHighlightConfig(h)
	h.FillColor           = _config.ESP_PLAYER_FILL_COLOR
	h.OutlineColor        = _config.ESP_PLAYER_OUTLINE_COLOR
	h.FillTransparency    = _config.ESP_PLAYER_FILL_TRANS
	h.OutlineTransparency = _config.ESP_PLAYER_OUTLINE_TRANS
end

-- ── Clean helpers ────────────────────────────────────────────────────────────
local function CleanPlayerESP()
	for plr, data in pairs(playerHighlights) do
		if data.highlight and data.highlight.Parent then
			pcall(function() data.highlight:Destroy() end)
		end
		if data.billboard and data.billboard.Parent then
			pcall(function() data.billboard:Destroy() end)
		end
	end
	playerHighlights = {}
end

local function CleanZombieESP()
	for inst, h in pairs(zombieHighlights) do
		if h and h.Parent then pcall(function() h:Destroy() end) end
	end
	zombieHighlights = {}
end

local function CleanNpcESP()
	for inst, h in pairs(npcHighlights) do
		if h and h.Parent then pcall(function() h:Destroy() end) end
	end
	npcHighlights = {}
end

-- ── Get male model of a player ───────────────────────────────────────────────
local function GetPlayerMale(plr)
	local wm = plr:FindFirstChild("WorldModel")
	if wm then
		local m = wm:FindFirstChild("Male")
		if m then return m end
	end
	if plr.Character then
		return plr.Character:FindFirstChild("Male") or plr.Character
	end
	return nil
end

-- ── Heartbeat update ─────────────────────────────────────────────────────────
local function StartHeartbeat()
	addConn(_services.RS.Heartbeat:Connect(function()
		-- ── Player ESP ──────────────────────────────────────────────────────
		if _config.ESP_PLAYER then
			for _, plr in pairs(_services.Players:GetPlayers()) do
				if plr == _player then continue end

				local male = GetPlayerMale(plr)
				if not male then continue end

				local root = male:FindFirstChild("Root")
					or male:FindFirstChild("HumanoidRootPart")
					or male.PrimaryPart
				if not root then continue end

				-- Buat highlight kalau belum ada
				if not playerHighlights[plr] then
					local h = MakeHighlight(
						male,
						_config.ESP_PLAYER_FILL_COLOR,
						_config.ESP_PLAYER_OUTLINE_COLOR,
						_config.ESP_PLAYER_FILL_TRANS,
						_config.ESP_PLAYER_OUTLINE_TRANS
					)
					playerHighlights[plr] = { highlight = h, billboard = nil, label = nil }
				end

				local data = playerHighlights[plr]

				-- Update highlight color berdasarkan raycast
				local visible = IsVisibleFromCamera(root)
				data.highlight.OutlineColor = visible
					and Color3.fromRGB(0, 255, 0)
					or  Color3.fromRGB(255, 0, 0)
				data.highlight.FillColor       = _config.ESP_PLAYER_FILL_COLOR
				data.highlight.FillTransparency    = _config.ESP_PLAYER_FILL_TRANS
				data.highlight.OutlineTransparency = _config.ESP_PLAYER_OUTLINE_TRANS

				-- Billboard label
				if _config.ESP_PLAYER_LABEL then
					local rootPos = _character:GetRootPos()
					local dist = rootPos and math.floor((rootPos - root.Position).Magnitude) or 0

					if dist <= _config.ESP_PLAYER_LABEL_DISTANCE then
						if not data.billboard then
							local bb, lbl = MakeBillboard(male, plr.Name)
							data.billboard = bb
							data.label     = lbl
						end
						if data.label then
							data.label.TextColor3    = _config.ESP_PLAYER_LABEL_COLOR
							data.label.TextTransparency = _config.ESP_PLAYER_LABEL_TRANS
							data.label.Text = string.format(
								'<b>%s</b>\n%dm', plr.Name, dist
							)
						end
					else
						-- Jauh dari jarak max: sembunyikan label
						if data.billboard then
							pcall(function() data.billboard:Destroy() end)
							data.billboard = nil
							data.label     = nil
						end
					end
				else
					-- Label dimatikan
					if data.billboard then
						pcall(function() data.billboard:Destroy() end)
						data.billboard = nil
						data.label     = nil
					end
				end
			end

			-- Bersihkan highlight player yang sudah keluar
			for plr, data in pairs(playerHighlights) do
				if not plr or not plr.Parent then
					if data.highlight and data.highlight.Parent then
						pcall(function() data.highlight:Destroy() end)
					end
					if data.billboard and data.billboard.Parent then
						pcall(function() data.billboard:Destroy() end)
					end
					playerHighlights[plr] = nil
				end
			end
		end

		-- ── Zombie ESP ─────────────────────────────────────────────────────
		if _config.ESP_ZOMBIE then
			for _, obj in pairs(workspace:GetDescendants()) do
				if (obj.Name == "Zombie" or obj.Name == "ZombieModel")
					and obj:IsA("Model")
					and not zombieHighlights[obj] then
					zombieHighlights[obj] = MakeHighlight(
						obj,
						Color3.fromRGB(255, 50, 50),
						Color3.fromRGB(255, 0, 0),
						0.5, 0
					)
				end
			end
			-- cleanup dead zombies
			for inst, h in pairs(zombieHighlights) do
				if not inst or not inst.Parent then
					if h and h.Parent then pcall(function() h:Destroy() end) end
					zombieHighlights[inst] = nil
				end
			end
		end

		-- ── NPC ESP ─────────────────────────────────────────────────────────
		if _config.ESP_NPC then
			for _, obj in pairs(workspace:GetDescendants()) do
				if obj.Name == "NPC"
					and obj:IsA("Model")
					and not npcHighlights[obj] then
					npcHighlights[obj] = MakeHighlight(
						obj,
						Color3.fromRGB(0, 200, 255),
						Color3.fromRGB(0, 150, 255),
						0.5, 0
					)
				end
			end
			for inst, h in pairs(npcHighlights) do
				if not inst or not inst.Parent then
					if h and h.Parent then pcall(function() h:Destroy() end) end
					npcHighlights[inst] = nil
				end
			end
		end
	end))
end

-- ── Public API ───────────────────────────────────────────────────────────────
function ESP:Init(ctx)
	_ctx       = ctx
	_services  = ctx.Services
	_config    = ctx.Config
	_character = ctx.Character
	_player    = ctx.Player
	_track     = ctx.Track

	StartHeartbeat()
end

function ESP:EnablePlayer(bool)
	_config.ESP_PLAYER = bool
	if not bool then CleanPlayerESP() end
end

function ESP:EnableZombie(bool)
	_config.ESP_ZOMBIE = bool
	if not bool then CleanZombieESP() end
end

function ESP:EnableNPC(bool)
	_config.ESP_NPC = bool
	if not bool then CleanNpcESP() end
end

function ESP:SetPlayerMarker(bool)
	_config.ESP_PLAYER_LABEL = bool
end

function ESP:SetMaxDistance(v)
	_config.ESP_PLAYER_LABEL_DISTANCE = v
end

function ESP:SetPlayerFillColor(c)
	_config.ESP_PLAYER_FILL_COLOR = c
	for _, data in pairs(playerHighlights) do
		if data.highlight then data.highlight.FillColor = c end
	end
end

function ESP:SetPlayerOutlineColor(c)
	_config.ESP_PLAYER_OUTLINE_COLOR = c
end

function ESP:SetPlayerFillTransparency(v)
	_config.ESP_PLAYER_FILL_TRANS = v
	for _, data in pairs(playerHighlights) do
		if data.highlight then data.highlight.FillTransparency = v end
	end
end

function ESP:SetPlayerOutlineTransparency(v)
	_config.ESP_PLAYER_OUTLINE_TRANS = v
	for _, data in pairs(playerHighlights) do
		if data.highlight then data.highlight.OutlineTransparency = v end
	end
end

function ESP:SetLabelColor(c)
	_config.ESP_PLAYER_LABEL_COLOR = c
	for _, data in pairs(playerHighlights) do
		if data.label then data.label.TextColor3 = c end
	end
end

function ESP:SetLabelTransparency(v)
	_config.ESP_PLAYER_LABEL_TRANS = v
	for _, data in pairs(playerHighlights) do
		if data.label then data.label.TextTransparency = v end
	end
end

function ESP:Destroy()
	for _, c in pairs(internalConns) do
		pcall(function() c:Disconnect() end)
	end
	internalConns = {}
	CleanPlayerESP()
	CleanZombieESP()
	CleanNpcESP()
end

-- Return connections untuk di-Track di main.lua (tidak dipakai karena ESP manage sendiri)
function ESP:GetConnections()
	return internalConns
end

return ESP
