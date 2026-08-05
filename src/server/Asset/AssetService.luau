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

local PopupUIRemote = ReplicatedStorage.Remotes:WaitForChild(Remotes.PopupUIRemote)
local InventoryUIRemote = ReplicatedStorage.Remotes:WaitForChild(Remotes.UpdateInventoryUIRemote)

local AssetService = {}

function AssetService:BuyAsset(player, asset)

	local assetId = accessory:GetAttribute("AssetId")
	local mutation = accessory:GetAttribute("Mutation") or "Normal"
	local grade = accessory:GetAttribute("Grade") or "Low"

	if not assetId then
		warn("Missing AssetId")
		return false
	end

	local mutationData = MutationDatabase[mutation]

	if not mutationData then
		warn("Missing mutation:", mutation)
		return false
	end

	local gradeData = GradeDatabase[grade]

	if not gradeData then
		warn("Missing grade:", grade)
		return false
	end

	local playerData = PlayerService:GetPlayer(player)
	local asset = AssetDatabase[assetId]

	if not asset then
		warn("Missing asset:", assetId)
		return false
	end

	local price = math.floor(asset.Price * mutationData.CostMultiplier * gradeData.CostMultiplier)

	if playerData.Gold < price then

		PopupUIRemote:FireClient(player, Messages.NotEnoughGold)

		return false
	end

	playerData.Gold -= price

	player.PlayerData:SetAttribute("Gold", playerData.Gold)

	local key = AssetKey:Create(assetId, grade, mutation)

	local ownedAsset = playerData.Assets[key]

	local isNew = false

	if ownedAsset then

		ownedAsset.Quantity += 1
	else

		isNew = true
		ownedAsset = table.clone(AssetData)
		ownedAsset.AssetId = assetId
		ownedAsset.Name = asset.Name
		ownedAsset.Quantity = 1
		ownedAsset.Grade = grade
		ownedAsset.Mutation = mutation
		ownedAsset.Income = asset.Income * mutationData.IncomeMultiplier * gradeData.IncomeMultiplier

		playerData.Assets[key] = ownedAsset
	end

	accessory:Destroy()

	PlayerService:UpdatePlayer(player)

	PopupUIRemote:FireClient(player, Messages.PurchaseSuccess)

	InventoryUIRemote:FireClient(
		player,
		{
			Action = isNew and "Add" or "Update",
			AssetId = assetId,
			Data = ownedAsset
		}
	)
	return true
end

return AssetService