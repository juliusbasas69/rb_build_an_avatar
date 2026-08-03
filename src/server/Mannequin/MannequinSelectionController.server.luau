local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Tags = require(ReplicatedStorage.Shared.Tags)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local OpenMannequinSelectorUIRemote =
	ReplicatedStorage.Remotes:WaitForChild(Remotes.OpenMannequinSelectorUIRemote)

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

local function connectMannequinSelectorPrompt(instance)
	local platform = instance.Parent.Parent

	if not platform then
		warn("Platform not found.")
		return
	end

	local stand = platform:FindFirstChild("Stand")

	if not stand then
		warn("Stand not found for", platform:GetFullName())
		return
	end

	local prompt = stand:FindFirstChild("ProximityPrompt")

	if not prompt then
		warn("ProximityPrompt not found for", platform:GetFullName())
		return
	end

	connectPrompt(prompt, function(player)
		local platformId = platform:GetAttribute("PlatformId")

		if not platformId then
			warn("PlatformId not found for", platform:GetFullName())
			return
		end

		OpenMannequinSelectorUIRemote:FireClient(
			player,
			platformId
		)
	end)
end

for _, instance in ipairs(CollectionService:GetTagged(Tags.OpenMannequinSelectorUITag)) do
	connectMannequinSelectorPrompt(instance)
end

CollectionService:GetInstanceAddedSignal(Tags.OpenMannequinSelectorUITag):Connect(function(instance)
	connectMannequinSelectorPrompt(instance)
end)