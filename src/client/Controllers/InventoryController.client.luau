local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Remotes = require(ReplicatedStorage.Shared.Remotes)
local RarityDatabase = require(ReplicatedStorage.Shared.Databases.RarityDatabase)

local GetPlayerDataRemote = ReplicatedStorage.Remotes.Functions:WaitForChild(Remotes.GetPlayerDataRemote)
local UpdateInventoryUIRemote = ReplicatedStorage.Remotes:WaitForChild(Remotes.UpdateInventoryUIRemote)

local GetPreviewAssetsRemote = ReplicatedStorage.Remotes.Functions:WaitForChild(Remotes.GetPreviewAssetsRemote)

local PlayerData = GetPlayerDataRemote:InvokeServer()

local PreviewCache = {}

if not PlayerData then
	warn("PlayerData failed to load")
	return
end

local player = Players.LocalPlayer

local GetMainGui = require(
	player:WaitForChild("PlayerScripts")
		:WaitForChild("Client")
		:WaitForChild("Shared")
		:WaitForChild("GetMainGui")
)

local MainGui = GetMainGui()

local InventoryGui = MainGui:WaitForChild("Inventory")
local InventoryFrame = InventoryGui:WaitForChild("InventoryFrame")
local ListFrame = InventoryFrame:WaitForChild("ListFrame")

local template = ListFrame:WaitForChild("Template")

local StatusLabel = ListFrame:WaitForChild("StatusLabel")
local CapacityLabel = InventoryFrame:WaitForChild("CapacityFrame"):WaitForChild("CapacityLabel")

local DetailsFrame = InventoryGui:WaitForChild("DetailsFrame")

local DetailsRarityLabel = DetailsFrame:WaitForChild("RarityLabel")
local DetailsMutationLabel = DetailsFrame:WaitForChild("MutationLabel")
local DetailsAssetNameLabel = DetailsFrame:WaitForChild("AssetNameLabel")
local DetailsIncomeLabel = DetailsFrame:WaitForChild("IncomeLabel")
local DetailsCreatorLabel = DetailsFrame:WaitForChild("CreatorLabel")
local DetailsViewport = DetailsFrame:WaitForChild("ViewportFrame")

local rotatingMannequin
local rotateConnection

-- local uiListLayout = InventoryGui:FindFirstChildWhichIsA("UIListLayout", true)

--------------------------------------------------------
-- DATA
--------------------------------------------------------

local assets = {}
local inventoryFrames = {}

for _, assetData in pairs(PlayerData.Assets or {}) do
	table.insert(assets, assetData)
end

local MAX_INVENTORY = 100

