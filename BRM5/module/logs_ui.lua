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
frame.Size = UDim2.new(0, 260, 0, 180)
frame.Position = UDim2.new(0, 20, 0.5, -90)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.BorderSizePixel = 0
frame.Parent = gui

-- TITLE BAR
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 25)
title.BackgroundColor3 = Color3.fromRGB(35,35,35)
title.Text = "STATE LOGGER"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.Code
title.TextSize = 14
title.Parent = frame

-- MINIMIZE BUTTON
local minimize = Instance.new("TextButton")
minimize.Size = UDim2.new(0, 25, 1, 0)
minimize.Position = UDim2.new(1, -25, 0, 0)
minimize.Text = "-"
minimize.BackgroundTransparency = 1
minimize.TextColor3 = Color3.new(1,1,1)
minimize.Parent = title

-- CONTENT
local content = Instance.new("TextLabel")
content.Size = UDim2.new(1, -10, 1, -30)
content.Position = UDim2.new(0, 5, 0, 25)
content.BackgroundTransparency = 1
content.TextXAlignment = Enum.TextXAlignment.Left
content.TextYAlignment = Enum.TextYAlignment.Top
content.Font = Enum.Font.Code
content.TextSize = 13
content.TextColor3 = Color3.fromRGB(180,180,180)
content.Text = ""
content.TextWrapped = false
content.Parent = frame

-- FORMAT VALUE
local function format(v)
	if typeof(v) == "EnumItem" then
		return v.Name
	end
	return tostring(v)
end

-- REFRESH UI
local function refresh()
	local text = ""

	for i, data in ipairs(states) do
		text ..= data.key .. " : " .. format(data.value) .. "\n"
	end

	content.Text = text
end

-- SET STATE
function StateUI:Set(key, value)
	if stateIndex[key] then
		local i = stateIndex[key]
		states[i].value = value
	else
		table.insert(states, {
			key = key,
			value = value
		})
		stateIndex[key] = #states
	end

	refresh()
end

-- CLEAR (optional)
function StateUI:Clear()
	states = {}
	stateIndex = {}
	refresh()
end

-- MINIMIZE
local minimized = false

minimize.MouseButton1Click:Connect(function()
	minimized = not minimized

	if minimized then
		content.Visible = false
		frame.Size = UDim2.new(0, 260, 0, 25)
		minimize.Text = "+"
	else
		content.Visible = true
		frame.Size = UDim2.new(0, 260, 0, 180)
		minimize.Text = "-"
	end
end)

-- DRAG SYSTEM
local dragging = false
local dragStart, startPos

title.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = frame.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

title.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
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