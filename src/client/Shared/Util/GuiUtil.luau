local Players = game:GetService("Players")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local GuiUtil = {}

function GuiUtil:GetMainGui(): ScreenGui
	local gui = PlayerGui:FindFirstChild("MainGui", true)

	while not gui do
		PlayerGui.DescendantAdded:Wait()
		gui = PlayerGui:FindFirstChild("MainGui", true)
	end

	return gui
end

return GuiUtil