local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Shared.Remotes)

local RequestPlayerDataRemote = ReplicatedStorage.Remotes.Functions:WaitForChild(Remotes.RequestPlayerDataRemote)

local PlayerData

local PlayerClientService = {}

function PlayerClientService:Initialize()
    self:Refresh()
end

function PlayerClientService:Refresh()
    PlayerData = RequestPlayerDataRemote:InvokeServer()
    return PlayerData
end

function PlayerClientService:GetPlayerData()
    return PlayerData
end

return PlayerClientService