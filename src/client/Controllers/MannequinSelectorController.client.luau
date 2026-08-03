local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Tags = require(ReplicatedStorage.Shared.Tags)

local PlaceMannequinRemote = ReplicatedStorage.Remotes:WaitForChild(Remotes.PlaceMannequinRemote)
local UpdateMannequinSelectorUIRemote = ReplicatedStorage.Remotes:WaitForChild(Remotes.UpdateMannequinSelectorUIRemote)

local mannequins = ReplicatedStorage:WaitForChild("Mannequins")

local player = Players.LocalPlayer
local GetMainGui = require(player:WaitForChild("PlayerScripts"):WaitForChild("Client"):WaitForChild("Shared"):WaitForChild("GetMainGui"))

local MainGui = GetMainGui()
local MannequinSelectorGui = MainGui.MannequinSelectorGui
local MenuGui = MainGui.Menu

local template
local hasMannequins = false

for _, instance in ipairs(CollectionService:GetTagged(Tags.MannequinDisplay)) do
	if instance:IsDescendantOf(MainGui) then
		template = instance
		break
	end
end

local function cloneFrame(ownedMannequin, mannequin)

	local frame = template:Clone()
	CollectionService:RemoveTag(frame, Tags.MannequinDisplay)

	frame.Name = ownedMannequin.Name
	frame.Visible = true
	frame.Parent = template.Parent
	frame:SetAttribute("MannequinId", ownedMannequin.Name)

	local quantityLabel = frame:WaitForChild("QuantityLabel")
	quantityLabel.Text = "x" .. ownedMannequin.Quantity.Value

	local viewport = frame:WaitForChild("ViewportFrame")

	local rig = mannequin:Clone()
	rig.Parent = viewport

	local camera = Instance.new("Camera")
	camera.Parent = viewport
	viewport.CurrentCamera = camera

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

	frame.MouseButton1Click:Connect(function()

		local platformId = MannequinSelectorGui:GetAttribute("PlatformId")

		PlaceMannequinRemote:FireServer(ownedMannequin.Name, platformId)
	end)
end

local function displayNoMannequins()
	local statusLabel = MannequinSelectorGui:FindFirstChild("StatusLabel", true)

	if not statusLabel then
		return
	end

	statusLabel.Text = "🛍️ Your mannequin collection is empty!"
	statusLabel.Visible = true

	statusLabel.BackgroundTransparency = 1
	statusLabel.Font = Enum.Font.LuckiestGuy
	statusLabel.TextScaled = true
	statusLabel.TextWrapped = true

	statusLabel.TextColor3 = Color3.fromHex("#B8860B")
	statusLabel.TextStrokeColor3 = Color3.fromHex("#FFFFFF")
	statusLabel.TextStrokeTransparency = 0.35
end

UpdateMannequinSelectorUIRemote.OnClientEvent:Connect(function(mannequinId)
	local ownedMannequins = player.PlayerData.OwnedMannequins

	local mannequinFolder = ownedMannequins:FindFirstChild(mannequinId)
	local frame = template.Parent:FindFirstChild(mannequinId)

	if not frame then
		return
	end

	if mannequinFolder then
		frame.QuantityLabel.Text = "x" .. mannequinFolder.Quantity.Value
	else
		frame:Destroy()

		if #ownedMannequins:GetChildren() == 0 then
			displayNoMannequins()
		end
	end

	MannequinSelectorGui.Visible = false
	MenuGui.Visible = true
end)

local function displayAllInitial()

	local ownedMannequins = player:WaitForChild("PlayerData"):WaitForChild("OwnedMannequins")

	for _, ownedMannequin in ipairs(ownedMannequins:GetChildren()) do

		local mannequin = mannequins:FindFirstChild(ownedMannequin.Name)

		if mannequin then
			print(mannequin)
			hasMannequins = true

			cloneFrame(ownedMannequin, mannequin)
		end
	end

	print(hasMannequins)
	if not hasMannequins then
		displayNoMannequins()
	end
	
	template:Destroy()

end

displayAllInitial()

