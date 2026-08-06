local MutationDatabase = {
	Normal = {
		Order = 1,
		Chance = 95.00,
		IncomeMultiplier = 1.0,
		CostMultiplier = 1.0,
		Color = nil,
	},

	Premium = {
		Order = 2,
		Chance = 3.00,
		IncomeMultiplier = 2.0,
		CostMultiplier = 1.8,
		Color = Color3.fromRGB(85, 255, 85), -- Green
	},

	Luxury = {
		Order = 3,
		Chance = 1.20,
		IncomeMultiplier = 3.0,
		CostMultiplier = 2.8,
		Color = Color3.fromRGB(85, 170, 255), -- Blue
	},

	Designer = {
		Order = 4,
		Chance = 0.50,
		IncomeMultiplier = 5.0,
		CostMultiplier = 4.8,
		Color = Color3.fromRGB(170, 85, 255), -- Purple
	},

	Limited = {
		Order = 5,
		Chance = 0.20,
		IncomeMultiplier = 8.0,
		CostMultiplier = 8.0,
		Color = Color3.fromRGB(255, 170, 0), -- Orange
	},

	Collectors = {
		Order = 6,
		Chance = 0.07,
		IncomeMultiplier = 12.0,
		CostMultiplier = 13.0,
		Color = Color3.fromRGB(255, 255, 85), -- Gold
	},

	Runway = {
		Order = 7,
		Chance = 0.02,
		IncomeMultiplier = 20.0,
		CostMultiplier = 24.0,
		Color = Color3.fromRGB(0, 255, 255), -- Cyan
		Animated = true,
	},

	Iconic = {
		Order = 8,
		Chance = 0.01,
		IncomeMultiplier = 50.0,
		CostMultiplier = 70.0,
		Color = Color3.fromRGB(255, 80, 180), -- Pink
		Animated = true,
		Effect = "Aura",
	},
}

return MutationDatabase