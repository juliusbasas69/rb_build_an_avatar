local ProximityPromptFactory = {}

function ProximityPromptFactory:Create(options)
	local prompt = Instance.new("ProximityPrompt")

	prompt.Name = "ProximityPrompt"
	prompt.ActionText = options.ActionText or "Interact"
	prompt.ObjectText = options.ObjectText or ""
	prompt.KeyboardKeyCode = Enum.KeyCode.E
	prompt.MaxActivationDistance = 10
	prompt.RequiresLineOfSight = false
	prompt.HoldDuration = 0
	prompt.ClickablePrompt = true
	prompt.UIOffset = Vector2.new(0, 25)
	prompt.Style = Enum.ProximityPromptStyle.Custom

	prompt.Parent = options.Parent

	return prompt
end

return ProximityPromptFactory