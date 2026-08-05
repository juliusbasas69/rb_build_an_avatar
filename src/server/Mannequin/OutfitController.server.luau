local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptServie = game:GetService("ServerScriptService")

local Remotes = require(ReplicatedStorage.Shared.Remotes)

local OutfitDataModule = require(ReplicatedStorage.Shared.Data.OutfitData)

local PlayerService = require(ServerScriptServie.Server.Player.PlayerService)

local TableClone = require(ReplicatedStorage.Shared.Util.TableClone)

local SaveMannequinOutfitRemote = ReplicatedStorage.Remotes:WaitForChild(Remotes.SaveMannequinOutfitRemote)

type OutfitData = OutfitDataModule.OutfitData

local function validateOutfitData(playerData, outfitData: OutfitData): boolean
	if typeof(outfitData) ~= "table" then
		return false
	end

	for _, assetKey in pairs(outfitData) do
		-- Skip empty slots
		if assetKey ~= "" then
			if not playerData.Assets[assetKey] then
				warn(("Invalid asset key: %s"):format(assetKey))
				return false
			end
		end
	end

	return true
end

SaveMannequinOutfitRemote.OnServerEvent:Connect(function(player, platformId, outfitData)

    local playerData = PlayerService:GetPlayer(player)

    if not playerData then
        warn("Player not found")
        return
    end

    -- if not validateOutfitData() then
    --     warn("Not Validated")
    --     return
    -- end

    playerData.Platforms[platformId].PlacedMannequin.Outfit = TableClone:Shallow(outfitData)

    PlayerService:UpdatePlayer(player)


end)