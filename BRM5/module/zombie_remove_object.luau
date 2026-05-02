local RemoveObject = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local CacheFolder = ReplicatedStorage:FindFirstChild("CacheFolder") or Instance.new("Folder")
CacheFolder.Name = "CacheFolder"
CacheFolder.Parent = ReplicatedStorage
local targetNames = {First = true,Last = true,Light = true,FULL = true,Unloaded = true}
local ENABLED = false
local DELAY_TIME = 0.2
local OriginalParents = {}

local function warnError(...)
    warn("[RemoveObject ERROR]:", ...)
end

local function moveDescendants(obj)
    task.delay(DELAY_TIME, function()
        if not ENABLED then return end

        local success, err = pcall(function()
            for _, desc in pairs(obj:GetDescendants()) do
                if not desc or not desc.Parent then
                    warnError("Invalid descendant detected")
                    continue
                end

                if not OriginalParents[desc] then
                    OriginalParents[desc] = desc.Parent
                end

                desc.Parent = CacheFolder
            end
        end)

        if not success then
            warnError("Failed moving descendants:", err)
        end

        -- handle descendant baru
        obj.DescendantAdded:Connect(function(desc)
            if not ENABLED then return end

            task.delay(DELAY_TIME, function()
                local ok, err2 = pcall(function()
                    if not desc or not desc.Parent then
                        warnError("Invalid new descendant")
                        return
                    end

                    if not OriginalParents[desc] then
                        OriginalParents[desc] = desc.Parent
                    end

                    desc.Parent = CacheFolder
                end)

                if not ok then
                    warnError("Error moving new descendant:", err2)
                end
            end)
        end)
    end)
end

function RemoveObject:Enable()
    ENABLED = true

    local ok, err = pcall(function()
        for _, obj in pairs(workspace:GetChildren()) do
            if targetNames[obj.Name] then
                moveDescendants(obj)
            end
        end
    end)

    if not ok then
        warnError("Enable failed:", err)
    end
end

function RemoveObject:Disable()
    ENABLED = false
    self:Restore()
end

function RemoveObject:Restore()
    local ok, err = pcall(function()
        for obj, parent in pairs(OriginalParents) do
            if obj and obj.Parent == CacheFolder then
                if parent and parent.Parent then
                    obj.Parent = parent
                else
                    warnError("Parent missing, fallback to workspace:", obj.Name)
                    obj.Parent = workspace
                end
            end
        end

        table.clear(OriginalParents)
    end)

    if not ok then
        warnError("Restore failed:", err)
    end
end

workspace.ChildAdded:Connect(function(obj)
    if not ENABLED then return end

    if targetNames[obj.Name] then
        local ok, err = pcall(function()
            moveDescendants(obj)
        end)

        if not ok then
            warnError("ChildAdded error:", err)
        end
    end
end)

return RemoveObject
