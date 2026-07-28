local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Tags = require(ReplicatedStorage.Shared.Tags)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local MannequinSelectorUIRemote = ReplicatedStorage.Remotes:WaitForChild(Remotes.MannequinSelectorUIRemote)

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
end

for _, prompt in ipairs(CollectionService:GetTagged(Tags.BuyItemPrompt)) do
	connectPrompt(prompt, handleBuyItemPrompt)
end

CollectionService:GetInstanceAddedSignal(Tags.BuyItemPrompt):Connect(function(prompt)
	connectPrompt(prompt, handleBuyItemPrompt)
end)

-- Mannequin Platform Prompt

local function openMannequinSelector(player)
	
	MannequinSelectorUIRemote:FireClient(player)
end

local function dressMannequin(player, prompt)
	print("Dress mannequin:", player.Name)
end

local function handlePlatformPrompt(player, prompt)
	local hasMannequin = prompt.Parent:GetAttribute("HasMannequin")

	if hasMannequin then
		dressMannequin(player, prompt)
	else
		openMannequinSelector(player)
	end
end

local function connectMannequinPlatformPrompt(platform)
	local prompt = platform:WaitForChild("ProximityPrompt")

	prompt.Triggered:Connect(function(player)
		handlePlatformPrompt(player, prompt)
	end)
end

for _, platform in ipairs(CollectionService:GetTagged(Tags.MannequinPlatformPrompt)) do
	connectMannequinPlatformPrompt(platform)
end

-- Connect future platforms
CollectionService:GetInstanceAddedSignal(Tags.MannequinPlatformPrompt):Connect(connectMannequinPlatformPrompt)