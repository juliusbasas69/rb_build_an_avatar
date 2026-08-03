local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local CollectionService = game:GetService("CollectionService")

local Assets = ReplicatedStorage:WaitForChild("Assets")

local TweenService = game:GetService("TweenService")

local BaseMannequin = ReplicatedStorage:WaitForChild("BaseMannequin")

local ProximityPromptFactory = require(ServerScriptService.Server.Shared.ProximityPromptFactory)

local AssetRollService = require(ServerScriptService.Server.Asset.AssetRollService)
local MutationDatabase = require(ReplicatedStorage.Shared.Databases.MutationDatabase)
local GradeDatabase = require(ReplicatedStorage.Shared.Databases.GradeDatabase)

local CurrentAssets = {}

--THIS IS GAMEPASS
local assetCount = 5
local speed = 8

local PortalService = {}

local function applyAsset(humanoid, asset)
	local description = humanoid:GetAppliedDescription()

	local accessoryType = asset.AccessoryType
	local assetId = asset.AssetId

	-- Layered Clothing
	if accessoryType == Enum.AccessoryType.Jacket
		or accessoryType == Enum.AccessoryType.Shirt
		or accessoryType == Enum.AccessoryType.Pants
		or accessoryType == Enum.AccessoryType.Sweater
		or accessoryType == Enum.AccessoryType.DressSkirt
		or accessoryType == Enum.AccessoryType.Shorts
		or accessoryType == Enum.AccessoryType.LeftShoe
		or accessoryType == Enum.AccessoryType.RightShoe
		or accessoryType == Enum.AccessoryType.TShirt
		or accessoryType == Enum.AccessoryType.Eyebrow
		or accessoryType == Enum.AccessoryType.Eyelash then

		local accessories = description:GetAccessories(true)

		table.insert(accessories, {
			AssetId = assetId,
			AccessoryType = accessoryType,
			IsLayered = true,
			Order = #accessories + 1
		})

		description:SetAccessories(accessories, true)

	-- Classic Accessories
	elseif accessoryType == Enum.AccessoryType.Hat then

		description.HatAccessory = description.HatAccessory .. "," .. assetId

	elseif accessoryType == Enum.AccessoryType.Hair then

		description.HairAccessory = description.HairAccessory .. "," .. assetId

	elseif accessoryType == Enum.AccessoryType.Face then

		description.FaceAccessory = description.FaceAccessory .. "," .. assetId

	elseif accessoryType == Enum.AccessoryType.Neck then

		description.NeckAccessory = description.NeckAccessory .. "," .. assetId

	elseif accessoryType == Enum.AccessoryType.Shoulder then

		description.ShoulderAccessory = description.ShoulderAccessory .. "," .. assetId

	elseif accessoryType == Enum.AccessoryType.Front then

		description.FrontAccessory = description.FrontAccessory .. "," .. assetId

	elseif accessoryType == Enum.AccessoryType.Back then

		description.BackAccessory = description.BackAccessory .. "," .. assetId

	elseif accessoryType == Enum.AccessoryType.Waist then

		description.WaistAccessory = description.WaistAccessory .. "," .. assetId
	end

	humanoid:ApplyDescription(description)
end


local function updateAssetInfo(mannequin, asset, grade, mutation)

	local head = mannequin:FindFirstChild("Head")

	if head then
		local info = head:WaitForChild("Info")

		local mutationLabel = info:WaitForChild("MutationLabel")
		local gradeLabel = info:WaitForChild("GradeLabel")
		local nameLabel = info:WaitForChild("NameLabel")
		local costLabel = info:WaitForChild("CostLabel")
	
		mannequin:SetAttribute("AssetId", asset.AssetId)
		mannequin:SetAttribute("Mutation", mutation)
		mannequin:SetAttribute("Grade", grade)

		mutationLabel.Text = mutation
		mutationLabel.TextColor3 = MutationDatabase[mutation].Color or Color3.new(1, 1, 1)
		CollectionService:AddTag(mutationLabel, mutation)

		CollectionService:AddTag(mutationLabel, mutation)

		gradeLabel.Text = grade
		gradeLabel.TextColor3 = GradeDatabase[grade].Color

		CollectionService:AddTag(gradeLabel, grade)

		nameLabel.Text = asset.Name
		nameLabel.TextColor3 = Color3.new(1, 1, 1)

		costLabel.Text = "$" .. math.floor(asset.Price * MutationDatabase[mutation].CostMultiplier)

		costLabel.TextColor3 =Color3.fromRGB(255, 223, 0)
	end
