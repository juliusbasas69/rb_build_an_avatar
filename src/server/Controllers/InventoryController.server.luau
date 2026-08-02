local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Remotes = require(ReplicatedStorage.Shared.Remotes)

local PreviewCacheService = require(ServerScriptService.Server.Services.PreviewCacheService)

local GetPreviewAssetsRemote = ReplicatedStorage.Remotes.Functions:WaitForChild(Remotes.GetPreviewAssetsRemote)


GetPreviewAssetsRemote.OnServerInvoke = function(player, assetIds)

	print("Received batch request")

	local previews = {}

	for _, assetId in ipairs(assetIds) do

		print("Creating preview:", assetId)

		local preview = PreviewCacheService:GetPreview(assetId)

		print("Preview result:", preview)

		if preview then
			previews[assetId] = preview
		end
	end

	print("Returning previews:", previews)

	return previews
end