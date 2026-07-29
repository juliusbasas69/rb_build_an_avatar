local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataService = require(ServerScriptService.Server.Services.DataStoreService)
local PlayerData = require(ReplicatedStorage.Shared.Data.PlayerData)
local OwnedMannequinData = require(ReplicatedStorage.Shared.Data.OwnedMannequinData)

local PlayerCache = {}

local UserService = {}

local function DeepClone(tbl)
	local clone = {}

	for key, value in pairs(tbl) do
		if type(value) == "table" then
			clone[key] = DeepClone(value)
		else
			clone[key] = value
		end
	end

	return clone
end

function UserService:UserInitial(player)

	if not player then
		return nil
	end

	local data = DataService:GetUser(player)

	if not data then

		data = DeepClone(PlayerData)

		local starterMannequin = table.clone(OwnedMannequinData)
		starterMannequin.Id = "MNR6"
		starterMannequin.Quantity = 2

		data.OwnedMannequins["MNR6"] = starterMannequin

		DataService:SaveUser(player, data)
	end

	PlayerCache[player] = data

	return data
end

function UserService:GetUser(player)

    if not PlayerCache[player] then
        local data = DataService:GetUser(player)

        PlayerCache[player] = data
    end

    return PlayerCache[player]
end

function UserService:UpdateUser(player)
	local data = PlayerCache[player]

	if not data then
		warn("No cached data found for " .. player.Name)
		return false
	end

	--DataService:SaveUser(player, data)

	return true
end


return UserService