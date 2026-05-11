--[[============== REMOVEWORLD MODULE ==============]]
local RemoveWorld = {}

local _services  = nil
local _config    = nil
local _track     = nil

local CacheFolder     = nil
local OriginalParents = {}
local ENABLED         = false
local DELAY           = 0.2

local removeTargets = {
	First    = true,
	Last     = true,
	Light    = true,
	FULL     = true,
	Unloaded = true,
}

local internalConns = {}
local function addConn(c) table.insert(internalConns, c) end

-- ── Move descendants to CacheFolder ──────────────────────────────────────────
local function MoveDescendants(obj)
	task.delay(DELAY, function()
		if not ENABLED then return end
		pcall(function()
			for _, desc in pairs(obj:GetDescendants()) do
				if desc and desc.Parent and desc.Parent ~= CacheFolder then
					if not OriginalParents[desc] then
						OriginalParents[desc] = desc.Parent
					end
					desc.Parent = CacheFolder
				end
			end
		end)

		addConn(obj.DescendantAdded:Connect(function(desc)
			if not ENABLED then return end
			task.delay(DELAY, function()
				pcall(function()
					if desc and desc.Parent and desc.Parent ~= CacheFolder then
						if not OriginalParents[desc] then
							OriginalParents[desc] = desc.Parent
						end
						desc.Parent = CacheFolder
					end
				end)
			end)
		end))
	end)
end

-- ── Restore semua ke parent asli ─────────────────────────────────────────────
local function Restore()
	pcall(function()
		for obj, parent in pairs(OriginalParents) do
			if obj and obj.Parent == CacheFolder then
				if parent and parent.Parent then
					obj.Parent = parent
				else
					obj.Parent = workspace
				end
			end
		end
		table.clear(OriginalParents)
	end)
end

-- ── Public API ────────────────────────────────────────────────────────────────
function RemoveWorld:Init(ctx)
	_services = ctx.Services
	_config   = ctx.Config
	_track    = ctx.Track

	-- Setup CacheFolder
	local RS = _services.ReplicatedStorage
	CacheFolder        = RS:FindFirstChild("CacheFolder") or Instance.new("Folder")
	CacheFolder.Name   = "CacheFolder"
	CacheFolder.Parent = RS

	-- Watch for new children di workspace
	addConn(workspace.ChildAdded:Connect(function(obj)
		if ENABLED and removeTargets[obj.Name] then
			MoveDescendants(obj)
		end
	end))
end

function RemoveWorld:Enable()
	ENABLED = true
	_config.REMOVE_OBJECT = true
	for _, obj in pairs(workspace:GetChildren()) do
		if removeTargets[obj.Name] then
			MoveDescendants(obj)
		end
	end
end

function RemoveWorld:Disable()
	ENABLED = false
	_config.REMOVE_OBJECT = false
	Restore()
end

function RemoveWorld:IsEnabled()
	return ENABLED
end

function RemoveWorld:Destroy()
	ENABLED = false
	Restore()
	table.clear(OriginalParents)

	for _, c in pairs(internalConns) do
		pcall(function() c:Disconnect() end)
	end
	internalConns = {}
end

return RemoveWorld
