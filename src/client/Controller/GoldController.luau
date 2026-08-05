local Players = game:GetService("Players")

local Player = Players.LocalPlayer
local PlayerScripts = Player:WaitForChild("PlayerScripts")

local GuiUtil = require(PlayerScripts.Client.Shared.Util.GuiUtil)
local NumberUtil = require(PlayerScripts.Client.Shared.Util.NumberUtil)

local GoldController = {}

local GoldLabel

local function updateGold()
	local gold = Player:GetAttribute("Gold") or 0
	GoldLabel.Text = "$" .. NumberUtil.FormatMoney(gold)
end

function GoldController:Initialize()
	local MainGui = GuiUtil:GetMainGui()

	GoldLabel = MainGui.MenuGui.GoldGui:FindFirstChild("GoldLabel", true)

	updateGold()

	Player:GetAttributeChangedSignal("Gold"):Connect(updateGold)
end

return GoldController