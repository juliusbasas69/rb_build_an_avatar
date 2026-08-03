local ServerScriptService = game:GetService("ServerScriptService")

local PlayerService = require(ServerScriptService.Server.Player.PlayerService)

local Players = game:GetService("Players")

Players.PlayerAdded:Connect(function(player)

	local data = PlayerService:UserInitial(player)

	local playerData = Instance.new("Folder")
	playerData.Name = "PlayerData"
	playerData.Parent = player

	playerData:SetAttribute("Gold", data.Gold)

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

	player.CharacterAdded:Connect(function(character)

		for _, object in ipairs(character:GetDescendants()) do
			if object:IsA("BasePart") then
				object.CollisionGroup = "Players"
			end
		end

	end)

end)

Players.PlayerRemoving:Connect(function(player)
	PlayerService:PlayerRemoving(player)
end)