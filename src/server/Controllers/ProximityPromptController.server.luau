local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Tags = require(ReplicatedStorage.Shared.Tags)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local OpenMannequinSelectorUIRemote = ReplicatedStorage.Remotes:WaitForChild(Remotes.OpenMannequinSelectorUIRemote)
local OpenMannequinCustomizationUIRemote = ReplicatedStorage.Remotes:WaitForChild(Remotes.OpenMannequinCustomizationUIRemote)

local AssetService = require(ServerScriptService.Server.Services.AssetService)

local connectedPrompts = {}

local function connectPrompt(prompt, callback)
	if connectedPrompts[prompt] then
		return
	end

	connectedPrompts[prompt] = true

	prompt.Triggered:Connect(function(player)
		callback(player, prompt)
	end)
end

local function connectTaggedPlatforms(tag, callback)
	for _, instance in ipairs(CollectionService:GetTagged(tag)) do
		callback(instance.Parent)
	end

	CollectionService:GetInstanceAddedSignal(tag):Connect(function(instance)
		callback(instance.Parent)
	end)
end

-- Buy Item Prompt

local function handleBuyItemPrompt(player, prompt)
	local accessory = prompt.Parent
	AssetService:BuyAsset(player, accessory)
end

for _, prompt in ipairs(CollectionService:GetTagged(Tags.BuyAssetPrompt)) do
	connectPrompt(prompt, handleBuyItemPrompt)
end

CollectionService:GetInstanceAddedSignal(Tags.BuyAssetPrompt):Connect(function(prompt)
	connectPrompt(prompt, handleBuyItemPrompt)
end)

-- Mannequin Selector Prompt

local function connectMannequinSelectorPrompt(platform)
	local prompt = platform:FindFirstChild("ProximityPrompt", true)

	if not prompt then
		warn("ProximityPrompt not found for", platform:GetFullName())
		return
	end

	connectPrompt(prompt, function(player)
		OpenMannequinSelectorUIRemote:FireClient(
			player,
			platform.PlatformId.Value
		)
	end)
end

connectTaggedPlatforms(
	Tags.OpenMannequinSelectorUITag,
	connectMannequinSelectorPrompt
)

-- Mannequin Customization Prompt

local function connectMannequinCustomizationPrompt(platform)
	local prompt = platform:FindFirstChild("ProximityPrompt", true)

	if not prompt then
		warn("ProximityPrompt not found for", platform:GetFullName())
		return
	end

	connectPrompt(prompt, function(player)
		OpenMannequinCustomizationUIRemote:FireClient(
			player,
			prompt:GetAttribute("MannequinId"),
			prompt:GetAttribute("PlatformId")
		)
	end)
end

connectTaggedPlatforms(
	Tags.OpenMannequinCustomizationUITag,
	connectMannequinCustomizationPrompt
)