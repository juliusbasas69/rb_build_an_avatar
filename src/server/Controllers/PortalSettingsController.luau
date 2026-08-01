local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Tags = require(ReplicatedStorage.Shared.Tags)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local OpenSettingsUIRemote = ReplicatedStorage.Remotes:WaitForChild(Remotes.OpenSettingsUIRemote)

local function ConnectOpenSettingsButton(button)
	local clickDetector = button:WaitForChild("ClickDetector")

	clickDetector.MouseClick:Connect(function(player)
		OpenSettingsUIRemote:FireClient(player)
	end)
end

for _, button in CollectionService:GetTagged(Tags.OpenPortalSettings) do
	ConnectOpenSettingsButton(button)
end

CollectionService:GetInstanceAddedSignal(Tags.OpenPortalSettings):Connect(ConnectOpenSettingsButton)