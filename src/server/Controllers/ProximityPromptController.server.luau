local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Tags = require(ReplicatedStorage.Shared.Tags)

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

-- Buy Item Prompt

local function handleBuyItemPrompt(player, prompt)

	local mannequin = prompt.Parent.Parent
	
	AssetService:BuyAsset(player, mannequin)
end

for _, prompt in ipairs(CollectionService:GetTagged(Tags.BuyAssetPrompt)) do
	connectPrompt(prompt, handleBuyItemPrompt)
end

CollectionService:GetInstanceAddedSignal(Tags.BuyAssetPrompt):Connect(function(prompt)
	connectPrompt(prompt, handleBuyItemPrompt)
end)
