local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")
local MainGui = PlayerGui:WaitForChild("MainGui")

local Tags = require(ReplicatedStorage.Shared.Tags)

local function ConnectMenuButton(menuButton)
	menuButton.MouseButton1Click:Connect(function()
		
		if menuButton.Name == "StatsButton" then
			MainGui.Stats.Visible = true
		end
		
		menuButton.Parent.Parent.Visible = not menuButton.Parent.Parent.Visible

	end)
end

for _, menuButton in CollectionService:GetTagged(Tags.MenuButton) do
	ConnectMenuButton(menuButton)
end

CollectionService:GetInstanceAddedSignal(Tags.MenuButton):Connect(ConnectMenuButton)