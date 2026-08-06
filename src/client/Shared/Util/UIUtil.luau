local UIUtil = {}

function UIUtil:DisplayNoInventory(statusLabel, textColor)
	statusLabel.Text = "🍃 Your inventory is empty!"
	statusLabel.Visible = true

	statusLabel.BackgroundTransparency = 1
	statusLabel.TextColor3 = textColor
	statusLabel.TextStrokeColor3 = Color3.fromHex("#FFFFFF")
	statusLabel.TextStrokeTransparency = 0.65
	statusLabel.Font = Enum.Font.LuckiestGuy
	statusLabel.TextSize = 22
	statusLabel.TextWrapped = true
end


return UIUtil