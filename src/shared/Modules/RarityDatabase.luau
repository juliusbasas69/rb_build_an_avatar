local RarityDatabase = {
	Common = {
		Weight = 60,
		UnlockLevel = 1,
		UnlockCost = 0,
		Color = Color3.fromRGB(190, 190, 190), -- Gray
	},

	Uncommon = {
		Weight = 25,
		UnlockLevel = 2,
		UnlockCost = 5_000,
		Color = Color3.fromRGB(85, 255, 85), -- Green
	},

	Rare = {
		Weight = 10,
		UnlockLevel = 3,
		UnlockCost = 25_000,
		Color = Color3.fromRGB(85, 170, 255), -- Blue
	},

	Epic = {
		Weight = 4,
		UnlockLevel = 4,
		UnlockCost = 100_000,
		Color = Color3.fromRGB(170, 85, 255), -- Purple
	},

	Legendary = {
		Weight = 1,
		UnlockLevel = 5,
		UnlockCost = 500_000,
		Color = Color3.fromRGB(255, 170, 0), -- Orange
	},

	Mythic = {
		Weight = 0.5,
		UnlockLevel = 6,
		UnlockCost = 2_000_000,
		Color = Color3.fromRGB(255, 0, 85), -- Magenta
	},

	Divine = {
		Weight = 0.2,
		UnlockLevel = 7,
		UnlockCost = 10_000_000,
		Color = Color3.fromRGB(255, 255, 85), -- Gold
	},

	Celestial = {
		Weight = 0.05,
		UnlockLevel = 8,
		UnlockCost = 50_000_000,
		Color = Color3.fromRGB(85, 255, 255), -- Cyan
	},

	Eternal = {
		Weight = 0.01,
		UnlockLevel = 9,
		UnlockCost = 250_000_000,
		Color = Color3.fromRGB(255, 255, 255), -- White
	},

	Secret = {
		Weight = 0.001,
		UnlockLevel = 10,
		UnlockCost = 1_000_000_000,
		Color = Color3.fromRGB(255, 0, 0), -- Red
	},
}

return RarityDatabase