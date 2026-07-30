local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")


local Tags = require(ReplicatedStorage.Shared.Tags)

local function ConnectExitButton(exitButton)
	exitButton.MouseButton1Click:Connect(function()

        local Player = Players.LocalPlayer
        local PlayerGui = Player:WaitForChild("PlayerGui")
        local MainGui = PlayerGui:WaitForChild("MainGui")

		exitButton.Parent.Parent.Visible = false
		
		MainGui.Menu.Visible = true
	end)
end

for _, exitButton in CollectionService:GetTagged(Tags.ExitButton) do
	ConnectExitButton(exitButton)
end

CollectionService:GetInstanceAddedSignal(Tags.ExitButton):Connect(ConnectExitButton)