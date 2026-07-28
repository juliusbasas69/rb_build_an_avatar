local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Shared.Remotes)
local MannequinDatabase = require(ReplicatedStorage.Shared.Databases.MannequinsDatabase)
local UserService = require(ServerScriptService.Server.Services.UserService)

local PlaceMannequinRemote = ReplicatedStorage.Remotes:WaitForChild(Remotes.PlaceMannequinRemote)

PlaceMannequinRemote.OnServerEvent:Connect(function(player, mannequin)

    print(mannequin)
    print(MannequinDatabase[mannequin])

    local mannequinInfo = MannequinDatabase[mannequin]

    if not mannequinInfo then
        warn(player.Name .. " sent an invalid mannequin ID.")
        return
    end

    local playerData = UserService:GetUser(player)

    if not playerData.OwnedMannequins[mannequin] then
        warn(player.Name .. " tried to place a mannequin they don't own.")
        return
    end

    print("PLACED")
end)