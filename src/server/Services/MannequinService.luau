local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local CollectionService = game:GetService("CollectionService")

local ProximityPromptFactory = require(ServerScriptService.Server.Shared.ProximityPromptFactory)
local Tags = require(ReplicatedStorage.Shared.Tags)

local MannequinService = {}

function MannequinService:PlaceMannequin(plot, platformId, mannequinId) : boolean
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

	for _, obj in ipairs(clone:GetDescendants()) do
		if obj:IsA("BasePart") then
			obj.Anchored = true
			obj.CanCollide = false
			obj.CanTouch = false
			obj.CanQuery = false
		end
	end

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

	local offset = CFrame.new(0, 3, 0) * CFrame.Angles(0, math.rad(180), 0)
	clone:PivotTo(spawnPart.CFrame * offset)

	return true
end

return MannequinService