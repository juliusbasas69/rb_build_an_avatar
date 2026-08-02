local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerData = player:WaitForChild("PlayerData")

local GetMainGui = require(
	player:WaitForChild("PlayerScripts")
		:WaitForChild("Client")
		:WaitForChild("Shared")
		:WaitForChild("GetMainGui")
)

local MainGui = GetMainGui()

local suffixes = {
	"",
	"K",
	"M",
	"B",
	"T",
	"Qa",
	"Qi",
	"Sx",
	"Sp",
	"Oc",
	"No",
	"De",
}

local function formatMoney(amount)
	if amount < 1000 then
		return tostring(math.floor(amount))
	end

	local index = math.floor(math.log(amount, 1000))
	local value = amount / (1000 ^ index)

	-- Prevent 999.995M from becoming 1000.00M
	value = math.floor(value * 100) / 100

	return string.format("%.2f%s", value, suffixes[index + 1])
		:gsub("%.?0+([A-Za-z]+)$", "%1")
end

local function updateGold()

    local GoldLabel = MainGui.Menu:WaitForChild("GoldGui"):FindFirstChild("GoldLabel", true)

	local gold = playerData:GetAttribute("Gold")
	GoldLabel.Text = "$" .. formatMoney(gold)

    print(gold)
end

-- Initial update
updateGold()

-- Update whenever Gold changes
playerData:GetAttributeChangedSignal("Gold"):Connect(updateGold)