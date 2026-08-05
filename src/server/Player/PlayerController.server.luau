local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Remotes = require(ReplicatedStorage.Shared.Remotes)

local UserService = require(ServerScriptService.Server.Player.PlayerService)

local RequestPlayerDataRemote = ReplicatedStorage.Remotes.Functions:WaitForChild(Remotes.RequestPlayerDataRemote)

RequestPlayerDataRemote.OnServerInvoke = function(player)

	local playerData = UserService:GetPlayer(player)

	return playerData
end