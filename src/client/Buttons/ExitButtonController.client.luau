local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerScripts = Player:WaitForChild("PlayerScripts")

local GuiUtil = require(PlayerScripts.Client.Shared.Util.GuiUtil)

local MainGui = GuiUtil:GetMainGui()
local MenuGui = MainGui:WaitForChild("MenuGui")

local Tags = require(ReplicatedStorage.Shared.Tags)

local function ConnectExitButton(exitButton)
	exitButton.MouseButton1Click:Connect(function()

		exitButton.Parent.Parent.Visible = false
		
		MenuGui.Visible = true
	end)
end

for _, exitButton in CollectionService:GetTagged(Tags.ExitButton) do
	ConnectExitButton(exitButton)
end

CollectionService:GetInstanceAddedSignal(Tags.ExitButton):Connect(ConnectExitButton)