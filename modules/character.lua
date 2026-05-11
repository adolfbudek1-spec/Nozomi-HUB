--[[============== CHARACTER ==============]]
local Character = {}
local _services  = nil
local _player    = nil

function Character:Init(ctx)
	_services = ctx.Services
	_player   = ctx.Player
end

-- Cari Male milik local player berdasarkan proximity ke RootPos
function Character:GetMyMale()
	local ok, pos = pcall(function() return self:GetRootPos() end)
	if not ok or not pos then return nil end
	for _, m in workspace:GetDescendants() do
		if m.Name == "Male" and m:FindFirstChild("Root") then
			if (m.Root.Position - pos).Magnitude < 30 then
				return m
			end
		end
	end
	return nil
end

-- Ambil object Root dari male player
function Character:GetRoot()
	local male = self:GetMyMale()
	if male then return male:FindFirstChild("Root") end
	return nil
end

-- Ambil posisi Root player (support WorldModel dan karakter biasa)
function Character:GetRootPos()
	-- Coba dari camera WorldModel
	local cam = workspace.CurrentCamera
	if cam then
		local wm = cam:FindFirstChild("WorldModel")
		if wm and wm:FindFirstChild("Model") and wm.Model:FindFirstChild("Root") then
			return wm.Model.Root.Position
		end
	end
	-- Coba dari player WorldModel
	if _player then
		local wm1 = _player:FindFirstChild("WorldModel")
		if wm1 then
			local wm2 = wm1:FindFirstChild("WorldModel")
			if wm2 and wm2:FindFirstChild("Model") and wm2.Model:FindFirstChild("Root") then
				return wm2.Model.Root.Position
			end
		end
	end
	return nil
end

-- Ambil karakter standar Roblox (fallback)
function Character:GetCharacter()
	if _player then return _player.Character end
	return nil
end

-- Cek apakah player masih hidup (ada humanoid dengan health > 0)
function Character:IsAlive()
	local char = self:GetCharacter()
	if not char then return false end
	local hum = char:FindFirstChildOfClass("Humanoid")
	return hum and hum.Health > 0 or false
end

return Character
