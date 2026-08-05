-- local ReplicatedStorage = game:GetService("ReplicatedStorage")
-- local CollectionService = game:GetService("CollectionService")
-- local RunService = game:GetService("RunService")
-- local Players = game:GetService("Players")
-- local TweenService = game:GetService("TweenService")

-- local Remotes = require(ReplicatedStorage.Shared.Remotes)
-- local GradeDatabase = require(ReplicatedStorage.Shared.Databases.GradeDatabase)
-- local AssetDatabase = require(ReplicatedStorage.Shared.Databases.AssetsDatabase)

-- local AssetKey = require(ReplicatedStorage.Shared.Util.AssetKey)

-- local OutfitData = require(ReplicatedStorage.Shared.Data.OutfitData)

-- local GetPlayerDataRemote = ReplicatedStorage.Remotes.Functions:WaitForChild(Remotes.GetPlayerDataRemote)
-- local UpdateInventoryUIRemote = ReplicatedStorage.Remotes:WaitForChild(Remotes.UpdateInventoryUIRemote)
-- local OpenMannequinCustomizationUIRemote = ReplicatedStorage.Remotes:WaitForChild(Remotes.OpenMannequinCustomizationUIRemote)
-- local SaveMannequinOutfitRemote = ReplicatedStorage.Remotes:WaitForChild(Remotes.SaveMannequinOutfitRemote)

-- local player = Players.LocalPlayer

-- local GetMainGui = require(player:WaitForChild("PlayerScripts"):WaitForChild("Client"):WaitForChild("Shared"):WaitForChild("GetMainGui"))

-- local MainGui = GetMainGui()

-- local MannequinCustomizationGui = MainGui:WaitForChild("MannequinCustomizationGui")
-- local InventoryFrame = MannequinCustomizationGui:WaitForChild("InventoryFrame")
-- local PreviewFrame = MannequinCustomizationGui:WaitForChild("PreviewFrame")
-- local PreviewViewPort = PreviewFrame:WaitForChild("ViewportFrame")
-- local ListFrame = InventoryFrame:WaitForChild("ListFrame")

-- local StatsButton = PreviewFrame:WaitForChild("StatsButton")
-- local StatsFrame = PreviewFrame:WaitForChild("StatsFrame")

-- local HideButton = PreviewFrame:WaitForChild("HideButton")
-- local ShowButton = PreviewFrame:WaitForChild("ShowButton")

-- local ZoomInButton = PreviewFrame:WaitForChild("ZoomInButton")
-- local ZoomOutButton = PreviewFrame:WaitForChild("ZoomOutButton")

-- local SlotsFrame = PreviewFrame:WaitForChild("SlotsFrame")
-- local NextButton = PreviewFrame:WaitForChild("NextButton")
-- local PrevButton = PreviewFrame:WaitForChild("PrevButton")

-- local SaveButton = PreviewFrame:WaitForChild("SaveButton")

-- local template = ListFrame:WaitForChild("Template")

-- local StatusLabel = InventoryFrame:WaitForChild("StatusLabel")
-- local CapacityLabel = InventoryFrame:WaitForChild("CapacityFrame"):WaitForChild("CapacityLabel")

-- local assets = {}
-- local inventoryFrames = {}

-- local MAX_INVENTORY = 100

-- local previewCamera
-- local previewCenter
-- local zoomDistance = 5
-- local MIN_ZOOM = 2
-- local MAX_ZOOM = 8

-- local SCROLL_AMOUNT = 280

-- local PlatformId = 0

-- local PlayerData

-- local function refreshPlayerData()
-- 	PlayerData = GetPlayerDataRemote:InvokeServer()

-- 	if PlayerData then
-- 		table.clear(assets)

-- 		for _, asset in pairs(PlayerData.Assets or {}) do
-- 			table.insert(assets, asset)
-- 		end
-- 	end
-- end

