local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")
local ServerScriptService = game:GetService("ServerScriptService")

local ConveyorService = require(ServerScriptService.Server.Services.ConveyorService)
local PlotService = require(ServerScriptService.Server.Services.PlotService)

local SpawnButtons = CollectionService:GetTagged("ConveyorSpawnButton")

local buttonDebounce = {}

local BUTTON_COOLDOWN = 1

local function pressButton(button)

	local originalCFrame = button.CFrame
	local pressedCFrame = originalCFrame * CFrame.new(0, -0.10, 0)

	local downTween = TweenService:Create(
		button,
		TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{CFrame = pressedCFrame}
	)

	local upTween = TweenService:Create(
		button,
		TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{CFrame = originalCFrame}
	)

	downTween:Play()
	downTween.Completed:Wait()

	-- Keep the button pressed during cooldown
	task.wait(BUTTON_COOLDOWN)

	upTween:Play()
	upTween.Completed:Wait()
end

for _, button in ipairs(SpawnButtons) do

	local clickDetector = button:FindFirstChild("ClickDetector")

	if clickDetector then
		clickDetector.MouseClick:Connect(function(player)

			if buttonDebounce[button] then
				return
			end

			buttonDebounce[button] = true

			local plot = PlotService:GetPlayerPlot(player)
			if plot then
				
				ConveyorService:SpawnItem(player, plot)
			end

			pressButton(button)

			buttonDebounce[button] = nil
		end)
	end
end