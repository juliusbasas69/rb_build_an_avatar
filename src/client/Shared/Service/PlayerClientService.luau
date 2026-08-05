local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Shared.Remotes)

local RequestPlayerDataRemote = ReplicatedStorage.Remotes.Functions:WaitForChild(Remotes.RequestPlayerDataRemote)

local PlayerData

local PlayerClientService = {}

function PlayerClientService:Initialize()
    PlayerData = RequestPlayerDataRemote:InvokeServer()
end

function PlayerClientService:GetPlayerData()
    return PlayerData
end

return PlayerClientService