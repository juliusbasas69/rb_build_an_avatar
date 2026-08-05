local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer
local PlayerScripts = Player:WaitForChild("PlayerScripts")

local GuiUtil = require(PlayerScripts:WaitForChild("Client").Shared.Util.GuiUtil)

local MainGui = GuiUtil:GetMainGui()

local Tags = require(ReplicatedStorage.Shared.Tags)

local function ConnectMenuButton(menuButton)
	menuButton.MouseButton1Click:Connect(function()
		
		if menuButton.Name == "StatsButton" then
			MainGui.StatsGui.Visible = true
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