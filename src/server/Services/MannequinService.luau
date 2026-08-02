local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local CollectionService = game:GetService("CollectionService")

local ProximityPromptFactory = require(ServerScriptService.Server.Shared.ProximityPromptFactory)
local PlayerService = require(ServerScriptService.Server.Services.PlayerService)
local Tags = require(ReplicatedStorage.Shared.Tags)

local PlacedMannequinData = require(ReplicatedStorage.Shared.Data.PlacedMannequinData)

local MannequinService = {}

local function DeepClone(tbl)
	local clone = {}

	for key, value in pairs(tbl) do
		if type(value) == "table" then
			clone[key] = DeepClone(value)
		else
			clone[key] = value
		end
	end

	return clone
end

local function PlaceMannequinOnPlatform(model, spawnPart)
	local _, size = model:GetBoundingBox()

	local offset =
		CFrame.new(0, size.Y / 2, 0)
		* CFrame.Angles(0, math.rad(180), 0)

	model:PivotTo(spawnPart.CFrame * offset)
end

function MannequinService:PlaceMannequin(player, plot, platformId, mannequinId) : boolean

	local PlayerData = PlayerService:GetPlayer(player)

	if not PlayerData then
		warn("PlayerData not found for player: " .. player.Name)
		return false
	end

	local platformsFolder = plot:WaitForChild("Platforms")
	local platformModel = platformsFolder:FindFirstChild(platformId)

    platformModel:FindFirstChild("HasMannequin", true).Value = true

	if not platformModel then
		warn("Platform P" .. platformId .. " not found.")
		return false
	end

	local spawnPart = platformModel:WaitForChild("Platform")

	local mannequin = ReplicatedStorage.Mannequins:FindFirstChild(mannequinId)

	if not mannequin then
		warn("Mannequin '" .. mannequinId .. "' does not exist.")
		return false
	end

	-- Remove existing mannequin if there is one
	local existing = platformModel:FindFirstChild("PlacedMannequin")
	if existing then
		existing:Destroy()
	end

	local clone = mannequin:Clone()
	clone.Name = "PlacedMannequin"
	clone.Parent = platformModel

	local humanoid = clone:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
		humanoid.AutoRotate = false
	end

    -- Add ProximityPrompt
	local humanoidRootPart = clone:FindFirstChild("HumanoidRootPart")

    if humanoidRootPart then
        local prompt = ProximityPromptFactory:Create({
            Parent = humanoidRootPart,
            ActionText = "Dress",
            ObjectText = "Mannequin",
        })

        CollectionService:AddTag(prompt, Tags.OpenMannequinCustomizationUITag)
    end

	local placedMannequin = DeepClone(PlacedMannequinData)
	placedMannequin.MannequinId = mannequinId

	PlayerData.Platforms[platformId].MannequinId = mannequinId
	PlayerData.Platforms[platformId].HasMannequin = true
	PlayerData.Platforms[platformId].PlacedMannequin = placedMannequin

	PlayerService:UpdatePlayer(player)

	PlaceMannequinOnPlatform(clone, spawnPart)

	return true
end

function MannequinService:LoadMannequins(player, plot)
	local PlayerData = PlayerService:GetPlayer(player)

	if not PlayerData then
		warn("PlayerData not found for player: " .. player.Name)
		return
	end

	local platformsFolder = plot:WaitForChild("Platforms")

	for platformId, platformData in pairs(PlayerData.Platforms) do
		if platformData.HasMannequin and platformData.MannequinId then
			local platformModel = platformsFolder:FindFirstChild(platformId)

			if platformModel then
				self:PlaceMannequin(player, plot, platformId, platformData.MannequinId)
			else
				warn("Platform P" .. platformId .. " not found.")
			end
		end
	end
end

return MannequinService