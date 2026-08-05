local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataService = require(ServerScriptService.Server.DataStore.DataStoreService)
local PlayerData = require(ReplicatedStorage.Shared.Data.PlayerData)
local InventoryMannequinData = require(ReplicatedStorage.Shared.Data.InventoryMannequinData)
local PlacedMannequinData = require(ReplicatedStorage.Shared.Data.PlacedMannequinData)
local TableClone = require(ReplicatedStorage.Shared.Util.TableClone)

local PlayerCache = {}

local PlayerService = {}

local AUTOSAVE_INTERVAL = 60

function PlayerService:UserInitial(player)

	if not player then
		return nil
	end

	local data = DataService:GetPlayer(player)

	if not data then

		data = TableClone:Deep(PlayerData)

		local starterMannequin = table.clone(InventoryMannequinData)
		starterMannequin.Id = "47221299427770"
		starterMannequin.Name = "F15 Boy"
		starterMannequin.Quantity = 999

		data.Inventory.Mannequins["47221299427770"] = starterMannequin

		DataService:SavePlayer(player, data)
	end

	PlayerCache[player] = data

	return data
end

function PlayerService:GetPlayer(player)

    if not PlayerCache[player] then
        local data = DataService:GetPlayer(player)

        PlayerCache[player] = data
    end

    return PlayerCache[player]
end

function PlayerService:UpdatePlayer(player)
	local data = PlayerCache[player]

	if not data then
		warn("No cached data found for " .. player.Name)
		return false
	end

	return true
end

function PlayerService:PlayerRemoving(player)
	local data = PlayerCache[player]

	if data then
		local success, err = pcall(function()
			DataService:SavePlayer(player, data)
		end)

		if not success then
			warn(("Failed to save %s: %s"):format(player.Name, err))
		end

		PlayerCache[player] = nil
	end
end

task.spawn(function()
	while true do
		task.wait(AUTOSAVE_INTERVAL)

		for player, data in pairs(PlayerCache) do
			if player.Parent then
				local success, err = pcall(function()
					DataService:SavePlayer(player, data)
				end)

				if not success then
					warn(("Failed to autosave %s: %s"):format(player.Name, err))
				end
			end
		end
	end
end)

function PlayerService:UpdatePlayerMannequins(player, platformId, mannequinId)

	local playerData = self:GetPlayer(player)

	if not PlayerData then
		warn("PlayerData not found for player: " .. player.Name)
		return false
	end

	local inventory = playerData.Inventory
	local mannequins = inventory.Mannequins
	local platforms = playerData.Platforms

	local placedMannequin = TableClone:Deep(PlacedMannequinData)
	placedMannequin.MannequinId = mannequinId

	platforms[platformId].HasMannequin = true
	platforms[platformId].PlacedMannequin = placedMannequin

	local mannequin = mannequins[mannequinId]

    if mannequin.Quantity > 1 then

        mannequin.Quantity -= 1
    else
        mannequins[mannequinId] = nil
    end

	return true
end



return PlayerService