end

local function moveAssets(models)

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

			applyAsset(humanoid, data.Asset)

			task.wait(0.2)

			updateAssetInfo(
				mannequin,
				data.Asset,
				data.Grade,
				data.Mutation
			)

			local rootPart = mannequin:WaitForChild("HumanoidRootPart")
			local destination = data.StopPoint

			local distance = (rootPart.Position - destination.Position).Magnitude

			local duration = distance / speed

			local tween = TweenService:Create(
				rootPart,
				TweenInfo.new(
					duration,
					Enum.EasingStyle.Linear
				),
				{
					Position = destination.Position
				}
			)

			tween:Play()

			tween.Completed:Wait()

			for _, object in ipairs(mannequin:GetDescendants()) do
				if object:IsA("BasePart") then

					object.Anchored = true
					object.CanCollide = false
					object.CanTouch = false
					object.CanQuery = false

					object.CollisionGroup = "Mannequin"

				end
			end

			local prompt = ProximityPromptFactory:Create({
				Parent = rootPart,
				ActionText = "Buy",
				ObjectText = data.Asset.Name,
			})

			CollectionService:AddTag(
				prompt,
				"BuyAssetPrompt"
			)
			data.Model = mannequin
		end)
	end
end



local function destroyAssets(models, destroyPoint)

	for _, data in ipairs(models) do

		task.spawn(function()

			local mannequin = data.Model

			if not mannequin then
				return
			end

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
				TweenInfo.new(
					duration,
					Enum.EasingStyle.Linear
				),
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

local function displayAsset(asset, grade, mutation, plot, index)

	CurrentAssets[plot] = CurrentAssets[plot] or {}

	local stopPoints = plot.Portal.StopPoints:GetChildren()

	table.sort(
		stopPoints,
		function(a,b)
			return tonumber(a.Name) < tonumber(b.Name)
		end
	)

	local stopPoint

	if assetCount == 1 then
		stopPoint = stopPoints[3]

	elseif assetCount == 3 then
		stopPoint = stopPoints[5 - index]

	elseif assetCount == 5 then
		stopPoint = stopPoints[6 - index]

	end

	if not stopPoint then
		warn("No stop point found!")
		return
	end

	table.insert(
		CurrentAssets[plot],
		{
			Asset = asset,
			Grade = grade,
			Mutation = mutation,
			StopPoint = stopPoint,
			Plot = plot
		}
	)
end



function PortalService:SpawnAsset(player, plot)


	local destroyPoint = plot.Portal.DestroyPoint.DestroyPoint

	CurrentAssets[plot] = CurrentAssets[plot] or {}

	destroyAssets(CurrentAssets[plot], destroyPoint)

	table.clear(CurrentAssets[plot])

	local portalLevel = plot:GetAttribute("PortalLevel")

	for i = 1, assetCount do
		local selectedAsset = AssetRollService:GetRandomAsset()

		if not selectedAsset then
			continue
		end

		local grade = AssetRollService:RollGrade(portalLevel)

		local mutation = AssetRollService:RollMutation()

		displayAsset(
			selectedAsset,
			grade,
			mutation,
			plot,
			i
		)
	end

	moveAssets(CurrentAssets[plot])
end

return PortalService