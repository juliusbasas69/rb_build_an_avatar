local MutationDatabase = {
	Normal = {
		Chance = 95.00,
		IncomeMultiplier = 1.0,
		CostMultiplier = 1.0,
		Color = nil,
	},

	Golden = {
		Chance = 3.00,
		IncomeMultiplier = 2.0,
		CostMultiplier = 1.8,
		Color = Color3.fromRGB(255, 215, 0),
	},

	Shiny = {
		Chance = 1.20,
		IncomeMultiplier = 3.0,
		CostMultiplier = 2.8,
		Color = Color3.fromRGB(245, 245, 255),
	},

	Crystal = {
		Chance = 0.50,
		IncomeMultiplier = 5.0,
		CostMultiplier = 4.8,
		Color = Color3.fromRGB(0, 255, 255),
	},

	Shadow = {
		Chance = 0.20,
		IncomeMultiplier = 8.0,
		CostMultiplier = 8.0,
		Color = Color3.fromRGB(30, 30, 30),
	},

	Rainbow = {
		Chance = 0.07,
		IncomeMultiplier = 12.0,
		CostMultiplier = 13.0,
		Animated = true,
	},

	Galaxy = {
		Chance = 0.02,
		IncomeMultiplier = 20.0,
		CostMultiplier = 24.0,
		Effect = "Stars",
	},

	Cursed = {
		Chance = 0.01,
		IncomeMultiplier = 50.0,
		CostMultiplier = 70.0,
		Effect = "Cursed",
	},
}

return MutationDatabase