local function updateInventoryCount()
	CapacityLabel.Text = string.format("Capacity: %d/%d", #assets, MAX_INVENTORY)
end

local function getAssetKey(assetId, mutation)
	return tostring(assetId) .. "_" .. mutation
end

updateInventoryCount()

--------------------------------------------------------
-- CREATE PREVIEW
--------------------------------------------------------

local function createPreview(asset, viewport)

	viewport:ClearAllChildren()

	local camera = Instance.new("Camera")
	camera.Parent = viewport
	viewport.CurrentCamera = camera


	local cached = PreviewCache[asset.AssetId]

	if not cached then
		warn("Missing cached preview:", asset.AssetId)
		return
	end


	local mannequin = cached:Clone()
	mannequin.Parent = viewport


	for _, obj in ipairs(mannequin:GetDescendants()) do
		if obj:IsA("BasePart") then
			obj.Anchored = true
		end
	end


	mannequin:PivotTo(
		mannequin:GetPivot()
		* CFrame.Angles(0, math.rad(90), 0)
	)


	local torso = mannequin:FindFirstChild("UpperTorso")

	if torso then
		camera.CFrame = CFrame.lookAt(
			torso.Position + Vector3.new(0,0,3.25),
			torso.Position
		)
	end


	return mannequin
end

local function updateDetails(asset)

	DetailsRarityLabel.Text = asset.Rarity
	DetailsRarityLabel.BackgroundColor3 = RarityDatabase[asset.Rarity].Color

	DetailsMutationLabel.Text = asset.Mutation or "Normal"
	DetailsAssetNameLabel.Text = asset.Name or "Unknown"
	DetailsIncomeLabel.Text = string.format("$%s/sec", tostring(asset.Income or 0))
	DetailsCreatorLabel.Text = asset.Creator or "Roblox"

	DetailsFrame:SetAttribute("AssetId", asset.AssetId)

	if rotateConnection then
		rotateConnection:Disconnect()
		rotateConnection = nil
	end

	rotatingMannequin = createPreview(asset, DetailsViewport)

	if rotatingMannequin then
		rotateConnection = RunService.RenderStepped:Connect(function(dt)
			if rotatingMannequin.Parent then
				rotatingMannequin:PivotTo(
					rotatingMannequin:GetPivot()
						* CFrame.Angles(0, math.rad(45) * dt, 0)
				)
			end
		end)
	end
end

RunService.RenderStepped:Connect(function(dt)
	if DetailsFrame.Visible and rotatingMannequin and rotatingMannequin.Parent then
		rotatingMannequin:PivotTo(
			rotatingMannequin:GetPivot()
				* CFrame.Angles(0, math.rad(45) * dt, 0)
		)
	end
end)

--------------------------------------------------------
-- CREATE ITEM FRAME
--------------------------------------------------------

local function createItemFrame(asset)

    StatusLabel.Visible = false

	local key = getAssetKey(
		asset.AssetId,
		asset.Mutation
	)

	if inventoryFrames[key] then
		return inventoryFrames[key]
	end

	local frame = template:Clone()

	frame.Name = key
	frame.Visible = false
	frame.Parent = ListFrame

	frame:SetAttribute(
		"AssetId",
		asset.AssetId
	)

	frame:SetAttribute(
		"Mutation",
		asset.Mutation
	)

    local RarityLabel = frame:WaitForChild("RarityLabel")
	local MutationLabel = frame:WaitForChild("MutationLabel")
    local QuantityLabel = frame:WaitForChild("QuantityLabel")

    RarityLabel.Text = asset.Rarity
    RarityLabel.BackgroundColor3 = RarityDatabase[asset.Rarity].Color

	MutationLabel.Text = asset.Mutation or "Error"

	CollectionService:AddTag(RarityLabel, asset.Rarity)
	CollectionService:AddTag(MutationLabel, asset.Mutation)

    QuantityLabel.Text = "x" .. (asset.Quantity or 1)
    
	inventoryFrames[key] = frame

	task.spawn(function()

		createPreview(asset, frame:WaitForChild("ViewportFrame"))

		frame.Visible = true
	end)

	frame.MouseButton1Click:Connect(function()
		updateDetails(asset)

		DetailsFrame.Visible = true

		-- if uiListLayout then
		-- 	uiListLayout.HorizontalFlex = Enum.UIFlexAlignment.SpaceEvenly
		-- end
	end)

	return frame
end

--------------------------------------------------------
-- LOAD PAGE
--------------------------------------------------------

local function loadInventory()

	StatusLabel.Text = "Loading..."
	StatusLabel.Visible = true

	table.clear(inventoryFrames)

	for _, child in ipairs(ListFrame:GetChildren()) do
		if child:IsA("ImageButton") and child ~= template then
			child:Destroy()
		end
	end

	if #assets == 0 then
		StatusLabel.Text = "No Items"
		StatusLabel.Visible = true
		return
	end


	-- Batch request
	local assetIds = {}

	for _, asset in ipairs(assets) do
		table.insert(assetIds, asset.AssetId)
	end


	local previews = GetPreviewAssetsRemote:InvokeServer(assetIds)


	for assetId, preview in pairs(previews) do
		PreviewCache[tonumber(assetId)] = preview
	end


	-- Create UI
	for _, asset in ipairs(assets) do
		createItemFrame(asset)
	end


	StatusLabel.Visible = false
end

--------------------------------------------------------
-- START
--------------------------------------------------------

template.Visible = false
StatusLabel.Visible = false

loadInventory()

--------------------------------------------------------
-- LIVE INVENTORY UPDATE
--------------------------------------------------------

UpdateInventoryUIRemote.OnClientEvent:Connect(function(update)

    print(update.Action)

	if update.Action == "Add" then

		local assetData = update.Data

		table.insert(
			assets,
			assetData
		)


		createItemFrame(assetData)

        print("UPDATED")

	elseif update.Action == "Update" then

		local key = getAssetKey(
			update.Data.AssetId,
			update.Data.Mutation
		)

		local frame = inventoryFrames[key]

        if frame then

            frame:SetAttribute("Quantity", update.Data.Quantity)

            local QuantityLabel = frame:FindFirstChild("QuantityLabel")

            if QuantityLabel then
                QuantityLabel.Text = "x" .. (update.Data.Quantity or 1)
            end
        end

	elseif update.Action == "Remove" then

		local key = getAssetKey(
			update.AssetId,
			update.Mutation
		)

		local frame = inventoryFrames[key]

		if frame then

			frame:Destroy()
			inventoryFrames[key] = nil
		end
	end
end)