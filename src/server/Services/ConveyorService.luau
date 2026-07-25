local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local ItemDatabase = require(ReplicatedStorage.Shared.Modules.ItemDatabase)
local MutationDatabase = require(ReplicatedStorage.Shared.Modules.MutationDatabase)
local RarityDatabase = require(ReplicatedStorage.Shared.Modules.RarityDatabase)
local ConveyorLevelDatabase = require(ReplicatedStorage.Shared.Modules.ConveyorLevelDatabase)
local LuckMultiplierDatabase = require(ReplicatedStorage.Shared.Modules.LuckMultiplierDatabase)
local MutationLuckMultiplierDatabase = require(ReplicatedStorage.Shared.Modules.MutationLuckMultiplierDatabase)

local BaseMannequin = ReplicatedStorage.Models:WaitForChild("BaseMannequin")

local ItemsByRarity = {}
local CurrentMannequin = {}

for _, item in pairs(ItemDatabase) do
	ItemsByRarity[item.Rarity] = ItemsByRarity[item.Rarity] or {}
	table.insert(ItemsByRarity[item.Rarity], item)
end

local function moveModel(model, destination, speed, lookAt, destroyAfter)
	local rootPart = model:WaitForChild("HumanoidRootPart")

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

	if lookAt then
		local target = Vector3.new(
			lookAt.Position.X,
			rootPart.Position.Y,
			lookAt.Position.Z
		)

		rootPart.CFrame = CFrame.lookAt(rootPart.Position, target)
	end

	if destroyAfter and model.Parent then
		model:Destroy()
	end
end

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


local function displayItem(item, mutation, plot)

	local spawnPoint = plot.Conveyor.SpawnPoint.SpawnPoint
	local stopPoint = plot.Conveyor.StopPoint.StopPoint
	local destroyPoint = plot.Conveyor.DestroyPoint.DestroyPoint
	local SpawnButton = plot.SpawnButton.Part

	-- Remove previous mannequin
	if CurrentMannequin[plot] then
		moveModel(CurrentMannequin[plot], destroyPoint, 8)
		CurrentMannequin[plot]:Destroy()
		CurrentMannequin[plot] = nil
	end

	local mannequin = BaseMannequin:Clone()
	mannequin.Parent = plot
	mannequin:PivotTo(spawnPoint.CFrame)

	local humanoid = mannequin:WaitForChild("Humanoid")
	
	applyItem(humanoid, item)
	
	local head = mannequin:FindFirstChild("Head")

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

		costLabel.Text = "$" .. item.Price
		costLabel.TextColor3 = Color3.fromRGB(255, 223, 0)
	end

	CurrentMannequin[plot] = mannequin

	task.spawn(function()
		moveModel(mannequin, stopPoint, 16, SpawnButton)
	end)
end


local playerLuck = 50
local mutationLuck = 100


local ConveyorService = {}


function ConveyorService:GetLootTable(conveyorLevel)
	return ConveyorLevelDatabase[tonumber(conveyorLevel)]
end


function ConveyorService:ApplyLuck(rarity, weight, luck)

	local multiplier = LuckMultiplierDatabase[rarity] or 0

	return weight * (
		1 + ((luck - 1) / 100) * multiplier
	)

end

function ConveyorService:ApplyMutationLuck(mutation, chance, luck)

	local multiplier = MutationLuckMultiplierDatabase[mutation] or 0

	return chance * (
		1 + ((luck - 1) / 100) * multiplier
	)

end


function ConveyorService:RollRarity(conveyorLevel)

	local lootTable = self:GetLootTable(conveyorLevel)

	if not lootTable then
		warn("No loot table found for level:", conveyorLevel)
		return nil
	end

	local adjustedTable = {}
	local totalWeight = 0

	for rarity, weight in pairs(lootTable) do

		local adjustedWeight = self:ApplyLuck(
			rarity,
			weight,
			playerLuck
		)

		adjustedTable[rarity] = adjustedWeight
		totalWeight += adjustedWeight

	end

	local roll = Random.new():NextNumber(0, totalWeight)

	local current = 0

	for rarity, weight in pairs(adjustedTable) do

		current += weight

		if roll <= current then
			return rarity
		end
	end
end

function ConveyorService:GetItemsByRarity(rarity)
	return ItemsByRarity[rarity] or {}
end

function ConveyorService:RollMutation()
	local adjustedTable = {}
	local totalChance = 0


	for mutation, data in pairs(MutationDatabase) do

		local adjustedChance = self:ApplyMutationLuck(
			mutation,
			data.Chance,
			mutationLuck
		)

		adjustedTable[mutation] = adjustedChance
		totalChance += adjustedChance
	end


	local roll = Random.new():NextNumber(0, totalChance)

	local current = 0

	for mutation, chance in pairs(adjustedTable) do

		current += chance

		if roll <= current then
			return mutation
		end
	end
end



function ConveyorService:SpawnItem(player, plot)

	local conveyorLevel = plot:GetAttribute("ConveyorLevel")

	local rarity = self:RollRarity(conveyorLevel)
	local mutation = self:RollMutation()

	print("Rolled rarity:", rarity)
	print("Rolled mutation:", mutation)

	local itemPool = self:GetItemsByRarity(rarity)

	if #itemPool == 0 then
		warn("No items found for rarity:", rarity)
		return
	end

	local selectedItem = itemPool[Random.new():NextInteger(1, #itemPool)]

	print("Selected Item:", selectedItem.Name)

	displayItem(selectedItem, mutation, plot)

	return selectedItem, mutation
end

return ConveyorService