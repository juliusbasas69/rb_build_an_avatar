local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AssetsDatabase = require(ReplicatedStorage.Shared.Databases.AssetsDatabase)
local MutationDatabase = require(ReplicatedStorage.Shared.Databases.MutationDatabase)
local RarityDatabase = require(ReplicatedStorage.Shared.Databases.RarityDatabase)
local PortalLevelDatabase = require(ReplicatedStorage.Shared.Databases.PortalLevelDatabase)
local LuckMultiplierDatabase = require(ReplicatedStorage.Shared.Databases.LuckMultiplierDatabase)
local MutationLuckMultiplierDatabase = require(ReplicatedStorage.Shared.Databases.MutationLuckMultiplierDatabase)

local AssetsByRarity = {}

--THIS IS GAMEPASS
local playerLuck = 1
local mutationLuck = 1

local AssetRollService = {}

for _, asset in pairs(AssetsDatabase) do
	AssetsByRarity[asset.Rarity] = AssetsByRarity[asset.Rarity] or {}
	table.insert(AssetsByRarity[asset.Rarity], asset)
end

function AssetRollService:GetLootTable(portalLevel)
	return PortalLevelDatabase[tonumber(portalLevel)]
end

function AssetRollService:ApplyLuck(rarity, weight, luck)

	local multiplier = LuckMultiplierDatabase[rarity] or 0

	return weight * (
		1 + ((luck - 1) / 100) * multiplier
	)

end

function AssetRollService:ApplyMutationLuck(mutation, chance, luck)

	local multiplier = MutationLuckMultiplierDatabase[mutation] or 0

	return chance * (
		1 + ((luck - 1) / 100) * multiplier
	)

end

function AssetRollService:RollRarity(portalLevel)

	local lootTable = self:GetLootTable(portalLevel)

	if not lootTable then
		warn("No loot table found for level:", portalLevel)
		return nil
	end

	local adjustedTable = {}
	local totalWeight = 0

	for rarity, weight in pairs(lootTable) do

		local adjustedWeight = self:ApplyLuck(
			rarity,
			weight,
			playerLuck
		)

		adjustedTable[rarity] = adjustedWeight
		totalWeight += adjustedWeight

	end

	local roll = Random.new():NextNumber(0, totalWeight)

	local current = 0

	for rarity, weight in pairs(adjustedTable) do

		current += weight

		if roll <= current then
			return rarity
		end
	end
end

function AssetRollService:GetAssetByRarity(rarity)
	return AssetsByRarity[rarity] or {}
end

function AssetRollService:RollMutation()
	local adjustedTable = {}
	local totalChance = 0


	for mutation, data in pairs(MutationDatabase) do

		local adjustedChance = self:ApplyMutationLuck(
			mutation,
			data.Chance,
			mutationLuck
		)

		adjustedTable[mutation] = adjustedChance
		totalChance += adjustedChance
	end


	local roll = Random.new():NextNumber(0, totalChance)

	local current = 0

	for mutation, chance in pairs(adjustedTable) do

		current += chance

		if roll <= current then
			return mutation
		end
	end
end

return AssetRollService