local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Remotes = require(ReplicatedStorage.Shared.Remotes)

local player = Players.LocalPlayer
local MainGui = player.PlayerGui:WaitForChild("MainGui")

local OpenSettingsUIRemote = ReplicatedStorage.Remotes:WaitForChild(Remotes.OpenSettingsUIRemote)
local MannequinSelectorUIRemote = ReplicatedStorage.Remotes:WaitForChild(Remotes.MannequinSelectorUIRemote)

OpenSettingsUIRemote.OnClientEvent:Connect(function()
	MainGui.Menu.Visible = false
	MainGui.PortalSettings.Visible = true
end)

MannequinSelectorUIRemote.OnClientEvent:Connect(function()
	MainGui.Menu.Visible = false
	MainGui.MannequinSelector.Visible = true
end)