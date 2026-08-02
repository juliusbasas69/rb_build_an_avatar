local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Remotes = require(ReplicatedStorage.Shared.Remotes)
local GradeDatabase = require(ReplicatedStorage.Shared.Databases.GradeDatabase)
local AssetDatabase = require(ReplicatedStorage.Shared.Databases.AssetsDatabase)

local ReplicatedAssets = ReplicatedStorage:WaitForChild("Assets")	

local GetPlayerDataRemote = ReplicatedStorage.Remotes.Functions:WaitForChild(Remotes.GetPlayerDataRemote)
local UpdateInventoryUIRemote = ReplicatedStorage.Remotes:WaitForChild(Remotes.UpdateInventoryUIRemote)

local PlayerData = GetPlayerDataRemote:InvokeServer()

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

local DetailsGradeLabel = DetailsFrame:WaitForChild("GradeLabel")
local DetailsMutationLabel = DetailsFrame:WaitForChild("MutationLabel")
local DetailsAssetNameLabel = DetailsFrame:WaitForChild("AssetNameLabel")
local DetailsIncomeLabel = DetailsFrame:WaitForChild("IncomeLabel")
local DetailsCreatorLabel = DetailsFrame:WaitForChild("CreatorLabel")
local DetailsViewport = DetailsFrame:WaitForChild("ViewportFrame")

local rotatingHandle
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

local function getAssetKey(assetId, mutation, grade)
	return tostring(assetId) .. "_" .. mutation .. "_" .. grade
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

	local preview = ReplicatedAssets:FindFirstChild(
		tostring(asset.AssetId)
	)

	if not preview then
		warn("Missing preview:", asset.AssetId)
		return
	end

	local handle = preview:FindFirstChild("Handle")

	if not handle then
		warn("Handle missing:", asset.AssetId)
		return
	end

	local clone = handle:Clone()

	clone.Parent = viewport

	clone.Anchored = true

	local assetData = AssetDatabase[asset.AssetId]

	local distance = 3
	local height = 0
	local rotation = Vector3.new(0, 180, 0)

	if assetData and assetData.Camera then
		distance = assetData.Camera.Distance or distance
		height = assetData.Camera.Height or height
		rotation = assetData.Camera.Rotation or rotation
	end

	clone.CFrame =
		CFrame.new(0, 0, 0)
		* CFrame.Angles(
			math.rad(rotation.X),
			math.rad(rotation.Y),
			math.rad(rotation.Z)
		)

	camera.CFrame = CFrame.lookAt(
		clone.Position + Vector3.new(0, height, distance),
		clone.Position + Vector3.new(0, height, 0)
	)

	return clone
end

local function updateDetails(asset)

	DetailsGradeLabel.Text = asset.Grade

	DetailsGradeLabel.BackgroundColor3 = GradeDatabase[asset.Grade].Color
	DetailsMutationLabel.Text = asset.Mutation or "Normal"
	DetailsAssetNameLabel.Text = asset.Name or "Unknown"
	DetailsIncomeLabel.Text = string.format("$%s/sec", tostring(asset.Income or 0))

	DetailsCreatorLabel.Text = asset.Creator or "Roblox"

	DetailsFrame:SetAttribute("AssetId", asset.AssetId)

	if rotateConnection then
		rotateConnection:Disconnect()
		rotateConnection = nil
	end

	rotatingHandle = createPreview(asset, DetailsViewport)

	if rotatingHandle then
		rotateConnection = RunService.RenderStepped:Connect(function()
			if rotatingHandle.Parent then
				rotatingHandle.CFrame *= CFrame.Angles(0, math.rad(1), 0)
			end
		end)
	end
end

--------------------------------------------------------
-- CREATE ITEM FRAME
--------------------------------------------------------

local function createItemFrame(asset)

    StatusLabel.Visible = false

	local key = getAssetKey(
		asset.AssetId,
		asset.Mutation,
		asset.Grade
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

	local GradeLabel = frame:WaitForChild("GradeLabel")
	local MutationLabel = frame:WaitForChild("MutationLabel")
    local QuantityLabel = frame:WaitForChild("QuantityLabel")

    GradeLabel.Text = asset.Grade
    GradeLabel.BackgroundColor3 = GradeDatabase[asset.Grade].Color

	MutationLabel.Text = asset.Mutation or "Error"

	CollectionService:AddTag(GradeLabel, asset.Grade)
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

	if update.Action == "Add" then

		local assetData = update.Data

		table.insert(
			assets,
			assetData
		)


		createItemFrame(assetData)

	elseif update.Action == "Update" then

		local key = getAssetKey(
			update.Data.AssetId,
			update.Data.Mutation,
			update.Data.Grade
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
			update.Mutation,
			update.Grade
		)

		local frame = inventoryFrames[key]

		if frame then

			frame:Destroy()
			inventoryFrames[key] = nil
		end
	end
end)