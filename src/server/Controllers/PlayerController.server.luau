local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Remotes = require(ReplicatedStorage.Shared.Remotes)

local UserService = require(ServerScriptService.Server.Services.PlayerService)

local GetPlayerDataRemote = ReplicatedStorage.Remotes.Functions:WaitForChild(Remotes.GetPlayerDataRemote)

GetPlayerDataRemote.OnServerInvoke = function(player)

	local playerData = UserService:GetPlayer(player)

	return playerData
end