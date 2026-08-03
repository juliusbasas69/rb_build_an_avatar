local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Remotes = require(ReplicatedStorage.Shared.Remotes)

local player = Players.LocalPlayer
local GetMainGui = require(
	player:WaitForChild("PlayerScripts")
		:WaitForChild("Client")
		:WaitForChild("Shared")
		:WaitForChild("GetMainGui")
)

local MainGui = GetMainGui()

local OpenSettingsUIRemote = ReplicatedStorage.Remotes:WaitForChild(Remotes.OpenSettingsUIRemote)
local OpenMannequinSelectorUIRemote = ReplicatedStorage.Remotes:WaitForChild(Remotes.OpenMannequinSelectorUIRemote)
OpenSettingsUIRemote.OnClientEvent:Connect(function()
	MainGui.Menu.Visible = false
	MainGui.PortalSettings.Visible = true
end)

OpenMannequinSelectorUIRemote.OnClientEvent:Connect(function(platformId)
	MainGui.Menu.Visible = false
	MainGui.MannequinSelector.Visible = true

	MainGui.MannequinSelector:SetAttribute("PlatformId", platformId)
end)