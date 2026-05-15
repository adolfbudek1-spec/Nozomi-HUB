local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local leaderstats = player:WaitForChild("leaderstats")
local cpValue = leaderstats:WaitForChild("Checkpoint")

local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")

local state = false
local delayTp = 0.3
local startCFrame = nil

local savedCP = {
	[1] = CFrame.new(5.090, 258.305, -225.744),
	[2] = CFrame.new(-28.629, 378.305, -770.197),
	[3] = CFrame.new(-142.581, 378.305, -1327.601),
	[4] = CFrame.new(-135.000, 426.352, -1857.776),
	[5] = CFrame.new(-526.276, 478.708, -2469.637),
	[6] = CFrame.new(-1206.370, 526.666, -2675.065),
	[7] = CFrame.new(-1773.977, 526.305, -3088.011),
	[8] = CFrame.new(-2156.053, 577.948, -3608.025),
	[9] = CFrame.new(-2711.977, 606.305, -3642.025),
	[10] = CFrame.new(-3370.977, 686.305, -3962.025),
	[11] = CFrame.new(-3855.977, 686.305, -4566.025),
	[12] = CFrame.new(-4237.943, 785.912, -5244.025),
	[13] = CFrame.new(-4734.977, 836.321, -5856.975),
	[14] = CFrame.new(-5357.977, 836.321, -6287.025),
	[15] = CFrame.new(-5361.054, 890.305, -6852.975),
	[16] = CFrame.new(-5473.023, 991.336, -7626.975),
	[17] = CFrame.new(-5815.977, 1041.321, -8348.975),
	[18] = CFrame.new(-6341.275, 1041.321, -8931.274),
	[19] = CFrame.new(-6928.583, 1141.321, -9453.861),
	[20] = CFrame.new(-7549.845, 1191.336, -9942.121),
	[21] = CFrame.new(-7867.975, 1191.336, -10663.023),
	[22] = CFrame.new(-7990.025, 1241.127, -11448.588),
	[23] = CFrame.new(-7783.975, 1341.321, -12191.977),
	[24] = CFrame.new(-7479.975, 1341.321, -12884.977),
	[25] = CFrame.new(-7474.975, 1526.321, -13501.977),
	[26] = CFrame.new(-7521.975, 1721.258, -14293.231),
	[27] = CFrame.new(-7297.385, 2388.046, -15026.231),
	[28] = CFrame.new(-7498.385, 3053.840, -15754.231),
	[29] = CFrame.new(-7297.385, 3720.840, -16501.230),
	[30] = CFrame.new(-7249.385, 4387.840, -17228.230),
	[31] = CFrame.new(-7244.632, 5838.305, -17885.750),
	[32] = CFrame.new(-6684.678, 5934.305, -17550.174),
	[33] = CFrame.new(-6405.141, 5934.305, -16479.379),
	[34] = CFrame.new(-6147.164, 5934.747, -15380.903),
	[35] = CFrame.new(-6617.856, 6070.305, -14270.959),
	[36] = CFrame.new(-7157.393, 6426.305, -14727.652),
	[37] = CFrame.new(-7919.979, 6451.617, -14674.761),
	[38] = CFrame.new(-7881.089, 6653.508, -13850.476),
	[39] = CFrame.new(-7437.387, 6831.773, -13122.044),
	[40] = CFrame.new(-6273.509, 6969.420, -13303.637),
	[41] = CFrame.new(-5437.076, 7085.731, -13271.331),
}

player.CharacterAdded:Connect(function(newChar)
	char = newChar
	hrp = char:WaitForChild("HumanoidRootPart")
end)

local function notify(text)
	pcall(function()
		StarterGui:SetCore("SendNotification", {
			Title = "⚡ CP Teleport",
			Text = text,
			Duration = 3
		})
	end)
end

local function teleportToCFrame(cf)
	if hrp and cf then
		hrp.CFrame = cf + Vector3.new(0, 4, 0)
	end
end

-- ========================
-- UI SETUP
-- ========================

local gui = Instance.new("ScreenGui")
gui.Name = "CheckpointTeleportUI"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = player:WaitForChild("PlayerGui")

-- === MAIN FRAME ===
local frame = Instance.new("Frame")
frame.Name = "MainFrame"
frame.Size = UDim2.new(0, 300, 0, 210)
frame.Position = UDim2.new(0, 20, 0.5, -105)
frame.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
frame.BorderSizePixel = 0
frame.ZIndex = 2
frame.ClipsDescendants = false
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

