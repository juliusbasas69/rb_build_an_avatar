local ProximityPromptService = game:GetService("ProximityPromptService")
local TweenService = game:GetService("TweenService")

ProximityPromptService.PromptShown:Connect(function(promptInstance: ProximityPrompt)

    if promptInstance.Style == Enum.ProximityPromptStyle.Default then return end

	local CustomProximity = game.ReplicatedStorage:WaitForChild("CustomProximity"):Clone()

    local KeyText = CustomProximity:FindFirstChild("KeyText", true)
    local ObjectText = CustomProximity:FindFirstChild("ObjectText", true)
    local ActionText = CustomProximity:FindFirstChild("ActionText", true)
    local Progress = KeyText and KeyText:FindFirstChild("Progress", true)

	KeyText.Text = promptInstance.KeyboardKeyCode.Name
	ObjectText.Text = promptInstance.ObjectText
	ActionText.Text = promptInstance.ActionText
	CustomProximity.Adornee = promptInstance.Parent
    CustomProximity.Parent = promptInstance.Parent
	
	local currentTween

	local holdBeganConnection = promptInstance.PromptButtonHoldBegan:Connect(function()
		if Progress then
			Progress.Size = UDim2.new(0, 0, 0, 0)
			currentTween = TweenService:Create(Progress, TweenInfo.new(promptInstance.HoldDuration), {
				Size = UDim2.new(1, 0, 1, 0)
			})
			currentTween:Play()
		end
	end)

	local holdEndedConnection = promptInstance.PromptButtonHoldEnded:Connect(function()
		if currentTween then
			currentTween:Cancel()
		end
		if Progress then
			Progress.Size = UDim2.new(0, 0, 0, 0)
		end
	end)

	promptInstance.PromptHidden:Once(function()
		if CustomProximity then
			CustomProximity:Destroy()
		end
		if holdBeganConnection then holdBeganConnection:Disconnect() end
		if holdEndedConnection then holdEndedConnection:Disconnect() end
	end)

    local humanoidRootPart = promptInstance.Parent
	if not humanoidRootPart then
		return
	end

	local mannequin = humanoidRootPart:FindFirstAncestor("BaseMannequin")
	if not mannequin then
		return
	end

	local highlight = mannequin:FindFirstChild("Highlight")
	if not highlight then
		return
	end

	highlight.Enabled = true

	promptInstance.PromptHidden:Once(function()
		highlight.Enabled = false
	end)
end)