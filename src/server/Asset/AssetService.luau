local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Messages = require(ReplicatedStorage.Shared.Messages)

local PlayerService = require(ServerScriptService.Server.Player.PlayerService)

local AssetDatabase = require(ReplicatedStorage.Shared.Databases.AssetsDatabase)
local MutationDatabase = require(ReplicatedStorage.Shared.Databases.MutationDatabase)
local GradeDatabase = require(ReplicatedStorage.Shared.Databases.GradeDatabase)
local InventoryAssetData = require(ReplicatedStorage.Shared.Data.InventoryAssetData)

local AssetKey = require(ReplicatedStorage.Shared.Util.AssetKey)

local AssetService = {}

function AssetService:BuyAsset(player, asset)

	local assetKey = asset:GetAttribute("AssetKey")

	local parsed  = AssetKey:Parse(assetKey)

	local assetId = parsed.AssetId
	local grade = parsed.Grade
	local mutation = parsed.Mutation

	if not assetId then
		warn("Missing AssetId")
		return false, {
			Success = false,
			Message = Messages.ServerError,
		}
	end

	local mutationData = MutationDatabase[mutation]

	if not mutationData then
		warn("Missing mutation:", mutation)
		return false, {
			Success = false,
			Message = Messages.ServerError,
		}
	end

	local gradeData = GradeDatabase[grade]

	if not gradeData then
		warn("Missing grade:", grade)
		return false, {
			Success = false,
			Message = Messages.ServerError,
		}
	end

	local playerData = PlayerService:GetPlayer(player)

	if not playerData then
		warn("No Player Data found for: ", player)
		return false, {
			Success = false,
			Message = Messages.ServerError,
		}
	end

	local assetData = AssetDatabase[assetId]

	if not assetData then
		warn("Missing asset:", assetId)
		return false, {
			Success = false,
			Message = Messages.ServerError,
		}
	end

	local price = math.floor(assetData.Price * mutationData.CostMultiplier * gradeData.CostMultiplier)

	if playerData.Gold < price then
		return false, {
			Success = false,
			Message = Messages.NotEnoughGold
		}
	end

	playerData.Gold -= price
	player:SetAttribute("Gold", playerData.Gold)

	local ownedAsset = playerData.Inventory.Assets[assetKey]
	local isNew = false

	if ownedAsset then
		ownedAsset.Quantity += 1
	else
		isNew = true
		ownedAsset = table.clone(InventoryAssetData)
		ownedAsset.AssetId = assetId
		ownedAsset.Name = assetData.Name
		ownedAsset.Quantity = 1
		ownedAsset.Grade = grade
		ownedAsset.Mutation = mutation
		ownedAsset.Income = assetData.Income * mutationData.IncomeMultiplier * gradeData.IncomeMultiplier
		if assetData.AccessoryType == "Shoes" then
			ownedAsset.Type = "Shoes"
		else
			ownedAsset.Type = assetData.AccessoryType.Name
		end
		ownedAsset.IsBundle = assetData.IsBundle

		playerData.Inventory.Assets[assetKey] = ownedAsset
	end

	asset:Destroy()

	return true, {
		Success = true,
		Message = Messages.PurchaseSuccess,
		Action = isNew and "Add" or "Update",
		AssetKey = assetKey,
		AssetData = ownedAsset
	}
end

return AssetService