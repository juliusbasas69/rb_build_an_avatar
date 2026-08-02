-- local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- local mannequinTemplate = ReplicatedStorage.Models:WaitForChild("BaseMannequin")

-- local CacheFolder = ReplicatedStorage:FindFirstChild("CacheAssets")

-- if not CacheFolder then
-- 	CacheFolder = Instance.new("Folder")
-- 	CacheFolder.Name = "CacheAssets"
-- 	CacheFolder.Parent = ReplicatedStorage
-- end

-- local PreviewCacheService = {}

-- function PreviewCacheService:GetPreview(assetId)

-- 	local cached = CacheFolder:FindFirstChild(tostring(assetId))

-- 	if cached then
-- 		return cached
-- 	end

-- 	-------------------
-- 	-- Create preview
-- 	-------------------

-- 	local mannequin = mannequinTemplate:Clone()

--     mannequin.Name = tostring(assetId)
--     mannequin.Parent = CacheFolder -- ✅ parent first

--     local humanoid = mannequin:WaitForChild("Humanoid")

--  local description = Instance.new("HumanoidDescription")

--     local white = Color3.fromRGB(255, 255, 255)

--     description.HeadColor = white
--     description.TorsoColor = white
--     description.LeftArmColor = white
--     description.RightArmColor = white
--     description.LeftLegColor = white
--     description.RightLegColor = white

--     description.Shirt = assetId

--     humanoid:ApplyDescriptionAsync(description)


--     local success, err = pcall(function()

--         print("Applying description for assetId:", assetId)

--         humanoid:ApplyDescriptionAsync(description)

--     end)


--     if not success then
--         warn("Failed to create preview:", assetId, err)
--         mannequin:Destroy()
--         return nil
--     end

-- 	mannequin.Parent = CacheFolder

-- 	return mannequin
-- end

-- return PreviewCacheService