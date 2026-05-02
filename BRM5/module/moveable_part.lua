local MoveablePart = {}

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Player = game:GetService("Players").LocalPlayer

local nozomiDebris = workspace:FindFirstChild("_nozomiDebris")
if not nozomiDebris then
	nozomiDebris = Instance.new("Folder")
	nozomiDebris.Name = "_nozomiDebris"
	nozomiDebris.Parent = workspace
end

local CONFIG = {
	IS_SHOW = nil,
	SPEED = nil,
	TRANSPARENCY = nil,
	MATERIAL = nil,

	MOVE_DIR = 0,
	MOVE_CON = nil,
	INPUT_BEGAN_CON = nil,
	INPUT_ENDED_CON = nil
}

local function GetRoot()
	local wm = Player:FindFirstChild("WorldModel")
	if not wm then return nil end

	local male = wm:FindFirstChild("Male")
	if male and male:FindFirstChild("Root") then
		return male.Root
	end

	if wm:FindFirstChild("WorldModel") then
		local model = wm.WorldModel:FindFirstChild("Model")
		if model and model:FindFirstChild("Root") then
			return model.Root
		end
	end

	return nil
end

local function removePlatform()
	for _, part in ipairs(nozomiDebris:GetChildren()) do
		if part.Name == "platform" then
			part:Destroy()
		end
	end
end

local function spawnPlatform()
	local hrp = GetRoot()
	if not hrp then
		warn("RootPart not found...")
		return
	end

	removePlatform()

	local size = 2048
	local range = 8

	for x = -range, range do
		for z = -range, range do
			local part = Instance.new("Part")

			part.Name = "platform"
			part.Size = Vector3.new(size, 1, size)
			part.Anchored = true
			part.CanCollide = true
			part.Transparency = CONFIG.TRANSPARENCY
			part.Material = CONFIG.MATERIAL

			part.Position = Vector3.new(
				x * size,
				hrp.Position.Y - 10,
				z * size
			)

			part.Parent = nozomiDebris
		end
	end
end

local function startMovement()
	if CONFIG.MOVE_CON then return end

	CONFIG.INPUT_BEGAN_CON = UserInputService.InputBegan:Connect(function(input, gp)
		if gp then return end
		if input.KeyCode == Enum.KeyCode.J then
			CONFIG.MOVE_DIR = 1
		elseif input.KeyCode == Enum.KeyCode.K then
			CONFIG.MOVE_DIR = -1
		end
	end)

	CONFIG.INPUT_ENDED_CON = UserInputService.InputEnded:Connect(function(input)
		if input.KeyCode == Enum.KeyCode.J or input.KeyCode == Enum.KeyCode.K then
			CONFIG.MOVE_DIR = 0
		end
	end)

	CONFIG.MOVE_CON = RunService.RenderStepped:Connect(function()
		if CONFIG.MOVE_DIR ~= 0 then
			for _, part in ipairs(nozomiDebris:GetChildren()) do
				if part.Name == "platform" then
					part.Position += Vector3.new(0, CONFIG.SPEED * CONFIG.MOVE_DIR, 0)
				end
			end
		end
	end)
end

local function stopMovement()
	if CONFIG.MOVE_CON then CONFIG.MOVE_CON:Disconnect() CONFIG.MOVE_CON = nil end
	if CONFIG.INPUT_BEGAN_CON then CONFIG.INPUT_BEGAN_CON:Disconnect() CONFIG.INPUT_BEGAN_CON = nil end
	if CONFIG.INPUT_ENDED_CON then CONFIG.INPUT_ENDED_CON:Disconnect() CONFIG.INPUT_ENDED_CON = nil end
end

function MoveablePart:setValue(name, value)
	if name == "spawn" then
		if value then
			spawnPlatform()
			startMovement()
		else
			removePlatform()
			stopMovement()
		end

		CONFIG.IS_SHOW = value

	elseif name == "speed" then
		CONFIG.SPEED = value

	elseif name == "transparency" then
		CONFIG.TRANSPARENCY = value

		for _, part in ipairs(nozomiDebris:GetChildren()) do
			if part.Name == "platform" then
				part.Transparency = value
			end
		end

	elseif name == "material" then
		CONFIG.MATERIAL = value

		for _, part in ipairs(nozomiDebris:GetChildren()) do
			if part.Name == "platform" then
				part.Material = value
			end
		end
	end
end

function MoveablePart:AssignAllConfig(config)
	MoveablePart:setValue("spawn", config.PLATFORM_SHOW)
	MoveablePart:setValue("speed", config.PLATFORM_SPEED)
	MoveablePart:setValue("transparency", config.PLATFORM_TRANSPARENCY)
	MoveablePartModule:setValue("material", Config.PLATFORM_MATERIAL)
end

return MoveablePart