local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local TweenService = game:GetService("TweenService")

local ItemRollService = require(ServerScriptService.Server.Services.ItemRollService)
local MutationDatabase = require(ReplicatedStorage.Shared.Modules.MutationDatabase)
local RarityDatabase = require(ReplicatedStorage.Shared.Modules.RarityDatabase)

local BaseMannequin = ReplicatedStorage.Models:WaitForChild("BaseMannequin")

local CurrentMannequin = {}

local multipleMannequin = false
local maxMannequins = 3
local speed = 16

local ConveyorService = {}

local function applyItem(humanoid, item)
	local description = Instance.new("HumanoidDescription")

	local white = Color3.fromRGB(255, 255, 255)

	description.HeadColor = white
	description.TorsoColor = white
	description.LeftArmColor = white
	description.RightArmColor = white
	description.LeftLegColor = white
	description.RightLegColor = white

	if item.Type == "Shirt" then
		description.Shirt = item.AssetId

	elseif item.Type == "Pants" then
		description.Pants = item.AssetId

	elseif item.Type == "BackAccessory" then
		description.BackAccessory = tostring(item.AssetId)

	elseif item.Type == "HatAccessory" then
		description.HatAccessory = tostring(item.AssetId)

	elseif item.Type == "HairAccessory" then
		description.HairAccessory = tostring(item.AssetId)
	end

	humanoid:ApplyDescription(description)
end

local function updateMannequinInfo(mannequin, item, mutation)
	local head = mannequin:FindFirstChild("Head")

	if head then
		local info = head:WaitForChild("Info")

		local mutationLabel = info:WaitForChild("Mutation")
		local rarityLabel = info:WaitForChild("Rarity")
		local nameLabel = info:WaitForChild("Name")
		local costLabel = info:WaitForChild("Cost")

		mutationLabel.Text = mutation
		mutationLabel.TextColor3 = MutationDatabase[mutation].Color or Color3.new(1, 1, 1)

		rarityLabel.Text = item.Rarity
		rarityLabel.TextColor3 = RarityDatabase[item.Rarity].Color

		nameLabel.Text = item.Name
		nameLabel.TextColor3 = Color3.new(1, 1, 1)

		costLabel.Text = "$" .. math.floor(item.Price * MutationDatabase[mutation].CostMultiplier)
		costLabel.TextColor3 = Color3.fromRGB(255, 223, 0)
	end
end

local function moveMannequin(models, lookAt)

	for index, data in ipairs(models) do

		task.spawn(function()

			-- stagger spawn
			task.wait((index - 1) * 0.5)

			local plot = data.Plot
			local spawnPoint = plot.Conveyor.SpawnPoint.SpawnPoint

			local mannequin = BaseMannequin:Clone()
			mannequin.Parent = plot
			mannequin:PivotTo(spawnPoint.CFrame)

			local humanoid = mannequin:WaitForChild("Humanoid")

			applyItem(humanoid, data.Item)
			updateMannequinInfo(mannequin, data.Item, data.Mutation)

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

			if lookAt and mannequin.Parent then

				local target = Vector3.new(
					lookAt.Position.X,
					rootPart.Position.Y,
					lookAt.Position.Z
				)

				rootPart.CFrame = CFrame.lookAt(rootPart.Position, target)
			end

			data.Model = mannequin

		end)

	end

end


local function destroyMannequin(models, destroyPoint)

	for _, data in ipairs(models) do 

		task.spawn(function()

			local mannequin = data.Model

			local rootPart = mannequin:WaitForChild("HumanoidRootPart")

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




local function displayItem(item, mutation, plot, index)

	CurrentMannequin[plot] = CurrentMannequin[plot] or {}

	local stopPoints = plot.Conveyor.StopPoints:GetChildren()

	table.sort(stopPoints, function(a, b)
		return tonumber(a.Name) < tonumber(b.Name)
	end)

	local stopPoint

	if multipleMannequin then
		-- 1st mannequin -> 3rd stop
		-- 2nd mannequin -> 2nd stop
		-- 3rd mannequin -> 1st stop
		stopPoint = stopPoints[maxMannequins - index + 1]
	else
		-- Single mannequin goes middle
		stopPoint = stopPoints[2]
	end

	if not stopPoint then
		warn("No stop point found!")
		return
	end

	table.insert(CurrentMannequin[plot], {
		Item = item,
		Mutation = mutation,
		StopPoint = stopPoint,
		Plot = plot
	})

end





function ConveyorService:SpawnItem(player, plot)

	local destroyPoint = plot.Conveyor.DestroyPoint.DestroyPoint

	

	CurrentMannequin[plot] = CurrentMannequin[plot] or {}

	destroyMannequin(CurrentMannequin[plot], destroyPoint)

	table.clear(CurrentMannequin[plot])


	local conveyorLevel = plot:GetAttribute("ConveyorLevel")

	local spawnCount = multipleMannequin and maxMannequins or 1

	local spawnedMannequins = {}

	for i = 1, spawnCount do

		local rarity = ItemRollService:RollRarity(conveyorLevel)
		local mutation = ItemRollService:RollMutation()

		local itemPool = ItemRollService:GetItemsByRarity(rarity)

		local selectedItem = itemPool[
			Random.new():NextInteger(1, #itemPool)
		]

		displayItem(
			selectedItem,
			mutation,
			plot,
			i
		)

	end

	-- MOVE ALL ONCE
	moveMannequin(CurrentMannequin[plot], plot.SpawnButton.Part)

end

return ConveyorService