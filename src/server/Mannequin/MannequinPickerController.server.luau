local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Tags = require(ReplicatedStorage.Shared.Tags)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Messages = require(ReplicatedStorage.Shared.Messages)

local OpenMannequinPickerUIRemote =ReplicatedStorage.Remotes:WaitForChild(Remotes.OpenMannequinPickerUIRemote)

local Remotes = require(ReplicatedStorage.Shared.Remotes)
local MannequinDatabase = require(ReplicatedStorage.Shared.Databases.MannequinDatabase)
local PlayerService = require(ServerScriptService.Server.Player.PlayerService)
local PlotService = require(ServerScriptService.Server.Plot.PlotService)
local MannequinService = require(ServerScriptService.Server.Mannequin.MannequinService)

local RequestPlaceMannequinRemote = ReplicatedStorage.Remotes:WaitForChild(Remotes.RequestPlaceMannequinRemote)
local UpdateMannequinPickerUIRemote = ReplicatedStorage.Remotes:WaitForChild(Remotes.UpdateMannequinPickerUIRemote)
local PopupUIRemote = ReplicatedStorage.Remotes:WaitForChild(Remotes.PopupUIRemote)

local function placeMannequin(plot, platformId, mannequinId) : boolean
	
	return MannequinService:PlaceMannequin(plot, platformId, mannequinId)
end

RequestPlaceMannequinRemote.OnServerEvent:Connect(function(player, mannequinId, platformId)

    local mannequinInfo = MannequinDatabase[mannequinId]

    if not mannequinInfo then
        warn(player.Name .. " sent an invalid mannequin ID.")
		PopupUIRemote:FireClient(player, Messages.ServerError)
        return
    end

    local playerData = PlayerService:GetPlayer(player)

    if not playerData.Inventory.Mannequins[mannequinId] then
        warn(player.Name .. " tried to place a mannequin they don't own.")
		PopupUIRemote:FireClient(player, Messages.ServerError)
        return
    end

    local plot = PlotService:GetPlayerPlot(player)

    if not plot then
        warn("Could not find the plot of " .. player.Name)
		PopupUIRemote:FireClient(player, Messages.ServerError)
        return 
    end

    if not placeMannequin(plot, platformId, mannequinId) then
		warn("Failed to place mannequin")
		PopupUIRemote:FireClient(player, Messages.ServerError)
		return
	end

	if not PlayerService:UpdatePlayerMannequins(player, platformId, mannequinId) then
		warn("Failed to update player mannequins")
		PopupUIRemote:FireClient(player, Messages.SaveDataFailed)
		return
	end

	UpdateMannequinPickerUIRemote:FireClient(player, mannequinId)
    PopupUIRemote:FireClient(player, Messages.MannequinPlaced)
end)

local connectedPrompts = {}

local function connectPrompt(prompt, callback)
	if connectedPrompts[prompt] then
		return
	end

	connectedPrompts[prompt] = true

	prompt.Triggered:Connect(function(player)
		callback(player)
	end)
end

local function connectMannequinSelectorPrompt(instance)
	local platform = instance.Parent.Parent

	if not platform then
		warn("Platform not found.")
		return
	end

	local stand = platform:FindFirstChild("Stand")

	if not stand then
		warn("Stand not found for", platform:GetFullName())
		return
	end

	local prompt = stand:FindFirstChild("ProximityPrompt")

	if not prompt then
		warn("ProximityPrompt not found for", platform:GetFullName())
		return
	end

	connectPrompt(prompt, function(player)
		local platformId = platform:GetAttribute("PlatformId")

		if not platformId then
			warn("PlatformId not found for", platform:GetFullName())
			return
		end

		OpenMannequinPickerUIRemote:FireClient(
			player,
			platformId
		)
	end)
end

for _, instance in ipairs(CollectionService:GetTagged(Tags.OpenMannequinPickerUITag)) do
	connectMannequinSelectorPrompt(instance)
end

CollectionService:GetInstanceAddedSignal(Tags.OpenMannequinPickerUITag):Connect(function(instance)
	connectMannequinSelectorPrompt(instance)
end)