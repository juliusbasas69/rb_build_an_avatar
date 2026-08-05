local Players = game:GetService("Players")

local plots = workspace.Plots:GetChildren()

local availablePlots = {}

local PlayerPlots = {}

local function refreshAvailable()
	
	table.clear(availablePlots)
	
	for _, plot in pairs(plots) do
		if not plot:GetAttribute("Occupied") then
			table.insert(availablePlots, plot)
		end
	end
end

local function updateStatue(player, plot)
	
	local ownerStand = plot:FindFirstChild("OwnerStand")
	if not ownerStand then
		return
	end

	local spawnStatue = ownerStand:FindFirstChild("SpawnStatue")
	if not spawnStatue then
		warn("SpawnStatue not found!")
		return
	end

	local character = player.Character or player.CharacterAdded:Wait()

	character.Archivable = true
	local clone = character:Clone()
	character.Archivable = false

	clone.Name = "Statue"
	clone.Parent = ownerStand
	

	-- Freeze the statue
	for _, obj in ipairs(clone:GetDescendants()) do
		if obj:IsA("BasePart") then
			obj.Anchored = true
			obj.CanCollide = false
			obj.CanTouch = false
			obj.CanQuery = false
		end
	end

	-- Hide name and health bar
	local humanoid = clone:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
		humanoid.AutoRotate = false
	end

	local offset = CFrame.new(0, 2.5, 0) * CFrame.Angles(0, math.rad(90), 0)
	clone:PivotTo(spawnStatue.CFrame * offset)
	
	local head = clone:FindFirstChild("Head")
	if head then
		local billboard = Instance.new("BillboardGui")
		billboard.Name = "OwnerBillboard"
		billboard.Adornee = head
		billboard.Parent = head
		billboard.Size = UDim2.fromScale(10, 5)
		billboard.StudsOffset = Vector3.new(0, 4, 0)
		billboard.AlwaysOnTop = true
		billboard.MaxDistance = 80

		local textLabel = Instance.new("TextLabel")
		textLabel.Parent = billboard
		textLabel.Size = UDim2.fromScale(1, 1)
		textLabel.BackgroundTransparency = 1
		textLabel.RichText = true
		textLabel.TextScaled = true
		textLabel.TextWrapped = true
		textLabel.FontFace = Font.new("rbxassetid://16658221428") -- Fredoka One

		textLabel.Text = string.format(
			"<font color='#FFD700'><b>👑 OWNER</b></font>\n<font color='#FFFFFF'><b>%s</b></font>",
			player.DisplayName
		)

		textLabel.TextStrokeTransparency = 0
		textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	end
end

local PlotService = {}

function PlotService:AssignPlot(player)
	refreshAvailable()

	if #availablePlots == 0 then
		return nil
	end

	local plot = availablePlots[math.random(1, #availablePlots)]

	plot:SetAttribute("OwnerId", player.UserId)
	plot:SetAttribute("PortalLevel", 1)
	plot:SetAttribute("PortalSpeed", 8)

	plot.Name = player.UserId

	-- Cache the player's plot
	PlayerPlots[player] = plot

	updateStatue(player, plot)

	local spawn = plot:FindFirstChild("Spawn")

	player.RespawnLocation = spawn

	local character = player.Character or player.CharacterAdded:Wait()
	character:PivotTo(spawn.CFrame + Vector3.new(0, 3, 0))

	return plot
end

function PlotService:ReleasePlot(player)
	local plot = PlayerPlots[player]

	if not plot then
		return
	end

	plot:SetAttribute("OwnerId", nil)
	plot:SetAttribute("PortalLevel", 1)
	plot:SetAttribute("PortalSpeed", 8)

	plot.Name = "Plot"

	-- Remove statue
	local ownerStand = plot:FindFirstChild("OwnerStand")
	if ownerStand then
		local statue = ownerStand:FindFirstChild("Statue")
		if statue then
			statue:Destroy()
		end
	end

	player.RespawnLocation = nil

	PlayerPlots[player] = nil

	refreshAvailable()
end

function PlotService:GetPlayerPlot(player)
	return PlayerPlots[player]
end

Players.PlayerRemoving:Connect(function(player)
	PlotService:ReleasePlot(player)
end)

return PlotService