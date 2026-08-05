local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Player = Players.LocalPlayer
local PlayerScripts = Player:WaitForChild("PlayerScripts")

local Remotes = require(ReplicatedStorage.Shared.Remotes)
local GuiUtil = require(PlayerScripts.Client.Shared.Util.GuiUtil)
local PlayerClientService = require(PlayerScripts.Client.Shared.Service.PlayerClientService)
local GradeDatabase = require(ReplicatedStorage.Shared.Databases.GradeDatabase)
local AssetDatabase = require(ReplicatedStorage.Shared.Databases.AssetsDatabase)

local PreviewAssets = ReplicatedStorage:WaitForChild("PreviewAssets")

local UpdateInventoryUIRemote = ReplicatedStorage.Remotes:WaitForChild(Remotes.UpdateInventoryUIRemote)
local RequestAsset3DPreviewRemote = ReplicatedStorage.Remotes.Functions:WaitForChild(Remotes.RequestAsset3DPreviewRemote)

local MainGui = GuiUtil:GetMainGui()

local InventoryGui = MainGui:WaitForChild("InventoryGui")
local InventoryFrame = InventoryGui:WaitForChild("InventoryFrame")
local ListFrame = InventoryFrame:WaitForChild("ListFrame")
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

local template = ListFrame:WaitForChild("Template")

local playerData
local rotateConnection
local assetCount = 0
local MAX_INVENTORY = 100

local InventoryController = {}

local function updateInventoryCount()
	CapacityLabel.Text = string.format("Capacity: %d/%d", assetCount, MAX_INVENTORY)
end

local function displayNoInventory()
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
end

local function createPreview(asset, previewType)

	if previewType == "2D" then
		ViewAsset2D.Image = "https://www.roblox.com/asset-thumbnail/image?assetId=" .. asset.AssetId .. "&width=420&height=420&format=png"
		return
	end

	local camera = Instance.new("Camera")
	camera.Parent = ViewAsset3D
	ViewAsset3D.CurrentCamera = camera

	RequestAsset3DPreviewRemote:InvokeServer(asset.AssetId)

	local preview = PreviewAssets:WaitForChild(tostring(asset.AssetId))

	local handle = preview:FindFirstChild("Handle")
	if not handle then
		warn("Handle missing:", asset.AssetId)
		return
	end

	local clone = handle:Clone()
	clone.Parent = ViewAsset3D
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

local function stopPreviewRotation()
    if rotateConnection then
        rotateConnection:Disconnect()
        rotateConnection = nil
    end

    ViewAsset3D:ClearAllChildren()
end

local function startPreviewRotation(asset)
    stopPreviewRotation()

    local handle = createPreview(asset, "3D")
    if not handle then
        return
    end

    rotateConnection = RunService.RenderStepped:Connect(function()
        if handle.Parent then
            handle.CFrame *= CFrame.Angles(0, math.rad(1), 0)
        end
    end)
end

local function showAssetDetails(asset)

    DetailsFrame:SetAttribute("AssetId", asset.AssetId)
	DetailsFrame.Visible = true

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

	createPreview(asset, "2D")
end

local function createAssetFrame(assetKey, assetData)

    local frame = template:Clone()

    frame.Name = assetKey
    frame.Visible = true
    frame.Parent = ListFrame

    local GradeLabel = frame:WaitForChild("GradeLabel")
    local MutationLabel = frame:WaitForChild("MutationLabel")
    local QuantityLabel = frame:WaitForChild("QuantityLabel")
    local ImageLabel = frame:WaitForChild("ImageLabel")

    GradeLabel.Text = assetData.Grade
    GradeLabel.BackgroundColor3 = GradeDatabase[assetData.Grade].Color

    MutationLabel.Text = assetData.Mutation or "Error"

    CollectionService:AddTag(GradeLabel, assetData.Grade)
    CollectionService:AddTag(MutationLabel, assetData.Mutation)

    QuantityLabel.Text = "x" .. (assetData.Quantity or 1)

    ImageLabel.Image =
        "https://www.roblox.com/asset-thumbnail/image?assetId="
        .. assetData.AssetId
        .. "&width=420&height=420&format=png"

    frame.MouseButton1Click:Connect(function()
        showAssetDetails(assetData)
    end)

    return frame
end

local function loadInventory()

    local inventory = playerData.Inventory
    local assets = inventory.Assets

    if not next(assets) then
        displayNoInventory()
        return
    end

    for assetKey, assetData in pairs(assets) do
        assetCount += 1
        createAssetFrame(assetKey, assetData)
    end
end

function InventoryController:Initialize()

    playerData = PlayerClientService:GetPlayerData()

    loadInventory()
    updateInventoryCount()
end

Button3D.MouseButton1Click:Connect(function()
    ViewAsset2D.Visible = false
    ViewAsset3D.Visible = true

    Button3D.Visible = false
    Button2D.Visible = true

    local assetId = DetailsFrame:GetAttribute("AssetId")
    local assetData = AssetDatabase[assetId]

    if assetData then
        startPreviewRotation(assetData)
    end
end)

Button2D.MouseButton1Click:Connect(function()
    stopPreviewRotation()

    ViewAsset2D.Visible = true
    ViewAsset3D.Visible = false

    Button3D.Visible = true
    Button2D.Visible = false
end)

UpdateInventoryUIRemote.OnClientEvent:Connect(function(update)

    if update.Action == "Add" then

        assetCount += 1
        createAssetFrame(update.AssetKey, update.AssetData)
        updateInventoryCount()

    elseif update.Action == "Update" then

        local frame = ListFrame:FindFirstChild(update.AssetKey)

        if frame then
            local quantityLabel = frame:FindFirstChild("QuantityLabel")

            if quantityLabel then
                quantityLabel.Text = "x" .. (update.AssetData.Quantity)
            end
        end

    elseif update.Action == "Remove" then

        local frame = ListFrame:FindFirstChild(update.AssetKey)

        if frame then
            frame:Destroy()
        end
    end
end)

return InventoryController