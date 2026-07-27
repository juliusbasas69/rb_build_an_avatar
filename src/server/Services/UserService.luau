local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataService = require(ServerScriptService.Server.Services.DataStoreService)
local UserDatabase = require(ReplicatedStorage.Shared.Modules.UserDatabase)

local PlayerCache = {}

local UserService = {}

function UserService:UserInitial(player)

	if not player then
		return nil
	end
    print(player)

	local data = DataService:GetUser(player)

	if not data then
		data = table.clone(UserDatabase)
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


return UserService