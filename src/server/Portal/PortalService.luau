local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local CollectionService = game:GetService("CollectionService")

local TweenService = game:GetService("TweenService")

local BaseMannequin = ReplicatedStorage:WaitForChild("BaseMannequin")

local Tags = require(ReplicatedStorage.Shared.Tags)
local ProximityPromptFactory = require(ServerScriptService.Server.Shared.ProximityPromptFactory)
local AssetKey = require(ReplicatedStorage.Shared.Util.AssetKey)
local AssetRollService = require(ServerScriptService.Server.Asset.AssetRollService)
local MutationDatabase = require(ReplicatedStorage.Shared.Databases.MutationDatabase)
local GradeDatabase = require(ReplicatedStorage.Shared.Databases.GradeDatabase)

local Shoes = ReplicatedStorage:WaitForChild("Shoes")

--THIS IS GAMEPASS
local assetCount = 5
local speed = 8

local PortalService = {}

local function applyAsset(mannequin, asset)

	local accessoryType = asset.AccessoryType
	local assetId = asset.AssetId

	-- Custom bundled shoes
	if accessoryType == "Shoes" then

		local shoeFolder = Shoes:FindFirstChild(tostring(assetId))
		if not shoeFolder then
			warn("Shoes folder not found:", assetId)
			return
		end

		local left = shoeFolder:FindFirstChild("LeftShoeAccessory")
		if left then
			left:Clone().Parent = mannequin
		end

		local right = shoeFolder:FindFirstChild("RightShoeAccessory")
		if right then
			right:Clone().Parent = mannequin
		end

		return
	end

	local humanoid = mannequin:WaitForChild("Humanoid")
	local description = humanoid:GetAppliedDescription()

	description.HeadColor = BrickColor.White().Color
	description.LeftArmColor = BrickColor.White().Color
	description.RightArmColor = BrickColor.White().Color
	description.LeftLegColor = BrickColor.White().Color
	description.RightLegColor = BrickColor.White().Color
	description.TorsoColor = BrickColor.White().Color
	
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
			AssetId = tonumber(assetId),
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
		
		mannequin:SetAttribute("AssetKey", AssetKey:Create(asset.AssetId, grade, mutation))

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
		
		info.Enabled = true
	end
end

local function moveMannequin(plot, mannequin, index)
	
	local portal = plot:FindFirstChild("Portal")
	local stopPoints = portal:FindFirstChild("StopPoints")

	local stopPoint

	if assetCount == 1 then
		stopPoint = stopPoints:FindFirstChild("3")
	elseif assetCount == 3 then
		stopPoint = stopPoints:FindFirstChild(tostring(5 - index))
	elseif assetCount == 5 then
		stopPoint = stopPoints:FindFirstChild(tostring(6 - index))
	end

	local rootPart = mannequin:WaitForChild("HumanoidRootPart")
	local destination = stopPoint

	local distance = (rootPart.Position - destination.Position).Magnitude

	local duration = distance / (speed * 1.5)

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
end

local function destroyMannequin(plot)

	local portal = plot:FindFirstChild("Portal")
	local destroyPoint = portal:FindFirstChild("DestroyPoint"):FindFirstChild("DestroyPoint")
	local portalMannequinsFolder = plot:FindFirstChild("PortalMannequins")

	if not portalMannequinsFolder then
		return
	end

	for _, mannequin in ipairs(portalMannequinsFolder:GetChildren()) do
		local rootPart = mannequin:WaitForChild("HumanoidRootPart")
		local destination = destroyPoint

		local distance = (rootPart.Position - destination.Position).Magnitude

		local duration = distance / (speed * 1.5)

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

		mannequin:Destroy()
	end
end

local function setupMannequin(plot, asset, grade, mutation, index)

	local portal = plot:FindFirstChild("Portal")
	local spawnPoint = portal:FindFirstChild("SpawnPoint"):FindFirstChild("SpawnPoint")
	local portalMannequinsFolder = plot:FindFirstChild("PortalMannequins")

	local clone = BaseMannequin:Clone()
	clone.Parent = portalMannequinsFolder
 	clone:PivotTo(spawnPoint.CFrame * CFrame.Angles(0, math.rad(180), 0))

	local prompt = ProximityPromptFactory:Create({
		Parent = clone:FindFirstChild("HumanoidRootPart"),
		ActionText = "Buy",
		ObjectText = asset.Name,
	})

	CollectionService:AddTag(prompt, Tags.BuyAssetPrompt)

	updateAssetInfo(clone, asset, grade, mutation)

	--task.spawn(function()
		applyAsset(clone, asset)
		moveMannequin(plot, clone, index)
	--end)

end

function PortalService:SpawnAsset(player, plot)

	destroyMannequin(plot)

	local portalLevel = plot:GetAttribute("PortalLevel")

	for index = 1, assetCount do

		local asset = AssetRollService:GetRandomAsset()
		local grade = AssetRollService:RollGrade(portalLevel)
		local mutation = AssetRollService:RollMutation()

		setupMannequin(plot, asset, grade, mutation, index)	
	end
end

return PortalService