-- === BASE OUTLINE ===
local outlineStroke = Instance.new("UIStroke")
outlineStroke.Color = Color3.fromRGB(80, 40, 0)
outlineStroke.Thickness = 1.5
outlineStroke.Parent = frame

-- ========================
-- ROTATING COMET OUTLINE
-- 2 comet berlawanan arah, masing-masing punya ekor 4 dot
-- bergerak sepanjang perimeter panel
-- ========================
local PW, PH = 300, 210
local perimeter = (PW + PH) * 2

local function perimeterToPos(t)
	local dist = t * perimeter
	local x, y
	if dist <= PW then
		x, y = dist, 0
	elseif dist <= PW + PH then
		x, y = PW, dist - PW
	elseif dist <= PW * 2 + PH then
		x, y = PW - (dist - PW - PH), PH
	else
		x, y = 0, PH - (dist - PW * 2 - PH)
	end
	return UDim2.new(x / PW, 0, y / PH, 0)
end

local function makeDot(sz, col)
	local d = Instance.new("Frame")
	d.Size = UDim2.new(0, sz, 0, sz)
	d.BackgroundColor3 = col
	d.BorderSizePixel = 0
	d.ZIndex = 12
	d.AnchorPoint = Vector2.new(0.5, 0.5)
	d.Parent = frame
	Instance.new("UICorner", d).CornerRadius = UDim.new(1, 0)
	return d
end

-- Warna ekor: kepala terang → ujung gelap
local cometColors = {
	Color3.fromRGB(255, 230, 100),
	Color3.fromRGB(255, 160, 20),
	Color3.fromRGB(255, 80, 0),
	Color3.fromRGB(160, 40, 0),
}
local cometSizes = {5, 4, 3, 2}

local comet1 = {}
local comet2 = {}
for i = 1, 4 do
	comet1[i] = makeDot(cometSizes[i], cometColors[i])
	comet2[i] = makeDot(cometSizes[i], cometColors[i])
end

-- Orange top accent bar
local accentBar = Instance.new("Frame")
accentBar.Size = UDim2.new(1, 0, 0, 3)
accentBar.Position = UDim2.new(0, 0, 0, 0)
accentBar.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
accentBar.BorderSizePixel = 0
accentBar.ZIndex = 3
accentBar.Parent = frame
Instance.new("UICorner", accentBar).CornerRadius = UDim.new(0, 10)

local accentBarFix = Instance.new("Frame")
accentBarFix.Size = UDim2.new(1, 0, 0.5, 0)
accentBarFix.Position = UDim2.new(0, 0, 0.5, 0)
accentBarFix.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
accentBarFix.BorderSizePixel = 0
accentBarFix.ZIndex = 3
accentBarFix.Parent = accentBar

-- === ICON ===
local iconLabel = Instance.new("TextLabel")
iconLabel.Size = UDim2.new(0, 28, 0, 28)
iconLabel.Position = UDim2.new(0, 10, 0, 8)
iconLabel.BackgroundColor3 = Color3.fromRGB(255, 110, 0)
iconLabel.Text = "⚡"
iconLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
iconLabel.TextSize = 14
iconLabel.Font = Enum.Font.GothamBold
iconLabel.ZIndex = 4
iconLabel.Parent = frame
Instance.new("UICorner", iconLabel).CornerRadius = UDim.new(0, 6)

-- === TITLE ===
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -90, 0, 30)
title.Position = UDim2.new(0, 45, 0, 8)
title.BackgroundTransparency = 1
title.Text = "CP TELEPORT"
title.TextColor3 = Color3.fromRGB(255, 145, 20)
title.TextSize = 15
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.ZIndex = 4
title.Parent = frame

-- === STATUS ===
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -90, 0, 16)
statusLabel.Position = UDim2.new(0, 45, 0, 25)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "● STANDBY"
statusLabel.TextColor3 = Color3.fromRGB(120, 120, 130)
statusLabel.TextSize = 10
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.ZIndex = 4
statusLabel.Parent = frame

-- === CLOSE BUTTON ===
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 26, 0, 26)
closeBtn.Position = UDim2.new(1, -34, 0, 7)
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 12
closeBtn.BorderSizePixel = 0
closeBtn.ZIndex = 4
closeBtn.Parent = frame
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)

