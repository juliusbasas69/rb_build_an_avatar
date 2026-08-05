local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local CollectionService = game:GetService("CollectionService")

local ProximityPromptFactory = require(ServerScriptService.Server.Shared.ProximityPromptFactory)
local PlayerService = require(ServerScriptService.Server.Player.PlayerService)
local Tags = require(ReplicatedStorage.Shared.Tags)

local MannequinService = {}

local function PlaceMannequinOnPlatform(model, spawnPart)
	local _, size = model:GetBoundingBox()

	local offset = CFrame.new(0, size.Y / 1.35, 0) * CFrame.Angles(0, math.rad(180), 0)

	model:PivotTo(spawnPart.CFrame * offset)
end

function MannequinService:PlaceMannequin(plot, platformId, mannequinId) : boolean

	local platformsFolder = plot:WaitForChild("Platforms")
	local platformModel = platformsFolder:FindFirstChild(platformId)

	platformModel:SetAttribute("MannequinId", true)

	if not platformModel then
		warn("Platform P" .. platformId .. " not found.")
		return false
	end

	local stand = platformModel:WaitForChild("Stand")

	if not stand then
		warn("Stand not found for platform P" .. platformId)
		return false
	end

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

	PlaceMannequinOnPlatform(clone, stand)

	return true
end

function MannequinService:LoadMannequins(player, plot)
	local playerData = PlayerService:GetPlayer(player)

	if not playerData then
		warn("PlayerData not found for player: " .. player.Name)
		return
	end

	local platforms = playerData.Platforms

	local platformsFolder = plot:WaitForChild("Platforms")

	for platformId, platformData in pairs(platforms) do
		if platformData.HasMannequin then

			local placedMannequin = platformData.PlacedMannequin
			local mannequinId = placedMannequin.MannequinId

			local platformModel = platformsFolder:FindFirstChild(platformId)

			if platformModel then

				local prompt = platformModel:FindFirstChildWhichIsA("ProximityPrompt", true)
				if prompt then
					prompt.Enabled = false
				end

				self:PlaceMannequin(plot, platformId, mannequinId)
			else
				warn("Platform P" .. platformId .. " not found.")
			end
		end
	end
end

return MannequinService