local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Tags = require(ReplicatedStorage.Shared.Tags)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local OpenMannequinCustomizationUIRemote =
	ReplicatedStorage.Remotes:WaitForChild(Remotes.OpenMannequinCustomizationUIRemote)

local connectedPrompts = {}

local function connectPrompt(prompt, callback)
	if connectedPrompts[prompt] then
		return
	end

	connectedPrompts[prompt] = true

	prompt.Triggered:Connect(function(player)
		callback(player)
	end)
end

local function connectMannequinCustomizationPrompt(instance)
	local platform = instance.Parent.Parent.Parent
	
	if not platform then
		warn("Platform not found.")
		return
	end

	local stand = platform:FindFirstChild("Stand", true)

	if not stand then
		warn("Stand not found for", platform:GetFullName())
		return
	end

	connectPrompt(instance, function(player)
		local platformId = platform:GetAttribute("PlatformId")
		local mannequinId = platform:GetAttribute("MannequinId")

		if not platformId then
			warn("PlatformId not found for", platform:GetFullName())
			return
		end

		if not mannequinId then
			warn("MannequinId not found for", platform:GetFullName())
			return
		end

		OpenMannequinCustomizationUIRemote:FireClient(
			player,
			mannequinId,
			platformId
		)
	end)
end

for _, instance in ipairs(CollectionService:GetTagged(Tags.OpenMannequinCustomizationUITag)) do
	connectMannequinCustomizationPrompt(instance)
end

CollectionService:GetInstanceAddedSignal(Tags.OpenMannequinCustomizationUITag):Connect(function(instance)
	connectMannequinCustomizationPrompt(instance)
end)