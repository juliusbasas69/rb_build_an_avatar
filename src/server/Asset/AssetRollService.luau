local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AssetsDatabase = require(ReplicatedStorage.Shared.Databases.AssetsDatabase)
local MutationDatabase = require(ReplicatedStorage.Shared.Databases.MutationDatabase)
local GradeDatabase = require(ReplicatedStorage.Shared.Databases.GradeDatabase)
local PortalLevelDatabase = require(ReplicatedStorage.Shared.Databases.PortalLevelDatabase)
local LuckMultiplierDatabase = require(ReplicatedStorage.Shared.Databases.LuckMultiplierDatabase)
local MutationLuckMultiplierDatabase = require(ReplicatedStorage.Shared.Databases.MutationLuckMultiplierDatabase)

-- THIS IS GAMEPASS
local mutationLuck = 1
local gradeLuck = 1

local AssetsList = {}

for _, asset in pairs(AssetsDatabase) do
	table.insert(AssetsList, asset)
end

local AssetRollService = {}

function AssetRollService:GetLootTable(portalLevel)
	return PortalLevelDatabase[tonumber(portalLevel)]
end


function AssetRollService:ApplyGradeLuck(grade, weight, luck)

	local multiplier = LuckMultiplierDatabase[grade] or 0

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

function AssetRollService:GetRandomAsset()

	return AssetsList[
		Random.new():NextInteger(1, #AssetsList)
	]

end


function AssetRollService:RollGrade(portalLevel)

	local lootTable = self:GetLootTable(portalLevel)

	if not lootTable then
		warn("No loot table found for level:", portalLevel)
		return nil
	end


	local adjustedTable = {}
	local totalWeight = 0


	for grade, weight in pairs(lootTable) do

		local adjustedWeight = self:ApplyGradeLuck(
			grade,
			weight,
			gradeLuck
		)

		adjustedTable[grade] = adjustedWeight
		totalWeight += adjustedWeight

	end


	local roll = Random.new():NextNumber(0, totalWeight)

	local current = 0


	for grade, weight in pairs(adjustedTable) do

		current += weight

		if roll <= current then
			return grade
		end

	end
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