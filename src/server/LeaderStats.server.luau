local ServerScriptService = game:GetService("ServerScriptService")

local UserService = require(ServerScriptService.Server.Services.UserService)

local Players = game:GetService("Players")

Players.PlayerAdded:Connect(function(player)

	local data = UserService:UserInitial(player)
	
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player
	
	local gold = Instance.new("NumberValue")
	gold.Name = "Gold"
	gold.Value = data.Gold
	gold.Parent = leaderstats 



end)