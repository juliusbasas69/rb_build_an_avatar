local Players = game:GetService("Players")

Players.PlayerAdded:Connect(function(player)
	
	player:SetAttribute("HasVIP", false)
    player:SetAttribute("HasAutoSpawn", false)
    player:SetAttribute("Has2xMoney", false)
    player:SetAttribute("HasAutoBuy", false)
    player:SetAttribute("Has2xLuck", false)
    player:SetAttribute("Has2xMutationLuck", false)

end)