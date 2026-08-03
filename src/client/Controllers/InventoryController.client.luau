local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local MarketplaceService = game:GetService("MarketplaceService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Remotes = require(ReplicatedStorage.Shared.Remotes)
local GradeDatabase = require(ReplicatedStorage.Shared.Databases.GradeDatabase)
local AssetDatabase = require(ReplicatedStorage.Shared.Databases.AssetsDatabase)

local ReplicatedAssets = ReplicatedStorage:WaitForChild("Assets")	
local PreviewAssets = ReplicatedStorage:WaitForChild("PreviewAssets")

local GetPlayerDataRemote = ReplicatedStorage.Remotes.Functions:WaitForChild(Remotes.GetPlayerDataRemote)
local UpdateInventoryUIRemote = ReplicatedStorage.Remotes:WaitForChild(Remotes.UpdateInventoryUIRemote)
local GetAsset3DPreviewRemote = ReplicatedStorage.Remotes.Functions:WaitForChild(Remotes.GetAsset3DPreviewRemote)

local PlayerData = GetPlayerDataRemote:InvokeServer()

if not PlayerData then
	warn("PlayerData failed to load")
	return
end

local player = Players.LocalPlayer

local GetMainGui = require(player:WaitForChild("PlayerScripts"):WaitForChild("Client"):WaitForChild("Shared"):WaitForChild("GetMainGui"))

local MainGui = GetMainGui()

local InventoryGui = MainGui:WaitForChild("InventoryGui")
local InventoryFrame = InventoryGui:WaitForChild("InventoryFrame")
local ListFrame = InventoryFrame:WaitForChild("ListFrame")

local template = ListFrame:WaitForChild("Template")

local StatusLabel = InventoryFrame:WaitForChild("StatusLabel")
local CapacityLabel = InventoryFrame:WaitForChild("CapacityFrame"):WaitForChild("CapacityLabel")

local DetailsFrame = InventoryGui:WaitForChild("DetailsFrame")

local DetailsGradeLabel = DetailsFrame:WaitForChild("GradeLabel")
local DetailsMutationLabel = DetailsFrame:WaitForChild("MutationLabel")
local DetailsAssetNameLabel = DetailsFrame:WaitForChild("AssetNameLabel")
local DetailsIncomeLabel = DetailsFrame:WaitForChild("IncomeLabel")
local DetailsCreatorLabel = DetailsFrame:WaitForChild("CreatorLabel")

local Button3D = DetailsFrame:WaitForChild("Button3D")
local Button2D = DetailsFrame:WaitForChild("Button2D")
local ViewAsset3D = DetailsFrame:WaitForChild("ViewAsset3D")
local ViewAsset2D = DetailsFrame:WaitForChild("ViewAsset2D")

local CatalogButton = DetailsFrame:WaitForChild("CatalogButton")

local rotatingHandle
local rotateConnection

local assets = {}
local inventoryFrames = {}

local MAX_INVENTORY = 100

for _, assetData in pairs(PlayerData.Assets or {}) do
	table.insert(assets, assetData)
end

local function updateInventoryCount()
	CapacityLabel.Text = string.format("Capacity: %d/%d", #assets, MAX_INVENTORY)
end

local function getAssetKey(assetId, mutation, grade)
	return tostring(assetId) .. "_" .. mutation .. "_" .. grade
end

local function createThumbnail(asset, imageLabel)

	imageLabel.Image =
		"https://www.roblox.com/asset-thumbnail/image?assetId="
		.. asset.AssetId
		.. "&width=420&height=420&format=png"

end

local function createPreview(asset, frame, previewType)

	if previewType == "2D" then
		frame.Image =
			"https://www.roblox.com/asset-thumbnail/image?assetId="
			.. asset.AssetId
			.. "&width=420&height=420&format=png"

		return
	end

	-- 3D Preview
	frame:ClearAllChildren()

	local camera = Instance.new("Camera")
	camera.Parent = frame
	frame.CurrentCamera = camera

	GetAsset3DPreviewRemote:InvokeServer(asset.AssetId)

	local preview = PreviewAssets:WaitForChild(tostring(asset.AssetId))

	local handle = preview:FindFirstChild("Handle")
	if not handle then
		warn("Handle missing:", asset.AssetId)
		return
	end

	local clone = handle:Clone()
	clone.Parent = frame
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
		CFrame.new()
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

local function updateDetailsFrame(asset)

	DetailsGradeLabel.Text = asset.Grade
	DetailsGradeLabel.BackgroundColor3 = GradeDatabase[asset.Grade].Color

	DetailsMutationLabel.Text = asset.Mutation or "Normal"
	DetailsAssetNameLabel.Text = asset.Name or "Unknown"
	DetailsIncomeLabel.Text = string.format("$%s/sec", tostring(asset.Income or 0))
	DetailsCreatorLabel.Text = "© " .. (asset.Creator or "Unknown")

	DetailsFrame:SetAttribute("AssetId", asset.AssetId)

	-- Default to 2D
	ViewAsset2D.Visible = true
	ViewAsset3D.Visible = false

	Button3D.Visible = true
	Button2D.Visible = false

	createPreview(asset, ViewAsset2D, "2D")
end

local function createItemFrame(asset)

    StatusLabel.Visible = false

	local key = getAssetKey(asset.AssetId, asset.Mutation, asset.Grade)

	if inventoryFrames[key] then
		return inventoryFrames[key]
	end

	local frame = template:Clone()

	frame.Name = key
	frame.Visible = false
	frame.Parent = ListFrame

	frame:SetAttribute("AssetId", asset.AssetId)
	frame:SetAttribute("Mutation", asset.Mutation)

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

		createThumbnail(
			asset,
			frame:WaitForChild("ViewItem")
		)

		frame.Visible = true
	end)

	frame.MouseButton1Click:Connect(function()
		updateDetailsFrame(asset)

		DetailsFrame:SetAttribute("AssetId", asset.AssetId)

		DetailsFrame.Visible = true
	end)

	return frame
end

local function loadInventory()

	StatusLabel.Text = "🌿 Loading your inventory..."
	StatusLabel.Visible = true

	StatusLabel.BackgroundTransparency = 1
	StatusLabel.TextColor3 = Color3.fromHex("#4E7A4A")
	StatusLabel.TextStrokeColor3 = Color3.fromHex("#FFFFFF")
	StatusLabel.TextStrokeTransparency = 0.65
	StatusLabel.Font = Enum.Font.FredokaOne -- or GothamBold
	StatusLabel.TextSize = 22
	StatusLabel.TextWrapped = true

	table.clear(inventoryFrames)

	for _, child in ipairs(ListFrame:GetChildren()) do
		if child:IsA("ImageButton") and child ~= template then
			child:Destroy()
		end
	end

	if #assets == 0 then
		StatusLabel.Text = "🍃 Your inventory is empty!"
		StatusLabel.Visible = true

		-- Styling
		StatusLabel.BackgroundTransparency = 1
		StatusLabel.TextColor3 = Color3.fromHex("#4E7A4A")
		StatusLabel.TextStrokeColor3 = Color3.fromHex("#FFFFFF")
		StatusLabel.TextStrokeTransparency = 0.65
		StatusLabel.Font = Enum.Font.LuckiestGuy -- or GothamBold if you prefer
		StatusLabel.TextSize = 22
		StatusLabel.TextWrapped = true

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
updateInventoryCount()


Button3D.MouseButton1Click:Connect(function()
	ViewAsset2D.Visible = false
	ViewAsset3D.Visible = true

	Button3D.Visible = false
	Button2D.Visible = true

	if rotateConnection then
		rotateConnection:Disconnect()
		rotateConnection = nil
	end

	local assetId = DetailsFrame:GetAttribute("AssetId")

	if not assetId then
		warn("No Asset Id for 3D")
		return
	end

	local assetData = AssetDatabase[assetId]

	if not assetData then
		warn("No Asset Data for: ", assetId)
		return
	end

	rotatingHandle = createPreview(assetData, ViewAsset3D, "3D")

	if rotatingHandle then
		rotateConnection = RunService.RenderStepped:Connect(function()
			if rotatingHandle.Parent then
				rotatingHandle.CFrame *= CFrame.Angles(0, math.rad(1), 0)
			end
		end)
	end
end)

Button2D.MouseButton1Click:Connect(function()
	ViewAsset2D.Visible = true
	ViewAsset3D.Visible = false

	Button3D.Visible = true
	Button2D.Visible = false
end)


CatalogButton.MouseButton1Click:Connect(function()
	local assetId = DetailsFrame:GetAttribute("AssetId")

	if assetId then
		MarketplaceService:PromptOpenBrowserWindow(
			"https://www.roblox.com/catalog/" .. assetId
		)
	end
end)

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