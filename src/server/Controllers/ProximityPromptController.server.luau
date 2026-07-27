local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")

local BUY_ITEM_PROMPT = "BuyItemPrompt"
local MANNEQUIN_PLATFORM_PROMPT = "MannequinPlatformPrompt"

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

for _, prompt in ipairs(CollectionService:GetTagged(BUY_ITEM_PROMPT)) do
	connectPrompt(prompt, handleBuyItemPrompt)
end

CollectionService:GetInstanceAddedSignal(BUY_ITEM_PROMPT):Connect(function(prompt)
	connectPrompt(prompt, handleBuyItemPrompt)
end)

-- Mannequin Platform Prompt

local function placeMannequin(player, prompt)
	print("Place mannequin:", player.Name)
end

local function dressMannequin(player, prompt)
	print("Dress mannequin:", player.Name)
end

local function handlePlatformPrompt(player, prompt)
	local hasMannequin = prompt.Parent:GetAttribute("HasMannequin")

	if hasMannequin then
		dressMannequin(player, prompt)
	else
		placeMannequin(player, prompt)
	end
end

local function connectMannequinPlatformPrompt(platform)
	local prompt = platform:WaitForChild("ProximityPrompt")

	prompt.Triggered:Connect(function(player)
		handlePlatformPrompt(player, prompt)
	end)
end

for _, platform in ipairs(CollectionService:GetTagged(MANNEQUIN_PLATFORM_PROMPT)) do
	connectMannequinPlatformPrompt(platform)
end

-- Connect future platforms
CollectionService:GetInstanceAddedSignal(MANNEQUIN_PLATFORM_PROMPT):Connect(connectMannequinPlatformPrompt)