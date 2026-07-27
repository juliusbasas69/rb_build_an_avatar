local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ItemDatabase = require(ReplicatedStorage.Shared.Modules.ItemDatabase)
local MutationDatabase = require(ReplicatedStorage.Shared.Modules.MutationDatabase)
local RarityDatabase = require(ReplicatedStorage.Shared.Modules.RarityDatabase)
local ConveyorLevelDatabase = require(ReplicatedStorage.Shared.Modules.ConveyorLevelDatabase)
local LuckMultiplierDatabase = require(ReplicatedStorage.Shared.Modules.LuckMultiplierDatabase)
local MutationLuckMultiplierDatabase = require(ReplicatedStorage.Shared.Modules.MutationLuckMultiplierDatabase)

local ItemsByRarity = {}

--THIS IS GAMEPASS
local playerLuck = 1
local mutationLuck = 1

local ItemRollService = {}

for _, item in pairs(ItemDatabase) do
	ItemsByRarity[item.Rarity] = ItemsByRarity[item.Rarity] or {}
	table.insert(ItemsByRarity[item.Rarity], item)
end

function ItemRollService:GetLootTable(conveyorLevel)
	return ConveyorLevelDatabase[tonumber(conveyorLevel)]
end

function ItemRollService:ApplyLuck(rarity, weight, luck)

	local multiplier = LuckMultiplierDatabase[rarity] or 0

	return weight * (
		1 + ((luck - 1) / 100) * multiplier
	)

end

function ItemRollService:ApplyMutationLuck(mutation, chance, luck)

	local multiplier = MutationLuckMultiplierDatabase[mutation] or 0

	return chance * (
		1 + ((luck - 1) / 100) * multiplier
	)

end

function ItemRollService:RollRarity(conveyorLevel)

	local lootTable = self:GetLootTable(conveyorLevel)

	if not lootTable then
		warn("No loot table found for level:", conveyorLevel)
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

function ItemRollService:GetItemsByRarity(rarity)
	return ItemsByRarity[rarity] or {}
end

function ItemRollService:RollMutation()
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

return ItemRollService