-- local function updateInventoryCount()
-- 	CapacityLabel.Text = string.format("Capacity: %d/%d", #assets, MAX_INVENTORY)
-- end

-- local function getAssetKey(assetId, mutation, grade)
-- 	return tostring(assetId) .. "_" .. mutation .. "_" .. grade
-- end

-- local function setTaggedObjectsVisible(visible)
-- 	SlotsFrame.Visible = visible
-- 	NextButton.Visible = visible
-- 	PrevButton.Visible = visible
-- end

-- local function scroll(amount)
-- 	local canvasWidth = SlotsFrame.AbsoluteCanvasSize.X
-- 	local windowWidth = SlotsFrame.AbsoluteWindowSize.X

-- 	local maxX = math.max(0, canvasWidth - windowWidth)

-- 	local newX = math.clamp(
-- 		SlotsFrame.CanvasPosition.X + amount,
-- 		0,
-- 		maxX
-- 	)

-- 	TweenService:Create(
-- 		SlotsFrame,
-- 		TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
-- 		{
-- 			CanvasPosition = Vector2.new(newX, 0)
-- 		}
-- 	):Play()
-- end

-- local function updatePreviewCamera()
-- 	if previewCamera and previewCenter then
-- 		previewCamera.CFrame = CFrame.lookAt(
-- 			previewCenter + Vector3.new(0, 1, -zoomDistance),
-- 			previewCenter
-- 		)
-- 	end
-- end

-- local rotateConnection

-- local function createMannequinPreview(platformId)
-- 	PlatformId = platformId
-- 	PreviewViewPort:ClearAllChildren()

-- 	if rotateConnection then
-- 		rotateConnection:Disconnect()
-- 		rotateConnection = nil
-- 	end

-- 	previewCamera = Instance.new("Camera")
-- 	previewCamera.Parent = PreviewViewPort
-- 	PreviewViewPort.CurrentCamera = previewCamera

-- 	local plot = workspace.Plots:FindFirstChild(player.UserId)

-- 	if not plot then
-- 		warn("Plot not found.")
-- 		return
-- 	end

-- 	local platform = plot:WaitForChild("Platforms"):FindFirstChild(platformId)

-- 	if not platform then
-- 		warn("Platform not found:", platformId)
-- 		return
-- 	end

-- 	local mannequin = platform:FindFirstChild("PlacedMannequin")

-- 	if not mannequin then
-- 		warn("PlacedMannequin not found.")
-- 		return
-- 	end

-- 	local clone = mannequin:Clone()
-- 	clone.Parent = PreviewViewPort

-- 	for _, obj in ipairs(clone:GetDescendants()) do
-- 		if obj:IsA("BasePart") then
-- 			obj.Anchored = true
-- 		end
-- 	end

-- 	local cf, size = clone:GetBoundingBox()
-- 	local center = cf.Position

-- 	previewCenter = center
-- 	zoomDistance = size.Y -- Reset zoom when opening a new mannequin
-- 	updatePreviewCamera()

-- 	rotateConnection = RunService.RenderStepped:Connect(function()
-- 		if clone.Parent then
-- 			clone:PivotTo(clone:GetPivot() * CFrame.Angles(0, math.rad(1), 0))
-- 		end
-- 	end)

-- 	return clone
-- end

-- local function createPreview(asset, frame)

-- 	frame.Image =
-- 		"https://www.roblox.com/asset-thumbnail/image?assetId="
-- 		.. asset.AssetId
-- 		.. "&width=420&height=420&format=png"

-- end

-- local function createItemFrame(asset)

--     StatusLabel.Visible = false

-- 	local key = AssetKey:Create(
-- 		asset.AssetId,
-- 		asset.Grade,
-- 		asset.Mutation
-- 	)

-- 	if inventoryFrames[key] then
-- 		return inventoryFrames[key]
-- 	end

-- 	local frame = template:Clone()

-- 	frame.Name = key
-- 	frame.Visible = false
-- 	frame.Parent = ListFrame

-- 	frame:SetAttribute("AssetKey", AssetKey:Create(asset.AssetId, asset.Grade, asset.Mutation))
-- 	frame:SetAttribute("AssetId", asset.AssetId)
-- 	frame:SetAttribute("Grade", asset.Grade)
-- 	frame:SetAttribute("Mutation", asset.Mutation)

-- 	local GradeLabel = frame:WaitForChild("GradeLabel")
-- 	local MutationLabel = frame:WaitForChild("MutationLabel")
--     local QuantityLabel = frame:WaitForChild("QuantityLabel")

--     GradeLabel.Text = asset.Grade
--     GradeLabel.BackgroundColor3 = GradeDatabase[asset.Grade].Color

-- 	MutationLabel.Text = asset.Mutation or "Error"

-- 	CollectionService:AddTag(GradeLabel, asset.Grade)
-- 	CollectionService:AddTag(MutationLabel, asset.Mutation)

--     QuantityLabel.Text = "x" .. (asset.Quantity or 1)
    
-- 	inventoryFrames[key] = frame

-- 	task.spawn(function()

-- 		createPreview(asset, frame:WaitForChild("ViewItem"))

-- 		frame.Visible = true
-- 	end)

-- 	frame.MouseButton1Click:Connect(function()
-- 		local PlacedMannequin = PreviewViewPort:WaitForChild("PlacedMannequin")
-- 		local Humanoid = PlacedMannequin:WaitForChild("Humanoid")

-- 		local assetId = frame:GetAttribute("AssetId")

-- 		if not assetId then
-- 			warn("No AssetId found")
-- 			return
-- 		end

-- 		local assetKey = frame:GetAttribute("AssetKey")

-- 		if not assetKey then
-- 			warn("No AssetKey found")
-- 			return
-- 		end

-- 		local assetData = AssetDatabase[assetId]

-- 		if not assetData then
-- 			warn("No asset data found for:", assetId)
-- 			return
-- 		end

-- 		local description = Humanoid:GetAppliedDescription()

-- 		local accessoryType = assetData.AccessoryType

-- 		-- Layered Clothing
-- 		if accessoryType == Enum.AccessoryType.Jacket
-- 			or accessoryType == Enum.AccessoryType.Shirt
-- 			or accessoryType == Enum.AccessoryType.Pants
-- 			or accessoryType == Enum.AccessoryType.Sweater
-- 			or accessoryType == Enum.AccessoryType.DressSkirt
-- 			or accessoryType == Enum.AccessoryType.Shorts
-- 			or accessoryType == Enum.AccessoryType.LeftShoe
-- 			or accessoryType == Enum.AccessoryType.RightShoe
-- 			or accessoryType == Enum.AccessoryType.TShirt then

-- 			local accessories = description:GetAccessories(true)

-- 			table.insert(accessories, {
-- 				AssetId = assetId,
-- 				AccessoryType = accessoryType,
-- 				IsLayered = true,
-- 				Order = #accessories + 1
-- 			})

-- 			description:SetAccessories(accessories, true)

-- 			if accessoryType == Enum.AccessoryType.TShirt then
-- 				OutfitData.TShirtAccessory = assetKey
-- 			elseif accessoryType == Enum.AccessoryType.Shirt then
-- 				OutfitData.ShirtAccessory = assetKey
-- 			elseif accessoryType == Enum.AccessoryType.Pants then
-- 				OutfitData.PantsAccessory = assetKey
-- 			elseif accessoryType == Enum.AccessoryType.Jacket then
-- 				OutfitData.JacketAccessory = assetKey
-- 			elseif accessoryType == Enum.AccessoryType.Sweater then
-- 				OutfitData.SweaterAccessory = assetKey
-- 			elseif accessoryType == Enum.AccessoryType.Shorts then
-- 				OutfitData.ShortsAccessory = assetKey
-- 			elseif accessoryType == Enum.AccessoryType.LeftShoe then
-- 				OutfitData.LeftShoeAccessory = assetKey
-- 			elseif accessoryType == Enum.AccessoryType.RightShoe then
-- 				OutfitData.RightShoeAccessory = assetKey
-- 			elseif accessoryType == Enum.AccessoryType.DressSkirt then
-- 				OutfitData.DressSkirtAccessory = assetKey
-- 			elseif accessoryType == Enum.AccessoryType.Eyebrow then
-- 				OutfitData.EyebrowAccessory = assetKey
-- 			elseif accessoryType == Enum.AccessoryType.Eyelash then
-- 				OutfitData.EyelashAccessory = assetKey
-- 			end

-- 		-- Classic Accessories
-- 		elseif accessoryType == Enum.AccessoryType.Hat then

-- 			description.HatAccessory = description.HatAccessory .. "," .. assetId
-- 			OutfitData.Hat = assetKey

-- 		elseif accessoryType == Enum.AccessoryType.Hair then

-- 			description.HairAccessory = description.HairAccessory .. "," .. assetId
-- 			OutfitData.Hair = assetKey

-- 		elseif accessoryType == Enum.AccessoryType.Face then

-- 			description.FaceAccessory = description.FaceAccessory .. "," .. assetId
-- 			OutfitData.FaceAccessory = assetKey

-- 		elseif accessoryType == Enum.AccessoryType.Neck then

-- 			description.NeckAccessory = description.NeckAccessory .. "," .. assetId
-- 			OutfitData.NeckAccessory = assetKey

-- 		elseif accessoryType == Enum.AccessoryType.Shoulder then

-- 			description.ShoulderAccessory = description.ShoulderAccessory .. "," .. assetId
-- 			OutfitData.ShoulderAccessory = assetKey

-- 		elseif accessoryType == Enum.AccessoryType.Front then

-- 			description.FrontAccessory = description.FrontAccessory .. "," .. assetId
-- 			OutfitData.FrontAccessory = assetKey

-- 		elseif accessoryType == Enum.AccessoryType.Back then

-- 			description.BackAccessory = description.BackAccessory .. "," .. assetId
-- 			OutfitData.BackAccessory = assetKey

-- 		elseif accessoryType == Enum.AccessoryType.Waist then

-- 			description.WaistAccessory = description.WaistAccessory .. "," .. assetId
-- 			OutfitData.WaistAccessory = assetKey
-- 		end

-- 		Humanoid:ApplyDescription(description)
-- 	end)

-- 	return frame
-- end

-- local function loadInventory()

-- 	StatusLabel.Text = "🌿 Loading your inventory..."
-- 	StatusLabel.Visible = true

-- 	StatusLabel.BackgroundTransparency = 1
-- 	StatusLabel.TextColor3 = Color3.fromHex("#4E7A4A")
-- 	StatusLabel.TextStrokeColor3 = Color3.fromHex("#FFFFFF")
-- 	StatusLabel.TextStrokeTransparency = 0.65
-- 	StatusLabel.Font = Enum.Font.FredokaOne -- or GothamBold
-- 	StatusLabel.TextSize = 22
-- 	StatusLabel.TextWrapped = true

-- 	table.clear(inventoryFrames)

-- 	for _, child in ipairs(ListFrame:GetChildren()) do
-- 		if child:IsA("ImageButton") and child ~= template then
-- 			child:Destroy()
-- 		end
-- 	end

-- 	if #assets == 0 then
-- 		StatusLabel.Text = "🍃 Your inventory is empty!"
-- 		StatusLabel.Visible = true

-- 		-- Styling
-- 		StatusLabel.BackgroundTransparency = 1
-- 		StatusLabel.TextColor3 = Color3.fromHex("#4FA9F5")
-- 		StatusLabel.TextStrokeColor3 = Color3.fromHex("#FFFFFF")
-- 		StatusLabel.TextStrokeTransparency = 0.65
-- 		StatusLabel.Font = Enum.Font.LuckiestGuy -- or GothamBold if you prefer
-- 		StatusLabel.TextSize = 22
-- 		StatusLabel.TextWrapped = true

-- 		return
-- 	end

-- 	-- Create UI
-- 	for _, asset in ipairs(assets) do
-- 		createItemFrame(asset)
-- 	end


-- 	StatusLabel.Visible = false
-- end

-- template.Visible = false
-- StatusLabel.Visible = false

-- refreshPlayerData()
-- loadInventory()
-- updateInventoryCount()

-- StatsButton.MouseEnter:Connect(function()
-- 	StatsFrame.Visible = true

-- 	NextButton.Visible = false
-- 	PrevButton.Visible = false
-- 	SlotsFrame.Visible = false
-- end)

-- StatsButton.MouseLeave:Connect(function()
-- 	StatsFrame.Visible = false

-- 	NextButton.Visible = true
-- 	PrevButton.Visible = true
-- 	SlotsFrame.Visible = true
-- end)

-- HideButton.MouseButton1Click:Connect(function()
-- 	setTaggedObjectsVisible(false)

-- 	HideButton.Visible = false
-- 	ShowButton.Visible = true
-- end)

-- ShowButton.MouseButton1Click:Connect(function()
-- 	setTaggedObjectsVisible(true)

-- 	ShowButton.Visible = false
-- 	HideButton.Visible = true
-- end)

-- ZoomInButton.MouseButton1Click:Connect(function()
-- 	zoomDistance = math.max(MIN_ZOOM, zoomDistance - 0.5)
-- 	updatePreviewCamera()
-- end)

-- ZoomOutButton.MouseButton1Click:Connect(function()
-- 	zoomDistance = math.min(MAX_ZOOM, zoomDistance + 0.5)
-- 	updatePreviewCamera()
-- end)

-- NextButton.MouseButton1Click:Connect(function()
-- 	scroll(SCROLL_AMOUNT)
-- end)

-- PrevButton.MouseButton1Click:Connect(function()
-- 	scroll(-SCROLL_AMOUNT)
-- end)

-- SaveButton.MouseButton1Click:Connect(function()
-- 	print("PLATFORM ID: " , PlatformId)
-- 	SaveMannequinOutfitRemote:FireServer(PlatformId, outfitData)
-- end)

-- OpenMannequinCustomizationUIRemote.OnClientEvent:Connect(function(mannequinId, platformId)

--     MainGui.Menu.Visible = false
--     MainGui.MannequinCustomizationGui.Visible = true

-- 	createMannequinPreview(platformId)
-- end)


-- UpdateInventoryUIRemote.OnClientEvent:Connect(function(update)

-- 	if update.Action == "Add" then

-- 		local assetData = update.Data

-- 		table.insert(
-- 			assets,
-- 			assetData
-- 		)

-- 		createItemFrame(assetData)

-- 	elseif update.Action == "Update" then

-- 		local key = AssetKey:Create(
-- 			update.Data.AssetId,
-- 			update.Data.Grade,
-- 			update.Data.Mutation
-- 		)

-- 		local frame = inventoryFrames[key]

--         if frame then

--             frame:SetAttribute("Quantity", update.Data.Quantity)

--             local QuantityLabel = frame:FindFirstChild("QuantityLabel")

--             if QuantityLabel then
--                 QuantityLabel.Text = "x" .. (update.Data.Quantity or 1)
--             end
--         end

-- 	elseif update.Action == "Remove" then

-- 		local key = AssetKey:Create(
-- 			update.AssetId,
-- 			update.Grade,
-- 			update.Mutation
-- 		)

-- 		local frame = inventoryFrames[key]

-- 		if frame then

-- 			frame:Destroy()
-- 			inventoryFrames[key] = nil
-- 		end
-- 	end
-- end)