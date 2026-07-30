local CollectionService = game:GetService("CollectionService")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Shared.Remotes)
local MannequinDatabase = require(ReplicatedStorage.Shared.Databases.MannequinsDatabase)
local Tags = require(ReplicatedStorage.Shared.Tags)
local UserService = require(ServerScriptService.Server.Services.UserService)
local PlotService = require(ServerScriptService.Server.Services.PlotService)

local PlaceMannequinRemote = ReplicatedStorage.Remotes:WaitForChild(Remotes.PlaceMannequinRemote)
local UpdateMannequinSelectorUIRemote = ReplicatedStorage.Remotes:WaitForChild(Remotes.UpdateMannequinSelectorUIRemote)
local OpenMannequinSelectorUIRemote = ReplicatedStorage.Remotes:WaitForChild(Remotes.OpenMannequinSelectorUIRemote)

local function placeMannequin(plot, platformId, mannequinId)
	local platformsFolder = plot:WaitForChild("Platforms")
	local platformModel = platformsFolder:FindFirstChild(platformId)

    platformModel:FindFirstChild("HasMannequin", true).Value = true

	if not platformModel then
		warn("Platform P" .. platformId .. " not found.")
		return false
	end

	local spawnPart = platformModel:WaitForChild("Platform")

	local mannequin = ReplicatedStorage.Mannequins:FindFirstChild(mannequinId)

	if not mannequin then
		warn("Mannequin '" .. mannequinId .. "' does not exist.")
		return false
	end

	-- Remove existing mannequin if there is one
	local existing = platformModel:FindFirstChild("PlacedMannequin")
	if existing then
		existing:Destroy()
	end

	local clone = mannequin:Clone()
	clone.Name = "PlacedMannequin"
	clone.Parent = platformModel

	for _, obj in ipairs(clone:GetDescendants()) do
		if obj:IsA("BasePart") then
			obj.Anchored = true
			obj.CanCollide = false
			obj.CanTouch = false
			obj.CanQuery = false
		end
	end

	local humanoid = clone:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
		humanoid.AutoRotate = false
	end

	local offset = CFrame.new(0, 3, 0) * CFrame.Angles(0, math.rad(180), 0)
	clone:PivotTo(spawnPart.CFrame * offset)

	return true
end

-- Mannequin Platform Prompt

local function openMannequinSelector(player, platformId)

	OpenMannequinSelectorUIRemote:FireClient(player, platformId)
end

local function dressMannequin(player, prompt)
	print("Dress mannequin:", player.Name)
end

local function connectPlaceMannequinButton(platform)
	local clickDetector = platform.PlaceMannequin:FindFirstChild("ClickDetector", true)

	if not clickDetector then
		warn("ClickDetector not found for", platform:GetFullName())
		return
	end

	clickDetector.MouseClick:Connect(function(player)

        local hasMannequin = platform:FindFirstChild("HasMannequin", true).Value
	    local platformId = platform:FindFirstChild("PlatformId", true).Value

		openMannequinSelector(player, platformId)
	end)
end

for _, button in ipairs(CollectionService:GetTagged(Tags.PlaceMannequinButton)) do

    local platform = button.Parent

	connectPlaceMannequinButton(platform)
end

-- Connect future platforms
CollectionService:GetInstanceAddedSignal(Tags.PlaceMannequinButton):Connect(connectPlaceMannequinButton)

PlaceMannequinRemote.OnServerEvent:Connect(function(player, mannequinId, platformId)

    
    local mannequinInfo = MannequinDatabase[mannequinId]

    if not mannequinInfo then
        warn(player.Name .. " sent an invalid mannequin ID.")
        return
    end

    local playerData = UserService:GetUser(player)

    if not playerData.OwnedMannequins[mannequinId] then
        warn(player.Name .. " tried to place a mannequin they don't own.")
        return
    end

    local plot = PlotService:GetPlayerPlot(player)

    if not plot then
        warn("Could not find the plot of " .. player.Name)
        return 
    end

    if not placeMannequin(plot, platformId, mannequinId) then
		return
	end

    local ownedMannequin = playerData.OwnedMannequins[mannequinId]
    local ownedMannequinsFolder = player.PlayerData:WaitForChild("OwnedMannequins")
    local mannequinFolder = ownedMannequinsFolder:FindFirstChild(mannequinId)

    if ownedMannequin.Quantity > 1 then

        print("FVK")
        ownedMannequin.Quantity -= 1

        if mannequinFolder then
            mannequinFolder.Quantity.Value = ownedMannequin.Quantity
        end
    else
        playerData.OwnedMannequins[mannequinId] = nil

        if mannequinFolder then
            mannequinFolder:Destroy()
        end
    end

    UserService:UpdateUser(player)
    UpdateMannequinSelectorUIRemote:FireClient(player, mannequinId)
end)