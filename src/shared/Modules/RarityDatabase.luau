local RarityDatabase = {
	Common = {
		Weight = 60,
		Color = Color3.fromRGB(190, 190, 190), -- Gray
	},

	Uncommon = {
		Weight = 25,
		Color = Color3.fromRGB(85, 255, 85), -- Green
	},

	Rare = {
		Weight = 10,
		Color = Color3.fromRGB(85, 170, 255), -- Blue
	},

	Epic = {
		Weight = 4,
		Color = Color3.fromRGB(170, 85, 255), -- Purple
	},

	Legendary = {
		Weight = 1,
		Color = Color3.fromRGB(255, 170, 0), -- Orange
	},

	Mythic = {
		Weight = 0.5,
		Color = Color3.fromRGB(255, 0, 85), -- Magenta
	},

	Divine = {
		Weight = 0.2,
		Color = Color3.fromRGB(255, 255, 85), -- Gold
	},

	Celestial = {
		Weight = 0.05,
		Color = Color3.fromRGB(85, 255, 255), -- Cyan
	},

	Eternal = {
		Weight = 0.01,
		Color = Color3.fromRGB(255, 255, 255), -- White
	},

	Secret = {
		Weight = 0.001,
		Color = Color3.fromRGB(255, 0, 0), -- Red
	},
}

return RarityDatabase