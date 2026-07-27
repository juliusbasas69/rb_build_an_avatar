local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local CollectionService = game:GetService("CollectionService")

local TweenService = game:GetService("TweenService")

local ItemRollService = require(ServerScriptService.Server.Services.ItemRollService)
local MutationDatabase = require(ReplicatedStorage.Shared.Modules.MutationDatabase)
local RarityDatabase = require(ReplicatedStorage.Shared.Modules.RarityDatabase)

local BaseMannequin = ReplicatedStorage.Models:WaitForChild("BaseMannequin")

local CurrentMannequin = {}

--THIS IS GAMEPASS
local mannequinCount = 1
local speed = 8

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

	elseif item.Type == "Back" then
		description.BackAccessory = tostring(item.AssetId)

	elseif item.Type == "Hat" then
		description.HatAccessory = tostring(item.AssetId)

	elseif item.Type == "Hair" then
		description.HairAccessory = tostring(item.AssetId)
	
	elseif item.Type == "Face" then
		description.FaceAccessory = tostring(item.AssetId)
	
	elseif item.Type == "Head" then
		description.Head = tostring(item.AssetId)	
	end
	

	local success, err = pcall(function()
		humanoid:ApplyDescription(description)

	end)

	if not success then
		warn("Failed applying item:", err)
	end
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
		CollectionService:AddTag(mutationLabel, mutation)

		rarityLabel.Text = item.Rarity
		rarityLabel.TextColor3 = RarityDatabase[item.Rarity].Color
		CollectionService:AddTag(rarityLabel, item.Rarity)

		nameLabel.Text = item.Name
		nameLabel.TextColor3 = Color3.new(1, 1, 1)

		costLabel.Text = "$" .. math.floor(item.Price * MutationDatabase[mutation].CostMultiplier)
		costLabel.TextColor3 = Color3.fromRGB(255, 223, 0)
	end
end

local function moveMannequin(models, lookAt)

	for index, data in ipairs(models) do

		task.spawn(function()

			local spawnDelay = (speed >= 16) and 0.35 or 0.7

			task.wait((index - 1) * spawnDelay)

			local plot = data.Plot
			local spawnPoint = plot.Conveyor.SpawnPoint.SpawnPoint

			local mannequin = BaseMannequin:Clone()
			mannequin.Parent = plot
			mannequin:PivotTo(spawnPoint.CFrame)

			local humanoid = mannequin:WaitForChild("Humanoid")

			-- Apply avatar first
			applyItem(humanoid, data.Item)

			-- Wait until Roblox finishes loading accessories/clothes
			task.wait(0.2)

			updateMannequinInfo(
				mannequin,
				data.Item,
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
			prompt.ObjectText = data.Item.Name
			prompt.KeyboardKeyCode = Enum.KeyCode.E
			prompt.MaxActivationDistance = 10
			prompt.RequiresLineOfSight = false
			prompt.Parent = mannequin:WaitForChild("HumanoidRootPart")
			prompt.HoldDuration = 2
			CollectionService:AddTag(prompt, "BuyItemPrompt")


			if lookAt and mannequin.Parent then

				local target = Vector3.new(
					lookAt.Position.X,
					rootPart.Position.Y,
					lookAt.Position.Z
				)

				rootPart.CFrame = CFrame.lookAt(
					rootPart.Position,
					target
				)
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

	for i = 1, mannequinCount do

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