-- Divider
local divider = Instance.new("Frame")
divider.Size = UDim2.new(1, -20, 0, 1)
divider.Position = UDim2.new(0, 10, 0, 44)
divider.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
divider.BorderSizePixel = 0
divider.ZIndex = 3
divider.Parent = frame

-- === INFO ROW ===
local infoRow = Instance.new("Frame")
infoRow.Size = UDim2.new(1, -20, 0, 28)
infoRow.Position = UDim2.new(0, 10, 0, 52)
infoRow.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
infoRow.BorderSizePixel = 0
infoRow.ZIndex = 3
infoRow.Parent = frame
Instance.new("UICorner", infoRow).CornerRadius = UDim.new(0, 6)

local delayDisplay = Instance.new("TextLabel")
delayDisplay.Size = UDim2.new(0.5, -2, 1, 0)
delayDisplay.Position = UDim2.new(0, 0, 0, 0)
delayDisplay.BackgroundTransparency = 1
delayDisplay.TextColor3 = Color3.fromRGB(200, 200, 210)
delayDisplay.Font = Enum.Font.Gotham
delayDisplay.TextSize = 11
delayDisplay.Text = "DELAY  0.3s"
delayDisplay.ZIndex = 4
delayDisplay.Parent = infoRow

local cpDisplay = Instance.new("TextLabel")
cpDisplay.Size = UDim2.new(0.5, -2, 1, 0)
cpDisplay.Position = UDim2.new(0.5, 2, 0, 0)
cpDisplay.BackgroundTransparency = 1
cpDisplay.TextColor3 = Color3.fromRGB(255, 145, 20)
cpDisplay.Font = Enum.Font.GothamBold
cpDisplay.TextSize = 11
cpDisplay.Text = "CP  0 / 41"
cpDisplay.ZIndex = 4
cpDisplay.Parent = infoRow

local function updateInfo()
	delayDisplay.Text = "DELAY  " .. string.format("%.1f", delayTp) .. "s"
	cpDisplay.Text = "CP  " .. tostring(cpValue.Value) .. " / " .. tostring(#savedCP)
end

-- === SLIDER ===
local sliderLabel = Instance.new("TextLabel")
sliderLabel.Size = UDim2.new(1, -20, 0, 14)
sliderLabel.Position = UDim2.new(0, 10, 0, 86)
sliderLabel.BackgroundTransparency = 1
sliderLabel.Text = "TELEPORT DELAY"
sliderLabel.TextColor3 = Color3.fromRGB(90, 90, 100)
sliderLabel.Font = Enum.Font.GothamBold
sliderLabel.TextSize = 9
sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
sliderLabel.ZIndex = 4
sliderLabel.Parent = frame

local sliderBg = Instance.new("Frame")
sliderBg.Size = UDim2.new(1, -20, 0, 6)
sliderBg.Position = UDim2.new(0, 10, 0, 105)
sliderBg.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
sliderBg.BorderSizePixel = 0
sliderBg.ZIndex = 3
sliderBg.Parent = frame
Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(1, 0)

local sliderFill = Instance.new("Frame")
sliderFill.BackgroundColor3 = Color3.fromRGB(255, 130, 0)
sliderFill.BorderSizePixel = 0
sliderFill.ZIndex = 4
sliderFill.Parent = sliderBg
Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(1, 0)

local sliderBtn = Instance.new("TextButton")
sliderBtn.Size = UDim2.new(0, 16, 0, 16)
sliderBtn.BackgroundColor3 = Color3.fromRGB(255, 160, 30)
sliderBtn.Text = ""
sliderBtn.ZIndex = 5
sliderBtn.BorderSizePixel = 0
sliderBtn.Parent = sliderBg
Instance.new("UICorner", sliderBtn).CornerRadius = UDim.new(1, 0)

local knobGlow = Instance.new("Frame")
knobGlow.Size = UDim2.new(0, 26, 0, 26)
knobGlow.BackgroundColor3 = Color3.fromRGB(255, 120, 0)
knobGlow.BackgroundTransparency = 0.7
knobGlow.BorderSizePixel = 0
knobGlow.ZIndex = 4
knobGlow.Parent = sliderBg
Instance.new("UICorner", knobGlow).CornerRadius = UDim.new(1, 0)

local dragging = false

local function setSlider(percent)
	percent = math.clamp(percent, 0, 1)
	delayTp = math.floor((0.1 + percent * 1.9) * 10) / 10
	sliderFill.Size = UDim2.new(percent, 0, 1, 0)
	sliderBtn.Position = UDim2.new(percent, -8, 0.5, -8)
	knobGlow.Position = UDim2.new(percent, -13, 0.5, -13)
	updateInfo()
end

sliderBtn.MouseButton1Down:Connect(function() dragging = true end)
UIS.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)
UIS.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local percent = (input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X
		setSlider(percent)
	end
end)

