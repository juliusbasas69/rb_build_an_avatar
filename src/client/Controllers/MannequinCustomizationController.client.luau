local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Tags = require(ReplicatedStorage.Shared.Tags)
local GradeDatabase = require(ReplicatedStorage.Shared.Databases.GradeDatabase)
local AssetDatabase = require(ReplicatedStorage.Shared.Databases.AssetsDatabase)

local ReplicatedAssets = ReplicatedStorage:WaitForChild("Assets")	

local GetPlayerDataRemote = ReplicatedStorage.Remotes.Functions:WaitForChild(Remotes.GetPlayerDataRemote)
local UpdateInventoryUIRemote = ReplicatedStorage.Remotes:WaitForChild(Remotes.UpdateInventoryUIRemote)
local OpenMannequinCustomizationUIRemote = ReplicatedStorage.Remotes:WaitForChild(Remotes.OpenMannequinCustomizationUIRemote)

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

local MannequinCustomizationGui = MainGui:WaitForChild("MannequinCustomizationGui")
local InventoryFrame = MannequinCustomizationGui:WaitForChild("InventoryFrame")
local PreviewFrame = MannequinCustomizationGui:WaitForChild("PreviewFrame")
local PreviewViewPort = PreviewFrame:WaitForChild("ViewportFrame")
local ListFrame = InventoryFrame:WaitForChild("ListFrame")

local StatsButton = PreviewFrame:WaitForChild("StatsButton")
local StatsFrame = PreviewFrame:WaitForChild("StatsFrame")

local HideButton = PreviewFrame:WaitForChild("HideButton")
local ShowButton = PreviewFrame:WaitForChild("ShowButton")

local template = ListFrame:WaitForChild("Template")

local StatusLabel = ListFrame:WaitForChild("StatusLabel")

local assets = {}
local inventoryFrames = {}

for _, assetData in pairs(PlayerData.Assets or {}) do
	table.insert(assets, assetData)
end

local function getAssetKey(assetId, mutation, grade)
	return tostring(assetId) .. "_" .. mutation .. "_" .. grade
end

StatsButton.MouseEnter:Connect(function()
	StatsFrame.Visible = true
end)

StatsButton.MouseLeave:Connect(function()
	StatsFrame.Visible = false
end)

local function setTaggedObjectsVisible(visible)
	for _, object in ipairs(CollectionService:GetTagged(Tags.SlotsUITag)) do
		if object:IsA("ImageButton") then
			object.Visible = visible
		end
	end
end

HideButton.MouseButton1Click:Connect(function()
	setTaggedObjectsVisible(false)

	HideButton.Visible = false
	ShowButton.Visible = true
end)

ShowButton.MouseButton1Click:Connect(function()
	setTaggedObjectsVisible(true)

	ShowButton.Visible = false
	HideButton.Visible = true
end)

local rotateConnection

local function createMannequinPreview(platformId)
	PreviewViewPort:ClearAllChildren()

	if rotateConnection then
		rotateConnection:Disconnect()
		rotateConnection = nil
	end

	local camera = Instance.new("Camera")
	camera.Parent = PreviewViewPort
	PreviewViewPort.CurrentCamera = camera

	local plot = workspace.Plots:FindFirstChild(player.UserId)

	if not plot then
		warn("Plot not found.")
		return
	end

	local platform = plot:WaitForChild("Platforms"):FindFirstChild(platformId)

	if not platform then
		warn("Platform not found:", platformId)
		return
	end

	local mannequin = platform:FindFirstChild("PlacedMannequin")

	if not mannequin then
		warn("PlacedMannequin not found.")
		return
	end

	local clone = mannequin:Clone()
	clone.Parent = PreviewViewPort

	for _, obj in ipairs(clone:GetDescendants()) do
		if obj:IsA("BasePart") then
			obj.Anchored = true
		end
	end

	local cf, size = clone:GetBoundingBox()
	local center = cf.Position

	camera.CFrame = CFrame.lookAt(
		center + Vector3.new(0, 1, -size.Y),
		center
	)

	rotateConnection = RunService.RenderStepped:Connect(function()
		if clone.Parent then
			clone:PivotTo(clone:GetPivot() * CFrame.Angles(0, math.rad(1), 0))
		end
	end)

	return clone
end

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

	clone.CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(rotation.X), math.rad(rotation.Y), math.rad(rotation.Z))

	camera.CFrame = CFrame.lookAt(
		clone.Position + Vector3.new(0, height, distance),
		clone.Position + Vector3.new(0, height, 0)
	)

	return clone
end

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

	frame:SetAttribute("AssetId", asset.AssetId)
	frame:SetAttribute("Grade", asset.Grade)
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

		createPreview(asset, frame:WaitForChild("ViewportFrame"))

		frame.Visible = true
	end)

	frame.MouseButton1Click:Connect(function()
		local PlacedMannequin = PreviewViewPort:WaitForChild("PlacedMannequin")
		local Humanoid = PlacedMannequin:WaitForChild("Humanoid")

		local assetId = frame:GetAttribute("AssetId")

		if not assetId then
			warn("No AssetId found")
			return
		end

		local assetData = AssetDatabase[assetId]

		if not assetData then
			warn("No asset data found for:", assetId)
			return
		end

		local description = Humanoid:GetAppliedDescription()

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

			table.insert(accessories, {
				AssetId = assetId,
				AccessoryType = accessoryType,
				IsLayered = true,
				Order = #accessories + 1
			})

			description:SetAccessories(accessories, true)

		-- Classic Accessories
		elseif accessoryType == Enum.AccessoryType.Hat then
			
			description.HatAccessory = description.HatAccessory .. "," .. assetId

		elseif accessoryType == Enum.AccessoryType.Hair then
			
			description.HairAccessory = description.HairAccessory .. "," .. assetId

		elseif accessoryType == Enum.AccessoryType.Face then
			
			description.FaceAccessory = description.FaceAccessory .. "," .. assetId

		elseif accessoryType == Enum.AccessoryType.Neck then
			
			description.NeckAccessory = description.NeckAccessory .. "," .. assetId

		elseif accessoryType == Enum.AccessoryType.Shoulder then
			
			description.ShoulderAccessory = description.ShoulderAccessory .. "," .. assetId

		elseif accessoryType == Enum.AccessoryType.Front then
			
			description.FrontAccessory = description.FrontAccessory .. "," .. assetId

		elseif accessoryType == Enum.AccessoryType.Back then
			
			description.BackAccessory = description.BackAccessory .. "," .. assetId

		elseif accessoryType == Enum.AccessoryType.Waist then
			
			description.WaistAccessory = description.WaistAccessory .. "," .. assetId
		end

		Humanoid:ApplyDescription(description)
	end)

	return frame
end

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

template.Visible = false
StatusLabel.Visible = false

loadInventory()

OpenMannequinCustomizationUIRemote.OnClientEvent:Connect(function(mannequinId, platformId)

    MainGui.Menu.Visible = false
    MainGui.MannequinCustomizationGui.Visible = true

	createMannequinPreview(platformId)
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