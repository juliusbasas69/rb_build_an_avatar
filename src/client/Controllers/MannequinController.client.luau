local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")


local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Tags = require(ReplicatedStorage.Shared.Tags)

local PlaceMannequinRemote = ReplicatedStorage.Remotes:WaitForChild(Remotes.PlaceMannequinRemote)

local mannequins = ReplicatedStorage:WaitForChild("Mannequins")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local mainGui = playerGui:WaitForChild("MainGui")

local template

for _, instance in ipairs(CollectionService:GetTagged(Tags.MannequinDisplay)) do
	if instance:IsDescendantOf(mainGui) then
		template = instance
		break
	end
end

assert(template, "No UI tagged with 'MannequinDisplay' found inside MainGui!")

for _, mannequin in ipairs(mannequins:GetChildren()) do
	local frame = template:Clone()
	CollectionService:RemoveTag(frame, Tags.MannequinDisplay)

	frame.Name = mannequin.Name
	frame.Visible = true
	frame.Parent = template.Parent
    frame:SetAttribute("MannequinId", mannequin.Name)

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

	local outerStroke = frame:WaitForChild("Outer")
	local innerStroke = frame:WaitForChild("Inner")
	local gradient = innerStroke:WaitForChild("UIGradient")

	local normalColor = outerStroke.Color
	local hoverColor = Color3.fromRGB(27, 254, 15)

	local tweenInfo = TweenInfo.new(
		0.15,
		Enum.EasingStyle.Quad,
		Enum.EasingDirection.Out
	)

	local colorValue = Instance.new("Color3Value")
	colorValue.Value = normalColor

	colorValue:GetPropertyChangedSignal("Value"):Connect(function()
		gradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, colorValue.Value),
			ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1))
		})
	end)

	frame.MouseEnter:Connect(function()
		TweenService:Create(outerStroke, tweenInfo, {
			Color = hoverColor
		}):Play()

		TweenService:Create(colorValue, tweenInfo, {
			Value = hoverColor
		}):Play()
	end)

	frame.MouseLeave:Connect(function()
		TweenService:Create(outerStroke, tweenInfo, {
			Color = normalColor
		}):Play()

		TweenService:Create(colorValue, tweenInfo, {
			Value = normalColor
		}):Play()
	end)

    frame.MouseButton1Click:Connect(function()

        PlaceMannequinRemote:FireServer(frame.Name)

    end)
end

template:Destroy()