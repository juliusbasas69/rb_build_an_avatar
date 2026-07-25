local Players = game:GetService("Players")

local PlotService = require(script.Parent.Parent.Services.PlotService)

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		PlotService:AssignPlot(player)
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	PlotService:ReleasePlot(player)
end)