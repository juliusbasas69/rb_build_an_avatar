local GradeDatabase = {
	Low = {
		Order = 1,
		Chance = 45.00,
		IncomeMultiplier = 0.5,
		CostMultiplier = 0.5,
		Color = Color3.fromRGB(120, 120, 120),
	},

	Average = {
		Order = 2,
		Chance = 30.00,
		IncomeMultiplier = 0.8,
		CostMultiplier = 0.8,
		Color = Color3.fromRGB(170, 170, 170),
	},

	Good = {
		Order = 3,
		Chance = 15.00,
		IncomeMultiplier = 1.0,
		CostMultiplier = 1.0,
		Color = Color3.fromRGB(85, 255, 85),
	},

	Excellent = {
		Order = 4,
		Chance = 6.00,
		IncomeMultiplier = 1.5,
		CostMultiplier = 1.5,
		Color = Color3.fromRGB(85, 170, 255),
	},

	Superior = {
		Order = 5,
		Chance = 2.50,
		IncomeMultiplier = 2.5,
		CostMultiplier = 2.5,
		Color = Color3.fromRGB(170, 85, 255),
	},

	Masterwork = {
		Order = 6,
		Chance = 1.00,
		IncomeMultiplier = 4.0,
		CostMultiplier = 4.0,
		Color = Color3.fromRGB(255, 170, 0),
	},

	Perfect = {
		Order = 7,
		Chance = 0.40,
		IncomeMultiplier = 6.0,
		CostMultiplier = 6.0,
		Color = Color3.fromRGB(255, 255, 85),
	},

	Pristine = {
		Order = 8,
		Chance = 0.10,
		IncomeMultiplier = 10.0,
		CostMultiplier = 10.0,
		Color = Color3.fromRGB(0, 255, 255),
	},
}

return GradeDatabase