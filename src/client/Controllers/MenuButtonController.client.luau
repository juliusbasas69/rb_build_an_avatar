local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local GetMainGui = require(
	player:WaitForChild("PlayerScripts")
		:WaitForChild("Client")
		:WaitForChild("Shared")
		:WaitForChild("GetMainGui")
)

local MainGui = GetMainGui()

local Tags = require(ReplicatedStorage.Shared.Tags)

local function ConnectMenuButton(menuButton)
	menuButton.MouseButton1Click:Connect(function()
		
		if menuButton.Name == "StatsButton" then
			MainGui.Stats.Visible = true
		elseif menuButton.Name == "ItemsButton" then
			MainGui.InventoryGui.Visible = true
		end
		
		menuButton.Parent.Visible = false

	end)
end

for _, menuButton in CollectionService:GetTagged(Tags.MenuButton) do
	ConnectMenuButton(menuButton)
end

CollectionService:GetInstanceAddedSignal(Tags.MenuButton):Connect(ConnectMenuButton)