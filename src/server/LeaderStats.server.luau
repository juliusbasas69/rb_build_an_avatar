local Players = game:GetService("Players")

Players.PlayerAdded:Connect(function(player)
	
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player
	
	local gold = Instance.new("NumberValue")
	gold.Name = "Gold"
	gold.Value = 10000
	gold.Parent = leaderstats 
end)