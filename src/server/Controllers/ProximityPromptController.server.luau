local CollectionService = game:GetService("CollectionService")

local function connectPrompt(prompt)
	prompt.Triggered:Connect(function(player)
		-- Handle purchase
        print("BUY ITEM PROMPT TRIGGERED BY PLAYER: " .. player.Name)
	end)
end

for _, prompt in ipairs(CollectionService:GetTagged("BuyItemPrompt")) do
	connectPrompt(prompt)
end

CollectionService:GetInstanceAddedSignal("BuyItemPrompt"):Connect(connectPrompt)