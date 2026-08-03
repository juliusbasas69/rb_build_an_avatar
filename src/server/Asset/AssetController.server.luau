local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Tags = require(ReplicatedStorage.Shared.Tags)

local AssetService = require(ServerScriptService.Server.Asset.AssetService)

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

local function handleBuyAssetPrompt(prompt)
	connectPrompt(prompt, function(player)
		local accessory = prompt.Parent

		AssetService:BuyAsset(player, accessory)
	end)
end

for _, prompt in ipairs(CollectionService:GetTagged(Tags.BuyAssetPrompt)) do
	handleBuyAssetPrompt(prompt)
end

CollectionService:GetInstanceAddedSignal(Tags.BuyAssetPrompt):Connect(function(prompt)
	handleBuyAssetPrompt(prompt)
end)