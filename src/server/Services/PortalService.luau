local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local CollectionService = game:GetService("CollectionService")

local TweenService = game:GetService("TweenService")

local AssetRollService = require(ServerScriptService.Server.Services.AssetRollService)
local MutationDatabase = require(ReplicatedStorage.Shared.Databases.MutationDatabase)
local RarityDatabase = require(ReplicatedStorage.Shared.Databases.RarityDatabase)

local BaseMannequin = ReplicatedStorage.Models:WaitForChild("BaseMannequin")

local CurrentMannequin = {}

--THIS IS GAMEPASS
local mannequinCount = 5
local speed = 8

local PortalService = {}

local function applyAsset(humanoid, asset)
	local description = Instance.new("HumanoidDescription")

	local white = Color3.fromRGB(255, 255, 255)

	description.HeadColor = white
	description.TorsoColor = white
	description.LeftArmColor = white
	description.RightArmColor = white
	description.LeftLegColor = white
	description.RightLegColor = white

	if asset.Type == "Shirt" then
		description.Shirt = asset.AssetId

	elseif asset.Type == "Pants" then
		description.Pants = asset.AssetId

	elseif asset.Type == "Back" then
		description.BackAccessory = tostring(asset.AssetId)

	elseif asset.Type == "Hat" then
		description.HatAccessory = tostring(asset.AssetId)

	elseif asset.Type == "Hair" then
		description.HairAccessory = tostring(asset.AssetId)
	
	elseif asset.Type == "Face" then
		description.FaceAccessory = tostring(asset.AssetId)
	
	elseif asset.Type == "Head" then
		description.Head = tostring(asset.AssetId)	
	end
	

	local success, err = pcall(function()
		humanoid:ApplyDescription(description)

	end)

	if not success then
		warn("Failed applying item:", err)
	end
end

local function updateMannequinInfo(mannequin, asset, mutation)
	local head = mannequin:FindFirstChild("Head")

	if head then
		local info = head:WaitForChild("Info")

		local mutationLabel = info:WaitForChild("Mutation")
		local rarityLabel = info:WaitForChild("Rarity")
		local nameLabel = info:WaitForChild("Name")
		local costLabel = info:WaitForChild("Cost")
	
		mannequin:SetAttribute("AssetId", asset.AssetId)

		mutationLabel.Text = mutation
		mutationLabel.TextColor3 = MutationDatabase[mutation].Color or Color3.new(1, 1, 1)
		CollectionService:AddTag(mutationLabel, mutation)

		rarityLabel.Text = asset.Rarity
		rarityLabel.TextColor3 = RarityDatabase[asset.Rarity].Color
		CollectionService:AddTag(rarityLabel, asset.Rarity)

		nameLabel.Text = asset.Name
		nameLabel.TextColor3 = Color3.new(1, 1, 1)

		costLabel.Text = "$" .. math.floor(asset.Price * MutationDatabase[mutation].CostMultiplier)
		costLabel.TextColor3 = Color3.fromRGB(255, 223, 0)
	end
end

local function moveMannequin(models)

	for index, data in ipairs(models) do

		task.spawn(function()

			local spawnDelay = (speed >= 16) and 0.35 or 0.7

			task.wait((index - 1) * spawnDelay)

			local plot = data.Plot
			local spawnPoint = plot.Portal.SpawnPoint.SpawnPoint

			local mannequin = BaseMannequin:Clone()
			mannequin.Parent = plot
			mannequin:PivotTo(spawnPoint.CFrame * CFrame.Angles(0, math.rad(180), 0))

			local humanoid = mannequin:WaitForChild("Humanoid")

			-- Apply avatar first
			applyAsset(humanoid, data.Asset)

			-- Wait until Roblox finishes loading accessories/clothes
			task.wait(0.2)

			updateMannequinInfo(
				mannequin,
				data.Asset,
				data.Mutation
			)

			local rootPart = mannequin:WaitForChild("HumanoidRootPart")
			local destination = data.StopPoint


			local distance = (rootPart.Position - destination.Position).Magnitude
			local duration = distance / speed

			local tween = TweenService:Create(
				rootPart,
				TweenInfo.new(duration, Enum.EasingStyle.Linear),
				{
					Position = destination.Position
				}
			)

			tween:Play()

			tween.Completed:Wait()

			local prompt = Instance.new("ProximityPrompt")
			prompt.ActionText = "Buy"
			prompt.ObjectText = data.Asset.Name
			prompt.KeyboardKeyCode = Enum.KeyCode.E
			prompt.MaxActivationDistance = 10
			prompt.RequiresLineOfSight = false
			prompt.Parent = mannequin:WaitForChild("HumanoidRootPart")
			CollectionService:AddTag(prompt, "BuyAssetPrompt")

			data.Model = mannequin

		end)

	end

end

local function destroyMannequin(models, destroyPoint)

	for _, data in ipairs(models) do 

		task.spawn(function()

			local mannequin = data.Model

			task.wait(0.1)
			local rootPart = mannequin:WaitForChild("HumanoidRootPart")

			if not rootPart then
				warn("HumanoidRootPart missing:", mannequin:GetFullName())
				return
			end

			local distance = (rootPart.Position - destroyPoint.Position).Magnitude
			local duration = distance / speed

			local tween = TweenService:Create(
				rootPart,
				TweenInfo.new(duration, Enum.EasingStyle.Linear),
				{
					Position = destroyPoint.Position
				}
			)

			tween:Play()
			tween.Completed:Wait()

			if mannequin.Parent then
				mannequin:Destroy()
			end

		end)

	end

end

local function displayAsset(asset, mutation, plot, index)

	CurrentMannequin[plot] = CurrentMannequin[plot] or {}

	local stopPoints = plot.Portal.StopPoints:GetChildren()

	table.sort(stopPoints, function(a, b)
		return tonumber(a.Name) < tonumber(b.Name)
	end)

	local stopPoint

	if mannequinCount == 1 then
		-- Single mannequin goes to the middle
		stopPoint = stopPoints[3]

	elseif mannequinCount == 3 then
		-- 1st -> 4, 2nd -> 3, 3rd -> 2
		stopPoint = stopPoints[5 - index]

	elseif mannequinCount == 5 then
		-- 1st -> 5, 2nd -> 4, 3rd -> 3, 4th -> 2, 5th -> 1
		stopPoint = stopPoints[6 - index]
	end

	if not stopPoint then
		warn("No stop point found!")
		return
	end

	table.insert(CurrentMannequin[plot], {
		Asset = asset,
		Mutation = mutation,
		StopPoint = stopPoint,
		Plot = plot
	})

end

function PortalService:SpawnAsset(player, plot)

	local destroyPoint = plot.Portal.DestroyPoint.DestroyPoint

	CurrentMannequin[plot] = CurrentMannequin[plot] or {}

	destroyMannequin(CurrentMannequin[plot], destroyPoint)

	table.clear(CurrentMannequin[plot])

	local portalLevel = plot:GetAttribute("PortalLevel")

	for i = 1, mannequinCount do

		local rarity = AssetRollService:RollRarity(portalLevel)
		local mutation = AssetRollService:RollMutation()

		local assetPool = AssetRollService:GetAssetByRarity(rarity)

		local selectedAsset = assetPool[
			Random.new():NextInteger(1, #assetPool)
		]

		if not selectedAsset then
			continue
		end

		displayAsset(
			selectedAsset,
			mutation,
			plot,
			i
		)

	end

	-- MOVE ALL ONCE
	moveMannequin(CurrentMannequin[plot])

end

return PortalService