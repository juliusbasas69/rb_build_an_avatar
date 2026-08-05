local ServerScriptService = game:GetService("ServerScriptService")

local PlayerService = require(ServerScriptService.Server.Player.PlayerService)
local PlotService = require(ServerScriptService.Server.Plot.PlotService)
local MannequinService = require(ServerScriptService.Server.Mannequin.MannequinService)

local Players = game:GetService("Players")

Players.PlayerAdded:Connect(function(player)

	player.CharacterAdded:Connect(function(character)
		
		local plot = PlotService:AssignPlot(player)
		
		if plot then
			MannequinService:LoadMannequins(player, plot)
		end

		for _, object in ipairs(character:GetDescendants()) do
			if object:IsA("BasePart") then
				object.CollisionGroup = "Players"
			end
		end
	end)

	local data = PlayerService:UserInitial(player)

	player:SetAttribute("Gold", data.Gold)
end)

Players.PlayerRemoving:Connect(function(player)
	PlayerService:PlayerRemoving(player)
	PlotService:ReleasePlot(player)
end)