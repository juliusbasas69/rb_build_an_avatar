local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerScripts = Player:WaitForChild("PlayerScripts")

local Remotes = require(ReplicatedStorage.Shared.Remotes)
local GradeDatabase = require(ReplicatedStorage.Shared.Databases.GradeDatabase)
local AssetDatabase = require(ReplicatedStorage.Shared.Databases.AssetsDatabase)

local AssetKey = require(ReplicatedStorage.Shared.Util.AssetKey)
local GuiUtil = require(PlayerScripts.Client.Shared.Util.GuiUtil)
local UIUtil = require(PlayerScripts.Client.Shared.Util.UIUtil)
local WardrobeUtil = require(PlayerScripts.Client.Shared.Util.WardrobeUtil)
local PlayerClientService = require(PlayerScripts.Client.Shared.Service.PlayerClientService)

local WardrobeData = require(ReplicatedStorage.Shared.Data.WardrobeData)

local UpdateInventoryUIRemote = ReplicatedStorage.Remotes:WaitForChild(Remotes.UpdateInventoryUIRemote)
local OpenWardrobeUIRemote = ReplicatedStorage.Remotes:WaitForChild(Remotes.OpenWardrobeUIRemote)
local SaveWardrobeRemote = ReplicatedStorage.Remotes:WaitForChild(Remotes.SaveWardrobeRemote)

local MainGui = GuiUtil:GetMainGui()

local MenuGui = MainGui:WaitForChild("MenuGui")
local WardrobeGui = MainGui:WaitForChild("WardrobeGui")
local InventoryFrame = WardrobeGui:WaitForChild("InventoryFrame")
local PreviewFrame = WardrobeGui:WaitForChild("PreviewFrame")
local PreviewViewPort = PreviewFrame:WaitForChild("ViewportFrame")
local ListFrame = InventoryFrame:WaitForChild("ListFrame")
local StatsButton = PreviewFrame:WaitForChild("StatsButton")
local StatsFrame = PreviewFrame:WaitForChild("StatsFrame")
local HideButton = PreviewFrame:WaitForChild("HideButton")
local ShowButton = PreviewFrame:WaitForChild("ShowButton")
local ZoomInButton = PreviewFrame:WaitForChild("ZoomInButton")
local ZoomOutButton = PreviewFrame:WaitForChild("ZoomOutButton")
local SlotsFrame = PreviewFrame:WaitForChild("SlotsFrame")
local NextButton = PreviewFrame:WaitForChild("NextButton")
local PrevButton = PreviewFrame:WaitForChild("PrevButton")
local SaveButton = PreviewFrame:WaitForChild("SaveButton")
local ExitButton = StatsFrame:WaitForChild("ExitButton")
local StatusLabel = InventoryFrame:WaitForChild("StatusLabel")
local CapacityLabel = InventoryFrame:WaitForChild("CapacityFrame"):WaitForChild("CapacityLabel")

local SlotNames = {
	[Enum.AccessoryType.Hair] = "HairAccessorySlot",
	[Enum.AccessoryType.Hat] = "HatAccessorySlot",
	[Enum.AccessoryType.Face] = "FaceAccessorySlot",
	[Enum.AccessoryType.Neck] = "NeckAccessorySlot",
	[Enum.AccessoryType.Shoulder] = "ShoulderAccessorySlot",
	[Enum.AccessoryType.Front] = "FrontAccessorySlot",
	[Enum.AccessoryType.Back] = "BackAccessorySlot",
	[Enum.AccessoryType.Waist] = "WaistAccessorySlot",

	[Enum.AccessoryType.TShirt] = "TShirtAccessorySlot",
	[Enum.AccessoryType.Shirt] = "ShirtAccessorySlot",
	[Enum.AccessoryType.Pants] = "PantsAccessorySlot",
	[Enum.AccessoryType.Jacket] = "JacketAccessorySlot",
	[Enum.AccessoryType.Sweater] = "SweaterAccessorySlot",
	[Enum.AccessoryType.Shorts] = "ShortsAccessorySlot",
	[Enum.AccessoryType.LeftShoe] = "LeftShoeAccessorySlot",
	[Enum.AccessoryType.RightShoe] = "RightShoeAccessorySlot",
	[Enum.AccessoryType.DressSkirt] = "DressSkirtAccessorySlot",
}

local template = ListFrame:WaitForChild("Template")

local MAX_INVENTORY = 100
local SCROLL_AMOUNT = 255
local assetCount = 0
local playerData
local currentPlatformId
local rotateConnection
local previewCamera
local previewCenter
local zoomDistance = 5
local MIN_ZOOM = 2
local MAX_ZOOM = 8

local WardrobeController = {}