-- === BUTTONS ===
local function makeButton(text, yPos, isStart)
	local btnFrame = Instance.new("Frame")
	btnFrame.Size = UDim2.new(0.5, -14, 0, 36)
	btnFrame.Position = isStart
		and UDim2.new(0, 10, 0, yPos)
		or UDim2.new(0.5, 4, 0, yPos)
	btnFrame.BackgroundColor3 = Color3.fromRGB(255, 120, 0)
	btnFrame.BackgroundTransparency = isStart and 0 or 1
	btnFrame.BorderSizePixel = 0
	btnFrame.ZIndex = 3
	btnFrame.Parent = frame
	Instance.new("UICorner", btnFrame).CornerRadius = UDim.new(0, 8)

	if not isStart then
		local btnBorder = Instance.new("UIStroke")
		btnBorder.Color = Color3.fromRGB(255, 100, 0)
		btnBorder.Thickness = 1.5
		btnBorder.Parent = btnFrame
	end

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 1, 0)
	btn.Position = UDim2.new(0, 0, 0, 0)
	btn.BackgroundTransparency = 1
	btn.Text = text
	btn.TextColor3 = isStart
		and Color3.fromRGB(255, 255, 255)
		or Color3.fromRGB(255, 130, 30)
	btn.TextSize = 13
	btn.Font = Enum.Font.GothamBold
	btn.ZIndex = 4
	btn.Parent = btnFrame

	btn.MouseEnter:Connect(function()
		TweenService:Create(btnFrame, TweenInfo.new(0.15), {
			BackgroundTransparency = isStart and 0 or 0.8
		}):Play()
		if isStart then
			TweenService:Create(btnFrame, TweenInfo.new(0.15), {
				BackgroundColor3 = Color3.fromRGB(255, 160, 30)
			}):Play()
		end
	end)
	btn.MouseLeave:Connect(function()
		TweenService:Create(btnFrame, TweenInfo.new(0.15), {
			BackgroundTransparency = isStart and 0 or 1
		}):Play()
		if isStart then
			TweenService:Create(btnFrame, TweenInfo.new(0.15), {
				BackgroundColor3 = Color3.fromRGB(255, 120, 0)
			}):Play()
		end
	end)

	return btn, btnFrame
end

local startBtn, startFrame = makeButton("▶  START", 126, true)
local cancelBtn, cancelFrame = makeButton("■  CANCEL", 126, false)

-- === PROGRESS BAR ===
local progressBg = Instance.new("Frame")
progressBg.Size = UDim2.new(1, -20, 0, 4)
progressBg.Position = UDim2.new(0, 10, 0, 170)
progressBg.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
progressBg.BorderSizePixel = 0
progressBg.ZIndex = 3
progressBg.Parent = frame
Instance.new("UICorner", progressBg).CornerRadius = UDim.new(1, 0)

local progressFill = Instance.new("Frame")
progressFill.Size = UDim2.new(0, 0, 1, 0)
progressFill.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
progressFill.BorderSizePixel = 0
progressFill.ZIndex = 4
progressFill.Parent = progressBg
Instance.new("UICorner", progressFill).CornerRadius = UDim.new(1, 0)

local progressLabel = Instance.new("TextLabel")
progressLabel.Size = UDim2.new(1, -20, 0, 14)
progressLabel.Position = UDim2.new(0, 10, 0, 176)
progressLabel.BackgroundTransparency = 1
progressLabel.Text = "PROGRESS  0%"
progressLabel.TextColor3 = Color3.fromRGB(80, 80, 90)
progressLabel.Font = Enum.Font.GothamBold
progressLabel.TextSize = 9
progressLabel.TextXAlignment = Enum.TextXAlignment.Left
progressLabel.ZIndex = 4
progressLabel.Parent = frame

