local ReplicatedStorage = game:GetService("ReplicatedStorage")

local WardrobeData = require(ReplicatedStorage.Shared.Data.WardrobeData)
local AssetDatabase = require(ReplicatedStorage.Shared.Databases.AssetsDatabase)

local AssetKey = require(ReplicatedStorage.Shared.Util.AssetKey)

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerScripts = Player:WaitForChild("PlayerScripts")

local AssetKey = require(ReplicatedStorage.Shared.Util.AssetKey)

local WardrobeUtil = {}

function WardrobeUtil:ApplyAsset(wardrobeData, mannequin, assetKey)

    WardrobeData = wardrobeData

	local humanoid = mannequin:WaitForChild("Humanoid")

	local parsed = AssetKey:Parse(assetKey)
	local assetId = parsed.AssetId

	local assetData = AssetDatabase[assetId]
	if not assetData then
		warn("No asset data found for:", assetId)
		return
	end

	local description = humanoid:GetAppliedDescription()
	local accessoryType = assetData.AccessoryType

	-- Layered Clothing
	if accessoryType == Enum.AccessoryType.Jacket
		or accessoryType == Enum.AccessoryType.Shirt
		or accessoryType == Enum.AccessoryType.Pants
		or accessoryType == Enum.AccessoryType.Sweater
		or accessoryType == Enum.AccessoryType.DressSkirt
		or accessoryType == Enum.AccessoryType.Shorts
		or accessoryType == Enum.AccessoryType.LeftShoe
		or accessoryType == Enum.AccessoryType.RightShoe
		or accessoryType == Enum.AccessoryType.TShirt then

		local accessories = description:GetAccessories(true)

        -- Remove existing accessory of the same type
        for i = #accessories, 1, -1 do
            if assetData.IsPair then
                if accessories[i].AccessoryType == Enum.AccessoryType.LeftShoe
                    or accessories[i].AccessoryType == Enum.AccessoryType.RightShoe then
                    table.remove(accessories, i)
                end
            elseif accessories[i].AccessoryType == accessoryType then
                table.remove(accessories, i)
            end
        end

        if assetData.IsPair then
            table.insert(accessories, {
                AssetId = tonumber(assetId),
                AccessoryType = Enum.AccessoryType.LeftShoe,
                IsLayered = true,
                Order = #accessories + 1,
            })

            table.insert(accessories, {
                AssetId = tonumber(assetId),
                AccessoryType = Enum.AccessoryType.RightShoe,
                IsLayered = true,
                Order = #accessories + 1,
            })
        else
            table.insert(accessories, {
                AssetId = tonumber(assetId),
                AccessoryType = accessoryType,
                IsLayered = true,
                Order = #accessories + 1,
            })
        end

        description:SetAccessories(accessories, true)

		if accessoryType == Enum.AccessoryType.TShirt then
			WardrobeData.TShirtAccessory = assetKey
		elseif accessoryType == Enum.AccessoryType.Shirt then
			WardrobeData.ShirtAccessory = assetKey
		elseif accessoryType == Enum.AccessoryType.Pants then
			WardrobeData.PantsAccessory = assetKey
		elseif accessoryType == Enum.AccessoryType.Jacket then
			WardrobeData.JacketAccessory = assetKey
		elseif accessoryType == Enum.AccessoryType.Sweater then
			WardrobeData.SweaterAccessory = assetKey
		elseif accessoryType == Enum.AccessoryType.Shorts then
			WardrobeData.ShortsAccessory = assetKey
		elseif accessoryType == Enum.AccessoryType.LeftShoe then
            if assetData.IsPair then
                WardrobeData.LeftShoeAccessory = assetKey
                WardrobeData.RightShoeAccessory = assetKey
            else
                WardrobeData.LeftShoeAccessory = assetKey
            end
        elseif accessoryType == Enum.AccessoryType.RightShoe then
            if assetData.IsPair then
                WardrobeData.LeftShoeAccessory = assetKey
                WardrobeData.RightShoeAccessory = assetKey
            else
                WardrobeData.RightShoeAccessory = assetKey
            end
		elseif accessoryType == Enum.AccessoryType.DressSkirt then
			WardrobeData.DressSkirtAccessory = assetKey
		elseif accessoryType == Enum.AccessoryType.Eyebrow then
			WardrobeData.EyebrowAccessory = assetKey
		elseif accessoryType == Enum.AccessoryType.Eyelash then
			WardrobeData.EyelashAccessory = assetKey
		end

	-- Classic Accessories
	elseif accessoryType == Enum.AccessoryType.Hat then
		description.HatAccessory = description.HatAccessory .. "," .. assetId
		WardrobeData.Hat = assetKey

	elseif accessoryType == Enum.AccessoryType.Hair then
		description.HairAccessory = description.HairAccessory .. "," .. assetId
		WardrobeData.Hair = assetKey

	elseif accessoryType == Enum.AccessoryType.Face then
		description.FaceAccessory = description.FaceAccessory .. "," .. assetId
		WardrobeData.FaceAccessory = assetKey

	elseif accessoryType == Enum.AccessoryType.Neck then
		description.NeckAccessory = description.NeckAccessory .. "," .. assetId
		WardrobeData.NeckAccessory = assetKey

	elseif accessoryType == Enum.AccessoryType.Shoulder then
		description.ShoulderAccessory = description.ShoulderAccessory .. "," .. assetId
		WardrobeData.ShoulderAccessory = assetKey

	elseif accessoryType == Enum.AccessoryType.Front then
		description.FrontAccessory = description.FrontAccessory .. "," .. assetId
		WardrobeData.FrontAccessory = assetKey

	elseif accessoryType == Enum.AccessoryType.Back then
		description.BackAccessory = description.BackAccessory .. "," .. assetId
		WardrobeData.BackAccessory = assetKey

	elseif accessoryType == Enum.AccessoryType.Waist then
		description.WaistAccessory = description.WaistAccessory .. "," .. assetId
		WardrobeData.WaistAccessory = assetKey
	end

	humanoid:ApplyDescription(description)

    return WardrobeData
end

function WardrobeUtil:UpdatePreviewSlots(slot, assetKey)
	local parsed = AssetKey:Parse(assetKey)
	local assetId = parsed.AssetId

	local imageLabel = slot:FindFirstChild("ImageLabel")

	if not imageLabel then
		warn("ImageLabel not found in slot:", slot.Name)
		return
	end

    imageLabel.ImageTransparency = 0
	imageLabel.Image = string.format(
		"https://www.roblox.com/asset-thumbnail/image?assetId=%s&width=420&height=420&format=png",
		assetId
	)
end

return WardrobeUtil