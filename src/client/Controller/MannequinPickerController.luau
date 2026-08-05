local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerScripts = Player:WaitForChild("PlayerScripts")

local GuiUtil = require(PlayerScripts.Client.Shared.Util.GuiUtil)
local PlayerClientService = require(PlayerScripts.Client.Shared.Service.PlayerClientService)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local OpenMannequinPickerUIRemote = ReplicatedStorage.Remotes:WaitForChild(Remotes.OpenMannequinPickerUIRemote)
local RequestPlaceMannequinRemote = ReplicatedStorage.Remotes:WaitForChild(Remotes.RequestPlaceMannequinRemote)
local UpdateMannequinPickerUIRemote = ReplicatedStorage.Remotes:WaitForChild(Remotes.UpdateMannequinPickerUIRemote)

local Mannequins = ReplicatedStorage:WaitForChild("Mannequins")

local MainGui = GuiUtil:GetMainGui()
local MenuGui = MainGui:WaitForChild("MenuGui")
local MannequinPickerGui = MainGui:WaitForChild("MannequinPickerGui")
local MannequinPickerFrame = MannequinPickerGui:WaitForChild("MannequinPickerFrame")
local Template = MannequinPickerFrame:WaitForChild("ScrollingFrame"):WaitForChild("Template")
local StatusLabel = MannequinPickerFrame:WaitForChild("StatusLabel")

local currentPlatformId
local playerData

local MannequinPickerController = {}

local function createRotatingMannequinPreview(viewportFrame, mannequinId)

	local replicatedMannequin = ReplicatedStorage.Mannequins:FindFirstChild(mannequinId)

	if not replicatedMannequin then
		warn("No Mannequin with ID: ", mannequinId)
		return
	end

	local rig = replicatedMannequin:Clone()
	rig.Parent = viewportFrame

	local camera = Instance.new("Camera")
	camera.Parent = viewportFrame
	viewportFrame.CurrentCamera = camera

	local root = rig:WaitForChild("HumanoidRootPart")

	camera.CFrame = CFrame.new(
		root.Position + Vector3.new(0, -0.5, 6.5),
		root.Position + Vector3.new(0, -0.5, 0)
	)

	local startPivot = rig:GetPivot()
	local angle = 0

	RunService.RenderStepped:Connect(function(dt)
		angle += math.rad(40) * dt
		rig:PivotTo(startPivot * CFrame.Angles(0, angle, 0))
	end)
end

local function loadMannequinFrames(mannequins)

	for mannequinId, mannequinData in pairs(mannequins) do

		local frame = Template:Clone()

		frame.Name = mannequinId
		frame.Visible = true
		frame.Parent = Template.Parent
		frame:SetAttribute("MannequinId", mannequinId)

		local quantityLabel = frame:WaitForChild("QuantityLabel")

		if not quantityLabel then
			warn("No Quantity Label in MannequinPickerFrame")
			return
		end

		quantityLabel.Text = "x" .. mannequinData.Quantity

		local viewportFrame = frame:WaitForChild("ViewportFrame")

		if not viewportFrame then
			warn("No ViewportFrame in MannequinPickerFrame")
			return
		end

		createRotatingMannequinPreview(viewportFrame, mannequinId)

		frame.MouseButton1Click:Connect(function()

			print(currentPlatformId)

			RequestPlaceMannequinRemote:FireServer(mannequinId, currentPlatformId)
		end)


		--HIGHLIGHTED
		local outerStroke = frame:WaitForChild("UIStroke")
		local normalColor = outerStroke.Color
		local hoverColor = Color3.fromRGB(27, 254, 15)

		local tweenInfo = TweenInfo.new(
			0.15,
			Enum.EasingStyle.Quad,
			Enum.EasingDirection.Out
		)

		frame.MouseEnter:Connect(function()
			TweenService:Create(outerStroke, tweenInfo, {
				Color = hoverColor,
				Transparency = 0
			}):Play()
		end)

		frame.MouseLeave:Connect(function()
			TweenService:Create(outerStroke, tweenInfo, {
				Color = normalColor,
				Transparency = 1
			}):Play()
		end)
	end
end

local function displayEmptyMannequins()

	StatusLabel.Text = "🛍️ Your mannequin collection is empty!"
	StatusLabel.Visible = true

	StatusLabel.BackgroundTransparency = 1
	StatusLabel.Font = Enum.Font.LuckiestGuy
	StatusLabel.TextScaled = true
	StatusLabel.TextWrapped = true

	StatusLabel.TextColor3 = Color3.fromHex("#B8860B")
	StatusLabel.TextStrokeColor3 = Color3.fromHex("#FFFFFF")
	StatusLabel.TextStrokeTransparency = 0.35
end

local function loadInventoryMannequins()

	local inventory = playerData.Inventory
	local mannequins = inventory.Mannequins

    if not next(mannequins) then
        displayEmptyMannequins()
        return
    end

	loadMannequinFrames(mannequins)
end

function MannequinPickerController:Initialize()
    playerData = PlayerClientService:GetPlayerData()

    loadInventoryMannequins()
end

OpenMannequinPickerUIRemote.OnClientEvent:Connect(function(platformId)
	currentPlatformId = platformId

	MenuGui.Visible = false
	MannequinPickerGui.Visible = true
end)

UpdateMannequinPickerUIRemote.OnClientEvent:Connect(function(mannequinId)

	local frame = MannequinPickerFrame:FindFirstChild("ScrollingFrame"):FindFirstChild(mannequinId)

	if not frame then
		warn("No Frame to update in MannequinPicker")
		return
	end

	local inventory = playerData.Inventory
	local mannequins = inventory.Mannequins

    if not next(mannequins) then
        displayEmptyMannequins()
        return
    end

	local mannequin = Mannequins[mannequinId]

	if not mannequin then
		frame:Destroy()
		return
	end

	frame.QuantityLabel.Text = "x" .. mannequin.Quantity

	MannequinPickerGui.Visible = false
	MenuGui.Visible = true
end)

return MannequinPickerController 
