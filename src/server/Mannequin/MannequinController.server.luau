local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Shared.Remotes)
local MannequinDatabase = require(ReplicatedStorage.Shared.Databases.MannequinsDatabase)
local PlayerService = require(ServerScriptService.Server.Player.PlayerService)
local PlotService = require(ServerScriptService.Server.Plot.PlotService)
local MannequinService = require(ServerScriptService.Server.Mannequin.MannequinService)

local PlaceMannequinRemote = ReplicatedStorage.Remotes:WaitForChild(Remotes.PlaceMannequinRemote)
local UpdateMannequinSelectorUIRemote = ReplicatedStorage.Remotes:WaitForChild(Remotes.UpdateMannequinSelectorUIRemote)

local function placeMannequin(player, plot, platformId, mannequinId) : boolean
	
	return MannequinService:PlaceMannequin(player, plot, platformId, mannequinId)
end

PlaceMannequinRemote.OnServerEvent:Connect(function(player, mannequinId, platformId)

    local mannequinInfo = MannequinDatabase[tonumber(mannequinId)]

    if not mannequinInfo then
        warn(player.Name .. " sent an invalid mannequin ID.")
        return
    end

    local playerData = PlayerService:GetPlayer(player)

    if not playerData.OwnedMannequins[mannequinId] then
        warn(player.Name .. " tried to place a mannequin they don't own.")
        return
    end

    local plot = PlotService:GetPlayerPlot(player)

    if not plot then
        warn("Could not find the plot of " .. player.Name)
        return 
    end

    if not placeMannequin(player, plot, platformId, mannequinId) then
		return
	end

    local ownedMannequin = playerData.OwnedMannequins[mannequinId]
    local ownedMannequinsFolder = player.PlayerData:WaitForChild("OwnedMannequins")
    local mannequinFolder = ownedMannequinsFolder:FindFirstChild(mannequinId)

    if ownedMannequin.Quantity > 1 then

        ownedMannequin.Quantity -= 1

        if mannequinFolder then
            mannequinFolder.Quantity.Value = ownedMannequin.Quantity
        end
    else
        playerData.OwnedMannequins[mannequinId] = nil

        if mannequinFolder then
            mannequinFolder:Destroy()
        end
    end

    PlayerService:UpdatePlayer(player)
    UpdateMannequinSelectorUIRemote:FireClient(player, mannequinId)
end)