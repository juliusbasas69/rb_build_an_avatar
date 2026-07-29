local ServerScriptService = game:GetService("ServerScriptService")

local UserService = require(ServerScriptService.Server.Services.UserService)

local Players = game:GetService("Players")

Players.PlayerAdded:Connect(function(player)

	local data = UserService:UserInitial(player)

	-- Leaderstats
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local gold = Instance.new("NumberValue")
	gold.Name = "Gold"
	gold.Value = data.Gold
	gold.Parent = leaderstats

	-- Replicated player data
	local playerData = Instance.new("Folder")
	playerData.Name = "PlayerData"
	playerData.Parent = player

	local ownedMannequins = Instance.new("Folder")
	ownedMannequins.Name = "OwnedMannequins"
	ownedMannequins.Parent = playerData

	for mannequinId, mannequinData in pairs(data.OwnedMannequins) do
		local mannequinFolder = Instance.new("Folder")
		mannequinFolder.Name = mannequinId
		mannequinFolder.Parent = ownedMannequins

		local quantity = Instance.new("IntValue")
		quantity.Name = "Quantity"
		quantity.Value = mannequinData.Quantity
		quantity.Parent = mannequinFolder
	end

end)