local function updateInventoryCount()
	CapacityLabel.Text = string.format("Capacity: %d/%d", assetCount, MAX_INVENTORY)
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

    ImageLabel.Image = "https://www.roblox.com/asset-thumbnail/image?assetId=" .. assetData.AssetId .. "&width=420&height=420&format=png"

    frame.MouseButton1Click:Connect(function()

        local placedMannequin = PreviewViewPort:WaitForChild("PlacedMannequin")

		local data = WardrobeUtil:ApplyAsset(WardrobeData, placedMannequin, assetKey)

        WardrobeData = data

        local accessoryType = AssetDatabase[AssetKey:Parse(assetKey).AssetId].AccessoryType
        local slot = SlotsFrame:FindFirstChild(SlotNames[accessoryType])

        if slot then
            WardrobeUtil:UpdatePreviewSlots(slot, assetKey)
        end
	end)
end

local function scrollSlotsFrame(amount)
	local canvasWidth = SlotsFrame.AbsoluteCanvasSize.X
	local windowWidth = SlotsFrame.AbsoluteWindowSize.X

	local maxX = math.max(0, canvasWidth - windowWidth)

	local newX = math.clamp(
		SlotsFrame.CanvasPosition.X + amount,
		0,
		maxX
	)

	TweenService:Create(
		SlotsFrame,
		TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{
			CanvasPosition = Vector2.new(newX, 0)
		}
	):Play()
end

local function updatePreviewCamera()
	if previewCamera and previewCenter then
		previewCamera.CFrame = CFrame.lookAt(
			previewCenter + Vector3.new(0, 1, -zoomDistance),
			previewCenter
		)
	end
end

local function createMannequinPreview(platformId)
	
	PreviewViewPort:ClearAllChildren()

	if rotateConnection then
		rotateConnection:Disconnect()
		rotateConnection = nil
	end

	previewCamera = Instance.new("Camera")
	previewCamera.Parent = PreviewViewPort
	PreviewViewPort.CurrentCamera = previewCamera

	local plot = workspace.Plots:FindFirstChild(Player.UserId)

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

	local cf, size = clone:GetBoundingBox()
	local center = cf.Position

	previewCenter = center
	zoomDistance = size.Y
	updatePreviewCamera()

	rotateConnection = RunService.RenderStepped:Connect(function()
		if clone.Parent then
			clone:PivotTo(clone:GetPivot() * CFrame.Angles(0, math.rad(1), 0))
		end
	end)

	return clone
end

local function loadInventory()

    local inventory = playerData.Inventory
    local assets = inventory.Assets

    if not next(assets) then
        UIUtil:DisplayNoInventory(StatusLabel, Color3.fromHex("#4da9e8"))
        return
    end

    for assetKey, assetData in pairs(assets) do
        assetCount += 1
        createAssetFrame(assetKey, assetData)
    end
end

function WardrobeController:Initialize()

    playerData = PlayerClientService:GetPlayerData()

    loadInventory()
    updateInventoryCount()
end

StatsButton.MouseButton1Click:Connect(function()
	StatsFrame.Visible = not StatsFrame.Visible
	local showMain = not StatsFrame.Visible
	NextButton.Visible = showMain
	PrevButton.Visible = showMain
	SlotsFrame.Visible = showMain
end)

HideButton.MouseButton1Click:Connect(function()
	SlotsFrame.Visible = false
    StatsButton.Visible = false
    HideButton.Visible = false
    ZoomInButton.Visible = false
    ZoomOutButton.Visible = false
    NextButton.Visible = false
    PrevButton.Visible = false
	ShowButton.Visible = true
end)

ShowButton.MouseButton1Click:Connect(function()
	SlotsFrame.Visible = true
    StatsButton.Visible = true
	HideButton.Visible = true
    ZoomInButton.Visible = true
    ZoomOutButton.Visible = true
    NextButton.Visible = true
    PrevButton.Visible = true
    ShowButton.Visible = false
end)

ZoomInButton.MouseButton1Click:Connect(function()
	zoomDistance = math.max(MIN_ZOOM, zoomDistance - 0.5)
	updatePreviewCamera()
end)

ZoomOutButton.MouseButton1Click:Connect(function()
	zoomDistance = math.min(MAX_ZOOM, zoomDistance + 0.5)
	updatePreviewCamera()
end)

NextButton.MouseButton1Click:Connect(function()
	scrollSlotsFrame(SCROLL_AMOUNT)
end)

PrevButton.MouseButton1Click:Connect(function()
	scrollSlotsFrame(-SCROLL_AMOUNT)
end)

ExitButton.MouseButton1Click:Connect(function()
    StatsFrame.Visible = not StatsFrame.Visible
    local showMain = not StatsFrame.Visible
	NextButton.Visible = showMain
	PrevButton.Visible = showMain
	SlotsFrame.Visible = showMain
end)

SaveButton.MouseButton1Click:Connect(function()
	
	SaveWardrobeRemote:FireServer(currentPlatformId, WardrobeData)
end)

OpenWardrobeUIRemote.OnClientEvent:Connect(function(platformId)

    currentPlatformId = platformId

    MenuGui.Visible = false
    WardrobeGui.Visible = true

	createMannequinPreview(platformId)
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

return WardrobeController