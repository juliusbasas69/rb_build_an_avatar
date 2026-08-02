local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local CollectionService = game:GetService("CollectionService")

local Assets = ReplicatedStorage:WaitForChild("Assets")

local TweenService = game:GetService("TweenService")

local ProximityPromptFactory = require(ServerScriptService.Server.Shared.ProximityPromptFactory)

local AssetRollService = require(ServerScriptService.Server.Services.AssetRollService)
local MutationDatabase = require(ReplicatedStorage.Shared.Databases.MutationDatabase)
local GradeDatabase = require(ReplicatedStorage.Shared.Databases.GradeDatabase)

local CurrentAssets = {}

--THIS IS GAMEPASS
local assetCount = 5
local speed = 8

local PortalService = {}


local function updateAssetInfo(handle, asset, grade, mutation)

	local info = handle:FindFirstChild("Info")

	if not info then
		warn("Info not found in Handle")
		return
	end

	local mutationLabel = info:WaitForChild("MutationLabel")
	local gradeLabel = info:WaitForChild("GradeLabel")
	local nameLabel = info:WaitForChild("NameLabel")
	local costLabel = info:WaitForChild("CostLabel")

	handle:SetAttribute("AssetId", asset.AssetId)
	handle:SetAttribute("Mutation", mutation)
	handle:SetAttribute("Grade", grade)

	mutationLabel.Text = mutation
	mutationLabel.TextColor3 = MutationDatabase[mutation].Color or Color3.new(1, 1, 1)

	CollectionService:AddTag(mutationLabel, mutation)

	gradeLabel.Text = grade
	gradeLabel.TextColor3 =
		GradeDatabase[grade].Color

	CollectionService:AddTag(gradeLabel, grade)

	nameLabel.Text = asset.Name
	nameLabel.TextColor3 = Color3.new(1, 1, 1)

	costLabel.Text = "$" .. math.floor(asset.Price * MutationDatabase[mutation].CostMultiplier)

	costLabel.TextColor3 =Color3.fromRGB(255, 223, 0)
end

local function moveAssets(models)

	for index, data in ipairs(models) do

		task.spawn(function()

			local spawnDelay = (speed >= 16) and 0.35 or 0.7

			task.wait((index - 1) * spawnDelay)

			local plot = data.Plot
			local spawnPoint = plot.Portal.SpawnPoint.SpawnPoint

			local accessory = Assets:FindFirstChild(tostring(data.Asset.AssetId))

			if not accessory then
				warn("Missing asset:", data.Asset.AssetId)
				return
			end

			local handle = accessory.Handle:Clone()

			handle.Parent = plot

			handle.CFrame =
				spawnPoint.CFrame *
				CFrame.Angles(0, math.rad(180), 0)


			handle.Anchored = true
			handle.CanCollide = false



			updateAssetInfo(
				handle,
				data.Asset,
				data.Grade,
				data.Mutation
			)



			local destination = data.StopPoint


			local distance =
				(handle.Position - destination.Position).Magnitude


			local duration =
				distance / speed



			local tween = TweenService:Create(
				handle,
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



			local prompt = ProximityPromptFactory:Create({
				Parent = handle,
				ActionText = "Buy",
				ObjectText = data.Asset.Name,
			})


			CollectionService:AddTag(
				prompt,
				"BuyAssetPrompt"
			)



			data.Model = handle


		end)

	end

end



local function destroyAssets(models, destroyPoint)

	for _, data in ipairs(models) do

		task.spawn(function()


			local handle = data.Model


			if not handle then
				return
			end



			local distance =
				(handle.Position - destroyPoint.Position).Magnitude


			local duration =
				distance / speed



			local tween = TweenService:Create(
				handle,
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



			if handle.Parent then
				handle:Destroy()
			end


		end)

	end

end



local function displayAsset(asset, grade, mutation, plot, index)


	CurrentAssets[plot] = CurrentAssets[plot] or {}


	local stopPoints =
		plot.Portal.StopPoints:GetChildren()



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


	local destroyPoint =
		plot.Portal.DestroyPoint.DestroyPoint



	CurrentAssets[plot] =
		CurrentAssets[plot] or {}



	destroyAssets(
		CurrentAssets[plot],
		destroyPoint
	)



	table.clear(
		CurrentAssets[plot]
	)



	local portalLevel =
		plot:GetAttribute("PortalLevel")



	for i = 1, assetCount do


		local selectedAsset =
			AssetRollService:GetRandomAsset()



		if not selectedAsset then
			continue
		end



		local grade =
			AssetRollService:RollGrade(
				portalLevel
			)



		local mutation =
			AssetRollService:RollMutation()



		displayAsset(
			selectedAsset,
			grade,
			mutation,
			plot,
			i
		)

	end



	moveAssets(
		CurrentAssets[plot]
	)

end



return PortalService