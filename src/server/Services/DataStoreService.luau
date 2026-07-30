local DataStoreService = game:GetService("DataStoreService")

local PlayerData = DataStoreService:GetDataStore("PlayerData")

local DataService = {}

function DataService:GetUser(player)

    local success, data = pcall(function(...)
        return PlayerData:GetAsync(player)
    end)

    if success then
        return data
    end

    warn(data)
    return nil
end

function DataService:SaveUser(player, data)

    local success, err = pcall(function(...)
        PlayerData:SetAsync(player, data)
    end)

    if not success then 
        warn(err)
    end
end

return DataService