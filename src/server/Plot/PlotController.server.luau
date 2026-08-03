local Players = game:GetService("Players")

local PlotService = require(script.Parent.Parent.Plot.PlotService)
local MannequinService = require(script.Parent.Parent.Mannequin.MannequinService)

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		local plot = PlotService:AssignPlot(player)
		
		if plot then
			MannequinService:LoadMannequins(player, plot)
		end
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	PlotService:ReleasePlot(player)
end)