local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Remotes = require(ReplicatedStorage.Shared.Remotes)
local RarityDatabase = require(ReplicatedStorage.Shared.Databases.RarityDatabase)

local mannequinTemplate = ReplicatedStorage.Models:WaitForChild("Mannequin")

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

local NextButton = InventoryFrame:WaitForChild("NextButton")
local PrevButton = InventoryFrame:WaitForChild("PrevButton")
local StatusLabel = ListFrame:WaitForChild("StatusLabel")
local PageLabel = InventoryFrame:WaitForChild("PageLabel")
local MaximumLabel = InventoryFrame:WaitForChild("MaximumLabel")


--------------------------------------------------------
-- DATA
--------------------------------------------------------

local assets = {}
local inventoryFrames = {}

for _, assetData in pairs(PlayerData.Assets or {}) do
	table.insert(assets, assetData)
end



local PAGE_SIZE = 1
local currentPage = 1

local MAX_INVENTORY = 100

local function updateInventoryCount()
	MaximumLabel.Text = string.format("Capacity: %d/%d", #assets, MAX_INVENTORY)
end

local function getAssetKey(assetId, mutation)
	return tostring(assetId) .. "_" .. mutation
end

updateInventoryCount()

--------------------------------------------------------
-- CREATE PREVIEW
--------------------------------------------------------

local function createPreview(frame)

	local viewport = frame:WaitForChild("ViewportFrame")

	local assetId = frame:GetAttribute("AssetId")

	if not assetId then
		warn("Missing AssetId")
		return
	end


	viewport:ClearAllChildren()


	local camera = Instance.new("Camera")
	camera.Parent = viewport
	viewport.CurrentCamera = camera


	local mannequin = mannequinTemplate:Clone()
	mannequin.Parent = viewport


	local humanoid = mannequin:WaitForChild("Humanoid")


	local description = Instance.new("HumanoidDescription")

	local white = Color3.fromRGB(255,255,255)

	description.TorsoColor = white
	description.LeftArmColor = white
	description.RightArmColor = white

	description.Shirt = tonumber(assetId)


	local success, err = pcall(function()
		humanoid:ApplyDescriptionAsync(description)
	end)


	if not success then
		warn(err)
	end


	for _, obj in ipairs(mannequin:GetDescendants()) do
		if obj:IsA("BasePart") then
			obj.Anchored = true
		end
	end


	mannequin:PivotTo(
		mannequin:GetPivot()
			* CFrame.Angles(0, math.rad(180), 0)
	)


	task.wait(0.2)


	local torso = mannequin:FindFirstChild("Torso")

	if torso then
		camera.CFrame = CFrame.lookAt(
			torso.Position + Vector3.new(0,0,4.25),
			torso.Position
		)
	end
end

local function setPageButtonsEnabled(enabled)

	local totalPages = math.max(1, math.ceil(#assets / PAGE_SIZE))

    PageLabel.Text = string.format("%d / %d", currentPage, totalPages)

	PrevButton.Active = enabled and currentPage > 1
	PrevButton.AutoButtonColor = enabled and currentPage > 1

	NextButton.Active = enabled and currentPage < totalPages
	NextButton.AutoButtonColor = enabled and currentPage < totalPages
end


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
    local QuantityLabel = frame:WaitForChild("QuantityLabel")

    RarityLabel.Text = asset.Rarity
    RarityLabel.BackgroundColor3 = RarityDatabase[asset.Rarity].Color
    
    QuantityLabel.Text = "x" .. (asset.Quantity or 1)
    
	inventoryFrames[key] = frame

	task.spawn(function()

		createPreview(frame)

		frame.Visible = true
	end)

	return frame
end

--------------------------------------------------------
-- LOAD PAGE
--------------------------------------------------------

local function loadPage(page)

	currentPage = page

    setPageButtonsEnabled(false)

	StatusLabel.Text = "Loading..."
	StatusLabel.Visible = true

	table.clear(inventoryFrames)

	for _, child in ipairs(ListFrame:GetChildren()) do
		if child:IsA("ImageButton") 
			and child ~= template then

			child:Destroy()
		end
	end

	local startIndex = ((page - 1) * PAGE_SIZE) + 1

	local endIndex = math.min(
		startIndex + PAGE_SIZE - 1,
		#assets
	)

	if #assets == 0 then

        StatusLabel.Text = "No Items"
        StatusLabel.Visible = true

        setPageButtonsEnabled(false)

        return
    end

	for i = startIndex, endIndex do

		local asset = assets[i]

		print(
			"Creating:",
			asset.AssetId,
			asset.Name
		)

		createItemFrame(asset)
	end

	StatusLabel.Visible = false
    setPageButtonsEnabled(true)
end

--------------------------------------------------------
-- PAGE BUTTONS
--------------------------------------------------------

local function nextPage()

	local totalPages = math.ceil(#assets / PAGE_SIZE)

	if currentPage < totalPages then
		loadPage(currentPage + 1)
	end

end

local function previousPage()

	if currentPage > 1 then
		loadPage(currentPage - 1)
	end
end

--------------------------------------------------------
-- START
--------------------------------------------------------

template.Visible = false
StatusLabel.Visible = false

loadPage(1)

NextButton.MouseButton1Click:Connect(nextPage)

PrevButton.MouseButton1Click:Connect(previousPage)

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