local StateUI = {}

local UIS = game:GetService("UserInputService")

-- STATE STORAGE (ORDERED)
local states = {}
local stateIndex = {}

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "StateUI"
gui.Parent = game:GetService("CoreGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 140)
frame.Position = UDim2.new(0, 15, 0.5, -70)
frame.BackgroundColor3 = Color3.fromRGB(0,0,0)
frame.BackgroundTransparency = 0.25
frame.BorderSizePixel = 0
frame.Parent = gui

Instance.new("UICorner", frame)

local stroke = Instance.new("UIStroke", frame)
stroke.Color = Color3.fromRGB(70,70,70)

-- TITLE BAR
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 22)
title.BackgroundColor3 = Color3.fromRGB(10,10,10)
title.BackgroundTransparency = 0.2
title.Text = "STATE"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.Code
title.TextSize = 13
title.TextStrokeTransparency = 0.7
title.Parent = frame

-- MINIMIZE
local minimize = Instance.new("TextButton")
minimize.Size = UDim2.new(0, 22, 1, 0)
minimize.Position = UDim2.new(1, -22, 0, 0)
minimize.Text = "-"
minimize.BackgroundTransparency = 1
minimize.TextColor3 = Color3.new(1,1,1)
minimize.Font = Enum.Font.Code
minimize.TextSize = 14
minimize.Parent = title

-- CONTENT
local content = Instance.new("TextLabel")
content.Size = UDim2.new(1, -8, 1, -26)
content.Position = UDim2.new(0, 4, 0, 22)
content.BackgroundTransparency = 1
content.TextXAlignment = Enum.TextXAlignment.Left
content.TextYAlignment = Enum.TextYAlignment.Top
content.Font = Enum.Font.Code
content.TextSize = 12
content.RichText = true
content.Text = ""
content.Parent = frame

-- FORMAT VALUE (COLOR + ON/OFF)
local function format(v)
	if typeof(v) == "boolean" then
		if v then
			return '<b><font color="#00ff7f">ON</font></b>'
		else
			return '<b><font color="#ff4d4d">OFF</font></b>'
		end
	end

	if typeof(v) == "EnumItem" then
		return '<b>' .. v.Name .. '</b>'
	end

	return '<b>' .. tostring(v) .. '</b>'
end

-- REFRESH
local MAX_LINES = 15

local function refresh()
	local text = ""
	local count = 0

	for i, data in ipairs(states) do
		text ..= '<font color="#cccccc">' .. data.key .. '</font>: ' .. format(data.value) .. "<br/>"
		count += 1
		if count >= MAX_LINES then break end
	end

	content.Text = text
end

-- SET STATE
function StateUI:Set(key, value)
	if stateIndex[key] then
		local i = stateIndex[key]
		states[i].value = value
	else
		table.insert(states, { key = key, value = value })
		stateIndex[key] = #states
	end

	refresh()
end

-- CLEAR
function StateUI:Clear()
	table.clear(states)
	table.clear(stateIndex)
	refresh()
end

-- MINIMIZE
local minimized = false

minimize.MouseButton1Click:Connect(function()
	minimized = not minimized

	if minimized then
		content.Visible = false
		frame.Size = UDim2.new(0, 220, 0, 22)
		minimize.Text = "+"
	else
		content.Visible = true
		frame.Size = UDim2.new(0, 220, 0, 140)
		minimize.Text = "-"
	end
end)

-- DRAG
local dragging = false
local dragStart, startPos

title.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = frame.Position
	end
end)

title.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)

UIS.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart

		frame.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)

return StateUI