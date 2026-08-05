local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerScripts = Player:WaitForChild("PlayerScripts")

local GuiUtil = require(PlayerScripts.Client.Shared.Util.GuiUtil)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local PopupUIRemote = ReplicatedStorage.Remotes:WaitForChild(Remotes.PopupUIRemote)
local PopupUIBindable = ReplicatedStorage.Remotes.BindableEvents:WaitForChild(Remotes.PopupUIBindable)

local MainGui = GuiUtil:GetMainGui()

local PopupFrame = MainGui:WaitForChild("Popup")
local Template = PopupFrame:WaitForChild("Template")

local PopupTime = 1

local sizeTween = {
	info = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
	props = {
		Size = UDim2.new(1, 0, .3, 0)
	}
}

local opacityInfo = {
	info = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
	props = {
		TextTransparency = 1,
		TextStrokeTransparency = 1,
	}
}

local ActivePopups = {}

local function ShowPopup(message)
	local key = message.Text

	local popup = ActivePopups[key]

	if popup then
		popup.Count += 1
		popup.Label.Text = string.format(
			"%s %s (x%d)",
			message.Icon or "",
			message.Text,
			popup.Count
		)
		popup.ExpireTime = tick() + PopupTime
		return
	end

	local newPopup = Template:Clone()

	newPopup.Text = string.format(
		"%s %s",
		message.Icon or "",
		message.Text
	)

	newPopup.TextColor3 = message.TextColor
	newPopup.TextStrokeColor3 = message.StrokeColor
	newPopup.TextStrokeTransparency = 0
	newPopup.TextTransparency = 0

	newPopup.Parent = PopupFrame

	ActivePopups[key] = {
		Label = newPopup,
		Count = 1,
		ExpireTime = tick() + PopupTime,
	}

	TweenService:Create(newPopup, sizeTween.info, sizeTween.props):Play()

	task.spawn(function()
		while tick() < ActivePopups[key].ExpireTime do
			task.wait(0.1)
		end

		local tween = TweenService:Create(
			newPopup,
			opacityInfo.info,
			opacityInfo.props
		)

		tween:Play()
		tween.Completed:Wait()

		ActivePopups[key] = nil
		newPopup:Destroy()
	end)
end

PopupUIRemote.OnClientEvent:Connect(ShowPopup)
PopupUIBindable.Event:Connect(ShowPopup)