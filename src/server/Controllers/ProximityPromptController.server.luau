local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Tags = require(ReplicatedStorage.Shared.Tags)

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
	print("BUY ITEM PROMPT TRIGGERED BY PLAYER:", player.Name)

	print(prompt.Parent.Parent:GetAttribute("AssetId"))

	print(prompt.Parent.Parent:Destroy())
end

for _, prompt in ipairs(CollectionService:GetTagged(Tags.BuyAssetPrompt)) do
	connectPrompt(prompt, handleBuyItemPrompt)
end

CollectionService:GetInstanceAddedSignal(Tags.BuyAssetPrompt):Connect(function(prompt)
	connectPrompt(prompt, handleBuyItemPrompt)
end)
