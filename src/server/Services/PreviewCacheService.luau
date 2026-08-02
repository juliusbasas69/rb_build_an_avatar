local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local mannequinTemplate = ReplicatedStorage.Models.Mannequin

local CacheFolder = ServerStorage:FindFirstChild("CacheAssets")

if not CacheFolder then
    CacheFolder = Instance.new("Folder")
    CacheFolder.Name = "CacheAssets"
    CacheFolder.Parent = ServerStorage
end

local PreviewCacheService = {}

function PreviewCacheService:GetPreview(assetId)

    local cached = CacheFolder:FindFirstChild(tostring(assetId))

    if cached then
        return cached
    end

    -------------------
    -- Create preview
    -------------------

    local mannequin = mannequinTemplate:Clone()

    local humanoid = mannequin.Humanoid

    local description = Instance.new("HumanoidDescription")

    description.Shirt = assetId

    humanoid:ApplyDescription(description)

    mannequin.Name = tostring(assetId)
    mannequin.Parent = CacheFolder

    return mannequin
end

return PreviewCacheService