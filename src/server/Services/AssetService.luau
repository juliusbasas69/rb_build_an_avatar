local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Messages = require(ReplicatedStorage.Shared.Messages)
local PlayerService = require(ServerScriptService.Server.Services.PlayerService)
local AssetDatabase = require(ReplicatedStorage.Shared.Databases.AssetsDatabase)
local MutationDatabase = require(ReplicatedStorage.Shared.Databases.MutationDatabase)


local AssetData = require(ReplicatedStorage.Shared.Data.AssetData)

local PopupUIRemote = ReplicatedStorage.Remotes:WaitForChild(Remotes.PopupUIRemote)
local InventoryUIRemote = ReplicatedStorage.Remotes:WaitForChild(Remotes.UpdateInventoryUIRemote)

local AssetService = {}

function AssetService:BuyAsset(player, mannequin)

	local assetId = mannequin:GetAttribute("AssetId")
	local mutation = mannequin:GetAttribute("Mutation") or "Normal"

    local mutationData = MutationDatabase[mutation]

    if not mutationData then
        return false
    end

	if not assetId then
		return false
	end

	local playerData = PlayerService:GetPlayer(player)
	local asset = AssetDatabase[assetId]

	if not asset then
		return false
	end

	-- Not enough gold
	if playerData.Gold < asset.Price then

        PopupUIRemote:FireClient(player, Messages.NotEnoughGold)

		return false
	end

    local price = math.floor(asset.Price * mutationData.CostMultiplier)

	-- Deduct gold
	playerData.Gold -= price
	player.PlayerData:SetAttribute("Gold", playerData.Gold)

	local key = assetId .. "_" .. mutationData.Order

    local ownedAsset = playerData.Assets[key]

    local IsNew = false

    if ownedAsset then
        ownedAsset.Quantity += 1
    else
        IsNew = true
        ownedAsset = table.clone(AssetData)
        ownedAsset.AssetId = assetId
        ownedAsset.Name = asset.Name
        ownedAsset.Quantity = 1
        ownedAsset.Rarity = asset.Rarity
        ownedAsset.Mutation = mutation
        ownedAsset.Income = asset.Income

        playerData.Assets[key] = ownedAsset
    end

	mannequin:Destroy()

    PlayerService:UpdatePlayer(player)

    PopupUIRemote:FireClient(player, Messages.PurchaseSuccess)
    InventoryUIRemote:FireClient(player, {
        Action = IsNew and "Add" or "Update",
        AssetId = assetId,
        Data = ownedAsset
    })

	return true
end

return AssetService