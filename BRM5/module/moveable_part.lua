local MoveablePart = {}

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer

-- Folder safe
local nozomiDebris = workspace:FindFirstChild("_nozomiDebris")
if not nozomiDebris then
	nozomiDebris = Instance.new("Folder")
	nozomiDebris.Name = "_nozomiDebris"
	nozomiDebris.Parent = workspace
end

-- State
local moveDir = 0
local moveConn, inputBeganConn, inputEndedConn

local PLATFORM = {
	SPAWNED = false,
	SPEED = 0.4,
	TRANSPARENCY = 0.4,
	MATERIAL = Enum.Material.Plastic
}

-- Get root
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

-- SPAWN PLATFORM
local function spawnPlatform()
	local hrp = GetRoot()
	if not hrp then
		warn("RootPart not found...")
		return
	end

	local size = 2048
	local half = 2

	for x = -half, half do
		for z = -half, half do
			local part = Instance.new("Part")

			part.Name = "platform"
			part.Size = Vector3.new(size, 1, size)
			part.Anchored = true
			part.CanCollide = true
			part.Transparency = PLATFORM.TRANSPARENCY
			part.Material = PLATFORM.MATERIAL

			part.Position = Vector3.new(
				hrp.Position.X + x * size,
				hrp.Position.Y - 10,
				hrp.Position.Z + z * size
			)

			part.Parent = nozomiDebris
		end
	end
end

-- REMOVE PLATFORM
local function removePlatform()
	for _, part in ipairs(nozomiDebris:GetChildren()) do
		if part.Name == "platform" then
			part:Destroy()
		end
	end
end

-- MOVE SYSTEM
local function startMovement()
	if moveConn then return end

	inputBeganConn = UserInputService.InputBegan:Connect(function(input, gp)
		if gp then return end

		if input.KeyCode == Enum.KeyCode.J then
			moveDir = 1
		elseif input.KeyCode == Enum.KeyCode.K then
			moveDir = -1
		end
	end)

	inputEndedConn = UserInputService.InputEnded:Connect(function(input)
		if input.KeyCode == Enum.KeyCode.J or input.KeyCode == Enum.KeyCode.K then
			moveDir = 0
		end
	end)

	moveConn = RunService.RenderStepped:Connect(function()
		if moveDir ~= 0 then
			for _, part in ipairs(nozomiDebris:GetChildren()) do
				if part.Name == "platform" then
					part.Position += Vector3.new(0, PLATFORM.SPEED * moveDir, 0)
				end
			end
		end
	end)
end

-- TOGGLE MAIN
function MoveablePart:togglePlatform()
	local hrp = GetRoot()
	if not hrp then
		warn("Rootpart not found...")
		return
	end

	if PLATFORM.SPAWNED then
		removePlatform()

		if moveConn then moveConn:Disconnect() moveConn = nil end
		if inputBeganConn then inputBeganConn:Disconnect() inputBeganConn = nil end
		if inputEndedConn then inputEndedConn:Disconnect() inputEndedConn = nil end

		PLATFORM.SPAWNED = false
	else
		spawnPlatform()
		startMovement()
		PLATFORM.SPAWNED = true
	end
end

-- SETTER SYSTEM
function MoveablePart:setValue(name, value)
	if name == "spawn" then
		PLATFORM.SPAWNED = value

	elseif name == "speed" then
		PLATFORM.SPEED = value

	elseif name == "transparency" then
		PLATFORM.TRANSPARENCY = value

		for _, part in ipairs(nozomiDebris:GetChildren()) do
			if part.Name == "platform" then
				part.Transparency = value
			end
		end

	elseif name == "material" then
		PLATFORM.MATERIAL = value

		for _, part in ipairs(nozomiDebris:GetChildren()) do
			if part.Name == "platform" then
				part.Material = value
			end
		end
	end
end

return MoveablePart