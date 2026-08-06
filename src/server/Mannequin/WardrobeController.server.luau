local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptServie = game:GetService("ServerScriptService")

local Tags = require(ReplicatedStorage.Shared.Tags)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local TableClone = require(ReplicatedStorage.Shared.Util.TableClone)

local PlayerService = require(ServerScriptServie.Server.Player.PlayerService)

local OpenWardrobeUIRemote = ReplicatedStorage.Remotes:WaitForChild(Remotes.OpenWardrobeUIRemote)

local connectedPrompts = {}

local SaveWardrobeRemote  = ReplicatedStorage.Remotes:WaitForChild(Remotes.SaveWardrobeRemote)

local function validateWardrobeData(playerData, wardrobeData): boolean

	for _, assetKey in pairs(wardrobeData) do

		if assetKey ~= "" then
			if not playerData.Inventory.Assets[assetKey] then
				warn(("Invalid asset key: %s"):format(assetKey))
				return false
			end
		end
	end

	return true
end

SaveWardrobeRemote.OnServerEvent:Connect(function(player, platformId, wardrobeData)

    local playerData = PlayerService:GetPlayer(player)

    if not playerData then
        warn("Player not found")
        return
    end

    if not validateWardrobeData(playerData, wardrobeData) then
        warn("Not Validated")
        return
    end

    playerData.Platforms[platformId].PlacedMannequin.Outfit = TableClone:Shallow(wardrobeData)

    PlayerService:UpdatePlayer(player)


end)

local function connectPrompt(prompt, callback)
	if connectedPrompts[prompt] then
		return
	end

	connectedPrompts[prompt] = true

	prompt.Triggered:Connect(function(player)
		callback(player)
	end)
end

local function connectWardrobePrompt(instance)
	local platform = instance.Parent.Parent.Parent
	
	if not platform then
		warn("Platform not found.")
		return
	end

	local stand = platform:FindFirstChild("Stand", true)

	if not stand then
		warn("Stand not found for", platform:GetFullName())
		return
	end

	connectPrompt(instance, function(player)
		local platformId = platform:GetAttribute("PlatformId")
		local mannequinId = platform:GetAttribute("MannequinId")

		if not platformId then
			warn("PlatformId not found for", platform:GetFullName())
			return
		end

		if not mannequinId then
			warn("MannequinId not found for", platform:GetFullName())
			return
		end

		OpenWardrobeUIRemote:FireClient(
			player,
			platformId
		)
	end)
end

for _, instance in ipairs(CollectionService:GetTagged(Tags.OpenWardrobeUITag)) do
	connectWardrobePrompt(instance)
end

CollectionService:GetInstanceAddedSignal(Tags.OpenWardrobeUITag):Connect(function(instance)
	connectWardrobePrompt(instance)
end)