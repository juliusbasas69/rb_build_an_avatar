local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local InsertService = game:GetService("InsertService")

local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Tags = require(ReplicatedStorage.Shared.Tags)

local PreviewAssets = ReplicatedStorage.PreviewAssets

local RequestAsset3DPreviewRemote = ReplicatedStorage.Remotes.Functions:WaitForChild(Remotes.RequestAsset3DPreviewRemote)

local AssetService = require(ServerScriptService.Server.Asset.AssetService)

local connectedPrompts = {}
local cache = {}

local function connectPrompt(prompt, callback)
	if connectedPrompts[prompt] then
		return
	end

	connectedPrompts[prompt] = true

	prompt.Triggered:Connect(function(player)
		callback(player)
	end)
end

local function handleBuyAssetPrompt(prompt)
	connectPrompt(prompt, function(player)
		
		local accessory = prompt.Parent.Parent

		AssetService:BuyAsset(player, accessory)
	end)
end

for _, prompt in ipairs(CollectionService:GetTagged(Tags.BuyAssetPrompt)) do
	handleBuyAssetPrompt(prompt)
end

CollectionService:GetInstanceAddedSignal(Tags.BuyAssetPrompt):Connect(function(prompt)
	handleBuyAssetPrompt(prompt)
end)

RequestAsset3DPreviewRemote.OnServerInvoke = function(player, assetId)

	if cache[assetId] then
		return cache[assetId]:Clone()
	end

	local success, asset = pcall(function()
		return InsertService:LoadAsset(assetId)
	end)

	if not success then
		warn(asset)
		return nil
	end

	local accessory = asset:FindFirstChildWhichIsA("Accessory", true)

	if not accessory then
		warn("No accessory:", assetId)
		asset:Destroy()
		return nil
	end

	-- Clone for the cache
	local cachedAccessory = accessory:Clone()
	cachedAccessory.Name = tostring(assetId)
	cachedAccessory.Parent = PreviewAssets

	cache[assetId] = cachedAccessory

	--asset:Destroy()

	-- Return a separate clone
	return cachedAccessory:Clone()
end