local function updateProgress()
	local pct = math.clamp(cpValue.Value / #savedCP, 0, 1)
	TweenService:Create(progressFill, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {
		Size = UDim2.new(pct, 0, 1, 0)
	}):Play()
	progressLabel.Text = "PROGRESS  " .. math.floor(pct * 100) .. "%"
end

-- ========================
-- LOGIC
-- ========================

local function setStatus(isActive)
	if isActive then
		statusLabel.Text = "● RUNNING"
		statusLabel.TextColor3 = Color3.fromRGB(255, 150, 30)
	else
		statusLabel.Text = "● STANDBY"
		statusLabel.TextColor3 = Color3.fromRGB(80, 80, 90)
	end
end

local function StartAction()
	if state then notify("Teleport masih berjalan") return end
	state = true
	startCFrame = hrp.CFrame
	setStatus(true)
	notify("Teleport dimulai")
	task.spawn(function()
		while state do
			local currentCP = cpValue.Value
			local targetCP = currentCP + 1

			if currentCP >= 41 then
				notify("CP 41! Menuju finish...")
				teleportToCFrame(CFrame.new(-5413.32470703125, 7076.3271484375, -13306.9658203125))
				task.wait(1)
				if not state then break end
				notify("Ulang dari CP 1")
				local cpCFrame = savedCP[1]
				if cpCFrame then
					teleportToCFrame(cpCFrame)
					updateProgress()
				end
				task.wait(delayTp)
				continue
			end

			if currentCP == 40 then
				targetCP = 41
			end

			local cpCFrame = savedCP[targetCP]
			if cpCFrame then
				teleportToCFrame(cpCFrame)
				updateProgress()
				task.wait(delayTp)
			else
				task.wait(delayTp)
			end
		end
	end)
end

local function CancelAction()
	if not state then notify("Teleport tidak berjalan") return end
	state = false
	if startCFrame and hrp then
		hrp.CFrame = startCFrame
	end
	setStatus(false)
	notify("Teleport dibatalkan")
end

startBtn.MouseButton1Click:Connect(StartAction)
cancelBtn.MouseButton1Click:Connect(CancelAction)

closeBtn.MouseButton1Click:Connect(function()
	TweenService:Create(frame, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
		Size = UDim2.new(0, 300, 0, 0),
		Position = UDim2.new(0, 20, 0.5, 0)
	}):Play()
	task.wait(0.3)
	gui.Enabled = false
	notify("UI ditutup")
end)

cpValue:GetPropertyChangedSignal("Value"):Connect(function()
	updateInfo()
	updateProgress()
end)

-- ========================
-- ANIMATIONS (RunService)
-- ========================

local glowTime = 0
local TAIL_GAP = 0.02  -- jarak antar dot ekor (0..1 perimeter)
local SPEED = 0.45     -- putaran per detik

RunService.RenderStepped:Connect(function(dt)
	glowTime = glowTime + dt

	-- Posisi kepala 2 comet (berlawanan = +0.5)
	local t1 = (glowTime * SPEED) % 1
	local t2 = (t1 + 0.5) % 1

	for i = 1, 4 do
		local offset = (i - 1) * TAIL_GAP
		comet1[i].Position = perimeterToPos((t1 - offset + 1) % 1)
		comet2[i].Position = perimeterToPos((t2 - offset + 1) % 1)
	end

	-- Outline base pulse (gelap ke sedikit lebih terang)
	local pulse = (math.sin(glowTime * 2) + 1) / 2
	outlineStroke.Color = Color3.fromRGB(
		math.floor(80 + pulse * 50),
		math.floor(20 + pulse * 20),
		0
	)

	-- Accent bar shimmer
	local shimmer = (math.sin(glowTime * 4) + 1) / 2
	accentBar.BackgroundColor3 = Color3.fromRGB(255, math.floor(120 + shimmer * 60), 0)

	-- Knob glow breathe
	local knobPulse = (math.sin(glowTime * 5) + 1) / 2
	knobGlow.BackgroundTransparency = 0.5 + knobPulse * 0.35

	-- Status dot blink when running
	if state then
		local blink = math.floor(glowTime * 2) % 2 == 0
		statusLabel.TextColor3 = blink
			and Color3.fromRGB(255, 160, 40)
			or Color3.fromRGB(200, 100, 20)
	end
end)

-- ========================
-- STARTUP ANIMATION
-- ========================

frame.Size = UDim2.new(0, 0, 0, 0)
frame.Position = UDim2.new(0, 20, 0.5, 0)

task.wait(0.1)

TweenService:Create(frame, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
	Size = UDim2.new(0, 300, 0, 210),
	Position = UDim2.new(0, 20, 0.5, -105)
}):Play()

-- Init
setSlider((delayTp - 0.1) / 1.9)
updateInfo()
updateProgress()
notify("⚡ CP Teleport Loaded!")